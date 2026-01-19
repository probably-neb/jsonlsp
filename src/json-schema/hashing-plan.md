# JSON Schema Refactor Plan: Supporting Arbitrary $id and Path Refs

In order to support arbitrary $id refs, a general refactor is in order

1. separate out "parsing" and "usage" arena
    - "parsing":
        - json
        - json-hash cache: base.XarMap[JSON_Hash: *Constraint]
        - released at end of parse
    - "usage":
        - constraints
        - copies of string values as needed (will it ever be needed with hashing?)

2. Create custom JSON parse + json.Value
    - should store + update hash as going
    - will be used to create JSON_Hash cache
    - during parse, should look up in map if current json already turned into constraint
    - can resolve path refs into json structure, and just call parse on the resolved path, will dedupe automatically with json hash cache

---

# Detailed Implementation Plan

## Stage 1: Separate Parsing and Usage Arenas

### Goal

Isolate temporary parsing allocations from the final constraint structures, allowing the JSON and intermediate data structures to be freed after parsing completes.

### Implementation Steps

#### Step 1.1: Modify `parseWithRevision` to use two arenas

**Current code:**

```zig
pub fn parseWithRevision(schema_contents: str8, revision: ?Revision) !Schema {
    var arena_state = try Arena.init(.{});
    const arena = arena_state.allocator();
    const parsed_schema = try std.json.parseFromSlice(...);
    // ... parsing ...
    return Schema{
        .root = root,
        .arena = arena_state,
    };
}
```

**New code:**

```zig
pub fn parseWithRevision(schema_contents: str8, revision: ?Revision) !Schema {
    // Usage arena - persists, returned in Schema
    var usage_arena = try Arena.init(.{});
    errdefer usage_arena.deinit();

    // Parsing arena - temporary, freed at end
    var parse_arena = try Arena.init(.{});
    defer parse_arena.deinit();

    const parsed_schema = try std.json.parseFromSlice(
        std.json.Value,
        parse_arena.allocator(),  // JSON goes in parse arena
        schema_contents,
        .{...}
    );

    // ... parsing uses both arenas ...

    return Schema{
        .root = root,
        .arena = usage_arena,
    };
}
```

#### Step 1.2: Update `ParseContext` to hold both arenas

```zig
const ParseContext = struct {
    revision: Revision,
    defs: []const Schema.Definition = &.{},

    // New fields:
    usage_arena: *Arena,    // For constraints that persist
    parse_arena: *Arena,    // For temporary parsing structures

    // JSON hash -> Constraint cache (allocated in parse_arena, values point to usage_arena)
    constraint_cache: XarMap(u64, *Schema.Constraint, 64) = .{},
};
```

#### Step 1.3: Update all constraint allocations to use usage_arena

All calls to `arena.create(Schema.Constraint)` must use `ctx.usage_arena`.

**Before:**

```zig
const constraint = try arena.allocator().create(Schema.Constraint);
```

**After:**

```zig
const constraint = try ctx.usage_arena.create(Schema.Constraint);
```

#### Step 1.4: Update string copies to use usage_arena

For any strings that must persist (like property names), copy them to usage_arena:

```zig
// Copy string from parse_arena to usage_arena
fn persist_string(ctx: *ParseContext, s: str8) !str8 {
    const copy = try ctx.usage_arena.alloc(u8, s.len);
    @memcpy(copy, s);
    return copy;
}
```

### Deliverables

- [ ] `parseWithRevision` creates two arenas
- [ ] `ParseContext` holds references to both arenas
- [ ] All `Constraint` allocations use `usage_arena`
- [ ] JSON parsing uses `parse_arena`
- [ ] All existing tests pass
- [ ] Memory usage is reduced (parse_arena freed after parsing)

---

## Stage 2: Custom JSON Parser with Incremental Hashing

### Goal

Create a custom JSON value type that computes its hash incrementally during parsing, enabling O(1) lookup of already-parsed JSON structures.

### Implementation Steps

#### Step 2.1: Define `HashableJsonValue` type

Create a new file `jsonlsp/src/json-schema/hashable-json.zig`:

