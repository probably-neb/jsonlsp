//! Generate markdown pages from learnjsonschema.com content.
//! Usage: generate-learnjsonschema <output_directory>

const std = @import("std");

const Allocator = std.mem.Allocator;
const str8 = []const u8;

const sitemap_url = "https://www.learnjsonschema.com/sitemap.xml";
const upstream_raw_base = "https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content";
const upstream_api_base = "https://api.github.com/repos/sourcemeta/learnjsonschema.com/contents/content";
const site_base = "https://www.learnjsonschema.com";
const dialects = [_]str8{ "2020-12", "2019-09", "draft7", "draft6", "draft4", "draft3" };

const Page = struct {
    url: str8,
    dialect: str8,
    rel_path: str8,
    source_url: str8,
};

const GithubEntry = struct {
    name: ?str8 = null,
    type: ?str8 = null,
    download_url: ?str8 = null,
};

pub fn main(init: std.process.Init) !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const io = init.io;

    const args = try init.minimal.args.toSlice(arena);
    if (args.len != 2) {
        std.debug.print("Usage: generate-learnjsonschema <output_directory>\n", .{});
        std.process.exit(1);
    }

    var client: std.http.Client = .{ .allocator = arena, .io = io };
    defer client.deinit();

    var source_lookup = std.StringHashMap(str8).init(arena);
    try build_source_lookup(arena, &client, &source_lookup);

    const pages = try parse_sitemap(arena, try fetch_text(arena, &client, sitemap_url), source_lookup);

    if (std.Io.Dir.cwd().access(io, args[1], .{})) {
        try std.Io.Dir.cwd().deleteTree(io, args[1]);
    } else |err| switch (err) {
        error.FileNotFound => {},
        else => return err,
    }
    try std.Io.Dir.cwd().createDirPath(io, args[1]);

    for (pages) |page| {
        const route = try join_route(arena, &.{ page.dialect, page.rel_path });
        const path = try std.fs.path.join(arena, &.{ args[1], try route_to_output(arena, route) });
        try write_file(io, path, try render_page(arena, args[1], page, try fetch_text(arena, &client, page.source_url), path));
        std.debug.print("{s}\n", .{path});
    }
    try build_index_pages(io, arena, args[1], pages);
}

fn fetch_text(allocator: Allocator, client: *std.http.Client, url: str8) !str8 {
    var body: std.Io.Writer.Allocating = .init(allocator);
    errdefer body.deinit();
    const result = try client.fetch(.{
        .location = .{ .url = url },
        .response_writer = &body.writer,
        .extra_headers = &.{.{ .name = "user-agent", .value = "jsonls-learnjsonschema-generator" }},
    });
    if (result.status != .ok) {
        std.debug.print("GET {s} failed with HTTP status {d}\n", .{ url, @intFromEnum(result.status) });
        return error.HttpRequestFailed;
    }
    return try body.toOwnedSlice();
}

fn build_source_lookup(allocator: Allocator, client: *std.http.Client, lookup: *std.StringHashMap(str8)) !void {
    for (dialects) |dialect| {
        const dialect_entries = try fetch_github_entries(allocator, client, try std.fmt.allocPrint(allocator, "{s}/{s}", .{ upstream_api_base, dialect }));
        for (dialect_entries) |entry| {
            const name = entry.name orelse continue;
            const kind = entry.type orelse continue;
            if (std.mem.eql(u8, name, "_index.markdown") and std.mem.eql(u8, kind, "file")) {
                try lookup.put(try allocator.dupe(u8, dialect), entry.download_url orelse return error.MissingDownloadUrl);
            } else if (std.mem.eql(u8, kind, "dir")) {
                const vocabulary_route = try join_route(allocator, &.{ dialect, name });
                const vocabulary_entries = try fetch_github_entries(allocator, client, try std.fmt.allocPrint(allocator, "{s}/{s}/{s}", .{ upstream_api_base, dialect, name }));
                for (vocabulary_entries) |vocabulary_entry| {
                    const vocabulary_name = vocabulary_entry.name orelse continue;
                    const vocabulary_kind = vocabulary_entry.type orelse continue;
                    if (std.mem.eql(u8, vocabulary_name, "_index.markdown") and std.mem.eql(u8, vocabulary_kind, "file")) {
                        try lookup.put(vocabulary_route, vocabulary_entry.download_url orelse return error.MissingDownloadUrl);
                    } else if (std.mem.eql(u8, vocabulary_kind, "file") and std.mem.endsWith(u8, vocabulary_name, ".markdown")) {
                        const stem = vocabulary_name[0 .. vocabulary_name.len - ".markdown".len];
                        const slug = try allocator.alloc(u8, stem.len);
                        for (stem, slug) |src, *dest| dest.* = std.ascii.toLower(src);
                        try lookup.put(try join_route(allocator, &.{ vocabulary_route, slug }), vocabulary_entry.download_url orelse return error.MissingDownloadUrl);
                    }
                }
            }
        }
    }
}

