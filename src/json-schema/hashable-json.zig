//! HashableJsonValue: A JSON value type that computes its hash incrementally during parsing.
//!
//! This module provides:
//! - `HashableJsonValue`: A JSON value type with a pre-computed hash
//! - `parse`: A parser that builds HashableJsonValue from JSON input
//! - `resolve_pointer`: JSON Pointer resolution (RFC 6901)
//!
//! The hash is computed bottom-up during parsing, enabling O(1) lookup of
//! already-parsed JSON structures via hash comparison.

const std = @import("std");
const mem = std.mem;
const base = @import("base");
const Arena = base.Arena;
const json = @import("json");

const str8 = []const u8;

const hash_seed: u64 = 0xdeadbeef;

pub const HashableJsonValue = struct {
    hash: u64 = 0,
    kind: Kind,

    pub const KindEnum = enum(u8) {
        null = 0,
        bool = 1,
        integer = 2,
        float = 3,
        string = 4,
        array = 5,
        object = 6,
    };

    pub const Kind = union(KindEnum) {
        null: void,
        bool: bool,
        integer: i64,
        float: f64,
        string: str8,
        array: Array,
        object: Object,
    };

    pub const Array = struct {
        first: ?*ArrayNode = null,
        len: usize = 0,

        pub const ArrayNode = struct {
            value: HashableJsonValue,
            next: ?*ArrayNode = null,
        };

        pub const empty: Array = .{};

        pub fn get(arr: *const Array, index: usize) ?*const HashableJsonValue {
            if (index >= arr.len) return null;
            var node = arr.first;
            var i: usize = 0;
            while (node) |n| : (i += 1) {
                if (i == index) return &n.value;
                node = n.next;
            }
            return null;
        }

        pub fn get_mut(arr: *Array, index: usize) ?*HashableJsonValue {
            if (index >= arr.len) return null;
            var node = arr.first;
            var i: usize = 0;
            while (node) |n| : (i += 1) {
                if (i == index) return &n.value;
                node = n.next;
            }
            return null;
        }

        pub const Iterator = struct {
            node: ?*const ArrayNode,

            pub fn next(iter: *Iterator) ?*const HashableJsonValue {
                const node = iter.node orelse return null;
                iter.node = node.next;
                return &node.value;
            }
        };

        pub fn iterator(arr: *const Array) Iterator {
            return .{ .node = arr.first };
        }
    };

    pub const Object = struct {
        map: ObjectMap,

        pub const ObjectMap = base.XarMap(str8, *HashableJsonValue, 8);

        pub fn get(obj: *const Object, key: str8) ?*const HashableJsonValue {
            const ptr = obj.map.get_const(key) orelse return null;
            return ptr.*;
        }

        pub fn get_mut(obj: *Object, key: str8) ?*HashableJsonValue {
            const ptr = obj.map.get(key) orelse return null;
            return ptr.*;
        }

        pub fn count(obj: *const Object) usize {
            return obj.map.count();
        }

        pub fn key_iterator(obj: *const Object) ObjectMap.KeyIterator {
            return obj.map.key_iterator();
        }

        pub fn iterator(obj: *const Object) ObjectMap.ConstIterator {
            return obj.map.const_iterator();
        }
    };

    /// Navigate a JSON pointer path (e.g., "#/properties/name/type")
    /// Supports both "#/path" (fragment) and "/path" (relative) formats
    pub fn resolve_pointer(value: *const HashableJsonValue, pointer: str8) ?*const HashableJsonValue {
        if (pointer.len == 0) return value;

        var path = pointer;

        // Handle fragment identifier
        if (path[0] == '#') {
            path = path[1..];
            if (path.len == 0) return value;
        }

        var current = value;

        while (path.len > 0) {
            if (path[0] != '/') return null;
            path = path[1..]; // Skip '/'

            // Find next segment
            const end = mem.indexOfScalar(u8, path, '/') orelse path.len;
            const segment_raw = path[0..end];
            path = path[end..];

            // Unescape the segment (RFC 6901: ~1 -> /, ~0 -> ~)
            const segment = unescape_pointer_segment(segment_raw);

            switch (current.kind) {
                .object => |*obj| {
                    current = obj.get(segment) orelse return null;
                },
                .array => |*arr| {
                    const index = std.fmt.parseInt(usize, segment, 10) catch return null;
                    current = arr.get(index) orelse return null;
                },
                else => return null,
            }
        }
        return current;
    }

    /// Mutable version of resolve_pointer
    pub fn resolve_pointer_mut(value: *HashableJsonValue, pointer: str8) ?*HashableJsonValue {
        if (pointer.len == 0) return value;

        var path = pointer;

        // Handle fragment identifier
        if (path[0] == '#') {
            path = path[1..];
            if (path.len == 0) return value;
        }

        var current = value;

        while (path.len > 0) {
            if (path[0] != '/') return null;
            path = path[1..]; // Skip '/'

            // Find next segment
            const end = mem.indexOfScalar(u8, path, '/') orelse path.len;
            const segment_raw = path[0..end];
            path = path[end..];

            // Unescape the segment (RFC 6901: ~1 -> /, ~0 -> ~)
            const segment = unescape_pointer_segment(segment_raw);

            switch (current.kind) {
                .object => |*obj| {
                    current = obj.get_mut(segment) orelse return null;
                },
                .array => |*arr| {
                    const index = std.fmt.parseInt(usize, segment, 10) catch return null;
                    current = arr.get_mut(index) orelse return null;
                },
                else => return null,
            }
        }
        return current;
    }
};

