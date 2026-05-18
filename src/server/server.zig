//! Server Subsystem
//!
//! Provides the core LSP server implementation including message handling,
//! document management, and the main server run loop.

const std = @import("std");

const base = @import("base");
const Arena = base.Arena;
const lsp = @import("lsp");

pub const documents = @import("documents.zig");
const DocumentStore = documents.DocumentStore;

const DIAGNOSTICS_BATCH_COUNT: usize = 512;

test {
    std.testing.refAllDecls(@This());
}

pub const ServerError = error{
    /// Server received exit notification after proper shutdown
    ServerShutdown,
    /// Server received exit notification without prior shutdown request
    ExitWithoutShutdown,
};

pub fn run(arena: *Arena, transport: *lsp.Transport) !void {
    {
        const scoped = arena.scoped();
        try wait_for_init(scoped.arena, transport);
        scoped.release();
    }

    var doc_store = DocumentStore.init();
    var diagnostics_buf = arena.alloc(lsp.types.Diagnostic, DIAGNOSTICS_BATCH_COUNT) catch @panic("OOM");
    defer doc_store.deinit();

    while (true) {
        var frame_arena = arena.scoped();
        defer frame_arena.release();
        const frame_alloc = frame_arena.arena.allocator();

        var document_iter = doc_store.iter();
        while (document_iter.next()) |doc_idx| {
            const document = doc_store.documents[doc_idx];
            if (!document.diagnostics_dirty) continue;
            @memset(diagnostics_buf, std.mem.zeroInit(lsp.types.Diagnostic, .{}));
            const diagnostic_count = doc_store.diagnostics_for_uri(frame_arena.arena, document.uri, diagnostics_buf);
            try transport.writeNotification(
                frame_alloc,
                "textDocument/publishDiagnostics",
                lsp.types.PublishDiagnosticsParams,
                .{
                    .uri = document.uri,
                    .version = document.snapshot.version,
                    .diagnostics = diagnostics_buf[0..diagnostic_count],
                },
                .{ .emit_null_optional_fields = true },
            );
            doc_store.mark_diagnostics_clean(doc_idx);
        }

        const json_message = try transport.readJsonMessage(frame_alloc);

        // parse the message
        const parsed_message: std.json.Parsed(Message) = try Message.parseFromSlice(
            arena.allocator(),
            json_message,
            .{ .ignore_unknown_fields = true },
        );
        defer parsed_message.deinit();

        // For the sake of simplicity, we will skip over some of the requirements for document synchronization and lifecycle messages:
        //
        // - https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_synchronization
        // - https://microsoft.github.io/language-server-protocol/specifications/specification-current/#lifeCycleMessages
        //
        // An actual LSP server implementation should try to comply with these requirements.

        switch (parsed_message.value) {
            .request => |request| std.log.debug("received '{s}' request from client", .{request.params.method()}),
            .notification => |notification| std.log.debug("received '{s}' notification from client", .{notification.params.method()}),
            .response => std.log.debug("received response from client", .{}),
        }

        switch (parsed_message.value) {
            // requests must send a response back to the client
            .request => |request| switch (request.params) {
                .shutdown => {
                    try shutdown_received(request.id, arena, transport);
                },
                .other => try transport.writeResponse(frame_alloc, request.id, void, {}, .{}),
            },
            .notification => |notification| switch (notification.params) {
                .initialized => {},
                .exit => return ServerError.ExitWithoutShutdown,
                .@"textDocument/didOpen" => |params| {
                    const doc = params.textDocument;
                    doc_store.open(doc.uri, doc.text, doc.version, doc.languageId) catch |err| {
                        switch (err) {
                            error.OpenDocumentLimitReached => {
                                std.log.err("Document limit reached. Could not open `{s}`", .{doc.uri});
                            },
                            error.DocumentAlreadyOpen => {
                                std.log.warn("Asked to open `{s}`, but it was already open", .{doc.uri});
                                continue;
                            },
                            else => {
                                std.log.err("Failed to open `{s}`: {}", .{ doc.uri, err });
                                continue;
                            },
                        }
                    };
                },
                .@"textDocument/didChange" => |params| {
                    const uri = params.textDocument.uri;
                    const version = params.textDocument.version;
                    for (params.contentChanges) |change| {
                        switch (change) {
                            .literal_0 => |incremental| {
                                doc_store.edit(uri, version, incremental.range, incremental.text) catch |err| {
                                    std.log.err("Failed to apply edit to `{s}`: {}", .{ uri, err });
                                };
                            },
                            .literal_1 => {
                                std.log.warn("Received full document change for `{s}` (full sync not supported)", .{uri});
                            },
                        }
                    }
                },
                .@"textDocument/didClose" => |params| {
                    const closed = doc_store.close(params.textDocument.uri);
                    if (!closed) {
                        std.log.warn("Asked to close `{s}`, but it wasn't open", .{params.textDocument.uri});
                        continue;
                    }
                },
                .other => {},
            },
            // We haven't sent any requests to the client.
            .response => @panic("TODO: implement response handler"),
        }
    }
}

