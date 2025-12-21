//! Base Layer
//!
//! Provides foundational utilities and abstractions for JSONLS.
//!
const std = @import("std");

pub const Arena = @import("arena.zig");
pub const get_scratch = Arena.get_scratch;

test {
    std.testing.refAllDecls(@This());
}