/// Unescape a JSON Pointer segment per RFC 6901
/// ~1 -> /
/// ~0 -> ~
fn unescape_pointer_segment(segment: str8) str8 {
    // Fast path: no escapes
    if (mem.indexOfScalar(u8, segment, '~') == null) {
        return segment;
    }

    // For now, return as-is since we'd need an arena to allocate
    // TODO: Handle escaping properly with arena allocation
    return segment;
}

pub const ParseError = error{
    OutOfMemory,
    InvalidJson,
    InvalidUtf8,
    UnexpectedToken,
    UnexpectedEndOfInput,
    InvalidNumber,
    InvalidString,
};

/// Parse JSON input into a HashableJsonValue with incrementally computed hashes
pub fn parse(arena: *Arena, input: str8) ParseError!HashableJsonValue {
    var lexer: json.Lexer = .zero;
    json.lex(&lexer, arena, input) catch |err| switch (err) {
        error.OutOfMemory => return error.OutOfMemory,
        error.InvalidUtf8 => return error.InvalidUtf8,
    };

    var parser = Parser{
        .arena = arena,
        .tokens = lexer.tokens.items,
        .input = input,
        .pos = 0,
    };

    return parser.parse_value();
}

const Parser = struct {
    arena: *Arena,
    tokens: []const json.Token,
    input: str8,
    pos: usize,

    fn parse_value(parser: *Parser) ParseError!HashableJsonValue {
        if (parser.pos >= parser.tokens.len) {
            return error.UnexpectedEndOfInput;
        }

        const token = parser.tokens[parser.pos];
        return switch (token.kind) {
            .null => parser.parse_null(),
            .true => parser.parse_bool(true),
            .false => parser.parse_bool(false),
            .string => parser.parse_string(),
            .number => parser.parse_number(),
            .l_bracket => parser.parse_array(),
            .l_curly => parser.parse_object(),
            .err => error.InvalidJson,
            else => error.UnexpectedToken,
        };
    }

    fn parse_null(parser: *Parser) ParseError!HashableJsonValue {
        parser.pos += 1;
        return .{
            .hash = compute_null_hash(),
            .kind = .null,
        };
    }

    fn parse_bool(parser: *Parser, value: bool) ParseError!HashableJsonValue {
        parser.pos += 1;
        return .{
            .hash = compute_bool_hash(value),
            .kind = .{ .bool = value },
        };
    }

    fn parse_string(parser: *Parser) ParseError!HashableJsonValue {
        const token = parser.tokens[parser.pos];
        parser.pos += 1;

        const raw = parser.input[token.range.start.byte..token.range.close.byte];

        // Remove quotes and unescape
        if (raw.len < 2) return error.InvalidString;
        const content = try unescape_string(parser.arena, raw[1 .. raw.len - 1]);

        return .{
            .hash = compute_string_hash(content),
            .kind = .{ .string = content },
        };
    }

    fn parse_number(parser: *Parser) ParseError!HashableJsonValue {
        const token = parser.tokens[parser.pos];
        parser.pos += 1;

        const raw = parser.input[token.range.start.byte..token.range.close.byte];

        // Try parsing as integer first
        if (std.fmt.parseInt(i64, raw, 10)) |int_val| {
            // Hash as float for consistency (42 == 42.0)
            const float_val: f64 = @floatFromInt(int_val);
            return .{
                .hash = compute_float_hash(float_val),
                .kind = .{ .integer = int_val },
            };
        } else |_| {
            // Parse as float
            const float_val = std.fmt.parseFloat(f64, raw) catch return error.InvalidNumber;
            return .{
                .hash = compute_float_hash(float_val),
                .kind = .{ .float = float_val },
            };
        }
    }

    fn parse_array(parser: *Parser) ParseError!HashableJsonValue {
        parser.pos += 1; // consume '['

        // Check for empty array
        if (parser.pos < parser.tokens.len and parser.tokens[parser.pos].kind == .r_bracket) {
            parser.pos += 1;
            const arr = HashableJsonValue.Array.empty;
            return .{
                .hash = compute_array_hash(&arr),
                .kind = .{ .array = arr },
            };
        }

        // Use intrusive linked list to collect items
        const ArrayNode = HashableJsonValue.Array.ArrayNode;
        var first: ?*ArrayNode = null;
        var last: ?*ArrayNode = null;
        var count: usize = 0;

        while (true) {
            if (parser.pos >= parser.tokens.len) {
                return error.UnexpectedEndOfInput;
            }

            const item = try parser.parse_value();
            const node = try parser.arena.create(ArrayNode);
            node.* = .{ .value = item };

            // Append to list
            if (last) |l| {
                l.next = node;
            } else {
                first = node;
            }
            last = node;
            count += 1;

            if (parser.pos >= parser.tokens.len) {
                return error.UnexpectedEndOfInput;
            }

            const next = parser.tokens[parser.pos];
            if (next.kind == .r_bracket) {
                parser.pos += 1;
                break;
            } else if (next.kind == .comma) {
                parser.pos += 1;
            } else {
                return error.UnexpectedToken;
            }
        }

        const arr = HashableJsonValue.Array{ .first = first, .len = count };

        return .{
            .hash = compute_array_hash(&arr),
            .kind = .{ .array = arr },
        };
    }

    fn parse_object(parser: *Parser) ParseError!HashableJsonValue {
        parser.pos += 1; // consume '{'

        var obj_map: HashableJsonValue.Object.ObjectMap = .empty;

        // Check for empty object
        if (parser.pos < parser.tokens.len and parser.tokens[parser.pos].kind == .r_curly) {
            parser.pos += 1;
            const obj = HashableJsonValue.Object{ .map = obj_map };
            return .{
                .hash = compute_object_hash(&obj.map),
                .kind = .{ .object = obj },
            };
        }

        while (true) {
            if (parser.pos >= parser.tokens.len) {
                return error.UnexpectedEndOfInput;
            }

            // Parse key
            const key_token = parser.tokens[parser.pos];
            if (key_token.kind != .string) {
                return error.UnexpectedToken;
            }
            parser.pos += 1;

            const raw_key = parser.input[key_token.range.start.byte..key_token.range.close.byte];
            if (raw_key.len < 2) return error.InvalidString;
            const key = try unescape_string(parser.arena, raw_key[1 .. raw_key.len - 1]);

            // Expect colon
            if (parser.pos >= parser.tokens.len) {
                return error.UnexpectedEndOfInput;
            }
            if (parser.tokens[parser.pos].kind != .colon) {
                return error.UnexpectedToken;
            }
            parser.pos += 1;

            // Parse value
            const value = try parser.parse_value();

            // Allocate value on arena and add to map for O(1) lookups
            const value_ptr = try parser.arena.create(HashableJsonValue);
            value_ptr.* = value;
            try obj_map.put(parser.arena, key, value_ptr);

            if (parser.pos >= parser.tokens.len) {
                return error.UnexpectedEndOfInput;
            }

            const next = parser.tokens[parser.pos];
            if (next.kind == .r_curly) {
                parser.pos += 1;
                break;
            } else if (next.kind == .comma) {
                parser.pos += 1;
            } else {
                return error.UnexpectedToken;
            }
        }

        const obj = HashableJsonValue.Object{ .map = obj_map };
        return .{
            .hash = compute_object_hash(&obj.map),
            .kind = .{ .object = obj },
        };
    }
};

