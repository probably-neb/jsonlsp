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
const lexer = @import("lex.zig");

const str8 = []const u8;

const hash_seed: u64 = 0xdeadbeef;

pub const Value = struct {
    hash: u64 = 0,
    kind: Kind,
    next: *Value,
    prev: *Value,
    range: lexer.Token.Range,

    const This = @This();

    pub const zero: Value = .{
        .hash = 0,
        .kind = .null,
        .next = @constCast(&Value.zero),
        .prev = @constCast(&Value.zero),
    };

    pub fn value(val: *Value, kind: Kind, hash: u64, range: lexer.Token.Range) *Value {
        val.kind = kind;
        val.hash = hash;
        val.next = val;
        val.prev = val;
        val.range = range;
        return val;
    }

    pub fn integer(int: i64, range: lexer.Token.Range) *Value {
        return .{
            .kind = .integer,
            .hash = compute_integer_hash(int),
            .next = &Value.zero,
            .prev = &Value.zero,
            .range = range,
        };
    }

    pub fn as_object(self: *const Value) ?*const Value.Kind.Object {
        switch (self.kind) {
            .object => |*obj| return obj,
            else => return null,
        }
    }

    pub fn as_array(self: *const Value) ?*const Value.Kind.Array {
        switch (self.kind) {
            .array => |arr| return arr,
            else => return null,
        }
    }

    pub fn as_string(self: *const Value) ?str8 {
        switch (self.kind) {
            .string => |str| return str.value,
            else => return null,
        }
    }

    pub fn as_bool(self: *const Value) ?bool {
        switch (self.kind) {
            .bool => |val| return val,
            else => return null,
        }
    }

    pub fn as_integer(self: *const Value) ?i64 {
        switch (self.kind) {
            .integer => |val| return val,
            else => return null,
        }
    }

    pub fn as_float(self: *const Value) ?f64 {
        switch (self.kind) {
            .float => |val| return val,
            else => return null,
        }
    }

    pub fn as_number(self: *const Value) ?f64 {
        switch (self.kind) {
            .integer => |val| return @floatFromInt(val),
            .float => |val| return val,
            else => return null,
        }
    }

    pub fn as_integer_lossy(self: *const Value) ?i64 {
        switch (self.kind) {
            .integer => |val| return val,
            .float => |val| return std.math.lossyCast(i64, val),
            else => return null,
        }
    }

    pub fn as_null(self: *const Value) ?void {
        switch (self.kind) {
            .null => return {},
            else => return null,
        }
    }

    pub const Kind_Tag = enum(u8) {
        null = 0,
        bool = 1,
        integer = 2,
        float = 3,
        string = 4,
        array = 5,
        object = 6,
    };

    pub const Kind = union(Kind_Tag) {
        null: void,
        bool: bool,
        integer: i64,
        float: f64,
        string: String,
        array: Array,
        object: Object,

        pub const String = struct {
            value: str8,
            child: ?*Value = null,
        };

        pub const Array = base.IntrusiveDoublyLinkedList(Value);

        pub const Object = struct {
            map: base.XarMap(str8, *Value, 4) = .empty,
            properties: Properties = .zero,

            pub const zero: Object = .{};
            pub const Properties = base.IntrusiveDoublyLinkedList(Value);

            pub fn count(obj: Object) usize {
                return obj.map.count();
            }

            pub fn get_const(obj: *const Object, key: str8) ?*const Value {
                const key_node = obj.map.get_const(key) orelse return null;
                return switch (key_node.*.kind) {
                    .string => |str| str.child,
                    else => unreachable,
                };
            }

            pub fn get(obj: *Object, key: str8) ?*Value {
                const key_node = obj.map.get(key) orelse return null;
                return switch (key_node.*.kind) {
                    .string => |str| str.child,
                    else => unreachable,
                };
            }
        };
    };
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

/// Navigate a JSON pointer path (e.g., "#/properties/name/type")
/// Supports both "#/path" (fragment) and "/path" (relative) formats
pub fn resolve_pointer(value: *const Value, pointer: str8) ?*const Value {
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
                current = obj.get_const(segment) orelse return null;
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
pub fn resolve_pointer_mut(value: *Value, pointer: str8) ?*Value {
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

        const segment = unescape_pointer_segment(segment_raw);

        switch (current.kind) {
            .object => |*obj| {
                current = obj.get(segment) orelse return null;
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
pub fn parse(arena: *Arena, input: str8) ParseError!*Value {
    var lxr: lexer.Lexer = .zero;
    try lexer.lex(&lxr, arena, input);

    var parser = Parser{
        .arena = arena,
        .tokens = lxr.tokens.items,
        .input = input,
        .pos = 0,
    };

    return parse_value(&parser);
}

const Parser = struct {
    arena: *Arena,
    tokens: []const lexer.Token,
    input: str8,
    pos: usize,

    pub const zero = Parser{
        .arena = &.empty,
        .tokens = &.{},
        .input = "",
        .pos = 0,
    };
};

fn parse_value(parser: *Parser) ParseError!*Value {
    if (parser.pos >= parser.tokens.len) {
        return error.UnexpectedEndOfInput;
    }

    const token = parser.tokens[parser.pos];
    return switch (token.kind) {
        .null => parse_null(parser),
        .true => parse_bool(parser, true),
        .false => parse_bool(parser, false),
        .string => parse_string(parser),
        .number => parse_number(parser),
        .l_bracket => parse_array(parser),
        .l_curly => parse_object(parser),
        .err => error.InvalidJson,
        else => error.UnexpectedToken,
    };
}

fn parse_null(parser: *Parser) ParseError!*Value {
    parser.pos += 1;
    return .value(
        try parser.arena.create(Value),
        .null,
        compute_null_hash(),
        prev_token_range(parser),
    );
}

fn parse_bool(parser: *Parser, value: bool) ParseError!*Value {
    parser.pos += 1;
    return .value(
        try parser.arena.create(Value),
        .{ .bool = value },
        compute_bool_hash(value),
        prev_token_range(parser),
    );
}

fn parse_string(parser: *Parser) ParseError!*Value {
    const token = parser.tokens[parser.pos];
    parser.pos += 1;

    const raw = parser.input[token.range.start.byte..token.range.close.byte];

    // Remove quotes and unescape
    if (raw.len < 2) return error.InvalidString;
    const content = try unescape_string(parser.arena, raw[1 .. raw.len - 1]);

    return .value(
        try parser.arena.create(Value),
        .{ .string = .{ .value = content } },
        compute_string_hash(content),
        prev_token_range(parser),
    );
}

fn parse_number(parser: *Parser) ParseError!*Value {
    const token = parser.tokens[parser.pos];
    parser.pos += 1;

    const raw = parser.input[token.range.start.byte..token.range.close.byte];

    if (std.fmt.parseInt(i64, raw, 10)) |int_val| {
        return .value(
            try parser.arena.create(Value),
            .{ .integer = int_val },
            // hashed as float so 42.0 == 42
            compute_float_hash(@floatFromInt(int_val)),
            prev_token_range(parser),
        );
    } else |_| {
        const float_val = std.fmt.parseFloat(f64, raw) catch return error.InvalidNumber;
        return .value(
            try parser.arena.create(Value),
            .{ .float = float_val },
            compute_float_hash(float_val),
            prev_token_range(parser),
        );
    }
}

fn parse_array(parser: *Parser) ParseError!*Value {
    parser.pos += 1; // consume '['
    const range_start = prev_token_range(parser).start;

    // Check for empty array
    if (parser.pos < parser.tokens.len and parser.tokens[parser.pos].kind == .r_bracket) {
        parser.pos += 1;
        const range_close = prev_token_range(parser).close;
        const arr: Value.Kind.Array = .zero;
        return .value(
            try parser.arena.create(Value),
            .{ .array = arr },
            compute_array_hash(&arr),
            .{ .start = range_start, .close = range_close },
        );
    }

    var list: Value.Kind.Array = .zero;

    while (parser.pos < parser.tokens.len) {
        // TODO: make parse functions take dest pointer if we're going to be using linked lists
        const item = try parse_value(parser);

        list.append(item);

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
    const range_close = prev_token_range(parser).close;

    return .value(
        try parser.arena.create(Value),
        .{ .array = list },
        compute_array_hash(&list),
        .{ .start = range_start, .close = range_close },
    );
}

fn parse_object(parser: *Parser) ParseError!*Value {
    parser.pos += 1; // consume '{'
    const range_start = prev_token_range(parser).start;

    var obj: Value.Kind.Object = .zero;

    // Check for empty object
    if (parser.pos < parser.tokens.len and parser.tokens[parser.pos].kind == .r_curly) {
        parser.pos += 1;
        const range_close = prev_token_range(parser).close;
        return .value(
            try parser.arena.create(Value),
            .{ .object = obj },
            compute_object_hash(&obj),
            .{ .start = range_start, .close = range_close },
        );
    }

    while (true) {
        if (parser.pos >= parser.tokens.len) {
            return error.UnexpectedEndOfInput;
        }

        const key_token = parser.tokens[parser.pos];
        if (key_token.kind != .string) {
            return error.UnexpectedToken;
        }
        parser.pos += 1;

        const raw_key = parser.input[key_token.range.start.byte..key_token.range.close.byte];
        if (raw_key.len < 2) return error.InvalidString;
        const key = try unescape_string(parser.arena, raw_key[1 .. raw_key.len - 1]);

        if (parser.pos >= parser.tokens.len) {
            return error.UnexpectedEndOfInput;
        }
        if (parser.tokens[parser.pos].kind != .colon) {
            return error.UnexpectedToken;
        }
        parser.pos += 1;

        const value = try parse_value(parser);

        const entry = try obj.map.get_or_put(parser.arena, key);
        if (entry.found_existing) {
            entry.value_ptr.*.kind.string.child = value;
        } else {
            const key_node: *Value = .value(
                try parser.arena.create(Value),
                .{ .string = .{ .value = entry.key_ptr.*, .child = value } },
                compute_string_hash(entry.key_ptr.*),
                key_token.range,
            );
            obj.properties.append(key_node);
            entry.value_ptr.* = key_node;
        }

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

    const range_close = prev_token_range(parser).close;
    return .value(
        try parser.arena.create(Value),
        .{ .object = obj },
        compute_object_hash(&obj),
        .{ .start = range_start, .close = range_close },
    );
}

const CharNode = struct {
    byte: u8,
    next: ?*CharNode = null,
};

// TODO: test and replace unescape_string
fn unescape_string2(arena: *Arena, input: str8) ParseError!str8 {
    var slash_pos = mem.indexOfScalar(u8, input, '\\') orelse input.len;
    // Fast path: no escapes
    if (slash_pos == input.len) {
        return input;
    }

    const arena_start_pos = arena.pos;
    _ = arena.alloc(u8, input.len);
    arena.set_pos(arena_start_pos);
    var cursor: u32 = 0;

    while (cursor < input.len and slash_pos < input.len) {
        defer if (mem.indexOfScalar(u8, input[slash_pos + 1 ..], '\\')) |next_slash_pos| {
            slash_pos += next_slash_pos + 1;
        } else {
            slash_pos = input.len;
        };

        const escaped_pos = slash_pos + 1;
        if (escaped_pos >= input.len) {
            break;
        }
        // \uXXXX
        if (input[escaped_pos] == 'u' and escaped_pos + 5 < input.len) {
            const hex = input[escaped_pos + 2 ..][0..6];
            const codepoint = std.fmt.parseInt(u21, hex, 16) orelse continue;
            var buf: [4]u8 = undefined;
            const codepoint_len = std.unicode.utf8Encode(codepoint, &buf) orelse continue;
            try arena.dupe(u8, input[cursor..escaped_pos]);
            try arena.dupe(u8, &buf[0..codepoint_len]);
            cursor = escaped_pos + 6;
            continue;
        }
        const char = switch (input[escaped_pos]) {
            'n' => '\n',
            't' => '\t',
            'r' => '\r',
            '"' => '"',
            '\\' => '\\',
            '/' => '/',
            'b' => 0x80,
            'f' => 0x0C,
            else => {
                continue;
            },
        };
        try arena.dupe(u8, input[cursor..escaped_pos]);
        try arena.dupe(u8, &.{char});
        cursor = escaped_pos + 1;
    }
    try arena.dupe(u8, input[cursor..]);
    return arena.memory[arena_start_pos..arena.pos];
}

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

fn hash_null_into(hasher: *std.hash.Wyhash) void {
    hasher.update(&[_]u8{@intFromEnum(Value.Kind_Tag.null)});
}

fn hash_bool_into(hasher: *std.hash.Wyhash, value: bool) void {
    hasher.update(&[_]u8{ @intFromEnum(Value.Kind_Tag.bool), @intFromBool(value) });
}

fn hash_string_into(hasher: *std.hash.Wyhash, value: str8) void {
    hasher.update(&[_]u8{@intFromEnum(Value.Kind_Tag.string)});
    hasher.update(value);
}

fn hash_float_into(hasher: *std.hash.Wyhash, value: f64) void {
    hasher.update(&[_]u8{@intFromEnum(Value.Kind_Tag.float)});
    hasher.update(mem.asBytes(&value));
}

fn hash_integer_into(hasher: *std.hash.Wyhash, value: i64) void {
    // For JSON Schema, integer and float values that are numerically equal must hash equal
    // (e.g., 42 and 42.0 are the same value)
    hash_float_into(hasher, @intFromFloat(value));
}

fn hash_hash_into(hasher: *std.hash.Wyhash, hash: u64) void {
    hasher.update(mem.asBytes(&hash));
}

fn hash_array_into(hasher: *std.hash.Wyhash, arr: *const Value.Kind.Array) void {
    hasher.update(&[_]u8{@intFromEnum(Value.Kind_Tag.array)});
    var iter = arr.iter();
    while (iter.next()) |item| {
        hash_hash_into(hasher, item.hash);
    }
}

fn hash_object_into(hasher: *std.hash.Wyhash, obj: *const Value.Kind.Object) void {
    hasher.update(&[_]u8{@intFromEnum(Value.Kind_Tag.object)});

    const n = obj.count();
    if (n == 0) return;

    const scratch = Arena.get_scratch(&.{});
    defer scratch.release();

    const properties = scratch.arena.alloc(*const Value, n) catch {
        hash_object_unsorted(hasher, obj);
        return;
    };

    var iter = obj.properties.iter();
    var i: usize = 0;
    while (iter.next()) |property| : (i += 1) {
        properties[i] = property;
    }

    // Sort indices by key for consistent hashing regardless of insertion order
    // PERF: sort by hash instead. Lexicographic sorting is not necessary.
    mem.sort(*const Value, properties, {}, struct {
        pub fn less_than(_: void, a: *const Value, b: *const Value) bool {
            return mem.lessThan(u8, a.kind.string.value, b.kind.string.value);
        }
    }.less_than);

    for (properties) |property| {
        hash_hash_into(hasher, property.hash);
        hash_hash_into(hasher, property.kind.string.child.?.hash);
    }
}

fn hash_object_unsorted(hasher: *std.hash.Wyhash, obj: *const Value.Kind.Object) void {
    var iter = obj.properties.iter();
    while (iter.next()) |property| {
        const child = property.kind.string.child.?;
        hash_hash_into(hasher, property.hash);
        hash_hash_into(hasher, child.hash);
    }
}

fn hash_value_into(hasher: *std.hash.Wyhash, value: *const Value) void {
    switch (value.kind) {
        .null => hash_null_into(hasher),
        .bool => |b| hash_bool_into(hasher, b),
        .integer => |i| hash_integer_into(hasher, i),
        .float => |f| hash_float_into(hasher, f),
        .string => |s| hash_string_into(hasher, s.value),
        .array => |*arr| hash_array_into(hasher, arr),
        .object => |*obj| hash_object_into(hasher, obj),
    }
}

fn compute_null_hash() u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hash_null_into(&hasher);
    return hasher.final();
}

fn compute_bool_hash(value: bool) u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hash_bool_into(&hasher, value);
    return hasher.final();
}

pub fn compute_string_hash(value: str8) u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hash_string_into(&hasher, value);
    return hasher.final();
}

fn compute_float_hash(value: f64) u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hash_float_into(&hasher, value);
    return hasher.final();
}

fn compute_integer_hash(value: i64) u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hash_integer_into(&hasher, value);
    return hasher.final();
}

fn compute_array_hash(arr: *const Value.Kind.Array) u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hash_array_into(&hasher, arr);
    return hasher.final();
}

fn compute_object_hash(obj: *const Value.Kind.Object) u64 {
    var hasher = std.hash.Wyhash.init(hash_seed);
    hash_object_into(&hasher, obj);
    return hasher.final();
}

fn prev_token_range(parser: *const Parser) lexer.Token.Range {
    return parser.tokens[parser.pos - 1].range;
}

// ============================================================================
// Tests
// ============================================================================

test "parse null" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const result = try parse(&arena, "null");
    try std.testing.expectEqual(Value.Kind.null, result.kind);
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
    try std.testing.expectEqualStrings("hello world", result.as_string().?);
}

