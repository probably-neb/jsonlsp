const std = @import("std");
const inner = @import("inner.zig");

fn bridge_named() void {}

test bridge_named {
    std.testing.refAllDecls(inner);
    std.debug.print("ROOT BRIDGE DECLTEST RAN\n", .{});
}
