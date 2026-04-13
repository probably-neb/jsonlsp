//! JSON Schema Subsystem
//!
//! Implements the validation layer of JSONLS
//! Implements multiple core concepts:
//! - Parsing and validation of JSON Schemas
//! - Validation of JSON according to it's respective schema
//! - Asynchronous fetching of schemas defined by URI from the interwebs
//!
//! TODO: use segmented list for storing Constraints
//! TODO: handle refs
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

        const uri = schema_uri.kind.string;
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
        kind: Kind,
        flags: packed struct {
            additional_items: bool = false,
            unique_items: bool = false,
            @"const": bool = false,
        } = .{},
        prefix_items: ?*const Constraint.Node = null,
        items: ?*const Constraint = null,
        properties: []Property = &.{},
        additional_properties: ?*const Constraint = null,
        pattern_properties: []PatternProperty = &.{},
        if_constraint: ?*const Constraint = null,
        then_constraint: ?*const Constraint = null,
        else_constraint: ?*const Constraint = null,
        required: []u64 = &.{},
        dependent_required: []DependentRequiredEntry = &.{},
        @"const": u64 = 0,

        pub const Kind = union(enum) {
            true: void,
            false: void,
            type: []ValidationType,
            all: ?*const Node, // corresponds to allOf,
            any: ?*const Node, // corresponds to anyOf,
            one: ?*const Node, // corresponds to oneOf,
            not: *const Constraint,
            @"enum": []u64,
            min_len: u64,
            max_len: u64,
            min_i64: i64,
            max_i64: i64,
            min_f64: f64,
            max_f64: f64,
            min_i64_exclusive: i64,
            max_i64_exclusive: i64,
            min_f64_exclusive: f64,
            max_f64_exclusive: f64,
            max_items: u64,
            min_items: u64,
            max_properties: u64,
            min_properties: u64,
            multiple_of_i64: i64,
            multiple_of_f64: f64,
            pattern: pcre.Regex,
            ref: *const Constraint,
        };

        pub const DependentRequiredEntry = struct {
            trigger_property_hash: u64,
            required_property_hashes: []u64,
        };

        pub const zero: Constraint = .{
            .kind = .true,
        };

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
        return check(&arena, schema.root.constraint, json_value) catch return false;
    }
};

