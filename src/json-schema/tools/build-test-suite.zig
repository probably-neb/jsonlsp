const std = @import("std");
const mem = std.mem;
const debug = std.debug;
const fs = std.fs;

const str8 = []const u8;

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const arena = arena_state.allocator();
    const args = try std.process.argsAlloc(arena);
    if (args.len != 3) {
        std.debug.panic("Not enough args", .{});
    }
    const tests_dir = try fs.openDirAbsolute(args[1], .{
        .iterate = true,
    });
    const test_suite_dir = try fs.openDirAbsolute(args[2], .{});

    var tests_dir_iter = tests_dir.iterate();

    while (try tests_dir_iter.next()) |draft| {
        if (draft.kind != .directory) continue;
        const draft_name = draft.name;
        const draft_dir = try tests_dir.openDir(draft_name, .{
            .iterate = true,
        });
        var draft_dir_iter = draft_dir.iterate();
        const draft_test_file = try test_suite_dir.createFile(
            try std.mem.join(arena, "", &.{ draft_name, ".zig" }),
            .{},
        );

        var output_buf: [4096]u8 = undefined;
        var output_writer = draft_test_file.writer(&output_buf);
        const output = &output_writer.interface;
        defer output.flush() catch unreachable;

        try output.print(
            \\ const std = @import("std");
            \\ const JSONSchema = @import("json-schema");
            \\
            \\
        ,
            .{},
        );

        while (try draft_dir_iter.next()) |test_case| {
            if (test_case.kind != .file) continue;
            if (!mem.eql(u8, fs.path.extension(test_case.name), ".json")) continue;

            const test_case_name = fs.path.stem(test_case.name);

            const test_case_file = try draft_dir.openFile(test_case.name, .{});
            var test_case_file_reader_buf: [512]u8 = undefined;
            var test_case_file_reader_impl = test_case_file.reader(&test_case_file_reader_buf);
            const test_case_file_reader = &test_case_file_reader_impl.interface;

            var json_reader: std.json.Reader = .init(arena, test_case_file_reader);
            const file_tests = std.json.parseFromTokenSource([]const Test_File, arena, &json_reader, .{
                .allocate = .alloc_always,
                .ignore_unknown_fields = true,
                .duplicate_field_behavior = .@"error",
            }) catch |err| {
                std.debug.print("failed to parse file: {s}/{s}", .{ draft_name, test_case.name });
                return err;
            };

            for (file_tests.value) |file_test| {
                const schema = try std.fmt.allocPrint(arena, "{f}", .{std.json.fmt(file_test.schema, .{
                    .whitespace = .indent_4,
                })});
                for (file_test.tests) |file_test_case| {
                    const zig_test_name = try mem.join(arena, ".", &.{
                        test_case_name,
                        file_test.description,
                        file_test_case.description,
                    });
                    defer arena.free(zig_test_name);
                    const test_case_json = try std.fmt.allocPrint(arena, "{f}", .{std.json.fmt(file_test_case.data, .{
                        .whitespace = .indent_4,
                    })});
                    defer arena.free(test_case_json);
                    for (zig_test_name) |*char| {
                        if (char.* == '"') {
                            char.* = '\'';
                        }
                        if (char.* == ' ') {
                            char.* = '-';
                        }
                    }
                    try output.print(
                        \\ test "{s}" {{
                        \\   const schema = try JSONSchema.parse(
                        \\      {f}
                        \\   );
                        \\
                        \\   const case =
                        \\            {f}
                        \\   ;
                        \\   try std.testing.expectEqual(schema.is_valid(case), {});
                        \\ }}
                        \\
                    ,
                        .{
                            zig_test_name,
                            MultiLineStringFormat{ .str = schema },
                            MultiLineStringFormat{ .str = test_case_json },
                            file_test_case.valid,
                        },
                    );
                }
            }
        }
    }
}

const MultiLineStringFormat = struct {
    str: str8,

    pub fn format(
        self: @This(),
        writer: *std.Io.Writer,
    ) !void {
        var line_iter = mem.splitScalar(u8, self.str, '\n');
        while (line_iter.next()) |line| {
            try writer.writeAll("\\\\ ");
            try writer.writeAll(line);
            try writer.writeByte('\n');
        }
    }
};

const Test_File = struct {
    description: str8,
    schema: std.json.Value,
    tests: []const Case,

    const Case = struct {
        description: str8,
        data: std.json.Value,
        valid: bool,
    };
};