```zig
const std = @import("std");
const base = @import("base");
const Arena = base.Arena;

pub const HashableJsonValue = struct {
    hash: u64,
    kind: Kind,

    pub const Kind = union(enum) {
        null: void,
        bool: bool,
        integer: i64,
        float: f64,
        string: []const u8,
        array: []HashableJsonValue,
        object: Object,
    };

    pub const Object = struct {
        keys: [][]const u8,
        values: []HashableJsonValue,

        pub fn get(obj: Object, key: []const u8) ?*const HashableJsonValue {
            for (obj.keys, obj.values) |k, *v| {
                if (std.mem.eql(u8, k, key)) return v;
            }
            return null;
        }
    };

    /// Navigate a JSON pointer path (e.g., "/properties/name/type")
    pub fn resolve_pointer(value: *const HashableJsonValue, pointer: []const u8) ?*const HashableJsonValue {
        // Implementation follows RFC 6901
        // ...
    }
};
```

#### Step 2.2: Implement incremental hash computation

The hash is computed as we build each value, bottom-up:

```zig
pub fn compute_hash(value: *const HashableJsonValue) u64 {
    var hasher = std.hash.Wyhash.init(0xdeadbeef);
    hash_into(&hasher, value);
    return hasher.final();
}

fn hash_into(hasher: *std.hash.Wyhash, value: *const HashableJsonValue) void {
    switch (value.kind) {
        .null => hasher.update(&[_]u8{0}),
        .bool => |b| hasher.update(&[_]u8{ 1, @intFromBool(b) }),
        .integer => |i| {
            const f: f64 = @floatFromInt(i);
            hasher.update(&[_]u8{2});
            hasher.update(std.mem.asBytes(&f));
        },
        .float => |f| {
            hasher.update(&[_]u8{2});
            hasher.update(std.mem.asBytes(&f));
        },
        .string => |s| {
            hasher.update(&[_]u8{4});
            hasher.update(s);
        },
        .array => |arr| {
            hasher.update(&[_]u8{5});
            for (arr) |*item| {
                hash_into(hasher, item);
            }
        },
        .object => |obj| {
            hasher.update(&[_]u8{6});
            // Must hash in sorted key order for consistency
            // Use scratch arena for sorting indices
            // ...
        },
    }
}
```

#### Step 2.3: Implement custom JSON parser

**Note:** Reuse the existing tokenizer/lexer from `src/json/json.zig`. The `Lexer` struct already handles tokenization with `Token_Kind` (l_curly, r_curly, l_bracket, r_bracket, comma, colon, string, number, null, true, false, err, eof). We only need to write a new parser that consumes these tokens and builds `HashableJsonValue` with incremental hashing.

```zig
const json = @import("../json/json.zig");

pub fn parse(arena: *Arena, input: []const u8) !HashableJsonValue {
    // Reuse existing lexer for tokenization
    var lexer = json.Lexer.zero;
    try lexer.lex(arena, input);

    var parser = Parser{
        .arena = arena,
        .tokens = lexer.tokens.items,
        .input = input,
        .pos = 0,
    };
    return parser.parseValue();
}

const Parser = struct {
    arena: *Arena,
    tokens: []const json.Token,
    input: []const u8,  // Original input for extracting string/number content
    pos: usize,

    fn parseValue(p: *Parser) !HashableJsonValue {
        const token = p.tokens[p.pos];
        return switch (token.kind) {
            .null => p.parseNull(),
            .true, .false => p.parseBool(),
            .string => p.parseString(),
            .l_bracket => p.parseArray(),
            .l_curly => p.parseObject(),
            .number => p.parseNumber(),
            else => error.InvalidJson,
        };
    }

    // Each parse* function computes hash after building value
    fn parseObject(p: *Parser) !HashableJsonValue {
        // Parse all key-value pairs using tokens
        // Compute hash from sorted keys
        // Return HashableJsonValue with pre-computed hash
    }
    // ...
};
```

#### Step 2.4: Implement JSON pointer resolution

```zig
pub fn resolve_pointer(value: *const HashableJsonValue, pointer: []const u8) ?*const HashableJsonValue {
    if (pointer.len == 0) return value;
    if (pointer[0] != '#') return null;

    var current = value;
    var path = pointer[1..]; // Skip '#'

    while (path.len > 0) {
        if (path[0] != '/') return null;
        path = path[1..]; // Skip '/'

        // Find next segment
        const end = std.mem.indexOfScalar(u8, path, '/') orelse path.len;
        const segment = unescape_segment(path[0..end]);
        path = path[end..];

        switch (current.kind) {
            .object => |obj| {
                current = obj.get(segment) orelse return null;
            },
            .array => |arr| {
                const index = std.fmt.parseInt(usize, segment, 10) catch return null;
                if (index >= arr.len) return null;
                current = &arr[index];
            },
            else => return null,
        }
    }
    return current;
}
```

