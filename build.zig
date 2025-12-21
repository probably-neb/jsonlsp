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
    const test_filters = b.option([]const []const u8, "test-filter", "Filter tests") orelse &.{};

    const mod_base = subsystem(b, "base", exe_mod, test_step, target, optimize, test_filters);
    const mod_json = subsystem(
        b,
        "json",
        exe_mod,
        test_step,
        target,
        optimize,
        test_filters,
    );
    mod_json.addImport("base", mod_base);

    const mod_json_schema = subsystem(b, "json-schema", exe_mod, test_step, target, optimize, test_filters);
    mod_json_schema.addImport("base", mod_base);

    const pcre_pkg = b.dependency("libpcre_zig", .{ .optimize = optimize, .target = target });
    const pcre_mod = pcre_pkg.module("libpcre");
    mod_json_schema.addImport("pcre", pcre_mod);

    const lsp_kit_pkg = b.dependency("lsp_kit", .{ .optimize = optimize, .target = target });
    const mod_lsp = lsp_kit_pkg.module("lsp");
    exe_mod.addImport("lsp", mod_lsp);
    exe_mod.addImport("base", mod_base);

    // Testing module for snapshot tests
    const mod_testing = b.createModule(.{
        .root_source_file = b.path("src/testing/testing.zig"),
        .optimize = optimize,
        .target = target,
    });
    mod_testing.addImport("lsp", mod_lsp);
    mod_testing.addImport("base", mod_base);

    const testing_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "testing",
        .root_module = mod_testing,
    });
    b.installArtifact(testing_lib);

    const testing_tests = b.addTest(.{
        .root_module = mod_testing,
        .filters = test_filters,
    });
    const run_testing_tests = b.addRunArtifact(testing_tests);
    test_step.dependOn(&run_testing_tests.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
        .filters = test_filters,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    test_step.dependOn(&run_exe_unit_tests.step);

    const exe = b.addExecutable(.{
        .name = "jsonls",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    // Check step (for ZLS build-on-save and fast compilation checks)
    // This creates an executable but doesn't install it, so Zig uses -fno-emit-bin
    {
        const exe_check = b.addExecutable(.{
            .name = "jsonls",
            .root_module = exe_mod,
        });
        const check = b.step("check", "Check if jsonls compiles");
        check.dependOn(&exe_check.step);
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
        const test_suite_dir_path = "src/json-schema/test-suite";
        const build_test_suite_path = b.path("src/json-schema/tools/build-test-suite.zig");

        const drafts = &.{
            "draft3",
            "draft4",
            "draft6",
            "draft7",
            "draft2019-09",
            "draft2020-12",
            "draft-next",
        };

        if (build_test_suite) blk: {
            test_suite_step.addWatchInput(build_test_suite_path) catch std.debug.panic("OOM", .{});
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
            const generated_test_suite_dir = tool_step.addOutputDirectoryArg("build-test-suite-output");
            const usf = b.addUpdateSourceFiles();
            const fmt = b.addFmt(.{ .paths = &.{test_suite_dir_path} });
            inline for (drafts) |draft| {
                const source_draft_test_file = generated_test_suite_dir.path(b, draft ++ ".zig");
                const target_draft_test_file = test_suite_dir_path ++ "/" ++ draft ++ ".zig";
                usf.addCopyFileToSource(source_draft_test_file, target_draft_test_file);
                fmt.step.dependOn(&usf.step);
            }
            exe.step.dependOn(&fmt.step);
            test_suite_step.dependOn(&fmt.step);
        }
        inline for (drafts) |draft| {
            const test_suite_module = b.createModule(.{
                .root_source_file = b.path(test_suite_dir_path).path(b, draft ++ ".zig"),
                .optimize = optimize,
                .target = target,
            });
            test_suite_module.addImport("json-schema", mod_json_schema);
            const test_suite_test = b.addTest(.{
                .root_module = test_suite_module,
                .filters = test_filters,
            });
            const run_test_suite = b.addRunArtifact(test_suite_test);
            run_test_suite.setName("run test " ++ draft ++ (" " ** (12 - draft.len)));
            test_suite_step.dependOn(&run_test_suite.step);
        }
    }
}

fn subsystem(b: *std.Build, name: []const u8, exe: *std.Build.Module, test_step: *std.Build.Step, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, test_filters: []const []const u8) *std.Build.Module {
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
        .filters = test_filters,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_tests);
    test_step.dependOn(&run_lib_unit_tests.step);
    return lib_mod;
}
