const std = @import("std");

fn target_decltest() void {}

test target_decltest {
    std.debug.print("INNER DECLTEST RAN\n", .{});
}
