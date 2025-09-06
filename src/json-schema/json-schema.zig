//! JSON Schema Subsystem
//!
//! Implements the validation layer of JSONLS
//! Implements multiple core concepts:
//! - Parsing and validation of JSON Schemas
//! - Validation of JSON according to it's respective schema
//! - Asynchronous fetching of schemas defined by URI from the interwebs
const std = @import("std");
const mem = std.mem;
const Arena = std.heap.ArenaAllocator;

const str8 = []const u8;

pub const Schema = struct {
    root: *const Constraint,
    arena: Arena,

    pub const Constraint = struct {
        next: ?*Constraint,
        kind: Kind,

        pub const Kind = union(enum) {
            true: void,
            false: void,
            type: []ValidationType,
            all: void, // corresponds to allOf,
            min_len: u64,
            max_len: u64,
            min_int: i64,
            max_int: i64,
            min_f64: f64,
            max_f64: f64,
        };

        pub const zero = Constraint{
            .next = null,
            .kind = .true,
        };
    };

    pub fn is_valid(schema: *const Schema, input: str8) bool {
        var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        const arena = arena_state.allocator();
        const json = std.json.parseFromSlice(std.json.Value, arena, input, .{
            .allocate = .alloc_if_needed,
            .parse_numbers = true,
            .ignore_unknown_fields = false,
            .duplicate_field_behavior = .use_last,
            .max_value_len = std.json.default_max_value_len,
        }) catch unreachable; // todo: error
        return check(schema.root, &json.value);
    }
};

fn check(constraint: *const Schema.Constraint, value: *const std.json.Value) bool {
    switch (constraint.kind) {
        .true => return true,
        .false => return false,
        .type => |v_types| {
            var result = false;
            for (v_types) |v_type| {
                result = result or switch (v_type) {
                    .string => value.* == .string,
                    .object => value.* == .object,
                    .array => value.* == .array,
                    .number => value.* == .float or value.* == .integer or value.* == .number_string,
                    .boolean => value.* == .bool,
                    .null => value.* == .null,
                    .integer => value.* == .integer,
                };
            }
            return result;
        },
        .all => {
            var result = true;
            var cur_constraint = constraint.next;
            while (cur_constraint) |cur| : (cur_constraint = cur.next) {
                result = result and check(cur, value);
            }
            return result;
        },
        .min_len => |min_len| {
            return value.* != .string or (std.unicode.utf8CountCodepoints(value.string) catch 0) >= min_len;
        },
        .max_len => |max_len| {
            return value.* != .string or (std.unicode.utf8CountCodepoints(value.string) catch 0) <= max_len;
        },
        .max_int => |max_int| {
            return switch (value.*) {
                .integer => |int_val| int_val <= max_int,
                .float => |float_val| float_val <= @as(f64, @floatFromInt(max_int)),
                .number_string => true, // todo: handle?
                else => true,
            };
        },
        .min_int => |min_int| {
            return switch (value.*) {
                .integer => |int_val| int_val >= min_int,
                .float => |float_val| float_val >= @as(f64, @floatFromInt(min_int)),
                .number_string => true, // todo: handle?
                else => true,
            };
        },
        .max_f64 => |max_f64| {
            return switch (value.*) {
                .integer => |int_val| @as(f64, @floatFromInt(int_val)) <= max_f64,
                .float => |float_val| float_val <= max_f64,
                .number_string => true, // todo: handle?
                else => true,
            };
        },
        .min_f64 => |min_f64| {
            return switch (value.*) {
                .integer => |int_val| @as(f64, @floatFromInt(int_val)) >= min_f64,
                .float => |float_val| float_val >= min_f64,
                .number_string => true, // todo: handle?
                else => true,
            };
        },
    }
}

pub fn parse(schema_contents: str8) !Schema {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const arena = arena_state.allocator();
    const parsed_schema = try std.json.parseFromSlice(std.json.Value, arena, schema_contents, .{
        .allocate = .alloc_if_needed,
        .parse_numbers = true,
        .ignore_unknown_fields = false,
        .duplicate_field_behavior = .use_last,
        .max_value_len = 1024,
    });
    const root = try parse_constraint(&arena_state, parsed_schema.value);
    return Schema{
        .root = root,
        .arena = arena_state,
    };
}

