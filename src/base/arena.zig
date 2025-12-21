const std = @import("std");
const builtin = @import("builtin");
const posix = std.posix;

/// Reserve virtual address space with no access permissions.
/// - POSIX: `mmap(PROT_NONE, MAP_PRIVATE|MAP_ANON)`
/// - Windows: `VirtualAlloc(MEM_RESERVE, PAGE_NOACCESS)`
///
/// Returned memory must be released with the corresponding OS call:
/// - POSIX: `munmap`
/// - Windows: `VirtualFree(..., MEM_RELEASE)`
///
/// Note: this returns an aligned pointer suitable for subsequent protection
/// changes / commit operations.
fn virtualalloc(reserve_size: usize) Arena.Error![]align(page_size) u8 {
    const size = std.mem.alignForward(usize, reserve_size, page_size);

    switch (builtin.os.tag) {
        .windows => {
            const w = std.os.windows;

            const ptr = w.kernel32.VirtualAlloc(
                null,
                size,
                w.MEM.RESERVE,
                w.PAGE.NOACCESS,
            );

            if (ptr == null) return error.OutOfMemory;

            return @as([*]align(page_size) u8, @ptrCast(@alignCast(ptr)))[0..size];
        },
        else => {
            // Reserve virtual address space with no access permissions (PROT_NONE)
            // This reserves the address range without committing physical memory
            return try posix.mmap(
                null,
                size,
                posix.PROT.NONE,
                .{ .TYPE = .PRIVATE, .ANONYMOUS = true },
                -1,
                0,
            );
        },
    }
}

/// Commit physical memory (back it with pages) and make it readable/writable.
/// - POSIX: `mprotect(PROT_READ|PROT_WRITE)`
/// - Windows: `VirtualAlloc(MEM_COMMIT, PAGE_READWRITE)`
fn virtualcommit(base: [*]align(page_size) u8, start: usize, len: usize) Arena.Error!void {
    if (len == 0) return;

    switch (builtin.os.tag) {
        .windows => {
            const w = std.os.windows;
            const addr: ?*anyopaque = @ptrCast(base + start);
            const p = w.kernel32.VirtualAlloc(
                addr,
                len,
                w.MEM.COMMIT,
                w.PAGE.READWRITE,
            );
            if (p == null) return error.OutOfMemory;
        },
        else => {
            const slice: []align(page_size) u8 = @alignCast(base[start .. start + len]);
            posix.mprotect(slice, posix.PROT.READ | posix.PROT.WRITE) catch |err| {
                return switch (err) {
                    error.OutOfMemory => error.OutOfMemory,
                    error.AccessDenied => error.AccessDenied,
                    error.Unexpected => error.Unexpected,
                };
            };
        },
    }
}

/// Default size to reserve for an arena (64 GB of virtual address space)
pub const default_reserve_size: usize = 64 * 1024 * 1024 * 1024;

/// Default commit granularity (64 KB)
pub const default_commit_size: usize = 64 * 1024;

/// Page size for the current platform
pub const page_size = std.heap.page_size_min;

