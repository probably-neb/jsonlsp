//! JSON Schema Subsystem
//!
//! Implements the validation layer of JSONLS
//! Implements multiple core concepts:
//! - Parsing and validation of JSON Schemas
//! - Validation of JSON according to it's respective schema
//! - Asynchronous fetching of schemas defined by URI from the interwebs
//!

const std = @import("std");
const mem = std.mem;
const base = @import("base");
const Arena = base.Arena;
const XarMap = base.XarMap;

const str8 = []const u8;
pub const OOM = error{OutOfMemory};

const pcre = @import("pcre");
const json = @import("json");
const HashableJsonValue = json.hashed.Value;

const check = @import("./check.zig");

pub const Revision = enum {
    draft3,
    draft4,
    draft6,
    draft7,
    draft2019_09,
    draft2020_12,
    draft_next,
    unknown,

    fn detect(schema: *const HashableJsonValue) Revision {
        if (schema.kind != .object) return .unknown;
        const schema_uri = (schema.kind.object.get_const("$schema") orelse return .unknown).*;
        if (schema_uri.kind != .string) return .unknown;

        const uri = schema_uri.kind.string.value;
        if (mem.indexOf(u8, uri, "draft-03") != null or mem.indexOf(u8, uri, "draft3") != null) {
            return .draft3;
        } else if (mem.indexOf(u8, uri, "draft-04") != null or mem.indexOf(u8, uri, "draft4") != null) {
            return .draft4;
        } else if (mem.indexOf(u8, uri, "draft-06") != null or mem.indexOf(u8, uri, "draft6") != null) {
            return .draft6;
        } else if (mem.indexOf(u8, uri, "draft-07") != null or mem.indexOf(u8, uri, "draft7") != null) {
            return .draft7;
        } else if (mem.indexOf(u8, uri, "draft/2019-09") != null or mem.indexOf(u8, uri, "draft2019-09") != null) {
            return .draft2019_09;
        } else if (mem.indexOf(u8, uri, "draft/2020-12") != null or mem.indexOf(u8, uri, "draft2020-12") != null) {
            return .draft2020_12;
        } else if (mem.indexOf(u8, uri, "draft/next") != null or mem.indexOf(u8, uri, "draft-next") != null) {
            return .draft_next;
        }
        return .unknown;
    }
};

pub const Schema = struct {
    root: *const Constraint.Node,
    arena: Arena,

    pub const Constraint = struct {
        flags: packed struct {
            additional_items: bool = false,
            unique_items: bool = false,
            @"const": bool = false,
            false_schema: bool = false,
        } = .{},
        prefix_items: ?*const Constraint.Node = null,
        items: ?*const Constraint = null,
        properties: []Property = &.{},
        additional_properties: ?*const Constraint = null,
        pattern_properties: []PatternProperty = &.{},
        all_of: ?*const Constraint.Node = null,
        any_of: ?*const Constraint.Node = null,
        one_of: ?*const Constraint.Node = null,
        not_constraint: ?*const Constraint = null,
        ref_constraint: ?*const Constraint = null,
        if_constraint: ?*const Constraint = null,
        then_constraint: ?*const Constraint = null,
        else_constraint: ?*const Constraint = null,
        required: []u64 = &.{},
        dependent_required: []DependentRequiredEntry = &.{},
        dependent_schemas: []Property = &.{},
        types: TypeMap = .{},
        min_len: u64 = 0,
        max_len: u64 = std.math.maxInt(u64),
        min_items: u64 = 0,
        max_items: u64 = std.math.maxInt(u64),
        min_properties: u64 = 0,
        max_properties: u64 = std.math.maxInt(u64),
        bounds: Bounds = .zero,
        multiple_of_i64: ?i64 = null,
        multiple_of_f64: ?f64 = null,
        pattern: ?pcre.Regex = null,
        @"const": u64 = 0,
        @"enum": []u64 = &.{},
        unevaluated_properties: ?*const Constraint = null,
        unevaluated_items: ?*const Constraint = null,
        contains: ?*const Constraint = null,
        contains_bounds: Bounds = .default(.{ 1, null }),

        pub const DependentRequiredEntry = struct {
            trigger_property_hash: u64,
            required_property_hashes: []u64,
        };

        pub const zero: Constraint = .{};

        pub const Node = struct {
            constraint: *const Constraint,
            next: ?*Node,

            pub const zero: Node = .{
                .constraint = &.zero,
                .next = null,
            };
        };

        pub const Property = struct {
            name: str8,
            hash: u64,
            constraint: *const Constraint,
        };

        pub const PatternProperty = struct {
            pattern: pcre.Regex,
            constraint: *const Constraint,
        };
    };

    pub fn is_valid(schema: *const Schema, input: str8) bool {
        var arena = Arena.init(.{}) catch unreachable;
        defer arena.release();

        const json_value = json.hashed.parse(&arena, input) catch return false;
        var ctx = check.CheckContext{
            .arena = &arena,
            .depth = 0,
        };
        return check.check(&ctx, schema.root.constraint, json_value) catch return false;
    }
};

