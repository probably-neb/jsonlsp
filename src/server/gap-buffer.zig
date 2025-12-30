const std = @import("std");
const base = @import("base");

pub const GapBuffer = struct {
    data: []u8,
    gap: base.Range(usize),

    pub const empty = GapBuffer{
        .data = &.{},
        .gap = .zero,
    };

    pub const Error = error{
        OutOfMemory,
        InvalidRange,
        OutOfBounds,
    };

    pub fn init(buffer: []u8, text_len: usize) GapBuffer {
        if (text_len > buffer.len) @panic("invalid initial text size");

        return .{
            .data = buffer,
            .gap = .{
                .start = text_len,
                .close = buffer.len,
            },
        };
    }

    pub fn new_from_smaller(prev: *const GapBuffer, new_buffer: []u8) GapBuffer {
        std.debug.assert(new_buffer.len > prev.data.len);
        std.debug.assert(prev.gap.start <= prev.gap.close);
        std.debug.assert(prev.gap.close <= prev.data.len);

        const old_prefix_len = prev.gap.start;
        const old_suffix_len = prev.data.len - prev.gap.close;

        std.debug.assert(old_prefix_len + old_suffix_len <= new_buffer.len);

        const new_gap_start = old_prefix_len;
        const new_gap_close = new_buffer.len - old_suffix_len;

        std.debug.assert(new_gap_close >= new_gap_start);

        @memcpy(new_buffer[0..old_prefix_len], prev.data[0..old_prefix_len]);
        @memcpy(new_buffer[new_gap_close..], prev.data[prev.gap.close..]);

        return .{
            .data = new_buffer,
            .gap = .{
                .start = new_gap_start,
                .close = new_gap_close,
            },
        };
    }

    pub fn len(gap_buf: *const GapBuffer) usize {
        return gap_buf.data.len - gap_buf.gap.len();
    }

    fn move_gap_to(gap_buf: *GapBuffer, pos: usize) Error!void {
        const content_len = gap_buf.len();
        if (pos > content_len) return error.OutOfBounds;

        const gap_len = gap_buf.gap.len();
        const gap_start = gap_buf.gap.start;
        const gap_close = gap_buf.gap.close;

        if (pos == gap_start) return;

        if (pos < gap_start) {
            const shift_len = gap_start - pos;
            const src = gap_buf.data[pos..gap_start];
            const dst = gap_buf.data[gap_close - shift_len .. gap_close];
            std.mem.copyBackwards(u8, dst, src);

            gap_buf.gap.start = pos;
            gap_buf.gap.close = gap_close - shift_len;
        } else {
            const shift_len = pos - gap_start;
            const src = gap_buf.data[gap_close .. gap_close + shift_len];
            const dst = gap_buf.data[gap_start .. gap_start + shift_len];
            @memcpy(dst, src);

            gap_buf.gap.start = pos;
            gap_buf.gap.close = gap_close + shift_len;
        }

        if (gap_buf.gap.len() != gap_len) return error.InvalidRange;
    }

    pub fn insert(gap_buf: *GapBuffer, pos: usize, text: []const u8) Error!void {
        if (text.len == 0) return;
        if (gap_buf.gap.len() < text.len) return error.OutOfMemory;

        try gap_buf.move_gap_to(pos);

        @memcpy(gap_buf.data[gap_buf.gap.start .. gap_buf.gap.start + text.len], text);
        gap_buf.gap.start += text.len;
    }

    pub fn delete(gap_buf: *GapBuffer, pos: usize, count: usize) Error!void {
        if (count == 0) return;

        const content_len = gap_buf.len();
        if (pos > content_len) return error.OutOfBounds;
        if (count > content_len - pos) return error.OutOfBounds;

        try gap_buf.move_gap_to(pos);
        if (gap_buf.gap.close + count > gap_buf.data.len) return error.InvalidRange;
        gap_buf.gap.close += count;
    }

    pub fn replace(gap_buf: *GapBuffer, start: usize, end: usize, text: []const u8) Error!void {
        if (start > end) return error.InvalidRange;

        const content_len = gap_buf.len();
        if (end > content_len) return error.OutOfBounds;

        const delete_len = end - start;

        if (delete_len == text.len) {
            try gap_buf.move_gap_to(end);
            @memcpy(gap_buf.data[start..end], text);
            return;
        }

        const gap_len = gap_buf.gap.len();
        if (gap_len + delete_len < text.len) return error.OutOfMemory;

        try gap_buf.move_gap_to(end);

        gap_buf.gap.start -= delete_len;

        @memcpy(gap_buf.data[gap_buf.gap.start .. gap_buf.gap.start + text.len], text);
        gap_buf.gap.start += text.len;
    }

    pub fn get(gap_buf: *const GapBuffer, pos: usize) Error!u8 {
        const content_len = gap_buf.len();
        if (pos >= content_len) return error.OutOfBounds;

        if (pos < gap_buf.gap.start) {
            return gap_buf.data[pos];
        }

        return gap_buf.data[pos + gap_buf.gap.len()];
    }

    pub fn slices(gap_buf: *const GapBuffer) struct { prefix: []const u8, suffix: []const u8 } {
        return .{
            .prefix = gap_buf.data[0..gap_buf.gap.start],
            .suffix = gap_buf.data[gap_buf.gap.close..],
        };
    }

    pub fn iterator(gap_buf: *const GapBuffer) Iterator {
        return .{ .buffer = gap_buf, .pos = 0 };
    }

    pub const Iterator = struct {
        buffer: *const GapBuffer,
        pos: usize,

        pub fn next(it: *Iterator) ?u8 {
            const byte = it.buffer.get(it.pos) catch return null;
            it.pos += 1;
            return byte;
        }
    };
};

