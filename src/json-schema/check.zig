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
    active_frames: [MAX_CHECK_DEPTH]Frame_List = .{Frame_List.zero} ** MAX_CHECK_DEPTH,

    const Item_List = base.IntrusiveDoublyLinkedList(Checked_Item);
    const Property_List = base.IntrusiveDoublyLinkedList(Checked_Property);
    const Frame_List = base.IntrusiveDoublyLinkedList(Frame);

    const Checked_Item = struct {
        value: *const HashableJsonValue,
        index: u32,
        next: *Checked_Item,
        prev: *Checked_Item,

        fn init(self: *Checked_Item, value: *const HashableJsonValue, index: u32) void {
            self.value = value;
            self.index = index;
        }
    };

    const Checked_Property = struct {
        value: *const HashableJsonValue,
        next: *Checked_Property,
        prev: *Checked_Property,

        fn init(self: *Checked_Property, value: *const HashableJsonValue) void {
            self.value = value;
        }
    };

    const Frame = struct {
        constraint: *const Schema.Constraint,
        instance: *const HashableJsonValue,
        unevaluated_items: Item_List = .zero,
        evaluated_items: Item_List = .zero,
        unevaluated_props: Property_List = .zero,
        evaluated_props: Property_List = .zero,
        next: *Frame,
        prev: *Frame,
    };

    const Save_Point = struct {
        snapshots: ?*Frame_Save = null,
    };

    const Frame_Save = struct {
        frame: *Frame,
        item_tail: ?*Checked_Item,
        property_tail: ?*Checked_Property,
        next: ?*Frame_Save,
    };

    fn get_frame(ctx: *CheckContext, constraint: *const Schema.Constraint, instance: *const HashableJsonValue) ?*Frame {
        var iter = ctx.active_frames[ctx.depth].iter();
        while (iter.next()) |frame| {
            if (frame.constraint == constraint and frame.instance == instance) {
                return frame;
            }
        }
        return null;
    }

    fn ensure_frame(ctx: *CheckContext, constraint: *const Schema.Constraint, instance: *const HashableJsonValue) OOM!*Frame {
        if (ctx.get_frame(constraint, instance)) |frame| {
            return frame;
        }
        const frame = try ctx.arena.create(Frame);
        frame.* = .{
            .constraint = constraint,
            .instance = instance,
            .next = undefined,
            .prev = undefined,
        };
        ctx.active_frames[ctx.depth].append(frame);
        return frame;
    }

    fn checked_savepoint(ctx: *CheckContext) OOM!Save_Point {
        var save_point = Save_Point{};
        var iter = ctx.active_frames[ctx.depth].iter();
        while (iter.next()) |frame| {
            const snapshot = try ctx.arena.create(Frame_Save);
            snapshot.* = .{
                .frame = frame,
                .item_tail = frame.evaluated_items.last(),
                .property_tail = frame.evaluated_props.last(),
                .next = save_point.snapshots,
            };
            save_point.snapshots = snapshot;
        }
        return save_point;
    }

    fn checked_rollback(_: *CheckContext, save_point: Save_Point) void {
        var snapshot = save_point.snapshots;
        while (snapshot) |frame_save| : (snapshot = frame_save.next) {
            const unevaluated_items = &frame_save.frame.unevaluated_items;
            while (frame_save.frame.evaluated_items.last()) |cur| {
                if (frame_save.item_tail == cur) break;
                _ = frame_save.frame.evaluated_items.pop_last();
                if (unevaluated_items.first == null) {
                    unevaluated_items.append(cur);
                    continue;
                }
                if (unevaluated_items.first.?.index > cur.index) {
                    Item_List.insert_before(unevaluated_items.first.?, cur);
                    continue;
                }
                if (unevaluated_items.last().?.index < cur.index) {
                    unevaluated_items.append(cur);
                    continue;
                }
                var inserted = false;
                var pre_unchecked = unevaluated_items.first;
                while (pre_unchecked) |unchecked_item| : (pre_unchecked = unevaluated_items.next_after(unchecked_item)) {
                    if (cur.index < unchecked_item.index) {
                        Item_List.insert_before(unchecked_item, cur);
                        inserted = true;
                        break;
                    }
                }
                if (!inserted) {
                    unevaluated_items.append(cur);
                }
            }

            const unevaluated_props = &frame_save.frame.unevaluated_props;
            while (frame_save.frame.evaluated_props.last()) |cur| {
                if (frame_save.property_tail == cur) break;
                _ = frame_save.frame.evaluated_props.pop_last();
                unevaluated_props.append(cur);
            }
        }
    }
};

fn check_property(ctx: *CheckContext, constraint: *const Schema.Constraint, value: *const HashableJsonValue) !bool {
    ctx.depth +|= 1;
    const result = try check(ctx, constraint, value.kind.string.child.?);
    ctx.depth -= 1;
    if (result) {
        var frame_iter = ctx.active_frames[ctx.depth].iter();
        while (frame_iter.next()) |frame| {
            var iter = frame.unevaluated_props.iter();
            while (iter.next()) |item| {
                if (item.value == value) {
                    frame.unevaluated_props.remove(item);
                    frame.evaluated_props.append(item);
                    break;
                }
            }
        }
    }
    return result;
}