pub fn parse(schema_contents: str8) !Schema {
    return parse_with_revision(schema_contents, null);
}

/// Alias for backward compatibility with camelCase naming
pub const parseWithRevision = parse_with_revision;

pub fn parse_with_revision(schema_contents: str8, revision: ?Revision) !Schema {
    var usage_arena = try Arena.init(.{});
    errdefer usage_arena.deinit();

    var parse_arena = try Arena.init(.{});
    defer parse_arena.deinit();

    const root_json = try json.hashed.parse(&parse_arena, schema_contents);

    var ctx: ParseContext = .{
        .revision = revision orelse Revision.detect(root_json),
        .id_registry = .empty,
        .usage_arena = &usage_arena,
        .parse_arena = &parse_arena,
        .root_json = root_json,
    };

    // Phase 3: Parse the root schema
    const root = try parse_node(&ctx, root_json);
    return Schema{
        .root = root,
        .arena = usage_arena,
    };
}

pub fn resolve_pointer(value: *const HashableJsonValue, unescaped_pointer: []const u8) ?*const HashableJsonValue {
    const scratch = Arena.get_scratch(&.{});
    defer scratch.release();

    if (unescaped_pointer.len == 0) return value;
    if (unescaped_pointer[0] != '#') return null;

    var current = value;
    var path = unescaped_pointer[1..]; // Skip '#'

    while (path.len > 0) {
        if (path[0] != '/') return null;
        path = path[1..]; // Skip '/'

        // Find next segment
        const end = std.mem.indexOfScalar(u8, path, '/') orelse path.len;
        const segment_escaped = path[0..end];
        path = path[end..];
        const segment = unescape_json_pointer(scratch.arena, segment_escaped) catch return null orelse return null;

        switch (current.kind) {
            .object => |obj| {
                current = obj.get_const(segment) orelse return null;
            },
            .array => |arr| {
                const index = std.fmt.parseInt(usize, segment, 10) catch return null;
                if (index >= arr.count()) return null;
                current = arr.at(index) orelse return null;
            },
            else => return null,
        }
    }
    return current;
}

fn resolve_ref(ctx: *ParseContext, ref_string: []const u8) !?*const Schema.Constraint {
    // Case 1: JSON pointer ref (starts with #)
    if (ref_string.len > 0 and ref_string[0] == '#') {
        if (resolve_pointer(ctx.root_json, ref_string)) |target_json| {
            // Parse the target JSON - cache handles dedup
            return try parse_constraint(ctx, target_json);
        }
        return null;
    }

    // Case 2: $id-based ref (URI)
    if (ctx.id_registry.get(ref_string)) |target_json| {
        return try parse_constraint(ctx, target_json.*);
    }

    // Case 3: URI with fragment (e.g., "https://example.com/schema#/defs/foo")
    if (std.mem.indexOfScalar(u8, ref_string, '#')) |hash_pos| {
        const base_uri = ref_string[0..hash_pos];
        const fragment = ref_string[hash_pos..];

        if (ctx.id_registry.get(base_uri)) |base_json| {
            if (resolve_pointer(base_json.*, fragment)) |target_json| {
                return try parse_constraint(ctx, target_json);
            }
        }
    }

    return null;
}

/// Unescape a JSON Pointer segment according to RFC 6901.
/// - ~0 -> ~
/// - ~1 -> /
/// Also handles percent-encoding (e.g., %25 -> %)
fn unescape_json_pointer(arena: *Arena, escaped: str8) OOM!str8 {
    var needs_unescape = false;
    for (escaped) |c| {
        if (c == '~' or c == '%') {
            needs_unescape = true;
            break;
        }
    }
    if (!needs_unescape) return escaped;

    // Count the result length
    var result_len: usize = 0;
    var i: usize = 0;
    while (i < escaped.len) {
        if (escaped[i] == '~' and i + 1 < escaped.len) {
            // ~0 or ~1
            result_len += 1;
            i += 2;
        } else if (escaped[i] == '%' and i + 2 < escaped.len) {
            // Percent encoding like %25
            result_len += 1;
            i += 3;
        } else {
            result_len += 1;
            i += 1;
        }
    }

    const result = try arena.alloc(u8, result_len);
    var out_idx: usize = 0;
    i = 0;
    while (i < escaped.len) {
        if (escaped[i] == '~' and i + 1 < escaped.len) {
            result[out_idx] = switch (escaped[i + 1]) {
                '0' => '~',
                '1' => '/',
                else => escaped[i + 1],
            };
            out_idx += 1;
            i += 2;
        } else if (escaped[i] == '%' and i + 2 < escaped.len) {
            // Parse hex digits
            const high = int_from_hex_digit(escaped[i + 1]);
            const low = int_from_hex_digit(escaped[i + 2]);
            if (high != null and low != null) {
                result[out_idx] = (@as(u8, high.?) << 4) | @as(u8, low.?);
                out_idx += 1;
                i += 3;
            } else {
                result[out_idx] = escaped[i];
                out_idx += 1;
                i += 1;
            }
        } else {
            result[out_idx] = escaped[i];
            out_idx += 1;
            i += 1;
        }
    }
    return result[0..out_idx];
}