### Deliverables

- [ ] New `hashable-json.zig` file with `HashableJsonValue` type
- [ ] Incremental hash computation during parsing
- [ ] JSON pointer resolution (`#/path/to/value`)
- [ ] Unit tests for JSON parsing and hashing
- [ ] Unit tests for pointer resolution
- [ ] Hash consistency tests (same JSON = same hash regardless of key order)

---

## Stage 3: Integrate HashableJsonValue into JSON Schema Parsing

### Goal

Before adding new caching features, integrate the `HashableJsonValue` type from `hashable-json.zig` into the existing `json-schema.zig` parsing code. This involves:

1. Replacing `std.json.Value` with `HashableJsonValue` in parsing functions
2. Removing the existing `ValueHash` implementation from `json-schema.zig` (moving tests to `hashable-json.zig`)
3. Using the pre-computed hash from `HashableJsonValue` instead of computing hashes on-demand

### Implementation Steps

#### Step 3.1: Remove `ValueHash` from json-schema.zig

The existing `ValueHash` packed struct (lines 739-844) computes hashes on `std.json.Value`. This should be removed since `HashableJsonValue` already computes hashes during parsing.

**Delete:**

- The `ValueHash` packed struct and all its methods (`hash_value`, `top_level_value_hash`, `hash_inner`)
- The `test ValueHash` block (lines 1275-1539)

#### Step 3.2: Move ValueHash tests to hashable-json.zig

The tests from the `test ValueHash` block should be adapted and moved to `hashable-json.zig`. Most of these tests already have equivalents in `hashable-json.zig`:

- `test "hash consistency - same value same hash"`
- `test "hash consistency - different values different hash"`
- `test "hash consistency - object key order independent"`
- etc.

Any missing test cases should be added to `hashable-json.zig`.

#### Step 3.3: Update parseWithRevision to use HashableJsonValue

**Current code uses `std.json.parseFromSlice`:**

```zig
const parsed_schema = try std.json.parseFromSlice(
    std.json.Value,
    parse_arena.allocator(),
    schema_contents,
    .{...}
);
```

**New code uses `hashable_json.parse`:**

```zig
const root_json = try hashable_json.parse(parse_arena, schema_contents);
```

#### Step 3.4: Update parsing functions to accept HashableJsonValue

All functions that currently take `*std.json.Value` or `std.json.Value` need to be updated:

```zig
// Before:
fn parse_into_constraint(ctx: *ParseContext, value: *std.json.Value, constraint: *Schema.Constraint) ParseError!void

// After:
fn parse_into_constraint(ctx: *ParseContext, value: *const HashableJsonValue, constraint: *Schema.Constraint) ParseError!void
```

Key functions to update:

- `parse_into_constraint`
- `parse_constraint`
- All `parse_validation__*` functions
- All `parse_applicitor__*` functions

#### Step 3.5: Update value access patterns

Replace `std.json.Value` union access with `HashableJsonValue.Kind` access:

**Before:**

```zig
switch (value.*) {
    .object => |obj| {
        if (obj.get("type")) |type_val| { ... }
    },
    .bool => |b| { ... },
    ...
}
```

**After:**

```zig
switch (value.kind) {
    .object => |obj| {
        if (obj.get("type")) |type_val| { ... }
    },
    .bool => |b| { ... },
    ...
}
```

#### Step 3.6: Use pre-computed hash for const/enum validation

In `parse_validation__const` and `parse_validation__enum`, use the hash directly from `HashableJsonValue`:

**Before (computing hash):**

```zig
fn parse_validation__const(value: *std.json.Value) Schema.Constraint.Kind {
    const hash = ValueHash.hash_value(value);
    return .{ .@"const" = hash };
}
```

**After (using pre-computed hash):**

```zig
fn parse_validation__const(value: *const HashableJsonValue) Schema.Constraint.Kind {
    return .{ .@"const" = value.hash };
}
```