fn check_item(ctx: *CheckContext, constraint: *const Schema.Constraint, value: *const HashableJsonValue, index: u32) OOM!bool {
    ctx.depth +|= 1;
    const result = try check(ctx, constraint, value);
    ctx.depth -= 1;
    if (result) {
        var frame_iter = ctx.active_frames[ctx.depth].iter();
        while (frame_iter.next()) |frame| {
            var iter = frame.unevaluated_items.iter();
            while (iter.next()) |item| {
                if (item.index == index) {
                    std.debug.assert(item.value.hash == value.hash);
                    frame.unevaluated_items.remove(item);
                    frame.evaluated_items.append(item);
                    break;
                }
            }
        }
    }
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
        const save_point = try ctx.checked_savepoint();
        const ok = try check(ctx, n.constraint, value);
        if (!ok) {
            ctx.checked_rollback(save_point);
        }
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
    const needs_frame = (constraint.unevaluated_items != null and value.kind == .array) or (constraint.unevaluated_properties != null and value.kind == .object);
    const existing_frame = if (needs_frame) ctx.get_frame(constraint, value) else null;
    const created_frame = needs_frame and existing_frame == null;
    const frame = if (existing_frame) |existing| existing else if (needs_frame) blk: {
        const new_frame = try ctx.arena.create(CheckContext.Frame);
        new_frame.* = .{
            .constraint = constraint,
            .instance = value,
            .next = undefined,
            .prev = undefined,
        };
        ctx.active_frames[ctx.depth].append(new_frame);
        break :blk new_frame;
    } else null;
    if (constraint.unevaluated_items != null and value.kind == .array) {
        frame.?.unevaluated_items = .{};
        var arr_iter = value.kind.array.iter();
        var arr_index: u32 = 0;
        while (arr_iter.next()) |item| : (arr_index += 1) {
            const item_value = try ctx.arena.create(CheckContext.Checked_Item);
            item_value.init(item, arr_index);
            frame.?.unevaluated_items.append(item_value);
        }
    }
    if (constraint.unevaluated_properties != null and value.kind == .object) {
        frame.?.unevaluated_props = .{};
        var obj_iter = value.kind.object.properties.iter();
        while (obj_iter.next()) |property| {
            const prop_value = try ctx.arena.create(CheckContext.Checked_Property);
            prop_value.init(property);
            frame.?.unevaluated_props.append(prop_value);
        }
    }
    defer if (created_frame) {
        ctx.active_frames[ctx.depth].remove(frame.?);
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
        var arr_index: u32 = 0;

        var prefix_item_node = constraint.prefix_items;
        while (prefix_item_node) |prefix_item| : ({
            prefix_item_node = prefix_item.next;
            arr_index += 1;
        }) {
            const next = arr_iter.next() orelse break;
            const ok = try check_item(ctx, prefix_item.constraint, next, arr_index);
            if (!ok) return false;
        }

        if (!constraint.flags.additional_items or constraint.prefix_items != null) {
            if (constraint.items) |items| {
                while (arr_iter.next()) |item| : (arr_index += 1) {
                    if (!try check_item(ctx, items, item, arr_index)) return false;
                }
            }
        }

        if (constraint.contains) |contains| {
            const contains_save_point = try ctx.checked_savepoint();
            var contains_result = Check_All_Result{};
            var iter = value.kind.array.iter();
            var index: u32 = 0;
            while (iter.next()) |item| : (index += 1) {
                const save_point = try ctx.checked_savepoint();
                const ok = try check_item(ctx, contains, item, index);
                if (!ok) {
                    ctx.checked_rollback(save_point);
                }
                contains_result.count += 1;
                contains_result.count_ok += @intFromBool(ok);
            }
            if (!constraint.contains_bounds.contains(.{ .int = contains_result.count_ok })) {
                ctx.checked_rollback(contains_save_point);
                return false;
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
        const save_point = try ctx.checked_savepoint();
        const result = try check(ctx, constraint_to_invert, value);
        ctx.checked_rollback(save_point);
        if (result) {
            return false;
        }
    }

    const all_of_save_point = try ctx.checked_savepoint();
    const all_of_result = try check_all(ctx, constraint.all_of, value);
    if (constraint.all_of != null and all_of_result.count_ok != all_of_result.count) {
        ctx.checked_rollback(all_of_save_point);
        return false;
    }

    const any_of_save_point = try ctx.checked_savepoint();
    const any_of_result = try check_all(ctx, constraint.any_of, value);
    if (constraint.any_of != null and any_of_result.count_ok == 0) {
        ctx.checked_rollback(any_of_save_point);
        return false;
    }

    const one_of_save_point = try ctx.checked_savepoint();
    const one_of_result = try check_all(ctx, constraint.one_of, value);
    if (constraint.one_of != null and one_of_result.count_ok != 1) {
        ctx.checked_rollback(one_of_save_point);
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
        if (ctx.get_frame(constraint, value)) |frame_for_constraint| {
            const unchecked_items = &frame_for_constraint.unevaluated_items;

            var unchecked_item = unchecked_items.first;
            while (unchecked_item) |item| {
                const next = unchecked_items.next_after(item);
                defer unchecked_item = next;
                if (!try check_item(ctx, unevaluated_items, item.value, item.index)) {
                    return false;
                }
            }
        }
    }
    if (constraint.unevaluated_properties) |unevaluated_properties_constraint| {
        if (ctx.get_frame(constraint, value)) |frame_for_constraint| {
            const unchecked_properties = &frame_for_constraint.unevaluated_props;
            var unchecked_prop = unchecked_properties.first;
            while (unchecked_prop) |prop| {
                const next = unchecked_properties.next_after(prop);
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