fn parse_constraint(arena: *Arena, schema: std.json.Value) !*Schema.Constraint {
    const constraint = try arena.allocator().create(Schema.Constraint);
    constraint.next = null;
    constraint.kind = .true;
    parse: switch (schema) {
        .bool => |value| {
            constraint.kind = switch (value) {
                true => .true,
                false => .false,
            };
        },
        .object => |obj| {
            if (obj.count() == 0) {
                constraint.kind = .true;
                break :parse;
            }
            // todo: error
            if (parse_validation__type(arena, &obj) catch null) |v_types| {
                try chain_with(arena, constraint, .{ .type = v_types });
            }
            if (parse_validation__min_length(&obj)) |min_length| {
                try chain_with(arena, constraint, .{ .min_len = min_length });
            }
            if (parse_validation__max_length(&obj)) |max_length| {
                try chain_with(arena, constraint, .{ .max_len = max_length });
            }
            if (parse_validation__min(&obj)) |min| {
                try chain_with(arena, constraint, min);
            }
            if (parse_validation__max(&obj)) |max| {
                try chain_with(arena, constraint, max);
            }
        },
        else => return error.UnrecognizedSchemaType,
    }
    return constraint;
}

fn chain_with(arena: *Arena, from: *Schema.Constraint, new_kind: Schema.Constraint.Kind) !void {
    if (from.kind == .all) {
        // add new link to chain
        const new = try arena.allocator().create(Schema.Constraint);
        new.next = from.next;
        new.kind = new_kind;
        from.next = new;
    } else if (from.kind != .true) {
        // turn from into chain of length two with it's current constraint and the new constraint
        var constraints = try arena.allocator().alloc(Schema.Constraint, 2);
        @memset(constraints, .zero);
        constraints[0].kind = from.kind;
        constraints[0].next = &constraints[1];
        from.next = &constraints[0];
        from.kind = .all;
        constraints[1].kind = new_kind;
    } else {
        from.kind = new_kind;
    }
}

/// The "type" field on an object
/// https://www.learnjsonschema.com/2020-12/validation/type/
const ValidationType = enum {
    /// The JSON null constant
    null,
    /// The JSON true or false constants
    boolean,
    /// A JSON object
    object,
    /// A JSON array
    array,
    /// A JSON number
    /// IEEE 764 64-bit double-precision floating point encoding (except NaN, Infinity, and +0)
    number,
    /// A JSON number that represents an integer
    /// 64-bit signed integer encoding (from -(2^53)+1 to (2^53)-1)
    integer,
    /// A JSON string
    /// UTF-8 Unicode encoding
    string,

    pub const Map = std.StaticStringMap(ValidationType).initComptime(.{
        .{ "null", .null },
        .{ "boolean", .boolean },
        .{ "object", .object },
        .{ "array", .array },
        .{ "number", .number },
        .{ "integer", .integer },
        .{ "string", .string },
    });
};

fn parse_validation__type(arena: *Arena, obj: *const std.json.ObjectMap) !?[]ValidationType {
    const ty = obj.get("type") orelse return null;
    switch (ty) {
        .string => |v_type_str| {
            const v_type = try arena.allocator().create(ValidationType);
            // todo: error
            v_type.* = ValidationType.Map.get(v_type_str) orelse return null;
            return v_type[0..1];
        },
        .array => |arr| {
            var v_types: std.ArrayList(ValidationType) = try .initCapacity(arena.allocator(), arr.items.len);
            for (arr.items) |v_type_str| {
                if (v_type_str != .string) {
                    // todo: error
                    continue;
                }
                const v_type = ValidationType.Map.get(v_type_str.string) orelse continue;
                v_types.appendAssumeCapacity(v_type);
            }
            return v_types.items;
        },
        else => return null,
    }
}
fn parse_validation__min_length(obj: *const std.json.ObjectMap) ?u64 {
    const min_len = obj.get("minLength") orelse return null;
    switch (min_len) {
        .integer => |int_val| {
            if (int_val < 0) {
                return 0;
            }
            return @intCast(int_val);
        },
        else => return null,
    }
}

fn parse_validation__max_length(obj: *const std.json.ObjectMap) ?u64 {
    const min_len = obj.get("maxLength") orelse return null;
    switch (min_len) {
        .integer => |int_val| {
            if (int_val < 0) {
                return 0;
            }
            return @intCast(int_val);
        },
        else => return null,
    }
}