fn check(arena: *Arena, constraint: *const Schema.Constraint, value: *const HashableJsonValue) !bool {
    if (constraint.flags.@"const" and value.hash != constraint.@"const") {
        return false;
    }
    if (value.kind == .array) {
        if (constraint.flags.unique_items) {
            const scratch = Arena.get_scratch(&.{arena});
            defer scratch.release();

            var hashes: XarMap(u64, void, 2) = .empty;
            try hashes.expand(scratch.arena, value.kind.array.count());

            var arr_iter = value.kind.array.iter();
            while (arr_iter.next()) |item| {
                const entry = try hashes.get_or_put(scratch.arena, item.hash);
                if (entry.found_existing) {
                    return false;
                }
            }
        }
        var arr_iter = value.kind.array.iter();
        if (constraint.prefix_items) |prefix_items| {
            var prefix_item_node: ?*const Schema.Constraint.Node = prefix_items;
            while (prefix_item_node) |prefix_item| : (prefix_item_node = prefix_item.next) {
                if (!try check(arena, prefix_item.constraint, arr_iter.next() orelse break)) return false;
            }
        }
        if (!constraint.flags.additional_items or constraint.prefix_items != null) {
            if (constraint.items) |items| {
                while (arr_iter.next()) |item| {
                    if (!try check(arena, items, item)) return false;
                }
            }
        }
    }
    if (value.kind == .object) {
        const scratch = Arena.get_scratch(&.{arena});
        defer scratch.release();

        var checked_properties: std.StringArrayHashMapUnmanaged(void) = .empty;
        defer checked_properties.deinit(scratch.arena.allocator());

        for (constraint.properties) |property| {
            const sub_value = (value.kind.object.get_const(property.name) orelse continue).*;
            try checked_properties.put(scratch.arena.allocator(), property.name, {});
            if (!try check(arena, property.constraint, sub_value)) {
                return false;
            }
        }

        var obj_iter = value.kind.object.const_iterator();
        while (obj_iter.next()) |entry| {
            var matched_pattern = false;
            for (constraint.pattern_properties) |pattern_property| {
                const matches = try pattern_property.pattern.matches(entry.key_ptr.*, .{});
                if (matches != null) {
                    matched_pattern = true;
                    if (!try check(arena, pattern_property.constraint, entry.value_ptr.*)) {
                        return false;
                    }
                }
            }

            if (!checked_properties.contains(entry.key_ptr.*) and !matched_pattern and constraint.additional_properties != null) {
                if (!try check(arena, constraint.additional_properties.?, entry.value_ptr.*)) {
                    return false;
                }
            }
        }

        for (constraint.required) |required_property_hash| {
            var key_iter = value.kind.object.key_iterator();
            while (key_iter.next()) |key_ptr| {
                const key_hash = json.hashed.compute_string_hash(key_ptr.*);
                if (key_hash == required_property_hash) break;
            } else return false;
        }

        for (constraint.dependent_required) |entry| {
            var trigger_present = false;
            var trigger_iter = value.kind.object.key_iterator();
            while (trigger_iter.next()) |key_ptr| {
                const key_hash = json.hashed.compute_string_hash(key_ptr.*);
                if (key_hash == entry.trigger_property_hash) {
                    trigger_present = true;
                    break;
                }
            }

            if (!trigger_present) continue;

            for (entry.required_property_hashes) |required_property_hash| {
                var dependent_present = false;
                var dependent_iter = value.kind.object.key_iterator();
                while (dependent_iter.next()) |key_ptr| {
                    const key_hash = json.hashed.compute_string_hash(key_ptr.*);
                    if (key_hash == required_property_hash) {
                        dependent_present = true;
                        break;
                    }
                }
                if (!dependent_present) return false;
            }
        }
    }

    const kind_result = switch (constraint.kind) {
        .true => true,
        .false => false,
        .type => |v_types| blk: {
            var result = false;
            for (v_types) |v_type| {
                result = result or switch (v_type) {
                    .string => value.kind == .string,
                    .object => value.kind == .object,
                    .array => value.kind == .array,
                    .number => value.kind == .float or value.kind == .integer,
                    .boolean => value.kind == .bool,
                    .null => value.kind == .null,
                    .integer => value.kind == .integer,
                };
            }
            break :blk result;
        },
        .all => |first_child| blk: {
            var result = true;
            var cur_node = first_child;
            while (cur_node) |node| : (cur_node = node.next) {
                result = result and try check(arena, node.constraint, value);
            }
            break :blk result;
        },
        .any => |first_child| blk: {
            var result = false;
            var cur_node = first_child;
            while (cur_node) |node| : (cur_node = node.next) {
                result = result or try check(arena, node.constraint, value);
            }
            break :blk result;
        },
        .one => |first_child| blk: {
            var count: u32 = 0;
            var cur_node = first_child;
            while (cur_node) |node| : (cur_node = node.next) {
                count += @intFromBool(try check(arena, node.constraint, value));
            }
            break :blk count == 1;
        },
        .@"enum" => |hashes| blk: {
            for (hashes) |hash| {
                if (hash == value.hash) break :blk true;
            }
            break :blk false;
        },
        .min_len => |min_len| value.kind != .string or (std.unicode.utf8CountCodepoints(value.kind.string) catch 0) >= min_len,
        .max_len => |max_len| value.kind != .string or (std.unicode.utf8CountCodepoints(value.kind.string) catch 0) <= max_len,
        .max_items => |max_items| value.kind != .array or value.kind.array.count() <= max_items,
        .min_items => |min_items| value.kind != .array or value.kind.array.count() >= min_items,
        .max_properties => |max_properties| value.kind != .object or value.kind.object.count() <= max_properties,
        .min_properties => |min_properties| value.kind != .object or value.kind.object.count() >= min_properties,
        .max_i64 => |max_int| switch (value.kind) {
            .integer => |int_val| int_val <= max_int,
            .float => |float_val| float_val <= @as(f64, @floatFromInt(max_int)),
            else => true,
        },
        .min_i64 => |min_int| switch (value.kind) {
            .integer => |int_val| int_val >= min_int,
            .float => |float_val| float_val >= @as(f64, @floatFromInt(min_int)),
            else => true,
        },
        .max_f64 => |max_f64| switch (value.kind) {
            .integer => |int_val| @as(f64, @floatFromInt(int_val)) <= max_f64,
            .float => |float_val| float_val <= max_f64,
            else => true,
        },
        .min_f64 => |min_f64| switch (value.kind) {
            .integer => |int_val| @as(f64, @floatFromInt(int_val)) >= min_f64,
            .float => |float_val| float_val >= min_f64,
            else => true,
        },
        .max_i64_exclusive => |max_int| switch (value.kind) {
            .integer => |int_val| int_val < max_int,
            .float => |float_val| float_val < @as(f64, @floatFromInt(max_int)),
            else => true,
        },
        .min_i64_exclusive => |min_int| switch (value.kind) {
            .integer => |int_val| int_val > min_int,
            .float => |float_val| float_val > @as(f64, @floatFromInt(min_int)),
            else => true,
        },
        .max_f64_exclusive => |max_f64| switch (value.kind) {
            .integer => |int_val| @as(f64, @floatFromInt(int_val)) < max_f64,
            .float => |float_val| float_val < max_f64,
            else => true,
        },
        .min_f64_exclusive => |min_f64| switch (value.kind) {
            .integer => |int_val| @as(f64, @floatFromInt(int_val)) > min_f64,
            .float => |float_val| float_val > min_f64,
            else => true,
        },
        .not => |constraint_to_invert| !try check(arena, constraint_to_invert, value),
        .multiple_of_f64 => |multiple_of| blk: {
            if (multiple_of == 0.0) break :blk false;
            const float_val = switch (value.kind) {
                .integer => |int_val| @as(f64, @floatFromInt(int_val)),
                .float => |fv| fv,
                else => 0.0,
            };
            const quotient = float_val / multiple_of;
            const diff = @abs(quotient - @round(quotient));
            break :blk diff < 1e-9;
        },
        .multiple_of_i64 => |multiple_of| blk: {
            if (multiple_of == 0) break :blk false;
            const int_val = switch (value.kind) {
                .integer => |iv| iv,
                .float => |fv| float_as_int(fv) orelse break :blk false,
                else => 0,
            };
            break :blk @rem(int_val, multiple_of) == 0;
        },
        .pattern => |regex| blk: {
            if (value.kind != .string) break :blk true;
            const matches = try regex.matches(value.kind.string, .{});
            break :blk matches != null;
        },
        .ref => |referenced_constraint| try check(arena, referenced_constraint, value),
    };
    if (!kind_result) {
        return false;
    }
    if (constraint.if_constraint) |if_constraint| {
        if (try check(arena, if_constraint, value)) {
            if (constraint.then_constraint) |then_constraint| {
                if (!try check(arena, then_constraint, value)) {
                    return false;
                }
            }
        } else if (constraint.else_constraint) |else_constraint| {
            if (!try check(arena, else_constraint, value)) {
                return false;
            }
        }
    }
    return true;
}

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
                current = (obj.get(segment) orelse return null).*;
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

