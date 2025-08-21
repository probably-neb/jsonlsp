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
    const test_suite = try fs.createFileAbsolute(args[2], .{});
    const tests_dir = try fs.openDirAbsolute(args[1], .{
        .iterate = true,
    });

    var output = test_suite.writer();

    var tests_dir_iter = tests_dir.iterate();

    try output.print(
        \\ const std = @import("std");
        \\ const JSONSchema = @import("json-schema.zig");
        \\
        \\
    ,
        .{},
    );

    while (try tests_dir_iter.next()) |draft| {
        if (draft.kind != .directory) continue;
        const draft_name = draft.name;
        const draft_dir = try tests_dir.openDir(draft_name, .{
            .iterate = true,
        });
        var draft_dir_iter = draft_dir.iterate();
        while (try draft_dir_iter.next()) |test_case| {
            if (test_case.kind != .file) continue;
            if (!mem.eql(u8, fs.path.extension(test_case.name), ".json")) continue;

            const test_case_name = fs.path.stem(test_case.name);

            const test_case_file = try draft_dir.openFile(test_case.name, .{});

            var json_reader = std.json.reader(arena, test_case_file.reader());
            const file_tests = std.json.parseFromTokenSource([]const Test_File, arena, &json_reader, .{
                .allocate = .alloc_always,
                .ignore_unknown_fields = true,
                .duplicate_field_behavior = .@"error",
            }) catch |err| {
                std.debug.print("failed to parse file: {s}/{s}", .{ draft_name, test_case.name });
                return err;
            };

            for (file_tests.value) |file_test| {
                const schema = try std.json.stringifyAlloc(arena, file_test.schema, .{
                    .whitespace = .indent_4,
                });
                for (file_test.tests) |file_test_case| {
                    const test_case_json = try std.json.stringifyAlloc(arena, file_test_case.data, .{
                        .whitespace = .indent_4,
                    });
                    const zig_test_name = try mem.join(arena, ".", &.{
                        draft_name,
                        test_case_name,
                        file_test.description,
                        file_test_case.description,
                    });
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
                        \\   const schema = JSONSchema.parse(
                        \\      {s}
                        \\   );
                        \\
                        \\   const case =
                        \\            {s}
                        \\   ;
                        \\   std.testing.assertEqual(schema.is_valid(case), {});
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
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        var line_iter = mem.splitScalar(u8, self.str, '\n');
        while (line_iter.next()) |line| {
            try writer.writeAll("\\\\ ");
            try writer.writeAll(line);
            try writer.writeByte('\n');
        }
    }
};

const PrettyJsonFmt = struct {
    json: std.json.Value,

    pub fn format(
        self: @This(),
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        const jws = std.json.writeStream(writer, .{
            .whitespace = .indent_4,
        });

        try self.json.jsonStringify(jws);
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
