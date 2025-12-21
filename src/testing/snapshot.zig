//! Snapshot file parser and serializer for LSP message testing.
//!
//! FILE FORMAT SPECIFICATION:
//!
//! - A snapshot file contains a sequence of message blocks separated by blank lines
//! - Each message block starts with a direction marker on its own line:
//!   - '>>>' means client-to-server (send)
//!   - '<<<' means server-to-client (expect)
//! - The JSON content follows on subsequent lines until a blank line or EOF
//! - The JSON should be pretty-printed (multi-line with indentation)
//! - No comments are supported in the format
//! - Blank lines between message blocks are required
//!
//! EXAMPLE FILE:
//!
//! >>>
//! {
//!   "jsonrpc": "2.0",
//!   "id": 1,
//!   "method": "initialize",
//!   "params": {
//!     "capabilities": {}
//!   }
//! }
//!
//! <<<
//! {
//!   "jsonrpc": "2.0",
//!   "id": 1,
//!   "result": {
//!     "capabilities": {}
//!   }
//! }
//!
//! >>>
//! {
//!   "jsonrpc": "2.0",
//!   "method": "exit"
//! }

const std = @import("std");
const Allocator = std.mem.Allocator;

/// Direction of a message in the snapshot.
pub const Direction = enum {
    /// Client-to-server message (>>>)
    send,
    /// Server-to-client message (<<<)
    expect,
};

/// A single message in a snapshot file.
pub const Message = struct {
    /// Direction of the message (send or expect).
    direction: Direction,
    /// The raw JSON content of the message.
    json: []const u8,
    /// Line number where the marker appeared (1-indexed for human readability).
    line_start: u32,
};

/// A parsed snapshot file containing a sequence of messages.
pub const Snapshot = struct {
    /// The messages in the snapshot, in order.
    messages: []const Message,
    /// Allocator used for allocations (needed for deinit).
    allocator: Allocator,

    /// Free all allocated memory.
    pub fn deinit(self: *Snapshot) void {
        for (self.messages) |msg| {
            self.allocator.free(msg.json);
        }
        self.allocator.free(self.messages);
        self.* = undefined;
    }
};

/// Errors that can occur during snapshot parsing.
pub const ParseError = error{
    /// A line that looks like a marker but isn't >>> or <<<
    InvalidDirectionMarker,
    /// A message block with no JSON content
    EmptyMessage,
    /// Content found before any direction marker
    UnexpectedContent,
    /// Memory allocation failed
    OutOfMemory,
};

/// Parse state machine states.
const ParseState = enum {
    /// Looking for a direction marker
    looking_for_marker,
    /// Reading JSON lines after a marker
    reading_json,
};

/// Parse a snapshot file from its content.
///
/// Returns a Snapshot containing all parsed messages.
/// The caller must call deinit() on the returned Snapshot to free memory.
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
        const line = std.mem.trimRight(u8, raw_line, "\r");
        const trimmed = std.mem.trim(u8, line, " \t");

        switch (state) {
            .looking_for_marker => {
                // Skip blank lines when looking for a marker
                if (trimmed.len == 0) {
                    continue;
                }

                // Check for direction markers
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
                    // Non-blank, non-marker content before any marker
                    return ParseError.UnexpectedContent;
                }
            },
            .reading_json => {
                // Blank line or new marker ends the current message
                const is_blank = trimmed.len == 0;
                const is_marker = std.mem.eql(u8, trimmed, ">>>") or std.mem.eql(u8, trimmed, "<<<");

                if (is_blank or is_marker) {
                    // Finalize current message
                    if (json_lines.items.len == 0) {
                        return ParseError.EmptyMessage;
                    }

                    // Join all JSON lines with newlines
                    const json = try std.mem.join(allocator, "\n", json_lines.items);
                    errdefer allocator.free(json);

                    try messages.append(allocator, .{
                        .direction = current_direction,
                        .json = json,
                        .line_start = current_line_start,
                    });

                    json_lines.clearRetainingCapacity();

                    if (is_marker) {
                        // Start new message immediately
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
                    // Accumulate JSON line
                    try json_lines.append(allocator, line);
                }
            },
        }
    }

    // Handle final message if we were reading JSON at EOF
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

/// Serialize a snapshot back to the file format.
///
/// For send (>>>) messages: writes the JSON as-is (preserves original formatting).
/// For expect (<<<) messages: parses and re-serializes with pretty printing.
///
/// Returns the complete serialized content as a single allocated string.
/// The caller owns the returned memory.
pub fn serialize(self: Snapshot, allocator: Allocator) ![]const u8 {
    var output: std.ArrayList(u8) = .empty;
    errdefer output.deinit(allocator);

    for (self.messages, 0..) |msg, i| {
        // Add blank line between messages (but not before the first one)
        if (i > 0) {
            try output.append(allocator, '\n');
        }

        // Write direction marker
        const marker: []const u8 = switch (msg.direction) {
            .send => ">>>",
            .expect => "<<<",
        };
        try output.appendSlice(allocator, marker);
        try output.append(allocator, '\n');

        // Write JSON content
        if (msg.direction == .expect) {
            // Pretty-print expect messages
            const parsed = std.json.parseFromSlice(std.json.Value, allocator, msg.json, .{}) catch {
                // If JSON is invalid, just write it as-is
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
            // Write send messages as-is
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

    // Parse again to verify structure is preserved
    var snapshot2 = try parse(allocator, serialized);
    defer snapshot2.deinit();

    try std.testing.expectEqual(snapshot.messages.len, snapshot2.messages.len);
    for (snapshot.messages, snapshot2.messages) |orig, round_tripped| {
        try std.testing.expectEqual(orig.direction, round_tripped.direction);
        // Note: JSON content may be reformatted for expect messages
    }
}

test "serialize pretty prints expect messages" {
    const allocator = std.testing.allocator;

    // Compact JSON that should be pretty-printed
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

    // Should contain newlines from pretty-printing
    try std.testing.expect(std.mem.indexOf(u8, result, "\n  ") != null);
    // Should start with the marker
    try std.testing.expect(std.mem.startsWith(u8, result, "<<<\n"));
}
