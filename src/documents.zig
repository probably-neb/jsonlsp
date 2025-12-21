const std = @import("std");
const base = @import("base");
const Alloc = std.mem.Allocator;
const Arena = base.Arena;
const OOM = error{OutOfMemory};

const DOCUMENTS_MAX: usize = 4096;

var DOCUMENTS: [DOCUMENTS_MAX]Document = undefined;
var DOCUMENTS_OPEN: usize = DOCUMENTS_MAX;
var DOCUMENTS_FREE: usize = 0;

const Document = struct {
    next: usize,
    arena_state: ?Arena,
    uri: []const u8,
    version: i32,
    text: []const u8, // todo! remove, store json tree
    language_id: []const u8,

    const zero = Document{
        .next = 0,
        .arena_state = null,
        .uri = "",
        .version = 0,
        .text = "",
        .language_id = "",
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
    var i: usize = DOCUMENTS_OPEN;
    while (i < DOCUMENTS_MAX) : (i = DOCUMENTS[i].next) {
        if (std.mem.eql(u8, DOCUMENTS[i].uri, uri)) return i;
    }
    return null;
}

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
    };
    doc.arena_state = arena_state;

    DOCUMENTS_OPEN = DOCUMENTS_FREE;
    DOCUMENTS_FREE = next_free;
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
    return true;
}
