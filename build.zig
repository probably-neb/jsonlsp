const std = @import("std");

const ModuleSpec = struct {
    name: []const u8,
    dependency_module_name: ?[]const u8 = null,
    // filled during build
    module: *std.Build.Module = undefined,
    dependency: *std.Build.Dependency = undefined,

    fn vendored(self: *const ModuleSpec) bool {
        return self.dependency_module_name != null;
    }

    fn root_file_path(self: *const ModuleSpec, b: *std.Build) []const u8 {
        if (self.vendored()) {
            return b.fmt("vendor/{s}/{s}.zig", .{ self.name, self.name });
        }
        return b.fmt("src/{s}/{s}.zig", .{ self.name, self.name });
    }
};

const ToolSpec = struct {
    name: []const u8,
    description: []const u8,
    build_tool: fn (*std.Build, *std.Build.Step.Run) ?*std.Build.Step,

    fn source_file(self: *const ToolSpec, b: *std.Build) []const u8 {
        return b.fmt("tools/{s}.zig", .{self.name});
    }
};

var module_specs = [_]ModuleSpec{
    .{
        .name = "base",
    },
    .{
        .name = "json",
    },
    .{
        .name = "json-schema",
    },
    .{
        .name = "server",
    },
    .{
        .name = "testing",
    },
    .{
        .name = "pcre",
        .dependency_module_name = "libpcre",
    },
    .{
        .name = "lsp",
        .dependency_module_name = "lsp",
    },
};

const tool_specs = [_]ToolSpec{
    .{
        .name = "generate-zed-config",
        .description = "Generate .zed/debug.json and .zed/tasks.json",
        .build_tool = generate_zed_config,
    },
    .{
        .name = "run-snapshot-tests",
        .description = "Run snapshot tests",
        .build_tool = run_snapshot_tests,
    },
    .{
        .name = "build-test-suite",
        .description = "Build the JSON schema test suite",
        .build_tool = build_json_schema_test_suite,
    },
    .{
        .name = "generate-learnjsonschema",
        .description = "Generate Learn JSON Schema markdown pages",
        .build_tool = generate_learnjsonschema,
    },
};

const json_schema_drafts = &.{
    "draft3",
    "draft4",
    "draft6",
    "draft7",
    "draft2019-09",
    "draft2020-12",
    "draft-next",
};
const json_schema_test_suite_dir_path = "src/json-schema/test-suite";
const learnjsonschema_dir_path = "src/json-schema/learnjsonschema";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const test_step = b.step("test", "Run unit tests");
    const check_step = b.step("check", "Check if jsonls compiles");
    const test_filters = b.option([]const []const u8, "test-filter", "Filter tests") orelse &.{};

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // initialze spec.module
    for (&module_specs) |*spec| {
        if (spec.dependency_module_name) |dep_mod_name| {
            spec.dependency = b.dependency(spec.name, .{ .optimize = optimize, .target = target });
            spec.module = spec.dependency.module(dep_mod_name);
        } else {
            spec.module = b.createModule(.{
                .root_source_file = b.path(spec.root_file_path(b)),
                .optimize = optimize,
                .target = target,
            });
        }
    }

    // add all modules as imports to each other
    for (&module_specs) |spec| {
        if (spec.vendored()) continue;
        for (&module_specs) |other_spec| {
            if (spec.module == other_spec.module) continue;
            spec.module.addImport(other_spec.name, other_spec.module);
        }
    }

    // add all modules as imports to the exe
    for (module_specs) |spec| {
        exe_mod.addImport(spec.name, spec.module);
    }

    // add all module tests
    inline for (module_specs) |spec| {
        const module_tests = b.addTest(.{
            .name = spec.name,
            .root_module = spec.module,
            .filters = test_filters,
        });
        check_step.dependOn(&module_tests.step);
        const run_module_tests = b.addRunArtifact(module_tests);
        test_step.dependOn(&run_module_tests.step);
    }

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
        .filters = test_filters,
    });
    check_step.dependOn(&exe_unit_tests.step);
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
        check_step.dependOn(&exe_check.step);
    }

    inline for (tool_specs) |tool_spec| {
        const tool_step = b.step("tool:" ++ tool_spec.name, tool_spec.description);
        const tool_mod = b.createModule(.{
            .root_source_file = b.path(tool_spec.source_file(b)),
            .target = target,
            .optimize = optimize,
        });
        add_specs_as_imports(tool_mod);
        const tool_exe = b.addExecutable(.{
            .name = tool_spec.name,
            .root_module = tool_mod,
        });
        b.installArtifact(tool_exe);

        const check_tool_exe = b.addExecutable(.{
            .name = tool_spec.name,
            .root_module = tool_mod,
        });
        check_step.dependOn(&check_tool_exe.step);

        const run_step = b.addRunArtifact(tool_exe);
        if (tool_spec.build_tool(b, run_step)) |step| {
            tool_step.dependOn(step);
        }
        tool_step.dependOn(&run_step.step);
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

        const run_suite = !(b.option(bool, "no-run", "Do not execute the test suite") orelse false);

        // WIP: need to make this into a tool
        inline for (json_schema_drafts) |draft| {
            const test_suite_module = b.createModule(.{
                .root_source_file = b.path(json_schema_test_suite_dir_path).path(b, draft ++ ".zig"),
                .optimize = optimize,
                .target = target,
            });
            add_specs_as_imports(test_suite_module);
            const test_suite_test = b.addTest(.{
                .name = "test_suite_" ++ draft,
                .root_module = test_suite_module,
                .filters = test_filters,
            });
            const install_test_suite = b.addInstallArtifact(test_suite_test, .{});
            test_suite_step.dependOn(&install_test_suite.step);
            if (run_suite) {
                const run_test_suite = b.addRunArtifact(install_test_suite.artifact);
                run_test_suite.setName("run test " ++ draft ++ (" " ** (12 - draft.len)));
                test_suite_step.dependOn(&run_test_suite.step);
            }
        }
    }
}