fn fetch_github_entries(allocator: Allocator, client: *std.http.Client, url: str8) ![]const GithubEntry {
    return (try std.json.parseFromSlice([]const GithubEntry, allocator, try fetch_text(allocator, client, url), .{
        .allocate = .alloc_always,
        .ignore_unknown_fields = true,
        .duplicate_field_behavior = .@"error",
    })).value;
}

fn parse_sitemap(allocator: Allocator, xml: str8, source_lookup: std.StringHashMap(str8)) ![]const Page {
    var pages: std.ArrayList(Page) = .empty;
    var pos: usize = 0;
    while (std.mem.indexOfPos(u8, xml, pos, "<loc>")) |start| {
        const url_start = start + "<loc>".len;
        const url_end = std.mem.indexOfPos(u8, xml, url_start, "</loc>") orelse break;
        const url = xml[url_start..url_end];
        pos = url_end + "</loc>".len;

        for (dialects) |dialect| {
            const prefix = try std.fmt.allocPrint(allocator, "{s}/{s}/", .{ site_base, dialect });
            if (!std.mem.startsWith(u8, url, prefix)) continue;
            const rel = std.mem.trim(u8, std.mem.trim(u8, url[prefix.len..], " \t\r\n"), "/");
            const route = try join_route(allocator, &.{ dialect, rel });
            try pages.append(allocator, .{
                .url = url,
                .dialect = dialect,
                .rel_path = rel,
                .source_url = source_lookup.get(route) orelse return error.MissingUpstreamSource,
            });
            break;
        }
    }
    std.mem.sort(Page, pages.items, {}, struct {
        fn less_than(_: void, a: Page, b: Page) bool {
            var ai = dialects.len;
            var bi = dialects.len;
            for (dialects, 0..) |dialect, index| {
                if (std.mem.eql(u8, dialect, a.dialect)) ai = index;
                if (std.mem.eql(u8, dialect, b.dialect)) bi = index;
            }
            return ai < bi or (ai == bi and std.mem.lessThan(u8, a.rel_path, b.rel_path));
        }
    }.less_than);
    return try pages.toOwnedSlice(allocator);
}

