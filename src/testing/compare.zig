//! JSON equality comparison helpers for tests.

const std = @import("std");

/// Compare two JSON strings for deep equality (order-insensitive for object keys).
/// Returns `false` if either input is invalid JSON.
pub fn json_eql(allocator: std.mem.Allocator, expected_json: []const u8, actual_json: []const u8) bool {
    const expected_parsed = std.json.parseFromSlice(std.json.Value, allocator, expected_json, .{}) catch return false;
    defer expected_parsed.deinit();

    const actual_parsed = std.json.parseFromSlice(std.json.Value, allocator, actual_json, .{}) catch return false;
    defer actual_parsed.deinit();

    return eql_json_value(expected_parsed.value, actual_parsed.value);
}

fn eql_json_value(a: std.json.Value, b: std.json.Value) bool {
    if (std.meta.activeTag(a) != std.meta.activeTag(b)) return false;

    return switch (a) {
        .null => true,
        .bool => |av| av == b.bool,
        .integer => |av| av == b.integer,
        .float => |av| av == b.float,
        .number_string => |av| std.mem.eql(u8, av, b.number_string),
        .string => |av| std.mem.eql(u8, av, b.string),
        .array => |av| {
            const bv = b.array;
            if (av.items.len != bv.items.len) return false;
            for (av.items, bv.items) |ae, be| {
                if (!eql_json_value(ae, be)) return false;
            }
            return true;
        },
        .object => |av| {
            const bv = b.object;
            if (av.count() != bv.count()) return false;

            var it = av.iterator();
            while (it.next()) |entry| {
                const b_value = bv.get(entry.key_ptr.*) orelse return false;
                if (!eql_json_value(entry.value_ptr.*, b_value)) return false;
            }
            return true;
        },
    };
}

// ============================================================================
// Tests
// ============================================================================

test "json_eql with identical json" {
    const allocator = std.testing.allocator;
    const json1 = "{\"a\":1,\"b\":2}";
    const json2 = "{\"a\":1,\"b\":2}";
    try std.testing.expect(json_eql(allocator, json1, json2));
}

test "json_eql with different field order" {
    const allocator = std.testing.allocator;
    const json1 = "{\"a\":1,\"b\":2}";
    const json2 = "{\"b\":2,\"a\":1}";
    try std.testing.expect(json_eql(allocator, json1, json2));
}

test "json_eql with different values" {
    const allocator = std.testing.allocator;
    const json1 = "{\"a\":1,\"b\":2}";
    const json2 = "{\"a\":1,\"b\":3}";
    try std.testing.expect(!json_eql(allocator, json1, json2));
}

test "json_eql with missing field" {
    const allocator = std.testing.allocator;
    const json1 = "{\"a\":1,\"b\":2}";
    const json2 = "{\"a\":1}";
    try std.testing.expect(!json_eql(allocator, json1, json2));
}

test "json_eql with extra field" {
    const allocator = std.testing.allocator;
    const json1 = "{\"a\":1}";
    const json2 = "{\"a\":1,\"b\":2}";
    try std.testing.expect(!json_eql(allocator, json1, json2));
}

test "json_eql with nested objects" {
    const allocator = std.testing.allocator;
    const json1 = "{\"outer\":{\"inner\":42}}";
    const json2 = "{\"outer\":{\"inner\":42}}";
    try std.testing.expect(json_eql(allocator, json1, json2));
}

test "json_eql with arrays" {
    const allocator = std.testing.allocator;
    const json1 = "[1,2,3]";
    const json2 = "[1,2,3]";
    const json3 = "[1,3,2]";
    try std.testing.expect(json_eql(allocator, json1, json2));
    try std.testing.expect(!json_eql(allocator, json1, json3));
}