const CharNode = struct {
    byte: u8,
    next: ?*CharNode = null,
};

/// Unescape a JSON string (handles \n, \t, \", \\, \/, \uXXXX, etc.)
fn unescape_string(arena: *Arena, input: str8) ParseError!str8 {
    // Fast path: no escapes
    if (mem.indexOfScalar(u8, input, '\\') == null) {
        return input;
    }

    // Use intrusive linked list to collect characters
    var list: base.IntrusiveLinkedList(CharNode) = .{};
    var count: usize = 0;
    var last_node: ?*CharNode = null;

    var i: usize = 0;

    while (i < input.len) {
        var bytes_to_add: []const u8 = undefined;
        var advance: usize = 1;

        if (input[i] == '\\' and i + 1 < input.len) {
            const escaped = input[i + 1];
            switch (escaped) {
                'n' => {
                    bytes_to_add = "\n";
                    advance = 2;
                },
                't' => {
                    bytes_to_add = "\t";
                    advance = 2;
                },
                'r' => {
                    bytes_to_add = "\r";
                    advance = 2;
                },
                '"' => {
                    bytes_to_add = "\"";
                    advance = 2;
                },
                '\\' => {
                    bytes_to_add = "\\";
                    advance = 2;
                },
                '/' => {
                    bytes_to_add = "/";
                    advance = 2;
                },
                'b' => {
                    bytes_to_add = &[_]u8{0x08};
                    advance = 2;
                },
                'f' => {
                    bytes_to_add = &[_]u8{0x0C};
                    advance = 2;
                },
                'u' => {
                    // \uXXXX
                    if (i + 5 < input.len) {
                        const hex = input[i + 2 .. i + 6];
                        if (std.fmt.parseInt(u21, hex, 16)) |codepoint| {
                            // Encode as UTF-8
                            var buf: [4]u8 = undefined;
                            if (std.unicode.utf8Encode(codepoint, &buf)) |len| {
                                bytes_to_add = buf[0..len];
                                advance = 6;
                            } else |_| {
                                bytes_to_add = input[i .. i + 1];
                                advance = 1;
                            }
                        } else |_| {
                            bytes_to_add = input[i .. i + 1];
                            advance = 1;
                        }
                    } else {
                        bytes_to_add = input[i .. i + 1];
                        advance = 1;
                    }
                },
                else => {
                    bytes_to_add = input[i .. i + 1];
                    advance = 1;
                },
            }
        } else {
            bytes_to_add = input[i .. i + 1];
            advance = 1;
        }

        // Add bytes to the linked list
        for (bytes_to_add) |b| {
            const node = try arena.create(CharNode);
            node.* = .{ .byte = b };

            if (last_node) |last| {
                last.next = node;
            } else {
                list.first = node;
            }
            last_node = node;
            count += 1;
        }

        i += advance;
    }

    // Convert linked list to string
    const result = try arena.alloc(u8, count);
    var it: ?*CharNode = list.first;
    var j: usize = 0;
    while (it) |node| : (it = node.next) {
        result[j] = node.byte;
        j += 1;
    }

    return result;
}

