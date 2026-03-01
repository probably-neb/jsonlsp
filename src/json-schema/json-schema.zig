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
    root: *const Constraint,
    arena: Arena,

    pub const PatternProperty = struct {
        pattern: pcre.Regex,
        constraint: *Constraint,
    };

    pub const Constraint = struct {
        next: ?*const Constraint,
        kind: Kind,

        pub const Kind = union(enum) {
            true: void,
            false: void,
            type: []ValidationType,
            all: ?*const Constraint, // corresponds to allOf,
            any: ?*const Constraint, // corresponds to anyOf,
            one: ?*const Constraint, // corresponds to oneOf,
            not: *const Constraint,
            @"const": u64,
            @"enum": []u64,
            unique_items: void,
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
            items: *const Constraint,
            tuple_items: ?struct {
                items: []*const Constraint,
                additional_items: ?*const Constraint,
            },
            properties: struct {
                first_property: ?*const Constraint,
                additional: *const Constraint,
                pattern_properties: []PatternProperty,
            },
            // todo: just store in slice, not actual constraint
            property: struct {
                name: str8,
                constraint: *const Constraint,
            },
            required: []u64,
            dependent_required: []DependentRequiredEntry,
            multiple_of_i64: i64,
            multiple_of_f64: f64,
            pattern: pcre.Regex,
            ref: *const Constraint,
            if_then_else: struct {
                cond: *const Constraint,
                then: *const Constraint,
                elsa: *const Constraint,
            },
        };

        pub const DependentRequiredEntry = struct {
            trigger_property_hash: u64,
            required_property_hashes: []u64,
        };

        pub const zero = Constraint{
            .next = null,
            .kind = .true,
        };
    };

    pub fn is_valid(schema: *const Schema, input: str8) bool {
        var arena = Arena.init(.{}) catch unreachable;
        defer arena.release();

        const json_value = json.hashed.parse(&arena, input) catch return false;
        return check(&arena, schema.root, json_value) catch return false;
    }
};

