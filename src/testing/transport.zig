//! Test transport for LSP server testing.
//!
//! Provides a mock transport that queues input messages and captures output messages,
//! allowing tests to run the server without real I/O.

const std = @import("std");
const lsp = @import("lsp");

/// A test transport that reads from a queue of input messages and captures output messages.
pub const TestTransport = struct {
    /// The transport interface that can be passed to server.run()
    transport: lsp.Transport,
    /// Pre-configured input messages to be returned by readJsonMessage
    input_messages: []const []const u8,
    /// Current index into input_messages
    input_index: usize,
    /// Captured output messages written by the server
    output_messages: std.ArrayList([]const u8),
    /// Allocator for copying output messages
    allocator: std.mem.Allocator,

    const vtable: lsp.Transport.VTable = .{
        .readJsonMessage = readJsonMessage,
        .writeJsonMessage = writeJsonMessage,
    };

    /// Initialize a TestTransport with a queue of input messages.
    ///
    /// The input_messages slice must remain valid for the lifetime of the TestTransport.
    pub fn init(allocator: std.mem.Allocator, input_messages: []const []const u8) TestTransport {
        return .{
            .transport = .{ .vtable = &vtable },
            .input_messages = input_messages,
            .input_index = 0,
            .output_messages = .empty,
            .allocator = allocator,
        };
    }

    /// Free all captured output messages and the output list.
    pub fn deinit(self: *TestTransport) void {
        for (self.output_messages.items) |msg| {
            self.allocator.free(msg);
        }
        self.output_messages.deinit(self.allocator);
    }

    /// Get the captured output messages.
    pub fn getOutputMessages(self: *const TestTransport) []const []const u8 {
        return self.output_messages.items;
    }

    /// Reset the transport for reuse - clears output and resets input index.
    pub fn reset(self: *TestTransport) void {
        for (self.output_messages.items) |msg| {
            self.allocator.free(msg);
        }
        self.output_messages.clearRetainingCapacity();
        self.input_index = 0;
    }

    fn readJsonMessage(transport_ptr: *lsp.Transport, allocator: std.mem.Allocator) lsp.Transport.ReadError![]u8 {
        const self: *TestTransport = @fieldParentPtr("transport", transport_ptr);

        if (self.input_index >= self.input_messages.len) {
            return error.EndOfStream;
        }

        const message = self.input_messages[self.input_index];
        self.input_index += 1;

        // Copy the message using the provided allocator (as the real transport would)
        const copy = try allocator.alloc(u8, message.len);
        @memcpy(copy, message);
        return copy;
    }

    fn writeJsonMessage(transport_ptr: *lsp.Transport, json_message: []const u8) lsp.Transport.WriteError!void {
        const self: *TestTransport = @fieldParentPtr("transport", transport_ptr);

        // Copy the message to capture it
        const copy = self.allocator.alloc(u8, json_message.len) catch {
            // WriteError doesn't include allocation errors, so we can't propagate this properly.
            // In practice, this shouldn't happen in tests with reasonable message sizes.
            return;
        };
        @memcpy(copy, json_message);

        self.output_messages.append(self.allocator, copy) catch {
            self.allocator.free(copy);
            return;
        };
    }
};

test "TestTransport reads input messages in order" {
    const allocator = std.testing.allocator;

    const inputs: []const []const u8 = &.{
        \\{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}
        ,
        \\{"jsonrpc":"2.0","method":"exit"}
        ,
    };

    var test_transport = TestTransport.init(allocator, inputs);
    defer test_transport.deinit();

    // Read first message
    const msg1 = try test_transport.transport.readJsonMessage(allocator);
    defer allocator.free(msg1);
    try std.testing.expectEqualStrings(inputs[0], msg1);

    // Read second message
    const msg2 = try test_transport.transport.readJsonMessage(allocator);
    defer allocator.free(msg2);
    try std.testing.expectEqualStrings(inputs[1], msg2);

    // Third read should return EndOfStream
    const result = test_transport.transport.readJsonMessage(allocator);
    try std.testing.expectError(error.EndOfStream, result);
}

test "TestTransport captures output messages" {
    const allocator = std.testing.allocator;

    var test_transport = TestTransport.init(allocator, &.{});
    defer test_transport.deinit();

    const msg1 =
        \\{"jsonrpc":"2.0","id":1,"result":{"capabilities":{}}}
    ;
    const msg2 =
        \\{"jsonrpc":"2.0","id":2,"result":null}
    ;

    try test_transport.transport.writeJsonMessage(msg1);
    try test_transport.transport.writeJsonMessage(msg2);

    const outputs = test_transport.getOutputMessages();
    try std.testing.expectEqual(@as(usize, 2), outputs.len);
    try std.testing.expectEqualStrings(msg1, outputs[0]);
    try std.testing.expectEqualStrings(msg2, outputs[1]);
}

test "TestTransport reset clears state" {
    const allocator = std.testing.allocator;

    const inputs: []const []const u8 = &.{
        \\{"jsonrpc":"2.0","method":"test"}
        ,
    };

    var test_transport = TestTransport.init(allocator, inputs);
    defer test_transport.deinit();

    // Read and write
    const msg = try test_transport.transport.readJsonMessage(allocator);
    defer allocator.free(msg);
    try test_transport.transport.writeJsonMessage(msg);

    try std.testing.expectEqual(@as(usize, 1), test_transport.getOutputMessages().len);

    // Reset
    test_transport.reset();

    try std.testing.expectEqual(@as(usize, 0), test_transport.getOutputMessages().len);
    try std.testing.expectEqual(@as(usize, 0), test_transport.input_index);
}
