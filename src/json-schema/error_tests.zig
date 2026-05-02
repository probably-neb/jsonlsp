const std = @import("std");
const json_schema = @import("json-schema.zig");
const base = @import("base");
const Arena = base.Arena;

fn parse_marked_json(arena: *Arena, marked_json: []const u8) !struct { []const u8, []const base.Range(u32) } {
    const start_marker = "<|";
    const end_marker = "|>";
    const start_marker_count = std.mem.count(u8, marked_json, start_marker);

    var in_span: bool = false;
    for (0..marked_json.len) |pos| {
        if (std.mem.startsWith(u8, marked_json[pos..], start_marker)) {
            if (in_span) {
                return error.NestedMarkers;
            }
            in_span = true;
        } else if (std.mem.startsWith(u8, marked_json[pos..], end_marker)) {
            if (!in_span) {
                return error.UnmatchedEndMarker;
            }
            in_span = false;
        }
    }

    if (start_marker_count == 0) return .{ marked_json, &.{} };

    const ranges = try arena.alloc(base.Range(u32), start_marker_count);
    @memset(ranges, .zero);
    var new_contents: base.ArenaList(u8) = .empty;

    var range_index: u32 = 0;
    var i: u32 = 0;
    while (i < marked_json.len) : (i += 1) {
        if (std.mem.startsWith(u8, marked_json[i..], start_marker)) {
            ranges[range_index].start = @intCast(new_contents.items.len);
            i += 1;
        } else if (std.mem.startsWith(u8, marked_json[i..], end_marker)) {
            ranges[range_index].close = @intCast(new_contents.items.len);
            i += 1;
            range_index += 1;
        } else {
            try new_contents.append(arena, marked_json[i]);
        }
    }

    return .{ new_contents.items, ranges };
}

fn check_errors(schema_contents: []const u8, marked_json: []const u8, messages: []const []const u8) !void {
    const schema = try json_schema.parse(schema_contents);
    var scratch = Arena.get_scratch(&.{});
    defer scratch.release();
    const json_contents, const error_ranges = try parse_marked_json(scratch.arena, marked_json);
    if (messages.len != error_ranges.len) {
        std.debug.print("Expected {} errors, got {}\n", .{ messages.len, error_ranges.len });
        return error.Mismatch;
    }
    const result = try schema.validate(scratch.arena, json_contents);
    if (result.valid and messages.len > 0) {
        std.debug.print("Failed to report errors:\n", .{});
        for (messages) |msg| {
            std.debug.print("  - {s}\n", .{msg});
        }
    }

    const actual_error_messages = try json_schema.render_errors(scratch.arena, result.errors);
    if (messages.len != actual_error_messages.len) {
        std.debug.print("Expected {} errors, got {}\n", .{ messages.len, actual_error_messages.len });
        return error.Mismatch;
    }

    for (messages, error_ranges, actual_error_messages) |msg, range, actual| {
        std.testing.expectEqualStrings(msg, actual.message) catch return error.Mismatch;
        if (range.start != actual.source_range.start.byte or range.close != actual.source_range.close.byte) {
            std.debug.print("Expected range {any}, got {any}\n", .{ range, actual.source_range });
            return error.Mismatch;
        }
    }
}

test parse_marked_json {
    const cases: []const struct { []const u8, []const u8, []const base.Range(u32) } = &.{
        .{ "abc", "abc", &.{} },
        .{ "<|abc|>", "abc", &.{.{ .start = 0, .close = 3 }} },
        .{
            "[<|1|>, <|2|>]", "[1, 2]", &.{
                .{ .start = 1, .close = 2 },
                .{ .start = 4, .close = 5 },
            },
        },
        .{
            "<||>",
            "",
            &.{.{ .start = 0, .close = 0 }},
        },
        .{
            "<|{}|><|[]|>",
            "{}[]",
            &.{
                .{ .start = 0, .close = 2 },
                .{ .start = 2, .close = 4 },
            },
        },
        .{
            "<|1|>\n<|2|>",
            "1\n2",
            &.{
                .{ .start = 0, .close = 1 },
                .{ .start = 2, .close = 3 },
            },
        },
    };
    const scratch = Arena.get_scratch(&.{});
    defer scratch.release();
    for (cases) |c| {
        const marked_json, const expected_json, const expected_ranges = c;
        const json_contents, const error_ranges = try parse_marked_json(scratch.arena, marked_json);
        for (error_ranges, expected_ranges) |r, expected| {
            if (r.start != expected.start or r.close != expected.close) {
                std.debug.print("Expected range {any}, got {any}\n", .{ expected, r });
                return error.Mismatch;
            }
        }
        try std.testing.expectEqualStrings(expected_json, json_contents);
    }

    try std.testing.expectError(error.NestedMarkers, parse_marked_json(scratch.arena, "<|1<||>2|>"));
    try std.testing.expectError(error.UnmatchedEndMarker, parse_marked_json(scratch.arena, "<|1|>2|>"));
}

test "value not a number" {
    try check_errors(
        \\{ "type": "number" }
    ,
        "<|null|>",
        &.{"Expected a value of type number, found null"},
    );
}

test "string shorter than minLength" {
    try check_errors(
        \\{ "minLength": 3 }
    ,
        "<|\"hi\"|>",
        &.{"Expected string length to be at least 3, found 2"},
    );
}

test "string longer than maxLength" {
    try check_errors(
        \\{ "maxLength": 2 }
    ,
        "<|\"hey\"|>",
        &.{"Expected string length to be at most 2, found 3"},
    );
}

test "string does not match pattern" {
    try check_errors(
        \\{ "pattern": "^[a-z]+$" }
    ,
        "<|\"abc123\"|>",
        &.{"Expected string to match pattern /^[a-z]+$/"},
    );
}