// ============================================================================
// Hash computation functions
// ============================================================================

fn compute_null_hash() u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hasher.update(&[_]u8{@intFromEnum(.KindEnum.null)});
    return hasher.final();
}

fn compute_bool_hash(value: bool) u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hasher.update(&[_]u8{ @intFromEnum(.KindEnum.bool), @intFromBool(value) });
    return hasher.final();
}

fn compute_string_hash(value: str8) u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hasher.update(&[_]u8{@intFromEnum(.KindEnum.string)});
    hasher.update(value);
    return hasher.final();
}

fn compute_int_hash(value: i64) u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hasher.update(&[_]u8{@intFromEnum(.KindEnum.int)});
    hasher.update(mem.asBytes(&value));
    return hasher.final();
}

fn compute_number_hash(value: f64) u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hasher.update(&[_]u8{@intFromEnum(.KindEnum.float)});
    hasher.update(mem.asBytes(&value));
    return hasher.final();
}

fn compute_array_hash(arr: *const HashableJsonValue.Array) u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hasher.update(&[_]u8{@intFromEnum(.KindEnum.array)});
    var iter = arr.iterator();
    while (iter.next()) |item| {
        hash_value_into(&hasher, item);
    }
    return hasher.final();
}

fn compute_object_hash(obj_map: *const HashableJsonValue.Object.ObjectMap) u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hasher.update(&[_]u8{@intFromEnum(.KindEnum.object)});

    const n = obj_map.count();
    if (n == 0) return hasher.final();

    // Get scratch arena for sorting
    const scratch = Arena.get_scratch(&.{});
    defer scratch.release();

    // Extract keys and values from map
    const keys = scratch.arena.alloc(str8, n) catch {
        // Fallback: hash without sorting (order-dependent)
        var iter = obj_map.const_iterator();
        while (iter.next()) |entry| {
            hasher.update(entry.key_ptr.*);
            hash_value_into(&hasher, entry.value_ptr.*);
        }
        return hasher.final();
    };
    const values = scratch.arena.alloc(*const HashableJsonValue, n) catch {
        var iter = obj_map.const_iterator();
        while (iter.next()) |entry| {
            hasher.update(entry.key_ptr.*);
            hash_value_into(&hasher, entry.value_ptr.*);
        }
        return hasher.final();
    };

    var iter = obj_map.const_iterator();
    var i: usize = 0;
    while (iter.next()) |entry| : (i += 1) {
        keys[i] = entry.key_ptr.*;
        values[i] = entry.value_ptr.*;
    }

    // Create array of indices
    const indices = scratch.arena.alloc(usize, n) catch {
        for (keys, values) |key, val| {
            hasher.update(key);
            hash_value_into(&hasher, val);
        }
        return hasher.final();
    };

    for (indices, 0..) |*idx, j| {
        idx.* = j;
    }

    // Sort indices by key for consistent hashing regardless of insertion order
    mem.sort(usize, indices, keys, struct {
        pub fn less_than(k: []const str8, a: usize, b: usize) bool {
            return mem.lessThan(u8, k[a], k[b]);
        }
    }.less_than);

    // Hash in sorted order
    for (indices) |idx| {
        hasher.update(keys[idx]);
        hash_value_into(&hasher, values[idx]);
    }

    return hasher.final();
}

