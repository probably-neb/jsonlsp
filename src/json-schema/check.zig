const std = @import("std");
const base = @import("base");
const json = @import("json");
const json_schema = @import("./json-schema.zig");
const OOM = base.OOM;

const Arena = base.Arena;
const XarMap = base.XarMap;
const Schema = json_schema.Schema;
const HashableJsonValue = json.hashed.Value;
const TypeMap = json_schema.TypeMap;
const JsonNumber = json_schema.JsonNumber;

const MAX_CHECK_DEPTH: u16 = 64;

// WIP:
// working on support for unevaluated items/properties
// all calls that descend down should call check_property/check_item
// which will increase depth
pub const CheckContext = struct {
    depth: u16,
    arena: *Arena,
    checked_items: [MAX_CHECK_DEPTH]?base.IntrusiveDoublyLinkedList(CheckedItem) = .{null} ** MAX_CHECK_DEPTH,
    checked_properties: [MAX_CHECK_DEPTH]?base.IntrusiveDoublyLinkedList(CheckedProperty) = .{null} ** MAX_CHECK_DEPTH,

    const CheckedItem = struct {
        value: ?*const HashableJsonValue,
        next: *CheckedItem,
        prev: *CheckedItem,
    };

    const CheckedProperty = struct {
        value: *const HashableJsonValue,
        next: *CheckedProperty,
        prev: *CheckedProperty,
    };
};

fn check_property(ctx: *CheckContext, constraint: *const Schema.Constraint, value: *const HashableJsonValue) !bool {
    ctx.depth +|= 1;
    const result = try check(ctx, constraint, value.kind.string.child.?);
    const checked_list = &ctx.checked_properties[ctx.depth - 1];
    if (result) {
        if (checked_list.*) |*list| {
            var iter = list.iter();
            while (iter.next()) |item| {
                if (item.value.hash == value.hash) {
                    list.remove(item);
                    break;
                }
            }
        }
    }
    ctx.depth -= 1;
    return result;
}

fn check_item(ctx: *CheckContext, constraint: *const Schema.Constraint, value: *const HashableJsonValue) OOM!bool {
    ctx.depth +|= 1;
    const result = try check(ctx, constraint, value);
    const checked_list = &ctx.checked_items[ctx.depth - 1];
    if (result) {
        if (checked_list.*) |*list| {
            var iter = list.iter();
            while (iter.next()) |item| {
                if (item.value) |item_value| {
                    if (item_value.hash == value.hash) {
                        list.remove(item);
                        break;
                    }
                }
            }
        }
    }
    ctx.depth -= 1;
    return result;
}

const Check_All_Result = struct {
    count: u32 = 0,
    count_ok: u32 = 0,
};

fn check_all(ctx: *CheckContext, node: ?*const Schema.Constraint.Node, value: *const HashableJsonValue) OOM!Check_All_Result {
    var result = Check_All_Result{};
    var cur = node;
    while (cur) |n| : (cur = n.next) {
        const ok = try check(ctx, n.constraint, value);
        result.count += 1;
        result.count_ok += @intFromBool(ok);
    }
    return result;
}