fn add_specs_as_imports(module: *std.Build.Module) void {
    for (module_specs) |spec| {
        if (spec.module == module) continue;
        module.addImport(spec.name, spec.module);
    }
}

fn generate_zed_config(b: *std.Build, run: *std.Build.Step.Run) ?*std.Build.Step {
    run.setCwd(b.path("."));
    const generated_dir = run.addOutputDirectoryArg("zed-config-output");

    const update_source_files = b.addUpdateSourceFiles();
    update_source_files.addCopyFileToSource(generated_dir.path(b, "debug.json"), ".zed/debug.json");
    update_source_files.addCopyFileToSource(generated_dir.path(b, "tasks.json"), ".zed/tasks.json");
    update_source_files.step.dependOn(&run.step);
    return &update_source_files.step;
}

fn run_snapshot_tests(b: *std.Build, run: *std.Build.Step.Run) ?*std.Build.Step {
    run.setCwd(b.path("."));
    const update_snapshots = b.option(bool, "update-snapshots", "Update snapshot files with actual outputs") orelse false;

    const options = b.addOptions();
    options.addOption(bool, "update_snapshots", update_snapshots);

    run.producer.?.root_module.addOptions("build_options", options);

    if (b.args) |args| {
        run.addArgs(args);
    }
    return null;
}

fn generate_learnjsonschema(b: *std.Build, run: *std.Build.Step.Run) ?*std.Build.Step {
    run.setCwd(b.path("."));
    const generated_dir = run.addOutputDirectoryArg("learnjsonschema-output");

    const remove_previous = b.addRemoveDirTree(b.path(learnjsonschema_dir_path));
    const install_generated = b.addInstallDirectory(.{
        .source_dir = generated_dir,
        .install_dir = .{ .custom = "../src/json-schema" },
        .install_subdir = "learnjsonschema",
    });
    install_generated.step.dependOn(&remove_previous.step);
    return &install_generated.step;
}

fn build_json_schema_test_suite(b: *std.Build, run: *std.Build.Step.Run) ?*std.Build.Step {
    const build_test_suite_path = b.path("src/json-schema/tools/build-test-suite.zig");
    run.step.addWatchInput(build_test_suite_path) catch std.debug.panic("OOM", .{});
    const test_suite = b.lazyDependency("json_schema_test_suite", .{}) orelse return null;
    const tests_path = test_suite.path("tests");
    run.addDirectoryArg(tests_path);
    const generated_test_suite_dir = run.addOutputDirectoryArg("build-test-suite-output");
    const usf = b.addUpdateSourceFiles();
    const fmt = b.addFmt(.{ .paths = &.{json_schema_test_suite_dir_path} });
    inline for (json_schema_drafts) |draft| {
        const source_draft_test_file = generated_test_suite_dir.path(b, draft ++ ".zig");
        const target_draft_test_file = json_schema_test_suite_dir_path ++ "/" ++ draft ++ ".zig";
        usf.addCopyFileToSource(source_draft_test_file, target_draft_test_file);
        fmt.step.dependOn(&usf.step);
    }
    return &fmt.step;
}
