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

    _ = subsystem(b, "json", exe_mod, test_step, target, optimize);
    _ = subsystem(b, "json-schema", exe_mod, test_step, target, optimize);
    _ = subsystem(b, "lsp", exe_mod, test_step, target, optimize);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    test_step.dependOn(&run_exe_unit_tests.step);

    const exe = b.addExecutable(.{
        .name = "jsonls",
        .root_module = exe_mod,
    });

    const no_bin = b.option(bool, "no-bin", "Don't build a binary, just check") orelse false;
    if (no_bin) {
        const bin = b.addExecutable(.{
            .name = "jsonls",
            .root_module = exe_mod,
        });
        b.default_step.dependOn(&bin.step);
    } else {
        b.installArtifact(exe);
    }

    // Run step
    {
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    // JSON Schema test suite
    {
        const test_suite_step = b.step("test:suite", "Run the JSON Schema test suite");

        const build_test_suite = b.option(bool, "build-test-suite", "Run the JSON Schema test suite") orelse false;
        const test_suite_file_path = "src/json-schema/test-suite.zig";
        const build_test_suite_path = b.path("src/json-schema/tools/build-test-suite.zig");

        if (build_test_suite) blk: {
            const test_suite = b.lazyDependency("json_schema_test_suite", .{}) orelse break :blk;
            const tests_path = test_suite.path("tests");
            const tool = b.addExecutable(.{
                .name = "generate_json_schema_test_suite",
                .root_module = b.createModule(.{
                    .root_source_file = build_test_suite_path,
                    .target = b.graph.host,
                    .optimize = .Debug,
                }),
            });
            const tool_step = b.addRunArtifact(tool);
            tool_step.addDirectoryArg(tests_path);
            const output = tool_step.addOutputFileArg("test-suite.zig");
            const wf = b.addUpdateSourceFiles();
            wf.addCopyFileToSource(output, test_suite_file_path);
            const fmt = b.addFmt(.{ .paths = &.{test_suite_file_path} });
            fmt.step.dependOn(&wf.step);
            exe.step.dependOn(&fmt.step);
            test_suite_step.dependOn(&fmt.step);
        }
        const test_suite_module = b.createModule(.{
            .root_source_file = b.path(test_suite_file_path),
            .optimize = optimize,
            .target = target,
        });
        const test_suite_test = b.addTest(.{
            .root_module = test_suite_module,
        });
        const run_test_suite = b.addRunArtifact(test_suite_test);
        test_suite_step.addWatchInput(build_test_suite_path) catch std.debug.panic("OOM", .{});
        test_suite_step.dependOn(&run_test_suite.step);
    }
}

fn subsystem(b: *std.Build, name: []const u8, exe: *std.Build.Module, test_step: *std.Build.Step, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Module {
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
    return lib_mod;
}