/// Arena allocator that reserves a large virtual address space upfront
/// and commits physical pages as needed.
///
/// This design is inspired by Ryan Fleury's arena allocator pattern:
/// https://www.rfleury.com/p/untangling-lifetimes-the-arena-allocator
///
/// Key benefits:
/// - O(1) allocation (just bump a pointer)
/// - O(1) bulk deallocation (just reset the position)
/// - Memory contiguity for cache-friendly access
/// - No per-allocation bookkeeping overhead
pub const Arena = struct {
    /// The reserved virtual address space
    memory: [*]align(page_size) u8,
    /// Total reserved size (virtual address space)
    capacity: usize,
    /// Current allocation position (bytes in use)
    pos: usize,
    /// How many bytes are currently committed (backed by physical memory)
    committed: usize,
    /// Commit granularity
    commit_size: usize,

    const Self = @This();

    pub const InitOptions = struct {
        /// Size of virtual address space to reserve
        reserve_size: usize = default_reserve_size,
        /// Granularity for committing physical pages
        commit_size: usize = default_commit_size,
    };

    pub const Error = error{
        OutOfMemory,
        AccessDenied,
        PermissionDenied,
        LockedMemoryLimitExceeded,
        MemoryMappingNotSupported,
        ProcessFdQuotaExceeded,
        SystemFdQuotaExceeded,
        MappingAlreadyExists,
        Unexpected,
    };

    /// Initialize an arena by reserving virtual address space.
    /// No physical memory is committed until allocations are made.
    pub fn init(options: InitOptions) Error!Self {
        const reserve_size = std.mem.alignForward(usize, options.reserve_size, page_size);

        const memory = try virtualalloc(reserve_size);

        return .{
            .memory = memory.ptr,
            .capacity = reserve_size,
            .pos = 0,
            .committed = 0,
            .commit_size = options.commit_size,
        };
    }

    /// Release all virtual memory back to the operating system.
    pub fn deinit(self: *Self) void {
        switch (builtin.os.tag) {
            .windows => {
                const w = std.os.windows;
                const ptr: ?*anyopaque = @ptrCast(self.memory);
                // dwSize must be 0 when using MEM_RELEASE
                _ = w.kernel32.VirtualFree(ptr, 0, w.MEM.RELEASE);
            },
            else => {
                const slice: []align(page_size) u8 = @alignCast(self.memory[0..self.capacity]);
                posix.munmap(slice);
            },
        }
        self.* = undefined;
    }

    /// Allocate `size` bytes from the arena.
    /// Returns a slice of uninitialized memory.
    pub fn push(arena: *Self, size: usize) Error![]u8 {
        return arena.push_aligned(size, 1);
    }

    /// Allocate `size` bytes from the arena, aligned to `alignment`.
    pub fn push_aligned(arena: *Self, size: usize, alignment: usize) Error![]u8 {
        const aligned_pos = std.mem.alignForward(usize, arena.pos, alignment);
        const new_pos = aligned_pos + size;

        if (new_pos > arena.capacity) {
            return error.OutOfMemory;
        }

        // Commit more physical memory if needed
        if (new_pos > arena.committed) {
            try arena.commit_up_to(new_pos);
        }

        arena.pos = new_pos;
        return arena.memory[aligned_pos..new_pos];
    }

    /// Allocate `size` bytes from the arena, initialized to zero.
    pub fn push_zero(arena: *Self, size: usize) Error![]u8 {
        return arena.push_zero_aligned(size, 1);
    }

    /// Allocate `size` bytes from the arena, aligned and zeroed.
    pub fn push_zero_aligned(arena: *Self, size: usize, alignment: usize) Error![]u8 {
        const slice = try arena.push_aligned(size, alignment);
        @memset(slice, 0);
        return slice;
    }

    /// Allocate and return a pointer to a single item of type `T`.
    pub fn create(arena: *Self, comptime T: type) Error!*T {
        const slice = try arena.push_zero_aligned(@sizeOf(T), @alignOf(T));
        return @ptrCast(@alignCast(slice.ptr));
    }

    /// Allocate a slice of `n` items of type `T`.
    pub fn alloc(arena: *Self, comptime T: type, n: usize) Error![]T {
        const byte_size = @sizeOf(T) * n;
        const slice = try arena.push_aligned(byte_size, @alignOf(T));
        return @as([*]T, @ptrCast(@alignCast(slice.ptr)))[0..n];
    }

    /// Allocate a slice of `n` items of type `T`, initialized to zero.
    pub fn alloc_zero(arena: *Self, comptime T: type, n: usize) Error![]T {
        const byte_size = @sizeOf(T) * n;
        const slice = try arena.push_zero_aligned(byte_size, @alignOf(T));
        return @as([*]T, @ptrCast(@alignCast(slice.ptr)))[0..n];
    }

    /// Pop `size` bytes from the top of the arena.
    pub fn pop(arena: *Self, size: usize) void {
        arena.pos = if (size > arena.pos) 0 else arena.pos - size;
    }

    /// Get the current allocation position.
    pub fn get_pos(arena: *const Self) usize {
        return arena.pos;
    }

    /// Restore the arena to a previous position.
    /// Any memory beyond this position is considered freed.
    pub fn set_pos(arena: *Self, new_pos: usize) void {
        if (new_pos < arena.pos) {
            arena.pos = new_pos;
        }
    }

    /// Clear all allocations, resetting position to zero.
    /// Committed memory is retained for future allocations.
    pub fn clear(arena: *Self) void {
        arena.pos = 0;
    }

    /// Create a temporary scope for sub-lifetime allocations.
    /// Call `release()` on the returned `Temp` to restore the arena position.
    pub fn temp(arena: *Self) Temp {
        return .{
            .arena = arena,
            .pos = arena.pos,
        };
    }

    /// Returns a `std.mem.Allocator` interface for this arena.
    /// Note: `free` and `resize` are no-ops since arena uses bulk deallocation.
    pub fn allocator(arena: *Self) std.mem.Allocator {
        return .{
            .ptr = arena,
            .vtable = &.{
                .alloc = alloc_fn,
                .resize = resize_fn,
                .remap = remap_fn,
                .free = free_fn,
            },
        };
    }

    fn alloc_fn(ctx: *anyopaque, len: usize, ptr_align: std.mem.Alignment, _: usize) ?[*]u8 {
        const self: *Self = @ptrCast(@alignCast(ctx));
        const alignment = ptr_align.toByteUnits();
        const slice = self.push_aligned(len, alignment) catch return null;
        return slice.ptr;
    }

    fn resize_fn(_: *anyopaque, _: []u8, _: std.mem.Alignment, _: usize, _: usize) bool {
        // Arena doesn't support resizing individual allocations
        return false;
    }

    fn remap_fn(_: *anyopaque, _: []u8, _: std.mem.Alignment, _: usize, _: usize) ?[*]u8 {
        // Arena doesn't support remapping individual allocations
        return null;
    }

    fn free_fn(_: *anyopaque, _: []u8, _: std.mem.Alignment, _: usize) void {
        // Arena uses bulk deallocation - individual frees are no-ops
    }

    /// Commit physical memory up to the specified position.
    fn commit_up_to(arena: *Self, target_pos: usize) Error!void {
        const new_committed = std.mem.alignForward(usize, target_pos, arena.commit_size);
        const commit_target = @min(new_committed, arena.capacity);

        if (commit_target <= arena.committed) {
            return;
        }

        const start = arena.committed;
        const len = commit_target - start;

        try virtualcommit(arena.memory, start, len);

        arena.committed = commit_target;
    }

    /// Temporary arena scope for sub-lifetime allocations.
    /// Captures the arena position at creation and restores it on release.
    pub const Temp = struct {
        arena: *Arena,
        pos: usize,

        /// Release the temporary scope, restoring the arena to its previous position.
        /// All allocations made since `temp()` was called are effectively freed.
        pub fn release(self: Temp) void {
            self.arena.set_pos(self.pos);
        }
    };
};

