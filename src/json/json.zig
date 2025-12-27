const std = @import("std");
const mem = std.mem;
const base = @import("base");
const Arena = base.Arena;
const Allocator = mem.Allocator;

const str8 = []const u8;
const OOM = Allocator.Error;

const Token_Kind = enum {
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

const Range = struct {
    start: u32,
    close: u32,
    line_num: u32,
    line_idx: u32,
};

const Token = struct {
    kind: Token_Kind,
    range: Range,
};

pub fn parse(
    arena: *Arena,
    contents: []const u8,
) OOM!Tree_Root {
    const tokens = try lex(arena.allocator(), contents);

    var parser: Parser = .init(arena, tokens);
    try parse_any(&parser);

    return build_tree(parser);
}

fn lex(alloc: Allocator, contents: []const u8) ![]const Token {
    var pos: u32 = 0;
    var state: enum { none, string, number } = .none;
    var line_num: u32 = 0;
    var line_idx: u32 = 0;

    var tokens: std.ArrayList(Token) = .empty;

    while (pos < contents.len) : (pos += 1) {
        const prev: ?*Token = if (tokens.items.len > 0) &tokens.items[tokens.items.len - 1] else null;
        switch (state) {
            .none => {
                const range = Range{
                    .start = pos,
                    .close = pos + 1,
                    .line_idx = line_idx,
                    .line_num = line_num,
                };
                switch (contents[pos]) {
                    '{' => {
                        try tokens.append(alloc, .{ .kind = .l_curly, .range = range });
                    },
                    '}' => {
                        try tokens.append(alloc, .{ .kind = .r_curly, .range = range });
                    },
                    '[' => {
                        try tokens.append(alloc, .{ .kind = .l_bracket, .range = range });
                    },
                    ']' => {
                        try tokens.append(alloc, .{ .kind = .r_bracket, .range = range });
                    },
                    ',' => {
                        try tokens.append(alloc, .{ .kind = .comma, .range = range });
                    },
                    ':' => {
                        try tokens.append(alloc, .{ .kind = .colon, .range = range });
                    },
                    '-', '+', '0'...'9' => {
                        state = .number;
                        try tokens.append(alloc, .{ .kind = .number, .range = range });
                    },
                    '"' => {
                        state = .string;
                        try tokens.append(alloc, .{ .kind = .string, .range = range });
                    },
                    'n' => {
                        const token = try tokens.addOne(alloc);
                        keyword_or_err("null", .null, contents, range, token);
                        state = .none;
                    },
                    't' => {
                        const token = try tokens.addOne(alloc);
                        keyword_or_err("true", .true, contents, range, token);
                        state = .none;
                    },
                    'f' => {
                        const token = try tokens.addOne(alloc);
                        keyword_or_err("false", .false, contents, range, token);
                        state = .none;
                    },
                    else => if (!std.ascii.isWhitespace(contents[pos])) {
                        try tokens.append(alloc, .{ .kind = .err, .range = range });
                    } else if (contents[pos] == '\n') {
                        line_idx = pos;
                        line_num += 1;
                    },
                }
            },
            .number => {
                switch (contents[pos]) {
                    'e', 'E', '0'...'9', '.' => {
                        prev.?.range.close += 1;
                    },
                    else => {
                        state = .none;
                        pos -= 1;
                    },
                }
            },
            .string => {
                prev.?.range.close += 1;
                if (contents[pos] == '"') {
                    state = .none;
                }
            },
        }
    }

    return tokens.items;
}

fn keyword_or_err(comptime keyword: str8, kind: Token_Kind, contents: str8, char_range: Range, token: *Token) void {
    var range = char_range;
    const pos = range.start;
    // todo: check in godbolt to see if mem.eql is optimized out
    const at_keyword = contents.len > pos + keyword.len - 1 and mem.eql(u8, contents[pos..][0..keyword.len], keyword);
    if (at_keyword) {
        range.close = pos + @as(u32, @intCast(keyword.len));
        token.* = .{ .kind = kind, .range = range };
    } else {
        token.* = .{ .kind = .err, .range = range };
    }
}

const Tree_Kind = union(enum) {
    err: []const u8,
    obj,
    array,
    kv,

    fn err_value(value: []const u8) Tree_Kind {
        return .{ .err = value };
    }
};

pub const Tree_Root = struct {
    tree: Tree,
    arena: *Arena,
};

const Tree = struct {
    kind: Tree_Kind,
    children: base.IntrusiveDoublyLinkedList(Child),

    fn empty(kind: Tree_Kind) Tree {
        return .{ .kind = kind, .children = .zero };
    }
};

const Child = struct {
    data: Data,
    next: *Child,
    prev: *Child,

    const Data = union(enum) {
        tree: Tree,
        tok: Token,
    };

    fn init(child: *Child, data: Data) void {
        child.* = .{
            .data = data,
            .next = child,
            .prev = child,
        };
    }
};

const Parser = struct {
    tokens: []const Token,
    pos: usize,
    arena: *Arena,
    events: std.ArrayList(Event),

    const Event = union(enum) {
        start: struct { kind: Tree_Kind },
        close,
        advance,

        fn open(kind: Tree_Kind) Event {
            return .{ .start = .{ .kind = kind } };
        }
    };

    fn init(arena: *Arena, tokens: []const Token) Parser {
        return .{
            .tokens = tokens,
            .pos = 0,
            .arena = arena,
            .events = .empty,
        };
    }

    fn open(p: *Parser) !usize {
        const mark = p.events.items.len;
        try p.events.append(p.arena.allocator(), .open(.err_value("expected value")));
        return mark;
    }

    fn close(
        p: *Parser,
        m: usize,
        kind: Tree_Kind,
    ) !void {
        p.events.items[m] = .open(kind);
        try p.events.append(p.arena.allocator(), .close);
    }

    fn advance(p: *Parser) OOM!void {
        std.debug.assert(!p.eof());
        // self.fuel.set(256);
        try p.events.append(p.arena.allocator(), .advance);
        p.pos += 1;
    }

    fn eof(p: *const Parser) bool {
        return p.pos == p.tokens.len;
    }

    fn nth(p: *const Parser, lookahead: usize) Token_Kind {
        // if self.fuel.get() == 0 {
        //   panic!("parser is stuck")
        // }
        // self.fuel.set(self.fuel.get() - 1);
        if (p.tokens.len <= p.pos + lookahead) {
            return .eof;
        }
        return p.tokens[p.pos + lookahead].kind;
    }

    fn at(p: *const Parser, kind: Token_Kind) bool {
        return p.nth(0) == kind;
    }

    fn eat(p: *Parser, kind: Token_Kind) !bool {
        if (p.at(kind)) {
            try p.advance();
            return true;
        }
        return false;
    }

    fn assert(p: *Parser, kind: Token_Kind) OOM!void {
        std.debug.assert(try p.eat(kind));
    }

    fn assert_opening(p: *Parser, kind: Tree_Kind) OOM!usize {
        const m = try p.open();
        try p.assert(switch (kind) {
            .obj => .l_curly,
            .array => .l_bracket,
            else => unreachable,
        });
        return m;
    }

    fn expect(p: *Parser, kind: Token_Kind) !void {
        if (try p.eat(kind)) {
            return;
        }
        const m = try p.open();
        const error_message = try std.fmt.allocPrint(p.arena.allocator(), "expected {t}", .{kind});
        try p.close(m, .err_value(error_message));

        // // TODO: Error reporting.
        // eprintln!("expected {kind:?}");
    }

    fn explicit_error(p: *Parser, err: []const u8) OOM!void {
        const m = try p.open();
        try p.close(m, .err_value(err));
    }

    fn advance_with_error(p: *Parser, err: []const u8) OOM!void {
        const m = try p.open();
        // TODO: Error reporting.
        // std.debug.print("{s}\n", .{err});
        try p.advance();
        try p.close(m, .err_value(err));
    }
};

fn build_tree(parser: Parser) OOM!Tree_Root {
    var p = parser;
    const tokens = p.tokens;
    var tok_pos: usize = 0;
    var stack: std.ArrayList(Tree) = .empty;

    // Special case: pop the last `Close` event to ensure
    // that the stack is non-empty inside the loop.
    std.debug.assert(p.events.pop().? == .close);
    const alloc = p.arena.allocator();

    for (p.events.items) |event| {
        switch (event) {
            // Starting a new node; just push an empty tree to the stack.
            .start => |open_event| {
                try stack.append(alloc, .empty(open_event.kind));
            },
            // A tree is done.
            // Pop it off the stack and append to a new current tree.
            .close => {
                const tree = stack.pop().?;
                const sub_tree = try alloc.create(Child);
                sub_tree.init(.{ .tree = tree });
                stack.items[stack.items.len - 1].children.append(sub_tree);
            },
            // Consume a token and append it to the current tree
            .advance => {
                const token = tokens[tok_pos];
                tok_pos += 1;

                const sub_tree = try alloc.create(Child);
                sub_tree.init(.{ .tok = token });
                stack.items[stack.items.len - 1].children.append(sub_tree);
            },
        }
    }

    // Our parser will guarantee that all the trees are closed
    // and cover the entirety of tokens.
    std.debug.assert(stack.items.len == 1);
    std.debug.assert(tok_pos == tokens.len);

    return Tree_Root{
        // TODO: remove arena, just pass around trees
        .arena = p.arena,
        .tree = stack.pop().?,
    };
}

fn parse_any(p: *Parser) OOM!void {
    const kind = p.nth(0);
    switch (kind) {
        .l_curly => {
            try parse_object(p);
        },
        .l_bracket => {
            try parse_array(p);
        },
        .number, .null, .string, .true, .false => {
            try p.advance();
        },
        .eof => return,
        else => {
            try p.advance_with_error("unexpected token");
        },
    }
}

fn parse_object(p: *Parser) OOM!void {
    const m = try p.assert_opening(.obj);
    while (!p.at(.r_curly) and !p.eof()) {
        if (p.at(.comma)) {
            try p.explicit_error("expected key: value");
            try p.advance();
            continue;
        }
        try parse_key_value(p);
        if (!p.at(.r_curly)) {
            try p.expect(.comma);
        }
    }
    try p.expect(.r_curly);
    try p.close(m, .obj);
}

fn parse_key_value(p: *Parser) OOM!void {
    const m = try p.open();
    try p.expect(.string);
    try p.expect(.colon);
    try parse_any(p);
    try p.close(m, .kv);
}

fn parse_array(p: *Parser) OOM!void {
    const m = try p.assert_opening(.array);
    while (!p.at(.r_bracket) and !p.eof()) {
        if (p.at(.comma)) {
            try p.explicit_error("expected value");
            try p.advance();
            continue;
        }
        try parse_any(p);
        if (!p.at(.r_bracket)) {
            try p.expect(.comma);
        }
    }
    try p.expect(.r_bracket);
    try p.close(m, .array);
}

pub fn dbg_print_tree(w: *std.io.Writer, tree: *const Tree, depth: usize, contents: []const u8) !void {
    const INDENTATION = 1;
    try w.splatByteAll(' ', depth * INDENTATION);
    try w.print("{t}:{s}\n", .{
        tree.kind, switch (tree.kind) {
            .err => |err| err,
            else => "",
        },
    });

    for (tree.children.items) |child| {
        switch (child) {
            .tree => try dbg_print_tree(w, &child.tree, depth + 1, contents),
            .tok => {
                try w.splatByteAll(' ', depth + 1 * INDENTATION);
                try w.print("{t} [{s}]\n", .{ child.tok.kind, contents[child.tok.range.start.byte..child.tok.range.close.byte] });
            },
        }
    }
}

pub const SyntaxError = struct {
    next: *SyntaxError,
    prev: *SyntaxError,
    message: []const u8,
    start: u32,
    close: u32,
    line_start: u32,
    line_close: u32,
    line_start_idx: u32,
    line_close_idx: u32,

    const zero = SyntaxError{
        .next = &zero,
        .prev = &zero,
        .message = "",
    };

    // TODO: make general range type
    pub fn line_and_char(err: *const SyntaxError, contents: []const u8) struct { start_char: UtfOffset, start_line: u32, close_char: UtfOffset, close_line: u32 } {
        // PERF: yikes, entire file up to offset?
        const start_line_offset = unicode_length(contents[0..err.line_start_idx]);
        const close_line_offset = if (err.line_close_idx != err.line_start_idx) unicode_length(contents[0..err.line_close_idx]) else start_line_offset;
        const start_char_offset = unicode_length(contents[err.line_start_idx..err.start]).add(start_line_offset);
        const close_char_offset = if (err.line_close_idx != err.line_start_idx)
            unicode_length(contents[err.line_close_idx..err.close]).add(close_line_offset)
        else
            unicode_length(contents[err.start..err.close]).add(start_char_offset);

        return .{
            .start_char = start_char_offset,
            .start_line = err.line_start,
            .close_char = close_char_offset,
            .close_line = err.line_close,
        };
    }
};

const UtfOffset = struct {
    utf8: u32,
    utf16: u32,

    fn add(self: UtfOffset, other: UtfOffset) UtfOffset {
        return .{
            .utf8 = self.utf8 + other.utf8,
            .utf16 = self.utf16 + other.utf16,
        };
    }
};

fn unicode_length(slice: []const u8) UtfOffset {
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

    return .{ .utf8 = utf8_count, .utf16 = utf16_count };
}

fn first_tree_token(tree: *const Tree) ?*const Token {
    var first_child = tree.children.first;
    while (first_child) |child| {
        switch (child.data) {
            .tok => |*tok| return tok,
            .tree => |sub_tree| {
                first_child = sub_tree.children.first;
            },
        }
    }
    return null;
}

fn last_tree_token(tree: *const Tree) ?*const Token {
    var last_child = tree.children.last();
    while (last_child) |child| {
        switch (child.data) {
            .tok => |*tok| return tok,
            .tree => |sub_tree| {
                last_child = sub_tree.children.last();
            },
        }
    }
    return null;
}

fn first_child_token(child: *const Child) ?*const Token {
    switch (child.data) {
        .tok => |*tok| return tok,
        .tree => |sub_tree| {
            return first_tree_token(&sub_tree);
        },
    }
}

fn last_child_token(child: *const Child) ?*const Token {
    switch (child.data) {
        .tok => |*tok| return tok,
        .tree => |sub_tree| {
            return last_tree_token(&sub_tree);
        },
    }
}

pub fn syntax_errors(arena: *Arena, tree: *const Tree) OOM!base.IntrusiveDoublyLinkedList(SyntaxError) {
    var result: base.IntrusiveDoublyLinkedList(SyntaxError) = .zero;
    const child = blk: {
        var c: Child = undefined;
        c.init(.{ .tree = tree.* });
        break :blk c;
    };
    try syntax_errors_impl(arena, &child, &result);
    return result;
}

fn syntax_errors_impl(arena: *Arena, child: *const Child, result: *base.IntrusiveDoublyLinkedList(SyntaxError)) OOM!void {
    if (std.meta.activeTag(child.data) != .tree) {
        return;
    }

    if (child.data.tree.kind != .err) {
        var iter = child.data.tree.children.iter();
        while (iter.next()) |sub_child| {
            try syntax_errors_impl(arena, sub_child, result);
        }
        return;
    }
    const error_message = child.data.tree.kind.err;

    const first_token = first_child_token(child);
    const last_token = last_child_token(child);
    const prev_token = if (child.prev != child) last_child_token(child.prev) else null;
    const next_token = if (child.next != child) first_child_token(child.next) else null;
    var start: Range = .{
        .close = 0,
        .start = 0,
        .line_idx = 0,
        .line_num = 0,
    };

    if (first_token) |tok| {
        start = tok.range;
    } else if (prev_token) |tok| {
        start = tok.range;
        start.start = tok.range.close;
    }

    var close: Range = start;

    if (last_token) |tok| {
        close = tok.range;
    } else if (next_token) |tok| {
        close = tok.range;
        close.close = tok.range.start;
    }

    const err = try arena.create(SyntaxError);
    err.* = .{
        .message = error_message,
        .start = start.start - start.line_idx,
        .close = close.close - close.line_idx,
        .line_start = start.line_num,
        .line_close = close.line_num,
        .line_start_idx = start.line_idx,
        .line_close_idx = close.line_idx,
        .next = err,
        .prev = err,
    };
    result.append(err);
}

test parse {
    const table: []const [2][]const u8 = &.{
        .{
            "{}",
            \\obj:
            \\ l_curly [{]
            \\ r_curly [}]
            \\
            ,
        },
        .{
            "[]",
            \\array:
            \\ l_bracket [[]
            \\ r_bracket []]
            \\
            ,
        },
        .{
            "[1, 2, 3]",
            \\array:
            \\ l_bracket [[]
            \\ number [1]
            \\ comma [,]
            \\ number [2]
            \\ comma [,]
            \\ number [3]
            \\ r_bracket []]
            \\
            ,
        },
        .{
            \\{"key": "value", "foo": "bar",}
            ,
            \\obj:
            \\ l_curly [{]
            \\ kv:
            \\  string ["key"]
            \\  colon [:]
            \\  string ["value"]
            \\ comma [,]
            \\ kv:
            \\  string ["foo"]
            \\  colon [:]
            \\  string ["bar"]
            \\ comma [,]
            \\ r_curly [}]
            \\
            ,
        },
        .{
            \\{"key": "value" "foo": "bar",}
            ,
            \\obj:
            \\ l_curly [{]
            \\ kv:
            \\  string ["key"]
            \\  colon [:]
            \\  string ["value"]
            \\ err:expected comma
            \\ kv:
            \\  string ["foo"]
            \\  colon [:]
            \\  string ["bar"]
            \\ comma [,]
            \\ r_curly [}]
            \\
            ,
        },
        .{
            "[,]",
            \\array:
            \\ l_bracket [[]
            \\ err:expected value
            \\ comma [,]
            \\ r_bracket []]
            \\
            ,
        },
        .{
            \\{,}
            ,
            \\obj:
            \\ l_curly [{]
            \\ err:expected key: value
            \\ comma [,]
            \\ r_curly [}]
            \\
            ,
        },
    };

    var arena = Arena.init(.{}) catch @panic("OOM");
    defer arena.deinit();
    for (table) |test_case| {
        const input, const expected = test_case;

        var scoped = arena.scoped();
        defer scoped.release();

        const result = try parse(scoped.arena, input);

        var actual_tree_writer: std.Io.Writer.Allocating = .init(scoped.arena.allocator());
        defer actual_tree_writer.deinit();
        try dbg_print_tree(&actual_tree_writer.writer, &result.tree, 0, input);
        const actual_tree = actual_tree_writer.written();

        try std.testing.expectEqualStrings(expected, actual_tree);
    }
}

// # Incremental + robust parse
//
// 1. Identify "tree" ranges, i.e. objects and arrays, potentially key values/array items?
//   1.1. If tree unbalanced, determine where to insert missing tokens
//      option A: insert missing closers/openers before/after (respectively) the mismatched next/previous delimiter, i.e. [{] => [{}], and {]} => {[]}
//      option B: treat delimiters as the same, i.e. [{]] is fine.
//          This seems less valuable intuitively,
//          it is less likely that the user mixes up bracket pairs,
//          to having an opened but not closed (or vice versa) pair
// 2. Parse tokens within ranges
//  2.1. Insert non pre-extracted ranges from 1. (array items, key/values) if not already extracted / cleaned up in prepass
// 3. read stream of incremental edits
//  if (edit does not contain brackets/delimiters) => do basic edit + reparse of deepest range containing edit
//  else if (delimiters are at expected balance boundaries) => replace inserted balancers with edit ranges, treat prefix,suffix around bracket as first case (non bracket containing edits)
//  else  => do insert, and bracket balancing, and reparse affected ranges