fn wait_for_init(arena: *Arena, transport: *lsp.Transport) !void {
    const InitRequest = union(enum) {
        /// https://microsoft.github.io/language-server-protocol/specifications/specification-current/#initialize
        initialize: lsp.types.InitializeParams,
        shutdown,
        other: lsp.MethodWithParams,
    };
    const InitNotifications = union(enum) {
        /// https://microsoft.github.io/language-server-protocol/specifications/specification-current/#initialized
        initialized: lsp.types.InitializedParams,
        /// https://microsoft.github.io/language-server-protocol/specifications/specification-current/#exit
        exit,
        other: lsp.MethodWithParams,
    };

    const InitMessage = lsp.Message(InitRequest, InitNotifications, .{});
    const NON_INIT_MESSAGES_MAX = 10;
    for (0..NON_INIT_MESSAGES_MAX) |_| {
        var scoped = arena.scoped();
        defer scoped.release();
        const scoped_alloc = scoped.arena.allocator();

        const json_message = try transport.readJsonMessage(scoped_alloc);

        const parsed_message: std.json.Parsed(InitMessage) = try InitMessage.parseFromSlice(
            scoped_alloc,
            json_message,
            .{ .ignore_unknown_fields = true },
        );
        const message = parsed_message.value;

        switch (parsed_message.value) {
            .request => |request| {
                switch (request.params) {
                    .initialize => |params| {
                        _ = params.capabilities; // the client capabilities tell the server what "features" the client supports
                        try transport.writeResponse(
                            scoped_alloc,
                            request.id,
                            lsp.types.InitializeResult,
                            .{
                                // the server capabilities tell the client what "features" the server supports
                                .serverInfo = .{
                                    .name = "json-lsp",
                                    .version = "0.0.0",
                                },
                                .capabilities = .{
                                    .textDocumentSync = .{
                                        .TextDocumentSyncOptions = .{
                                            .openClose = true,
                                            .change = .Incremental,
                                        },
                                    },
                                },
                            },
                            .{ .emit_null_optional_fields = false },
                        );
                        return;
                    },
                    .shutdown => {
                        return shutdown_received(request.id, scoped.arena, transport);
                    },
                    .other => |other_request| {
                        std.log.warn("{s} request received before initialization", .{other_request.method});
                        try transport.writeErrorResponse(
                            scoped_alloc,
                            message.request.id,
                            .{ .code = @as(lsp.JsonRPCMessage.Response.Error.Code, @enumFromInt(-32002)), .message = "Server not initialized" },
                            .{ .emit_null_optional_fields = false },
                        );
                        continue;
                    },
                }
            },
            .notification => |notification| {
                if (notification.params == .exit) {
                    return ServerError.ExitWithoutShutdown;
                }
            },
            .response => {
                continue;
            },
        }
    }
    return error.FailedToReceiveInit;
}

fn shutdown_received(
    request_id: lsp.JsonRPCMessage.ID,
    arena: *Arena,
    transport: *lsp.Transport,
) !void {
    try transport.writeResponse(arena.allocator(), request_id, void, {}, .{});

    const ExitNotification = union(enum) {
        exit,
        other: lsp.MethodWithParams,
    };
    const ExitRequest = union(enum) {
        other: lsp.MethodWithParams,
    };

    const ExitMessage = lsp.Message(ExitRequest, ExitNotification, .{});

    const NON_EXIT_MESSAGES_MAX = 10;

    for (0..NON_EXIT_MESSAGES_MAX) |_| {
        const scoped = arena.scoped();
        defer scoped.release();
        const scoped_alloc = scoped.arena.allocator();

        const json_message = transport.readJsonMessage(scoped_alloc) catch |err| {
            std.log.err("Failed to read JSON message: {}", .{err});
            return err;
        };

        const parsed_message: std.json.Parsed(ExitMessage) = ExitMessage.parseFromSlice(
            scoped_alloc,
            json_message,
            .{ .ignore_unknown_fields = true },
        ) catch |err| {
            std.log.err("Failed to parse JSON message: {}", .{err});
            continue;
        };
        const message = parsed_message.value;
        switch (message) {
            .notification => |notification| {
                if (notification.params == .exit) {
                    return ServerError.ServerShutdown;
                }
            },
            .request => |request| {
                std.log.warn("{s} request received while awaiting exit notification", .{request.params.other.method});

                transport.writeErrorResponse(
                    scoped_alloc,
                    request.id,
                    .{
                        .code = .invalid_request,
                        .message = "Server shutting down",
                    },
                    .{ .emit_null_optional_fields = false },
                ) catch |err| {
                    std.log.err("Failed to write error response: {}", .{err});
                };
            },
            .response => {},
        }
    }
    std.log.err("Exit notification never received", .{});
    return error.ExitNotReceived;
}

pub const Message = lsp.Message(RequestMethods, NotificationMethods, .{});

pub const RequestMethods = union(enum) {
    /// https://microsoft.github.io/language-server-protocol/specifications/specification-current/#shutdown
    shutdown,
    other: lsp.MethodWithParams,

    pub fn method(msg: RequestMethods) []const u8 {
        return switch (msg) {
            .other => |other| other.method,
            else => @tagName(msg),
        };
    }
};

pub const NotificationMethods = union(enum) {
    /// https://microsoft.github.io/language-server-protocol/specifications/specification-current/#initialized
    initialized: lsp.types.InitializedParams,
    /// https://microsoft.github.io/language-server-protocol/specifications/specification-current/#exit
    exit,
    /// https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_didOpen
    @"textDocument/didOpen": lsp.types.DidOpenTextDocumentParams,
    /// https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_didChange
    @"textDocument/didChange": lsp.types.DidChangeTextDocumentParams,
    /// https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_didClose
    @"textDocument/didClose": lsp.types.DidCloseTextDocumentParams,
    other: lsp.MethodWithParams,

    pub fn method(notif: NotificationMethods) []const u8 {
        return switch (notif) {
            .other => |other| other.method,
            else => @tagName(notif),
        };
    }
};

test {
    std.testing.refAllDecls(@This());
}
