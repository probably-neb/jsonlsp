//! JSON Schema Subsystem
//!
//! Implements the validation layer of JSONLS
//! Implements multiple core concepts:
//! - Parsing and validation of JSON Schemas
//! - Validation of JSON according to it's respective schema
//! - Asynchronous fetching of schemas defined by URI from the interwebs
const std = @import("std");
const Arena = std.heap.ArenaAllocator;

const str8 = []const u8;

pub const Schema = struct {
    root: *const Check,
    arena: Arena,

    pub const Check = union(enum) {
        true: void,
        false: void,
    };

    pub fn is_valid(schema: *const Schema, input: str8) bool {
        _ = input;
        return switch (schema.root.*) {
            .true => true,
            .false => false,
        };
    }
};

pub fn parse(schema: str8) !Schema {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const arena = arena_state.allocator();
    _ = schema;
    const root = try arena.create(Schema.Check);
    root.* = .false;
    return Schema{
        .root = root,
        .arena = arena_state,
    };
}