fn parse_validation__min(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const min_val = obj.get("minimum") orelse return null;
    switch (min_val) {
        .integer => |int_val| {
            return .{ .min_int = int_val };
        },
        .float => |float_val| {
            return .{ .min_f64 = float_val };
        },
        else => return null,
    }
}

fn parse_validation__max(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const max_val = obj.get("maximum") orelse return null;
    switch (max_val) {
        .integer => |int_val| {
            return .{ .max_int = int_val };
        },
        .float => |float_val| {
            return .{ .max_f64 = float_val };
        },
        else => return null,
    }
}

test "boolean schema - true schema accepts everything" {
    const schema_str = "true";
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // True schema should accept any valid JSON
    try std.testing.expectEqual(schema.is_valid("42"), true);
    try std.testing.expectEqual(schema.is_valid("\"hello\""), true);
    try std.testing.expectEqual(schema.is_valid("null"), true);
    try std.testing.expectEqual(schema.is_valid("[]"), true);
    try std.testing.expectEqual(schema.is_valid("{}"), true);
    try std.testing.expectEqual(schema.is_valid("true"), true);
    try std.testing.expectEqual(schema.is_valid("false"), true);
}

test "boolean schema - false schema rejects everything" {
    const schema_str = "false";
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // False schema should reject any JSON
    try std.testing.expectEqual(schema.is_valid("42"), false);
    try std.testing.expectEqual(schema.is_valid("\"hello\""), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
    try std.testing.expectEqual(schema.is_valid("{}"), false);
    try std.testing.expectEqual(schema.is_valid("true"), false);
    try std.testing.expectEqual(schema.is_valid("false"), false);
}

test "empty object schema - accepts everything" {
    const schema_str = "{}";
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Empty object schema should accept any valid JSON
    try std.testing.expectEqual(schema.is_valid("42"), true);
    try std.testing.expectEqual(schema.is_valid("\"test\""), true);
    try std.testing.expectEqual(schema.is_valid("null"), true);
    try std.testing.expectEqual(schema.is_valid("[]"), true);
    try std.testing.expectEqual(schema.is_valid("{}"), true);
}

test "type constraint - string" {
    const schema_str =
        \\{
        \\  "type": "string"
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Should accept strings
    try std.testing.expectEqual(schema.is_valid("\"hello\""), true);
    try std.testing.expectEqual(schema.is_valid("\"\""), true);
    try std.testing.expectEqual(schema.is_valid("\"123\""), true);

    // Should reject non-strings
    try std.testing.expectEqual(schema.is_valid("123"), false);
    try std.testing.expectEqual(schema.is_valid("true"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
    try std.testing.expectEqual(schema.is_valid("{}"), false);
}

test "type constraint - number" {
    const schema_str =
        \\{
        \\  "type": "number"
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Should accept numbers
    try std.testing.expectEqual(schema.is_valid("42"), true);
    try std.testing.expectEqual(schema.is_valid("3.14"), true);
    try std.testing.expectEqual(schema.is_valid("-10"), true);
    try std.testing.expectEqual(schema.is_valid("0"), true);
    try std.testing.expectEqual(schema.is_valid("1.5e10"), true);

    // Should reject non-numbers
    try std.testing.expectEqual(schema.is_valid("\"42\""), false);
    try std.testing.expectEqual(schema.is_valid("true"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
    try std.testing.expectEqual(schema.is_valid("{}"), false);
}

test "type constraint - integer" {
    const schema_str =
        \\{
        \\  "type": "integer"
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Should accept integers
    try std.testing.expectEqual(schema.is_valid("42"), true);
    try std.testing.expectEqual(schema.is_valid("-10"), true);
    try std.testing.expectEqual(schema.is_valid("0"), true);

    // Should reject non-integers
    try std.testing.expectEqual(schema.is_valid("3.14"), false);
    try std.testing.expectEqual(schema.is_valid("\"42\""), false);
    try std.testing.expectEqual(schema.is_valid("true"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
}

test "type constraint - boolean" {
    const schema_str =
        \\{
        \\  "type": "boolean"
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Should accept booleans
    try std.testing.expectEqual(schema.is_valid("true"), true);
    try std.testing.expectEqual(schema.is_valid("false"), true);

    // Should reject non-booleans
    try std.testing.expectEqual(schema.is_valid("\"true\""), false);
    try std.testing.expectEqual(schema.is_valid("1"), false);
    try std.testing.expectEqual(schema.is_valid("0"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
}

test "type constraint - null" {
    const schema_str =
        \\{
        \\  "type": "null"
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Should accept null
    try std.testing.expectEqual(schema.is_valid("null"), true);

    // Should reject non-null
    try std.testing.expectEqual(schema.is_valid("\"null\""), false);
    try std.testing.expectEqual(schema.is_valid("0"), false);
    try std.testing.expectEqual(schema.is_valid("false"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
    try std.testing.expectEqual(schema.is_valid("{}"), false);
}

test "type constraint - array" {
    const schema_str =
        \\{
        \\  "type": "array"
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Should accept arrays
    try std.testing.expectEqual(schema.is_valid("[]"), true);
    try std.testing.expectEqual(schema.is_valid("[1, 2, 3]"), true);
    try std.testing.expectEqual(schema.is_valid("[\"a\", \"b\"]"), true);
    try std.testing.expectEqual(schema.is_valid("[true, false, null]"), true);

    // Should reject non-arrays
    try std.testing.expectEqual(schema.is_valid("{}"), false);
    try std.testing.expectEqual(schema.is_valid("\"array\""), false);
    try std.testing.expectEqual(schema.is_valid("123"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
}

test "type constraint - object" {
    const schema_str =
        \\{
        \\  "type": "object"
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Should accept objects
    try std.testing.expectEqual(schema.is_valid("{}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"key\": \"value\"}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"a\": 1, \"b\": 2}"), true);

    // Should reject non-objects
    try std.testing.expectEqual(schema.is_valid("[]"), false);
    try std.testing.expectEqual(schema.is_valid("\"object\""), false);
    try std.testing.expectEqual(schema.is_valid("123"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
}

test "string constraints - minLength and maxLength" {
    const schema_str =
        \\{
        \\  "type": "string",
        \\  "minLength": 2,
        \\  "maxLength": 5
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid lengths
    try std.testing.expectEqual(schema.is_valid("\"ab\""), true);
    try std.testing.expectEqual(schema.is_valid("\"abc\""), true);
    try std.testing.expectEqual(schema.is_valid("\"abcde\""), true);

    // Invalid lengths
    try std.testing.expectEqual(schema.is_valid("\"a\""), false);
    try std.testing.expectEqual(schema.is_valid("\"abcdef\""), false);
    try std.testing.expectEqual(schema.is_valid("\"\""), false);

    // Non-strings should fail
    try std.testing.expectEqual(schema.is_valid("123"), false);
}

test "string constraints - pattern" {
    const schema_str =
        \\{
        \\  "type": "string",
        \\  "pattern": "^[a-z]+$"
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Matching pattern
    try std.testing.expectEqual(schema.is_valid("\"abc\""), true);
    try std.testing.expectEqual(schema.is_valid("\"hello\""), true);

    // Not matching pattern
    try std.testing.expectEqual(schema.is_valid("\"ABC\""), false);
    try std.testing.expectEqual(schema.is_valid("\"hello123\""), false);
    try std.testing.expectEqual(schema.is_valid("\"hello world\""), false);
}

test "number constraints - minimum and maximum" {
    const schema_str =
        \\{
        \\  "type": "number",
        \\  "minimum": 0,
        \\  "maximum": 100
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid range
    try std.testing.expectEqual(schema.is_valid("0"), true);
    try std.testing.expectEqual(schema.is_valid("50"), true);
    try std.testing.expectEqual(schema.is_valid("100"), true);
    try std.testing.expectEqual(schema.is_valid("99.99"), true);

    // Outside range
    try std.testing.expectEqual(schema.is_valid("-1"), false);
    try std.testing.expectEqual(schema.is_valid("101"), false);
    try std.testing.expectEqual(schema.is_valid("1000"), false);
}

test "number constraints - exclusiveMinimum and exclusiveMaximum" {
    const schema_str =
        \\{
        \\  "type": "number",
        \\  "exclusiveMinimum": 0,
        \\  "exclusiveMaximum": 100
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid range (exclusive)
    try std.testing.expectEqual(schema.is_valid("0.1"), true);
    try std.testing.expectEqual(schema.is_valid("50"), true);
    try std.testing.expectEqual(schema.is_valid("99.99"), true);

    // Invalid (at boundaries)
    try std.testing.expectEqual(schema.is_valid("0"), false);
    try std.testing.expectEqual(schema.is_valid("100"), false);
    try std.testing.expectEqual(schema.is_valid("-1"), false);
    try std.testing.expectEqual(schema.is_valid("101"), false);
}

test "array constraints - minItems and maxItems" {
    const schema_str =
        \\{
        \\  "type": "array",
        \\  "minItems": 1,
        \\  "maxItems": 3
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid counts
    try std.testing.expectEqual(schema.is_valid("[1]"), true);
    try std.testing.expectEqual(schema.is_valid("[1, 2]"), true);
    try std.testing.expectEqual(schema.is_valid("[1, 2, 3]"), true);

    // Invalid counts
    try std.testing.expectEqual(schema.is_valid("[]"), false);
    try std.testing.expectEqual(schema.is_valid("[1, 2, 3, 4]"), false);
}

test "array constraints - uniqueItems" {
    const schema_str =
        \\{
        \\  "type": "array",
        \\  "uniqueItems": true
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Unique items
    try std.testing.expectEqual(schema.is_valid("[1, 2, 3]"), true);
    try std.testing.expectEqual(schema.is_valid("[\"a\", \"b\", \"c\"]"), true);
    try std.testing.expectEqual(schema.is_valid("[]"), true);

    // Duplicate items
    try std.testing.expectEqual(schema.is_valid("[1, 2, 1]"), false);
    try std.testing.expectEqual(schema.is_valid("[\"a\", \"a\"]"), false);
}

test "object constraints - required properties" {
    const schema_str =
        \\{
        \\  "type": "object",
        \\  "properties": {
        \\    "name": { "type": "string" },
        \\    "age": { "type": "number" }
        \\  },
        \\  "required": ["name"]
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Has required property
    try std.testing.expectEqual(schema.is_valid("{\"name\": \"John\"}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"name\": \"John\", \"age\": 30}"), true);

    // Missing required property
    try std.testing.expectEqual(schema.is_valid("{}"), false);
    try std.testing.expectEqual(schema.is_valid("{\"age\": 30}"), false);
}

test "object constraints - additionalProperties" {
    const schema_str =
        \\{
        \\  "type": "object",
        \\  "properties": {
        \\    "name": { "type": "string" }
        \\  },
        \\  "additionalProperties": false
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Only defined properties
    try std.testing.expectEqual(schema.is_valid("{\"name\": \"John\"}"), true);
    try std.testing.expectEqual(schema.is_valid("{}"), true);

    // Additional properties present
    try std.testing.expectEqual(schema.is_valid("{\"name\": \"John\", \"age\": 30}"), false);
    try std.testing.expectEqual(schema.is_valid("{\"extra\": \"field\"}"), false);
}

test "enum constraint" {
    const schema_str =
        \\{
        \\  "enum": ["red", "green", "blue", 42, null]
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid enum values
    try std.testing.expectEqual(schema.is_valid("\"red\""), true);
    try std.testing.expectEqual(schema.is_valid("\"green\""), true);
    try std.testing.expectEqual(schema.is_valid("\"blue\""), true);
    try std.testing.expectEqual(schema.is_valid("42"), true);
    try std.testing.expectEqual(schema.is_valid("null"), true);

    // Invalid enum values
    try std.testing.expectEqual(schema.is_valid("\"yellow\""), false);
    try std.testing.expectEqual(schema.is_valid("43"), false);
    try std.testing.expectEqual(schema.is_valid("false"), false);
}

test "const constraint" {
    const schema_str =
        \\{
        \\  "const": "fixed-value"
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Exact match
    try std.testing.expectEqual(schema.is_valid("\"fixed-value\""), true);

    // Different values
    try std.testing.expectEqual(schema.is_valid("\"other-value\""), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("42"), false);
}

test "allOf combinator" {
    const schema_str =
        \\{
        \\  "allOf": [
        \\    { "type": "number" },
        \\    { "minimum": 0 },
        \\    { "maximum": 100 }
        \\  ]
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Satisfies all constraints
    try std.testing.expectEqual(schema.is_valid("50"), true);
    try std.testing.expectEqual(schema.is_valid("0"), true);
    try std.testing.expectEqual(schema.is_valid("100"), true);

    // Fails one or more constraints
    try std.testing.expectEqual(schema.is_valid("-1"), false);
    try std.testing.expectEqual(schema.is_valid("101"), false);
    try std.testing.expectEqual(schema.is_valid("\"50\""), false);
}

test "anyOf combinator" {
    const schema_str =
        \\{
        \\  "anyOf": [
        \\    { "type": "string" },
        \\    { "type": "number" }
        \\  ]
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Satisfies at least one
    try std.testing.expectEqual(schema.is_valid("\"hello\""), true);
    try std.testing.expectEqual(schema.is_valid("42"), true);

    // Satisfies none
    try std.testing.expectEqual(schema.is_valid("true"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
}

test "oneOf combinator" {
    const schema_str =
        \\{
        \\  "oneOf": [
        \\    { "type": "number", "multipleOf": 5 },
        \\    { "type": "number", "multipleOf": 3 }
        \\  ]
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Satisfies exactly one
    try std.testing.expectEqual(schema.is_valid("10"), true); // multiple of 5 only
    try std.testing.expectEqual(schema.is_valid("9"), true); // multiple of 3 only

    // Satisfies both (invalid for oneOf)
    try std.testing.expectEqual(schema.is_valid("15"), false); // multiple of both 3 and 5

    // Satisfies none
    try std.testing.expectEqual(schema.is_valid("7"), false);
    try std.testing.expectEqual(schema.is_valid("\"hello\""), false);
}

test "not combinator" {
    const schema_str =
        \\{
        \\  "not": {
        \\    "type": "string"
        \\  }
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Not a string (valid)
    try std.testing.expectEqual(schema.is_valid("42"), true);
    try std.testing.expectEqual(schema.is_valid("true"), true);
    try std.testing.expectEqual(schema.is_valid("null"), true);
    try std.testing.expectEqual(schema.is_valid("[]"), true);

    // Is a string (invalid)
    try std.testing.expectEqual(schema.is_valid("\"hello\""), false);
    try std.testing.expectEqual(schema.is_valid("\"\""), false);
}

test "nested object validation" {
    const schema_str =
        \\{
        \\  "type": "object",
        \\  "properties": {
        \\    "user": {
        \\      "type": "object",
        \\      "properties": {
        \\        "name": { "type": "string" },
        \\        "email": { "type": "string", "format": "email" }
        \\      },
        \\      "required": ["name", "email"]
        \\    },
        \\    "age": { "type": "integer", "minimum": 0 }
        \\  },
        \\  "required": ["user"]
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid nested object
    const valid_input =
        \\{
        \\  "user": {
        \\    "name": "John Doe",
        \\    "email": "john@example.com"
        \\  },
        \\  "age": 30
        \\}
    ;
    try std.testing.expectEqual(schema.is_valid(valid_input), true);

    // Missing required nested property
    const invalid_input =
        \\{
        \\  "user": {
        \\    "name": "John Doe"
        \\  }
        \\}
    ;
    try std.testing.expectEqual(schema.is_valid(invalid_input), false);
}

test "array items validation" {
    const schema_str =
        \\{
        \\  "type": "array",
        \\  "items": {
        \\    "type": "number",
        \\    "minimum": 0
        \\  }
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // All items valid
    try std.testing.expectEqual(schema.is_valid("[1, 2, 3]"), true);
    try std.testing.expectEqual(schema.is_valid("[0, 100, 50.5]"), true);
    try std.testing.expectEqual(schema.is_valid("[]"), true);

    // Some items invalid
    try std.testing.expectEqual(schema.is_valid("[-1, 2, 3]"), false);
    try std.testing.expectEqual(schema.is_valid("[\"1\", 2, 3]"), false);
}

test "multipleOf constraint" {
    const schema_str =
        \\{
        \\  "type": "number",
        \\  "multipleOf": 0.5
        \\}
    ;
    const schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid multiples
    try std.testing.expectEqual(schema.is_valid("0"), true);
    try std.testing.expectEqual(schema.is_valid("0.5"), true);
    try std.testing.expectEqual(schema.is_valid("1"), true);
    try std.testing.expectEqual(schema.is_valid("2.5"), true);
    try std.testing.expectEqual(schema.is_valid("-1.5"), true);

    // Not multiples
    try std.testing.expectEqual(schema.is_valid("0.3"), false);
    try std.testing.expectEqual(schema.is_valid("1.7"), false);
}
