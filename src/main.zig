//! TODO: Handle init/shutdown

const std = @import("std");
const builtin = @import("builtin");
const lsp = @import("lsp");
const Alloc = std.mem.Allocator;

pub const std_options: std.Options = .{
    .log_level = std.log.default_level, // Customize the log level here
};

var debug_allocator: std.heap.DebugAllocator(.{}) = .init;

pub fn main() !void {
    const gpa, const is_debug = switch (builtin.mode) {
        .Debug, .ReleaseSafe => .{ debug_allocator.allocator(), true },
        .ReleaseFast, .ReleaseSmall => .{ std.heap.smp_allocator, false },
    };
    defer if (is_debug) {
        _ = debug_allocator.deinit();
    };

    // Language servers can support multiple communication channels (e.g. stdio, pipes, sockets).
    // See https://microsoft.github.io/language-server-protocol/specifications/specification-current/#implementationConsiderations
    //
    // The `lsp.Transport.Stdio` implements the necessary logic to read and write messages over stdio.
    var read_buffer: [256]u8 = undefined;
    var stdio_transport: lsp.Transport.Stdio = .init(&read_buffer, .stdin(), .stdout());
    const transport: *lsp.Transport = &stdio_transport.transport;

    try wait_for_init(gpa, transport);

    // keep track of opened documents
    var documents: std.StringArrayHashMapUnmanaged([]const u8) = .empty;
    defer {
        for (documents.keys()) |uri| gpa.free(uri);
        for (documents.values()) |source| gpa.free(source);
        documents.deinit(gpa);
    }

    while (true) {
        // read the unparsed JSON-RPC message
        const json_message = try transport.readJsonMessage(gpa);
        defer gpa.free(json_message);
        // std.log.debug("received message from client: {s}", .{json_message});

        // parse the message
        const parsed_message: std.json.Parsed(Message) = try Message.parseFromSlice(
            gpa,
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
            .request => |request| std.log.debug("received '{s}' request from client", .{@tagName(request.params)}),
            .notification => |notification| std.log.debug("received '{s}' notification from client", .{@tagName(notification.params)}),
            .response => std.log.debug("received response from client", .{}),
        }

        switch (parsed_message.value) {
            // requests must send a response back to the client
            .request => |request| switch (request.params) {
                .shutdown => {
                    shutdown_received(request.id, gpa, transport);
                },
                .other => try transport.writeResponse(gpa, request.id, void, {}, .{}),
            },
            .notification => |notification| switch (notification.params) {
                .initialized => {},
                .exit => return,
                .@"textDocument/didOpen" => |params| {
                    // The client has given us a document. We must use it over what is actually located on the file system.

                    const duped_uri = try gpa.dupe(u8, params.textDocument.uri);
                    errdefer gpa.free(duped_uri);
                    const duped_text = try gpa.dupe(u8, params.textDocument.text);
                    errdefer gpa.free(duped_text);

                    const gop = try documents.getOrPutValue(gpa, duped_uri, duped_text);
                    if (gop.found_existing) @panic("document opened twice");
                },
                .@"textDocument/didChange" => |_| {},
                .@"textDocument/didClose" => |params| {
                    const old_entry = documents.fetchOrderedRemove(params.textDocument.uri) orelse continue;
                    gpa.free(old_entry.key);
                    gpa.free(old_entry.value);
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
fn wait_for_init(gpa: Alloc, transport: *lsp.Transport) !void {
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
        const json_message = try transport.readJsonMessage(gpa);
        defer gpa.free(json_message);

        const parsed_message: std.json.Parsed(InitMessage) = try InitMessage.parseFromSlice(
            gpa,
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
                            gpa,
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
                        return shutdown_received(request.id, gpa, transport);
                    },
                    .other => |other_request| {
                        std.log.warn("{s} request received before initialization", .{other_request.method});
                        try transport.writeErrorResponse(
                            gpa,
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
    gpa: Alloc,
    transport: *lsp.Transport,
) noreturn {
    try transport.writeResponse(gpa, request_id, void, {}, .{});

    const ExitNotification = union(enum) {
        exit,
    };
    const ExitRequest = union(enum) {
        unexpected: lsp.MethodWithParams,
    };

    const ExitMessage = lsp.Message(ExitRequest, ExitNotification, .{});

    const NON_EXIT_MESSAGES_MAX = 10;

    for (0..NON_EXIT_MESSAGES_MAX) |_| {
        const json_message = transport.readJsonMessage(gpa) catch |err| {
            std.log.err("Failed to read JSON message: {}", .{err});
            std.process.exit(1);
        };
        defer gpa.free(json_message);

        const parsed_message: std.json.Parsed(ExitMessage) = ExitMessage.parseFromSlice(
            gpa,
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
                std.log.warn("{s} request received before initialization", .{request.params.unexpected.method});

                transport.writeErrorResponse(
                    gpa,
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
};
