//! Generates .zed/debug.json and .zed/tasks.json with entries for each snapshot test.
//! Usage: generate_zed_config <output_directory>

const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const args = try std.process.argsAlloc(arena);

    if (args.len < 2) {
        std.debug.print("Usage: generate_zed_config <output_directory>\n", .{});
        std.process.exit(1);
    }

    const output_dir_path = args[1];

    const snapshot_names = try discover_snapshot_names(arena, "tests/snapshots");

    try generate_debug_json(arena, output_dir_path, snapshot_names);
    try generate_tasks_json(arena, output_dir_path, snapshot_names);

    std.debug.print("Generated debug.json and tasks.json with {d} snapshot entries\n", .{snapshot_names.len});
}

fn discover_snapshot_names(allocator: Allocator, dir_path: []const u8) ![][]const u8 {
    var names: std.ArrayList([]const u8) = .empty;

    var dir = std.fs.cwd().openDir(dir_path, .{ .iterate = true }) catch |err| {
        if (err == error.FileNotFound) {
            return try names.toOwnedSlice(allocator);
        }
        return err;
    };
    defer dir.close();

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.endsWith(u8, entry.name, ".txt")) continue;

        const stem = entry.name[0 .. entry.name.len - ".txt".len];
        try names.append(allocator, try allocator.dupe(u8, stem));
    }

    std.mem.sort([]const u8, names.items, {}, struct {
        fn lessThan(_: void, a: []const u8, b: []const u8) bool {
            return std.mem.lessThan(u8, a, b);
        }
    }.lessThan);

    return try names.toOwnedSlice(allocator);
}

const DebugEntry = struct {
    label: []const u8,
    adapter: []const u8 = "CodeLLDB",
    request: []const u8 = "launch",
    program: []const u8,
    args: ?[]const []const u8 = null,
    cwd: []const u8 = "${ZED_WORKTREE_ROOT}",
    build: Build,
    initCommands: []const []const u8,

    const Build = struct {
        command: []const u8 = "zig",
        args: []const []const u8,
    };
};

fn generate_debug_json(allocator: Allocator, output_dir: []const u8, snapshot_names: []const []const u8) !void {
    var entries: std.ArrayList(DebugEntry) = .empty;

    const init_commands: []const []const u8 = &.{
        "command script import ${ZED_WORKTREE_ROOT}/tools/lldb_pretty_printers.py",
        "type category enable zig.lang",
        "type category enable zig.std",
    };

    try entries.append(allocator, .{
        .label = "Debug Exe",
        .program = "${ZED_WORKTREE_ROOT}/zig-out/bin/jsonls",
        .build = .{ .args = &.{"build"} },
        .initCommands = init_commands,
    });

    const drafts = &.{
        "draft3",
        "draft4",
        "draft6",
        "draft7",
        "draft2019-09",
        "draft2020-12",
        "draft-next",
    };
    inline for (drafts) |draft| {
        try entries.append(allocator, .{
            .label = "Debug test suite " ++ draft,
            .program = "${ZED_WORKTREE_ROOT}/zig-out/bin/test_suite_" ++ draft,
            .build = .{
                .args = &.{ "build", "test:suite", "-Dno-run" },
            },
            .initCommands = init_commands,
            .args = &.{},
        });
    }

    for (snapshot_names) |name| {
        const label = try std.fmt.allocPrint(allocator, "snapshot: {s}", .{name});
        const snapshot_path = try std.fmt.allocPrint(allocator, "tests/snapshots/{s}.txt", .{name});
        const args: []const []const u8 = try allocator.dupe([]const u8, &.{snapshot_path});

        try entries.append(allocator, .{
            .label = label,
            .program = "${ZED_WORKTREE_ROOT}/zig-out/bin/snapshot_tests",
            .args = args,
            .build = .{ .args = &.{ "build", "snapshots" } },
            .initCommands = init_commands,
        });
    }

    const json_str = try std.fmt.allocPrint(allocator, "{f}\n", .{std.json.fmt(entries.items, .{ .whitespace = .indent_2 })});

    var dir = try std.fs.cwd().makeOpenPath(output_dir, .{});
    defer dir.close();

    try dir.writeFile(.{ .sub_path = "debug.json", .data = json_str });
}

const TaskEntry = struct {
    label: []const u8,
    command: []const u8 = "zig",
    args: []const []const u8,
    cwd: []const u8 = "$ZED_WORKTREE_ROOT",
};

fn generate_tasks_json(allocator: Allocator, output_dir: []const u8, snapshot_names: []const []const u8) !void {
    var entries: std.ArrayList(TaskEntry) = .empty;

    const static_tasks = [_]struct { label: []const u8, args: []const []const u8 }{
        .{ .label = "build", .args = &.{"build"} },
        .{ .label = "test", .args = &.{ "build", "test" } },
        .{ .label = "test:suite", .args = &.{ "build", "test:suite" } },
        .{ .label = "test:snapshots", .args = &.{ "build", "test:snapshots" } },
        .{ .label = "snapshots (build only)", .args = &.{ "build", "snapshots" } },
    };

    for (static_tasks) |task| {
        try entries.append(allocator, .{ .label = task.label, .args = task.args });
    }

    for (snapshot_names) |name| {
        const snapshot_path = try std.fmt.allocPrint(allocator, "tests/snapshots/{s}.txt", .{name});
        const run_label = try std.fmt.allocPrint(allocator, "snapshot: {s}", .{name});
        const args: []const []const u8 = try allocator.dupe([]const u8, &.{ "build", "test:snapshots", "--", snapshot_path });
        try entries.append(allocator, .{ .label = run_label, .args = args });
    }

    const json_str = try std.fmt.allocPrint(allocator, "{f}\n", .{std.json.fmt(entries.items, .{ .whitespace = .indent_2 })});

    var dir = try std.fs.cwd().makeOpenPath(output_dir, .{});
    defer dir.close();

    try dir.writeFile(.{ .sub_path = "tasks.json", .data = json_str });
}