#### Step 3.7: Update constraint types to use u64 hash

If `Schema.Constraint.Kind` uses `ValueHash`, update it to use `u64` directly since that's what `HashableJsonValue.hash` provides.

### Deliverables

- [ ] `ValueHash` struct removed from `json-schema.zig`
- [ ] `test ValueHash` tests moved/merged into `hashable-json.zig`
- [ ] `parseWithRevision` uses `hashable_json.parse` instead of `std.json.parseFromSlice`
- [ ] All parsing functions updated to accept `*const HashableJsonValue`
- [ ] Value access patterns updated for `HashableJsonValue.Kind` union
- [ ] `const` and `enum` validations use pre-computed hash
- [ ] All existing tests pass
- [ ] No hash computation happens in `json-schema.zig` - all hashes come from `HashableJsonValue`

---

## Stage 4: Hash-Based Constraint Caching and Ref Resolution

### Goal

Use the JSON hash cache to automatically deduplicate constraints and resolve arbitrary `$ref` paths by parsing the target JSON and looking up/creating constraints through the cache.

### Implementation Steps

#### Step 4.1: Add constraint cache to ParseContext

```zig
const ParseContext = struct {
    revision: Revision,
    usage_arena: *Arena,
    parse_arena: *Arena,
    root_json: *const HashableJsonValue,  // Keep root for path resolution

    // Hash -> Constraint cache
    // Key: JSON hash (u64)
    // Value: pointer to already-parsed Constraint
    constraint_cache: XarMap(u64, *Schema.Constraint, 64) = .{},

    // $id -> JSON value mapping (for URI-based refs)
    id_registry: XarMap(u64, *const HashableJsonValue, 16) = .{},
};
```

#### Step 4.2: Collect $id declarations during JSON parse

When parsing JSON, track `$id` fields:

```zig
fn parseObject(p: *Parser, ctx: *ParseContext) !HashableJsonValue {
    // ... parse object ...

    // After building object, check for $id
    if (obj.get("$id")) |id_val| {
        if (id_val.kind == .string) {
            const id_hash = std.hash.Wyhash.hash(0, id_val.kind.string);
            try ctx.id_registry.put(ctx.parse_arena, id_hash, &result);
        }
    }

    return result;
}
```

#### Step 4.3: Modify parse_constraint to use cache

```zig
fn parse_constraint(ctx: *ParseContext, json: *const HashableJsonValue) ParseError!*Schema.Constraint {
    // Check cache first
    const hash = json.hash;
    if (ctx.constraint_cache.get(hash)) |existing| {
        return existing.*;
    }

    // Not in cache, parse it
    const constraint = try ctx.usage_arena.create(Schema.Constraint);

    // Add to cache BEFORE parsing (handles recursive refs)
    try ctx.constraint_cache.put(ctx.parse_arena, hash, constraint);

    // Now parse into the constraint
    try parse_into_constraint(ctx, json, constraint);

    return constraint;
}
```

#### Step 4.4: Implement unified $ref resolution

```zig
fn resolve_ref(ctx: *ParseContext, ref_string: []const u8) !?*Schema.Constraint {
    // Case 1: JSON pointer ref (starts with #)
    if (ref_string.len > 0 and ref_string[0] == '#') {
        if (ctx.root_json.resolve_pointer(ref_string)) |target_json| {
            // Parse the target JSON - cache handles dedup
            return try parse_constraint(ctx, target_json);
        }
        return null;
    }

    // Case 2: $id-based ref (URI)
    const id_hash = std.hash.Wyhash.hash(0, ref_string);
    if (ctx.id_registry.get(id_hash)) |target_json| {
        return try parse_constraint(ctx, target_json.*);
    }

    // Case 3: URI with fragment (e.g., "https://example.com/schema#/defs/foo")
    if (std.mem.indexOfScalar(u8, ref_string, '#')) |hash_pos| {
        const base_uri = ref_string[0..hash_pos];
        const fragment = ref_string[hash_pos..];

        const base_hash = std.hash.Wyhash.hash(0, base_uri);
        if (ctx.id_registry.get(base_hash)) |base_json| {
            if (base_json.*.resolve_pointer(fragment)) |target_json| {
                return try parse_constraint(ctx, target_json);
            }
        }
    }

    return null;
}
```

