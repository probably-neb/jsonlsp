const std = @import("std");
const inner = @import("inner.zig");

test {
    std.testing.refAllDecls(inner);
    std.debug.print("ROOT ANON TEST RAN\n", .{});
}