/// FreeList wraps an Arena and maintains a free list of previously freed allocations.
/// This allows memory to be reused without resetting the entire arena.
///
/// Each allocation is at least `min_alloc_size` bytes (2 * @sizeOf(usize)) to ensure
/// there's enough space to store the free list node (next pointer and length) when freed.
pub const FreeList = struct {
    arena: *Arena,
    /// Head of the free list - points to the first free node
    free_head: ?*FreeNode,

    const Self = @This();

    /// Free list node stored in freed memory
    const FreeNode = struct {
        /// Pointer to the next free node
        next: ?*FreeNode,
        /// Size of this free block (including the node header)
        size: usize,
    };

    /// Minimum allocation size to ensure space for free list node
    pub const min_alloc_size = @max(2 * @sizeOf(usize), @alignOf(FreeNode));

    /// Minimum alignment to ensure we can store a FreeNode in freed memory
    pub const min_alignment = @alignOf(FreeNode);

    /// Initialize a FreeList wrapping the given arena.
    pub fn init(arena: *Arena) Self {
        return .{
            .arena = arena,
            .free_head = null,
        };
    }

    /// Returns a `std.mem.Allocator` interface for this free list.
    pub fn allocator(self: *Self) std.mem.Allocator {
        return .{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc_fn,
                .resize = resize_fn,
                .remap = remap_fn,
                .free = free_fn,
            },
        };
    }

    fn alloc_fn(ctx: *anyopaque, len: usize, ptr_align: std.mem.Alignment, _: usize) ?[*]u8 {
        const self: *Self = @ptrCast(@alignCast(ctx));
        return self.alloc_internal(len, ptr_align);
    }

    fn alloc_internal(self: *Self, len: usize, ptr_align: std.mem.Alignment) ?[*]u8 {
        // Ensure minimum alignment for free list node storage
        const alignment = @max(ptr_align.toByteUnits(), min_alignment);
        // Ensure minimum size for free list node storage
        const alloc_size = @max(len, min_alloc_size);

        // Search the free list for a suitable block
        var prev: ?*FreeNode = null;
        var current = self.free_head;

        while (current) |node| {
            const node_addr = @intFromPtr(node);
            const aligned_addr = std.mem.alignForward(usize, node_addr, alignment);
            const padding = aligned_addr - node_addr;

            // Check if this block is large enough
            if (node.size >= alloc_size + padding) {
                // Remove from free list
                if (prev) |p| {
                    p.next = node.next;
                } else {
                    self.free_head = node.next;
                }

                // Return the aligned pointer
                return @ptrFromInt(aligned_addr);
            }

            prev = node;
            current = node.next;
        }

        // No suitable free block found, allocate from arena
        const slice = self.arena.push_aligned(alloc_size, alignment) catch return null;
        return slice.ptr;
    }

    fn resize_fn(_: *anyopaque, _: []u8, _: std.mem.Alignment, _: usize, _: usize) bool {
        // FreeList doesn't support resizing individual allocations
        return false;
    }

    fn remap_fn(_: *anyopaque, _: []u8, _: std.mem.Alignment, _: usize, _: usize) ?[*]u8 {
        // FreeList doesn't support remapping individual allocations
        return null;
    }

    fn free_fn(ctx: *anyopaque, buf: []u8, _: std.mem.Alignment, _: usize) void {
        const self: *Self = @ptrCast(@alignCast(ctx));
        self.free_internal(buf);
    }

    fn free_internal(self: *Self, buf: []u8) void {
        if (buf.len == 0) return;

        // The actual allocation size was at least min_alloc_size
        const size = @max(buf.len, min_alloc_size);

        // Store a free node in the freed memory
        const node: *FreeNode = @ptrCast(@alignCast(buf.ptr));
        node.* = .{
            .next = self.free_head,
            .size = size,
        };
        self.free_head = node;
    }

    /// Clear the free list (does not affect the underlying arena).
    pub fn clear(self: *Self) void {
        self.free_head = null;
    }
};

