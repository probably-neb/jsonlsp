//! Comptime-based deep equality comparison for LSP types.
//!
//! Provides type-safe comparison of LSP message structs using comptime reflection
//! to enumerate fields and compare them recursively. Supports special case handling
//! for specific types as needed.

const std = @import("std");
const lsp = @import("lsp");

/// Compare two values of the same type for deep equality.
/// Uses comptime reflection to handle structs, unions, optionals, slices, etc.
pub fn eql(comptime T: type, a: T, b: T) bool {
    return eqlImpl(T, a, b);
}

fn eqlImpl(comptime T: type, a: T, b: T) bool {
    const info = @typeInfo(T);

    return switch (info) {
        .void => true,
        .bool, .int, .float, .comptime_int, .comptime_float => a == b,
        .@"enum" => a == b,
        .pointer => |ptr| eqlPointer(T, ptr, a, b),
        .array => |arr| eqlArray(arr.child, arr.len, &a, &b),
        .optional => |opt| eqlOptional(opt.child, a, b),
        .@"struct" => |s| eqlStruct(T, s, a, b),
        .@"union" => |u| eqlUnion(T, u, a, b),
        // Skip types we can't meaningfully compare
        .@"opaque", .@"fn", .noreturn, .undefined, .null => true,
        else => @compileError("Unsupported type for comparison: " ++ @typeName(T)),
    };
}

fn eqlPointer(comptime T: type, comptime ptr: std.builtin.Type.Pointer, a: T, b: T) bool {
    // Handle slices
    if (ptr.size == .slice) {
        // Skip function pointer slices and opaque types
        const child_info = @typeInfo(ptr.child);
        if (child_info == .@"fn" or child_info == .@"opaque") {
            return true;
        }

        // Special case for []const u8 (strings)
        if (ptr.child == u8) {
            return std.mem.eql(u8, a, b);
        }
        // General slice comparison
        if (a.len != b.len) return false;
        for (a, b) |a_elem, b_elem| {
            if (!eqlImpl(ptr.child, a_elem, b_elem)) return false;
        }
        return true;
    }

    // Handle single-item pointers
    if (ptr.size == .one) {
        // Skip function pointers and opaque types
        const child_info = @typeInfo(ptr.child);
        if (child_info == .@"fn" or child_info == .@"opaque") {
            return true;
        }
        return eqlImpl(ptr.child, a.*, b.*);
    }

    // Skip other pointer types (many, c)
    return true;
}

fn eqlArray(comptime Child: type, comptime len: usize, a: *const [len]Child, b: *const [len]Child) bool {
    // Skip function pointer arrays and opaque types
    const child_info = @typeInfo(Child);
    if (child_info == .@"fn" or child_info == .@"opaque") {
        return true;
    }

    for (a, b) |a_elem, b_elem| {
        if (!eqlImpl(Child, a_elem, b_elem)) return false;
    }
    return true;
}

fn eqlOptional(comptime Child: type, a: ?Child, b: ?Child) bool {
    if (a == null and b == null) return true;
    if (a == null or b == null) return false;
    return eqlImpl(Child, a.?, b.?);
}

fn eqlStruct(comptime T: type, comptime s: std.builtin.Type.Struct, a: T, b: T) bool {
    // Special case for std.json.Value
    if (T == std.json.Value) {
        return eqlJsonValue(a, b);
    }

    // Special case for ArrayHashMap types (check by structure)
    if (comptime hasArrayHashMapShape(T)) {
        return eqlArrayHashMapLike(T, a, b);
    }

    inline for (s.fields) |field| {
        // Skip comptime fields
        if (field.is_comptime) continue;

        // Skip function pointer fields and opaque types
        const field_info = @typeInfo(field.type);
        if (field_info == .@"fn" or field_info == .@"opaque") continue;
        if (field_info == .pointer) {
            const ptr_child_info = @typeInfo(field_info.pointer.child);
            if (ptr_child_info == .@"fn" or ptr_child_info == .@"opaque") continue;
        }

        const a_field = @field(a, field.name);
        const b_field = @field(b, field.name);
        if (!eqlImpl(field.type, a_field, b_field)) return false;
    }
    return true;
}

fn eqlUnion(comptime T: type, comptime u: std.builtin.Type.Union, a: T, b: T) bool {
    const TagType = u.tag_type orelse @compileError("Cannot compare untagged union: " ++ @typeName(T));

    const a_tag = std.meta.activeTag(a);
    const b_tag = std.meta.activeTag(b);

    if (a_tag != b_tag) return false;

    inline for (u.fields) |field| {
        if (a_tag == @field(TagType, field.name)) {
            // Skip function pointer fields and opaque types
            const field_info = @typeInfo(field.type);
            if (field_info == .@"fn" or field_info == .@"opaque") return true;

            const a_val = @field(a, field.name);
            const b_val = @field(b, field.name);
            return eqlImpl(field.type, a_val, b_val);
        }
    }

    return false;
}

