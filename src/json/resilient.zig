const std = @import("std");

const base = @import("base");
const Arena = base.Arena;

const lxr = @import("lex.zig");
const Lexer = lxr.Lexer;
const Token = lxr.Token;
const ParseError = lxr.ParseError;
const Offset = lxr.Offset;
const Line = lxr.Line;
const OOM = std.mem.Allocator.Error;

pub fn parse(
    arena: *Arena,
    lexer: *const Lexer,
) ParseError!Tree_Root {
    const tokens = lexer.tokens.items;
    var parser: Parser = .init(arena, tokens);
    try parse_any(&parser);

    return build_tree(parser);
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

// TODO: don't store Arena, and create zero value
pub const Tree_Root = struct {
    tree: Tree,
    tokens: []const Token,
};

const Tree = struct {
    kind: Tree_Kind,
    children: base.IntrusiveDoublyLinkedList(Child),

    pub fn empty(kind: Tree_Kind) Tree {
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

    fn nth(p: *const Parser, lookahead: usize) Token.Kind {
        // if self.fuel.get() == 0 {
        //   panic!("parser is stuck")
        // }
        // self.fuel.set(self.fuel.get() - 1);
        if (p.tokens.len <= p.pos + lookahead) {
            return .eof;
        }
        return p.tokens[p.pos + lookahead].kind;
    }

    fn at(p: *const Parser, kind: Token.Kind) bool {
        return p.nth(0) == kind;
    }

    fn eat(p: *Parser, kind: Token.Kind) !bool {
        if (p.at(kind)) {
            try p.advance();
            return true;
        }
        return false;
    }

    fn assert(p: *Parser, kind: Token.Kind) OOM!void {
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

    fn expect(p: *Parser, kind: Token.Kind) !void {
        if (try p.eat(kind)) {
            return;
        }
        const m = try p.open();
        const error_message = try std.fmt.allocPrint(p.arena.allocator(), "expected {t}", .{kind});
        try p.skip_consecutive_errors();
        try p.close(m, .err_value(error_message));
    }

    fn skip_consecutive_errors(p: *Parser) OOM!void {
        while (p.at(.err)) {
            try p.advance();
        }
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

pub fn build_tree(parser: Parser) OOM!Tree_Root {
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
        .tree = stack.pop().?,
        .tokens = tokens,
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
        .err => {
            const m = try p.open();
            try p.skip_consecutive_errors();
            try p.close(m, .err_value("unexpected token"));
        },
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

    var child_iter = tree.children.iter();
    while (child_iter.next()) |child| {
        switch (child.data) {
            .tree => |*sub_tree| try dbg_print_tree(w, sub_tree, depth + 1, contents),
            .tok => |tok| {
                try w.splatByteAll(' ', depth + 1 * INDENTATION);
                try w.print("{t} [{s}]\n", .{ tok.kind, contents[tok.range.start.byte..tok.range.close.byte] });
            },
        }
    }
}

pub const Encoding = enum {
    utf8,
    utf16,
};

pub const SyntaxError = struct {
    next: *SyntaxError,
    prev: *SyntaxError,
    message: []const u8,
    range: base.Range(struct { char: Offset, line: Line }),

    const zero = SyntaxError{
        .next = &zero,
        .prev = &zero,
        .message = "",
    };

    pub fn line_and_char(err: *const SyntaxError, encoding: Encoding) base.Range(struct { line: u32, char: u32 }) {
        const start_char, const start_line_idx, const close_char, const close_line_idx = switch (encoding) {
            .utf8 => .{
                err.range.start.char.utf8,
                err.range.start.line.idx.utf8,
                err.range.close.char.utf8,
                err.range.close.line.idx.utf8,
            },
            .utf16 => .{
                err.range.start.char.utf16,
                err.range.start.line.idx.utf16,
                err.range.close.char.utf16,
                err.range.close.line.idx.utf16,
            },
        };
        const start_char_rel = if (err.range.start.line.num == 0)
            start_char
        else
            start_char - start_line_idx - 1;
        const close_char_rel = if (err.range.close.line.num == 0)
            close_char
        else
            close_char - close_line_idx - 1;
        return .{
            .start = .{
                .char = start_char_rel,
                .line = err.range.start.line.num,
            },
            .close = .{
                .char = close_char_rel,
                .line = err.range.close.line.num,
            },
        };
    }
};

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
    var start = std.mem.zeroes(Token.Range);
    var start_line: Line = std.mem.zeroes(Line);

    if (first_token) |tok| {
        start = tok.range;
        start_line = tok.line;
    } else if (prev_token) |tok| {
        start = tok.range;
        start_line = tok.line;
        start.start = tok.range.close;
    }

    var close: Token.Range = start;
    var close_line = start_line;

    if (last_token) |tok| {
        close = tok.range;
        close_line = tok.line;
    } else if (next_token) |tok| {
        close = tok.range;
        close_line = tok.line;
        close.close = tok.range.start;
    }

    const err = try arena.create(SyntaxError);
    err.* = .{
        .message = error_message,
        .range = .{
            .start = .{
                .char = start.start,
                .line = start_line,
            },
            .close = .{
                .char = close.close,
                .line = close_line,
            },
        },
        .next = err,
        .prev = err,
    };
    result.append(err);
}

test parse {
    const Case = struct { []const []const u8, []const u8 };
    const table: []const Case = &.{
        .{
            &.{
                \\{}
            },
            \\obj:
            \\ l_curly [{]
            \\ r_curly [}]
            \\
        },
        .{
            &.{
                \\{
                ,
                \\}
                ,
            },
            \\obj:
            \\ l_curly [{]
            \\ r_curly [}]
            \\
        },
        .{
            &.{
                \\[]
            },
            \\array:
            \\ l_bracket [[]
            \\ r_bracket []]
            \\
        },
        .{
            &.{
                \\[1, 2, 3]
            },
            \\array:
            \\ l_bracket [[]
            \\ number [1]
            \\ comma [,]
            \\ number [2]
            \\ comma [,]
            \\ number [3]
            \\ r_bracket []]
            \\
        },
        .{
            &.{
                \\[1, 2
                ,
                \\, 3]
                ,
            },
            \\array:
            \\ l_bracket [[]
            \\ number [1]
            \\ comma [,]
            \\ number [2]
            \\ comma [,]
            \\ number [3]
            \\ r_bracket []]
            \\
        },
        .{
            &.{
                \\{"key": "value", "foo": "bar",}
            },
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
        },
        .{
            &.{
                \\{"key": "val
                ,
                \\ue", "foo": "bar",}
                ,
            },
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
        },
        .{
            &.{
                \\{"key": "value" "foo": "bar",}
            },
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
        },
        .{
            &.{
                \\{
                \\  "key": "value"
                \\  "foo": "bar",
                \\}
                ,
            },
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
        },
        .{
            &.{
                \\[,]
            },
            \\array:
            \\ l_bracket [[]
            \\ err:expected value
            \\ comma [,]
            \\ r_bracket []]
            \\
        },
        .{
            &.{
                \\{,}
            },
            \\obj:
            \\ l_curly [{]
            \\ err:expected key: value
            \\ comma [,]
            \\ r_curly [}]
            \\
        },
        .{
            &.{
                \\{"a": tr
                ,
                \\ue, "b": fal
                ,
                \\se, "c": nu
                ,
                \\ll}
                ,
            },
            \\obj:
            \\ l_curly [{]
            \\ kv:
            \\  string ["a"]
            \\  colon [:]
            \\  true [true]
            \\ comma [,]
            \\ kv:
            \\  string ["b"]
            \\  colon [:]
            \\  false [false]
            \\ comma [,]
            \\ kv:
            \\  string ["c"]
            \\  colon [:]
            \\  null [null]
            \\ r_curly [}]
            \\
        },
    };

    var arena = Arena.init(.{}) catch @panic("OOM");
    defer arena.deinit();
    for (table) |test_case| {
        const input_parts, const expected = test_case;

        var scoped = arena.scoped();
        defer scoped.release();

        var lexed = Lexer{};
        for (input_parts) |part| {
            try lxr.lex(&lexed, scoped.arena, part);
        }

        var parser: Parser = .init(scoped.arena, lexed.tokens.items);
        try parse_any(&parser);
        const result = try build_tree(parser);

        var input_len: usize = 0;
        for (input_parts) |part| input_len += part.len;
        const input = try scoped.arena.allocator().alloc(u8, input_len);
        var offset: usize = 0;
        for (input_parts) |part| {
            @memcpy(input[offset..][0..part.len], part);
            offset += part.len;
        }

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
