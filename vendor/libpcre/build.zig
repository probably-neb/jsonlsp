const std = @import("std");
const builtin = @import("builtin");

const pcre_vendor_dir = "vendor/pcre-8.45-6a08aa250b3ca1deea5fbc5f696bb4e25ac2da90";

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});
    const use_system = b.option(bool, "system_library", "link against libpcre from the system instead of source build") orelse false;

    const pcre_lib = if (use_system) null else try buildPcreLibrary(b, target, optimize);

    const mod = b.addModule("libpcre", .{
        .root_source_file = b.path("src/main.zig"),
        .optimize = optimize,
        .target = target,
    });
    try linkPcre(b, mod, pcre_lib, use_system);

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .optimize = optimize,
        .target = target,
    });
    const lib = b.addLibrary(.{
        .name = "libpcre.zig",
        .linkage = .static,
        .root_module = lib_mod,
    });
    try linkPcre(b, lib.root_module, pcre_lib, use_system);
    b.installArtifact(lib);

    const main_tests_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .optimize = optimize,
        .target = target,
    });
    const main_tests = b.addTest(.{
        .name = "main_tests",
        .root_module = main_tests_mod,
    });
    try linkPcre(b, main_tests.root_module, pcre_lib, use_system);

    const main_tests_run = b.addRunArtifact(main_tests);
    main_tests_run.step.dependOn(&main_tests.step);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests_run.step);
}

fn buildPcreLibrary(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !*std.Build.Step.Compile {
    var arena = std.heap.ArenaAllocator.init(b.allocator);
    defer arena.deinit();

    var files: std.ArrayList([]const u8) = .empty;

    const io = b.graph.io;
    var dir = std.Io.Dir.cwd().openDir(io, b.pathFromRoot(pcre_vendor_dir), .{ .iterate = true }) catch |err| {
        std.debug.panic("failed to open vendored pcre directory '{s}': {s}", .{ pcre_vendor_dir, @errorName(err) });
    };
    defer dir.close(io);

    var walker = dir.walk(arena.allocator()) catch |err| {
        std.debug.panic("failed to walk vendored pcre directory '{s}': {s}", .{ pcre_vendor_dir, @errorName(err) });
    };
    defer walker.deinit();

    while (try walker.next(io)) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.endsWith(u8, entry.path, ".c")) continue;
        if (!std.mem.startsWith(u8, entry.path, "pcre")) continue;
        if (std.mem.containsAtLeast(u8, entry.path, 1, "pcre16")) continue;
        if (std.mem.containsAtLeast(u8, entry.path, 1, "pcre32")) continue;
        if (std.mem.containsAtLeast(u8, entry.path, 1, "pcretest")) continue;
        if (std.mem.containsAtLeast(u8, entry.path, 1, "pcregrep")) continue;
        if (std.mem.containsAtLeast(u8, entry.path, 1, "pcreposix")) continue;
        if (std.mem.containsAtLeast(u8, entry.path, 1, "pcredemo")) continue;
        if (std.mem.containsAtLeast(u8, entry.path, 1, "pcre_jit_test")) continue;
        if (std.mem.containsAtLeast(u8, entry.path, 1, "dftables")) continue;

        const full_path = try std.mem.concat(arena.allocator(), u8, &.{ pcre_vendor_dir, "/", entry.path });
        try files.append(arena.allocator(), full_path);
    }

    if (files.items.len == 0) {
        std.debug.panic("no pcre C sources found under '{s}'", .{pcre_vendor_dir});
    }

    const lib_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    const lib = b.addLibrary(.{
        .name = "pcre",
        .linkage = .static,
        .root_module = lib_mod,
    });
    lib.root_module.link_libc = true;

    lib.root_module.addIncludePath(b.path(pcre_vendor_dir));
    lib.root_module.addIncludePath(b.path(pcre_vendor_dir ++ "/sljit"));

    lib.root_module.addCMacro("HAVE_CONFIG_H", "1");
    lib.root_module.addCMacro("PCRE_STATIC", "1");

    lib.root_module.addCSourceFiles(.{
        .files = files.items,
        .flags = &.{},
    });

    return lib;
}

pub fn linkPcre(b: *std.Build, mod: *std.Build.Module, libpcre: ?*std.Build.Step.Compile, use_system: bool) !void {
    if (use_system) {
        if (builtin.os.tag == .macos) {
            var code: u8 = undefined;
            if (b.runAllowFail(&[_][]const u8{ "pkg-config", "libpcre" }, &code, .Inherit)) |_| {
                mod.linkSystemLibrary("libpcre", .{});
            } else |_| {
                mod.linkSystemLibrary("pcre", .{});
            }
        } else {
            mod.linkSystemLibrary("pcre", .{});
        }
        return;
    }

    if (libpcre) |lib| {
        mod.linkLibrary(lib);
        mod.addIncludePath(b.path(pcre_vendor_dir));
        mod.addIncludePath(b.path(pcre_vendor_dir ++ "/sljit"));
        mod.addCMacro("HAVE_CONFIG_H", "1");
        return;
    }

    std.debug.panic("vendored pcre build was not created", .{});
}