#### Step 4.5: Update $ref handling in parse_into_constraint

```zig
fn parse_into_constraint(ctx: *ParseContext, json: *const HashableJsonValue, constraint: *Schema.Constraint) ParseError!void {
    constraint.next = null;
    constraint.kind = .true;

    switch (json.kind) {
        .object => |obj| {
            // Handle $ref
            if (obj.get("$ref")) |ref_val| {
                if (ref_val.kind == .string) {
                    if (try resolve_ref(ctx, ref_val.kind.string)) |target| {
                        constraint.kind = .{ .ref = target };

                        // In draft4-7, $ref overrides all siblings
                        if (ctx.revision != .draft2019_09 and
                            ctx.revision != .draft2020_12 and
                            ctx.revision != .draft_next) {
                            return;
                        }
                        // In 2019-09+, $ref can combine with siblings
                        // Continue parsing other keywords...
                    }
                }
            }

            // ... rest of object parsing ...
        },
        // ...
    }
}
```

#### Step 4.6: Update main parse function

```zig
pub fn parseWithRevision(schema_contents: str8, revision: ?Revision) !Schema {
    var usage_arena = try Arena.init(.{});
    errdefer usage_arena.deinit();

    var parse_arena = try Arena.init(.{});
    defer parse_arena.deinit();

    // Parse JSON with custom parser (computes hashes)
    const root_json = try HashableJsonValue.parse(&parse_arena, schema_contents);

    var ctx = ParseContext{
        .revision = revision orelse detectRevision(&root_json),
        .usage_arena = &usage_arena,
        .parse_arena = &parse_arena,
        .root_json = &root_json,
        .constraint_cache = .{},
        .id_registry = .{},
    };

    // First pass: collect all $id declarations
    collectIdDeclarations(&ctx, &root_json);

    // Parse root schema (cache handles everything)
    const root = try parse_constraint(&ctx, &root_json);

    return Schema{
        .root = root,
        .arena = usage_arena,
    };
}

fn collectIdDeclarations(ctx: *ParseContext, json: *const HashableJsonValue) void {
    switch (json.kind) {
        .object => |obj| {
            // Check for $id at this level
            if (obj.get("$id")) |id_val| {
                if (id_val.kind == .string) {
                    const id_hash = std.hash.Wyhash.hash(0, id_val.kind.string);
                    ctx.id_registry.put(ctx.parse_arena, id_hash, json) catch {};
                }
            }
            // Recurse into all values
            for (obj.values) |*v| {
                collectIdDeclarations(ctx, v);
            }
        },
        .array => |arr| {
            for (arr) |*item| {
                collectIdDeclarations(ctx, item);
            }
        },
        else => {},
    }
}
```

### Deliverables

- [ ] Constraint cache in ParseContext using XarMap
- [ ] $id registry for URI-based refs
- [ ] Unified `resolve_ref` function handling all ref types:
    - [ ] `#/path/to/value` (JSON pointer)
    - [ ] `#/$defs/name` and `#/definitions/name` (definition refs)
    - [ ] `https://example.com/id` ($id refs)
    - [ ] `https://example.com/id#/path` (URI + fragment)
- [ ] Automatic deduplication via hash cache
- [ ] Recursive ref handling (cache entry created before parsing)
- [ ] All existing tests pass
- [ ] New tests for:
    - [ ] Arbitrary path refs (`#/properties/foo`)
    - [ ] $id-based refs
    - [ ] URI + fragment refs
    - [ ] Circular refs via $id
    - [ ] Hash collision handling (if hashes match, verify JSON equality)

---

## Stage 5: Code Reorganization

### Goal

Reorganize the codebase to establish clearer module boundaries:

1. Move `hashable-json.zig` from `json-schema/` to the `json/` subsystem
2. Move JSON-schema-specific code (like JSON pointer resolution) from `hashable-json.zig` into `json-schema.zig`
3. Establish `hashable-json` as a sibling to the existing lenient (error-recovering) parser, sharing the lexer

### Implementation Steps

#### Step 5.1: Identify code to move out of hashable-json.zig

The following should be moved to `json-schema.zig` since they are JSON Schema specific:

- `resolve_pointer` function - JSON pointers (RFC 6901) are used by JSON Schema `$ref`
- `resolve_pointer_mut` function
- `unescape_pointer_segment` function
- Related tests for pointer resolution

