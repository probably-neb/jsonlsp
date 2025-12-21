//! TODO: Handle init/shutdown

const std = @import("std");
const Alloc = std.mem.Allocator;
const builtin = @import("builtin");
const base = @import("base");

const Arena = base.Arena;

const lsp = @import("lsp");

const documents = @import("documents.zig");

pub const std_options: std.Options = .{
    .log_level = std.log.default_level, // Customize the log level here
};

pub fn main() !void {
    var arena: Arena = try .init(.{});

    // Language servers can support multiple communication channels (e.g. stdio, pipes, sockets).
    // See https://microsoft.github.io/language-server-protocol/specifications/specification-current/#implementationConsiderations
    //
    // The `lsp.Transport.Stdio` implements the necessary logic to read and write messages over stdio.
    var read_buffer: [256]u8 = undefined;
    var stdio_transport: lsp.Transport.Stdio = .init(&read_buffer, .stdin(), .stdout());
    const transport: *lsp.Transport = &stdio_transport.transport;

    {
        const scoped = arena.scoped();
        try wait_for_init(scoped.arena, transport);
        scoped.release();
    }

    documents.init();

    while (true) {
        var frame_arena = arena.scoped();
        defer frame_arena.release();
        const frame_alloc = frame_arena.arena.allocator();

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
                    shutdown_received(request.id, &arena, transport);
                },
                .other => try transport.writeResponse(frame_alloc, request.id, void, {}, .{}),
            },
            .notification => |notification| switch (notification.params) {
                .initialized => {},
                .exit => return,
                .@"textDocument/didOpen" => |params| {
                    const doc = params.textDocument;
                    documents.open(doc.uri, doc.text, doc.version, doc.languageId) catch |err| {
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
                .@"textDocument/didChange" => |_| {},
                .@"textDocument/didClose" => |params| {
                    const closed = documents.close(params.textDocument.uri);
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

// WIP:
// - following spec to wait for initialize request or shutdown + exit
// - partially implemented
// - needs loop waiting on initialized notif to be split out and after a successful initialization req
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
                                            .change = .None,
                                        },
                                    },
                                },
                            },
                            .{ .emit_null_optional_fields = false },
                        );
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
                            .{ .emit_null_optional_fields = true },
                        );
                        continue;
                    },
                }
            },
            .notification => |notification| {
                if (notification.params == .exit) {
                    exit_received_without_shutdown();
                }
            },
            .response => |_| {
                continue;
            },
        }
    } else {
        return error.FailedToReceiveInit;
    }
}

/// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#exit
fn exit_received_without_shutdown() noreturn {
    std.process.exit(1);
}

fn shutdown_received(
    request_id: lsp.JsonRPCMessage.ID,
    arena: *Arena,
    transport: *lsp.Transport,
) noreturn {
    transport.writeResponse(arena.allocator(), request_id, void, {}, .{}) catch |err| {
        std.log.err("Failed to write shutdown response: {}", .{err});
        std.process.exit(1);
    };

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
            std.process.exit(1);
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
                    std.process.exit(0);
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
                    .{ .emit_null_optional_fields = true },
                ) catch |err| {
                    std.log.err("Failed to write error response: {}", .{err});
                };
            },
            .response => |_| {},
        }
    } else {
        std.log.err("Exit notification never received", .{});
        std.process.exit(1);
    }
}

const Message = lsp.Message(RequestMethods, NotificationMethods, .{});

const RequestMethods = union(enum) {
    /// https://microsoft.github.io/language-server-protocol/specifications/specification-current/#shutdown
    shutdown,
    other: lsp.MethodWithParams,

    fn method(msg: RequestMethods) []const u8 {
        return switch (msg) {
            .other => |other| other.method,
            else => @tagName(msg),
        };
    }
};

const NotificationMethods = union(enum) {
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

    fn method(notif: NotificationMethods) []const u8 {
        return switch (notif) {
            .other => |other| other.method,
            else => @tagName(notif),
        };
    }
};

test {
    std.testing.refAllDecls(@This());
}