test "parse string with escapes" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const result = try parse(&arena, "\"hello\\nworld\"");
    try std.testing.expectEqualStrings("hello\nworld", result.as_string().?);

    const result2 = try parse(&arena, "\"tab\\there\"");
    try std.testing.expectEqualStrings("tab\there", result2.as_string().?);
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

    const name_key = result.kind.object.map.get_const("name").?.*;
    try std.testing.expectEqualStrings("name", name_key.kind.string.value);
    try std.testing.expectEqualStrings("test", name_key.kind.string.child.?.as_string().?);

    const val = result.kind.object.get_const("value").?;
    try std.testing.expectEqual(@as(i64, 42), val.kind.integer);
}

test "parse nested structure" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const result = try parse(&arena,
        \\{"arr": [1, {"nested": true}], "obj": {"a": "b"}}
    );
    try std.testing.expectEqual(@as(usize, 2), result.kind.object.count());

    const arr = result.kind.object.get_const("arr").?;
    try std.testing.expectEqual(@as(usize, 2), arr.kind.array.len);
    try std.testing.expectEqual(@as(i64, 1), arr.kind.array.get(0).?.kind.integer);
    try std.testing.expectEqual(true, arr.kind.array.get(1).?.kind.object.get_const("nested").?.kind.bool);
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
    try std.testing.expectEqualStrings("string", resolved.?.as_string().?);
}

