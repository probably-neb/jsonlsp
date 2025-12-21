const std = @import("std");
const Alloc = std.mem.Allocator;

const base = @import("base");
const Arena = base.Arena;
const json = @import("json");

const OOM = error{OutOfMemory};
const DOCUMENTS_MAX: usize = 4096;

const Document = struct {
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

    pub fn deinit(self: *DocumentStore) void {
        var it = self.iter();
        while (it.next()) |i| {
            const doc = &self.documents[i];
            if (doc.arena_state) |*arena_state| {
                arena_state.deinit();
            }
        }
        self.* = undefined;
    }

    fn find(self: *DocumentStore, uri: []const u8) ?usize {
        var it = self.iter();
        while (it.next()) |i| {
            if (std.mem.eql(u8, self.documents[i].uri, uri)) return i;
        }
        return null;
    }

    fn iter(self: *DocumentStore) Document_Iter {
        return .{ .store = self, .idx = self.documents_open };
    }

    const Document_Iter = struct {
        store: *DocumentStore,
        idx: usize,

        fn next(it: *Document_Iter) ?usize {
            if (it.idx == DOCUMENTS_MAX) return null;
            const result = it.idx;
            it.idx = it.store.documents[result].next;
            return result;
        }
    };

    pub const OpenError = error{ OpenDocumentLimitReached, DocumentAlreadyOpen } || Arena.InitError;

    pub fn open(self: *DocumentStore, uri: []const u8, contents: []const u8, version: i32, language_id: []const u8) OpenError!void {
        if (self.find(uri) != null) return error.DocumentAlreadyOpen;
        if (self.documents_free == DOCUMENTS_MAX) {
            return error.OpenDocumentLimitReached;
        }

        const doc = &self.documents[self.documents_free];
        const next_free = doc.next;
        var arena_state: Arena = try .init(.{});
        const alloc = arena_state.allocator();
        doc.* = .{
            .next = self.documents_open,
            .uri = try alloc.dupe(u8, uri),
            .text = try alloc.dupe(u8, contents),
            .version = version,
            .language_id = try alloc.dupe(u8, language_id),
            .arena_state = null,
            .tree = null,
        };
        doc.tree = try json.parse(&arena_state, doc.text);
        doc.arena_state = arena_state;

        self.documents_open = self.documents_free;
        self.documents_free = next_free;
        self.documents_used += 1;
    }

    pub fn close(self: *DocumentStore, uri: []const u8) bool {
        const idx = self.find(uri) orelse return false;

        const doc = &self.documents[idx];
        if (doc.arena_state) |*arena_state| {
            arena_state.deinit();
        }

        // Remove from open list
        if (self.documents_open == idx) {
            self.documents_open = doc.next;
        } else {
            // Find the previous document that points to this one
            var prev_idx: ?usize = null;
            var it = self.iter();
            while (it.next()) |i| {
                if (self.documents[i].next == idx) {
                    prev_idx = i;
                    break;
                }
            }
            if (prev_idx) |pi| {
                self.documents[pi].next = doc.next;
            }
        }

        doc.* = .zero;
        self.documents[idx].next = self.documents_free;
        self.documents_free = idx;
        self.documents_used -= 1;
        return true;
    }

    pub const DiagnosticSet = struct {
        document: *const Document,
        syntax_errors: base.IntrusiveDoublyLinkedList(json.SyntaxError),

        pub fn has_diagnostics(set: DiagnosticSet) bool {
            return set.syntax_errors.first != null;
        }
    };

    pub fn diagnostics(self: *DocumentStore, arena: *Arena) OOM![]const DiagnosticSet {
        var result = try arena.alloc(DiagnosticSet, self.documents_used);
        var it = self.iter();
        var result_idx: usize = 0;

        while (it.next()) |i| {
            const doc = &self.documents[i];
            result[result_idx].document = doc;
            result[result_idx].syntax_errors = try json.syntax_errors(arena, &doc.tree.?.tree);
            result_idx += 1;
        }
        return result;
    }
};
