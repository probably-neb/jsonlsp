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
    errors: base.IntrusiveDoublyLinkedList(Error) = .zero,

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
    if (constraint.constant) |constant| {
        if (value.hash != constant.hash) {
            try record_const_mismatch_error(ctx, value, constant);
            return false;
        }
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
    if (!types_ok) {
        try record_type_mismatch_error(ctx, value, &constraint.types);
        return false;
    }

    for (constraint.@"enum") |expected| {
        if (expected.hash == value.hash) break;
    } else if (constraint.@"enum".len > 0) {
        try record_enum_mismatch_error(ctx, value, constraint.@"enum");
        return false;
    }

    if (value.kind == .string) {
        const len = std.unicode.utf8CountCodepoints(value.kind.string.value) catch 0;
        if (len < constraint.min_len) {
            try record_count_error(ctx, value, .min_length, len, constraint.min_len);
            return false;
        }
        if (len > constraint.max_len) {
            try record_count_error(ctx, value, .max_length, len, constraint.max_len);
            return false;
        }
        if (constraint.pattern) |regex| {
            const matches = regex.matches(value.kind.string.value, .{}) catch |err| switch (err) {
                error.ExecError => null,
                error.OutOfMemory => return error.OutOfMemory,
            };
            if (matches == null) {
                try record_pattern_mismatch_error(ctx, value, constraint.pattern_source);
                return false;
            }
        }
    }
    if (JsonNumber.from_json_value(value)) |number| {
        if (!constraint.bounds.contains(number)) {
            try record_bounds_error(ctx, value, number, constraint.bounds);
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
                try record_number_error(ctx, value, .multiple_of, JsonNumber.from_json_value(value).?, .{ .float = multiple_of });
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
            try record_number_error(ctx, value, .multiple_of, JsonNumber.from_json_value(value).?, .{ .int = multiple_of });
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
            try record_count_error(ctx, value, .min_items, @intCast(length), constraint.min_items);
            return false;
        }
        if (length > constraint.max_items) {
            try record_count_error(ctx, value, .max_items, @intCast(length), constraint.max_items);
            return false;
        }
        if (constraint.flags.unique_items) {
            var arr_iter = value.kind.array.iter();
            while (arr_iter.next()) |item| {
                var seen_iter = value.kind.array.iter();
                while (seen_iter.next()) |seen| {
                    if (seen == item) break;
                    if (seen.hash == item.hash) {
                        try record_unique_items_error(ctx, item);
                        return false;
                    }
                }
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
        const property_count = value.kind.object.count();
        if (property_count < constraint.min_properties) {
            try record_count_error(ctx, value, .min_properties, @intCast(property_count), constraint.min_properties);
            return false;
        }
        if (property_count > constraint.max_properties) {
            try record_count_error(ctx, value, .max_properties, @intCast(property_count), constraint.max_properties);
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

        for (constraint.dependent_schemas) |dependent_schema| {
            var trigger_present = false;
            var trigger_iter = value.kind.object.properties.iter();
            while (trigger_iter.next()) |key_ptr| {
                if (key_ptr.hash == dependent_schema.hash) {
                    trigger_present = true;
                    break;
                }
            }

            if (!trigger_present) continue;
            const save_point = try ctx.checked_savepoint();
            const result = try check(ctx, dependent_schema.constraint, value);
            ctx.checked_rollback(save_point);
            if (!result) return false;
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

pub const Error = struct {
    code: Code,
    instance_range: json.Token.Range,
    next: *Error,
    prev: *Error,
    actual_type: ?HashableJsonValue.Kind_Tag = null,
    expected_types: *const TypeMap = &.zero,
    expected_value: ?*const HashableJsonValue = null,
    expected_values: []*const HashableJsonValue = &.{},
    actual_number: JsonNumber = .{ .int = 0 },
    expected_number: JsonNumber = .{ .int = 0 },
    actual_count: u64 = 0,
    expected_count: u64 = 0,
    expected_pattern: []const u8 = &.{},
    // todo:
    // instance_path: []const u8,
    // actual: *const HashableJsonValue,
    // expected: *const HashableJsonValue,
    // help: ?[]const u8,

    pub const Code = enum {
        any_error,
        type_mismatch,
        const_mismatch,
        enum_mismatch,
        minimum,
        exclusive_minimum,
        maximum,
        exclusive_maximum,
        multiple_of,
        min_length,
        max_length,
        pattern_mismatch,
        min_items,
        max_items,
        unique_items,
        min_properties,
        max_properties,
    };
};

fn record_error(ctx: *CheckContext, value: *const HashableJsonValue) !*Error {
    const err = try ctx.arena.create(Error);
    err.* = Error{
        .code = .any_error,
        .instance_range = value.range,
        .next = undefined,
        .prev = undefined,
    };
    ctx.errors.append(err);
    return err;
}

fn record_type_mismatch_error(ctx: *CheckContext, value: *const HashableJsonValue, type_map: *const TypeMap) !void {
    const err = try record_error(ctx, value);
    err.code = .type_mismatch;
    err.expected_types = type_map;
    err.actual_type = value.kind;
}

fn record_const_mismatch_error(ctx: *CheckContext, value: *const HashableJsonValue, expected: *const HashableJsonValue) !void {
    const err = try record_error(ctx, value);
    err.code = .const_mismatch;
    err.expected_value = expected;
}

fn record_enum_mismatch_error(ctx: *CheckContext, value: *const HashableJsonValue, expected: []*const HashableJsonValue) !void {
    const err = try record_error(ctx, value);
    err.code = .enum_mismatch;
    err.expected_values = expected;
}

fn record_number_error(ctx: *CheckContext, value: *const HashableJsonValue, code: Error.Code, actual: JsonNumber, expected: JsonNumber) !void {
    const err = try record_error(ctx, value);
    err.code = code;
    err.actual_number = actual;
    err.expected_number = expected;
}

fn record_bounds_error(ctx: *CheckContext, value: *const HashableJsonValue, actual: JsonNumber, bounds: json_schema.Bounds) !void {
    if (bounds.present[0]) {
        const order = JsonNumber.cmp(actual, bounds.values[0]);
        if (order == .lt or (order == .eq and bounds.exclusive[0])) {
            return record_number_error(ctx, value, if (bounds.exclusive[0]) .exclusive_minimum else .minimum, actual, bounds.values[0]);
        }
    }
    if (bounds.present[1]) {
        const order = JsonNumber.cmp(actual, bounds.values[1]);
        if (order == .gt or (order == .eq and bounds.exclusive[1])) {
            return record_number_error(ctx, value, if (bounds.exclusive[1]) .exclusive_maximum else .maximum, actual, bounds.values[1]);
        }
    }
    unreachable;
}

fn record_count_error(ctx: *CheckContext, value: *const HashableJsonValue, code: Error.Code, actual: u64, expected: u64) !void {
    const err = try record_error(ctx, value);
    err.code = code;
    err.actual_count = actual;
    err.expected_count = expected;
}

fn record_pattern_mismatch_error(ctx: *CheckContext, value: *const HashableJsonValue, pattern: []const u8) !void {
    const err = try record_error(ctx, value);
    err.code = .pattern_mismatch;
    err.expected_pattern = pattern;
}

fn record_unique_items_error(ctx: *CheckContext, value: *const HashableJsonValue) !void {
    const err = try record_error(ctx, value);
    err.code = .unique_items;
}

const ExpectedTypesFormatter = struct {
    types: *const TypeMap,

    pub fn format(
        self: @This(),
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        const strings: [7][]const u8 = comptime .{
            "null",
            "boolean",
            "integer",
            "number",
            "object",
            "string",
            "array",
        };
        var present: [strings.len]bool = .{false} ** strings.len;
        var count: u32 = 0;
        inline for (strings, &present) |str, *is_present| {
            is_present.* = @field(self.types, str);
            count += @intFromBool(is_present.*);
        }

        if (count == 0) {
            try writer.writeAll("none");
            return;
        }

        var found: u32 = 0;
        for (strings, present) |str, is_present| {
            if (!is_present) {
                continue;
            }
            if (found > 0 and found < count and count > 2) {
                try writer.writeAll(", ");
            }
            if (found > 0 and found == count - 1) {
                if (count == 2) {
                    try writer.writeByte(' ');
                }
                try writer.writeAll("or ");
            }
            try writer.writeAll(str);
            found += 1;
        }
    }
};

fn fmt_expected_types(types: *const TypeMap) ExpectedTypesFormatter {
    return .{ .types = types };
}

const JsonNumberFormatter = struct {
    number: JsonNumber,

    pub fn format(formatter: @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
        switch (formatter.number) {
            .int => |int| try writer.print("{d}", .{int}),
            .float => |float| try writer.print("{d}", .{float}),
        }
    }
};

fn fmt_json_number(number: JsonNumber) JsonNumberFormatter {
    return .{ .number = number };
}

const JsonValueFormatter = struct {
    value: *const HashableJsonValue,

    pub fn format(formatter: @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
        var json_writer: std.json.Stringify = .{ .writer = writer };
        try write_json_value(formatter.value, &json_writer);
    }
};

fn write_json_value(value: *const HashableJsonValue, writer: *std.json.Stringify) std.Io.Writer.Error!void {
    switch (value.kind) {
        .null => try writer.write(null),
        .bool => |bool_value| try writer.write(bool_value),
        .integer => |int| try writer.write(int),
        .float => |float| try writer.write(float),
        .string => |string| try writer.write(string.value),
        .array => |array| {
            try writer.beginArray();
            var it = array.first;
            while (it) |item| : (it = array.next_after(item)) {
                try write_json_value(item, writer);
            }
            try writer.endArray();
        },
        .object => |object| {
            try writer.beginObject();
            var it = object.properties.first;
            while (it) |property| : (it = object.properties.next_after(property)) {
                const key = property.kind.string;
                try writer.objectField(key.value);
                try write_json_value(key.child.?, writer);
            }
            try writer.endObject();
        },
    }
}

fn fmt_json_value(value: *const HashableJsonValue) JsonValueFormatter {
    return .{ .value = value };
}

const JsonValuesFormatter = struct {
    values: []const *const HashableJsonValue,

    pub fn format(formatter: @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
        for (formatter.values, 0..) |value, index| {
            if (index > 0 and index < formatter.values.len and formatter.values.len > 2) {
                try writer.writeAll(", ");
            }
            if (index > 0 and index == formatter.values.len - 1) {
                if (formatter.values.len == 2) {
                    try writer.writeByte(' ');
                }
                try writer.writeAll("or ");
            }
            try writer.print("{f}", .{fmt_json_value(value)});
        }
    }
};

fn fmt_json_values(values: []const *const HashableJsonValue) JsonValuesFormatter {
    return .{ .values = values };
}

test fmt_expected_types {
    var arena: Arena = try .init(.{});
    defer arena.release();

    const none = try arena.print("{f}", .{fmt_expected_types(&.{})});
    try std.testing.expectEqualStrings("none", none);

    const single = try arena.print("{f}", .{fmt_expected_types(&.{ .boolean = true })});
    try std.testing.expectEqualStrings("boolean", single);

    const two = try arena.print("{f}", .{fmt_expected_types(&.{ .boolean = true, .string = true })});
    try std.testing.expectEqualStrings("boolean or string", two);

    const all = try arena.print("{f}", .{fmt_expected_types(&.{
        .boolean = true,
        .string = true,
        .number = true,
        .array = true,
        .object = true,
    })});
    try std.testing.expectEqualStrings("boolean, number, object, string, or array", all);
}

pub const RenderedError = struct {
    code: Error.Code,
    message: []const u8,
    source_range: json.Token.Range,
};

pub fn render_errors(arena: *Arena, errors: base.IntrusiveDoublyLinkedList(Error)) ![]const RenderedError {
    var rendered_errors: base.ArenaList(RenderedError) = .empty;
    try rendered_errors.ensure_total_capacity(arena, errors.count());
    var current_error = errors.first;
    while (current_error) |err| : (current_error = errors.next_after(err)) {
        const message = switch (err.code) {
            .type_mismatch => try arena.print("Expected a value of type {f}, found {t}", .{ fmt_expected_types(err.expected_types), err.actual_type.? }),
            .const_mismatch => try arena.print("Expected value to equal {f}", .{fmt_json_value(err.expected_value.?)}),
            .enum_mismatch => try arena.print("Expected value to be one of {f}", .{fmt_json_values(err.expected_values)}),
            .minimum => try arena.print("Expected number to be at least {f}, found {f}", .{ fmt_json_number(err.expected_number), fmt_json_number(err.actual_number) }),
            .exclusive_minimum => try arena.print("Expected number to be greater than {f}, found {f}", .{ fmt_json_number(err.expected_number), fmt_json_number(err.actual_number) }),
            .maximum => try arena.print("Expected number to be at most {f}, found {f}", .{ fmt_json_number(err.expected_number), fmt_json_number(err.actual_number) }),
            .exclusive_maximum => try arena.print("Expected number to be less than {f}, found {f}", .{ fmt_json_number(err.expected_number), fmt_json_number(err.actual_number) }),
            .multiple_of => try arena.print("Expected number to be a multiple of {f}, found {f}", .{ fmt_json_number(err.expected_number), fmt_json_number(err.actual_number) }),
            .min_length => try arena.print("Expected string length to be at least {}, found {}", .{ err.expected_count, err.actual_count }),
            .max_length => try arena.print("Expected string length to be at most {}, found {}", .{ err.expected_count, err.actual_count }),
            .pattern_mismatch => try arena.print("Expected string to match pattern /{s}/", .{err.expected_pattern}),
            .min_items => try arena.print("Expected array to contain at least {} item{s}, found {}", .{ err.expected_count, if (err.expected_count == 1) "" else "s", err.actual_count }),
            .max_items => try arena.print("Expected array to contain at most {} item{s}, found {}", .{ err.expected_count, if (err.expected_count == 1) "" else "s", err.actual_count }),
            .unique_items => try arena.print("Expected array items to be unique", .{}),
            .min_properties => try arena.print("Expected object to contain at least {} propert{s}, found {}", .{ err.expected_count, if (err.expected_count == 1) "y" else "ies", err.actual_count }),
            .max_properties => try arena.print("Expected object to contain at most {} propert{s}, found {}", .{ err.expected_count, if (err.expected_count == 1) "y" else "ies", err.actual_count }),
            .any_error => continue,
        };
        rendered_errors.append_assume_capacity(.{
            .code = err.code,
            .message = message,
            .source_range = err.instance_range,
        });
    }
    return rendered_errors.items;
}

test {
    std.testing.refAllDecls(@This());
}