pub fn check(ctx: *CheckContext, constraint: *const Schema.Constraint, value: *const HashableJsonValue) OOM!bool {
    if (constraint.flags.false_schema) {
        return false;
    }
    if (constraint.flags.@"const" and value.hash != constraint.@"const") {
        return false;
    }
    const types_ok = constraint.types == TypeMap.zero or switch (value.kind) {
        .string => constraint.types.string,
        .object => constraint.types.object,
        .array => constraint.types.array,
        .float => constraint.types.number,
        .bool => constraint.types.boolean,
        .null => constraint.types.null,
        .integer => constraint.types.integer or constraint.types.number,
    };
    if (!types_ok) return false;

    for (constraint.@"enum") |hash| {
        if (hash == value.hash) break;
    } else if (constraint.@"enum".len > 0) {
        return false;
    }

    if (value.kind == .string) {
        const len = std.unicode.utf8CountCodepoints(value.kind.string.value) catch 0;
        if (len < constraint.min_len or len > constraint.max_len) {
            return false;
        }
        if (constraint.pattern) |regex| {
            const matches = regex.matches(value.kind.string.value, .{}) catch |err| switch (err) {
                error.ExecError => null,
                error.OutOfMemory => return error.OutOfMemory,
            };
            if (matches == null) {
                return false;
            }
        }
    }
    if (JsonNumber.from_json_value(value)) |number| {
        if (!constraint.bounds.contains(number)) {
            return false;
        }
    }
    // TODO: combine with integer multiple_of
    if (constraint.multiple_of_f64) |multiple_of| {
        if (multiple_of == 0.0) {
            return false;
        }
        const float_val = switch (value.kind) {
            .integer => |int_val| @as(f64, @floatFromInt(int_val)),
            .float => |fv| fv,
            else => null,
        };
        if (float_val) |fv| {
            const quotient = fv / multiple_of;
            const diff = @abs(quotient - @round(quotient));
            if (!(diff < 1e-9)) {
                return false;
            }
        }
    }
    if (constraint.multiple_of_i64) |multiple_of| {
        if (multiple_of == 0) {
            return false;
        }
        const int_val = switch (value.kind) {
            .integer => |iv| iv,
            .float => |fv| float_as_int(fv),
            else => null,
        };
        if (int_val != null and @rem(int_val.?, multiple_of) != 0) {
            return false;
        }
    }
    const initialize_unevaluated_items = constraint.unevaluated_items != null and ctx.checked_items[ctx.depth] == null and value.kind == .array;
    if (initialize_unevaluated_items) {
        ctx.checked_items[ctx.depth] = .{};
        var arr_iter = value.kind.array.iter();
        while (arr_iter.next()) |item| {
            const item_value = try ctx.arena.create(CheckContext.CheckedItem);
            item_value.value = item;
            ctx.checked_items[ctx.depth].?.append(item_value);
        }
    }
    defer if (initialize_unevaluated_items) {
        ctx.checked_items[ctx.depth] = null;
    };

    const initialize_unevaluated_properties = constraint.unevaluated_properties != null and ctx.checked_properties[ctx.depth] == null and value.kind == .object;
    if (initialize_unevaluated_properties) {
        ctx.checked_properties[ctx.depth] = .{};
        var obj_iter = value.kind.object.properties.iter();
        while (obj_iter.next()) |property| {
            const prop_value = try ctx.arena.create(CheckContext.CheckedProperty);
            prop_value.value = property;
            ctx.checked_properties[ctx.depth].?.append(prop_value);
        }
    }
    defer if (initialize_unevaluated_properties) {
        ctx.checked_properties[ctx.depth] = null;
    };

    if (value.kind == .array) {
        const length = value.kind.array.count();
        if (length < constraint.min_items) {
            return false;
        }
        if (length > constraint.max_items) {
            return false;
        }
        if (constraint.flags.unique_items) {
            const scratch = Arena.get_scratch(&.{});
            defer scratch.release();

            var hashes: base.ArenaList(u64) = .empty;
            try hashes.ensure_total_capacity(scratch.arena, length);

            var arr_iter = value.kind.array.iter();
            while (arr_iter.next()) |item| {
                for (hashes.items) |hash| {
                    if (hash == item.hash) {
                        return false;
                    }
                }
                hashes.append_assume_capacity(item.hash);
            }
        }
        var arr_iter = value.kind.array.iter();

        var prefix_item_node = constraint.prefix_items;
        while (prefix_item_node) |prefix_item| : (prefix_item_node = prefix_item.next) {
            const next = arr_iter.next() orelse break;
            const ok = try check_item(ctx, prefix_item.constraint, next);
            if (!ok) return false;
        }

        if (!constraint.flags.additional_items or constraint.prefix_items != null) {
            if (constraint.items) |items| {
                while (arr_iter.next()) |item| {
                    if (!try check_item(ctx, items, item)) return false;
                }
            }
        }
    }
    if (value.kind == .object) {
        if (value.kind.object.count() < constraint.min_properties) {
            return false;
        }
        if (value.kind.object.count() > constraint.max_properties) {
            return false;
        }

        const scratch = Arena.get_scratch(&.{});
        defer scratch.release();

        var checked_properties: XarMap(u64, void, 0) = .empty;

        for (constraint.properties) |property| {
            const key_value = value.kind.object.map.get_const(property.name) orelse continue;
            try checked_properties.put(scratch.arena, property.hash, {});
            if (!try check_property(ctx, property.constraint, key_value.*)) {
                return false;
            }
        }

        var obj_iter = value.kind.object.properties.iter();
        while (obj_iter.next()) |key_node| {
            const key_string = key_node.kind.string;
            const key = key_string.value;

            var matched_pattern = false;
            for (constraint.pattern_properties) |pattern_property| {
                const matches = pattern_property.pattern.matches(key, .{}) catch |err| switch (err) {
                    error.ExecError => null,
                    error.OutOfMemory => return error.OutOfMemory,
                };
                if (matches != null) {
                    matched_pattern = true;
                    if (!try check_property(ctx, pattern_property.constraint, key_node)) {
                        return false;
                    }
                }
            }

            if (!checked_properties.contains(key_node.hash) and !matched_pattern and constraint.additional_properties != null) {
                if (!try check_property(ctx, constraint.additional_properties.?, key_node)) {
                    return false;
                }
            }
        }

        for (constraint.required) |required_property_hash| {
            var key_iter = value.kind.object.properties.iter();
            while (key_iter.next()) |key_ptr| {
                if (key_ptr.hash == required_property_hash) break;
            } else return false;
        }

        for (constraint.dependent_required) |entry| {
            var trigger_present = false;
            var trigger_iter = value.kind.object.properties.iter();
            while (trigger_iter.next()) |key_ptr| {
                if (key_ptr.hash == entry.trigger_property_hash) {
                    trigger_present = true;
                    break;
                }
            }

            if (!trigger_present) continue;

            for (entry.required_property_hashes) |required_property_hash| {
                var dependent_present = false;
                var dependent_iter = value.kind.object.properties.iter();
                while (dependent_iter.next()) |key_ptr| {
                    if (key_ptr.hash == required_property_hash) {
                        dependent_present = true;
                        break;
                    }
                }
                if (!dependent_present) return false;
            }
        }
    }

    if (constraint.ref_constraint) |referenced_constraint| {
        if (!try check(ctx, referenced_constraint, value)) {
            return false;
        }
    }
    if (constraint.not_constraint) |constraint_to_invert| {
        if (try check(ctx, constraint_to_invert, value)) {
            return false;
        }
    }

    const all_of_result = try check_all(ctx, constraint.all_of, value);
    if (constraint.all_of != null and all_of_result.count_ok != all_of_result.count) {
        return false;
    }

    const any_of_result = try check_all(ctx, constraint.any_of, value);
    if (constraint.any_of != null and any_of_result.count_ok == 0) {
        return false;
    }

    const one_of_result = try check_all(ctx, constraint.one_of, value);
    if (constraint.one_of != null and one_of_result.count_ok != 1) {
        return false;
    }

    if (constraint.if_constraint) |if_constraint| {
        if (try check(ctx, if_constraint, value)) {
            if (constraint.then_constraint) |then_constraint| {
                if (!try check(ctx, then_constraint, value)) {
                    return false;
                }
            }
        } else if (constraint.else_constraint) |else_constraint| {
            if (!try check(ctx, else_constraint, value)) {
                return false;
            }
        }
    }

    if (constraint.unevaluated_items) |unevaluated_items| {
        if (ctx.checked_items[ctx.depth]) |*unchecked_items| {
            var unchecked_item = unchecked_items.first;
            while (unchecked_item) |item| {
                const next = if (item.next != unchecked_items.first) item.next else null;
                defer unchecked_item = next;
                if (item.value) |item_value| {
                    if (!try check_item(ctx, unevaluated_items, item_value)) {
                        return false;
                    }
                }
            }
        }
    }
    if (constraint.unevaluated_properties) |unevaluated_properties_constraint| {
        if (ctx.checked_properties[ctx.depth]) |*unchecked_properties| {
            var unchecked_prop = unchecked_properties.first;
            while (unchecked_prop) |prop| {
                const next = if (prop.next != unchecked_properties.first) prop.next else null;
                defer unchecked_prop = next;
                if (!try check_property(ctx, unevaluated_properties_constraint, prop.value)) {
                    return false;
                }
            }
        }
    }
    return true;
}

fn float_as_int(float: f64) ?i64 {
    if (@trunc(float) != float) return null;
    const min_int: f64 = @floatFromInt(std.math.minInt(i64));
    const max_int: f64 = @floatFromInt(std.math.maxInt(i64));
    if (std.math.clamp(float, min_int, max_int) != float) return null;
    return @intFromFloat(float);
}
