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
const Arena = std.heap.ArenaAllocator;

const str8 = []const u8;
pub const OOM = error{OutOfMemory};

const pcre = @import("pcre");

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
            items: *Constraint,
            properties: struct {
                first_property: ?*Constraint,
                additional: *Constraint,
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
        };

        pub const zero = Constraint{
            .next = null,
            .kind = .true,
        };
    };

    pub fn is_valid(schema: *const Schema, input: str8) bool {
        var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
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
            return value_hash == ValueHash.hash_value(value);
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
            var hashes: std.AutoHashMapUnmanaged(ValueHash, void) = .empty;
            defer hashes.deinit(arena.allocator());
            try hashes.ensureTotalCapacity(arena.allocator(), @intCast(value.array.items.len));
            for (value.array.items) |*item| {
                if (try hashes.fetchPut(arena.allocator(), .hash_value(item), {})) |_| {
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
            var current_property = properties.first_property;
            var checked_properties: std.StringArrayHashMapUnmanaged(void) = .empty;
            while (current_property) |property_constraint| : (current_property = property_constraint.next) {
                const sub_value = value.object.getPtr(property_constraint.kind.property.name) orelse continue;
                try checked_properties.put(arena.allocator(), property_constraint.kind.property.name, {});
                if (!try check(arena, property_constraint.kind.property.constraint, sub_value)) {
                    return false;
                }
            }
            var obj_iter = value.object.iterator();
            while (obj_iter.next()) |entry| {
                if (checked_properties.contains(entry.key_ptr.*)) continue;
                if (!try check(arena, properties.additional, entry.value_ptr)) return false;
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
            return @rem(float_val, multiple_of) <= std.math.floatEps(f64);
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

const ParseError = OOM || error{UnrecognizedSchemaType};

fn parse_constraint(arena: *Arena, schema: std.json.Value) ParseError!*Schema.Constraint {
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
            if (parse_validation__exclusive_min(&obj)) |exclusive_min| {
                try chain_with(arena, constraint, exclusive_min);
            }
            if (parse_validation__exclusive_max(&obj)) |exclusive_max| {
                try chain_with(arena, constraint, exclusive_max);
            }
            if (parse_validation__min_items(&obj)) |min_items| {
                try chain_with(arena, constraint, min_items);
            }
            if (parse_validation__max_items(&obj)) |max_items| {
                try chain_with(arena, constraint, max_items);
            }
            if (parse_validation__const(&obj)) |@"const"| {
                try chain_with(arena, constraint, @"const");
            }
            if (parse_validation__enum(arena, &obj) catch null) |@"enum"| {
                try chain_with(arena, constraint, @"enum");
            }
            if (parse_validation__unique_items(&obj)) |unique_items| {
                try chain_with(arena, constraint, unique_items);
            }
            if (parse_applicitor__items(arena, &obj) catch null) |items| {
                try chain_with(arena, constraint, items);
            }
            if (parse_applicitor__properties(arena, &obj) catch null) |properties| {
                try chain_with(arena, constraint, properties);
            }
            if (parse_validation__required_properties(arena, &obj) catch null) |required_properties| {
                try chain_with(arena, constraint, required_properties);
            }
            if (parse_applicator_not(arena, &obj) catch null) |not| {
                try chain_with(arena, constraint, not);
            }
            if (parse_applicitor__all_of(arena, &obj) catch null) |all| {
                try chain_with(arena, constraint, all);
            }
            if (parse_applicitor__any_of(arena, &obj) catch null) |all| {
                try chain_with(arena, constraint, all);
            }
            if (parse_applicitor__one_of(arena, &obj) catch null) |all| {
                try chain_with(arena, constraint, all);
            }
            if (parse_validation__multiple_of(&obj)) |multiple_of| {
                try chain_with(arena, constraint, multiple_of);
            }
            if (parse_validation__pattern(arena, &obj) catch null) |pattern| {
                try chain_with(arena, constraint, pattern);
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
        new.next = from.kind.all;
        new.kind = new_kind;
        from.kind.all = new;
    } else if (from.kind != .true) {
        // turn from into chain of length two with it's current constraint and the new constraint
        var constraints = try arena.allocator().alloc(Schema.Constraint, 2);
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
            .null, .bool, .integer, .float => {
                const primitive_value_hash = hash_value(value);
                hasher.update(mem.asBytes(&primitive_value_hash));
            },
            .number_string => |val| hasher.update(val),
            .string => |val| hasher.update(val),
            .array => |val| {
                for (val.items) |*item| {
                    hash_inner(hasher, item);
                }
            },
            .object => |*val| {
                val.sort(struct {
                    val: @TypeOf(val),
                    pub fn lessThan(ctx: @This(), a: usize, b: usize) bool {
                        const keys = ctx.val.keys();
                        return mem.lessThan(u8, keys[a], keys[b]);
                    }
                }{ .val = val });
                var iter = val.iterator();
                while (iter.next()) |entry| {
                    hasher.update(entry.key_ptr.*);
                    hash_inner(hasher, entry.value_ptr);
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

fn parse_validation__const(obj: *const std.json.ObjectMap) ?Schema.Constraint.Kind {
    const value = obj.getPtr("const") orelse return null;
    return .{ .@"const" = .hash_value(value) };
}

fn parse_validation__enum(arena: *Arena, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const value = obj.get("enum") orelse return null;
    if (value != .array) {
        return .{ .@"enum" = &.{} };
    }
    var hashes: std.ArrayList(ValueHash) = try .initCapacity(arena.allocator(), value.array.items.len);
    for (value.array.items) |*item| {
        hashes.appendAssumeCapacity(.hash_value(item));
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

fn parse_applicitor__items(arena: *Arena, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const items_sub_schema = obj.get("items") orelse return null;
    return .{ .items = try parse_constraint(arena, items_sub_schema) };
}

fn parse_applicitor__properties(arena: *Arena, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const properties_value = obj.get("properties") orelse return null;
    if (properties_value != .object) return null;
    var property_iter = properties_value.object.iterator();
    var property_constraints = try arena.allocator().alloc(Schema.Constraint, properties_value.object.count());
    var index: u64 = 0;
    while (property_iter.next()) |entry| : (index += 1) {
        if (index > 0) {
            property_constraints[index - 1].next = &property_constraints[index];
        }
        property_constraints[index] = .{
            .next = null,
            .kind = .{
                .property = .{
                    .name = try arena.allocator().dupe(u8, entry.key_ptr.*),
                    .constraint = try parse_constraint(arena, entry.value_ptr.*),
                },
            },
        };
    }

    return .{ .properties = .{
        .first_property = if (property_constraints.len > 0) &property_constraints[0] else null,
        .additional = if (obj.get("additionalProperties")) |additional| try parse_constraint(arena, additional) else @constCast(&Schema.Constraint.zero),
    } };
}

fn parse_validation__required_properties(arena: *Arena, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const required_properties_value = obj.get("required") orelse return null;
    if (required_properties_value != .array) return null;
    var required_properties: std.ArrayList(ValueHash) = try .initCapacity(arena.allocator(), required_properties_value.array.items.len);
    for (required_properties_value.array.items) |required_property| {
        if (required_property != .string) continue;
        required_properties.appendAssumeCapacity(.hash_value(@constCast(&required_property)));
    }
    return .{
        .required = required_properties.items,
    };
}

fn parse_applicator_not(arena: *Arena, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const sub_schema = obj.get("not") orelse return null;
    return .{
        .not = try parse_constraint(arena, sub_schema),
    };
}

fn parse_applicitor__all_of(arena: *Arena, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const items = obj.get("allOf") orelse return null;
    if (items != .array) return null;
    var all_of_constraint = Schema.Constraint.Kind{
        .all = null,
    };
    var prev_next_ptr = &all_of_constraint.all;
    for (items.array.items) |item| {
        const sub_schema = try parse_constraint(arena, item);
        prev_next_ptr.* = sub_schema;
        prev_next_ptr = &sub_schema.next;
    }
    return all_of_constraint;
}

fn parse_applicitor__any_of(arena: *Arena, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const items = obj.get("anyOf") orelse return null;
    if (items != .array) return null;
    var any_of_constraint = Schema.Constraint.Kind{
        .any = null,
    };
    var prev_next_ptr = &any_of_constraint.any;
    for (items.array.items) |item| {
        const sub_schema = try parse_constraint(arena, item);
        prev_next_ptr.* = sub_schema;
        prev_next_ptr = &sub_schema.next;
    }
    return any_of_constraint;
}

fn parse_applicitor__one_of(arena: *Arena, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const items = obj.get("oneOf") orelse return null;
    if (items != .array) return null;
    var one_of_constraint = Schema.Constraint.Kind{
        .one = null,
    };
    var prev_next_ptr = &one_of_constraint.one;
    for (items.array.items) |item| {
        const sub_schema = try parse_constraint(arena, item);
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

fn parse_validation__pattern(arena: *Arena, obj: *const std.json.ObjectMap) !?Schema.Constraint.Kind {
    const pattern = obj.get("pattern") orelse return null;
    if (pattern != .string) return null;

    const pattern_c = try arena.allocator().dupeZ(u8, pattern.string);
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
        fn parse(json: str8) *std.json.Value {
            const parsed = std.json.parseFromSlice(std.json.Value, std.heap.page_allocator, json, .{
                .allocate = .alloc_if_needed,
                .parse_numbers = true,
                .ignore_unknown_fields = false,
                .duplicate_field_behavior = .use_last,
                .max_value_len = 1024,
            }) catch std.debug.panic("failed to parse json", .{});
            const value_ptr = std.heap.page_allocator.create(std.json.Value) catch unreachable;
            value_ptr.* = parsed.value;
            return value_ptr;
        }
    };
    {
        const a: H = .hash_value(util.parse("[ 0 ]"));
        const b: H = .hash_value(util.parse("[ 0 ]"));
        try std.testing.expectEqual(a, b);
    }
    try std.testing.expectEqual(util.parse("0.0").float, 0.0);
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