fn render_page(allocator: Allocator, output_root: str8, page: Page, source_text: str8, path: str8) !str8 {
    const front_matter, const body = blk: {
        if (std.mem.startsWith(u8, source_text, "---\n")) {
            if (std.mem.indexOfPos(u8, source_text, "---\n".len, "\n---\n")) |end| {
                break :blk .{ source_text["---\n".len..end], source_text[end + "\n---\n".len ..] };
            }
        }
        break :blk .{ "", source_text };
    };
    const route = try join_route(allocator, &.{ page.dialect, page.rel_path });
    var title_slug = page.dialect;
    var rel_parts = std.mem.splitScalar(u8, page.rel_path, '/');
    while (rel_parts.next()) |part| {
        if (part.len != 0) title_slug = part;
    }
    const title = parse_scalar(front_matter, "title") orelse parse_scalar(front_matter, "keyword") orelse try slug_to_title(allocator, title_slug);

    var out: std.ArrayList(u8) = .empty;
    try out.print(allocator,
        \\# {s}
        \\
        \\- Original: [{s}]({s})
        \\- Upstream source: [{s}]({s})
    , .{ title, page.url, page.url, page.source_url, page.source_url });
    try out.append(allocator, '\n');
    if (parse_scalar(front_matter, "specification")) |v| try out.print(allocator, "- Specification: [{s}]({s})\n", .{ v, v });
    if (parse_scalar(front_matter, "metaschema")) |v| try out.print(allocator, "- Metaschema: `{s}`\n", .{v});
    if (parse_scalar(front_matter, "introduced_in")) |v| try out.print(allocator, "- Introduced in: `{s}`\n", .{v});
    if (parse_scalar(front_matter, "summary")) |v| try out.print(allocator, "\n{s}\n", .{v});

    const cleaned = try clean_body(allocator, output_root, body, route, path);
    if (std.mem.trim(u8, cleaned, " \t\r\n").len == 0) return try std.fmt.allocPrint(allocator, "{s}\n", .{std.mem.trimEnd(u8, out.items, "\n")});
    return try std.fmt.allocPrint(allocator, "{s}\n{s}", .{ std.mem.trimEnd(u8, out.items, "\n"), cleaned });
}

fn clean_body(allocator: Allocator, output_root: str8, body: str8, route: str8, path: str8) !str8 {
    var result = try replace_ref_shortcodes(allocator, output_root, body, path);
    result = try replace_link_shortcodes(allocator, output_root, result, route, path);
    result = try replace_constraint_warnings(allocator, output_root, result, route, path);

    const admonitions = [_]struct { shortcode: str8, label: str8 }{
        .{ .shortcode = "best-practice", .label = "Best Practice" },
        .{ .shortcode = "common-pitfall", .label = "Common Pitfall" },
        .{ .shortcode = "learning-more", .label = "Digging Deeper" },
    };
    for (admonitions) |item| result = try replace_blocks(allocator, result, item.shortcode, .admonition, item.label);

    const examples = [_]struct { shortcode: str8, label: str8 }{
        .{ .shortcode = "schema", .label = "Schema" },
        .{ .shortcode = "instance-pass", .label = "Valid instance" },
        .{ .shortcode = "instance-fail", .label = "Invalid instance" },
        .{ .shortcode = "instance-annotation", .label = "Annotation" },
    };
    for (examples) |item| result = try replace_blocks(allocator, result, item.shortcode, .example, item.label);

    var out: std.ArrayList(u8) = .empty;
    var newlines: usize = 0;
    for (result) |byte| {
        if (byte == '\n') {
            newlines += 1;
            if (newlines <= 2) try out.append(allocator, byte);
        } else {
            newlines = 0;
            try out.append(allocator, byte);
        }
    }
    return try std.fmt.allocPrint(allocator, "{s}\n", .{std.mem.trim(u8, out.items, "\n")});
}

fn replace_ref_shortcodes(allocator: Allocator, output_root: str8, body: str8, path: str8) !str8 {
    var out: std.ArrayList(u8) = .empty;
    var pos: usize = 0;
    while (find_open_shortcode(body, pos, "ref")) |open| {
        try out.appendSlice(allocator, body[pos..open.start]);
        const route = trim_quotes(std.mem.trim(u8, open.args, " \t\r\n"));
        try out.appendSlice(allocator, try relative_link(allocator, output_root, path, route));
        pos = open.end;
    }
    try out.appendSlice(allocator, body[pos..]);
    return try out.toOwnedSlice(allocator);
}

