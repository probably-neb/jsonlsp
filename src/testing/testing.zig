//! Testing utilities for JSON Language Server.
//!
//! This module provides test infrastructure for running snapshot tests
//! against the server without needing real I/O.

const std = @import("std");

pub const compare = @import("compare.zig");
pub const runner = @import("runner.zig");
pub const snapshot = @import("snapshot.zig");
pub const transport = @import("transport.zig");

test {
    std.testing.refAllDecls(@This());
}
