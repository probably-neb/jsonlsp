//! Base Layer
//!
//! Provides foundational utilities and abstractions for JSONLS.
//!
const std = @import("std");

pub const Arena = @import("arena.zig");

test {
    std.testing.refAllDecls(@This());
}
