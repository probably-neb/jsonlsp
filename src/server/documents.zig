const std = @import("std");
const Alloc = std.mem.Allocator;

const base = @import("base");
const Arena = base.Arena;
const json = @import("json");
const lsp = @import("lsp");
const GapBuffer = @import("gap-buffer.zig").GapBuffer;

const OOM = error{OutOfMemory};
const DOCUMENTS_MAX: usize = 4096;

pub const Document = struct {
    next: usize,
    uri: []const u8,
    version: i32,
    buf: GapBuffer,
    buf_arena: Arena,
    language_id: []const u8,
    tree: ?json.Tree_Root,
    lex_arena: Arena,
    tree_arena: Arena,

    const zero = Document{
        .next = 0,
        .lex_arena = .zero,
        .tree_arena = .zero,
        .buf_arena = .zero,
        .uri = "",
        .version = 0,
        .buf = .empty,
        .language_id = "",
        .tree = null,
    };
};

pub const DocumentStore = struct {
    documents: [DOCUMENTS_MAX]Document,
    documents_open: usize,
    documents_free: usize,
    documents_used: usize,

    pub fn init() DocumentStore {
        var store = DocumentStore{
            .documents = undefined,
            .documents_open = DOCUMENTS_MAX,
            .documents_free = 0,
            .documents_used = 0,
        };
        for (&store.documents, 0..) |*doc, i| {
            doc.* = .zero;
            doc.next = i + 1;
        }
        return store;
    }

    pub fn deinit(store: *DocumentStore) void {
        var it = store.iter();
        while (it.next()) |i| {
            const doc = &store.documents[i];
            _ = store.close(doc.uri);
        }
        store.* = undefined;
    }

    fn find(store: *DocumentStore, uri: []const u8) ?usize {
        var it = store.iter();
        while (it.next()) |i| {
            if (std.mem.eql(u8, store.documents[i].uri, uri)) return i;
        }
        return null;
    }

    pub fn iter(store: *DocumentStore) Document_Iter {
        return .{ .store = store, .idx = store.documents_open };
    }

    const Document_Iter = struct {
        store: *DocumentStore,
        idx: usize,

        pub fn next(it: *Document_Iter) ?usize {
            if (it.idx == DOCUMENTS_MAX) return null;
            const result = it.idx;
            it.idx = it.store.documents[result].next;
            return result;
        }
    };

    pub const OpenError = error{ OpenDocumentLimitReached, DocumentAlreadyOpen } || json.ParseError || Arena.InitError;

    pub fn open(store: *DocumentStore, uri: []const u8, contents: []const u8, version: i32, language_id: []const u8) OpenError!void {
        if (store.find(uri) != null) return error.DocumentAlreadyOpen;
        if (store.documents_free == DOCUMENTS_MAX) {
            return error.OpenDocumentLimitReached;
        }

        const doc = &store.documents[store.documents_free];
        const next_free = doc.next;

        var buf_arena: Arena = try .init(.{});
        const language_id_owned = try buf_arena.dupe(u8, language_id);
        const buf = try buf_arena.alloc(u8, contents.len * 2);
        @memcpy(buf[0..contents.len], contents);
        const gap_buf = GapBuffer.init(buf, contents.len);

        var lex_arena: Arena = try .init(.{});
        var lexer: json.Lexer = .zero;
        const slices = gap_buf.slices();
        try json.lex(&lexer, &lex_arena, slices.prefix);
        try json.lex(&lexer, &lex_arena, slices.suffix);

        var tree_arena: Arena = try .init(.{});
        const tree = try json.parse(&tree_arena, &lexer);

        doc.* = .{
            .next = store.documents_open,
            .uri = try buf_arena.dupe(u8, uri),
            .buf = gap_buf,
            .version = version,
            .language_id = language_id_owned,
            .buf_arena = buf_arena,
            .tree = tree,
            .lex_arena = lex_arena,
            .tree_arena = tree_arena,
        };

        store.documents_open = store.documents_free;
        store.documents_free = next_free;
        store.documents_used += 1;
    }

    pub fn close(store: *DocumentStore, uri: []const u8) bool {
        const idx = store.find(uri) orelse return false;

        const doc = &store.documents[idx];
        doc.buf_arena.release();
        doc.lex_arena.release();
        doc.tree_arena.release();

        if (store.documents_open == idx) {
            store.documents_open = doc.next;
        } else {
            var prev_idx: ?usize = null;
            var it = store.iter();
            while (it.next()) |i| {
                if (store.documents[i].next == idx) {
                    prev_idx = i;
                    break;
                }
            }
            if (prev_idx) |pi| {
                store.documents[pi].next = doc.next;
            }
        }

        doc.* = .zero;
        store.documents[idx].next = store.documents_free;
        store.documents_free = idx;
        store.documents_used -= 1;
        return true;
    }

    pub const EditError = error{ DocumentNotFound, OutOfMemory } || GapBuffer.Error;

    // WIP:
    // working on edits
    // position_to_offset is slow
    // nothing is freed, infinite memory usage! (probably time to use free-list)
    // should think about using gap buffer to store tokens, so that token edits can be applied the same way as text edits?
    pub fn edit(store: *DocumentStore, uri: []const u8, version: i32, range: lsp.types.Range, text: []const u8) EditError!void {
        const doc_idx = store.find(uri) orelse return error.DocumentNotFound;
        const doc = &store.documents[doc_idx];

        // PERF: can use one offset to find the next
        const start_offset = position_to_offset(doc, range.start.line, range.start.character);
        const end_offset = position_to_offset(doc, range.end.line, range.end.character);

        const buf_range: base.Range(usize) = .range(start_offset, end_offset);

        if (!doc.buf.will_fit(buf_range, text)) {
            const new_buf = try doc.buf_arena.expand(u8, doc.buf.data, doc.buf.data.len * 2);
            doc.buf.expand(new_buf);
        }
        doc.buf.replace(buf_range, text) catch |err| {
            switch (err) {
                error.OutOfMemory => unreachable,
                else => return err,
            }
        };
        doc.version = version;

        doc.lex_arena.clear();
        var lexer: json.Lexer = .zero;
        const text_slices = doc.buf.slices();
        json.lex(&lexer, &doc.lex_arena, text_slices.prefix) catch {
            doc.tree = null;
            return;
        };
        json.lex(&lexer, &doc.lex_arena, text_slices.suffix) catch {
            doc.tree = null;
            return;
        };
        doc.tree_arena.clear();
        doc.tree = json.parse(&doc.tree_arena, &lexer) catch null;
    }

    pub const DiagnosticSet = struct {
        document: *const Document,
        syntax_errors: base.IntrusiveDoublyLinkedList(json.SyntaxError),

        pub fn has_diagnostics(set: DiagnosticSet) bool {
            return set.syntax_errors.first != null;
        }
    };

    pub fn diagnostics_for_uri(store: *DocumentStore, arena: *Arena, uri: []const u8, result: []lsp.types.Diagnostic) u32 {
        const doc_idx = store.find(uri) orelse return 0;
        const doc = store.documents[doc_idx];

        if (doc.tree == null) return 0;
        const tree = &doc.tree.?.tree;

        var diagnostic_index: u32 = 0;

        const syntax_errors = json.syntax_errors(arena, tree) catch @panic("OOM");
        var syntax_error_iter = syntax_errors.iter();

        while (syntax_error_iter.next()) |syntax_error| : (diagnostic_index += 1) {
            if (diagnostic_index >= result.len) {
                break;
            }
            const range = syntax_error.line_and_char(.utf16);
            result[diagnostic_index] = lsp.types.Diagnostic{
                .severity = .Error,
                .message = syntax_error.message,
                .range = lsp.types.Range{
                    .start = lsp.types.Position{
                        .character = range.start.char,
                        .line = range.start.line,
                    },
                    .end = lsp.types.Position{
                        .character = range.close.char,
                        .line = range.close.line,
                    },
                },
            };
        }
        return diagnostic_index;
    }
};

