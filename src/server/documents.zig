const std = @import("std");
const Alloc = std.mem.Allocator;

const base = @import("base");
const Arena = base.Arena;
const json = @import("json");
const lsp = @import("lsp");

const OOM = error{OutOfMemory};
const DOCUMENTS_MAX: usize = 4096;

pub const Document = struct {
    next: usize,
    arena_state: ?Arena,
    uri: []const u8,
    version: i32,
    text: []const u8,
    language_id: []const u8,
    tree: ?json.Tree_Root,

    const zero = Document{
        .next = 0,
        .arena_state = null,
        .uri = "",
        .version = 0,
        .text = "",
        .language_id = "",
        .tree = null,
    };

    fn arena(doc: *Document) Alloc {
        return doc.arena_state.?.allocator();
    }
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
            if (doc.arena_state) |*arena_state| {
                arena_state.deinit();
            }
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
        var arena_state: Arena = try .init(.{});
        const alloc = arena_state.allocator();
        doc.* = .{
            .next = store.documents_open,
            .uri = try alloc.dupe(u8, uri),
            .text = try alloc.dupe(u8, contents),
            .version = version,
            .language_id = try alloc.dupe(u8, language_id),
            .arena_state = null,
            .tree = null,
        };
        doc.tree = try json.parse(&arena_state, doc.text);
        doc.arena_state = arena_state;

        store.documents_open = store.documents_free;
        store.documents_free = next_free;
        store.documents_used += 1;
    }

    pub fn close(store: *DocumentStore, uri: []const u8) bool {
        const idx = store.find(uri) orelse return false;

        const doc = &store.documents[idx];
        if (doc.arena_state) |*arena_state| {
            arena_state.deinit();
        }

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

    pub const DiagnosticSet = struct {
        document: *const Document,
        syntax_errors: base.IntrusiveDoublyLinkedList(json.SyntaxError),

        pub fn has_diagnostics(set: DiagnosticSet) bool {
            return set.syntax_errors.first != null;
        }
    };

    pub fn diagnostics_for_uri(store: *DocumentStore, arena: *Arena, uri: []const u8, result: []lsp.types.Diagnostic) ?u32 {
        const doc_idx = store.find(uri) orelse return null;
        const doc = store.documents[doc_idx];

        if (doc.tree == null) return null;
        const tree = &doc.tree.?.tree;

        var diag_idx: u32 = 0;

        const syntax_errors = json.syntax_errors(arena, tree) catch @panic("OOM");
        var syntax_error_iter = syntax_errors.iter();

        while (syntax_error_iter.next()) |syntax_error| : (diag_idx += 1) {
            if (diag_idx >= result.len) {
                break;
            }
            const range = syntax_error.line_and_char(.utf16);
            result[diag_idx] = lsp.types.Diagnostic{
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
        return if (diag_idx == 0) null else diag_idx;
    }
};