fn persist_string(ctx: *ParseContext, s: str8) OOM!str8 {
    const copy = try ctx.usage_arena.alloc(u8, s.len);
    @memcpy(copy, s);
    return copy;
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
        constraint.* = switch (schema.kind.bool) {
            true => .{ .kind = .true },
            false => .{ .kind = .false },
        };
        return;
    }
    if (schema.kind != .object) {
        return error.UnrecognizedSchemaType;
    }
    const obj = &schema.kind.object;

    if (obj.count() == 0) {
        constraint.* = .{ .kind = .true };
        return;
    }

    if (obj.get_const("$id")) |id_ptr| {
        if (id_ptr.*.kind == .string) {
            ctx.id_registry.put(ctx.parse_arena, id_ptr.*.kind.string, schema) catch {};
        }
    }

    if (obj.get_const("$ref")) |ref_ptr| parse_ref: {
        const ref = ref_ptr.*;
        if (ref.kind != .string) {
            break :parse_ref;
        }
        if (try resolve_ref(ctx, ref.kind.string)) |target| {
            try chain_with(ctx, constraint, .{ .ref = target });
        }
        // In draft4-7, $ref overrides all siblings
        if (ref_overrides_siblings(ctx.revision)) {
            return;
        }
    }
    // todo: error
    if (parse_validation__type(ctx, obj) catch null) |types| {
        try chain_with(ctx, constraint, types);
    }
    if (parse_validation__min_length(obj)) |min_length| {
        try chain_with(ctx, constraint, min_length);
    }
    if (parse_validation__max_length(obj)) |max_length| {
        try chain_with(ctx, constraint, max_length);
    }
    if (parse_validation__min(obj)) |min| {
        try chain_with(ctx, constraint, min);
    }
    if (parse_validation__max(obj)) |max| {
        try chain_with(ctx, constraint, max);
    }
    if (parse_validation__exclusive_min(obj)) |exclusive_min| {
        try chain_with(ctx, constraint, exclusive_min);
    }
    if (parse_validation__exclusive_max(obj)) |exclusive_max| {
        try chain_with(ctx, constraint, exclusive_max);
    }
    if (parse_validation__min_items(obj)) |min_items| {
        try chain_with(ctx, constraint, min_items);
    }
    if (parse_validation__max_items(obj)) |max_items| {
        try chain_with(ctx, constraint, max_items);
    }
    if (parse_validation__min_properties(obj)) |min_properties| {
        try chain_with(ctx, constraint, min_properties);
    }
    if (parse_validation__max_properties(obj)) |max_properties| {
        try chain_with(ctx, constraint, max_properties);
    }
    parse_validation__const(obj, constraint);
    if (parse_validation__enum(ctx, obj) catch null) |@"enum"| {
        try chain_with(ctx, constraint, @"enum");
    }
    parse_validation__unique_items(obj, constraint);
    parse_applicator__prefix_items(ctx, obj, constraint) catch {};
    parse_applicator__items(ctx, obj, constraint) catch {};
    parse_applicator__properties(ctx, obj, constraint) catch {};
    parse_applicator__pattern_properties(ctx, obj, constraint) catch {};
    parse_applicator__additional_properties(ctx, obj, constraint) catch {};
    try parse_validation__required_properties(ctx, obj, constraint);
    try parse_validation__dependent_required(ctx, obj, constraint);
    if (parse_applicator_not(ctx, obj) catch null) |not| {
        try chain_with(ctx, constraint, not);
    }
    if (parse_applicator__all_of(ctx, obj) catch null) |all_of| {
        try chain_with(ctx, constraint, all_of);
    }
    if (parse_applicator__any_of(ctx, obj) catch null) |any_of| {
        try chain_with(ctx, constraint, any_of);
    }
    if (parse_applicator__one_of(ctx, obj) catch null) |one_of| {
        try chain_with(ctx, constraint, one_of);
    }
    try parse_applicator__if_then_else(ctx, obj, constraint);
    if (parse_validation__multiple_of(obj)) |multiple_of| {
        try chain_with(ctx, constraint, multiple_of);
    }
    if (parse_validation__pattern(ctx, obj) catch null) |pattern| {
        try chain_with(ctx, constraint, pattern);
    }
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