/// Convert LSP line/character position to byte offset using binary search on tokens.
/// LSP uses UTF-16 code units for character offsets.
pub fn position_to_offset(doc: *const Document, line: u32, character: u32) usize {
    const tokens = if (doc.tree) |tree| tree.tokens else &[_]json.Token{};
    if (tokens.len == 0) {
        return scan_to_char(doc, scan_to_line(doc, 0, 0, line), character);
    }

    // Binary search for a token on or near the target line
    var left: usize = 0;
    var right: usize = tokens.len;
    while (left < right) {
        const mid = left + (right - left) / 2;
        if (tokens[mid].line.num < line) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }

    // Find the line start offset
    const line_start_byte: u32 = blk: {
        if (left < tokens.len and tokens[left].line.num == line) {
            break :blk tokens[left].line.idx.byte;
        } else if (left > 0) {
            // Use previous token to find line start
            const prev_token = tokens[left - 1];
            if (prev_token.line.num == line) {
                break :blk prev_token.line.idx.byte;
            }
            // Need to scan from previous token's line to target line
            // Fall back to linear scan from that point
            break :blk scan_to_line(doc, prev_token.line.idx.byte, prev_token.line.num, line);
        } else {
            break :blk 0;
        }
    };

    // Now scan from line start to find the character offset
    return scan_to_char(doc, line_start_byte, character);
}

fn scan_to_line(doc: *const Document, start_byte: u32, start_line: u32, target_line: u32) u32 {
    var byte_offset: u32 = start_byte;
    var current_line = start_line;
    var it = doc.buf.iterator();
    it.pos = start_byte;

    while (it.next()) |byte| {
        if (current_line == target_line) {
            return byte_offset;
        }
        if (byte == '\n') {
            current_line += 1;
        }
        byte_offset = @intCast(it.pos);
    }
    return byte_offset;
}

fn scan_to_char(doc: *const Document, line_start: u32, target_char: u32) usize {
    var current_char: u32 = 0;
    var it = doc.buf.iterator();
    it.pos = line_start;

    while (it.next()) |byte| {
        if (current_char == target_char or byte == '\n') {
            return it.pos - 1;
        }
        const byte_len = std.unicode.utf8ByteSequenceLength(byte) catch 1;
        const utf16_len: u32 = if (byte_len == 4) 2 else 1;
        current_char += utf16_len;
        // Skip continuation bytes
        var skip: usize = 1;
        while (skip < byte_len) : (skip += 1) {
            _ = it.next();
        }
    }
    return it.pos;
}