/// Number of scratch arenas per thread.
/// Two is sufficient for alternating between persistent and scratch allocations.
const scratch_arena_count = 2;

/// Thread-local scratch arenas for temporary allocations.
threadlocal var scratch_arenas: [scratch_arena_count]?Arena = .{null} ** scratch_arena_count;

/// Get a thread-local scratch arena for temporary allocations.
///
/// Pass any arenas being used for persistent allocations as `conflicts`
/// to ensure the returned scratch arena is different, avoiding the case
/// where scratch allocations are accidentally freed with persistent ones.
///
/// Example:
/// ```
/// fn processData(arena: *Arena) !void {
///     var scratch = getScratch(&.{arena});
///     defer scratch.release();
///     // Use scratch.arena for temporary work...
/// }
/// ```
pub fn get_scratch(conflicts: []const *const Arena) Arena.Temp {
    // Initialize scratch arenas lazily
    for (&scratch_arenas) |*maybe_arena| {
        if (maybe_arena.* == null) {
            maybe_arena.* = Arena.init(.{}) catch @panic("Failed to initialize scratch arena");
        }
    }

    // Find a scratch arena that doesn't conflict
    for (&scratch_arenas) |*maybe_arena| {
        const arena = &(maybe_arena.*.?);
        var is_conflict = false;
        for (conflicts) |conflict| {
            if (@intFromPtr(arena) == @intFromPtr(conflict)) {
                is_conflict = true;
                break;
            }
        }
        if (!is_conflict) {
            return arena.temp();
        }
    }

    // This should never happen if scratch_arena_count >= 2
    // and conflicts only contains arenas from the call stack
    @panic("All scratch arenas are in conflict - this indicates a bug");
}

