const base = @import("base");
const Arena = base.Arena;
const std = @import("std");

pub const Token = struct {
    kind: Kind,
    range: Range,
    line: Line,

    pub const Range = base.Range(Offset);

    pub const Kind = enum {
        l_curly,
        r_curly,
        l_bracket,
        r_bracket,
        comma,
        colon,
        string,
        number,
        null,
        true,
        false,
        eof,
        err,
    };
};

const str8 = []const u8;
pub const ParseError = std.mem.Allocator.Error || error{InvalidUtf8};

pub const Line = struct {
    num: u32,
    idx: Offset,
};

pub const Offset = struct {
    byte: u32,
    utf8: u32,
    utf16: u32,

    pub fn add(self: Offset, other: Offset) Offset {
        return .{
            .byte = self.byte + other.byte,
            .utf8 = self.utf8 + other.utf8,
            .utf16 = self.utf16 + other.utf16,
        };
    }

    fn advance(self: Offset, char: u8) error{InvalidUtf8}!Offset {
        const byte_count = std.unicode.utf8ByteSequenceLength(char) catch return error.InvalidUtf8;
        const utf8_count = 1; // One code point

        // UTF-16: supplementary characters (4-byte UTF-8) need 2 code units
        const utf16_count: u32 = if (byte_count == 4)
            2
        else
            1;
        return self.add(.{
            .byte = byte_count,
            .utf8 = utf8_count,
            .utf16 = utf16_count,
        });
    }
};

pub const Lexer = struct {
    state: State = .none,
    offset: Offset = std.mem.zeroes(Offset),
    line_num: u32 = 0,
    line_idx: Offset = std.mem.zeroes(Offset),
    tokens: base.ArenaList(Token) = .empty,

    pub const zero: Lexer = .{};

    const State = union(enum) {
        none,
        string,
        number,
        keyword: KeywordState,
    };

    const KeywordState = struct {
        expected: Keyword,
        matched: u8,

        const Keyword = enum {
            null,
            true,
            false,

            fn str(self: Keyword) []const u8 {
                return switch (self) {
                    .null => "null",
                    .true => "true",
                    .false => "false",
                };
            }

            fn token_kind(self: Keyword) Token.Kind {
                return switch (self) {
                    .null => .null,
                    .true => .true,
                    .false => .false,
                };
            }
        };
    };
};

pub fn lex(lexer: *Lexer, arena: *Arena, contents: []const u8) ParseError!void {
    var buf_idx: u32 = 0;

    while (buf_idx < contents.len) {
        const byte = contents[buf_idx];
        const byte_len = std.unicode.utf8ByteSequenceLength(byte) catch return error.InvalidUtf8;
        const next_buf_idx = buf_idx + byte_len;
        const next_offset = lexer.offset.add(.{
            .byte = byte_len,
            .utf8 = 1,
            .utf16 = if (byte_len == 4) 2 else 1,
        });

        var advance = true;
        defer if (advance) {
            lexer.offset = next_offset;
            buf_idx = next_buf_idx;
        };

        const bytes = contents[buf_idx..next_buf_idx];
        const char = std.unicode.utf8Decode(bytes) catch unreachable;

        const prev: ?*Token = if (lexer.tokens.items.len > 0) &lexer.tokens.items[lexer.tokens.items.len - 1] else null;
        switch (lexer.state) {
            .none => {
                if (bytes.len == 1 and std.ascii.isWhitespace(@truncate(char))) {
                    if (char == '\n') {
                        lexer.line_idx = lexer.offset;
                        lexer.line_num += 1;
                    }
                    continue;
                }
                var token = try lexer.tokens.add_one(arena);
                token.* = .{
                    .kind = .err,
                    .line = .{
                        .idx = lexer.line_idx,
                        .num = lexer.line_num,
                    },
                    .range = .{
                        .start = lexer.offset,
                        .close = next_offset,
                    },
                };
                switch (char) {
                    '{' => {
                        token.kind = .l_curly;
                    },
                    '}' => {
                        token.kind = .r_curly;
                    },
                    '[' => {
                        token.kind = .l_bracket;
                    },
                    ']' => {
                        token.kind = .r_bracket;
                    },
                    ',' => {
                        token.kind = .comma;
                    },
                    ':' => {
                        token.kind = .colon;
                    },
                    '-', '+', '0'...'9' => {
                        lexer.state = .number;
                        token.kind = .number;
                    },
                    '"' => {
                        lexer.state = .string;
                        token.kind = .string;
                    },
                    'n' => {
                        lexer.state = .{ .keyword = .{ .expected = .null, .matched = 1 } };
                    },
                    't' => {
                        lexer.state = .{ .keyword = .{ .expected = .true, .matched = 1 } };
                    },
                    'f' => {
                        lexer.state = .{ .keyword = .{ .expected = .false, .matched = 1 } };
                    },
                    else => {},
                }
            },
            .number => {
                switch (char) {
                    'e', 'E', '0'...'9', '.' => {
                        prev.?.range.close = next_offset;
                    },
                    else => {
                        lexer.state = .none;
                        advance = false;
                    },
                }
            },
            .string => {
                prev.?.range.close = next_offset;
                if (byte == '"') {
                    lexer.state = .none;
                }
            },
            .keyword => |*kw| {
                const expected_str = kw.expected.str();
                if (kw.matched < expected_str.len and byte == expected_str[kw.matched]) {
                    kw.matched += 1;
                    prev.?.range.close = next_offset;
                    if (kw.matched == expected_str.len) {
                        prev.?.kind = kw.expected.token_kind();
                        lexer.state = .none;
                    }
                } else {
                    lexer.state = .none;
                    advance = false;
                }
            },
        }
    }
}