fn replace_link_shortcodes(allocator: Allocator, output_root: str8, body: str8, route: str8, path: str8) !str8 {
    const current = try split_non_empty(allocator, route, '/');
    const current_dialect = if (current.len > 0) current[0] else "";
    const current_vocabulary = if (current.len > 1) current[1] else "";

    var out: std.ArrayList(u8) = .empty;
    var pos: usize = 0;
    while (find_open_shortcode(body, pos, "link")) |open| {
        try out.appendSlice(allocator, body[pos..open.start]);
        const keyword = shortcode_arg(open.args, "keyword") orelse "link";
        const stripped = std.mem.trim(u8, keyword, " \t\r\n");
        var keyword_slug: std.ArrayList(u8) = .empty;
        for (if (std.mem.startsWith(u8, stripped, "$")) stripped[1..] else stripped) |byte| switch (byte) {
            '$', '_', ' ', '-' => {},
            else => try keyword_slug.append(allocator, std.ascii.toLower(byte)),
        };
        const keyword_route = try join_route(allocator, &.{
            shortcode_arg(open.args, "dialect") orelse current_dialect,
            shortcode_arg(open.args, "vocabulary") orelse current_vocabulary,
            try keyword_slug.toOwnedSlice(allocator),
        });
        try out.print(allocator, "[`{s}`]({s})", .{ keyword, try relative_link(allocator, output_root, path, keyword_route) });
        pos = open.end;
    }
    try out.appendSlice(allocator, body[pos..]);
    return try out.toOwnedSlice(allocator);
}

fn replace_constraint_warnings(allocator: Allocator, output_root: str8, body: str8, route: str8, path: str8) !str8 {
    const parts = try split_non_empty(allocator, route, '/');
    const type_link = try relative_link(allocator, output_root, path, try join_route(allocator, &.{ if (parts.len > 0) parts[0] else "", if (parts.len > 1) parts[1] else "", "type" }));

    var out: std.ArrayList(u8) = .empty;
    var pos: usize = 0;
    while (find_open_shortcode(body, pos, "constraint-warning")) |open| {
        try out.appendSlice(allocator, body[pos..open.start]);
        try out.print(
            allocator,
            "> **Type constraint:** Non-`{s}` instances also validate against this keyword. Use [`type`]({s}) if you need to restrict the accepted type.",
            .{ trim_quotes(std.mem.trim(u8, open.args, " `\"\t\r\n")), type_link },
        );
        pos = open.end;
    }
    try out.appendSlice(allocator, body[pos..]);
    return try out.toOwnedSlice(allocator);
}

const BlockKind = enum { admonition, example };

fn replace_blocks(allocator: Allocator, body: str8, shortcode: str8, kind: BlockKind, label: str8) !str8 {
    var out: std.ArrayList(u8) = .empty;
    var pos: usize = 0;
    while (find_open_shortcode(body, pos, shortcode)) |open| {
        const close = find_close_shortcode(body, open.end, shortcode) orelse break;
        try out.appendSlice(allocator, body[pos..open.start]);
        const inner = std.mem.trim(u8, body[open.end..close.start], "\n");
        const caption = if (std.mem.trim(u8, open.args, " \t\r\n").len == 0) null else trim_quotes(std.mem.trim(u8, open.args, " `\"\t\r\n"));
        switch (kind) {
            .example => if (caption) |c|
                try out.print(allocator, "### {s}: {s}\n\n```json\n{s}\n```", .{ label, c, inner })
            else
                try out.print(allocator, "### {s}\n\n```json\n{s}\n```", .{ label, inner }),
            .admonition => {
                try out.print(allocator, "> **{s}:**", .{label});
                var lines = std.mem.splitScalar(u8, inner, '\n');
                while (lines.next()) |line| {
                    if (std.mem.trim(u8, line, " \t\r").len == 0) try out.appendSlice(allocator, "\n>") else try out.print(allocator, "\n> {s}", .{line});
                }
            },
        }
        pos = close.end;
    }
    try out.appendSlice(allocator, body[pos..]);
    return try out.toOwnedSlice(allocator);
}

const Shortcode = struct { start: usize, end: usize, args: str8 };

fn find_open_shortcode(body: str8, start_pos: usize, name: str8) ?Shortcode {
    var pos = start_pos;
    while (std.mem.indexOfPos(u8, body, pos, "{{<")) |start| {
        var cursor = skip_space(body, start + "{{<".len);
        if (!starts_with_token(body[cursor..], name)) {
            pos = start + "{{<".len;
            continue;
        }
        cursor += name.len;
        const end = std.mem.indexOfPos(u8, body, cursor, ">}}") orelse return null;
        return .{ .start = start, .end = end + ">}}".len, .args = std.mem.trim(u8, body[cursor..end], " \t\r\n") };
    }
    return null;
}

