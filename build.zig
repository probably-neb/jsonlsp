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
    const check_step = b.step("check", "Check if jsonls compiles");
    const test_filters = b.option([]const []const u8, "test-filter", "Filter tests") orelse &.{};

    const mod_base = subsystem(b, "base", exe_mod, test_step, check_step, target, optimize, test_filters);
    const mod_json = subsystem(b, "json", exe_mod, test_step, check_step, target, optimize, test_filters);
    mod_json.addImport("base", mod_base);

    const mod_json_schema = subsystem(b, "json-schema", exe_mod, test_step, check_step, target, optimize, test_filters);
    mod_json_schema.addImport("base", mod_base);
    mod_json_schema.addImport("json", mod_json);

    const pcre_pkg = b.dependency("libpcre_zig", .{ .optimize = optimize, .target = target });
    const pcre_mod = pcre_pkg.module("libpcre");
    mod_json_schema.addImport("pcre", pcre_mod);

    const lsp_kit_pkg = b.dependency("lsp_kit", .{ .optimize = optimize, .target = target });
    const mod_lsp = lsp_kit_pkg.module("lsp");
    exe_mod.addImport("lsp", mod_lsp);

    // Server subsystem
    const mod_server = subsystem(b, "server", exe_mod, test_step, check_step, target, optimize, test_filters);
    mod_server.addImport("base", mod_base);
    mod_server.addImport("json", mod_json);
    mod_server.addImport("lsp", mod_lsp);

    // Testing module for snapshot tests
    const mod_testing = b.createModule(.{
        .root_source_file = b.path("src/testing/testing.zig"),
        .optimize = optimize,
        .target = target,
    });
    mod_testing.addImport("lsp", mod_lsp);
    mod_testing.addImport("base", mod_base);
    mod_testing.addImport("server", mod_server);

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
    check_step.dependOn(&testing_tests.step);
    const run_testing_tests = b.addRunArtifact(testing_tests);
    test_step.dependOn(&run_testing_tests.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
        .filters = test_filters,
    });
    check_step.dependOn(&exe_unit_tests.step);
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    test_step.dependOn(&run_exe_unit_tests.step);

    // Snapshot tests
    {
        const snapshot_test_step = b.step("test:snapshots", "Run snapshot tests");
        const snapshot_build_step = b.step("snapshots", "Build snapshot test executable");

        const update_snapshots = b.option(bool, "update-snapshots", "Update snapshot files with actual outputs") orelse false;

        const options = b.addOptions();
        options.addOption(bool, "update_snapshots", update_snapshots);

        const snapshot_test_mod = b.createModule(.{
            .root_source_file = b.path("src/snapshot_tests.zig"),
            .optimize = optimize,
            .target = target,
        });
        snapshot_test_mod.addOptions("build_options", options);
        snapshot_test_mod.addImport("testing", mod_testing);

        const snapshot_test_exe = b.addExecutable(.{
            .name = "snapshot_tests",
            .root_module = snapshot_test_mod,
        });

        const install_snapshot_exe = b.addInstallArtifact(snapshot_test_exe, .{});
        snapshot_build_step.dependOn(&install_snapshot_exe.step);

        const run_snapshot_tests = b.addRunArtifact(snapshot_test_exe);
        run_snapshot_tests.setCwd(b.path("."));

        if (b.args) |args| {
            run_snapshot_tests.addArgs(args);
        }

        snapshot_test_step.dependOn(&run_snapshot_tests.step);
    }

    // Zed debug/task config generator
    {
        const debug_zed_step = b.step("debug:zed", "Generate Zed debug and task configurations");

        const generator_mod = b.createModule(.{
            .root_source_file = b.path("tools/generate_zed_config.zig"),
            .target = b.graph.host,
            .optimize = .Debug,
        });

        const generator_exe = b.addExecutable(.{
            .name = "generate_zed_config",
            .root_module = generator_mod,
        });

        const run_generator = b.addRunArtifact(generator_exe);
        run_generator.setCwd(b.path("."));
        const generated_dir = run_generator.addOutputDirectoryArg("zed-config-output");

        const update_source_files = b.addUpdateSourceFiles();
        update_source_files.addCopyFileToSource(generated_dir.path(b, "debug.json"), ".zed/debug.json");
        update_source_files.addCopyFileToSource(generated_dir.path(b, "tasks.json"), ".zed/tasks.json");
        update_source_files.step.dependOn(&run_generator.step);

        debug_zed_step.dependOn(&update_source_files.step);
    }

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
        check_step.dependOn(&exe_check.step);
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
            const tool_module = b.createModule(.{
                .root_source_file = build_test_suite_path,
                .target = b.graph.host,
                .optimize = .Debug,
            });
            tool_module.addImport("base", mod_base);
            const tool = b.addExecutable(.{
                .name = "generate_json_schema_test_suite",
                .root_module = tool_module,
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

fn subsystem(b: *std.Build, name: []const u8, exe: *std.Build.Module, test_step: *std.Build.Step, check_step: *std.Build.Step, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, test_filters: []const []const u8) *std.Build.Module {
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
    check_step.dependOn(&lib_tests.step);

    const run_lib_unit_tests = b.addRunArtifact(lib_tests);
    test_step.dependOn(&run_lib_unit_tests.step);
    return lib_mod;
}
