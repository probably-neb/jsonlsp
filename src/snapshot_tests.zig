//! Snapshot test entry point.
//!
//! This module discovers and runs snapshot tests from .txt files in the
//! tests/snapshots/ directory. Each snapshot file contains a sequence of
//! send (>>>) and expect (<<<) messages that define a test scenario.
//!
//! Run with: zig build test:snapshots
//! Update mode: zig build test:snapshots -Dupdate-snapshots=true

const std = @import("std");
const builtin = @import("builtin");
const build_options = @import("build_options");
const testing = @import("testing");

const Allocator = std.mem.Allocator;
const Snapshot = testing.snapshot.Snapshot;
const Direction = testing.snapshot.Direction;

const update_snapshots = build_options.update_snapshots;

/// Discover all .txt snapshot files in the given directory.
fn discoverSnapshots(allocator: Allocator, dir_path: []const u8) ![][]const u8 {
    var paths: std.ArrayList([]const u8) = .empty;
    errdefer {
        for (paths.items) |p| allocator.free(p);
        paths.deinit(allocator);
    }

    var dir = std.fs.cwd().openDir(dir_path, .{ .iterate = true }) catch |err| {
        if (err == error.FileNotFound) {
            return try paths.toOwnedSlice(allocator);
        }
        return err;
    };
    defer dir.close();

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.endsWith(u8, entry.name, ".txt")) continue;

        const full_path = try std.fs.path.join(allocator, &.{ dir_path, entry.name });
        try paths.append(allocator, full_path);
    }

    std.mem.sort([]const u8, paths.items, {}, struct {
        fn lessThan(_: void, a: []const u8, b: []const u8) bool {
            return std.mem.lessThan(u8, a, b);
        }
    }.lessThan);

    return try paths.toOwnedSlice(allocator);
}

/// Format a diff between expected and actual messages.
fn formatDiff(allocator: Allocator, expected: []const u8, actual: []const u8) ![]const u8 {
    var output: std.ArrayList(u8) = .empty;
    errdefer output.deinit(allocator);

    try output.appendSlice(allocator, "--- Expected ---\n");

    const expected_parsed = std.json.parseFromSlice(std.json.Value, allocator, expected, .{}) catch {
        try output.appendSlice(allocator, expected);
        try output.appendSlice(allocator, "\n");
        try output.appendSlice(allocator, "\n+++ Actual +++\n");
        try output.appendSlice(allocator, actual);
        try output.appendSlice(allocator, "\n");
        return try output.toOwnedSlice(allocator);
    };
    defer expected_parsed.deinit();

    const expected_pretty = try std.json.Stringify.valueAlloc(allocator, expected_parsed.value, .{ .whitespace = .indent_2 });
    defer allocator.free(expected_pretty);
    try output.appendSlice(allocator, expected_pretty);
    try output.appendSlice(allocator, "\n");

    try output.appendSlice(allocator, "\n+++ Actual +++\n");

    const actual_parsed = std.json.parseFromSlice(std.json.Value, allocator, actual, .{}) catch {
        try output.appendSlice(allocator, actual);
        try output.appendSlice(allocator, "\n");
        return try output.toOwnedSlice(allocator);
    };
    defer actual_parsed.deinit();

    const actual_pretty = try std.json.Stringify.valueAlloc(allocator, actual_parsed.value, .{ .whitespace = .indent_2 });
    defer allocator.free(actual_pretty);
    try output.appendSlice(allocator, actual_pretty);
    try output.appendSlice(allocator, "\n");

    return try output.toOwnedSlice(allocator);
}

/// Build an updated snapshot from original messages and actual outputs.
fn buildUpdatedSnapshot(allocator: Allocator, original: Snapshot, actual_outputs: []const []const u8) !Snapshot {
    var messages: std.ArrayList(testing.snapshot.Message) = .empty;
    errdefer {
        for (messages.items) |msg| allocator.free(msg.json);
        messages.deinit(allocator);
    }

    var output_index: usize = 0;
    for (original.messages) |msg| {
        switch (msg.direction) {
            .send => {
                const json_copy = try allocator.dupe(u8, msg.json);
                errdefer allocator.free(json_copy);
                try messages.append(allocator, .{
                    .direction = .send,
                    .json = json_copy,
                    .line_start = msg.line_start,
                });
            },
            .expect => {
                if (output_index < actual_outputs.len) {
                    const json_copy = try allocator.dupe(u8, actual_outputs[output_index]);
                    errdefer allocator.free(json_copy);
                    try messages.append(allocator, .{
                        .direction = .expect,
                        .json = json_copy,
                        .line_start = msg.line_start,
                    });
                    output_index += 1;
                }
            },
        }
    }

    while (output_index < actual_outputs.len) {
        const json_copy = try allocator.dupe(u8, actual_outputs[output_index]);
        errdefer allocator.free(json_copy);
        try messages.append(allocator, .{
            .direction = .expect,
            .json = json_copy,
            .line_start = 0,
        });
        output_index += 1;
    }

    return .{
        .messages = try messages.toOwnedSlice(allocator),
        .allocator = allocator,
    };
}