fn find_close_shortcode(body: str8, start_pos: usize, name: str8) ?struct { start: usize, end: usize } {
    var pos = start_pos;
    while (std.mem.indexOfPos(u8, body, pos, "{{<")) |start| {
        var cursor = skip_space(body, start + "{{<".len);
        if (cursor >= body.len or body[cursor] != '/') {
            pos = start + "{{<".len;
            continue;
        }
        cursor = skip_space(body, cursor + 1);
        if (!starts_with_token(body[cursor..], name)) {
            pos = start + "{{<".len;
            continue;
        }
        cursor = skip_space(body, cursor + name.len);
        if (std.mem.startsWith(u8, body[cursor..], ">}}")) return .{ .start = start, .end = cursor + ">}}".len };
        pos = start + "{{<".len;
    }
    return null;
}

fn build_index_pages(io: std.Io, allocator: Allocator, output_root: str8, pages: []const Page) !void {
    var root_lines: std.ArrayList(u8) = .empty;
    try root_lines.appendSlice(allocator,
        \\# Learn JSON Schema index
        \\
        \\Generated from [learnjsonschema.com](https://www.learnjsonschema.com/) with backlinks to the original pages.
        \\
        \\## Dialects
        \\
    );
    for (dialects) |dialect| try root_lines.print(allocator, "- [{s}]({s}/index.md)\n", .{ try slug_to_title(allocator, dialect), dialect });
    try root_lines.append(allocator, '\n');
    try write_file(io, try std.fs.path.join(allocator, &.{ output_root, "index.md" }), root_lines.items);

    for (dialects) |dialect| {
        var vocabularies: std.ArrayList(str8) = .empty;
        for (pages) |page| {
            if (!std.mem.eql(u8, page.dialect, dialect)) continue;
            const parts = try split_non_empty(allocator, page.rel_path, '/');
            if (parts.len == 0) continue;
            for (vocabularies.items) |vocabulary| {
                if (std.mem.eql(u8, vocabulary, parts[0])) break;
            } else try vocabularies.append(allocator, parts[0]);
        }
        std.mem.sort(str8, vocabularies.items, {}, struct {
            fn less_than(_: void, a: str8, b: str8) bool {
                return std.mem.lessThan(u8, a, b);
            }
        }.less_than);

        var dialect_lines: std.ArrayList(u8) = .empty;
        try dialect_lines.print(allocator,
            \\# {s}
            \\
            \\- Original: [{s}/{s}/]({s}/{s}/)
            \\- Upstream source: [{s}/{s}/_index.markdown]({s}/{s}/_index.markdown)
            \\
            \\## Vocabularies
            \\
        , .{ try slug_to_title(allocator, dialect), site_base, dialect, site_base, dialect, upstream_raw_base, dialect, upstream_raw_base, dialect });
        for (vocabularies.items) |vocabulary| try dialect_lines.print(allocator, "- [{s}]({s}/index.md)\n", .{ try slug_to_title(allocator, vocabulary), vocabulary });
        try dialect_lines.append(allocator, '\n');
        try write_file(io, try std.fs.path.join(allocator, &.{ output_root, dialect, "index.md" }), dialect_lines.items);

        for (vocabularies.items) |vocabulary| {
            var vocab_lines: std.ArrayList(u8) = .empty;
            try vocab_lines.print(allocator,
                \\# {s}
                \\
                \\- Dialect: [{s}](../index.md)
                \\- Original: [{s}/{s}/{s}/]({s}/{s}/{s}/)
                \\- Upstream source: [{s}/{s}/{s}/_index.markdown]({s}/{s}/{s}/_index.markdown)
                \\
                \\## Pages
                \\
            , .{ try slug_to_title(allocator, vocabulary), try slug_to_title(allocator, dialect), site_base, dialect, vocabulary, site_base, dialect, vocabulary, upstream_raw_base, dialect, vocabulary, upstream_raw_base, dialect, vocabulary });

            var keyword_pages: std.ArrayList(Page) = .empty;
            for (pages) |page| {
                if (std.mem.eql(u8, page.dialect, dialect) and !std.mem.eql(u8, page.rel_path, vocabulary) and std.mem.startsWith(u8, page.rel_path, vocabulary) and page.rel_path.len > vocabulary.len and page.rel_path[vocabulary.len] == '/') try keyword_pages.append(allocator, page);
            }
            std.mem.sort(Page, keyword_pages.items, {}, struct {
                fn less_than(_: void, a: Page, b: Page) bool {
                    return std.mem.lessThan(u8, a.rel_path, b.rel_path);
                }
            }.less_than);
            for (keyword_pages.items) |page| {
                const page_route = try join_route(allocator, &.{ page.dialect, page.rel_path });
                const page_path = try std.fs.path.join(allocator, &.{ output_root, try route_to_output(allocator, page_route) });
                const file = std.Io.Dir.cwd().openFile(io, page_path, .{}) catch null;
                const title = if (file) |f| title: {
                    defer f.close(io);
                    var buf: [512]u8 = undefined;
                    var reader = f.reader(io, &buf);
                    const first_line = reader.interface.takeDelimiterExclusive('\n') catch "";
                    break :title if (std.mem.startsWith(u8, first_line, "# ")) try allocator.dupe(u8, first_line[2..]) else try slug_to_title(allocator, std.fs.path.basename(std.fs.path.dirname(page_path) orelse ""));
                } else try slug_to_title(allocator, std.fs.path.basename(std.fs.path.dirname(page_path) orelse ""));
                try vocab_lines.print(allocator, "- [{s}]({s}.md)\n", .{ title, std.fs.path.basename(page.rel_path) });
            }
            try vocab_lines.append(allocator, '\n');
            try write_file(io, try std.fs.path.join(allocator, &.{ output_root, dialect, vocabulary, "index.md" }), vocab_lines.items);
        }
    }
}

fn parse_scalar(front_matter: str8, key: str8) ?str8 {
    var lines = std.mem.splitScalar(u8, front_matter, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (!std.mem.startsWith(u8, trimmed, key)) continue;
        var rest = std.mem.trimStart(u8, trimmed[key.len..], " \t");
        if (rest.len == 0 or rest[0] != ':') continue;
        rest = std.mem.trim(u8, rest[1..], " \t\r");
        if (rest.len >= 2 and rest[0] == '"' and rest[rest.len - 1] == '"') return rest[1 .. rest.len - 1];
        return rest;
    }
    return null;
}

fn route_to_output(allocator: Allocator, route_value: str8) !str8 {
    const route = std.mem.trim(u8, route_value, "/");
    if (route.len == 0) return try allocator.dupe(u8, "index.md");
    const parts = try split_non_empty(allocator, route, '/');
    if (parts.len <= 1) return try std.mem.join(allocator, "/", &.{ parts[0], "index.md" });
    const file_name = try std.fmt.allocPrint(allocator, "{s}.md", .{parts[parts.len - 1]});
    var output_parts = try allocator.alloc(str8, parts.len);
    @memcpy(output_parts[0 .. parts.len - 1], parts[0 .. parts.len - 1]);
    output_parts[parts.len - 1] = file_name;
    return try std.mem.join(allocator, "/", output_parts);
}

fn relative_link(allocator: Allocator, output_root: str8, from_path: str8, target_route: str8) !str8 {
    const target_parts = try split_non_empty(allocator, try route_to_output(allocator, target_route), '/');
    var from_rel = from_path;
    if (std.mem.startsWith(u8, from_rel, output_root)) from_rel = std.mem.trimStart(u8, from_rel[output_root.len..], "/");
    const from_parts = try split_non_empty(allocator, std.fs.path.dirname(from_rel) orelse "", '/');
    var common: usize = 0;
    while (common < from_parts.len and common < target_parts.len and std.mem.eql(u8, from_parts[common], target_parts[common])) common += 1;
    var parts: std.ArrayList(str8) = .empty;
    for (from_parts[common..]) |_| try parts.append(allocator, "..");
    for (target_parts[common..]) |part| try parts.append(allocator, part);
    return try std.mem.join(allocator, "/", parts.items);
}

fn slug_to_title(allocator: Allocator, slug: str8) !str8 {
    const mappings = [_]struct { str8, str8 }{
        .{ "meta-data", "Meta Data" }, .{ "format-annotation", "Format Annotation" }, .{ "format-assertion", "Format Assertion" },
        .{ "draft7", "Draft 7" },      .{ "draft6", "Draft 6" },                      .{ "draft4", "Draft 4" },
        .{ "draft3", "Draft 3" },      .{ "2019-09", "2019-09" },                     .{ "2020-12", "2020-12" },
    };
    for (mappings) |mapping| if (std.mem.eql(u8, slug, mapping[0])) return mapping[1];
    var out: std.ArrayList(u8) = .empty;
    var parts = std.mem.splitScalar(u8, slug, '-');
    while (parts.next()) |part| {
        if (part.len == 0) continue;
        if (out.items.len != 0) try out.append(allocator, ' ');
        try out.append(allocator, std.ascii.toUpper(part[0]));
        if (part.len > 1) try out.appendSlice(allocator, part[1..]);
    }
    return try out.toOwnedSlice(allocator);
}

fn join_route(allocator: Allocator, parts: []const str8) !str8 {
    var non_empty: std.ArrayList(str8) = .empty;
    for (parts) |part| {
        const trimmed = std.mem.trim(u8, part, "/");
        if (trimmed.len != 0) try non_empty.append(allocator, trimmed);
    }
    return try std.mem.join(allocator, "/", non_empty.items);
}

fn split_non_empty(allocator: Allocator, value: str8, delimiter: u8) ![]const str8 {
    var parts: std.ArrayList(str8) = .empty;
    var iter = std.mem.splitScalar(u8, value, delimiter);
    while (iter.next()) |part| if (part.len != 0) try parts.append(allocator, part);
    return try parts.toOwnedSlice(allocator);
}

fn shortcode_arg(args: str8, key: str8) ?str8 {
    var pos: usize = 0;
    while (pos < args.len) {
        while (pos < args.len and std.ascii.isWhitespace(args[pos])) pos += 1;
        const key_start = pos;
        while (pos < args.len and (std.ascii.isAlphanumeric(args[pos]) or args[pos] == '_')) pos += 1;
        const found_key = args[key_start..pos];
        while (pos < args.len and std.ascii.isWhitespace(args[pos])) pos += 1;
        if (pos >= args.len or args[pos] != '=') break;
        pos += 1;
        while (pos < args.len and std.ascii.isWhitespace(args[pos])) pos += 1;
        if (pos >= args.len or args[pos] != '"') break;
        pos += 1;
        const value_start = pos;
        while (pos < args.len and args[pos] != '"') pos += 1;
        const value = args[value_start..pos];
        if (pos < args.len) pos += 1;
        if (std.mem.eql(u8, found_key, key)) return value;
    }
    return null;
}

fn trim_quotes(value: str8) str8 {
    return if (value.len >= 2 and ((value[0] == '"' and value[value.len - 1] == '"') or (value[0] == '\'' and value[value.len - 1] == '\''))) value[1 .. value.len - 1] else value;
}

fn skip_space(value: str8, start: usize) usize {
    var cursor = start;
    while (cursor < value.len and std.ascii.isWhitespace(value[cursor])) cursor += 1;
    return cursor;
}

fn starts_with_token(value: str8, token: str8) bool {
    return std.mem.startsWith(u8, value, token) and (value.len == token.len or std.ascii.isWhitespace(value[token.len]) or value[token.len] == '>');
}

fn write_file(io: std.Io, path: str8, data: str8) !void {
    if (std.fs.path.dirname(path)) |dir| try std.Io.Dir.cwd().createDirPath(io, dir);
    try std.Io.Dir.cwd().writeFile(io, .{ .sub_path = path, .data = data });
}

test {
    std.testing.refAllDecls(@This());
}