fn hash_value_into(hasher: *std.hash.Wyhash, value: *const HashableJsonValue) void {
    switch (value.kind) {
        .null => hasher.update(&[_]u8{0}),
        .bool => |b| hasher.update(&[_]u8{ 1, @intFromBool(b) }),
        .integer => |i| {
            const f: f64 = @floatFromInt(i);
            hasher.update(&[_]u8{2});
            hasher.update(mem.asBytes(&f));
        },
        .float => |f| {
            hasher.update(&[_]u8{3});
            hasher.update(mem.asBytes(&f));
        },
        .string => |s| {
            hasher.update(&[_]u8{4});
            hasher.update(s);
        },
        .array => |*arr| {
            hasher.update(&[_]u8{5});
            var iter = arr.iterator();
            while (iter.next()) |item| {
                hash_value_into(hasher, item);
            }
        },
        .object => |*obj| {
            hasher.update(&[_]u8{6});
            var iter = obj.map.const_iterator();
            while (iter.next()) |entry| {
                hasher.update(entry.key_ptr.*);
                hash_value_into(hasher, entry.value_ptr.*);
            }
        },
    }
}

// ============================================================================
// Tests
// ============================================================================

test "parse null" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const result = try parse(&arena, "null");
    try std.testing.expectEqual(HashableJsonValue.Kind.null, result.kind);
}

test "parse booleans" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const true_result = try parse(&arena, "true");
    try std.testing.expectEqual(true, true_result.kind.bool);

    const false_result = try parse(&arena, "false");
    try std.testing.expectEqual(false, false_result.kind.bool);
}

test "parse integers" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const result = try parse(&arena, "42");
    try std.testing.expectEqual(@as(i64, 42), result.kind.integer);

    const neg_result = try parse(&arena, "-123");
    try std.testing.expectEqual(@as(i64, -123), neg_result.kind.integer);
}

test "parse floats" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const result = try parse(&arena, "3.14159");
    try std.testing.expectApproxEqRel(@as(f64, 3.14159), result.kind.float, 0.00001);
}

test "parse strings" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const result = try parse(&arena, "\"hello world\"");
    try std.testing.expectEqualStrings("hello world", result.kind.string);
}

test "parse string with escapes" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const result = try parse(&arena, "\"hello\\nworld\"");
    try std.testing.expectEqualStrings("hello\nworld", result.kind.string);

    const result2 = try parse(&arena, "\"tab\\there\"");
    try std.testing.expectEqualStrings("tab\there", result2.kind.string);
}

test "parse empty array" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const result = try parse(&arena, "[]");
    try std.testing.expectEqual(@as(usize, 0), result.kind.array.len);
}

