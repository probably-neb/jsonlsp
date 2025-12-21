//! Test transport for LSP server testing.

const std = @import("std");
const lsp = @import("lsp");

pub const TestTransport = struct {
    transport: lsp.Transport,
    input_messages: []const []const u8,
    input_index: usize,
    output_messages: std.ArrayList([]const u8),
    allocator: std.mem.Allocator,

    const vtable: lsp.Transport.VTable = .{
        .readJsonMessage = read_json_message,
        .writeJsonMessage = write_json_message,
    };

    pub fn init(allocator: std.mem.Allocator, input_messages: []const []const u8) TestTransport {
        return .{
            .transport = .{ .vtable = &vtable },
            .input_messages = input_messages,
            .input_index = 0,
            .output_messages = .empty,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *TestTransport) void {
        for (self.output_messages.items) |msg| {
            self.allocator.free(msg);
        }
        self.output_messages.deinit(self.allocator);
    }

    pub fn get_output_messages(self: *const TestTransport) []const []const u8 {
        return self.output_messages.items;
    }

    pub fn reset(self: *TestTransport) void {
        for (self.output_messages.items) |msg| {
            self.allocator.free(msg);
        }
        self.output_messages.clearRetainingCapacity();
        self.input_index = 0;
    }

    fn read_json_message(transport_ptr: *lsp.Transport, allocator: std.mem.Allocator) lsp.Transport.ReadError![]u8 {
        const self: *TestTransport = @fieldParentPtr("transport", transport_ptr);

        if (self.input_index >= self.input_messages.len) {
            return error.EndOfStream;
        }

        const message = self.input_messages[self.input_index];
        self.input_index += 1;

        const copy = try allocator.alloc(u8, message.len);
        @memcpy(copy, message);
        return copy;
    }

    fn write_json_message(transport_ptr: *lsp.Transport, json_message: []const u8) lsp.Transport.WriteError!void {
        const self: *TestTransport = @fieldParentPtr("transport", transport_ptr);

        const copy = self.allocator.alloc(u8, json_message.len) catch return;
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

    const msg1 = try test_transport.transport.readJsonMessage(allocator);
    defer allocator.free(msg1);
    try std.testing.expectEqualStrings(inputs[0], msg1);

    const msg2 = try test_transport.transport.readJsonMessage(allocator);
    defer allocator.free(msg2);
    try std.testing.expectEqualStrings(inputs[1], msg2);

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

    const outputs = test_transport.get_output_messages();
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

    const msg = try test_transport.transport.readJsonMessage(allocator);
    defer allocator.free(msg);
    try test_transport.transport.writeJsonMessage(msg);

    try std.testing.expectEqual(@as(usize, 1), test_transport.get_output_messages().len);

    test_transport.reset();

    try std.testing.expectEqual(@as(usize, 0), test_transport.get_output_messages().len);
    try std.testing.expectEqual(@as(usize, 0), test_transport.input_index);
}
