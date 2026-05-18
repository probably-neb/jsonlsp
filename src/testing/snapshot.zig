//! Snapshot parser and serializer for LSP message testing.

const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Direction = enum {
    send,
    expect,
};

pub const Message = struct {
    direction: Direction,
    json: []const u8,
    line_start: u32,
};

pub const Snapshot = struct {
    messages: []const Message,
    allocator: Allocator,

    pub fn deinit(self: *Snapshot) void {
        for (self.messages) |msg| {
            self.allocator.free(msg.json);
        }
        self.allocator.free(self.messages);
        self.* = undefined;
    }
};

pub const ParseError = error{
    InvalidDirectionMarker,
    EmptyMessage,
    UnexpectedContent,
    OutOfMemory,
};

const ParseState = enum {
    looking_for_marker,
    reading_json,
};

pub fn parse(allocator: Allocator, content: []const u8) ParseError!Snapshot {
    var messages: std.ArrayList(Message) = .empty;
    errdefer {
        for (messages.items) |msg| {
            allocator.free(msg.json);
        }
        messages.deinit(allocator);
    }

    var json_lines: std.ArrayList([]const u8) = .empty;
    defer json_lines.deinit(allocator);

    var state: ParseState = .looking_for_marker;
    var current_direction: Direction = undefined;
    var current_line_start: u32 = 0;

    var line_number: u32 = 0;
    var lines = std.mem.splitScalar(u8, content, '\n');

    while (lines.next()) |raw_line| {
        line_number += 1;
        const line = std.mem.trimEnd(u8, raw_line, "\r");
        const trimmed = std.mem.trim(u8, line, " \t");

        switch (state) {
            .looking_for_marker => {
                if (trimmed.len == 0) {
                    continue;
                }

                if (std.mem.eql(u8, trimmed, ">>>")) {
                    state = .reading_json;
                    current_direction = .send;
                    current_line_start = line_number;
                    json_lines.clearRetainingCapacity();
                } else if (std.mem.eql(u8, trimmed, "<<<")) {
                    state = .reading_json;
                    current_direction = .expect;
                    current_line_start = line_number;
                    json_lines.clearRetainingCapacity();
                } else {
                    return ParseError.UnexpectedContent;
                }
            },
            .reading_json => {
                const is_blank = trimmed.len == 0;
                const is_marker = std.mem.eql(u8, trimmed, ">>>") or std.mem.eql(u8, trimmed, "<<<");

                if (is_blank or is_marker) {
                    if (json_lines.items.len == 0) {
                        return ParseError.EmptyMessage;
                    }

                    const json = try std.mem.join(allocator, "\n", json_lines.items);
                    errdefer allocator.free(json);

                    try messages.append(allocator, .{
                        .direction = current_direction,
                        .json = json,
                        .line_start = current_line_start,
                    });

                    json_lines.clearRetainingCapacity();

                    if (is_marker) {
                        if (std.mem.eql(u8, trimmed, ">>>")) {
                            current_direction = .send;
                        } else {
                            current_direction = .expect;
                        }
                        current_line_start = line_number;
                    } else {
                        state = .looking_for_marker;
                    }
                } else {
                    try json_lines.append(allocator, line);
                }
            },
        }
    }

    if (state == .reading_json) {
        if (json_lines.items.len == 0) {
            return ParseError.EmptyMessage;
        }

        const json = try std.mem.join(allocator, "\n", json_lines.items);
        errdefer allocator.free(json);

        try messages.append(allocator, .{
            .direction = current_direction,
            .json = json,
            .line_start = current_line_start,
        });
    }

    return .{
        .messages = try messages.toOwnedSlice(allocator),
        .allocator = allocator,
    };
}

pub fn serialize(self: Snapshot, allocator: Allocator) ![]const u8 {
    var output: std.ArrayList(u8) = .empty;
    errdefer output.deinit(allocator);

    for (self.messages, 0..) |msg, i| {
        if (i > 0) {
            try output.append(allocator, '\n');
        }

        const marker: []const u8 = switch (msg.direction) {
            .send => ">>>",
            .expect => "<<<",
        };
        try output.appendSlice(allocator, marker);
        try output.append(allocator, '\n');

        if (msg.direction == .expect) {
            const parsed = std.json.parseFromSlice(std.json.Value, allocator, msg.json, .{}) catch {
                try output.appendSlice(allocator, msg.json);
                try output.append(allocator, '\n');
                continue;
            };
            defer parsed.deinit();

            const pretty_json = try std.json.Stringify.valueAlloc(allocator, parsed.value, .{ .whitespace = .indent_2 });
            defer allocator.free(pretty_json);
            try output.appendSlice(allocator, pretty_json);
            try output.append(allocator, '\n');
        } else {
            try output.appendSlice(allocator, msg.json);
            try output.append(allocator, '\n');
        }
    }

    return try output.toOwnedSlice(allocator);
}

// ============================================================================
// Tests
// ============================================================================

test "parse empty file" {
    const allocator = std.testing.allocator;
    var snapshot = try parse(allocator, "");
    defer snapshot.deinit();

    try std.testing.expectEqual(@as(usize, 0), snapshot.messages.len);
}

test "parse single send message" {
    const allocator = std.testing.allocator;
    const content =
        \\>>>
        \\{
        \\  "jsonrpc": "2.0",
        \\  "id": 1
        \\}
    ;

    var snapshot = try parse(allocator, content);
    defer snapshot.deinit();

    try std.testing.expectEqual(@as(usize, 1), snapshot.messages.len);
    try std.testing.expectEqual(Direction.send, snapshot.messages[0].direction);
    try std.testing.expectEqual(@as(u32, 1), snapshot.messages[0].line_start);
    try std.testing.expectEqualStrings(
        \\{
        \\  "jsonrpc": "2.0",
        \\  "id": 1
        \\}
    , snapshot.messages[0].json);
}

