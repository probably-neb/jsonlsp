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

const str8 = []const u8;
pub const OOM = error{OutOfMemory};

const pcre = @import("pcre");

pub const Revision = enum {
    draft3,
    draft4,
    draft6,
    draft7,
    draft2019_09,
    draft2020_12,
    draft_next,
    unknown,

    fn detect(schema: std.json.Value) Revision {
        if (schema != .object) return .unknown;
        const schema_uri = schema.object.get("$schema") orelse return .unknown;
        if (schema_uri != .string) return .unknown;

        const uri = schema_uri.string;
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

    pub const Definition = struct {
        path: str8,
        constraint: *Constraint,

        fn lessThan(_: void, a: Definition, b: Definition) bool {
            return mem.order(u8, a.path, b.path) == .lt;
        }
    };

    pub const Constraint = struct {
        next: ?*Constraint,
        kind: Kind,

        pub const Kind = union(enum) {
            true: void,
            false: void,
            type: []ValidationType,
            all: ?*Constraint, // corresponds to allOf,
            any: ?*Constraint, // corresponds to anyOf,
            one: ?*Constraint, // corresponds to oneOf,
            @"const": ValueHash,
            @"enum": []ValueHash,
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
            items: *Constraint,
            tuple_items: ?struct {
                items: []*Constraint,
                additional_items: ?*Constraint,
            },
            properties: struct {
                first_property: ?*Constraint,
                additional: *Constraint,
                pattern_properties: []PatternProperty,
            },
            // todo: just store in slice, not actual constraint
            property: struct {
                name: str8,
                constraint: *Constraint,
            },
            required: []ValueHash,
            not: *Constraint,
            multiple_of_i64: i64,
            multiple_of_f64: f64,
            pattern: pcre.Regex,
            ref: *Constraint,
        };

        pub const zero = Constraint{
            .next = null,
            .kind = .true,
        };
    };

    pub fn is_valid(schema: *const Schema, input: str8) bool {
        var arena_state = Arena.init(.{}) catch unreachable;
        defer arena_state.deinit();
        const arena = arena_state.allocator();
        var json = std.json.parseFromSlice(std.json.Value, arena, input, .{
            .allocate = .alloc_if_needed,
            .parse_numbers = true,
            .ignore_unknown_fields = false,
            .duplicate_field_behavior = .use_last,
            .max_value_len = std.json.default_max_value_len,
        }) catch unreachable; // todo: error
        // todo: oom error
        return check(&arena_state, schema.root, &json.value) catch unreachable;
    }
};

fn check(arena: *Arena, constraint: *const Schema.Constraint, value: *std.json.Value) !bool {
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
        .@"const" => |value_hash| {
            // perf: check type then hash
            // todo: make pr to zig to have .hash_value() work here
            const input_hash = ValueHash.hash_value(value);
            return value_hash == input_hash;
        },
        .@"enum" => |hashes| {
            // perf: check type then hash
            for (hashes) |hash| {
                if (hash == ValueHash.hash_value(value)) return true;
            }
            return false;
        },
        .unique_items => {
            if (value.* != .array) {
                return true;
            }
            const scratch = Arena.get_scratch(&.{arena});
            defer scratch.release();
            var hashes: std.AutoHashMapUnmanaged(ValueHash, void) = .empty;
            defer hashes.deinit(scratch.arena.allocator());
            try hashes.ensureTotalCapacity(scratch.arena.allocator(), @intCast(value.array.items.len));
            for (value.array.items) |*item| {
                if (try hashes.fetchPut(scratch.arena.allocator(), .hash_value(item), {})) |_| {
                    return false;
                }
            }
            return true;
        },
        .items => |item_sub_schema| {
            if (value.* != .array) {
                return true;
            }

            for (value.array.items) |*item| {
                if (!try check(arena, item_sub_schema, item)) return false;
            }
            return true;
        },
        .tuple_items => |tuple_info| {
            const ti = tuple_info orelse return true;
            if (value.* != .array) {
                return true;
            }

            // Validate each array item against its corresponding schema
            for (value.array.items, 0..) |*item, i| {
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
            return value.* != .string or (std.unicode.utf8CountCodepoints(value.string) catch 0) >= min_len;
        },
        .max_len => |max_len| {
            return value.* != .string or (std.unicode.utf8CountCodepoints(value.string) catch 0) <= max_len;
        },
        .max_items => |max_items| {
            return value.* != .array or value.array.items.len <= max_items;
        },
        .min_items => |min_items| {
            return value.* != .array or value.array.items.len >= min_items;
        },
        .max_properties => |max_properties| {
            return value.* != .object or value.object.count() <= max_properties;
        },
        .min_properties => |min_properties| {
            return value.* != .object or value.object.count() >= min_properties;
        },
        .max_i64 => |max_int| {
            return switch (value.*) {
                .integer => |int_val| int_val <= max_int,
                .float => |float_val| float_val <= @as(f64, @floatFromInt(max_int)),
                .number_string => true, // todo: handle?
                else => true,
            };
        },
        .min_i64 => |min_int| {
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
        .max_i64_exclusive => |max_int| {
            return switch (value.*) {
                .integer => |int_val| int_val < max_int,
                .float => |float_val| float_val < @as(f64, @floatFromInt(max_int)),
                .number_string => true, // todo: handle?
                else => true,
            };
        },
        .min_i64_exclusive => |min_int| {
            return switch (value.*) {
                .integer => |int_val| int_val > min_int,
                .float => |float_val| float_val > @as(f64, @floatFromInt(min_int)),
                .number_string => true, // todo: handle?
                else => true,
            };
        },
        .max_f64_exclusive => |max_f64| {
            return switch (value.*) {
                .integer => |int_val| @as(f64, @floatFromInt(int_val)) < max_f64,
                .float => |float_val| float_val < max_f64,
                .number_string => true, // todo: handle?
                else => true,
            };
        },
        .min_f64_exclusive => |min_f64| {
            return switch (value.*) {
                .integer => |int_val| @as(f64, @floatFromInt(int_val)) > min_f64,
                .float => |float_val| float_val > min_f64,
                .number_string => true, // todo: handle?
                else => true,
            };
        },
        .properties => |properties| {
            if (value.* != .object) {
                return true;
            }
            const scratch = Arena.get_scratch(&.{arena});
            defer scratch.release();
            var current_property = properties.first_property;
            var checked_properties: std.StringArrayHashMapUnmanaged(void) = .empty;
            defer checked_properties.deinit(scratch.arena.allocator());
            while (current_property) |property_constraint| : (current_property = property_constraint.next) {
                const sub_value = value.object.getPtr(property_constraint.kind.property.name) orelse continue;
                try checked_properties.put(scratch.arena.allocator(), property_constraint.kind.property.name, {});
                if (!try check(arena, property_constraint.kind.property.constraint, sub_value)) {
                    return false;
                }
            }
            // Check all properties against patternProperties and additionalProperties
            var obj_iter = value.object.iterator();
            while (obj_iter.next()) |entry| {
                // Check if property matches any patternProperties (applies to ALL properties)
                var matched_pattern = false;
                for (properties.pattern_properties) |pattern_prop| {
                    const matches = try pattern_prop.pattern.matches(entry.key_ptr.*, .{});
                    if (matches != null) {
                        matched_pattern = true;
                        // Validate against the pattern's constraint
                        if (!try check(arena, pattern_prop.constraint, entry.value_ptr)) {
                            return false;
                        }
                    }
                }

                // Only check additionalProperties if not in properties AND no pattern matched
                if (!checked_properties.contains(entry.key_ptr.*) and !matched_pattern) {
                    if (!try check(arena, properties.additional, entry.value_ptr)) return false;
                }
            }
            return true;
        },
        .property => unreachable,
        .required => |required_property_hashes| {
            if (value.* != .object) {
                return true;
            }

            for (required_property_hashes) |required_property_hash| {
                // perf: should be improved
                for (value.object.keys()) |key| {
                    const key_hash = ValueHash.hash_value(@constCast(@as(*const std.json.Value, &.{ .string = key })));
                    if (key_hash == required_property_hash) break;
                } else return false;
            }
            return true;
        },
        .not => |constraint_to_invert| {
            return !try check(arena, constraint_to_invert, value);
        },
        .multiple_of_f64 => |multiple_of| {
            if (multiple_of == 0.0) return false;
            const float_val = switch (value.*) {
                .integer => |int_val| @as(f64, @floatFromInt(int_val)),
                .float => |float_val| float_val,
                .number_string => 0.0, // todo: handle?
                else => 0.0,
            };
            // Check if value/multiple_of is close to an integer to handle floating-point precision
            const quotient = float_val / multiple_of;
            const diff = @abs(quotient - @round(quotient));
            return diff < 1e-9;
        },
        .multiple_of_i64 => |multiple_of| {
            if (multiple_of == 0) return false;
            const int_val = switch (value.*) {
                .integer => |int_val| int_val,
                .float => |float_val| float_as_int(float_val) orelse return false,
                .number_string => 0,
                else => 0,
            };
            return @rem(int_val, multiple_of) == 0;
        },
        .pattern => |regex| {
            if (value.* != .string) return true;
            const matches = try regex.matches(value.string, .{});
            return matches != null;
        },
        .ref => |referenced_constraint| {
            return check(arena, referenced_constraint, value);
        },
    }
}

pub fn parse(schema_contents: str8) !Schema {
    return parse_with_revision(schema_contents, null);
}

pub fn parse_with_revision(schema_contents: str8, revision: ?Revision) !Schema {
    var usage_arena = try Arena.init(.{});
    errdefer usage_arena.deinit();

    var parse_arena = try Arena.init(.{});
    defer parse_arena.deinit();

    const parsed_schema = try std.json.parseFromSlice(std.json.Value, parse_arena.allocator(), schema_contents, .{
        .allocate = .alloc_if_needed,
        .parse_numbers = true,
        .ignore_unknown_fields = false,
        .duplicate_field_behavior = .use_last,
        .max_value_len = 1024,
    });
    var ctx: ParseContext = .{
        .revision = revision orelse Revision.detect(parsed_schema.value),
        .usage_arena = &usage_arena,
        .parse_arena = &parse_arena,
    };

    // Phase 1: Collect and pre-allocate definitions
    ctx.defs = if (parsed_schema.value == .object) blk: {
        const defs_obj = parsed_schema.value.object.get("$defs") orelse
            parsed_schema.value.object.get("definitions");
        if (defs_obj == null or defs_obj.? != .object) break :blk &.{};
        const d = defs_obj.?.object;
        const slice = try usage_arena.alloc(Schema.Definition, d.count());
        for (slice, d.keys()) |*def, key| {
            const stub = try usage_arena.create(Schema.Constraint);
            stub.* = Schema.Constraint.zero;
            def.* = .{ .path = key, .constraint = stub };
        }
        mem.sort(Schema.Definition, slice, {}, Schema.Definition.lessThan);
        break :blk slice;
    } else &.{};

    // Phase 2: Parse each definition into its pre-allocated stub
    if (parsed_schema.value == .object) {
        const defs_obj = parsed_schema.value.object.get("$defs") orelse
            parsed_schema.value.object.get("definitions");
        if (defs_obj != null and defs_obj.? == .object) {
            const d = defs_obj.?.object;
            for (d.keys(), d.values()) |key, def_value| {
                const def = find_def(ctx.defs, key) orelse continue;
                try parse_into_constraint(&ctx, def_value, def);
            }
        }
    }

    // Phase 3: Parse the root schema
    const root = try parse_constraint(&ctx, parsed_schema.value);
    return Schema{
        .root = root,
        .arena = usage_arena,
    };
}

fn find_def(defs: []const Schema.Definition, path: str8) ?*Schema.Constraint {
    var left: usize = 0;
    var right: usize = defs.len;
    while (left < right) {
        const mid = left + (right - left) / 2;
        const cmp = mem.order(u8, defs[mid].path, path);
        switch (cmp) {
            .lt => left = mid + 1,
            .gt => right = mid,
            .eq => return defs[mid].constraint,
        }
    }
    return null;
}

fn parse_local_def_ref(ref: str8) ?str8 {
    if (mem.startsWith(u8, ref, "#/$defs/")) {
        return ref["#/$defs/".len..];
    } else if (mem.startsWith(u8, ref, "#/definitions/")) {
        return ref["#/definitions/".len..];
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
fn unescape_json_pointer(ctx: *ParseContext, escaped: str8) OOM!str8 {
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

    const result = try ctx.usage_arena.alloc(u8, result_len);
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
    revision: Revision,
    defs: []const Schema.Definition = &.{},
    usage_arena: *Arena,
    parse_arena: *Arena,
};

fn parse_into_constraint(ctx: *ParseContext, schema: std.json.Value, constraint: *Schema.Constraint) ParseError!void {
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
            // Handle $ref first (in draft4-7, $ref overrides siblings)
            if (obj.get("$ref")) |ref_val| {
                if (ref_val == .string) {
                    if (parse_local_def_ref(ref_val.string)) |name| {
                        const unescaped_name = try unescape_json_pointer(ctx, name);
                        if (find_def(ctx.defs, unescaped_name)) |target| {
                            constraint.kind = .{ .ref = target };
                            // In draft4-7, $ref overrides all siblings, so return early
                            if (ctx.revision != .draft2019_09 and ctx.revision != .draft2020_12 and ctx.revision != .draft_next) {
                                return;
                            }
                            // In 2019-09+, $ref can combine with siblings, so chain it
                            try chain_with(ctx, constraint, .{ .ref = target });
                        }
                    }
                }
            }
            // todo: error
            if (parse_validation__type(ctx, &obj) catch null) |v_types| {
                try chain_with(ctx, constraint, .{ .type = v_types });
            }
            if (parse_validation__min_length(&obj)) |min_length| {
                try chain_with(ctx, constraint, .{ .min_len = min_length });
            }
            if (parse_validation__max_length(&obj)) |max_length| {
                try chain_with(ctx, constraint, .{ .max_len = max_length });
            }
            if (parse_validation__min(&obj)) |min| {
                try chain_with(ctx, constraint, min);
            }
            if (parse_validation__max(&obj)) |max| {
                try chain_with(ctx, constraint, max);
            }
            if (parse_validation__exclusive_min(&obj)) |exclusive_min| {
                try chain_with(ctx, constraint, exclusive_min);
            }
            if (parse_validation__exclusive_max(&obj)) |exclusive_max| {
                try chain_with(ctx, constraint, exclusive_max);
            }
            if (parse_validation__min_items(&obj)) |min_items| {
                try chain_with(ctx, constraint, min_items);
            }
            if (parse_validation__max_items(&obj)) |max_items| {
                try chain_with(ctx, constraint, max_items);
            }
            if (parse_validation__min_properties(&obj)) |min_properties| {
                try chain_with(ctx, constraint, min_properties);
            }
            if (parse_validation__max_properties(&obj)) |max_properties| {
                try chain_with(ctx, constraint, max_properties);
            }
            if (parse_validation__const(&obj)) |@"const"| {
                try chain_with(ctx, constraint, @"const");
            }
            if (parse_validation__enum(ctx, &obj) catch null) |@"enum"| {
                try chain_with(ctx, constraint, @"enum");
            }
            if (parse_validation__unique_items(&obj)) |unique_items| {
                try chain_with(ctx, constraint, unique_items);
            }
            if (parse_applicitor__items(ctx, &obj) catch null) |items| {
                try chain_with(ctx, constraint, items);
            }
            if (parse_applicitor__properties(ctx, &obj) catch null) |properties| {
                try chain_with(ctx, constraint, properties);
            }
            if (parse_validation__required_properties(ctx, &obj) catch null) |required_properties| {
                try chain_with(ctx, constraint, required_properties);
            }
            if (parse_applicator_not(ctx, &obj) catch null) |not| {
                try chain_with(ctx, constraint, not);
            }
            if (parse_applicitor__all_of(ctx, &obj) catch null) |all| {
                try chain_with(ctx, constraint, all);
            }
            if (parse_applicitor__any_of(ctx, &obj) catch null) |all| {
                try chain_with(ctx, constraint, all);
            }
            if (parse_applicitor__one_of(ctx, &obj) catch null) |all| {
                try chain_with(ctx, constraint, all);
            }
            if (parse_validation__multiple_of(&obj)) |multiple_of| {
                try chain_with(ctx, constraint, multiple_of);
            }
            if (parse_validation__pattern(ctx, &obj) catch null) |pattern| {
                try chain_with(ctx, constraint, pattern);
            }
        },
        else => return error.UnrecognizedSchemaType,
    }
}

fn parse_constraint(ctx: *ParseContext, schema: std.json.Value) ParseError!*Schema.Constraint {
    const constraint = try ctx.usage_arena.create(Schema.Constraint);
    try parse_into_constraint(ctx, schema, constraint);
    return constraint;
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

const ValueHash = packed struct(u68) {
    kind: u4,
    hash: u64,

    fn hash_value(json_value: *std.json.Value) ValueHash {
        var hasher = std.hash.Wyhash.init(0xdeadbeef);
        var fake_float_value: ?std.json.Value = null;
        if (json_value.* == .integer) {
            fake_float_value = .{ .float = @floatFromInt(json_value.integer) };
        }
        const value = if (fake_float_value) |*ffv| ffv else json_value;

        return .{
            .kind = @intCast(@intFromEnum(value.*)),
            .hash = top_level_value_hash(&hasher, value),
        };
    }

    fn top_level_value_hash(hasher: *std.hash.Wyhash, value: *std.json.Value) u64 {
        switch (value.*) {
            .null => return 0,
            .bool => |val| return @intCast(@intFromBool(val)),
            .integer => |val| return @bitCast(@as(f64, @floatFromInt(val))),
            .float => |val| return @bitCast(val),
            .number_string => |val| hasher.update(val),
            .string => |val| hasher.update(val),
            .array => {
                hash_inner(hasher, value);
            },
            .object => {
                hash_inner(hasher, value);
            },
        }
        return hasher.final();
    }

    fn hash_inner(hasher: *std.hash.Wyhash, value: *std.json.Value) void {
        switch (value.*) {
            .null => {
                hasher.update(&[_]u8{0});
            },
            .bool => |val| {
                hasher.update(&[_]u8{ 1, @intFromBool(val) });
            },
            .integer => |val| {
                const float_val: f64 = @floatFromInt(val);
                hasher.update(&[_]u8{2});
                hasher.update(mem.asBytes(&float_val));
            },
            .float => |val| {
                hasher.update(&[_]u8{2});
                hasher.update(mem.asBytes(&val));
            },
            .number_string => |val| {
                hasher.update(&[_]u8{3});
                hasher.update(val);
            },
            .string => |val| {
                hasher.update(&[_]u8{4});
                hasher.update(val);
            },
            .array => |val| {
                hasher.update(&[_]u8{5});
                for (val.items) |*item| {
                    hash_inner(hasher, item);
                }
            },
            .object => |val| {
                hasher.update(&[_]u8{6});
                const keys = val.keys();
                const values = val.values();
                const n = keys.len;

                // Use scratch arena for temporary allocation
                const scratch = Arena.get_scratch(&.{});
                defer scratch.release();

                // Create temporary array of indices and sort by key
                const indices = scratch.arena.allocator().alloc(usize, n) catch {
                    // Fallback: hash without sorting (produces consistent but order-dependent hash)
                    for (keys, values) |key, *v| {
                        hasher.update(key);
                        hash_inner(hasher, v);
                    }
                    return;
                };
                for (indices, 0..) |*idx, i| {
                    idx.* = i;
                }

                // Sort indices by key
                mem.sort(usize, indices, keys, struct {
                    pub fn lessThan(k: []const []const u8, a: usize, b: usize) bool {
                        return mem.lessThan(u8, k[a], k[b]);
                    }
                }.lessThan);

                // Hash in sorted order without mutating original
                for (indices) |idx| {
                    hasher.update(keys[idx]);
                    hash_inner(hasher, @constCast(&values[idx]));
                }
            },
        }
    }
};

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

fn parse_validation__type(ctx: *ParseContext, obj: *const std.json.ObjectMap) !?[]ValidationType {
    const ty = obj.get("type") orelse return null;
    switch (ty) {
        .string => |v_type_str| {
            const v_type = try ctx.usage_arena.create(ValidationType);
            // todo: error
            v_type.* = ValidationType.Map.get(v_type_str) orelse return null;
            return v_type[0..1];
        },
        .array => |arr| {
            var v_types: base.ArenaList(ValidationType) = try .init_capacity(ctx.usage_arena, arr.items.len);
            for (arr.items) |v_type_str| {
                if (v_type_str != .string) {
                    // todo: error
                    continue;
                }
                const v_type = ValidationType.Map.get(v_type_str.string) orelse continue;
                v_types.append_assume_capacity(v_type);
            }
            return v_types.items;
        },
        else => return null,
    }
}

/// https://www.learnjsonschema.com/2020-12/validation/minlength/
fn parse_validation__min_length(obj: *const std.json.ObjectMap) ?u64 {
    const min_len = obj.get("minLength") orelse return null;
    switch (min_len) {
        .integer => |int_val| {
            return std.math.lossyCast(u64, int_val);
        },
        else => return null,
    }
}

/// https://www.learnjsonschema.com/2020-12/validation/maxlength/
fn parse_validation__max_length(obj: *const std.json.ObjectMap) ?u64 {
    const min_len = obj.get("maxLength") orelse return null;
    switch (min_len) {
        .integer => |int_val| {
            return std.math.lossyCast(u64, int_val);
        },
        else => return null,
    }
}

/// https://www.learnjsonschema.com/2020-12/validation/minimum/
fn parse_validation__min(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const min_val = obj.get("minimum") orelse return null;
    switch (min_val) {
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
fn parse_validation__max(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const max_val = obj.get("maximum") orelse return null;
    switch (max_val) {
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
fn parse_validation__exclusive_min(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const min_val = obj.get("exclusiveMinimum") orelse return null;
    switch (min_val) {
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
fn parse_validation__exclusive_max(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const max_val = obj.get("exclusiveMaximum") orelse return null;
    switch (max_val) {
        .integer => |int_val| {
            return .{ .max_i64_exclusive = int_val };
        },
        .float => |float_val| {
            return .{ .max_f64_exclusive = float_val };
        },
        else => return null,
    }
}

fn parse_validation__min_items(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const min_items = obj.get("minItems") orelse return null;
    switch (min_items) {
        .integer => |int_val| {
            return .{ .min_items = std.math.lossyCast(u64, int_val) };
        },
        .float => |flt_val| {
            return .{ .min_items = std.math.lossyCast(u64, flt_val) };
        },
        else => return null,
    }
}

fn parse_validation__max_items(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const max_items = obj.get("maxItems") orelse return null;
    switch (max_items) {
        .integer => |int_val| {
            return .{ .max_items = std.math.lossyCast(u64, int_val) };
        },
        .float => |flt_val| {
            return .{ .max_items = std.math.lossyCast(u64, flt_val) };
        },
        else => return null,
    }
}

fn parse_validation__min_properties(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const min_properties = obj.get("minProperties") orelse return null;
    switch (min_properties) {
        .integer => |int_val| {
            return .{ .min_properties = std.math.lossyCast(u64, int_val) };
        },
        .float => |flt_val| {
            return .{ .min_properties = std.math.lossyCast(u64, flt_val) };
        },
        else => return null,
    }
}

fn parse_validation__max_properties(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const max_properties = obj.get("maxProperties") orelse return null;
    switch (max_properties) {
        .integer => |int_val| {
            return .{ .max_properties = std.math.lossyCast(u64, int_val) };
        },
        .float => |flt_val| {
            return .{ .max_properties = std.math.lossyCast(u64, flt_val) };
        },
        else => return null,
    }
}

fn parse_validation__const(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const value = obj.getPtr("const") orelse return null;
    return .{ .@"const" = .hash_value(value) };
}

fn parse_validation__enum(ctx: *ParseContext, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const value = obj.get("enum") orelse return null;
    if (value != .array) {
        return .{ .@"enum" = &.{} };
    }
    var hashes: base.ArenaList(ValueHash) = try .init_capacity(ctx.usage_arena, value.array.items.len);
    for (value.array.items) |*item| {
        hashes.append_assume_capacity(.hash_value(item));
    }
    return .{
        .@"enum" = hashes.items,
    };
}

fn parse_validation__unique_items(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const unique_items = obj.get("uniqueItems") orelse return null;
    // todo: how to handle
    if (unique_items != .bool or !unique_items.bool) return null;
    return .unique_items;
}

fn parse_applicitor__items(ctx: *ParseContext, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const items_sub_schema = obj.get("items") orelse return null;
    // items can be either a single schema (applies to all items) or an array of schemas (tuple validation)
    if (items_sub_schema == .array) {
        const item_schemas = try ctx.usage_arena.alloc(*Schema.Constraint, items_sub_schema.array.items.len);
        for (items_sub_schema.array.items, 0..) |item_schema, i| {
            item_schemas[i] = try parse_constraint(ctx, item_schema);
        }
        // Parse additionalItems
        const additional_items: ?*Schema.Constraint = blk: {
            const additional_items_value = obj.get("additionalItems") orelse break :blk null;
            break :blk try parse_constraint(ctx, additional_items_value);
        };
        return .{ .tuple_items = .{
            .items = item_schemas,
            .additional_items = additional_items,
        } };
    }
    return .{ .items = try parse_constraint(ctx, items_sub_schema) };
}

fn parse_applicitor__properties(ctx: *ParseContext, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const properties_value = obj.get("properties");
    const pattern_properties_value = obj.get("patternProperties");
    const additional_properties_value = obj.get("additionalProperties");

    // Return null if none of the three property-related keywords are present
    if (properties_value == null and pattern_properties_value == null and additional_properties_value == null) {
        return null;
    }

    // Parse properties
    var first_property: ?*Schema.Constraint = null;
    if (properties_value) |props| {
        if (props == .object) {
            var property_iter = props.object.iterator();
            var property_constraints = try ctx.usage_arena.alloc(Schema.Constraint, props.object.count());
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
        if (pattern_props == .object) {
            var pattern_property_list = try ctx.usage_arena.alloc(PatternProperty, pattern_props.object.count());
            var pattern_iter = pattern_props.object.iterator();
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

fn parse_validation__required_properties(ctx: *ParseContext, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    if (ctx.revision == .draft3) {
        // Draft3 style: "required": true inside each property definition
        const properties_value = obj.get("properties") orelse return null;
        if (properties_value != .object) return null;

        var required_properties: base.ArenaList(ValueHash) = .empty;
        var property_iter = properties_value.object.iterator();
        while (property_iter.next()) |entry| {
            if (entry.value_ptr.* != .object) continue;
            const required_field = entry.value_ptr.object.get("required") orelse continue;
            if (required_field != .bool) continue;
            if (required_field.bool) {
                const name_value: std.json.Value = .{ .string = entry.key_ptr.* };
                try required_properties.append(ctx.usage_arena, .hash_value(@constCast(&name_value)));
            }
        }

        if (required_properties.items.len == 0) return null;
        return .{
            .required = required_properties.items,
        };
    }

    // Draft4+ style: "required" is an array of property names at the object level
    const required_properties_value = obj.get("required") orelse return null;
    if (required_properties_value != .array) return null;

    var required_properties = try base.ArenaList(ValueHash).init_capacity(ctx.usage_arena, required_properties_value.array.items.len);
    for (required_properties_value.array.items) |required_property| {
        if (required_property != .string) continue;
        required_properties.append_assume_capacity(.hash_value(@constCast(&required_property)));
    }
    if (required_properties.items.len == 0) return null;
    return .{
        .required = required_properties.items,
    };
}

fn parse_applicator_not(ctx: *ParseContext, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const sub_schema = obj.get("not") orelse return null;
    return .{
        .not = try parse_constraint(ctx, sub_schema),
    };
}

fn parse_applicitor__all_of(ctx: *ParseContext, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const items = obj.get("allOf") orelse return null;
    if (items != .array) return null;
    var all_of_constraint = Schema.Constraint.Kind{
        .all = null,
    };
    var prev_next_ptr = &all_of_constraint.all;
    for (items.array.items) |item| {
        const sub_schema = try parse_constraint(ctx, item);
        prev_next_ptr.* = sub_schema;
        prev_next_ptr = &sub_schema.next;
    }
    return all_of_constraint;
}

fn parse_applicitor__any_of(ctx: *ParseContext, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const items = obj.get("anyOf") orelse return null;
    if (items != .array) return null;
    var any_of_constraint = Schema.Constraint.Kind{
        .any = null,
    };
    var prev_next_ptr = &any_of_constraint.any;
    for (items.array.items) |item| {
        const sub_schema = try parse_constraint(ctx, item);
        prev_next_ptr.* = sub_schema;
        prev_next_ptr = &sub_schema.next;
    }
    return any_of_constraint;
}

fn parse_applicitor__one_of(ctx: *ParseContext, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const items = obj.get("oneOf") orelse return null;
    if (items != .array) return null;
    var one_of_constraint = Schema.Constraint.Kind{
        .one = null,
    };
    var prev_next_ptr = &one_of_constraint.one;
    for (items.array.items) |item| {
        const sub_schema = try parse_constraint(ctx, item);
        prev_next_ptr.* = sub_schema;
        prev_next_ptr = &sub_schema.next;
    }
    return one_of_constraint;
}

fn parse_validation__multiple_of(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const multiple_of = obj.get("multipleOf") orelse return null;
    return switch (multiple_of) {
        .float => |float_val| .{ .multiple_of_f64 = float_val },
        .integer => |int_val| .{ .multiple_of_i64 = int_val },
        else => null,
    };
}

fn parse_validation__pattern(ctx: *ParseContext, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const pattern = obj.get("pattern") orelse return null;
    if (pattern != .string) return null;

    const pattern_c = try ctx.usage_arena.allocator().dupeZ(u8, pattern.string);
    const re = try pcre.Regex.compile(pattern_c, .{
        .Dotall = true,
        .JavascriptCompat = true,
        .Utf8 = true,
    });

    return .{
        .pattern = re,
    };
}

fn float_as_int(float: f64) ?i64 {
    if (@trunc(float) != float) return null;
    const min_int: f64 = @floatFromInt(std.math.minInt(i64));
    const max_int: f64 = @floatFromInt(std.math.maxInt(i64));
    if (std.math.clamp(float, min_int, max_int) != float) return null;
    return @intFromFloat(float);
}

test ValueHash {
    const H = ValueHash;
    const util = struct {
        fn parse_value(arena: *Arena, json: str8) !std.json.Value {
            const parsed = try std.json.parseFromSlice(std.json.Value, arena.allocator(), json, .{
                .allocate = .alloc_if_needed,
                .parse_numbers = true,
                .ignore_unknown_fields = false,
                .duplicate_field_behavior = .use_last,
                .max_value_len = 1024,
            });
            return parsed.value;
        }

        fn expect_hash_match(json: str8) !void {
            var tmp = Arena.get_scratch(&.{});
            defer tmp.release();

            var value_a = try parse_value(tmp.arena, json);
            var value_b = try parse_value(tmp.arena, json);

            const hash_a: H = .hash_value(&value_a);
            const hash_b: H = .hash_value(&value_b);
            try std.testing.expectEqual(hash_a, hash_b);
        }

        fn expect_hashes_match(left: str8, right: str8) !void {
            var tmp = Arena.get_scratch(&.{});
            defer tmp.release();

            var value_a = try parse_value(tmp.arena, left);
            var value_b = try parse_value(tmp.arena, right);

            const hash_a: H = .hash_value(&value_a);
            const hash_b: H = .hash_value(&value_b);
            try std.testing.expectEqual(hash_a, hash_b);
        }

        fn expect_hash_mismatch(left: str8, right: str8) !void {
            var tmp = Arena.get_scratch(&.{});
            defer tmp.release();

            var value_a = try parse_value(tmp.arena, left);
            var value_b = try parse_value(tmp.arena, right);

            const hash_a: H = .hash_value(&value_a);
            const hash_b: H = .hash_value(&value_b);
            try std.testing.expect(hash_a != hash_b);
        }
    };

    try util.expect_hash_match(
        \\null
        \\
    );
    try util.expect_hash_match(
        \\true
        \\
    );
    try util.expect_hash_match(
        \\false
        \\
    );
    try util.expect_hash_match(
        \\0
        \\
    );
    try util.expect_hash_match(
        \\12345
        \\
    );
    try util.expect_hash_match(
        \\-9876
        \\
    );
    try util.expect_hash_match(
        \\3.14159
        \\
    );
    try util.expect_hash_match(
        \\"hello"
        \\
    );
    try util.expect_hash_match(
        \\"escaped \\\"quotes\\\" and \\n newlines"
        \\
    );
    try util.expect_hash_match(
        \\[1, 2, 3, 4]
        \\
    );
    try util.expect_hash_match(
        \\[
        \\  "alpha",
        \\  "beta",
        \\  "gamma"
        \\]
        \\
    );
    try util.expect_hash_match(
        \\{
        \\  "a": 1,
        \\  "b": 2,
        \\  "c": 3
        \\}
        \\
    );
    try util.expect_hashes_match(
        \\{
        \\  "a": 1,
        \\  "b": 2,
        \\  "c": 3
        \\}
        \\
    ,
        \\{
        \\  "c": 3,
        \\  "b": 2,
        \\  "a": 1
        \\}
        \\
    );
    try util.expect_hash_match(
        \\{
        \\  "nested": {
        \\    "list": [1, 2, 3],
        \\    "flag": true,
        \\    "value": 42
        \\  },
        \\  "name": "example"
        \\}
        \\
    );
    try util.expect_hashes_match(
        \\{
        \\  "outer": {
        \\    "x": 1,
        \\    "y": 2
        \\  },
        \\  "z": 3
        \\}
        \\
    ,
        \\{
        \\  "z": 3,
        \\  "outer": {
        \\    "y": 2,
        \\    "x": 1
        \\  }
        \\}
        \\
    );
    try util.expect_hash_match(
        \\{
        \\  "mixed": [null, true, false, 0, 1.5, "text"]
        \\}
        \\
    );

    try util.expect_hash_mismatch(
        \\null
        \\
    ,
        \\false
        \\
    );
    try util.expect_hash_mismatch(
        \\0
        \\
    ,
        \\1
        \\
    );
    try util.expect_hash_mismatch(
        \\1
        \\
    ,
        \\1.5
        \\
    );
    try util.expect_hash_mismatch(
        \\"a"
        \\
    ,
        \\"b"
        \\
    );
    try util.expect_hash_mismatch(
        \\[]
        \\
    ,
        \\{}
        \\
    );
    try util.expect_hash_mismatch(
        \\[1, 2, 3]
        \\
    ,
        \\[3, 2, 1]
        \\
    );
    try util.expect_hash_mismatch(
        \\{
        \\  "a": 1
        \\}
        \\
    ,
        \\{
        \\  "a": 2
        \\}
        \\
    );
    try util.expect_hash_mismatch(
        \\{
        \\  "a": 1,
        \\  "b": 2
        \\}
        \\
    ,
        \\{
        \\  "a": 1,
        \\  "b": 2,
        \\  "c": 3
        \\}
        \\
    );
    try util.expect_hash_mismatch(
        \\{
        \\  "nested": {
        \\    "x": 1,
        \\    "y": 2
        \\  }
        \\}
        \\
    ,
        \\{
        \\  "nested": {
        \\    "x": 1,
        \\    "y": 3
        \\  }
        \\}
        \\
    );
    try util.expect_hash_mismatch(
        \\true
        \\
    ,
        \\1
        \\
    );
    try util.expect_hash_mismatch(
        \\false
        \\
    ,
        \\0
        \\
    );
    try util.expect_hash_mismatch(
        \\[false]
        \\
    ,
        \\[0]
        \\
    );
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
