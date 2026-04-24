const std = @import("std");
const inner = @import("inner.zig");

pub fn middle_fn() void {}

test {
    std.testing.refAllDecls(@This());
    std.testing.refAllDecls(inner);
    std.debug.print("MIDDLE ANON TEST RAN\n", .{});
}
