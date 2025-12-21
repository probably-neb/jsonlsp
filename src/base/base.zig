//! Base Layer
//!
//! Provides foundational utilities and abstractions for JSONLS.
//!
const std = @import("std");

const arena = @import("arena.zig");
pub const Arena = arena.Arena;
pub const get_scratch = arena.get_scratch;

test {
    std.testing.refAllDecls(@This());
}
