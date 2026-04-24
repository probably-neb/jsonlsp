const std = @import("std");
const middle = @import("middle.zig");

test {
    middle.middle_fn();
    std.testing.refAllDecls(@This());
    std.debug.print("OUTER ANON TEST RAN\n", .{});
}
