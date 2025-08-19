const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run unit tests");

    subsystem(b, "json", exe_mod, test_step, target, optimize);
    subsystem(b, "json-schema", exe_mod, test_step, target, optimize);
    subsystem(b, "lsp", exe_mod, test_step, target, optimize);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    test_step.dependOn(&run_exe_unit_tests.step);

    const exe = b.addExecutable(.{
        .name = "jsonls",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

fn subsystem(b: *std.Build, name: []const u8, exe: *std.Build.Module, test_step: *std.Build.Step, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const lib_mod = b.createModule(.{
        .root_source_file = b.path(b.fmt("src/{s}/{s}.zig", .{ name, name })),
        .optimize = optimize,
        .target = target,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = name,
        .root_module = lib_mod,
    });

    b.installArtifact(lib);

    exe.addImport(name, lib_mod);

    const lib_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_tests);
    test_step.dependOn(&run_lib_unit_tests.step);
}