fn int_from_hex_digit(c: u8) ?u4 {
    return switch (c) {
        '0'...'9' => @intCast(c - '0'),
        'a'...'f' => @intCast(c - 'a' + 10),
        'A'...'F' => @intCast(c - 'A' + 10),
        else => null,
    };
}

const ParseError = OOM || error{UnrecognizedSchemaType};

const ParseContext = struct {
    root_json: *const HashableJsonValue,
    revision: Revision,
    id_registry: XarMap(str8, *const HashableJsonValue, 4),

    usage_arena: *Arena,
    parse_arena: *Arena,
    /// Cache of value hash to Constraint
    /// Used to deduplciate parsing generally, but specifically useful for refs
    constraint_cache: XarMap(u64, *Schema.Constraint, 64) = .empty,
};

fn parse_into_constraint(ctx: *ParseContext, schema: *const HashableJsonValue, constraint: *Schema.Constraint) ParseError!void {
    constraint.* = .zero;

    if (schema.kind == .bool) {
        constraint.flags.false_schema = !schema.kind.bool;
        return;
    }
    if (schema.kind != .object) {
        return error.UnrecognizedSchemaType;
    }
    const obj = &schema.kind.object;

    if (obj.count() == 0) {
        constraint.* = .zero;
        return;
    }

    if (obj.get_const("$id")) |id_ptr| {
        if (id_ptr.*.kind == .string) {
            ctx.id_registry.put(ctx.parse_arena, id_ptr.*.kind.string.value, schema) catch {};
        }
    }

    if (obj.get_const("$ref")) |ref_ptr| parse_ref: {
        const ref = ref_ptr.*;
        if (ref.kind != .string) {
            break :parse_ref;
        }
        if (try resolve_ref(ctx, ref.kind.string.value)) |target| {
            constraint.ref_constraint = target;
        }
        // In draft4-7, $ref overrides all siblings
        if (ref_overrides_siblings(ctx.revision)) {
            return;
        }
    }

    parse_validation__type(obj, constraint) catch {};
    parse_validation__min_length(obj, constraint);
    parse_validation__max_length(obj, constraint);
    parse_validation__min(obj, constraint);
    parse_validation__max(obj, constraint);
    parse_validation__exclusive_min(obj, constraint);
    parse_validation__exclusive_max(obj, constraint);
    parse_validation__min_items(obj, constraint);
    parse_validation__max_items(obj, constraint);
    parse_validation__min_properties(obj, constraint);
    parse_validation__max_properties(obj, constraint);
    parse_validation__const(obj, constraint);
    parse_validation__enum(ctx, obj, constraint) catch {};
    parse_validation__unique_items(obj, constraint);
    parse_applicator__prefix_items(ctx, obj, constraint) catch {};
    parse_applicator__items(ctx, obj, constraint) catch {};
    parse_applicator__properties(ctx, obj, constraint) catch {};
    parse_applicator__pattern_properties(ctx, obj, constraint) catch {};
    parse_applicator__additional_properties(ctx, obj, constraint) catch {};
    parse_validation__required_properties(ctx, obj, constraint) catch {};
    parse_validation__dependent_required(ctx, obj, constraint) catch {};
    parse_applicator__dependent_schemas(ctx, obj, constraint) catch {};
    parse_validation__dependencies(ctx, obj, constraint) catch {};
    parse_applicator_not(ctx, obj, constraint) catch {};
    parse_applicator__all_of(ctx, obj, constraint) catch {};
    parse_applicator__any_of(ctx, obj, constraint) catch {};
    parse_applicator__one_of(ctx, obj, constraint) catch {};
    parse_applicator__if_then_else(ctx, obj, constraint) catch {};
    parse_validation__multiple_of(obj, constraint);
    parse_validation__pattern(ctx, obj, constraint) catch {};
    parse_unevaluated__unevaluated_properties(ctx, obj, constraint) catch {};
    parse_unevaluated__unevaluated_items(ctx, obj, constraint) catch {};
    parse_applicator__contains(ctx, obj, constraint) catch {};
}