test "resolve_pointer - with fragment" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const value = try parse(&arena,
        \\{"properties": {"name": {"type": "string"}}}
    );

    const resolved = value.resolve_pointer("#/properties/name/type");
    try std.testing.expect(resolved != null);
    try std.testing.expectEqualStrings("string", resolved.?.as_string().?);
}

test "resolve_pointer - array index" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const value = try parse(&arena,
        \\{"items": [{"type": "number"}, {"type": "string"}]}
    );

    const resolved = value.resolve_pointer("/items/1/type");
    try std.testing.expect(resolved != null);
    try std.testing.expectEqualStrings("string", resolved.?.as_string().?);
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

// ============================================================================
// Additional hash consistency tests (moved from json-schema.zig ValueHash tests)
// ============================================================================

test "hash consistency - primitives" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    // null
    const null1 = try parse(&arena, "null");
    const null2 = try parse(&arena, "null");
    try std.testing.expectEqual(null1.hash, null2.hash);

    // booleans
    const true1 = try parse(&arena, "true");
    const true2 = try parse(&arena, "true");
    try std.testing.expectEqual(true1.hash, true2.hash);

    const false1 = try parse(&arena, "false");
    const false2 = try parse(&arena, "false");
    try std.testing.expectEqual(false1.hash, false2.hash);

    // different booleans have different hashes
    try std.testing.expect(true1.hash != false1.hash);
}