test "parse send and expect" {
    const allocator = std.testing.allocator;
    const content =
        \\>>>
        \\{"id": 1}
        \\
        \\<<<
        \\{"id": 1, "result": null}
    ;

    var snapshot = try parse(allocator, content);
    defer snapshot.deinit();

    try std.testing.expectEqual(@as(usize, 2), snapshot.messages.len);

    try std.testing.expectEqual(Direction.send, snapshot.messages[0].direction);
    try std.testing.expectEqualStrings("{\"id\": 1}", snapshot.messages[0].json);

    try std.testing.expectEqual(Direction.expect, snapshot.messages[1].direction);
    try std.testing.expectEqualStrings("{\"id\": 1, \"result\": null}", snapshot.messages[1].json);
}

test "parse multiple messages" {
    const allocator = std.testing.allocator;
    const content =
        \\>>>
        \\{"method": "initialize"}
        \\
        \\<<<
        \\{"result": {}}
        \\
        \\>>>
        \\{"method": "shutdown"}
        \\
        \\<<<
        \\{"result": null}
        \\
        \\>>>
        \\{"method": "exit"}
    ;

    var snapshot = try parse(allocator, content);
    defer snapshot.deinit();

    try std.testing.expectEqual(@as(usize, 5), snapshot.messages.len);
    try std.testing.expectEqual(Direction.send, snapshot.messages[0].direction);
    try std.testing.expectEqual(Direction.expect, snapshot.messages[1].direction);
    try std.testing.expectEqual(Direction.send, snapshot.messages[2].direction);
    try std.testing.expectEqual(Direction.expect, snapshot.messages[3].direction);
    try std.testing.expectEqual(Direction.send, snapshot.messages[4].direction);
}

test "parse with extra blank lines" {
    const allocator = std.testing.allocator;
    const content =
        \\
        \\
        \\>>>
        \\{"id": 1}
        \\
        \\
        \\
        \\<<<
        \\{"id": 1, "result": null}
        \\
        \\
    ;

    var snapshot = try parse(allocator, content);
    defer snapshot.deinit();

    try std.testing.expectEqual(@as(usize, 2), snapshot.messages.len);
    try std.testing.expectEqual(Direction.send, snapshot.messages[0].direction);
    try std.testing.expectEqual(Direction.expect, snapshot.messages[1].direction);
}

test "invalid marker - unexpected content" {
    const allocator = std.testing.allocator;
    const content =
        \\some random content
        \\>>>
        \\{"id": 1}
    ;

    const result = parse(allocator, content);
    try std.testing.expectError(ParseError.UnexpectedContent, result);
}

test "empty message error" {
    const allocator = std.testing.allocator;
    const content =
        \\>>>
        \\
        \\<<<
        \\{"result": null}
    ;

    const result = parse(allocator, content);
    try std.testing.expectError(ParseError.EmptyMessage, result);
}

test "serialize empty snapshot" {
    const allocator = std.testing.allocator;
    const snapshot = Snapshot{
        .messages = &[_]Message{},
        .allocator = allocator,
    };

    const result = try serialize(snapshot, allocator);
    defer allocator.free(result);

    try std.testing.expectEqualStrings("", result);
}

test "serialize single message" {
    const allocator = std.testing.allocator;

    const json = try allocator.dupe(u8, "{\"id\": 1}");
    defer allocator.free(json);

    const messages = try allocator.alloc(Message, 1);
    defer allocator.free(messages);

    messages[0] = .{
        .direction = .send,
        .json = json,
        .line_start = 1,
    };

    const snapshot = Snapshot{
        .messages = messages,
        .allocator = allocator,
    };

    const result = try serialize(snapshot, allocator);
    defer allocator.free(result);

    try std.testing.expectEqualStrings(">>>\n{\"id\": 1}\n", result);
}

test "round trip parse then serialize" {
    const allocator = std.testing.allocator;
    const content =
        \\>>>
        \\{"method": "initialize"}
        \\
        \\<<<
        \\{"result": {}}
        \\
        \\>>>
        \\{"method": "exit"}
    ;

    var snapshot = try parse(allocator, content);
    defer snapshot.deinit();

    const serialized = try serialize(snapshot, allocator);
    defer allocator.free(serialized);

    var snapshot2 = try parse(allocator, serialized);
    defer snapshot2.deinit();

    try std.testing.expectEqual(snapshot.messages.len, snapshot2.messages.len);
    for (snapshot.messages, snapshot2.messages) |orig, round_tripped| {
        try std.testing.expectEqual(orig.direction, round_tripped.direction);
    }
}

test "serialize pretty prints expect messages" {
    const allocator = std.testing.allocator;

    const json = try allocator.dupe(u8, "{\"result\":{\"capabilities\":{}}}");
    defer allocator.free(json);

    const messages = try allocator.alloc(Message, 1);
    defer allocator.free(messages);

    messages[0] = .{
        .direction = .expect,
        .json = json,
        .line_start = 1,
    };

    const snapshot = Snapshot{
        .messages = messages,
        .allocator = allocator,
    };

    const result = try serialize(snapshot, allocator);
    defer allocator.free(result);

    try std.testing.expect(std.mem.indexOf(u8, result, "\n  ") != null);
    try std.testing.expect(std.mem.startsWith(u8, result, "<<<\n"));
}
