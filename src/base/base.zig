//! Base Layer
//!
//! Provides foundational utilities and abstractions for JSONLS.
//!
const std = @import("std");

pub const Arena = @import("arena.zig");
pub const IntrusiveLinkedList = @import("intrusive-linked-list.zig").IntrusiveLinkedList;
pub const IntrusiveDoublyLinkedList = @import("intrusive-linked-list.zig").IntrusiveDoublyLinkedList;
pub const meta = @import("meta.zig");

test {
    std.testing.refAllDecls(@This());
}

pub fn Range(comptime T: type) type {
    return struct {
        start: T,
        close: T,

        pub fn len(self: @This()) T {
            if (@hasDecl(T, "sub")) {
                return self.close.sub(self.start);
            }
            return self.close - self.start;
        }
    };
}