fn eqlJsonValue(a: std.json.Value, b: std.json.Value) bool {
    if (std.meta.activeTag(a) != std.meta.activeTag(b)) return false;

    return switch (a) {
        .null => true,
        .bool => |av| av == b.bool,
        .integer => |av| av == b.integer,
        .float => |av| av == b.float,
        .number_string => |av| std.mem.eql(u8, av, b.number_string),
        .string => |av| std.mem.eql(u8, av, b.string),
        .array => |av| {
            const bv = b.array;
            if (av.items.len != bv.items.len) return false;
            for (av.items, bv.items) |ae, be| {
                if (!eqlJsonValue(ae, be)) return false;
            }
            return true;
        },
        .object => |av| {
            const bv = b.object;
            if (av.count() != bv.count()) return false;
            var it = av.iterator();
            while (it.next()) |entry| {
                const b_value = bv.get(entry.key_ptr.*) orelse return false;
                if (!eqlJsonValue(entry.value_ptr.*, b_value)) return false;
            }
            return true;
        },
    };
}

fn hasArrayHashMapShape(comptime T: type) bool {
    const info = @typeInfo(T);
    if (info != .@"struct") return false;

    // Check if it has the characteristic fields of an ArrayHashMap
    const has_entries = @hasField(T, "entries");
    const has_index_header = @hasField(T, "index_header");
    return has_entries and has_index_header;
}

fn eqlArrayHashMapLike(comptime T: type, a: T, b: T) bool {
    if (a.count() != b.count()) return false;

    var it = a.iterator();
    while (it.next()) |entry| {
        const b_value = b.get(entry.key_ptr.*) orelse return false;
        if (!eqlImpl(@TypeOf(entry.value_ptr.*), entry.value_ptr.*, b_value)) return false;
    }
    return true;
}

// ============================================================================
// Tests
// ============================================================================

test "eql primitives" {
    try std.testing.expect(eql(i32, 42, 42));
    try std.testing.expect(!eql(i32, 42, 43));
    try std.testing.expect(eql(bool, true, true));
    try std.testing.expect(!eql(bool, true, false));
    try std.testing.expect(eql(f64, 3.14, 3.14));
}

test "eql strings" {
    try std.testing.expect(eql([]const u8, "hello", "hello"));
    try std.testing.expect(!eql([]const u8, "hello", "world"));
    try std.testing.expect(!eql([]const u8, "hello", "hello!"));
}

test "eql optionals" {
    const a: ?i32 = 42;
    const b: ?i32 = 42;
    const c: ?i32 = null;
    const d: ?i32 = 99;

    try std.testing.expect(eql(?i32, a, b));
    try std.testing.expect(eql(?i32, c, c));
    try std.testing.expect(!eql(?i32, a, c));
    try std.testing.expect(!eql(?i32, a, d));
}

test "eql slices" {
    const a = [_]i32{ 1, 2, 3 };
    const b = [_]i32{ 1, 2, 3 };
    const c = [_]i32{ 1, 2, 4 };
    const d = [_]i32{ 1, 2 };

    try std.testing.expect(eql([]const i32, &a, &b));
    try std.testing.expect(!eql([]const i32, &a, &c));
    try std.testing.expect(!eql([]const i32, &a, &d));
}

test "eql structs" {
    const Point = struct {
        x: i32,
        y: i32,
    };

    const a = Point{ .x = 10, .y = 20 };
    const b = Point{ .x = 10, .y = 20 };
    const c = Point{ .x = 10, .y = 30 };

    try std.testing.expect(eql(Point, a, b));
    try std.testing.expect(!eql(Point, a, c));
}

test "eql nested structs" {
    const Inner = struct {
        value: i32,
    };
    const Outer = struct {
        inner: Inner,
        name: []const u8,
    };

    const a = Outer{ .inner = .{ .value = 42 }, .name = "test" };
    const b = Outer{ .inner = .{ .value = 42 }, .name = "test" };
    const c = Outer{ .inner = .{ .value = 99 }, .name = "test" };

    try std.testing.expect(eql(Outer, a, b));
    try std.testing.expect(!eql(Outer, a, c));
}