fn check(arena: *Arena, constraint: *const Schema.Constraint, value: *const HashableJsonValue) !bool {
    switch (constraint.kind) {
        .true => return true,
        .false => return false,
        .type => |v_types| {
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
            return result;
        },
        .all => |first_child| {
            var result = true;
            var cur_constraint = first_child;
            // std.debug.print("\nall\n", .{});
            while (cur_constraint) |cur| : (cur_constraint = cur.next) {
                result = result and try check(arena, cur, value);
                // std.debug.print("Constraint {t} -> {}\n", .{ cur.kind, result });
            }
            return result;
        },
        .any => |first_child| {
            var result = false;
            var cur_constraint = first_child;
            // std.debug.print("\nall\n", .{});
            while (cur_constraint) |cur| : (cur_constraint = cur.next) {
                result = result or try check(arena, cur, value);
                // std.debug.print("Constraint {t} -> {}\n", .{ cur.kind, result });
            }
            return result;
        },
        .one => |first_child| {
            var result = false;
            var cur_constraint = first_child;
            // std.debug.print("\nall\n", .{});
            while (cur_constraint) |cur| : (cur_constraint = cur.next) {
                result = result != try check(arena, cur, value);
                // std.debug.print("Constraint {t} -> {}\n", .{ cur.kind, result });
            }
            return result;
        },
        .@"const" => |stored_hash| {
            return stored_hash == value.hash;
        },
        .@"enum" => |hashes| {
            for (hashes) |hash| {
                if (hash == value.hash) return true;
            }
            return false;
        },
        .unique_items => {
            if (value.kind != .array) {
                return true;
            }
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
            return true;
        },
        .items => |item_sub_schema| {
            if (value.kind != .array) {
                return true;
            }

            var arr_iter = value.kind.array.iter();
            while (arr_iter.next()) |item| {
                if (!try check(arena, item_sub_schema, item)) return false;
            }
            return true;
        },
        .tuple_items => |tuple_info| {
            const ti = tuple_info orelse return true;
            if (value.kind != .array) {
                return true;
            }

            // Validate each array item against its corresponding schema
            var arr_iter = value.kind.array.iter();
            var i: usize = 0;
            while (arr_iter.next()) |item| : (i += 1) {
                if (i >= ti.items.len) {
                    // Check additional items
                    if (ti.additional_items) |additional_schema| {
                        if (!try check(arena, additional_schema, item)) return false;
                    }
                    // If no additional_items constraint, extra items are allowed
                    continue;
                }
                if (!try check(arena, ti.items[i], item)) return false;
            }
            return true;
        },
        .min_len => |min_len| {
            return value.kind != .string or (std.unicode.utf8CountCodepoints(value.kind.string) catch 0) >= min_len;
        },
        .max_len => |max_len| {
            return value.kind != .string or (std.unicode.utf8CountCodepoints(value.kind.string) catch 0) <= max_len;
        },
        .max_items => |max_items| {
            return value.kind != .array or value.kind.array.count() <= max_items;
        },
        .min_items => |min_items| {
            return value.kind != .array or value.kind.array.count() >= min_items;
        },
        .max_properties => |max_properties| {
            return value.kind != .object or value.kind.object.count() <= max_properties;
        },
        .min_properties => |min_properties| {
            return value.kind != .object or value.kind.object.count() >= min_properties;
        },
        .max_i64 => |max_int| {
            return switch (value.kind) {
                .integer => |int_val| int_val <= max_int,
                .float => |float_val| float_val <= @as(f64, @floatFromInt(max_int)),
                else => true,
            };
        },
        .min_i64 => |min_int| {
            return switch (value.kind) {
                .integer => |int_val| int_val >= min_int,
                .float => |float_val| float_val >= @as(f64, @floatFromInt(min_int)),
                else => true,
            };
        },
        .max_f64 => |max_f64| {
            return switch (value.kind) {
                .integer => |int_val| @as(f64, @floatFromInt(int_val)) <= max_f64,
                .float => |float_val| float_val <= max_f64,
                else => true,
            };
        },
        .min_f64 => |min_f64| {
            return switch (value.kind) {
                .integer => |int_val| @as(f64, @floatFromInt(int_val)) >= min_f64,
                .float => |float_val| float_val >= min_f64,
                else => true,
            };
        },
        .max_i64_exclusive => |max_int| {
            return switch (value.kind) {
                .integer => |int_val| int_val < max_int,
                .float => |float_val| float_val < @as(f64, @floatFromInt(max_int)),
                else => true,
            };
        },
        .min_i64_exclusive => |min_int| {
            return switch (value.kind) {
                .integer => |int_val| int_val > min_int,
                .float => |float_val| float_val > @as(f64, @floatFromInt(min_int)),
                else => true,
            };
        },
        .max_f64_exclusive => |max_f64| {
            return switch (value.kind) {
                .integer => |int_val| @as(f64, @floatFromInt(int_val)) < max_f64,
                .float => |float_val| float_val < max_f64,
                else => true,
            };
        },
        .min_f64_exclusive => |min_f64| {
            return switch (value.kind) {
                .integer => |int_val| @as(f64, @floatFromInt(int_val)) > min_f64,
                .float => |float_val| float_val > min_f64,
                else => true,
            };
        },
        .properties => |properties| {
            if (value.kind != .object) {
                return true;
            }
            const scratch = Arena.get_scratch(&.{arena});
            defer scratch.release();
            var current_property = properties.first_property;
            var checked_properties: std.StringArrayHashMapUnmanaged(void) = .empty;
            defer checked_properties.deinit(scratch.arena.allocator());
            while (current_property) |property_constraint| : (current_property = property_constraint.next) {
                const sub_value = (value.kind.object.get_const(property_constraint.kind.property.name) orelse continue).*;
                try checked_properties.put(scratch.arena.allocator(), property_constraint.kind.property.name, {});
                if (!try check(arena, property_constraint.kind.property.constraint, sub_value)) {
                    return false;
                }
            }
            // Check all properties against patternProperties and additionalProperties
            var obj_iter = value.kind.object.const_iterator();
            while (obj_iter.next()) |entry| {
                // Check if property matches any patternProperties (applies to ALL properties)
                var matched_pattern = false;
                for (properties.pattern_properties) |pattern_prop| {
                    const matches = try pattern_prop.pattern.matches(entry.key_ptr.*, .{});
                    if (matches != null) {
                        matched_pattern = true;
                        // Validate against the pattern's constraint
                        if (!try check(arena, pattern_prop.constraint, entry.value_ptr.*)) {
                            return false;
                        }
                    }
                }

                // Only check additionalProperties if not in properties AND no pattern matched
                if (!checked_properties.contains(entry.key_ptr.*) and !matched_pattern) {
                    if (!try check(arena, properties.additional, entry.value_ptr.*)) return false;
                }
            }
            return true;
        },
        .property => unreachable,
        .required => |required_property_hashes| {
            if (value.kind != .object) {
                return true;
            }

            for (required_property_hashes) |required_property_hash| {
                // perf: should be improved - could store string hashes in a set
                var key_iter = value.kind.object.key_iterator();
                while (key_iter.next()) |key_ptr| {
                    // Hash the key string to compare
                    const key_hash = json.hashed.compute_string_hash(key_ptr.*);
                    if (key_hash == required_property_hash) break;
                } else return false;
            }
            return true;
        },
        .dependent_required => |entries| {
            if (value.kind != .object) {
                return true;
            }

            for (entries) |entry| {
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
            return true;
        },
        .not => |constraint_to_invert| {
            return !try check(arena, constraint_to_invert, value);
        },
        .multiple_of_f64 => |multiple_of| {
            if (multiple_of == 0.0) return false;
            const float_val = switch (value.kind) {
                .integer => |int_val| @as(f64, @floatFromInt(int_val)),
                .float => |fv| fv,
                else => 0.0,
            };
            // Check if value/multiple_of is close to an integer to handle floating-point precision
            const quotient = float_val / multiple_of;
            const diff = @abs(quotient - @round(quotient));
            return diff < 1e-9;
        },
        .multiple_of_i64 => |multiple_of| {
            if (multiple_of == 0) return false;
            const int_val = switch (value.kind) {
                .integer => |iv| iv,
                .float => |fv| float_as_int(fv) orelse return false,
                else => 0,
            };
            return @rem(int_val, multiple_of) == 0;
        },
        .pattern => |regex| {
            if (value.kind != .string) return true;
            const matches = try regex.matches(value.kind.string, .{});
            return matches != null;
        },
        .ref => |referenced_constraint| {
            return check(arena, referenced_constraint, value);
        },
        .if_then_else => |if_then_else| {
            if (try check(arena, if_then_else.cond, value)) {
                return try check(arena, if_then_else.then, value);
            } else {
                return try check(arena, if_then_else.elsa, value);
            }
        },
    }
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
    const root = try parse_constraint(&ctx, root_json);
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

fn resolve_ref(ctx: *ParseContext, ref_string: []const u8) !?*Schema.Constraint {
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
    constraint.next = null;
    constraint.kind = .true;

    if (schema.kind == .bool) {
        constraint.kind = switch (schema.kind.bool) {
            true => .true,
            false => .false,
        };
        return;
    }
    if (schema.kind != .object) {
        return error.UnrecognizedSchemaType;
    }
    const obj = &schema.kind.object;

    if (obj.count() == 0) {
        constraint.kind = .true;
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
    if (parse_validation__const(obj)) |@"const"| {
        try chain_with(ctx, constraint, @"const");
    }
    if (parse_validation__enum(ctx, obj) catch null) |@"enum"| {
        try chain_with(ctx, constraint, @"enum");
    }
    if (parse_validation__unique_items(obj)) |unique_items| {
        try chain_with(ctx, constraint, unique_items);
    }
    if (parse_applicator__items(ctx, obj) catch null) |items| {
        try chain_with(ctx, constraint, items);
    }
    if (parse_applicator__properties(ctx, obj) catch null) |properties| {
        try chain_with(ctx, constraint, properties);
    }
    if (parse_validation__required_properties(ctx, obj) catch null) |required_properties| {
        try chain_with(ctx, constraint, required_properties);
    }
    if (parse_validation__dependent_required(ctx, obj) catch null) |dependent_required| {
        try chain_with(ctx, constraint, dependent_required);
    }
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
    if (try parse_applicator__if_then_else(ctx, obj)) |if_then_else| {
        try chain_with(ctx, constraint, if_then_else);
    }
    if (parse_validation__multiple_of(obj)) |multiple_of| {
        try chain_with(ctx, constraint, multiple_of);
    }
    if (parse_validation__pattern(ctx, obj) catch null) |pattern| {
        try chain_with(ctx, constraint, pattern);
    }
}

fn parse_constraint(ctx: *ParseContext, schema: *const HashableJsonValue) ParseError!*Schema.Constraint {
    const cached_constraint = try ctx.constraint_cache.get_or_put(ctx.usage_arena, schema.hash);
    if (cached_constraint.found_existing) {
        return cached_constraint.value_ptr.*;
    }
    cached_constraint.value_ptr.* = try ctx.usage_arena.create(Schema.Constraint);
    try parse_into_constraint(ctx, schema, cached_constraint.value_ptr.*);
    return cached_constraint.value_ptr.*;
}

fn chain_with(ctx: *ParseContext, from: *Schema.Constraint, new_kind: Schema.Constraint.Kind) !void {
    if (from.kind == .all) {
        // add new link to chain
        const new = try ctx.usage_arena.create(Schema.Constraint);
        new.next = from.kind.all;
        new.kind = new_kind;
        from.kind.all = new;
    } else if (from.kind != .true) {
        // turn from into chain of length two with it's current constraint and the new constraint
        var constraints = try ctx.usage_arena.alloc(Schema.Constraint, 2);
        @memset(constraints, .zero);
        constraints[0].kind = from.kind;
        constraints[0].next = &constraints[1];
        constraints[1].kind = new_kind;
        from.kind = .{ .all = &constraints[0] };
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

fn parse_validation__const(obj: *const HashableJsonValue.Kind.Object) ?Schema.Constraint.Kind {
    const value = (obj.get_const("const") orelse return null).*;
    return .{ .@"const" = value.hash };
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

fn parse_validation__unique_items(obj: *const HashableJsonValue.Kind.Object) ?Schema.Constraint.Kind {
    const unique_items = (obj.get_const("uniqueItems") orelse return null).*;
    // todo: how to handle
    if (unique_items.kind != .bool or !unique_items.kind.bool) return null;
    return .unique_items;
}

fn parse_applicator__items(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    const items_sub_schema = (obj.get_const("items") orelse return null).*;
    // items can be either a single schema (applies to all items) or an array of schemas (tuple validation)
    if (items_sub_schema.kind == .array) {
        const item_schemas = try ctx.usage_arena.alloc(*const Schema.Constraint, items_sub_schema.kind.array.count());
        var iter = items_sub_schema.kind.array.iter();
        var i: usize = 0;
        while (iter.next()) |item_schema| : (i += 1) {
            item_schemas[i] = try parse_constraint(ctx, item_schema);
        }
        // Parse additionalItems
        const additional_items: ?*const Schema.Constraint = blk: {
            const additional_items_ptr = obj.get_const("additionalItems") orelse break :blk null;
            break :blk try parse_constraint(ctx, additional_items_ptr.*);
        };
        return .{ .tuple_items = .{
            .items = item_schemas,
            .additional_items = additional_items,
        } };
    }
    return .{ .items = try parse_constraint(ctx, items_sub_schema) };
}

fn parse_applicator__properties(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    const properties_ptr = obj.get_const("properties");
    const pattern_properties_ptr = obj.get_const("patternProperties");
    const additional_properties_ptr = obj.get_const("additionalProperties");

    const properties_value: ?*const HashableJsonValue = if (properties_ptr) |p| p.* else null;
    const pattern_properties_value: ?*const HashableJsonValue = if (pattern_properties_ptr) |p| p.* else null;
    const additional_properties_value: ?*const HashableJsonValue = if (additional_properties_ptr) |p| p.* else null;

    // Return null if none of the three property-related keywords are present
    if (properties_value == null and pattern_properties_value == null and additional_properties_value == null) {
        return null;
    }

    // Parse properties
    var first_property: ?*Schema.Constraint = null;
    if (properties_value) |props| {
        if (props.kind == .object) {
            var property_iter = props.kind.object.const_iterator();
            var property_constraints = try ctx.usage_arena.alloc(Schema.Constraint, props.kind.object.count());
            var index: u64 = 0;
            while (property_iter.next()) |entry| : (index += 1) {
                if (index > 0) {
                    property_constraints[index - 1].next = &property_constraints[index];
                }
                property_constraints[index] = .{
                    .next = null,
                    .kind = .{
                        .property = .{
                            .name = try persist_string(ctx, entry.key_ptr.*),
                            .constraint = try parse_constraint(ctx, entry.value_ptr.*),
                        },
                    },
                };
            }
            if (property_constraints.len > 0) {
                first_property = &property_constraints[0];
            }
        }
    }

    // Parse patternProperties
    const PatternProperty = Schema.PatternProperty;
    var pattern_properties: []PatternProperty = &.{};
    if (pattern_properties_value) |pattern_props| {
        if (pattern_props.kind == .object) {
            var pattern_property_list = try ctx.usage_arena.alloc(PatternProperty, pattern_props.kind.object.count());
            var pattern_iter = pattern_props.kind.object.const_iterator();
            var pattern_index: usize = 0;
            while (pattern_iter.next()) |entry| {
                const pattern_c = try ctx.usage_arena.allocator().dupeZ(u8, entry.key_ptr.*);
                const re = pcre.Regex.compile(pattern_c, .{
                    .Dotall = true,
                    .JavascriptCompat = true,
                    .Utf8 = true,
                }) catch continue; // Skip invalid patterns
                pattern_property_list[pattern_index] = .{
                    .pattern = re,
                    .constraint = try parse_constraint(ctx, entry.value_ptr.*),
                };
                pattern_index += 1;
            }
            pattern_properties = pattern_property_list[0..pattern_index];
        }
    }

    return .{
        .properties = .{
            .first_property = first_property,
            .additional = if (additional_properties_value) |additional| try parse_constraint(ctx, additional) else @constCast(&Schema.Constraint.zero),
            .pattern_properties = pattern_properties,
        },
    };
}

fn parse_validation__required_properties(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    if (ctx.revision == .draft3) {
        // Draft3 style: "required": true inside each property definition
        const properties_value = (obj.get_const("properties") orelse return null).*;
        if (properties_value.kind != .object) return null;

        var required_properties: base.ArenaList(u64) = .empty;
        var property_iter = properties_value.kind.object.const_iterator();
        while (property_iter.next()) |entry| {
            if (entry.value_ptr.*.kind != .object) continue;
            const required_field = (entry.value_ptr.*.kind.object.get_const("required") orelse continue).*;
            if (required_field.kind != .bool) continue;
            if (required_field.kind.bool) {
                // Hash the property name as a string for required check
                try required_properties.append(ctx.usage_arena, json.hashed.compute_string_hash(entry.key_ptr.*));
            }
        }

        if (required_properties.items.len == 0) return null;
        return .{
            .required = required_properties.items,
        };
    }

    // Draft4+ style: "required" is an array of property names at the object level
    const required_properties_value = (obj.get_const("required") orelse return null).*;
    if (required_properties_value.kind != .array) return null;

    var required_properties = try base.ArenaList(u64).init_capacity(ctx.usage_arena, required_properties_value.kind.array.count());
    var iter = required_properties_value.kind.array.iter();
    while (iter.next()) |required_property| {
        if (required_property.kind != .string) continue;
        required_properties.append_assume_capacity(required_property.hash);
    }
    if (required_properties.items.len == 0) return null;
    return .{
        .required = required_properties.items,
    };
}

fn parse_validation__dependent_required(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    const dependent_required_value = (obj.get_const("dependentRequired") orelse return null).*;
    if (dependent_required_value.kind != .object) return null;

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

    if (entries.items.len == 0) return null;
    return .{
        .dependent_required = entries.items,
    };
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
    var all_of_constraint = Schema.Constraint.Kind{
        .all = null,
    };
    var prev_next_ptr = &all_of_constraint.all;
    var iter = items.kind.array.iter();
    while (iter.next()) |item| {
        const sub_schema = try parse_constraint(ctx, item);
        prev_next_ptr.* = sub_schema;
        prev_next_ptr = &sub_schema.next;
    }
    return all_of_constraint;
}

fn parse_applicator__any_of(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    const items = (obj.get_const("anyOf") orelse return null).*;
    if (items.kind != .array) return null;
    var any_of_constraint = Schema.Constraint.Kind{
        .any = null,
    };
    var prev_next_ptr = &any_of_constraint.any;
    var iter = items.kind.array.iter();
    while (iter.next()) |item| {
        const sub_schema = try parse_constraint(ctx, item);
        prev_next_ptr.* = sub_schema;
        prev_next_ptr = &sub_schema.next;
    }
    return any_of_constraint;
}

fn parse_applicator__one_of(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    const items = (obj.get_const("oneOf") orelse return null).*;
    if (items.kind != .array) return null;
    var one_of_constraint = Schema.Constraint.Kind{
        .one = null,
    };
    var prev_next_ptr = &one_of_constraint.one;
    var iter = items.kind.array.iter();
    while (iter.next()) |item| {
        const sub_schema = try parse_constraint(ctx, item);
        prev_next_ptr.* = sub_schema;
        prev_next_ptr = &sub_schema.next;
    }
    return one_of_constraint;
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

fn parse_applicator__if_then_else(ctx: *ParseContext, obj: *const HashableJsonValue.Kind.Object) !?Schema.Constraint.Kind {
    const cond_value = obj.get_const("if") orelse return null;
    const cond = try parse_constraint(ctx, cond_value.*);
    return .{
        .if_then_else = .{
            .cond = cond,
            .then = if (obj.get_const("then")) |then| try parse_constraint(ctx, then.*) else &.zero,
            .elsa = if (obj.get_const("else")) |else_| try parse_constraint(ctx, else_.*) else &.zero,
        },
    };
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

test "boolean schema - true schema accepts everything" {
    const schema_str = "true";
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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
    var schema = try parse(schema_str);
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

test "object constraints - minProperties and maxProperties" {
    const schema_str =
        \\{
        \\  "type": "object",
        \\  "minProperties": 1,
        \\  "maxProperties": 3
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid counts
    try std.testing.expectEqual(schema.is_valid("{\"a\": 1}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"a\": 1, \"b\": 2}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"a\": 1, \"b\": 2, \"c\": 3}"), true);

    // Too few properties
    try std.testing.expectEqual(schema.is_valid("{}"), false);

    // Too many properties
    try std.testing.expectEqual(schema.is_valid("{\"a\": 1, \"b\": 2, \"c\": 3, \"d\": 4}"), false);

    // Non-objects are not affected
    try std.testing.expectEqual(schema.is_valid("[]"), false); // fails type check
    try std.testing.expectEqual(schema.is_valid("\"string\""), false); // fails type check
}

test "$ref with definitions" {
    const schema_str =
        \\{
        \\  "definitions": {
        \\    "positiveInteger": {
        \\      "type": "integer",
        \\      "minimum": 0
        \\    }
        \\  },
        \\  "type": "object",
        \\  "properties": {
        \\    "count": { "$ref": "#/definitions/positiveInteger" }
        \\  }
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("{\"count\": 5}"));
    try std.testing.expect(schema.is_valid("{\"count\": 0}"));
    try std.testing.expect(!schema.is_valid("{\"count\": -1}"));
    try std.testing.expect(!schema.is_valid("{\"count\": \"five\"}"));
}

test "$ref with $defs (2019-09+ style)" {
    const schema_str =
        \\{
        \\  "$defs": {
        \\    "stringArray": {
        \\      "type": "array",
        \\      "items": { "type": "string" }
        \\    }
        \\  },
        \\  "$ref": "#/$defs/stringArray"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("[\"a\", \"b\", \"c\"]"));
    try std.testing.expect(schema.is_valid("[]"));
    try std.testing.expect(!schema.is_valid("[\"a\", 1]"));
    try std.testing.expect(!schema.is_valid("\"not an array\""));
}

test "$ref nested refs" {
    const schema_str =
        \\{
        \\  "definitions": {
        \\    "a": { "type": "integer" },
        \\    "b": { "$ref": "#/definitions/a" },
        \\    "c": { "$ref": "#/definitions/b" }
        \\  },
        \\  "$ref": "#/definitions/c"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("5"));
    try std.testing.expect(schema.is_valid("-10"));
    try std.testing.expect(!schema.is_valid("\"string\""));
    try std.testing.expect(!schema.is_valid("1.5"));
}

test "$ref recursive schema" {
    const schema_str =
        \\{
        \\  "definitions": {
        \\    "node": {
        \\      "type": "object",
        \\      "properties": {
        \\        "value": { "type": "integer" },
        \\        "child": { "$ref": "#/definitions/node" }
        \\      }
        \\    }
        \\  },
        \\  "$ref": "#/definitions/node"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("{\"value\": 1}"));
    try std.testing.expect(schema.is_valid("{\"value\": 1, \"child\": {\"value\": 2}}"));
    try std.testing.expect(schema.is_valid("{\"value\": 1, \"child\": {\"value\": 2, \"child\": {\"value\": 3}}}"));
    try std.testing.expect(!schema.is_valid("{\"value\": \"not an int\"}"));
    try std.testing.expect(!schema.is_valid("{\"value\": 1, \"child\": {\"value\": \"bad\"}}"));
}

test "$ref pointer escape segment slash (~1)" {
    const schema_str =
        \\{
        \\  "$defs": {
        \\    "slash/field": { "type": "integer" }
        \\  },
        \\  "$ref": "#/$defs/slash~1field"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("1"));
    try std.testing.expect(!schema.is_valid("\"1\""));
}

test "$ref pointer escape segment tilde (~0)" {
    const schema_str =
        \\{
        \\  "$defs": {
        \\    "tilde~field": { "type": "string" }
        \\  },
        \\  "$ref": "#/$defs/tilde~0field"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("\"ok\""));
    try std.testing.expect(!schema.is_valid("1"));
}

test "$ref pointer escape segment percent (%25)" {
    const schema_str =
        \\{
        \\  "$defs": {
        \\    "percent%field": { "type": "boolean" }
        \\  },
        \\  "$ref": "#/$defs/percent%25field"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("true"));
    try std.testing.expect(!schema.is_valid("\"true\""));
}

test "dependentRequired - trigger present requires dependents (draft 2020-12)" {
    const schema_str =
        \\{
        \\  "dependentRequired": {
        \\    "credit_card": ["billing_address"]
        \\  }
        \\}
    ;
    var schema = try parse_with_revision(schema_str, .draft2020_12);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("{}"));
    try std.testing.expect(schema.is_valid("{\"billing_address\": \"123 Main St\"}"));
    try std.testing.expect(schema.is_valid("{\"credit_card\": 1234, \"billing_address\": \"123 Main St\"}"));
    try std.testing.expect(!schema.is_valid("{\"credit_card\": 1234}"));
}

test "dependentRequired - multiple dependencies (draft 2019-09)" {
    const schema_str =
        \\{
        \\  "dependentRequired": {
        \\    "name": ["surname", "given_name"]
        \\  }
        \\}
    ;
    var schema = try parse_with_revision(schema_str, .draft2019_09);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("{}"));
    try std.testing.expect(schema.is_valid("{\"surname\": \"Doe\"}"));
    try std.testing.expect(!schema.is_valid("{\"name\": \"X\", \"surname\": \"Doe\"}"));
    try std.testing.expect(schema.is_valid("{\"name\": \"X\", \"surname\": \"Doe\", \"given_name\": \"John\"}"));
}
