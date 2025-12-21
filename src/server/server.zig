//! Server Subsystem
//!
//! Provides the core LSP server implementation including message handling,
//! document management, and the main server run loop.

const std = @import("std");

pub const documents = @import("documents.zig");
pub const run = @import("run.zig").run;
pub const ServerError = @import("run.zig").ServerError;

test {
    std.testing.refAllDecls(@This());
}