/// Release all thread-local scratch arenas.
/// Call this before thread termination to clean up resources.
pub fn deinit_scratch_arenas() void {
    for (&scratch_arenas) |*maybe_arena| {
        if (maybe_arena.*) |*arena| {
            arena.deinit();
            maybe_arena.* = null;
        }
    }
}

// ============================================================================
// Tests
// ============================================================================

test "Arena: basic allocation" {
    var arena = try Arena.init(.{ .reserve_size = 1024 * 1024 });
    defer arena.deinit();

    const slice1 = try arena.push(100);
    try std.testing.expectEqual(@as(usize, 100), slice1.len);

    const slice2 = try arena.push(200);
    try std.testing.expectEqual(@as(usize, 200), slice2.len);

    // Slices should be contiguous
    try std.testing.expectEqual(slice1.ptr + 100, slice2.ptr);
}

test "Arena: typed allocation" {
    var arena = try Arena.init(.{ .reserve_size = 1024 * 1024 });
    defer arena.deinit();

    const Point = struct { x: i32, y: i32 };

    const point = try arena.create(Point);
    point.x = 10;
    point.y = 20;

    try std.testing.expectEqual(@as(i32, 10), point.x);
    try std.testing.expectEqual(@as(i32, 20), point.y);

    const points = try arena.alloc(Point, 10);
    try std.testing.expectEqual(@as(usize, 10), points.len);
}

test "Arena: zeroed allocation" {
    var arena = try Arena.init(.{ .reserve_size = 1024 * 1024 });
    defer arena.deinit();

    const slice = try arena.push_zero(100);
    for (slice) |byte| {
        try std.testing.expectEqual(@as(u8, 0), byte);
    }
}

test "Arena: clear and reuse" {
    var arena = try Arena.init(.{ .reserve_size = 1024 * 1024 });
    defer arena.deinit();

    _ = try arena.push(1000);
    try std.testing.expectEqual(@as(usize, 1000), arena.get_pos());

    arena.clear();
    try std.testing.expectEqual(@as(usize, 0), arena.get_pos());

    // Can allocate again after clear
    _ = try arena.push(500);
    try std.testing.expectEqual(@as(usize, 500), arena.get_pos());
}

test "Arena: temp scope" {
    var arena = try Arena.init(.{ .reserve_size = 1024 * 1024 });
    defer arena.deinit();

    _ = try arena.push(100);
    const pos_before = arena.get_pos();

    {
        const temp_scope = arena.temp();
        defer temp_scope.release();

        _ = try arena.push(500);
        try std.testing.expectEqual(pos_before + 500, arena.get_pos());
    }

    // Position should be restored after temp scope
    try std.testing.expectEqual(pos_before, arena.get_pos());
}

test "Arena: std.mem.Allocator interface" {
    var arena = try Arena.init(.{ .reserve_size = 1024 * 1024 });
    defer arena.deinit();

    const ally = arena.allocator();

    const slice = try ally.alloc(u8, 100);
    try std.testing.expectEqual(@as(usize, 100), slice.len);

    // Free is a no-op but shouldn't crash
    ally.free(slice);
}

