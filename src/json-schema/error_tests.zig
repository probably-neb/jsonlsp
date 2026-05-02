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
        \\<|"hi"|>
    ,
        &.{"Expected string length to be at least 3, found 2"},
    );
}

test "string longer than maxLength" {
    try check_errors(
        \\{ "maxLength": 2 }
    ,
        \\<|"hey"|>
    ,
        &.{"Expected string length to be at most 2, found 3"},
    );
}

test "string does not match pattern" {
    try check_errors(
        \\{ "pattern": "^[a-z]+$" }
    ,
        \\<|"abc123"|>
    ,
        &.{"Expected string to match pattern /^[a-z]+$/"},
    );
}

test "value does not match const" {
    try check_errors(
        \\{ "const": 1 }
    ,
        "<|2|>",
        &.{"Expected value to equal 1"},
    );
}

test "value does not match enum" {
    try check_errors(
        \\{ "enum": [1, "two", null] }
    ,
        "<|false|>",
        &.{
            \\Expected value to be one of 1, "two", or null
        },
    );
}

test "number less than minimum" {
    try check_errors(
        \\{ "minimum": 3 }
    ,
        "<|2|>",
        &.{"Expected number to be at least 3, found 2"},
    );
}

test "number equal to exclusiveMinimum" {
    try check_errors(
        \\{ "exclusiveMinimum": 3 }
    ,
        "<|3|>",
        &.{"Expected number to be greater than 3, found 3"},
    );
}

test "number greater than maximum" {
    try check_errors(
        \\{ "maximum": 3 }
    ,
        "<|4|>",
        &.{"Expected number to be at most 3, found 4"},
    );
}

test "number equal to exclusiveMaximum" {
    try check_errors(
        \\{ "exclusiveMaximum": 3 }
    ,
        "<|3|>",
        &.{"Expected number to be less than 3, found 3"},
    );
}

test "number is not multipleOf" {
    try check_errors(
        \\{ "multipleOf": 2 }
    ,
        "<|3|>",
        &.{"Expected number to be a multiple of 2, found 3"},
    );
}

test "array has too few items" {
    try check_errors(
        \\{ "minItems": 2 }
    ,
        "<|[1]|>",
        &.{"Expected array to contain at least 2 items, found 1"},
    );
}

test "array has too many items" {
    try check_errors(
        \\{ "maxItems": 2 }
    ,
        "<|[1, 2, 3]|>",
        &.{"Expected array to contain at most 2 items, found 3"},
    );
}

test "array contains duplicate item" {
    try check_errors(
        \\{ "uniqueItems": true }
    ,
        "[1, <|1|>]",
        &.{"Expected array items to be unique"},
    );
}

test "object has too few properties" {
    try check_errors(
        \\{ "minProperties": 2 }
    ,
        \\<|{"a": 1}|>
    ,
        &.{"Expected object to contain at least 2 properties, found 1"},
    );
}

test "object has too many properties" {
    try check_errors(
        \\{ "maxProperties": 1 }
    ,
        \\<|{"a": 1, "b": 2}|>
    ,
        &.{"Expected object to contain at most 1 property, found 2"},
    );
}

test "object missing required property" {
    try check_errors(
        \\{ "required": ["b"] }
    ,
        \\<|{"a": 1}|>
    ,
        &.{
            \\missing required property "b"
        },
    );
}

test "object missing required properties" {
    try check_errors(
        \\{ "required": ["a", "b", "c"] }
    ,
        \\<|{}|>
    ,
        &.{
            \\missing required properties "a", "b", and "c"
        },
    );
}

test "array contains too few matching items" {
    try check_errors(
        \\{ "contains": { "const": 1 }, "minContains": 2 }
    ,
        \\<|[1, 2]|>
    ,
        &.{"Expected array to contain at least 2 matching items, found 1"},
    );
}

test "array contains too many matching items" {
    try check_errors(
        \\{ "contains": { "const": 1 }, "maxContains": 1 }
    ,
        \\<|[1, 1]|>
    ,
        &.{"Expected array to contain at most 1 matching item, found 2"},
    );
}

test "object contains additional property" {
    try check_errors(
        \\{ "properties": { "a": true }, "additionalProperties": false }
    ,
        \\{ "a": 1, <|"b"|>: 2 }
    ,
        &.{
            \\unexpected property "b"
        },
    );
}