test "parse array with values" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const result = try parse(&arena, "[1, 2, 3]");
    try std.testing.expectEqual(@as(usize, 3), result.kind.array.len);
    try std.testing.expectEqual(@as(i64, 1), result.kind.array.get(0).?.kind.integer);
    try std.testing.expectEqual(@as(i64, 2), result.kind.array.get(1).?.kind.integer);
    try std.testing.expectEqual(@as(i64, 3), result.kind.array.get(2).?.kind.integer);
}

test "parse empty object" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const result = try parse(&arena, "{}");
    try std.testing.expectEqual(@as(usize, 0), result.kind.object.count());
}

test "parse object with values" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const result = try parse(&arena,
        \\{"name": "test", "value": 42}
    );
    try std.testing.expectEqual(@as(usize, 2), result.kind.object.count());

    const name = result.kind.object.get("name");
    try std.testing.expect(name != null);
    try std.testing.expectEqualStrings("test", name.?.kind.string);

    const val = result.kind.object.get("value");
    try std.testing.expect(val != null);
    try std.testing.expectEqual(@as(i64, 42), val.?.kind.integer);
}

test "parse nested structure" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const result = try parse(&arena,
        \\{"arr": [1, {"nested": true}], "obj": {"a": "b"}}
    );
    try std.testing.expectEqual(@as(usize, 2), result.kind.object.count());

    const arr = result.kind.object.get("arr").?;
    try std.testing.expectEqual(@as(usize, 2), arr.kind.array.len);
    try std.testing.expectEqual(@as(i64, 1), arr.kind.array.get(0).?.kind.integer);
    try std.testing.expectEqual(true, arr.kind.array.get(1).?.kind.object.get("nested").?.kind.bool);
}

test "hash consistency - same value same hash" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const v1 = try parse(&arena, "42");
    const v2 = try parse(&arena, "42");
    try std.testing.expectEqual(v1.hash, v2.hash);
}

test "hash consistency - different values different hash" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const v1 = try parse(&arena, "42");
    const v2 = try parse(&arena, "43");
    try std.testing.expect(v1.hash != v2.hash);
}

test "hash consistency - integer and float same value" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const v1 = try parse(&arena, "42");
    const v2 = try parse(&arena, "42.0");
    try std.testing.expectEqual(v1.hash, v2.hash);
}

test "hash consistency - object key order independent" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const v1 = try parse(&arena,
        \\{"a": 1, "b": 2}
    );
    const v2 = try parse(&arena,
        \\{"b": 2, "a": 1}
    );
    try std.testing.expectEqual(v1.hash, v2.hash);
}

test "hash consistency - nested objects key order independent" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const v1 = try parse(&arena,
        \\{"outer": {"a": 1, "b": 2}}
    );
    const v2 = try parse(&arena,
        \\{"outer": {"b": 2, "a": 1}}
    );
    try std.testing.expectEqual(v1.hash, v2.hash);
}

test "resolve_pointer - root" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const value = try parse(&arena,
        \\{"a": 1}
    );
    const resolved = value.resolve_pointer("");
    try std.testing.expect(resolved != null);
    try std.testing.expectEqual(@as(usize, 1), resolved.?.kind.object.count());
}

test "resolve_pointer - simple path" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const value = try parse(&arena,
        \\{"properties": {"name": {"type": "string"}}}
    );

    const resolved = value.resolve_pointer("/properties/name/type");
    try std.testing.expect(resolved != null);
    try std.testing.expectEqualStrings("string", resolved.?.kind.string);
}

test "resolve_pointer - with fragment" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const value = try parse(&arena,
        \\{"properties": {"name": {"type": "string"}}}
    );

    const resolved = value.resolve_pointer("#/properties/name/type");
    try std.testing.expect(resolved != null);
    try std.testing.expectEqualStrings("string", resolved.?.kind.string);
}

test "resolve_pointer - array index" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const value = try parse(&arena,
        \\{"items": [{"type": "number"}, {"type": "string"}]}
    );

    const resolved = value.resolve_pointer("/items/1/type");
    try std.testing.expect(resolved != null);
    try std.testing.expectEqualStrings("string", resolved.?.kind.string);
}

test "resolve_pointer - not found" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const value = try parse(&arena,
        \\{"a": 1}
    );

    const resolved = value.resolve_pointer("/nonexistent");
    try std.testing.expect(resolved == null);
}
