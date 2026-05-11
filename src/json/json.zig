const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
pub const OOM = Allocator.Error;

const base = @import("base");
const Arena = base.Arena;

pub const hashed = @import("hashed.zig");
pub const lexer = @import("lex.zig");
pub const lex = lexer.lex;
pub const Lexer = lexer.Lexer;
pub const Token = lexer.Token;
pub const resilient = @import("resilient.zig");

fn unicode_length(slice: []const u8) lexer.Offset {
    var utf8_count: u32 = 0;
    var utf16_count: u32 = 0;
    var i: usize = 0;

    while (i < slice.len) {
        const byte = slice[i];
        const seq_len = std.unicode.utf8ByteSequenceLength(byte) catch 1;

        utf8_count += 1; // One code point

        // UTF-16: supplementary characters (4-byte UTF-8) need 2 code units
        if (seq_len == 4) {
            utf16_count += 2;
        } else {
            utf16_count += 1;
        }

        i += seq_len;
    }

    return .{ .utf8 = utf8_count, .utf16 = utf16_count, .byte = @intCast(slice.len) };
}

test "resilient parse skips comments" {
    var arena = try Arena.init(.{});
    defer arena.deinit();

    const input =
        \\// line comment
        \\/* block comment */
        \\{}
    ;

    var l: Lexer = .zero;
    try lex(&l, &arena, input);

    _ = try resilient.parse(&arena, &l);
}
