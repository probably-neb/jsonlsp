# AGENTS.md

## Version Control

This project uses **jj** (Jujutsu), not git. Use jj commands instead of git:

- `jj log` - View commit history (not `git log`)
- `jj diff` - Show changes (not `git diff`)
- `jj new` - Create a new change (not `git commit`)
- `jj describe` - Edit change description
- `jj status` - Show working copy status

## Build Commands

- `zig build` - Build and install the `jsonls` executable and tool executables to `zig-out/`
- `zig build check` - Fast compilation check for `jsonls`, tools, and tests (used for build-on-save)
- `zig build run` - Build and run the language server
- `zig build run -- <args>` - Pass arguments to the language server
- `zig build test` - Run all unit tests
- `zig build test -Dtest-filter="test name"` - Run matching unit tests
- `zig build test:suite` - Build and run the JSON Schema test suite
- `zig build test:suite -Dno-run=true` - Build the JSON Schema test suite without running it
- `zig build test:suite -Dtest-filter="test name"` - Run matching JSON Schema test suite tests
- `zig build tool:run-snapshot-tests` - Run snapshot tests
- `zig build tool:run-snapshot-tests -- test_name` - Run a single snapshot test
- `zig build tool:run-snapshot-tests -Dupdate-snapshots=true` - Update snapshot files
- `zig build tool:generate-zed-config` - Generate Zed editor debug/task configurations
- `zig build tool:build-test-suite` - Regenerate JSON Schema test suite sources
- `zig build tool:generate-learnjsonschema` - Generate Learn JSON Schema markdown pages

## Code Style

- **Naming**: snake_case for variables/functions, PascalCase for types, SCREAMING_CASE for constants
- **Methods**: Never name the first parameter `self`. Use a descriptive name (e.g., `arena`, `store`, `gap_buf`)
- **Type-directed syntax**: Prefer Zig's point-free, type-directed forms when the type is already known. Use `.tag` instead of `Type.tag`, `.{ ... }` instead of `Type{ ... }`, and `.from_value(args)` or `const obj: Object = .from_value(args)` instead of `Object.from_value(args)` when the expected type makes the namespace unambiguous. Use the explicit `Type.foo(...)` form only when the type is not already known or when it materially improves clarity.
- **Memory**: Use `Arena` from `src/base/` for allocations. Use `arena.scoped()` / `scoped.release()` for temporary allocations on an existing arena. For true temporary allocations use `const scratch = Arena.get_scratch()` and corresponding `scratch.release()`
- **Lists**: Use `ArenaList` instead of `std.ArrayList` - it integrates with Arena and avoids realloc/memcpy. Only can be used when no intermediate allocations are happening on the arena while the array is constructed. For cases where other allocations are needed on the same arena (e.g. copying strings, etc) use a `Xar`
- **Comments**: Use `//!` for module-level docs, `///` for item docs. Minimal inline comments
- **Tests**: Place `test` blocks at module bottom. Use `std.testing.refAllDecls(@This())` to ensure all decls compile
- **Functions** Avoid trivial wrapper/helper functions that only forward or repack data. Inline the logic at the call site unless the wrapper adds meaningful abstractions or is reused enough to justify it