test "hash consistency - numbers" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    // integers
    const int1 = try parse(&arena, "12345");
    const int2 = try parse(&arena, "12345");
    try std.testing.expectEqual(int1.hash, int2.hash);

    // negative integers
    const neg1 = try parse(&arena, "-9876");
    const neg2 = try parse(&arena, "-9876");
    try std.testing.expectEqual(neg1.hash, neg2.hash);

    // floats
    const float1 = try parse(&arena, "3.14159");
    const float2 = try parse(&arena, "3.14159");
    try std.testing.expectEqual(float1.hash, float2.hash);

    // different numbers have different hashes
    const one = try parse(&arena, "1");
    const two = try parse(&arena, "2");
    try std.testing.expect(one.hash != two.hash);
}

test "hash consistency - strings" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const str1 = try parse(&arena, "\"hello\"");
    const str2 = try parse(&arena, "\"hello\"");
    try std.testing.expectEqual(str1.hash, str2.hash);

    // different strings have different hashes
    const a = try parse(&arena, "\"a\"");
    const b = try parse(&arena, "\"b\"");
    try std.testing.expect(a.hash != b.hash);
}

test "hash consistency - arrays" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const arr1 = try parse(&arena, "[1, 2, 3, 4]");
    const arr2 = try parse(&arena, "[1, 2, 3, 4]");
    try std.testing.expectEqual(arr1.hash, arr2.hash);

    // array order matters
    const forward = try parse(&arena, "[1, 2, 3]");
    const reverse = try parse(&arena, "[3, 2, 1]");
    try std.testing.expect(forward.hash != reverse.hash);

    // empty array vs empty object
    const empty_arr = try parse(&arena, "[]");
    const empty_obj = try parse(&arena, "{}");
    try std.testing.expect(empty_arr.hash != empty_obj.hash);
}