fn parse_node(ctx: *ParseContext, schema: *const HashableJsonValue) ParseError!*Schema.Constraint.Node {
    const constraint = try parse_constraint(ctx, schema);
    var node = try ctx.usage_arena.create(Schema.Constraint.Node);
    node.constraint = constraint;
    return node;
}

fn parse_constraint(ctx: *ParseContext, schema: *const HashableJsonValue) ParseError!*const Schema.Constraint {
    const cached_constraint = try ctx.constraint_cache.get_or_put(ctx.usage_arena, schema.hash);
    if (cached_constraint.found_existing) {
        return cached_constraint.value_ptr.*;
    }
    const constraint = try ctx.usage_arena.create(Schema.Constraint);

    cached_constraint.value_ptr.* = constraint;
    constraint.* = .zero;

    try parse_into_constraint(ctx, schema, constraint);
    return constraint;
}

fn parse_array_of_constraints(ctx: *ParseContext, arr: *const @FieldType(HashableJsonValue.Kind, "array")) !?*const Schema.Constraint.Node {
    var head: ?*Schema.Constraint.Node = null;
    var cur: *?*Schema.Constraint.Node = &head;
    var arr_iter = arr.iter();
    while (arr_iter.next()) |item| {
        const item_schema = try parse_constraint(ctx, item);

        const node = try ctx.usage_arena.create(Schema.Constraint.Node);
        node.* = .{ .constraint = item_schema, .next = null };
        cur.* = node;
        cur = &node.next;
    }
    return head;
}

/// The "type" field on an object
/// https://www.learnjsonschema.com/2020-12/validation/type/
pub const TypeMap = packed struct(u8) {
    /// The JSON null constant
    null: bool = false,
    /// The JSON true or false constants
    boolean: bool = false,
    /// A JSON object
    object: bool = false,
    /// A JSON array
    array: bool = false,
    /// A JSON number
    /// IEEE 764 64-bit double-precision floating point encoding (except NaN, Infinity, and +0)
    number: bool = false,
    /// A JSON number that represents an integer
    /// 64-bit signed integer encoding (from -(2^53)+1 to (2^53)-1)
    integer: bool = false,
    /// A JSON string
    /// UTF-8 Unicode encoding
    string: bool = false,
    _pad: bool = false,

    pub const zero: TypeMap = .{};

    test TypeMap {
        const value: u8 = @bitCast(TypeMap.zero);
        try std.testing.expectEqual(value, 0);
    }

    fn add(types: *TypeMap, str: str8) void {
        if (str.len == 0) return;
        switch (str[0]) {
            'n' => if (str.len > 2) {
                switch (str[2]) {
                    'l' => types.null = std.mem.eql(u8, str, "null"),
                    'm' => types.number = std.mem.eql(u8, str, "number"),
                    else => {},
                }
            },
            'b' => types.boolean = std.mem.eql(u8, str, "boolean"),
            'o' => types.object = std.mem.eql(u8, str, "object"),
            'a' => if (str.len > 1) {
                switch (str[1]) {
                    'r' => types.array = std.mem.eql(u8, str, "array"),
                    'n' => if (std.mem.eql(u8, str, "any")) {
                        types.* = @bitCast(@as(u8, 0xFF));
                    },
                    else => {},
                }
            },
            'i' => types.integer = std.mem.eql(u8, str, "integer"),
            's' => types.string = std.mem.eql(u8, str, "string"),
            else => {},
        }
    }

    pub fn is_empty(types: TypeMap) bool {
        return types == TypeMap.zero;
    }
};

fn parse_validation__type(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const ty = (obj.get_const("type") orelse return).*;
    var found_type = false;
    switch (ty.kind) {
        .string => |v_type_str| {
            found_type = true;
            constraint.types.add(v_type_str.value);
        },
        .array => |*arr| {
            var iter = arr.iter();
            while (iter.next()) |v_type_item| {
                found_type = true;
                if (v_type_item.kind != .string) {
                    // todo: error
                    continue;
                }
                constraint.types.add(v_type_item.kind.string.value);
            }
        },
        else => {},
    }
    // no types allowed => no schema accepted
    // TODO: flag for this scenario for better errors
    if (constraint.types.is_empty()) {
        constraint.flags.false_schema = true;
        return;
    }
}