fn chain_with(ctx: *ParseContext, from: *Schema.Constraint, new_kind: Schema.Constraint.Kind) !void {
    if (from.kind == .all) {
        const first = from.kind.all orelse {
            const new_constraint = try ctx.usage_arena.create(Schema.Constraint);
            new_constraint.* = .zero;
            new_constraint.kind = new_kind;
            const new_node = try ctx.usage_arena.create(Schema.Constraint.Node);
            new_node.* = .{
                .constraint = new_constraint,
                .next = null,
            };
            from.kind = .{ .all = new_node };
            return;
        };
        var tail = first;
        while (tail.next) |next| {
            tail = next;
        }

        const new_constraint = try ctx.usage_arena.create(Schema.Constraint);
        new_constraint.* = .zero;
        new_constraint.kind = new_kind;

        const new_node = try ctx.usage_arena.create(Schema.Constraint.Node);
        new_node.* = .{
            .constraint = new_constraint,
            .next = null,
        };
        @constCast(tail).next = new_node;
    } else if (from.kind != .true) {
        const first_constraint = try ctx.usage_arena.create(Schema.Constraint);
        first_constraint.* = from.*;

        const second_constraint = try ctx.usage_arena.create(Schema.Constraint);
        second_constraint.* = .zero;
        second_constraint.kind = new_kind;

        const nodes = try ctx.usage_arena.alloc(Schema.Constraint.Node, 2);
        nodes[0] = .{
            .constraint = first_constraint,
            .next = &nodes[1],
        };
        nodes[1] = .{
            .constraint = second_constraint,
            .next = null,
        };
        from.* = .{ .kind = .{ .all = &nodes[0] } };
    } else {
        from.kind = new_kind;
    }
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

fn parse_validation__type(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    const ty = (obj.get_const("type") orelse return null).*;
    switch (ty.kind) {
        .string => |v_type_str| {
            const v_type = try ctx.usage_arena.create(ValidationType);
            // todo: error
            v_type.* = ValidationType.Map.get(v_type_str) orelse return null;
            return .{ .type = v_type[0..1] };
        },
        .array => |*arr| {
            var v_types: base.ArenaList(ValidationType) = try .init_capacity(ctx.usage_arena, arr.count());
            var iter = arr.iter();
            while (iter.next()) |v_type_item| {
                if (v_type_item.kind != .string) {
                    // todo: error
                    continue;
                }
                const v_type = ValidationType.Map.get(v_type_item.kind.string) orelse continue;
                v_types.append_assume_capacity(v_type);
            }
            return .{ .type = v_types.items };
        },
        else => return null,
    }
}

/// https://www.learnjsonschema.com/2020-12/validation/minlength/
fn parse_validation__min_length(obj: *const HashableJsonValue.Kind.Object) ?Schema.Constraint.Kind {
    const min_len = (obj.get_const("minLength") orelse return null).*;
    switch (min_len.kind) {
        .integer => |int_val| {
            return .{ .min_len = std.math.lossyCast(u64, int_val) };
        },
        else => return null,
    }
}

/// https://www.learnjsonschema.com/2020-12/validation/maxlength/
fn parse_validation__max_length(obj: *const HashableJsonValue.Kind.Object) ?Schema.Constraint.Kind {
    const min_len = (obj.get_const("maxLength") orelse return null).*;
    switch (min_len.kind) {
        .integer => |int_val| {
            return .{ .max_len = std.math.lossyCast(u64, int_val) };
        },
        else => return null,
    }
}

/// https://www.learnjsonschema.com/2020-12/validation/minimum/
fn parse_validation__min(obj: *const HashableJsonValue.Kind.Object) ?Schema.Constraint.Kind {
    const min_val = (obj.get_const("minimum") orelse return null).*;
    switch (min_val.kind) {
        .integer => |int_val| {
            return .{ .min_i64 = int_val };
        },
        .float => |float_val| {
            return .{ .min_f64 = float_val };
        },
        else => return null,
    }
}

/// https://www.learnjsonschema.com/2020-12/validation/maximum/
fn parse_validation__max(obj: *const HashableJsonValue.Kind.Object) ?Schema.Constraint.Kind {
    const max_val = (obj.get_const("maximum") orelse return null).*;
    switch (max_val.kind) {
        .integer => |int_val| {
            return .{ .max_i64 = int_val };
        },
        .float => |float_val| {
            return .{ .max_f64 = float_val };
        },
        else => return null,
    }
}

/// https://www.learnjsonschema.com/2020-12/validation/exclusiveminimum/
fn parse_validation__exclusive_min(obj: *const HashableJsonValue.Kind.Object) ?Schema.Constraint.Kind {
    const min_val = (obj.get_const("exclusiveMinimum") orelse return null).*;
    switch (min_val.kind) {
        .integer => |int_val| {
            return .{ .min_i64_exclusive = int_val };
        },
        .float => |float_val| {
            return .{ .min_f64_exclusive = float_val };
        },
        else => return null,
    }
}

/// https://www.learnjsonschema.com/2020-12/validation/exclusivemaximum/
fn parse_validation__exclusive_max(obj: *const HashableJsonValue.Kind.Object) ?Schema.Constraint.Kind {
    const max_val = (obj.get_const("exclusiveMaximum") orelse return null).*;
    switch (max_val.kind) {
        .integer => |int_val| {
            return .{ .max_i64_exclusive = int_val };
        },
        .float => |float_val| {
            return .{ .max_f64_exclusive = float_val };
        },
        else => return null,
    }
}

fn parse_validation__min_items(obj: *const HashableJsonValue.Kind.Object) ?Schema.Constraint.Kind {
    const min_items = (obj.get_const("minItems") orelse return null).*;
    switch (min_items.kind) {
        .integer => |int_val| {
            return .{ .min_items = std.math.lossyCast(u64, int_val) };
        },
        .float => |flt_val| {
            return .{ .min_items = std.math.lossyCast(u64, flt_val) };
        },
        else => return null,
    }
}

fn parse_validation__max_items(obj: *const HashableJsonValue.Kind.Object) ?Schema.Constraint.Kind {
    const max_items = (obj.get_const("maxItems") orelse return null).*;
    switch (max_items.kind) {
        .integer => |int_val| {
            return .{ .max_items = std.math.lossyCast(u64, int_val) };
        },
        .float => |flt_val| {
            return .{ .max_items = std.math.lossyCast(u64, flt_val) };
        },
        else => return null,
    }
}

fn parse_validation__min_properties(obj: *const HashableJsonValue.Kind.Object) ?Schema.Constraint.Kind {
    const min_properties = (obj.get_const("minProperties") orelse return null).*;
    switch (min_properties.kind) {
        .integer => |int_val| {
            return .{ .min_properties = std.math.lossyCast(u64, int_val) };
        },
        .float => |flt_val| {
            return .{ .min_properties = std.math.lossyCast(u64, flt_val) };
        },
        else => return null,
    }
}

fn parse_validation__max_properties(obj: *const HashableJsonValue.Kind.Object) ?Schema.Constraint.Kind {
    const max_properties = (obj.get_const("maxProperties") orelse return null).*;
    switch (max_properties.kind) {
        .integer => |int_val| {
            return .{ .max_properties = std.math.lossyCast(u64, int_val) };
        },
        .float => |flt_val| {
            return .{ .max_properties = std.math.lossyCast(u64, flt_val) };
        },
        else => return null,
    }
}

fn parse_validation__const(obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) void {
    const value = (obj.get_const("const") orelse return).*;
    constraint.flags.@"const" = true;
    constraint.@"const" = value.hash;
}

fn parse_validation__enum(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    const value = (obj.get_const("enum") orelse return null).*;
    if (value.kind != .array) {
        return .{ .@"enum" = &.{} };
    }
    var hashes: base.ArenaList(u64) = try .init_capacity(ctx.usage_arena, value.kind.array.count());
    var iter = value.kind.array.iter();
    while (iter.next()) |item| {
        hashes.append_assume_capacity(item.hash);
    }
    return .{
        .@"enum" = hashes.items,
    };
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
            if (items_ptr.*.kind != .array) break :blk items_ptr.*;
        }
        if (has_legacy_tuple_items and ctx.revision != .draft2020_12 and ctx.revision != .draft_next) {
            if (obj.get_const("additionalItems")) |additional_items_ptr| {
                if (additional_items_ptr.*.kind != .array) {
                    constraint.flags.additional_items = true;
                    break :blk additional_items_ptr.*;
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

    const properties_obj = &properties_ptr.*.kind.object;
    var properties = try base.ArenaList(Schema.Constraint.Property).init_capacity(ctx.usage_arena, properties_obj.count());
    var property_iter = properties_obj.const_iterator();
    while (property_iter.next()) |entry| {
        properties.append_assume_capacity(.{
            .name = try persist_string(ctx, entry.key_ptr.*),
            .constraint = try parse_constraint(ctx, entry.value_ptr.*),
        });
    }
    constraint.properties = properties.items;
}

fn parse_applicator__pattern_properties(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const pattern_properties_ptr = obj.get_const("patternProperties") orelse return;
    if (pattern_properties_ptr.*.kind != .object) return;

    const pattern_properties_obj = &pattern_properties_ptr.*.kind.object;
    var pattern_properties = try base.ArenaList(Schema.Constraint.PatternProperty).init_capacity(ctx.usage_arena, pattern_properties_obj.count());
    var pattern_iter = pattern_properties_obj.const_iterator();
    while (pattern_iter.next()) |entry| {
        const pattern_c = try ctx.usage_arena.allocator().dupeZ(u8, entry.key_ptr.*);
        // PERF: lazy compile
        const re = pcre.Regex.compile(pattern_c, .{
            .Dotall = true,
            .JavascriptCompat = true,
            .Utf8 = true,
        }) catch continue;
        pattern_properties.append_assume_capacity(.{
            .pattern = re,
            .constraint = try parse_constraint(ctx, entry.value_ptr.*),
        });
    }
    constraint.pattern_properties = pattern_properties.items;
}

fn parse_applicator__additional_properties(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const additional_properties_ptr = obj.get_const("additionalProperties") orelse return;
    constraint.additional_properties = try parse_constraint(ctx, additional_properties_ptr.*);
}

fn parse_validation__required_properties(
    ctx: *ParseContext,
    obj: *const HashableJsonValue.Kind.Object,
    constraint: *Schema.Constraint,
) !void {
    if (ctx.revision == .draft3) {
        // Draft3 style: "required": true inside each property definition
        const properties_value = (obj.get_const("properties") orelse return).*;
        if (properties_value.kind != .object) return;

        var required_properties: base.ArenaList(u64) = .empty;
        var property_iter = properties_value.kind.object.const_iterator();
        while (property_iter.next()) |entry| {
            if (entry.value_ptr.*.kind != .object) continue;
            const required_field = (entry.value_ptr.*.kind.object.get_const("required") orelse continue).*;
            if (required_field.kind != .bool) continue;
            if (required_field.kind.bool) {
                try required_properties.append(ctx.usage_arena, json.hashed.compute_string_hash(entry.key_ptr.*));
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
    const dependent_required_value = (obj.get_const("dependentRequired") orelse return).*;
    if (dependent_required_value.kind != .object) return;

    var entries = try base.ArenaList(Schema.Constraint.DependentRequiredEntry).init_capacity(
        ctx.usage_arena,
        dependent_required_value.kind.object.count(),
    );
    var iter = dependent_required_value.kind.object.const_iterator();
    while (iter.next()) |entry| {
        if (entry.value_ptr.*.kind != .array) continue;

        var required_hashes = try base.ArenaList(u64).init_capacity(ctx.usage_arena, entry.value_ptr.*.kind.array.count());
        var req_iter = entry.value_ptr.*.kind.array.iter();
        while (req_iter.next()) |required_property| {
            if (required_property.kind != .string) continue;
            required_hashes.append_assume_capacity(required_property.hash);
        }

        if (required_hashes.items.len == 0) continue;

        entries.append_assume_capacity(.{
            .trigger_property_hash = json.hashed.compute_string_hash(entry.key_ptr.*),
            .required_property_hashes = required_hashes.items,
        });
    }

    constraint.dependent_required = entries.items;
}

fn parse_applicator_not(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    const sub_schema = (obj.get_const("not") orelse return null).*;
    return .{
        .not = try parse_constraint(ctx, sub_schema),
    };
}

fn parse_applicator__all_of(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    const items = (obj.get_const("allOf") orelse return null).*;
    if (items.kind != .array) return null;

    const count = items.kind.array.count();
    if (count == 0) return .{ .all = null };

    const nodes = try ctx.usage_arena.alloc(Schema.Constraint.Node, count);
    var iter = items.kind.array.iter();
    var i: usize = 0;
    while (iter.next()) |item| : (i += 1) {
        nodes[i] = .{
            .constraint = try parse_constraint(ctx, item),
            .next = if (i + 1 < count) &nodes[i + 1] else null,
        };
    }

    return .{ .all = &nodes[0] };
}

fn parse_applicator__any_of(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    const items = (obj.get_const("anyOf") orelse return null).*;
    if (items.kind != .array) return null;

    const count = items.kind.array.count();
    if (count == 0) return .{ .any = null };

    const nodes = try ctx.usage_arena.alloc(Schema.Constraint.Node, count);
    var iter = items.kind.array.iter();
    var i: usize = 0;
    while (iter.next()) |item| : (i += 1) {
        nodes[i] = .{
            .constraint = try parse_constraint(ctx, item),
            .next = if (i + 1 < count) &nodes[i + 1] else null,
        };
    }

    return .{ .any = &nodes[0] };
}

fn parse_applicator__one_of(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    const items = (obj.get_const("oneOf") orelse return null).*;
    if (items.kind != .array) return null;

    const count = items.kind.array.count();
    if (count == 0) return .{ .one = null };

    const nodes = try ctx.usage_arena.alloc(Schema.Constraint.Node, count);
    var iter = items.kind.array.iter();
    var i: usize = 0;
    while (iter.next()) |item| : (i += 1) {
        nodes[i] = .{
            .constraint = try parse_constraint(ctx, item),
            .next = if (i + 1 < count) &nodes[i + 1] else null,
        };
    }

    return .{ .one = &nodes[0] };
}

fn parse_validation__multiple_of(obj: *const HashableJsonValue.Kind.Object) ?Schema.Constraint.Kind {
    const multiple_of = (obj.get_const("multipleOf") orelse return null).*;
    return switch (multiple_of.kind) {
        .float => |float_val| .{ .multiple_of_f64 = float_val },
        .integer => |int_val| .{ .multiple_of_i64 = int_val },
        else => null,
    };
}

fn parse_validation__pattern(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    const pattern = (obj.get_const("pattern") orelse return null).*;
    if (pattern.kind != .string) return null;

    const pattern_c = try ctx.usage_arena.allocator().dupeZ(u8, pattern.kind.string);
    const re = try pcre.Regex.compile(pattern_c, .{
        .Dotall = true,
        .JavascriptCompat = true,
        .Utf8 = true,
    });

    return .{
        .pattern = re,
    };
}

fn parse_applicator__if_then_else(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object, constraint: *Schema.Constraint) !void {
    const cond_value = obj.get_const("if") orelse return;
    constraint.if_constraint = try parse_constraint(ctx, cond_value.*);
    if (obj.get_const("then")) |then| {
        constraint.then_constraint = try parse_constraint(ctx, then.*);
    }
    if (obj.get_const("else")) |elsa| {
        constraint.else_constraint = try parse_constraint(ctx, elsa.*);
    }
}

fn float_as_int(float: f64) ?i64 {
    if (@trunc(float) != float) return null;
    const min_int: f64 = @floatFromInt(std.math.minInt(i64));
    const max_int: f64 = @floatFromInt(std.math.maxInt(i64));
    if (std.math.clamp(float, min_int, max_int) != float) return null;
    return @intFromFloat(float);
}

fn ref_overrides_siblings(revision: Revision) bool {
    return revision != .draft2019_09 and revision != .draft2020_12 and revision != .draft_next;
}

test {
    std.testing.refAllDecls(@This());
    std.testing.refAllDecls(@import("tests.zig"));
}