#### Step 5.2: Move hashable-json.zig to json subsystem

Relocate the file:

```
src/json-schema/hashable-json.zig  →  src/json/hashable-json.zig
```

Update the import in `json-schema.zig`:

```zig
// Before:
pub const hashable_json = @import("hashable-json.zig");

// After:
pub const hashable_json = @import("json").hashable;
```

#### Step 5.3: Update json subsystem exports

In `src/json/json.zig`, add export for hashable parsing:

```zig
pub const hashable = @import("hashable-json.zig");

// Entry points:
pub const parse_lenient = @import("parse.zig").parse;  // existing error-recovering parser
pub const parse_hashed = hashable.parse;                // new hashing parser
```

#### Step 5.4: Keep parsing implementations separate

The two parsing approaches serve different purposes and should remain in separate files:

- `src/json/parse.zig` (or existing file) - Lenient, error-recovering parsing for editor use
- `src/json/hashable-json.zig` - Strict parsing with hash computation for schema validation

Both share:

- The lexer/tokenizer from `src/json/json.zig` (or `lexer.zig`)
- Token types and definitions

They differ in:

- Error handling (lenient vs strict)
- Output types (`json.Value` vs `HashableJsonValue`)
- Hash computation (none vs incremental)

#### Step 5.5: Move JSON pointer code to json-schema.zig

Add to `json-schema.zig`:

```zig
const HashableJsonValue = hashable_json.HashableJsonValue;

/// Resolve a JSON pointer (RFC 6901) relative to a HashableJsonValue.
/// Used for $ref resolution in JSON Schema.
pub fn resolve_json_pointer(
    root: *const HashableJsonValue,
    pointer: []const u8,
) ?*const HashableJsonValue {
    // Implementation moved from hashable-json.zig
    // ...
}

fn unescape_pointer_segment(arena: *Arena, segment: []const u8) ![]const u8 {
    // Implementation moved from hashable-json.zig
    // ...
}
```

#### Step 5.6: Update tests

- Move JSON pointer tests from `hashable-json.zig` to `json-schema.zig`
- Keep hash computation tests in `hashable-json.zig` (they test the JSON subsystem)
- Keep JSON parsing tests in `hashable-json.zig`

### Deliverables

- [ ] `hashable-json.zig` moved to `src/json/` directory
- [ ] JSON pointer resolution moved to `json-schema.zig`
- [ ] `src/json/json.zig` exports both `parse_lenient` and `parse_hashed` entry points
- [ ] Both parsers share the lexer but have separate implementations
- [ ] `json-schema.zig` imports hashable JSON from `json` subsystem
- [ ] All tests pass in their new locations
- [ ] No circular dependencies between `json` and `json-schema` modules

### File Structure After Reorganization

```
src/
├── json/
│   ├── json.zig              # Main entry point, exports lexer + both parsers
│   ├── lexer.zig             # Shared tokenizer (if separate file)
│   ├── parse.zig             # Lenient/error-recovering parser
│   └── hashable-json.zig     # Strict parser with hash computation
│
└── json-schema/
    ├── json-schema.zig       # Schema parsing, validation, JSON pointer resolution
    └── hashing-plan.md       # This plan document
```

---

## Summary

| Stage | Focus              | Key Changes                                                         |
| ----- | ------------------ | ------------------------------------------------------------------- |
| 1     | Arena separation   | Two arenas, parse arena freed after parsing                         |
| 2     | Custom JSON parser | HashableJsonValue with incremental hashing, pointer resolution      |
| 3     | Integration        | Replace std.json with HashableJsonValue, remove duplicate hash code |
| 4     | Hash-based caching | XarMap cache, unified ref resolution, automatic dedup               |
| 5     | Reorganization     | Move hashable-json to json subsystem, separate schema-specific code |

### Benefits of this approach

1. **Memory efficiency**: Parse-time structures freed after parsing
2. **Automatic deduplication**: Same JSON = same constraint (via hash)
3. **Simple ref resolution**: Just resolve path to JSON, parse it, cache handles dedup
4. **Handles all ref types**: Path refs, $id refs, and hybrid refs all use same mechanism
5. **Recursive refs work**: Cache entry created before parsing prevents infinite loops
6. **No pre-pass needed for definitions**: Cache handles forward references naturally