/// https://www.learnjsonschema.com/2020-12/validation/minlength/
fn parse_validation__min_length(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const min_len = (obj.get_const("minLength") orelse return).*;
    switch (min_len.kind) {
        .integer => |int_val| {
            constraint.min_len = std.math.lossyCast(u64, int_val);
        },
        else => {},
    }
}

/// https://www.learnjsonschema.com/2020-12/validation/maxlength/
fn parse_validation__max_length(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const max_len = (obj.get_const("maxLength") orelse return).*;
    switch (max_len.kind) {
        .integer => |int_val| {
            constraint.max_len = std.math.lossyCast(u64, int_val);
        },
        else => {},
    }
}

/// https://www.learnjsonschema.com/2020-12/validation/minimum/
fn parse_validation__min(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const min_val_ptr = obj.get_const("minimum") orelse return;
    const number = JsonNumber.from_json_value(min_val_ptr) orelse return;
    constraint.bounds.upsert_lower(number, false);
}

/// https://www.learnjsonschema.com/2020-12/validation/maximum/
fn parse_validation__max(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const max_val_ptr = obj.get_const("maximum") orelse return;
    const number = JsonNumber.from_json_value(max_val_ptr) orelse return;
    constraint.bounds.upsert_upper(number, false);
}

/// https://www.learnjsonschema.com/2020-12/validation/exclusiveminimum/
fn parse_validation__exclusive_min(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const min_val_ptr = obj.get_const("exclusiveMinimum") orelse return;
    const number = JsonNumber.from_json_value(min_val_ptr) orelse return;
    constraint.bounds.upsert_lower(number, true);
}

/// https://www.learnjsonschema.com/2020-12/validation/exclusivemaximum/
fn parse_validation__exclusive_max(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const max_val_ptr = obj.get_const("exclusiveMaximum") orelse return;
    const number = JsonNumber.from_json_value(max_val_ptr) orelse return;
    constraint.bounds.upsert_upper(number, true);
}

fn parse_validation__min_items(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const min_items = (obj.get_const("minItems") orelse return).*;
    switch (min_items.kind) {
        .integer => |int_val| {
            constraint.min_items = std.math.lossyCast(u64, int_val);
        },
        .float => |flt_val| {
            constraint.min_items = std.math.lossyCast(u64, flt_val);
        },
        else => {},
    }
}

fn parse_validation__max_items(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const max_items = (obj.get_const("maxItems") orelse return).*;
    switch (max_items.kind) {
        .integer => |int_val| {
            constraint.max_items = std.math.lossyCast(u64, int_val);
        },
        .float => |flt_val| {
            constraint.max_items = std.math.lossyCast(u64, flt_val);
        },
        else => {},
    }
}

fn parse_validation__min_properties(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const min_properties = (obj.get_const("minProperties") orelse return).*;
    switch (min_properties.kind) {
        .integer => |int_val| {
            constraint.min_properties = std.math.lossyCast(u64, int_val);
        },
        .float => |flt_val| {
            constraint.min_properties = std.math.lossyCast(u64, flt_val);
        },
        else => {},
    }
}

fn parse_validation__max_properties(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const max_properties = (obj.get_const("maxProperties") orelse return).*;
    switch (max_properties.kind) {
        .integer => |int_val| {
            constraint.max_properties = std.math.lossyCast(u64, int_val);
        },
        .float => |flt_val| {
            constraint.max_properties = std.math.lossyCast(u64, flt_val);
        },
        else => {},
    }
}

fn parse_validation__const(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const value = (obj.get_const("const") orelse return).*;
    constraint.flags.@"const" = true;
    constraint.@"const" = value.hash;
}

fn parse_validation__enum(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const value = (obj.get_const("enum") orelse return).*;
    if (value.kind != .array) {
        return;
    }
    // no values allowed => no schema accepted
    // TODO: flag for this scenario for better errors
    if (value.kind.array.count() == 0) {
        constraint.flags.false_schema = true;
        return;
    }
    var hashes: base.ArenaList(u64) = try .init_capacity(ctx.usage_arena, value.kind.array.count());
    var iter = value.kind.array.iter();
    while (iter.next()) |item| {
        hashes.append_assume_capacity(item.hash);
    }
    constraint.@"enum" = hashes.items;
}

fn parse_validation__unique_items(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const unique_items = (obj.get_const("uniqueItems") orelse return).*;
    constraint.flags.unique_items = unique_items.kind == .bool and unique_items.kind.bool;
}

fn parse_applicator__prefix_items(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const prefix_items = blk: {
        if (obj.get_const("items")) |items_sub_schema| {
            if (items_sub_schema.*.kind == .array) break :blk &items_sub_schema.*.kind.array;
        }
        if (obj.get_const("prefixItems")) |prefix_items_ptr| {
            if (prefix_items_ptr.*.kind == .array) break :blk &prefix_items_ptr.*.kind.array;
        }
        return;
    };

    constraint.prefix_items = try parse_array_of_constraints(ctx, prefix_items);
}

