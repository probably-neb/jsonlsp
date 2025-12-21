//! Snapshot test runner.

const std = @import("std");
const Allocator = std.mem.Allocator;

const base = @import("base");
const Arena = base.Arena;

const compare = @import("compare.zig");
const server = @import("server");
const snapshot_mod = @import("snapshot.zig");
const transport_mod = @import("transport.zig");

const Snapshot = snapshot_mod.Snapshot;
const Direction = snapshot_mod.Direction;
const TestTransport = transport_mod.TestTransport;

pub const TestResult = struct {
    passed: bool,
    expected_messages: []const []const u8,
    actual_messages: []const []const u8,
    first_mismatch_index: ?usize,
    allocator: Allocator,

    pub fn deinit(self: *TestResult) void {
        self.allocator.free(self.expected_messages);
        for (self.actual_messages) |msg| {
            self.allocator.free(msg);
        }
        self.allocator.free(self.actual_messages);
        self.* = undefined;
    }
};

pub const RunError = error{
    Timeout,
    ServerError,
    ParseError,
    OutOfMemory,
};

const ServerThreadContext = struct {
    transport: *TestTransport,
    completed: *std.atomic.Value(bool),
    server_error: *?anyerror,
    arena: *Arena,
};

fn server_thread_fn(ctx: ServerThreadContext) void {
    defer ctx.completed.store(true, .release);

    server.run(ctx.arena, &ctx.transport.transport) catch |err| {
        switch (err) {
            error.ServerShutdown => {},
            else => ctx.server_error.* = err,
        }
    };
}

pub fn run_test(allocator: Allocator, snap: Snapshot, timeout_ms: u64) RunError!TestResult {
    var send_list: std.ArrayListUnmanaged([]const u8) = .empty;
    defer send_list.deinit(allocator);

    var expect_list: std.ArrayListUnmanaged([]const u8) = .empty;
    defer expect_list.deinit(allocator);

    for (snap.messages) |msg| {
        switch (msg.direction) {
            .send => send_list.append(allocator, msg.json) catch return error.OutOfMemory,
            .expect => expect_list.append(allocator, msg.json) catch return error.OutOfMemory,
        }
    }

    var test_transport = TestTransport.init(allocator, send_list.items);
    defer test_transport.deinit();

    var arena = Arena.init(.{}) catch return error.OutOfMemory;
    defer arena.deinit();

    var completed = std.atomic.Value(bool).init(false);
    var server_error: ?anyerror = null;

    const ctx = ServerThreadContext{
        .transport = &test_transport,
        .completed = &completed,
        .server_error = &server_error,
        .arena = &arena,
    };

    const thread = std.Thread.spawn(.{}, server_thread_fn, .{ctx}) catch return error.ServerError;

    const timeout_ns = timeout_ms * std.time.ns_per_ms;
    const start_time = std.time.nanoTimestamp();

    const poll_interval_ns: u64 = 1 * std.time.ns_per_ms;
    while (!completed.load(.acquire)) {
        const elapsed: u64 = @intCast(std.time.nanoTimestamp() - start_time);
        if (elapsed >= timeout_ns) {
            return error.Timeout;
        }
        std.Thread.sleep(poll_interval_ns);
    }

    thread.join();

    if (server_error) |_| {
        return error.ServerError;
    }

    const actual_outputs = test_transport.get_output_messages();

    const expected_copy = allocator.alloc([]const u8, expect_list.items.len) catch return error.OutOfMemory;
    @memcpy(expected_copy, expect_list.items);

    const actual_copy = allocator.alloc([]const u8, actual_outputs.len) catch return error.OutOfMemory;
    errdefer allocator.free(actual_copy);
    for (actual_outputs, 0..) |msg, i| {
        actual_copy[i] = allocator.dupe(u8, msg) catch return error.OutOfMemory;
    }

    const compare_result = compare_messages(allocator, expected_copy, actual_copy);

    return .{
        .passed = compare_result.passed,
        .expected_messages = expected_copy,
        .actual_messages = actual_copy,
        .first_mismatch_index = compare_result.first_mismatch_index,
        .allocator = allocator,
    };
}

const CompareResult = struct {
    passed: bool,
    first_mismatch_index: ?usize,
};

fn compare_messages(allocator: Allocator, expected: []const []const u8, actual: []const []const u8) CompareResult {
    if (expected.len != actual.len) {
        const min_len = @min(expected.len, actual.len);
        for (0..min_len) |i| {
            if (!compare.json_eql(allocator, expected[i], actual[i])) {
                return .{ .passed = false, .first_mismatch_index = i };
            }
        }
        return .{ .passed = false, .first_mismatch_index = min_len };
    }

    for (expected, actual, 0..) |exp, act, i| {
        if (!compare.json_eql(allocator, exp, act)) {
            return .{ .passed = false, .first_mismatch_index = i };
        }
    }

    return .{ .passed = true, .first_mismatch_index = null };
}

// Tests

test "run simple init/shutdown/exit" {
    const allocator = std.testing.allocator;

    const content =
        \\>>>
        \\{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}
        \\
        \\<<<
        \\{"jsonrpc":"2.0","id":1,"result":{"capabilities":{"textDocumentSync":{"openClose":true,"change":0}},"serverInfo":{"name":"json-lsp","version":"0.0.0"}}}
        \\
        \\>>>
        \\{"jsonrpc":"2.0","method":"initialized","params":{}}
        \\
        \\>>>
        \\{"jsonrpc":"2.0","id":2,"method":"shutdown"}
        \\
        \\<<<
        \\{"jsonrpc":"2.0","id":2,"result":null}
        \\
        \\>>>
        \\{"jsonrpc":"2.0","method":"exit"}
    ;

    var snap = try snapshot_mod.parse(allocator, content);
    defer snap.deinit();

    var result = try run_test(allocator, snap, 5000);
    defer result.deinit();

    try std.testing.expect(result.passed);
    try std.testing.expectEqual(@as(?usize, null), result.first_mismatch_index);
}

test "mismatch detected" {
    const allocator = std.testing.allocator;

    const content =
        \\>>>
        \\{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}
        \\
        \\<<<
        \\{"jsonrpc":"2.0","id":1,"result":{"wrong":"response"}}
        \\
        \\>>>
        \\{"jsonrpc":"2.0","method":"initialized","params":{}}
        \\
        \\>>>
        \\{"jsonrpc":"2.0","id":2,"method":"shutdown"}
        \\
        \\<<<
        \\{"jsonrpc":"2.0","id":2,"result":null}
        \\
        \\>>>
        \\{"jsonrpc":"2.0","method":"exit"}
    ;

    var snap = try snapshot_mod.parse(allocator, content);
    defer snap.deinit();

    var result = try run_test(allocator, snap, 5000);
    defer result.deinit();

    try std.testing.expect(!result.passed);
    try std.testing.expectEqual(@as(?usize, 0), result.first_mismatch_index);
}

test "timeout triggers" {
    const allocator = std.testing.allocator;

    const content =
        \\>>>
        \\{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}
    ;

    var snap = try snapshot_mod.parse(allocator, content);
    defer snap.deinit();

    const result = run_test(allocator, snap, 100);
    try std.testing.expectError(error.ServerError, result);
}