test "hash consistency - objects with different key orders" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const obj1 = try parse(&arena,
        \\{"a": 1, "b": 2, "c": 3}
    );
    const obj2 = try parse(&arena,
        \\{"c": 3, "b": 2, "a": 1}
    );
    try std.testing.expectEqual(obj1.hash, obj2.hash);
}

test "hash consistency - nested objects with different key orders" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const obj1 = try parse(&arena,
        \\{"outer": {"x": 1, "y": 2}, "z": 3}
    );
    const obj2 = try parse(&arena,
        \\{"z": 3, "outer": {"y": 2, "x": 1}}
    );
    try std.testing.expectEqual(obj1.hash, obj2.hash);
}

test "hash consistency - complex nested structure" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const v1 = try parse(&arena,
        \\{"nested": {"list": [1, 2, 3], "flag": true, "value": 42}, "name": "example"}
    );
    const v2 = try parse(&arena,
        \\{"name": "example", "nested": {"value": 42, "flag": true, "list": [1, 2, 3]}}
    );
    try std.testing.expectEqual(v1.hash, v2.hash);
}

test "hash consistency - different object values produce different hashes" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const obj1 = try parse(&arena,
        \\{"a": 1}
    );
    const obj2 = try parse(&arena,
        \\{"a": 2}
    );
    try std.testing.expect(obj1.hash != obj2.hash);

    const obj3 = try parse(&arena,
        \\{"a": 1, "b": 2}
    );
    const obj4 = try parse(&arena,
        \\{"a": 1, "b": 2, "c": 3}
    );
    try std.testing.expect(obj3.hash != obj4.hash);
}