fn parse_applicator__items(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const has_legacy_tuple_items = if (obj.get_const("items")) |items_ptr|
        items_ptr.*.kind == .array
    else
        false;

    const items = blk: {
        if (obj.get_const("items")) |items_ptr| {
            if (items_ptr.*.kind != .array) break :blk items_ptr;
        }
        if (has_legacy_tuple_items and ctx.revision != .draft2020_12 and ctx.revision != .draft_next) {
            if (obj.get_const("additionalItems")) |additional_items_ptr| {
                if (additional_items_ptr.*.kind != .array) {
                    constraint.flags.additional_items = true;
                    break :blk additional_items_ptr;
                }
            }
        }
        return;
    };
    constraint.items = try parse_constraint(ctx, items);
}

fn parse_applicator__properties(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const properties_ptr = obj.get_const("properties") orelse return;
    if (properties_ptr.*.kind != .object) return;

    constraint.properties = try make_properties_list(ctx, &properties_ptr.*.kind.object);
}

fn parse_applicator__pattern_properties(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const pattern_properties_ptr = obj.get_const("patternProperties") orelse return;
    if (pattern_properties_ptr.*.kind != .object) return;

    const pattern_properties_obj = &pattern_properties_ptr.*.kind.object;
    var pattern_properties = try base.ArenaList(Schema.Constraint.PatternProperty).init_capacity(ctx.usage_arena, pattern_properties_obj.count());
    var pattern_iter = pattern_properties_obj.properties.iter();
    while (pattern_iter.next()) |key_node| {
        const key_string = key_node.kind.string;
        const pattern_c = try ctx.usage_arena.allocator().dupeZ(u8, key_string.value);
        const re = pcre.Regex.compile(pattern_c, .{
            .Dotall = true,
            .JavascriptCompat = true,
            .Utf8 = true,
        }) catch continue;
        pattern_properties.append_assume_capacity(.{
            .pattern = re,
            .constraint = try parse_constraint(ctx, key_string.child.?),
        });
    }
    constraint.pattern_properties = pattern_properties.items;
}

fn parse_applicator__additional_properties(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const additional_properties_ptr = obj.get_const("additionalProperties") orelse return;
    constraint.additional_properties = try parse_constraint(ctx, additional_properties_ptr);
}

// TODO: draft checking is brittle
fn parse_validation__required_properties(
    ctx: *ParseContext,
    obj: *const HashableJsonValue.Kind.Object,
    constraint: *Schema.Constraint,
) !void {
    if (ctx.revision == .draft3) {
        // Draft3 style: "required": true inside each property definition
        const properties_value = (obj.get_const("properties") orelse return).*;
        const properties_object = properties_value.as_object() orelse return;

        var required_properties: base.ArenaList(u64) = .empty;
        var property_iter = properties_object.properties.iter();
        while (property_iter.next()) |key_node| {
            const property_schema = key_node.kind.string.child.?;
            if (property_schema.kind != .object) continue;
            const required_field = (property_schema.kind.object.get_const("required") orelse continue).*;
            if (required_field.kind != .bool) continue;
            if (required_field.kind.bool) {
                try required_properties.append(ctx.usage_arena, key_node.hash);
            }
        }

        constraint.required = required_properties.items;
        return;
    }

    // Draft4+ style: "required" is an array of property names at the object level
    const required_properties_value = (obj.get_const("required") orelse return).*;
    if (required_properties_value.kind != .array) return;

    var required_properties = try base.ArenaList(u64).init_capacity(ctx.usage_arena, required_properties_value.kind.array.count());
    var iter = required_properties_value.kind.array.iter();
    while (iter.next()) |required_property| {
        if (required_property.kind != .string) continue;
        required_properties.append_assume_capacity(required_property.hash);
    }
    constraint.required = required_properties.items;
}

fn parse_validation__dependent_required(
    ctx: *ParseContext,
    obj: *const HashableJsonValue.Kind.Object,
    constraint: *Schema.Constraint,
) !void {
    const dependent_required_value = (obj.get_const("dependentRequired") orelse return);
    const dependent_required_obj = dependent_required_value.as_object() orelse return;
    constraint.dependent_required = try make_dependent_required_list(ctx, dependent_required_obj);
}

fn parse_applicator__dependent_schemas(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const dependent_schemas_value = obj.get_const("dependentSchemas") orelse return;
    const dependent_schemas_obj = dependent_schemas_value.as_object() orelse return;
    constraint.dependent_schemas = try make_properties_list(ctx, dependent_schemas_obj);
}