test "eql tagged unions" {
    const Value = union(enum) {
        integer: i32,
        string: []const u8,
        none,
    };

    const a = Value{ .integer = 42 };
    const b = Value{ .integer = 42 };
    const c = Value{ .integer = 99 };
    const d = Value{ .string = "hello" };
    const e = Value.none;

    try std.testing.expect(eql(Value, a, b));
    try std.testing.expect(!eql(Value, a, c));
    try std.testing.expect(!eql(Value, a, d));
    try std.testing.expect(!eql(Value, a, e));
    try std.testing.expect(eql(Value, e, e));
}

test "eql enums" {
    const Color = enum { red, green, blue };

    try std.testing.expect(eql(Color, .red, .red));
    try std.testing.expect(!eql(Color, .red, .blue));
}

test "eql std.json.Value" {
    const null_a: std.json.Value = .null;
    const null_b: std.json.Value = .null;
    const bool_true: std.json.Value = .{ .bool = true };
    const bool_false: std.json.Value = .{ .bool = false };
    const int_42: std.json.Value = .{ .integer = 42 };
    const int_99: std.json.Value = .{ .integer = 99 };

    try std.testing.expect(eql(std.json.Value, null_a, null_b));
    try std.testing.expect(eql(std.json.Value, bool_true, bool_true));
    try std.testing.expect(!eql(std.json.Value, bool_true, bool_false));
    try std.testing.expect(!eql(std.json.Value, null_a, bool_true));
    try std.testing.expect(eql(std.json.Value, int_42, int_42));
    try std.testing.expect(!eql(std.json.Value, int_42, int_99));
}

test "eql lsp Position" {
    const a = lsp.types.Position{ .line = 10, .character = 5 };
    const b = lsp.types.Position{ .line = 10, .character = 5 };
    const c = lsp.types.Position{ .line = 10, .character = 6 };

    try std.testing.expect(eql(lsp.types.Position, a, b));
    try std.testing.expect(!eql(lsp.types.Position, a, c));
}

test "eql lsp Range" {
    const a = lsp.types.Range{
        .start = .{ .line = 0, .character = 0 },
        .end = .{ .line = 1, .character = 10 },
    };
    const b = lsp.types.Range{
        .start = .{ .line = 0, .character = 0 },
        .end = .{ .line = 1, .character = 10 },
    };
    const c = lsp.types.Range{
        .start = .{ .line = 0, .character = 0 },
        .end = .{ .line = 2, .character = 10 },
    };

    try std.testing.expect(eql(lsp.types.Range, a, b));
    try std.testing.expect(!eql(lsp.types.Range, a, c));
}

test "eql lsp Diagnostic" {
    const a = lsp.types.Diagnostic{
        .range = .{
            .start = .{ .line = 0, .character = 0 },
            .end = .{ .line = 0, .character = 5 },
        },
        .message = "Test error",
        .severity = .Error,
    };
    const b = lsp.types.Diagnostic{
        .range = .{
            .start = .{ .line = 0, .character = 0 },
            .end = .{ .line = 0, .character = 5 },
        },
        .message = "Test error",
        .severity = .Error,
    };
    const c = lsp.types.Diagnostic{
        .range = .{
            .start = .{ .line = 0, .character = 0 },
            .end = .{ .line = 0, .character = 5 },
        },
        .message = "Different error",
        .severity = .Error,
    };

    try std.testing.expect(eql(lsp.types.Diagnostic, a, b));
    try std.testing.expect(!eql(lsp.types.Diagnostic, a, c));
}

test "eql struct with optional fields" {
    const Config = struct {
        name: []const u8,
        value: ?i32 = null,
        enabled: ?bool = null,
    };

    const a = Config{ .name = "test", .value = 42, .enabled = true };
    const b = Config{ .name = "test", .value = 42, .enabled = true };
    const c = Config{ .name = "test", .value = null, .enabled = true };
    const d = Config{ .name = "test", .value = 42, .enabled = null };

    try std.testing.expect(eql(Config, a, b));
    try std.testing.expect(!eql(Config, a, c));
    try std.testing.expect(!eql(Config, a, d));
}

test "eql slice of structs" {
    const Item = struct {
        id: i32,
        name: []const u8,
    };

    const items_a = [_]Item{
        .{ .id = 1, .name = "first" },
        .{ .id = 2, .name = "second" },
    };
    const items_b = [_]Item{
        .{ .id = 1, .name = "first" },
        .{ .id = 2, .name = "second" },
    };
    const items_c = [_]Item{
        .{ .id = 1, .name = "first" },
        .{ .id = 2, .name = "different" },
    };

    try std.testing.expect(eql([]const Item, &items_a, &items_b));
    try std.testing.expect(!eql([]const Item, &items_a, &items_c));
}
