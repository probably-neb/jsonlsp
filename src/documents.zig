const std = @import("std");
const Alloc = std.mem.Allocator;

const base = @import("base");
const Arena = base.Arena;
const json = @import("json");

const OOM = error{OutOfMemory};
const DOCUMENTS_MAX: usize = 4096;

var DOCUMENTS: [DOCUMENTS_MAX]Document = undefined;
var DOCUMENTS_OPEN: usize = DOCUMENTS_MAX;
var DOCUMENTS_FREE: usize = 0;
var DOCUMENTS_USED: usize = 0;

const Document = struct {
    next: usize,
    arena_state: ?Arena,
    uri: []const u8,
    version: i32,
    text: []const u8, // todo! remove, store json tree
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

pub fn init() void {
    for (&DOCUMENTS, 0..) |*doc, i| {
        doc.* = .zero;
        doc.next = i + 1;
    }
}

fn find(uri: []const u8) ?usize {
    var iter: Document_Iter = .init();
    while (iter.next()) |i| {
        if (std.mem.eql(u8, DOCUMENTS[i].uri, uri)) return i;
    }
    return null;
}

const Document_Iter = struct {
    idx: usize,

    fn init() Document_Iter {
        return .{ .idx = DOCUMENTS_OPEN };
    }

    fn next(iter: *Document_Iter) ?usize {
        if (iter.idx == DOCUMENTS_MAX) return null;
        const result = iter.idx;
        iter.idx = DOCUMENTS[result].next;
        return result;
    }
};

const OpenError = error{ OpenDocumentLimitReached, DocumentAlreadyOpen } || Arena.InitError;

pub fn open(uri: []const u8, contents: []const u8, version: i32, language_id: []const u8) OpenError!void {
    if (find(uri) != null) return error.DocumentAlreadyOpen;
    if (DOCUMENTS_FREE == DOCUMENTS_MAX) {
        return error.OpenDocumentLimitReached;
    }

    const doc = &DOCUMENTS[DOCUMENTS_FREE];
    const next_free = doc.next;
    var arena_state: Arena = try .init(.{});
    const alloc = arena_state.allocator();
    doc.* = .{
        .next = DOCUMENTS_OPEN,
        .uri = try alloc.dupe(u8, uri),
        .text = try alloc.dupe(u8, contents),
        .version = version,
        .language_id = try alloc.dupe(u8, language_id),
        .arena_state = null,
        .tree = null,
    };
    doc.tree = try json.parse(&arena_state, doc.text);
    doc.arena_state = arena_state;

    DOCUMENTS_OPEN = DOCUMENTS_FREE;
    DOCUMENTS_FREE = next_free;
    DOCUMENTS_USED += 1;
}

pub fn close(uri: []const u8) bool {
    const idx = find(uri) orelse return false;

    const doc = &DOCUMENTS[idx];
    doc.arena_state.?.deinit();
    if (DOCUMENTS_OPEN == idx) {
        DOCUMENTS_OPEN = doc.next;
    }
    doc.* = .zero;
    DOCUMENTS[idx].next = DOCUMENTS_FREE;
    DOCUMENTS_FREE = idx;
    DOCUMENTS_USED -= 1;
    return true;
}

pub const DiagnosticSet = struct {
    document: *const Document,
    syntax_errors: base.IntrusiveDoublyLinkedList(json.SyntaxError),

    pub fn has_diagnostics(set: DiagnosticSet) bool {
        return set.syntax_errors.first != null;
    }
};

pub fn diagnostics(arena: *Arena) OOM![]const DiagnosticSet {
    var result = try arena.alloc(DiagnosticSet, DOCUMENTS_USED);
    var iter: Document_Iter = .init();

    while (iter.next()) |i| {
        const doc = &DOCUMENTS[i];
        result[i].document = doc;

        result[i].syntax_errors = try json.syntax_errors(arena, &doc.tree.?.tree);
    }
    return result;
}