fn parse_validation__dependencies(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const dependencies = obj.get_const("dependencies") orelse return;
    const dependencies_obj = dependencies.as_object() orelse return;
    constraint.dependent_required = try make_dependent_required_list(ctx, dependencies_obj);
    constraint.dependent_schemas = try make_properties_list(ctx, dependencies_obj);
}

fn make_dependent_required_list(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) ![]Schema.Constraint.DependentRequiredEntry {
    var entries: base.ArenaList(Schema.Constraint.DependentRequiredEntry) = try .init_capacity(
        ctx.usage_arena,
        obj.count(),
    );
    var iter = obj.properties.iter();
    while (iter.next()) |key_node| {
        const key_string = key_node.kind.string;
        const dependent_value = key_string.child.?;
        if (dependent_value.kind != .array) continue;

        var required_hashes: base.ArenaList(u64) = try .init_capacity(ctx.usage_arena, dependent_value.kind.array.count());
        var req_iter = dependent_value.kind.array.iter();
        while (req_iter.next()) |required_property| {
            if (required_property.kind != .string) continue;
            required_hashes.append_assume_capacity(required_property.hash);
        }

        if (required_hashes.items.len == 0) continue;

        entries.append_assume_capacity(.{
            .trigger_property_hash = key_node.hash,
            .required_property_hashes = required_hashes.items,
        });
    }

    return entries.items;
}

// todo: combine with "properties" parsing
fn make_properties_list(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) ![]Schema.Constraint.Property {
    var properties: base.ArenaList(Schema.Constraint.Property) = try .init_capacity(ctx.usage_arena, obj.count());
    var property_iter = obj.properties.iter();
    while (property_iter.next()) |key_node| {
        const key_string = key_node.kind.string;
        properties.append_assume_capacity(.{
            .name = try ctx.usage_arena.dupe(u8, key_string.value),
            .hash = key_node.hash,
            .constraint = try parse_constraint(ctx, key_string.child.?),
        });
    }
    return properties.items;
}

fn parse_applicator_not(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const sub_schema = obj.get_const("not") orelse return;
    constraint.not_constraint = try parse_constraint(ctx, sub_schema);
}

fn parse_applicator__all_of(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const items = (obj.get_const("allOf") orelse return).*;
    if (items.kind != .array) return;
    constraint.all_of = try parse_array_of_constraints(ctx, &items.kind.array);
}

fn parse_applicator__any_of(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const items = (obj.get_const("anyOf") orelse return).*;
    if (items.kind != .array) return;
    constraint.any_of = try parse_array_of_constraints(ctx, &items.kind.array);
}

fn parse_applicator__one_of(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const items = (obj.get_const("oneOf") orelse return).*;
    if (items.kind != .array) return;
    constraint.one_of = try parse_array_of_constraints(ctx, &items.kind.array);
}

fn parse_validation__multiple_of(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const multiple_of = (obj.get_const("multipleOf") orelse obj.get_const("divisibleBy") orelse return).*;
    switch (multiple_of.kind) {
        .float => |float_val| {
            constraint.multiple_of_f64 = float_val;
        },
        .integer => |int_val| {
            constraint.multiple_of_i64 = int_val;
        },
        else => {},
    }
}

fn parse_validation__pattern(
    ctx: *ParseContext,
    obj: *const HashableJsonValue.Kind.Object,
    constraint: *Schema.Constraint,
) !void {
    const pattern = (obj.get_const("pattern") orelse return).*;
    if (pattern.kind != .string) return;

    const pattern_c = try ctx.usage_arena.allocator().dupeZ(u8, pattern.kind.string.value);
    constraint.pattern = try pcre.Regex.compile(pattern_c, .{
        .Dotall = true,
        .JavascriptCompat = true,
        .Utf8 = true,
    });
}

fn parse_applicator__if_then_else(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const cond_value = obj.get_const("if") orelse return;
    constraint.if_constraint = try parse_constraint(ctx, cond_value);
    if (obj.get_const("then")) |then| {
        constraint.then_constraint = try parse_constraint(ctx, then);
    }
    if (obj.get_const("else")) |elsa| {
        constraint.else_constraint = try parse_constraint(ctx, elsa);
    }
}

fn parse_unevaluated__unevaluated_properties(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const unevaluated_properties = obj.get_const("unevaluatedProperties") orelse return;
    constraint.unevaluated_properties = try parse_constraint(ctx, unevaluated_properties);
}

fn parse_unevaluated__unevaluated_items(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const unevaluated_items = obj.get_const("unevaluatedItems") orelse return;
    constraint.unevaluated_items = try parse_constraint(ctx, unevaluated_items);
}