test "scratch arenas: basic usage" {
    defer deinit_scratch_arenas();

    const scratch = get_scratch(&.{});
    defer scratch.release();

    _ = try scratch.arena.push(100);
}

test "scratch arenas: conflict avoidance" {
    defer deinit_scratch_arenas();

    var arena1 = try Arena.init(.{ .reserve_size = 1024 * 1024 });
    defer arena1.deinit();

    // Get first scratch arena
    const scratch1 = get_scratch(&.{});

    // Get second scratch with first as conflict
    const scratch2 = get_scratch(&.{scratch1.arena});

    // They should be different arenas
    try std.testing.expect(scratch1.arena != scratch2.arena);

    scratch2.release();
    scratch1.release();
}

test "FreeList: basic allocation and reuse" {
    var arena = try Arena.init(.{ .reserve_size = 1024 * 1024 });
    defer arena.deinit();

    var free_list = FreeList.init(&arena);
    const ally = free_list.allocator();

    // Allocate some memory
    const slice1 = try ally.alloc(u8, 100);
    try std.testing.expectEqual(@as(usize, 100), slice1.len);

    const pos_after_alloc = arena.get_pos();

    // Free it
    ally.free(slice1);

    // Allocate again - should reuse the freed block
    const slice2 = try ally.alloc(u8, 50);
    try std.testing.expectEqual(@as(usize, 50), slice2.len);

    // Arena position should not have changed (memory was reused)
    try std.testing.expectEqual(pos_after_alloc, arena.get_pos());
}

test "FreeList: minimum allocation size" {
    var arena = try Arena.init(.{ .reserve_size = 1024 * 1024 });
    defer arena.deinit();

    var free_list = FreeList.init(&arena);
    const ally = free_list.allocator();

    // Allocate less than min_alloc_size
    const slice = try ally.alloc(u8, 1);
    try std.testing.expectEqual(@as(usize, 1), slice.len);

    // Free and reallocate
    ally.free(slice);

    const slice2 = try ally.alloc(u8, FreeList.min_alloc_size);
    try std.testing.expectEqual(@as(usize, FreeList.min_alloc_size), slice2.len);
}

test "FreeList: multiple allocations and frees" {
    var arena = try Arena.init(.{ .reserve_size = 1024 * 1024 });
    defer arena.deinit();

    var free_list = FreeList.init(&arena);
    const ally = free_list.allocator();

    // Allocate multiple blocks (use sizes >= min_alloc_size to be predictable)
    const a = try ally.alloc(u8, FreeList.min_alloc_size);
    const b = try ally.alloc(u8, FreeList.min_alloc_size * 2);
    const c = try ally.alloc(u8, FreeList.min_alloc_size * 3);

    const pos_after_allocs = arena.get_pos();

    // Free them in reverse order (LIFO - so smallest ends up at head)
    ally.free(c);
    ally.free(b);
    ally.free(a);

    // Reallocate with same sizes - should reuse freed blocks in order
    _ = try ally.alloc(u8, FreeList.min_alloc_size);
    _ = try ally.alloc(u8, FreeList.min_alloc_size * 2);
    _ = try ally.alloc(u8, FreeList.min_alloc_size * 3);

    // Arena should not have grown
    try std.testing.expectEqual(pos_after_allocs, arena.get_pos());
}

test "FreeList: typed allocations" {
    var arena = try Arena.init(.{ .reserve_size = 1024 * 1024 });
    defer arena.deinit();

    var free_list = FreeList.init(&arena);
    const ally = free_list.allocator();

    const Point = struct { x: i32, y: i32, z: i32 };

    const points = try ally.alloc(Point, 10);
    try std.testing.expectEqual(@as(usize, 10), points.len);

    points[0] = .{ .x = 1, .y = 2, .z = 3 };
    try std.testing.expectEqual(@as(i32, 1), points[0].x);

    ally.free(points);
}
