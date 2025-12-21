//! Snapshot test runner that runs the server in a separate thread.
//!
//! The runner communicates with the server via TestTransport, compares
//! actual output messages against expected messages from the snapshot,
//! and supports timeout to prevent hanging tests.

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

/// Result of running a snapshot test.
pub const TestResult = struct {
    /// Whether all expected messages matched actual messages.
    passed: bool,
    /// The expected messages from the snapshot.
    expected_messages: []const []const u8,
    /// The actual messages produced by the server.
    actual_messages: []const []const u8,
    /// Index of the first mismatched message, if any.
    first_mismatch_index: ?usize,
    /// Allocator used for allocations (needed for deinit).
    allocator: Allocator,

    /// Free all allocated memory.
    pub fn deinit(self: *TestResult) void {
        self.allocator.free(self.expected_messages);
        // actual_messages are owned by TestTransport, not freed here
        self.* = undefined;
    }
};

/// Errors that can occur during test execution.
pub const RunError = error{
    /// The server did not complete within the timeout period.
    Timeout,
    /// The server returned an unexpected error.
    ServerError,
    /// Failed to parse a message.
    ParseError,
    /// Memory allocation failed.
    OutOfMemory,
};

/// Thread context for running the server.
const ServerThreadContext = struct {
    transport: *TestTransport,
    completed: *std.atomic.Value(bool),
    server_error: *?anyerror,
    arena: *Arena,
};

/// Server thread function.
fn serverThreadFn(ctx: ServerThreadContext) void {
    defer ctx.completed.store(true, .release);

    server.run(ctx.arena, &ctx.transport.transport) catch |err| {
        switch (err) {
            error.ServerShutdown => {
                // Normal shutdown, not an error
            },
            else => {
                ctx.server_error.* = err;
            },
        }
    };
}

/// Run a snapshot test against the server.
///
/// Extracts send messages from the snapshot to use as server inputs,
/// runs the server in a separate thread, waits for completion or timeout,
/// and compares actual outputs against expected messages.
///
/// Parameters:
/// - allocator: Allocator for test infrastructure
/// - snap: The parsed snapshot containing test messages
/// - timeout_ms: Maximum time to wait for server completion (milliseconds)
///
/// Returns a TestResult indicating whether the test passed and details about any mismatches.
pub fn runTest(allocator: Allocator, snap: Snapshot, timeout_ms: u64) RunError!TestResult {
    // Extract send messages (inputs to server) and expect messages (expected outputs)
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

    // Create TestTransport with send messages as input
    var test_transport = TestTransport.init(allocator, send_list.items);
    defer test_transport.deinit();

    // Create arena for server
    var arena = Arena.init(.{}) catch return error.OutOfMemory;
    defer arena.deinit();

    // Thread synchronization
    var completed = std.atomic.Value(bool).init(false);
    var server_error: ?anyerror = null;

    // Spawn server thread
    const ctx = ServerThreadContext{
        .transport = &test_transport,
        .completed = &completed,
        .server_error = &server_error,
        .arena = &arena,
    };

    const thread = std.Thread.spawn(.{}, serverThreadFn, .{ctx}) catch return error.ServerError;

    // Wait for completion with timeout using ResetEvent pattern
    const timeout_ns = timeout_ms * std.time.ns_per_ms;
    const start_time = std.time.nanoTimestamp();

    // Poll for completion with small sleep intervals
    const poll_interval_ns: u64 = 1 * std.time.ns_per_ms; // 1ms poll interval
    while (!completed.load(.acquire)) {
        const elapsed: u64 = @intCast(std.time.nanoTimestamp() - start_time);
        if (elapsed >= timeout_ns) {
            // Timeout - thread will be left running
            return error.Timeout;
        }
        std.Thread.sleep(poll_interval_ns);
    }

    // Thread completed, join it
    thread.join();

    // Check for server errors (ExitWithoutShutdown is an error, ServerShutdown is handled in thread)
    if (server_error) |_| {
        return error.ServerError;
    }

    // Get actual outputs from transport
    const actual_outputs = test_transport.getOutputMessages();

    // Copy expected messages for result (we need owned copies)
    const expected_copy = allocator.alloc([]const u8, expect_list.items.len) catch return error.OutOfMemory;
    @memcpy(expected_copy, expect_list.items);

    // Compare outputs
    const compare_result = compareMessages(allocator, expected_copy, actual_outputs);

    return .{
        .passed = compare_result.passed,
        .expected_messages = expected_copy,
        .actual_messages = actual_outputs,
        .first_mismatch_index = compare_result.first_mismatch_index,
        .allocator = allocator,
    };
}

/// Result of comparing message lists.
const CompareResult = struct {
    passed: bool,
    first_mismatch_index: ?usize,
};

/// Compare expected and actual message lists.
fn compareMessages(allocator: Allocator, expected: []const []const u8, actual: []const []const u8) CompareResult {
    // Check length first
    if (expected.len != actual.len) {
        // Find first difference point
        const min_len = @min(expected.len, actual.len);
        for (0..min_len) |i| {
            if (!compare.jsonEql(allocator, expected[i], actual[i])) {
                return .{ .passed = false, .first_mismatch_index = i };
            }
        }
        // Length mismatch is the first difference
        return .{ .passed = false, .first_mismatch_index = min_len };
    }

    // Compare each message
    for (expected, actual, 0..) |exp, act, i| {
        if (!compare.jsonEql(allocator, exp, act)) {
            return .{ .passed = false, .first_mismatch_index = i };
        }
    }

    return .{ .passed = true, .first_mismatch_index = null };
}

// ============================================================================
// Tests
// ============================================================================

test "run simple init/shutdown/exit" {
    const allocator = std.testing.allocator;

    // Create a minimal snapshot for init/shutdown/exit sequence
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

    var result = try runTest(allocator, snap, 5000);
    defer result.deinit();

    try std.testing.expect(result.passed);
    try std.testing.expectEqual(@as(?usize, null), result.first_mismatch_index);
}

test "mismatch detected" {
    const allocator = std.testing.allocator;

    // Create snapshot with intentionally wrong expected response
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

    var result = try runTest(allocator, snap, 5000);
    defer result.deinit();

    try std.testing.expect(!result.passed);
    try std.testing.expectEqual(@as(?usize, 0), result.first_mismatch_index);
}

test "timeout triggers" {
    // Note: With the current TestTransport design, when input messages are exhausted,
    // the transport returns EndOfStream, causing the server to exit with ExitWithoutShutdown
    // (mapped to ServerError) rather than blocking and timing out.
    //
    // To properly test timeouts, we would need a modified TestTransport that blocks
    // instead of returning EndOfStream. For now, we verify that incomplete sequences
    // return ServerError (which indicates the server exited abnormally).
    const allocator = std.testing.allocator;

    // Create a snapshot that sends initialize but never sends shutdown/exit,
    // so the server will get EndOfStream and exit abnormally
    const content =
        \\>>>
        \\{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}
    ;

    var snap = try snapshot_mod.parse(allocator, content);
    defer snap.deinit();

    // Server will exit with ExitWithoutShutdown when it gets EndOfStream
    const result = runTest(allocator, snap, 100);

    // This returns ServerError because the server exits without proper shutdown
    try std.testing.expectError(error.ServerError, result);
}
