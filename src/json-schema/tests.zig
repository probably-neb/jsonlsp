const std = @import("std");
const json_schema = @import("json-schema.zig");

const parse = json_schema.parse;
const parse_with_revision = json_schema.parse_with_revision;

test "boolean schema - true schema accepts everything" {
    const schema_str = "true";
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // True schema should accept any valid JSON
    try std.testing.expectEqual(schema.is_valid("42"), true);
    try std.testing.expectEqual(schema.is_valid("\"hello\""), true);
    try std.testing.expectEqual(schema.is_valid("null"), true);
    try std.testing.expectEqual(schema.is_valid("[]"), true);
    try std.testing.expectEqual(schema.is_valid("{}"), true);
    try std.testing.expectEqual(schema.is_valid("true"), true);
    try std.testing.expectEqual(schema.is_valid("false"), true);
}

test "boolean schema - false schema rejects everything" {
    const schema_str = "false";
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // False schema should reject any JSON
    try std.testing.expectEqual(schema.is_valid("42"), false);
    try std.testing.expectEqual(schema.is_valid("\"hello\""), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
    try std.testing.expectEqual(schema.is_valid("{}"), false);
    try std.testing.expectEqual(schema.is_valid("true"), false);
    try std.testing.expectEqual(schema.is_valid("false"), false);
}

test "empty object schema - accepts everything" {
    const schema_str = "{}";
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Empty object schema should accept any valid JSON
    try std.testing.expectEqual(schema.is_valid("42"), true);
    try std.testing.expectEqual(schema.is_valid("\"test\""), true);
    try std.testing.expectEqual(schema.is_valid("null"), true);
    try std.testing.expectEqual(schema.is_valid("[]"), true);
    try std.testing.expectEqual(schema.is_valid("{}"), true);
}

test "type constraint - string" {
    const schema_str =
        \\{
        \\  "type": "string"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expectEqual(schema.is_valid("\"hello\""), true);
    try std.testing.expectEqual(schema.is_valid("\"\""), true);
    try std.testing.expectEqual(schema.is_valid("\"123\""), true);

    // Should reject non-strings
    try std.testing.expectEqual(schema.is_valid("123"), false);
    try std.testing.expectEqual(schema.is_valid("true"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
    try std.testing.expectEqual(schema.is_valid("{}"), false);
}

test "type constraint - number" {
    const schema_str =
        \\{
        \\  "type": "number"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Should accept numbers
    try std.testing.expectEqual(schema.is_valid("42"), true);
    try std.testing.expectEqual(schema.is_valid("3.14"), true);
    try std.testing.expectEqual(schema.is_valid("-10"), true);
    try std.testing.expectEqual(schema.is_valid("0"), true);
    try std.testing.expectEqual(schema.is_valid("1.5e10"), true);

    // Should reject non-numbers
    try std.testing.expectEqual(schema.is_valid("\"42\""), false);
    try std.testing.expectEqual(schema.is_valid("true"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
    try std.testing.expectEqual(schema.is_valid("{}"), false);
}

test "type constraint - integer" {
    const schema_str =
        \\{
        \\  "type": "integer"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Should accept integers
    try std.testing.expectEqual(schema.is_valid("42"), true);
    try std.testing.expectEqual(schema.is_valid("-10"), true);
    try std.testing.expectEqual(schema.is_valid("0"), true);

    // Should reject non-integers
    try std.testing.expectEqual(schema.is_valid("3.14"), false);
    try std.testing.expectEqual(schema.is_valid("\"42\""), false);
    try std.testing.expectEqual(schema.is_valid("true"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
}

test "type constraint - boolean" {
    const schema_str =
        \\{
        \\  "type": "boolean"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Should accept booleans
    try std.testing.expectEqual(schema.is_valid("true"), true);
    try std.testing.expectEqual(schema.is_valid("false"), true);

    // Should reject non-booleans
    try std.testing.expectEqual(schema.is_valid("\"true\""), false);
    try std.testing.expectEqual(schema.is_valid("1"), false);
    try std.testing.expectEqual(schema.is_valid("0"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
}

test "type constraint - null" {
    const schema_str =
        \\{
        \\  "type": "null"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Should accept null
    try std.testing.expectEqual(schema.is_valid("null"), true);

    // Should reject non-null
    try std.testing.expectEqual(schema.is_valid("\"null\""), false);
    try std.testing.expectEqual(schema.is_valid("0"), false);
    try std.testing.expectEqual(schema.is_valid("false"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
    try std.testing.expectEqual(schema.is_valid("{}"), false);
}

test "type constraint - array" {
    const schema_str =
        \\{
        \\  "type": "array"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Should accept arrays
    try std.testing.expectEqual(schema.is_valid("[]"), true);
    try std.testing.expectEqual(schema.is_valid("[1, 2, 3]"), true);
    try std.testing.expectEqual(schema.is_valid("[\"a\", \"b\"]"), true);
    try std.testing.expectEqual(schema.is_valid("[true, false, null]"), true);

    // Should reject non-arrays
    try std.testing.expectEqual(schema.is_valid("{}"), false);
    try std.testing.expectEqual(schema.is_valid("\"array\""), false);
    try std.testing.expectEqual(schema.is_valid("123"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
}

test "type constraint - object" {
    const schema_str =
        \\{
        \\  "type": "object"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Should accept objects
    try std.testing.expectEqual(schema.is_valid("{}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"key\": \"value\"}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"a\": 1, \"b\": 2}"), true);

    // Should reject non-objects
    try std.testing.expectEqual(schema.is_valid("[]"), false);
    try std.testing.expectEqual(schema.is_valid("\"object\""), false);
    try std.testing.expectEqual(schema.is_valid("123"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
}

test "string constraints - minLength and maxLength" {
    const schema_str =
        \\{
        \\  "type": "string",
        \\  "minLength": 2,
        \\  "maxLength": 5
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid lengths
    try std.testing.expectEqual(schema.is_valid("\"ab\""), true);
    try std.testing.expectEqual(schema.is_valid("\"abc\""), true);
    try std.testing.expectEqual(schema.is_valid("\"abcde\""), true);

    // Invalid lengths
    try std.testing.expectEqual(schema.is_valid("\"a\""), false);
    try std.testing.expectEqual(schema.is_valid("\"abcdef\""), false);
    try std.testing.expectEqual(schema.is_valid("\"\""), false);

    // Non-strings should fail
    try std.testing.expectEqual(schema.is_valid("123"), false);
}

test "string constraints - pattern" {
    const schema_str =
        \\{
        \\  "type": "string",
        \\  "pattern": "^[a-z]+$"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Matching pattern
    try std.testing.expectEqual(schema.is_valid("\"abc\""), true);
    try std.testing.expectEqual(schema.is_valid("\"hello\""), true);

    // Not matching pattern
    try std.testing.expectEqual(schema.is_valid("\"ABC\""), false);
    try std.testing.expectEqual(schema.is_valid("\"hello123\""), false);
    try std.testing.expectEqual(schema.is_valid("\"hello world\""), false);
}

test "number constraints - minimum and maximum" {
    const schema_str =
        \\{
        \\  "type": "number",
        \\  "minimum": 0,
        \\  "maximum": 100
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid range
    try std.testing.expectEqual(schema.is_valid("0"), true);
    try std.testing.expectEqual(schema.is_valid("50"), true);
    try std.testing.expectEqual(schema.is_valid("100"), true);
    try std.testing.expectEqual(schema.is_valid("99.99"), true);

    // Outside range
    try std.testing.expectEqual(schema.is_valid("-1"), false);
    try std.testing.expectEqual(schema.is_valid("101"), false);
    try std.testing.expectEqual(schema.is_valid("1000"), false);
}

test "number constraints - exclusiveMinimum and exclusiveMaximum" {
    const schema_str =
        \\{
        \\  "type": "number",
        \\  "exclusiveMinimum": 0,
        \\  "exclusiveMaximum": 100
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid range (exclusive)
    try std.testing.expectEqual(schema.is_valid("0.1"), true);
    try std.testing.expectEqual(schema.is_valid("50"), true);
    try std.testing.expectEqual(schema.is_valid("99.99"), true);

    // Invalid (at boundaries)
    try std.testing.expectEqual(schema.is_valid("0"), false);
    try std.testing.expectEqual(schema.is_valid("100"), false);
    try std.testing.expectEqual(schema.is_valid("-1"), false);
    try std.testing.expectEqual(schema.is_valid("101"), false);
}

test "array constraints - minItems and maxItems" {
    const schema_str =
        \\{
        \\  "type": "array",
        \\  "minItems": 1,
        \\  "maxItems": 3
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid counts
    try std.testing.expectEqual(schema.is_valid("[1]"), true);
    try std.testing.expectEqual(schema.is_valid("[1, 2]"), true);
    try std.testing.expectEqual(schema.is_valid("[1, 2, 3]"), true);

    // Invalid counts
    try std.testing.expectEqual(schema.is_valid("[]"), false);
    try std.testing.expectEqual(schema.is_valid("[1, 2, 3, 4]"), false);
}

test "array constraints - uniqueItems" {
    const schema_str =
        \\{
        \\  "type": "array",
        \\  "uniqueItems": true
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Unique items
    try std.testing.expectEqual(schema.is_valid("[1, 2, 3]"), true);
    try std.testing.expectEqual(schema.is_valid("[\"a\", \"b\", \"c\"]"), true);
    try std.testing.expectEqual(schema.is_valid("[]"), true);

    // Duplicate items
    try std.testing.expectEqual(schema.is_valid("[1, 2, 1]"), false);
    try std.testing.expectEqual(schema.is_valid("[\"a\", \"a\"]"), false);
}

test "array constraints - uniqueItems treats numerically equivalent values as duplicates" {
    const schema_str =
        \\{
        \\  "uniqueItems": true
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("[1, 1.5]"));
    try std.testing.expect(!schema.is_valid("[1, 1.0]"));
}

test "array constraints - uniqueItems treats object key order as duplicates" {
    const schema_str =
        \\{
        \\  "uniqueItems": true
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(!schema.is_valid(
        \\[
        \\  {"a": 1, "b": 2},
        \\  {"b": 2, "a": 1}
        \\]
    ));
}

test "array constraints - uniqueItems composes with items" {
    const schema_str =
        \\{
        \\  "type": "array",
        \\  "items": { "type": "integer" },
        \\  "uniqueItems": true
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expectEqual(schema.is_valid("[1, 2, 3]"), true);
    try std.testing.expectEqual(schema.is_valid("[1, 2, 1]"), false);
    try std.testing.expectEqual(schema.is_valid("[1, \"2\", 3]"), false);
}

test "array constraints - uniqueItems composes with minItems" {
    const schema_str =
        \\{
        \\  "type": "array",
        \\  "minItems": 2,
        \\  "uniqueItems": true
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expectEqual(schema.is_valid("[1, 2]"), true);
    try std.testing.expectEqual(schema.is_valid("[1]"), false);
    try std.testing.expectEqual(schema.is_valid("[1, 1]"), false);
}

test "object constraints - required properties" {
    const schema_str =
        \\{
        \\  "type": "object",
        \\  "properties": {
        \\    "name": { "type": "string" },
        \\    "age": { "type": "number" }
        \\  },
        \\  "required": ["name"]
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Has required property
    try std.testing.expectEqual(schema.is_valid("{\"name\": \"John\"}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"name\": \"John\", \"age\": 30}"), true);

    // Missing required property
    try std.testing.expectEqual(schema.is_valid("{}"), false);
    try std.testing.expectEqual(schema.is_valid("{\"age\": 30}"), false);
}

test "object constraints - additionalProperties" {
    const schema_str =
        \\{
        \\  "type": "object",
        \\  "properties": {
        \\    "name": { "type": "string" }
        \\  },
        \\  "additionalProperties": false
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Only defined properties
    try std.testing.expectEqual(schema.is_valid("{\"name\": \"John\"}"), true);
    try std.testing.expectEqual(schema.is_valid("{}"), true);

    // Additional properties present
    try std.testing.expectEqual(schema.is_valid("{\"name\": \"John\", \"age\": 30}"), false);
    try std.testing.expectEqual(schema.is_valid("{\"extra\": \"field\"}"), false);
}

test "object constraints - properties do not require presence or restrict extras by default" {
    const schema_str =
        \\{
        \\  "properties": {
        \\    "name": { "type": "string" },
        \\    "forbidden": false
        \\  }
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expectEqual(schema.is_valid("{}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"name\": \"John\"}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"extra\": 42}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"forbidden\": 1}"), false);
}

test "object constraints - patternProperties" {
    const schema_str =
        \\{
        \\  "patternProperties": {
        \\    "^[a-z]+$": { "type": "integer" }
        \\  }
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expectEqual(schema.is_valid("{\"foo\": 1, \"bar\": 2}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"CamelCase\": true, \"alphanumeric123\": \"ok\"}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"foo\": \"nope\"}"), false);
}

test "object constraints - overlapping patternProperties all apply" {
    const schema_str =
        \\{
        \\  "patternProperties": {
        \\    "^f": { "type": "string" },
        \\    "o$": { "minLength": 3 }
        \\  }
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expectEqual(schema.is_valid("{\"foo\": \"long\"}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"boo\": 1}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"foo\": \"xx\"}"), false);
    try std.testing.expectEqual(schema.is_valid("{\"boo\": \"xx\"}"), false);
}

test "object constraints - properties and patternProperties both apply before additionalProperties" {
    const schema_str =
        \\{
        \\  "properties": {
        \\    "foo": { "type": "string" }
        \\  },
        \\  "patternProperties": {
        \\    "^f": { "minLength": 3 }
        \\  },
        \\  "additionalProperties": { "type": "boolean" }
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expectEqual(schema.is_valid("{\"foo\": \"long\", \"extra\": true}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"foo\": \"xx\"}"), false);
    try std.testing.expectEqual(schema.is_valid("{\"foo\": 3}"), false);
    try std.testing.expectEqual(schema.is_valid("{\"fizz\": 1}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"extra\": \"nope\"}"), false);
}

test "enum constraint" {
    const schema_str =
        \\{
        \\  "enum": ["red", "green", "blue", 42, null]
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid enum values
    try std.testing.expectEqual(schema.is_valid("\"red\""), true);
    try std.testing.expectEqual(schema.is_valid("\"green\""), true);
    try std.testing.expectEqual(schema.is_valid("\"blue\""), true);
    try std.testing.expectEqual(schema.is_valid("42"), true);
    try std.testing.expectEqual(schema.is_valid("null"), true);

    // Invalid enum values
    try std.testing.expectEqual(schema.is_valid("\"yellow\""), false);
    try std.testing.expectEqual(schema.is_valid("43"), false);
    try std.testing.expectEqual(schema.is_valid("false"), false);
}

test "const constraint" {
    const schema_str =
        \\{
        \\  "const": "fixed-value"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Exact match
    try std.testing.expectEqual(schema.is_valid("\"fixed-value\""), true);

    // Different values
    try std.testing.expectEqual(schema.is_valid("\"other-value\""), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("42"), false);
}

test "const constraint treats integer and float representations as equal" {
    const schema_str =
        \\{
        \\  "const": 5
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("5"));
    try std.testing.expect(schema.is_valid("5.0"));
    try std.testing.expect(!schema.is_valid("5.5"));
}

test "const constraint treats object key order as equal" {
    const schema_str =
        \\{
        \\  "const": {
        \\    "name": "John Doe",
        \\    "age": 30
        \\  }
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid(
        \\{
        \\  "age": 30,
        \\  "name": "John Doe"
        \\}
    ));
    try std.testing.expect(!schema.is_valid(
        \\{
        \\  "age": 31,
        \\  "name": "John Doe"
        \\}
    ));
}

test "const constraint composes with conflicting type" {
    const schema_str =
        \\{
        \\  "const": 42,
        \\  "type": "string"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expectEqual(schema.is_valid("42"), false);
    try std.testing.expectEqual(schema.is_valid("\"42\""), false);
}

test "const constraint composes with other validators" {
    const schema_str =
        \\{
        \\  "const": "abc",
        \\  "minLength": 5
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expectEqual(schema.is_valid("\"abc\""), false);
    try std.testing.expectEqual(schema.is_valid("\"abcdef\""), false);
}

test "allOf combinator" {
    const schema_str =
        \\{
        \\  "allOf": [
        \\    { "type": "number" },
        \\    { "minimum": 0 },
        \\    { "maximum": 100 }
        \\  ]
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Satisfies all constraints
    try std.testing.expectEqual(schema.is_valid("50"), true);
    try std.testing.expectEqual(schema.is_valid("0"), true);
    try std.testing.expectEqual(schema.is_valid("100"), true);

    // Fails one or more constraints
    try std.testing.expectEqual(schema.is_valid("-1"), false);
    try std.testing.expectEqual(schema.is_valid("101"), false);
    try std.testing.expectEqual(schema.is_valid("\"50\""), false);
}

test "anyOf combinator" {
    const schema_str =
        \\{
        \\  "anyOf": [
        \\    { "type": "string" },
        \\    { "type": "number" }
        \\  ]
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Satisfies at least one
    try std.testing.expectEqual(schema.is_valid("\"hello\""), true);
    try std.testing.expectEqual(schema.is_valid("42"), true);

    // Satisfies none
    try std.testing.expectEqual(schema.is_valid("true"), false);
    try std.testing.expectEqual(schema.is_valid("null"), false);
    try std.testing.expectEqual(schema.is_valid("[]"), false);
}

test "oneOf combinator" {
    const schema_str =
        \\{
        \\  "oneOf": [
        \\    { "type": "number", "multipleOf": 5 },
        \\    { "type": "number", "multipleOf": 3 },
        \\    { "type": "number", "multipleOf": 6 },
        \\    { "type": "number", "multipleOf": 3 }
        \\  ]
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Satisfies exactly one
    try std.testing.expectEqual(schema.is_valid("10"), true); // multiple of 5 only
    try std.testing.expectEqual(schema.is_valid("9"), false); // multiple of 3 twice

    // Satisfies both (invalid for oneOf)
    try std.testing.expectEqual(schema.is_valid("15"), false); // multiple of both 3 and 5
    try std.testing.expectEqual(schema.is_valid("30"), false); // multiple of both 3 and 5

    // Satisfies none
    try std.testing.expectEqual(schema.is_valid("7"), false);
    try std.testing.expectEqual(schema.is_valid("\"hello\""), false);
}

test "not combinator" {
    const schema_str =
        \\{
        \\  "not": {
        \\    "type": "string"
        \\  }
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Not a string (valid)
    try std.testing.expectEqual(schema.is_valid("42"), true);
    try std.testing.expectEqual(schema.is_valid("true"), true);
    try std.testing.expectEqual(schema.is_valid("null"), true);
    try std.testing.expectEqual(schema.is_valid("[]"), true);

    // Is a string (invalid)
    try std.testing.expectEqual(schema.is_valid("\"hello\""), false);
    try std.testing.expectEqual(schema.is_valid("\"\""), false);
}

test "nested object validation" {
    const schema_str =
        \\{
        \\  "type": "object",
        \\  "properties": {
        \\    "user": {
        \\      "type": "object",
        \\      "properties": {
        \\        "name": { "type": "string" },
        \\        "email": { "type": "string", "format": "email" }
        \\      },
        \\      "required": ["name", "email"]
        \\    },
        \\    "age": { "type": "integer", "minimum": 0 }
        \\  },
        \\  "required": ["user"]
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid nested object
    const valid_input =
        \\{
        \\  "user": {
        \\    "name": "John Doe",
        \\    "email": "john@example.com"
        \\  },
        \\  "age": 30
        \\}
    ;
    try std.testing.expectEqual(schema.is_valid(valid_input), true);

    // Missing required nested property
    const invalid_input =
        \\{
        \\  "user": {
        \\    "name": "John Doe"
        \\  }
        \\}
    ;
    try std.testing.expectEqual(schema.is_valid(invalid_input), false);
}

test "array items validation" {
    const schema_str =
        \\{
        \\  "type": "array",
        \\  "items": {
        \\    "type": "number",
        \\    "minimum": 0
        \\  }
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // All items valid
    try std.testing.expectEqual(schema.is_valid("[1, 2, 3]"), true);
    try std.testing.expectEqual(schema.is_valid("[0, 100, 50.5]"), true);
    try std.testing.expectEqual(schema.is_valid("[]"), true);

    // Some items invalid
    try std.testing.expectEqual(schema.is_valid("[-1, 2, 3]"), false);
    try std.testing.expectEqual(schema.is_valid("[\"1\", 2, 3]"), false);
}

test "array constraints - prefixItems does not require the full tuple length" {
    const schema_str =
        \\{
        \\  "type": "array",
        \\  "prefixItems": [
        \\    { "type": "boolean" },
        \\    { "type": "number" }
        \\  ]
        \\}
    ;
    var schema = try parse_with_revision(schema_str, .draft2020_12);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("[]"));
    try std.testing.expect(schema.is_valid("[true]"));
    try std.testing.expect(schema.is_valid("[true, 3]"));
    try std.testing.expect(!schema.is_valid("[1]"));
}

test "array constraints - additionalItems false rejects items beyond legacy tuple" {
    const schema_str =
        \\{
        \\  "items": [
        \\    { "type": "boolean" },
        \\    { "type": "number" }
        \\  ],
        \\  "additionalItems": false
        \\}
    ;
    var schema = try parse_with_revision(schema_str, .draft4);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("[false, 35]"));
    try std.testing.expect(!schema.is_valid("[false, 35, \"foo\"]"));
}

test "array constraints - additionalItems is ignored without tuple items" {
    const schema_str =
        \\{
        \\  "additionalItems": false
        \\}
    ;
    var schema = try parse_with_revision(schema_str, .draft2019_09);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("[]"));
    try std.testing.expect(schema.is_valid("[1, 2, 3]"));
    try std.testing.expect(schema.is_valid("\"Hello World\""));
}

test "array constraints - 2020-12 ignores legacy additionalItems with prefixItems" {
    const schema_str =
        \\{
        \\  "prefixItems": [
        \\    { "type": "string" }
        \\  ],
        \\  "additionalItems": false
        \\}
    ;
    var schema = try parse_with_revision(schema_str, .draft2020_12);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("[\"x\"]"));
    try std.testing.expect(schema.is_valid("[\"x\", 1]"));
}

test "conditional applicators - only the selected branch applies" {
    const schema_str =
        \\{
        \\  "if": {
        \\    "required": ["kind"],
        \\    "properties": {
        \\      "kind": { "const": "card" }
        \\    }
        \\  },
        \\  "then": {
        \\    "required": ["billing_address"]
        \\  },
        \\  "else": {
        \\    "required": ["email"]
        \\  }
        \\}
    ;
    var schema = try parse_with_revision(schema_str, .draft2020_12);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid(
        \\{"kind": "card", "billing_address": "123 Main St"}
    ));
    try std.testing.expect(!schema.is_valid(
        \\{"kind": "card", "email": "person@example.com"}
    ));
    try std.testing.expect(schema.is_valid(
        \\{"email": "person@example.com"}
    ));
    try std.testing.expect(!schema.is_valid(
        \\{"kind": "cash"}
    ));
}

test "multipleOf constraint" {
    const schema_str =
        \\{
        \\  "type": "number",
        \\  "multipleOf": 0.5
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid multiples
    try std.testing.expectEqual(schema.is_valid("0"), true);
    try std.testing.expectEqual(schema.is_valid("0.5"), true);
    try std.testing.expectEqual(schema.is_valid("1"), true);
    try std.testing.expectEqual(schema.is_valid("2.5"), true);
    try std.testing.expectEqual(schema.is_valid("-1.5"), true);

    // Not multiples
    try std.testing.expectEqual(schema.is_valid("0.3"), false);
    try std.testing.expectEqual(schema.is_valid("1.7"), false);
}

test "object constraints - minProperties and maxProperties" {
    const schema_str =
        \\{
        \\  "type": "object",
        \\  "minProperties": 1,
        \\  "maxProperties": 3
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    // Valid counts
    try std.testing.expectEqual(schema.is_valid("{\"a\": 1}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"a\": 1, \"b\": 2}"), true);
    try std.testing.expectEqual(schema.is_valid("{\"a\": 1, \"b\": 2, \"c\": 3}"), true);

    // Too few properties
    try std.testing.expectEqual(schema.is_valid("{}"), false);

    // Too many properties
    try std.testing.expectEqual(schema.is_valid("{\"a\": 1, \"b\": 2, \"c\": 3, \"d\": 4}"), false);

    // Non-objects are not affected
    try std.testing.expectEqual(schema.is_valid("[]"), false); // fails type check
    try std.testing.expectEqual(schema.is_valid("\"string\""), false); // fails type check
}

test "$ref with definitions" {
    const schema_str =
        \\{
        \\  "definitions": {
        \\    "positiveInteger": {
        \\      "type": "integer",
        \\      "minimum": 0
        \\    }
        \\  },
        \\  "type": "object",
        \\  "properties": {
        \\    "count": { "$ref": "#/definitions/positiveInteger" }
        \\  }
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("{\"count\": 5}"));
    try std.testing.expect(schema.is_valid("{\"count\": 0}"));
    try std.testing.expect(!schema.is_valid("{\"count\": -1}"));
    try std.testing.expect(!schema.is_valid("{\"count\": \"five\"}"));
}

test "$ref with $defs (2019-09+ style)" {
    const schema_str =
        \\{
        \\  "$defs": {
        \\    "stringArray": {
        \\      "type": "array",
        \\      "items": { "type": "string" }
        \\    }
        \\  },
        \\  "$ref": "#/$defs/stringArray"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("[\"a\", \"b\", \"c\"]"));
    try std.testing.expect(schema.is_valid("[]"));
    try std.testing.expect(!schema.is_valid("[\"a\", 1]"));
    try std.testing.expect(!schema.is_valid("\"not an array\""));
}

test "$ref nested refs" {
    const schema_str =
        \\{
        \\  "definitions": {
        \\    "a": { "type": "integer" },
        \\    "b": { "$ref": "#/definitions/a" },
        \\    "c": { "$ref": "#/definitions/b" }
        \\  },
        \\  "$ref": "#/definitions/c"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("5"));
    try std.testing.expect(schema.is_valid("-10"));
    try std.testing.expect(!schema.is_valid("\"string\""));
    try std.testing.expect(!schema.is_valid("1.5"));
}

test "$ref recursive schema" {
    const schema_str =
        \\{
        \\  "definitions": {
        \\    "node": {
        \\      "type": "object",
        \\      "properties": {
        \\        "value": { "type": "integer" },
        \\        "child": { "$ref": "#/definitions/node" }
        \\      }
        \\    }
        \\  },
        \\  "$ref": "#/definitions/node"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("{\"value\": 1}"));
    try std.testing.expect(schema.is_valid("{\"value\": 1, \"child\": {\"value\": 2}}"));
    try std.testing.expect(schema.is_valid("{\"value\": 1, \"child\": {\"value\": 2, \"child\": {\"value\": 3}}}"));
    try std.testing.expect(!schema.is_valid("{\"value\": \"not an int\"}"));
    try std.testing.expect(!schema.is_valid("{\"value\": 1, \"child\": {\"value\": \"bad\"}}"));
}

test "$ref pointer escape segment slash (~1)" {
    const schema_str =
        \\{
        \\  "$defs": {
        \\    "slash/field": { "type": "integer" }
        \\  },
        \\  "$ref": "#/$defs/slash~1field"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("1"));
    try std.testing.expect(!schema.is_valid("\"1\""));
}

test "$ref pointer escape segment tilde (~0)" {
    const schema_str =
        \\{
        \\  "$defs": {
        \\    "tilde~field": { "type": "string" }
        \\  },
        \\  "$ref": "#/$defs/tilde~0field"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("\"ok\""));
    try std.testing.expect(!schema.is_valid("1"));
}

test "$ref pointer escape segment percent (%25)" {
    const schema_str =
        \\{
        \\  "$defs": {
        \\    "percent%field": { "type": "boolean" }
        \\  },
        \\  "$ref": "#/$defs/percent%25field"
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("true"));
    try std.testing.expect(!schema.is_valid("\"true\""));
}

test "$ref root pointer recursive object does not crash" {
    const schema_str =
        \\{
        \\  "properties": {
        \\    "foo": { "$ref": "#" }
        \\  },
        \\  "additionalProperties": false
        \\}
    ;
    var schema = try parse_with_revision(schema_str, .draft4);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("{\"foo\": false}"));
    try std.testing.expect(schema.is_valid("{\"foo\": {\"foo\": false}}"));
    try std.testing.expect(!schema.is_valid("{\"bar\": false}"));
    try std.testing.expect(!schema.is_valid("{\"foo\": {\"bar\": false}}"));
}

test "dependentRequired - trigger present requires dependents (draft 2020-12)" {
    const schema_str =
        \\{
        \\  "dependentRequired": {
        \\    "credit_card": ["billing_address"]
        \\  }
        \\}
    ;
    var schema = try parse_with_revision(schema_str, .draft2020_12);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("{}"));
    try std.testing.expect(schema.is_valid("{\"billing_address\": \"123 Main St\"}"));
    try std.testing.expect(schema.is_valid("{\"credit_card\": 1234, \"billing_address\": \"123 Main St\"}"));
    try std.testing.expect(!schema.is_valid("{\"credit_card\": 1234}"));
}

test "dependentRequired - multiple dependencies (draft 2019-09)" {
    const schema_str =
        \\{
        \\  "dependentRequired": {
        \\    "name": ["surname", "given_name"]
        \\  }
        \\}
    ;
    var schema = try parse_with_revision(schema_str, .draft2019_09);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("{}"));
    try std.testing.expect(schema.is_valid("{\"surname\": \"Doe\"}"));
    try std.testing.expect(!schema.is_valid("{\"name\": \"X\", \"surname\": \"Doe\"}"));
    try std.testing.expect(schema.is_valid("{\"name\": \"X\", \"surname\": \"Doe\", \"given_name\": \"John\"}"));
}

test "allOf with duplicate empty subschemas does not hang" {
    const schema_str =
        \\{
        \\  "allOf": [
        \\    {},
        \\    {}
        \\  ]
        \\}
    ;
    var schema = try parse(schema_str);
    defer schema.arena.deinit();

    try std.testing.expect(schema.is_valid("1"));
    try std.testing.expect(schema.is_valid("\"text\""));
    try std.testing.expect(schema.is_valid("true"));
    try std.testing.expect(schema.is_valid("null"));
    try std.testing.expect(schema.is_valid("[]"));
    try std.testing.expect(schema.is_valid("{}"));
}
