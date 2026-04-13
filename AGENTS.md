# AGENTS.md

## Version Control
This project uses **jj** (Jujutsu), not git. Use jj commands instead of git:
- `jj log` - View commit history (not `git log`)
- `jj diff` - Show changes (not `git diff`)
- `jj new` - Create a new change (not `git commit`)
- `jj describe` - Edit change description
- `jj status` - Show working copy status

## Build Commands
- `zig build` - Build the jsonls executable
- `zig build check` - Fast compilation check (no binary output, used for build-on-save)
- `zig build run` - Build and run the language server
- `zig build test` - Run all unit tests
- `zig build test -Dtest-filter="test name"` - Run a single test by name
- `zig build test:snapshots` - Run snapshot tests
- `zig build test:snapshots -- test_name` - Run a single snapshot test
- `zig build test:snapshots -Dupdate-snapshots=true` - Update snapshot files
- `zig build test:suite` - Run JSON Schema test suite
- `zig build debug:zed` - Generate Zed editor debug/task configurations

## Code Style
- **Naming**: snake_case for variables/functions, PascalCase for types, SCREAMING_CASE for constants
- **Methods**: Never name the first parameter `self`. Use a descriptive name (e.g., `arena`, `store`, `gap_buf`)
- **Type-directed syntax**: Prefer Zig's point-free, type-directed forms when the type is already known. Use `.tag` instead of `Type.tag`, `.{ ... }` instead of `Type{ ... }`, and `.from_value(args)` or `const obj: Object = .from_value(args)` instead of `Object.from_value(args)` when the expected type makes the namespace unambiguous. Use the explicit `Type.foo(...)` form only when the type is not already known or when it materially improves clarity.
- **Memory**: Use `Arena` from `src/base/` for allocations. Use `arena.scoped()` / `scoped.release()` for temporary allocations
- **Lists**: Use `ArenaList` instead of `std.ArrayList` - it integrates with Arena and avoids realloc/memcpy
- **Comments**: Use `//!` for module-level docs, `///` for item docs. Minimal inline comments
- **Tests**: Place `test` blocks at module bottom. Use `std.testing.refAllDecls(@This())` to ensure all decls compile