test "hash consistency - nested object value differences" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const obj1 = try parse(&arena,
        \\{"nested": {"x": 1, "y": 2}}
    );
    const obj2 = try parse(&arena,
        \\{"nested": {"x": 1, "y": 3}}
    );
    try std.testing.expect(obj1.hash != obj2.hash);
}

test "hash consistency - type differences" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    // null vs false
    const null_val = try parse(&arena, "null");
    const false_val = try parse(&arena, "false");
    try std.testing.expect(null_val.hash != false_val.hash);

    // true vs 1
    const true_val = try parse(&arena, "true");
    const one_val = try parse(&arena, "1");
    try std.testing.expect(true_val.hash != one_val.hash);

    // false vs 0
    const zero_val = try parse(&arena, "0");
    try std.testing.expect(false_val.hash != zero_val.hash);

    // [false] vs [0]
    const arr_false = try parse(&arena, "[false]");
    const arr_zero = try parse(&arena, "[0]");
    try std.testing.expect(arr_false.hash != arr_zero.hash);
}

test "hash consistency - mixed array" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const v1 = try parse(&arena,
        \\{"mixed": [null, true, false, 0, 1.5, "text"]}
    );
    const v2 = try parse(&arena,
        \\{"mixed": [null, true, false, 0, 1.5, "text"]}
    );
    try std.testing.expectEqual(v1.hash, v2.hash);
}