test "basic insert and read" {
    var storage: [128]u8 = undefined;
    @memcpy(storage[0.."hello world".len], "hello world");

    var buf = GapBuffer.init(storage[0..], "hello world".len);

    try std.testing.expectEqual(@as(usize, 11), buf.len());

    const s = buf.slices();
    try std.testing.expectEqualStrings("hello world", s.prefix);
    try std.testing.expectEqualStrings("", s.suffix);
}

test "insert in middle" {
    var storage: [128]u8 = undefined;
    @memcpy(storage[0.."helloworld".len], "helloworld");

    var buf = GapBuffer.init(storage[0..], "helloworld".len);

    try buf.insert(5, " ");

    const s = buf.slices();
    const got = try collect(&buf, std.testing.allocator);
    defer std.testing.allocator.free(got);
    try std.testing.expectEqualStrings("hello world", got);
    _ = s;
}

test "delete" {
    var storage: [128]u8 = undefined;
    @memcpy(storage[0.."hello world".len], "hello world");

    var buf = GapBuffer.init(storage[0..], "hello world".len);

    try buf.delete(5, 1);

    const got = try collect(&buf, std.testing.allocator);
    defer std.testing.allocator.free(got);
    try std.testing.expectEqualStrings("helloworld", got);
}

test "replace" {
    var storage: [128]u8 = undefined;
    @memcpy(storage[0.."hello world".len], "hello world");

    var buf = GapBuffer.init(storage[0..], "hello world".len);

    try buf.replace(6, 11, "zig");

    const got = try collect(&buf, std.testing.allocator);
    defer std.testing.allocator.free(got);
    try std.testing.expectEqualStrings("hello zig", got);
}

test "slices" {
    var storage: [128]u8 = undefined;
    @memcpy(storage[0.."hello world".len], "hello world");

    var buf = GapBuffer.init(storage[0..], "hello world".len);

    try buf.insert(5, "");

    const s = buf.slices();
    const got = try collect(&buf, std.testing.allocator);
    defer std.testing.allocator.free(got);
    try std.testing.expectEqualStrings("hello world", got);
    _ = s;
}

test "new_from_smaller expands gap and preserves content" {
    var old_storage: [64]u8 = undefined;
    @memcpy(old_storage[0.."hello world".len], "hello world");

    var prev = GapBuffer.init(old_storage[0..], "hello world".len);
    try prev.insert(5, ""); // no-op
    try prev.delete(5, 1); // create a non-empty gap between "hello" and "world"

    var new_storage: [128]u8 = undefined;
    var grown = GapBuffer.new_from_smaller(&prev, new_storage[0..]);

    try std.testing.expectEqual(prev.gap.start, grown.gap.start);
    try std.testing.expectEqual(prev.data.len - prev.gap.close, grown.data.len - grown.gap.close);

    const got = try collect(&grown, std.testing.allocator);
    defer std.testing.allocator.free(got);
    try std.testing.expectEqualStrings("helloworld", got);
    try std.testing.expectEqualStrings("hello", grown.slices().prefix);
    try std.testing.expectEqualStrings("world", grown.slices().suffix);
}

fn collect(buf: *const GapBuffer, allocator: std.mem.Allocator) ![]u8 {
    const n = buf.len();
    var out = try allocator.alloc(u8, n);
    errdefer allocator.free(out);

    var it = buf.iterator();
    var i: usize = 0;
    while (it.next()) |b| {
        out[i] = b;
        i += 1;
    }

    return out;
}