/// Run a single snapshot test.
fn runSnapshotTest(allocator: Allocator, path: []const u8) !void {
    const content = std.fs.cwd().readFileAlloc(allocator, path, 1024 * 1024) catch |err| {
        std.debug.print("Failed to read snapshot file '{s}': {}\n", .{ path, err });
        return err;
    };
    defer allocator.free(content);

    var snap = testing.snapshot.parse(allocator, content) catch |err| {
        std.debug.print("Failed to parse snapshot file '{s}': {}\n", .{ path, err });
        return err;
    };
    defer snap.deinit();

    var result = testing.runner.runTest(allocator, snap, 10000) catch |err| {
        std.debug.print("Test execution failed for '{s}': {}\n", .{ path, err });
        return err;
    };
    defer result.deinit();

    if (result.passed) {
        std.debug.print("PASS: {s}\n", .{path});
        return;
    }

    if (update_snapshots) {
        var updated_snap = try buildUpdatedSnapshot(allocator, snap, result.actual_messages);
        defer updated_snap.deinit();

        const serialized = try testing.snapshot.serialize(updated_snap, allocator);
        defer allocator.free(serialized);

        std.fs.cwd().writeFile(.{
            .sub_path = path,
            .data = serialized,
        }) catch |err| {
            std.debug.print("Failed to update snapshot '{s}': {}\n", .{ path, err });
            return err;
        };

        std.debug.print("UPDATED: {s}\n", .{path});
        return;
    }

    std.debug.print("FAIL: {s}\n", .{path});

    if (result.first_mismatch_index) |idx| {
        std.debug.print("  First mismatch at message index {d}\n", .{idx});

        if (idx < result.expected_messages.len and idx < result.actual_messages.len) {
            const diff = try formatDiff(allocator, result.expected_messages[idx], result.actual_messages[idx]);
            defer allocator.free(diff);
            std.debug.print("{s}\n", .{diff});
        } else if (idx >= result.expected_messages.len) {
            std.debug.print("  Unexpected extra output message:\n", .{});
            if (idx < result.actual_messages.len) {
                std.debug.print("  {s}\n", .{result.actual_messages[idx]});
            }
        } else {
            std.debug.print("  Missing expected message:\n", .{});
            std.debug.print("  {s}\n", .{result.expected_messages[idx]});
        }
    }

    std.debug.print("  Expected {d} messages, got {d}\n", .{ result.expected_messages.len, result.actual_messages.len });

    return error.TestFailed;
}

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const snapshot_dir = "tests/snapshots";

    const snapshot_paths = try discoverSnapshots(allocator, snapshot_dir);
    defer {
        for (snapshot_paths) |p| allocator.free(p);
        allocator.free(snapshot_paths);
    }

    if (snapshot_paths.len == 0) {
        std.debug.print("No snapshot tests found in {s}\n", .{snapshot_dir});
        return;
    }

    std.debug.print("Running {d} snapshot test(s)...\n\n", .{snapshot_paths.len});

    var passed: usize = 0;
    var failed: usize = 0;
    var updated: usize = 0;

    for (snapshot_paths) |path| {
        runSnapshotTest(allocator, path) catch |err| {
            if (err == error.TestFailed) {
                failed += 1;
                continue;
            }
            return err;
        };

        if (update_snapshots) {
            updated += 1;
        } else {
            passed += 1;
        }
    }

    std.debug.print("\n", .{});

    if (update_snapshots) {
        std.debug.print("Updated {d} snapshot(s)\n", .{updated});
    } else {
        std.debug.print("Results: {d} passed, {d} failed\n", .{ passed, failed });
    }

    if (failed > 0) {
        std.process.exit(1);
    }
}

test "discoverSnapshots returns empty for missing directory" {
    const allocator = std.testing.allocator;
    const paths = try discoverSnapshots(allocator, "nonexistent/directory");
    defer {
        for (paths) |p| allocator.free(p);
        allocator.free(paths);
    }
    try std.testing.expectEqual(@as(usize, 0), paths.len);
}
