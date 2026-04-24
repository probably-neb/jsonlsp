const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const filters = b.option([]const []const u8, "test-filter", "Filter tests") orelse &.{};

    const direct_mod = b.createModule(.{
        .root_source_file = b.path("root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const named_mod = b.createModule(.{
        .root_source_file = b.path("root_named.zig"),
        .target = target,
        .optimize = optimize,
    });
    const outer_mod = b.createModule(.{
        .root_source_file = b.path("outer.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run tests");

    inline for ([_]struct { []const u8, *std.Build.Module }{
        .{ "direct", direct_mod },
        .{ "named", named_mod },
        .{ "outer", outer_mod },
    }) |entry| {
        const unit = b.addTest(.{
            .name = entry[0],
            .root_module = entry[1],
            .filters = filters,
        });
        const run = b.addRunArtifact(unit);
        test_step.dependOn(&run.step);
    }
}