fn parse_applicator__contains(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const contains = obj.get_const("contains") orelse return;
    constraint.contains = try parse_constraint(ctx, contains);
    constraint.contains_bounds.upsert_from_keys("minContains", "maxContains", obj);
}

fn ref_overrides_siblings(revision: Revision) bool {
    return revision != .draft2019_09 and revision != .draft2020_12 and revision != .draft_next;
}

// TODO: move to json.zig, and have this be return type of Value.as_number
pub const JsonNumber = union(enum) {
    int: i64,
    float: f64,

    pub fn cmp(lhs: JsonNumber, rhs: JsonNumber) std.math.Order {
        return switch (lhs) {
            .int => |lhs_int| switch (rhs) {
                .int => |rhs_int| std.math.order(lhs_int, rhs_int),
                .float => |rhs_float| std.math.order(@as(f64, @floatFromInt(lhs_int)), rhs_float),
            },
            .float => |lhs_float| switch (rhs) {
                .int => |rhs_int| std.math.order(lhs_float, @as(f64, @floatFromInt(rhs_int))),
                .float => |rhs_float| std.math.order(lhs_float, rhs_float),
            },
        };
    }

    pub fn from_json_value(value: *const HashableJsonValue) ?JsonNumber {
        return switch (value.kind) {
            .integer => |int_val| .{ .int = int_val },
            .float => |float_val| .{ .float = float_val },
            else => null,
        };
    }
};

pub const Bounds = struct {
    // TODO: remove present, just use int vals
    present: [2]bool = .{ false, false },
    exclusive: [2]bool = .{ false, false },
    values: [2]JsonNumber = .{
        .{ .int = 0 },
        .{ .int = 0 },
    },

    pub const zero: Bounds = .{};

    const lower_idx = 0;
    const upper_idx = 1;

    pub fn default(range: [2]?i64) Bounds {
        var bounds = Bounds.zero;
        if (range[lower_idx]) |v| {
            bounds.upsert_lower(JsonNumber{ .int = v }, false);
        }
        if (range[upper_idx]) |v| {
            bounds.upsert_upper(JsonNumber{ .int = v }, false);
        }
        return bounds;
    }

    pub fn contains(bounds: Bounds, value: JsonNumber) bool {
        if (bounds.present[lower_idx]) {
            const lower_order = JsonNumber.cmp(value, bounds.values[lower_idx]);
            if (lower_order == .lt) return false;
            if (lower_order == .eq and bounds.exclusive[lower_idx]) return false;
        }
        if (bounds.present[upper_idx]) {
            const upper_order = JsonNumber.cmp(value, bounds.values[upper_idx]);
            if (upper_order == .gt) return false;
            if (upper_order == .eq and bounds.exclusive[upper_idx]) return false;
        }
        return true;
    }

    pub fn upsert_lower(bounds: *Bounds, value: JsonNumber, exclusive: bool) void {
        bounds.upsert(lower_idx, value, exclusive);
    }

    pub fn upsert_upper(bounds: *Bounds, value: JsonNumber, exclusive: bool) void {
        bounds.upsert(upper_idx, value, exclusive);
    }

    fn upsert(bounds: *Bounds, comptime idx: usize, value: JsonNumber, exclusive: bool) void {
        if (!bounds.present[idx]) {
            bounds.present[idx] = true;
            bounds.exclusive[idx] = exclusive;
            bounds.values[idx] = value;
            return;
        }

        const order = JsonNumber.cmp(value, bounds.values[idx]);
        const should_replace = if (idx == lower_idx)
            order == .gt or (order == .eq and exclusive and !bounds.exclusive[idx])
        else
            order == .lt or (order == .eq and exclusive and !bounds.exclusive[idx]);

        if (should_replace) {
            bounds.exclusive[idx] = exclusive;
            bounds.values[idx] = value;
        }
    }

    fn upsert_from_keys(bounds: *Bounds, lower: str8, upper: str8, obj: *const HashableJsonValue.Kind.Object) void {
        if (obj.get_const(lower)) |val| {
            if (val.as_integer_lossy()) |v| {
                bounds.present[lower_idx] = true;
                bounds.values[lower_idx] = JsonNumber{ .int = v };
            }
        }
        if (obj.get_const(upper)) |val| {
            if (val.as_integer_lossy()) |v| {
                bounds.present[upper_idx] = true;
                bounds.values[upper_idx] = JsonNumber{ .int = v };
            }
        }
    }
};

test {
    std.testing.refAllDecls(@This());
    std.testing.refAllDecls(@import("tests.zig"));
}
