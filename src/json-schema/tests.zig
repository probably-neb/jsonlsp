const std = @import("std");
const json_schema = @import("json-schema.zig");

const parse = json_schema.parse;
const parse_with_revision = json_schema.parse_with_revision;

const ValidationCase = struct {
    []const u8,
    bool,
};

fn expect_validation_cases(
    schema_str: []const u8,
    revision: ?json_schema.Revision,
    cases: []const ValidationCase,
) !void {
    var schema = if (revision) |resolved_revision|
        try parse_with_revision(schema_str, resolved_revision)
    else
        try parse(schema_str);
    defer schema.arena.deinit();

    for (cases, 0..) |validation_case, case_index| {
        const actual_valid = schema.is_valid(validation_case[0]);
        if (actual_valid != validation_case[1]) {
            std.debug.print(
                \\validation case {d} failed
                \\expected valid: {}
                \\actual valid: {}
                \\input JSON:
                \\{s}
                \\schema JSON:
                \\{s}
                \\
            , .{
                case_index,
                validation_case[1],
                actual_valid,
                validation_case[0],
                schema_str,
            });
            return error.TestUnexpectedResult;
        }
    }
}

test "boolean schema - true schema accepts everything" {
    try expect_validation_cases("true", null, &.{
        .{ "42", true },
        .{
            \\"hello"
            ,
            true,
        },
        .{ "null", true },
        .{ "[]", true },
        .{ "{}", true },
        .{ "true", true },
        .{ "false", true },
    });
}

test "boolean schema - false schema rejects everything" {
    try expect_validation_cases("false", null, &.{
        .{ "42", false },
        .{
            \\"hello"
            ,
            false,
        },
        .{ "null", false },
        .{ "[]", false },
        .{ "{}", false },
        .{ "true", false },
        .{ "false", false },
    });
}

test "empty object schema - accepts everything" {
    try expect_validation_cases("{}", null, &.{
        .{ "42", true },
        .{
            \\"test"
            ,
            true,
        },
        .{ "null", true },
        .{ "[]", true },
        .{ "{}", true },
    });
}

test "type constraint - string" {
    const schema_str =
        \\{
        \\  "type": "string"
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"hello"
            ,
            true,
        },
        .{
            \\""
            ,
            true,
        },
        .{
            \\"123"
            ,
            true,
        },
        .{ "123", false },
        .{ "true", false },
        .{ "null", false },
        .{ "[]", false },
        .{ "{}", false },
    });
}

test "type constraint - number" {
    const schema_str =
        \\{
        \\  "type": "number"
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "42", true },
        .{ "3.14", true },
        .{ "-10", true },
        .{ "0", true },
        .{ "1.5e10", true },
        .{
            \\"42"
            ,
            false,
        },
        .{ "true", false },
        .{ "null", false },
        .{ "[]", false },
        .{ "{}", false },
    });
}

test "type constraint - integer" {
    const schema_str =
        \\{
        \\  "type": "integer"
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "42", true },
        .{ "-10", true },
        .{ "0", true },
        .{ "3.14", false },
        .{
            \\"42"
            ,
            false,
        },
        .{ "true", false },
        .{ "null", false },
        .{ "[]", false },
    });
}

test "type constraint - boolean" {
    const schema_str =
        \\{
        \\  "type": "boolean"
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "true", true },
        .{ "false", true },
        .{
            \\"true"
            ,
            false,
        },
        .{ "1", false },
        .{ "0", false },
        .{ "null", false },
        .{ "[]", false },
    });
}

test "type constraint - null" {
    const schema_str =
        \\{
        \\  "type": "null"
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "null", true },
        .{
            \\"null"
            ,
            false,
        },
        .{ "0", false },
        .{ "false", false },
        .{ "[]", false },
        .{ "{}", false },
    });
}

test "type constraint - array" {
    const schema_str =
        \\{
        \\  "type": "array"
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "[]", true },
        .{ "[1, 2, 3]", true },
        .{
            \\["a", "b"]
            ,
            true,
        },
        .{ "[true, false, null]", true },
        .{ "{}", false },
        .{
            \\"array"
            ,
            false,
        },
        .{ "123", false },
        .{ "null", false },
    });
}

test "type constraint - object" {
    const schema_str =
        \\{
        \\  "type": "object"
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "{}", true },
        .{
            \\{"key": "value"}
            ,
            true,
        },
        .{
            \\{"a": 1, "b": 2}
            ,
            true,
        },
        .{ "[]", false },
        .{
            \\"object"
            ,
            false,
        },
        .{ "123", false },
        .{ "null", false },
    });
}

test "type constraint - array of types" {
    const schema_str =
        \\{
        \\  "type": ["boolean", "array"]
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "true", true },
        .{ "false", true },
        .{ "[]", true },
        .{ "[1, 2, 3]", true },
        .{ "1234", false },
        .{
            \\"foo"
            ,
            false,
        },
        .{ "null", false },
        .{ "{}", false },
    });
}

test "type constraint - siblings stay conjunctive with anyOf" {
    const schema_str =
        \\{
        \\  "type": ["string", "boolean"],
        \\  "anyOf": [
        \\    { "type": "string", "minLength": 3 },
        \\    { "type": "integer" }
        \\  ]
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"hello"
            ,
            true,
        },
        .{
            \\"hi"
            ,
            false,
        },
        .{ "true", false },
        .{ "42", false },
    });
}

test "string constraints - minLength and maxLength" {
    const schema_str =
        \\{
        \\  "type": "string",
        \\  "minLength": 2,
        \\  "maxLength": 5
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"ab"
            ,
            true,
        },
        .{
            \\"abc"
            ,
            true,
        },
        .{
            \\"abcde"
            ,
            true,
        },
        .{
            \\"a"
            ,
            false,
        },
        .{
            \\"abcdef"
            ,
            false,
        },
        .{
            \\""
            ,
            false,
        },
        .{ "123", false },
    });
}

test "string constraints - minLength counts Unicode code points and ignores non-strings" {
    const schema_str =
        \\{
        \\  "minLength": 3
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"foo"
            ,
            true,
        },
        .{
            \\"こんにちは"
            ,
            true,
        },
        .{
            \\"hi"
            ,
            false,
        },
        .{ "55", true },
    });
}

test "string constraints - maxLength counts Unicode code points and ignores non-strings" {
    const schema_str =
        \\{
        \\  "maxLength": 3
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"foo"
            ,
            true,
        },
        .{
            \\"hi"
            ,
            true,
        },
        .{
            \\"こんにちは"
            ,
            false,
        },
        .{ "55", true },
    });
}

test "string constraints - pattern" {
    const schema_str =
        \\{
        \\  "type": "string",
        \\  "pattern": "^[a-z]+$"
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"abc"
            ,
            true,
        },
        .{
            \\"hello"
            ,
            true,
        },
        .{
            \\"ABC"
            ,
            false,
        },
        .{
            \\"hello123"
            ,
            false,
        },
        .{
            \\"hello world"
            ,
            false,
        },
    });
}

test "string constraints - pattern is unanchored, case-sensitive, and ignores non-strings" {
    const schema_str =
        \\{
        \\  "pattern": "es"
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"expression"
            ,
            true,
        },
        .{
            \\"EXPRESSION"
            ,
            false,
        },
        .{
            \\"foo"
            ,
            false,
        },
        .{ "1234", true },
    });
}

test "number constraints - minimum and maximum" {
    const schema_str =
        \\{
        \\  "type": "number",
        \\  "minimum": 0,
        \\  "maximum": 100
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "0", true },
        .{ "50", true },
        .{ "100", true },
        .{ "99.99", true },
        .{ "-1", false },
        .{ "101", false },
        .{ "1000", false },
    });
}

test "number constraints - exclusiveMinimum and exclusiveMaximum" {
    const schema_str =
        \\{
        \\  "type": "number",
        \\  "exclusiveMinimum": 0,
        \\  "exclusiveMaximum": 100
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "0.1", true },
        .{ "50", true },
        .{ "99.99", true },
        .{ "0", false },
        .{ "100", false },
        .{ "-1", false },
        .{ "101", false },
    });
}

test "number constraints - minimum and maximum compare integer and float values consistently" {
    const schema_str =
        \\{
        \\  "minimum": 10,
        \\  "maximum": 10
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "10", true },
        .{ "10.0", true },
        .{ "9.9", false },
        .{ "10.1", false },
        .{
            \\"10"
            ,
            true,
        },
    });
}

test "number constraints - exclusive bounds reject equal integer and float values and ignore non-numbers" {
    const schema_str =
        \\{
        \\  "exclusiveMinimum": 10,
        \\  "exclusiveMaximum": 20
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "10", false },
        .{ "10.0", false },
        .{ "10.1", true },
        .{ "19.9", true },
        .{ "20", false },
        .{ "20.0", false },
        .{
            \\"15"
            ,
            true,
        },
    });
}

test "number constraints - lower bounds combine to the stricter constraint" {
    const inclusive_schema_str =
        \\{
        \\  "minimum": 5,
        \\  "exclusiveMinimum": 3
        \\}
    ;
    try expect_validation_cases(inclusive_schema_str, null, &.{
        .{ "4.9", false },
        .{ "5", true },
    });

    const exclusive_schema_str =
        \\{
        \\  "minimum": 3,
        \\  "exclusiveMinimum": 3
        \\}
    ;
    try expect_validation_cases(exclusive_schema_str, null, &.{
        .{ "3", false },
        .{ "3.1", true },
    });
}

test "number constraints - upper bounds combine to the stricter constraint" {
    const inclusive_schema_str =
        \\{
        \\  "maximum": 5,
        \\  "exclusiveMaximum": 8
        \\}
    ;
    try expect_validation_cases(inclusive_schema_str, null, &.{
        .{ "5", true },
        .{ "5.1", false },
    });

    const exclusive_schema_str =
        \\{
        \\  "maximum": 5,
        \\  "exclusiveMaximum": 5
        \\}
    ;
    try expect_validation_cases(exclusive_schema_str, null, &.{
        .{ "5", false },
        .{ "4.9", true },
    });
}

test "array constraints - minItems and maxItems" {
    const schema_str =
        \\{
        \\  "type": "array",
        \\  "minItems": 1,
        \\  "maxItems": 3
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "[1]", true },
        .{ "[1, 2]", true },
        .{ "[1, 2, 3]", true },
        .{ "[]", false },
        .{ "[1, 2, 3, 4]", false },
    });
}

test "array constraints - uniqueItems" {
    const schema_str =
        \\{
        \\  "type": "array",
        \\  "uniqueItems": true
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "[1, 2, 3]", true },
        .{
            \\["a", "b", "c"]
            ,
            true,
        },
        .{ "[]", true },
        .{ "[1, 2, 1]", false },
        .{
            \\["a", "a"]
            ,
            false,
        },
    });
}

test "array constraints - uniqueItems treats numerically equivalent values as duplicates" {
    const schema_str =
        \\{
        \\  "uniqueItems": true
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "[1, 1.5]", true },
        .{ "[1, 1.0]", false },
    });
}

test "array constraints - uniqueItems treats object key order as duplicates" {
    const schema_str =
        \\{
        \\  "uniqueItems": true
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\[
            \\  {"a": 1, "b": 2},
            \\  {"b": 2, "a": 1}
            \\]
            ,
            false,
        },
    });
}

test "array constraints - uniqueItems composes with items" {
    const schema_str =
        \\{
        \\  "type": "array",
        \\  "items": { "type": "integer" },
        \\  "uniqueItems": true
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "[1, 2, 3]", true },
        .{ "[1, 2, 1]", false },
        .{
            \\[1, "2", 3]
            ,
            false,
        },
    });
}

test "array constraints - uniqueItems composes with minItems" {
    const schema_str =
        \\{
        \\  "type": "array",
        \\  "minItems": 2,
        \\  "uniqueItems": true
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "[1, 2]", true },
        .{ "[1]", false },
        .{ "[1, 1]", false },
    });
}

test "array constraints - minItems and maxItems ignore non-arrays" {
    const schema_str =
        \\{
        \\  "minItems": 1,
        \\  "maxItems": 2
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"hello"
            ,
            true,
        },
        .{ "42", true },
        .{ "true", true },
        .{ "null", true },
        .{ "[]", false },
        .{ "[1]", true },
        .{ "[1, 2]", true },
        .{ "[1, 2, 3]", false },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\{"name": "John"}
            ,
            true,
        },
        .{
            \\{"name": "John", "age": 30}
            ,
            true,
        },
        .{ "{}", false },
        .{
            \\{"age": 30}
            ,
            false,
        },
    });
}

test "object constraints - required applies without properties and checks presence only" {
    const schema_str =
        \\{
        \\  "required": ["foo"]
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\{"foo": 1}
            ,
            true,
        },
        .{
            \\{"foo": null}
            ,
            true,
        },
        .{
            \\{"foo": false}
            ,
            true,
        },
        .{ "{}", false },
    });
}

test "object constraints - required is ignored for non-objects" {
    const schema_str =
        \\{
        \\  "required": ["foo"]
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "42", true },
        .{
            \\"hello"
            ,
            true,
        },
        .{ "true", true },
        .{ "[]", true },
        .{ "null", true },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\{"name": "John"}
            ,
            true,
        },
        .{ "{}", true },
        .{
            \\{"name": "John", "age": 30}
            ,
            false,
        },
        .{
            \\{"extra": "field"}
            ,
            false,
        },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{ "{}", true },
        .{
            \\{"name": "John"}
            ,
            true,
        },
        .{
            \\{"extra": 42}
            ,
            true,
        },
        .{
            \\{"forbidden": 1}
            ,
            false,
        },
    });
}

test "object constraints - patternProperties" {
    const schema_str =
        \\{
        \\  "patternProperties": {
        \\    "^[a-z]+$": { "type": "integer" }
        \\  }
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\{"foo": 1, "bar": 2}
            ,
            true,
        },
        .{
            \\{"CamelCase": true, "alphanumeric123": "ok"}
            ,
            true,
        },
        .{
            \\{"foo": "nope"}
            ,
            false,
        },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\{"foo": "long"}
            ,
            true,
        },
        .{
            \\{"boo": 1}
            ,
            true,
        },
        .{
            \\{"foo": "xx"}
            ,
            false,
        },
        .{
            \\{"boo": "xx"}
            ,
            false,
        },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\{"foo": "long", "extra": true}
            ,
            true,
        },
        .{
            \\{"foo": "xx"}
            ,
            false,
        },
        .{
            \\{"foo": 3}
            ,
            false,
        },
        .{
            \\{"fizz": 1}
            ,
            true,
        },
        .{
            \\{"extra": "nope"}
            ,
            false,
        },
    });
}

test "enum constraint" {
    const schema_str =
        \\{
        \\  "enum": ["red", "green", "blue", 42, null]
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"red"
            ,
            true,
        },
        .{
            \\"green"
            ,
            true,
        },
        .{
            \\"blue"
            ,
            true,
        },
        .{ "42", true },
        .{ "null", true },
        .{
            \\"yellow"
            ,
            false,
        },
        .{ "43", false },
        .{ "false", false },
    });
}

test "enum constraint treats integer and float representations as equal" {
    const schema_str =
        \\{
        \\  "enum": [1, 2.0, 3]
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "1", true },
        .{ "1.0", true },
        .{ "2", true },
        .{ "2.0", true },
        .{ "4", false },
        .{
            \\"1"
            ,
            false,
        },
    });
}

test "enum constraint supports heterogeneous values including object and array equality" {
    const schema_str =
        \\{
        \\  "enum": ["red", 123, true, {"foo": "bar", "baz": 1}, [1, 2], null]
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "true", true },
        .{
            \\{"baz":1,"foo":"bar"}
            ,
            true,
        },
        .{ "[1,2]", true },
        .{
            \\{"foo":"baz","baz":1}
            ,
            false,
        },
        .{ "[2,1]", false },
    });
}

test "enum constraint stays conjunctive with anyOf siblings" {
    const schema_str =
        \\{
        \\  "enum": ["foo", 42, true],
        \\  "anyOf": [
        \\    { "type": "string", "minLength": 3 },
        \\    { "type": "integer", "minimum": 100 }
        \\  ]
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"foo"
            ,
            true,
        },
        .{ "42", false },
        .{ "true", false },
        .{ "100", false },
    });
}

test "const constraint" {
    const schema_str =
        \\{
        \\  "const": "fixed-value"
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"fixed-value"
            ,
            true,
        },
        .{
            \\"other-value"
            ,
            false,
        },
        .{ "null", false },
        .{ "42", false },
    });
}

test "const constraint treats integer and float representations as equal" {
    const schema_str =
        \\{
        \\  "const": 5
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "5", true },
        .{ "5.0", true },
        .{ "5.5", false },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\{
            \\  "age": 30,
            \\  "name": "John Doe"
            \\}
            ,
            true,
        },
        .{
            \\{
            \\  "age": 31,
            \\  "name": "John Doe"
            \\}
            ,
            false,
        },
    });
}

test "const constraint composes with conflicting type" {
    const schema_str =
        \\{
        \\  "const": 42,
        \\  "type": "string"
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "42", false },
        .{
            \\"42"
            ,
            false,
        },
    });
}

test "const constraint composes with other validators" {
    const schema_str =
        \\{
        \\  "const": "abc",
        \\  "minLength": 5
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"abc"
            ,
            false,
        },
        .{
            \\"abcdef"
            ,
            false,
        },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{ "50", true },
        .{ "0", true },
        .{ "100", true },
        .{ "-1", false },
        .{ "101", false },
        .{
            \\"50"
            ,
            false,
        },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"hello"
            ,
            true,
        },
        .{ "42", true },
        .{ "true", false },
        .{ "null", false },
        .{ "[]", false },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{ "10", true },
        .{ "9", false },
        .{ "15", false },
        .{ "30", false },
        .{ "7", false },
        .{
            \\"hello"
            ,
            false,
        },
    });
}

test "not combinator" {
    const schema_str =
        \\{
        \\  "not": {
        \\    "type": "string"
        \\  }
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "42", true },
        .{ "true", true },
        .{ "null", true },
        .{ "[]", true },
        .{
            \\"hello"
            ,
            false,
        },
        .{
            \\""
            ,
            false,
        },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\{
            \\  "user": {
            \\    "name": "John Doe",
            \\    "email": "john@example.com"
            \\  },
            \\  "age": 30
            \\}
            ,
            true,
        },
        .{
            \\{
            \\  "user": {
            \\    "name": "John Doe"
            \\  }
            \\}
            ,
            false,
        },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{ "[1, 2, 3]", true },
        .{ "[0, 100, 50.5]", true },
        .{ "[]", true },
        .{ "[-1, 2, 3]", false },
        .{
            \\["1", 2, 3]
            ,
            false,
        },
    });
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
    try expect_validation_cases(schema_str, .draft2020_12, &.{
        .{ "[]", true },
        .{ "[true]", true },
        .{ "[true, 3]", true },
        .{ "[1]", false },
    });
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
    try expect_validation_cases(schema_str, .draft4, &.{
        .{ "[false, 35]", true },
        .{
            \\[false, 35, "foo"]
            ,
            false,
        },
    });
}

test "array constraints - additionalItems is ignored without tuple items" {
    const schema_str =
        \\{
        \\  "additionalItems": false
        \\}
    ;
    try expect_validation_cases(schema_str, .draft2019_09, &.{
        .{ "[]", true },
        .{ "[1, 2, 3]", true },
        .{
            \\"Hello World"
            ,
            true,
        },
    });
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
    try expect_validation_cases(schema_str, .draft2020_12, &.{
        .{
            \\["x"]
            ,
            true,
        },
        .{
            \\["x", 1]
            ,
            true,
        },
    });
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
    try expect_validation_cases(schema_str, .draft2020_12, &.{
        .{
            \\{"kind": "card", "billing_address": "123 Main St"}
            ,
            true,
        },
        .{
            \\{"kind": "card", "email": "person@example.com"}
            ,
            false,
        },
        .{
            \\{"email": "person@example.com"}
            ,
            true,
        },
        .{
            \\{"kind": "cash"}
            ,
            false,
        },
    });
}

test "multipleOf constraint" {
    const schema_str =
        \\{
        \\  "type": "number",
        \\  "multipleOf": 0.5
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "0", true },
        .{ "0.5", true },
        .{ "1", true },
        .{ "2.5", true },
        .{ "-1.5", true },
        .{ "0.3", false },
        .{ "1.7", false },
    });
}

test "multipleOf constraint - integer divisors follow docs examples" {
    const schema_str =
        \\{
        \\  "multipleOf": 5
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "10", true },
        .{ "-5", true },
        .{ "15.0", true },
        .{ "0", true },
        .{ "8", false },
        .{
            \\"100000"
            ,
            true,
        },
    });
}

test "multipleOf constraint - fractional divisors follow docs examples" {
    const schema_str =
        \\{
        \\  "multipleOf": 0.01
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "2", true },
        .{ "5.1", true },
        .{ "-12.34", true },
        .{ "1.234", false },
        .{ "0", true },
        .{
            \\"100000"
            ,
            true,
        },
    });
}

test "multipleOf constraint - siblings stay conjunctive with anyOf" {
    const schema_str =
        \\{
        \\  "anyOf": [
        \\    { "type": "integer" },
        \\    { "type": "string" }
        \\  ],
        \\  "multipleOf": 2
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "4", true },
        .{ "3", false },
        .{
            \\"word"
            ,
            true,
        },
        .{ "true", false },
    });
}

test "object constraints - minProperties and maxProperties" {
    const schema_str =
        \\{
        \\  "type": "object",
        \\  "minProperties": 1,
        \\  "maxProperties": 3
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\{"a": 1}
            ,
            true,
        },
        .{
            \\{"a": 1, "b": 2}
            ,
            true,
        },
        .{
            \\{"a": 1, "b": 2, "c": 3}
            ,
            true,
        },
        .{ "{}", false },
        .{
            \\{"a": 1, "b": 2, "c": 3, "d": 4}
            ,
            false,
        },
        .{ "[]", false },
        .{
            \\"string"
            ,
            false,
        },
    });
}

test "object constraints - minProperties and maxProperties ignore non-objects" {
    const schema_str =
        \\{
        \\  "minProperties": 1,
        \\  "maxProperties": 2
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"hello"
            ,
            true,
        },
        .{ "42", true },
        .{ "true", true },
        .{ "[]", true },
        .{ "null", true },
        .{ "{}", false },
        .{
            \\{"a": 1}
            ,
            true,
        },
        .{
            \\{"a": 1, "b": 2}
            ,
            true,
        },
        .{
            \\{"a": 1, "b": 2, "c": 3}
            ,
            false,
        },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\{"count": 5}
            ,
            true,
        },
        .{
            \\{"count": 0}
            ,
            true,
        },
        .{
            \\{"count": -1}
            ,
            false,
        },
        .{
            \\{"count": "five"}
            ,
            false,
        },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\["a", "b", "c"]
            ,
            true,
        },
        .{ "[]", true },
        .{
            \\["a", 1]
            ,
            false,
        },
        .{
            \\"not an array"
            ,
            false,
        },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{ "5", true },
        .{ "-10", true },
        .{
            \\"string"
            ,
            false,
        },
        .{ "1.5", false },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\{"value": 1}
            ,
            true,
        },
        .{
            \\{"value": 1, "child": {"value": 2}}
            ,
            true,
        },
        .{
            \\{"value": 1, "child": {"value": 2, "child": {"value": 3}}}
            ,
            true,
        },
        .{
            \\{"value": "not an int"}
            ,
            false,
        },
        .{
            \\{"value": 1, "child": {"value": "bad"}}
            ,
            false,
        },
    });
}

test "$ref overrides siblings in draft7" {
    const schema_str =
        \\{
        \\  "$schema": "http://json-schema.org/draft-07/schema#",
        \\  "$defs": {
        \\    "positiveInteger": {
        \\      "type": "integer",
        \\      "minimum": 0
        \\    }
        \\  },
        \\  "$ref": "#/$defs/positiveInteger",
        \\  "type": "string"
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "5", true },
        .{ "-1", false },
        .{
            \\"five"
            ,
            false,
        },
    });
}

test "$ref stays conjunctive with siblings in 2020-12" {
    const schema_str =
        \\{
        \\  "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\  "$defs": {
        \\    "positiveInteger": {
        \\      "type": "integer",
        \\      "minimum": 0
        \\    }
        \\  },
        \\  "$ref": "#/$defs/positiveInteger",
        \\  "maximum": 10
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{ "0", true },
        .{ "10", true },
        .{ "11", false },
        .{ "-1", false },
        .{
            \\"5"
            ,
            false,
        },
    });
}

test "$ref stays conjunctive with siblings in 2020-12 inside anyOf branch" {
    const schema_str =
        \\{
        \\  "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\  "$defs": {
        \\    "smallString": {
        \\      "type": "string",
        \\      "maxLength": 5
        \\    }
        \\  },
        \\  "anyOf": [
        \\    {
        \\      "$ref": "#/$defs/smallString",
        \\      "minLength": 3
        \\    },
        \\    { "const": 42 }
        \\  ]
        \\}
    ;
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"four"
            ,
            true,
        },
        .{
            \\"hi"
            ,
            false,
        },
        .{
            \\"toolong"
            ,
            false,
        },
        .{ "42", true },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{ "1", true },
        .{
            \\"1"
            ,
            false,
        },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{
            \\"ok"
            ,
            true,
        },
        .{ "1", false },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{ "true", true },
        .{
            \\"true"
            ,
            false,
        },
    });
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
    try expect_validation_cases(schema_str, .draft4, &.{
        .{
            \\{"foo": false}
            ,
            true,
        },
        .{
            \\{"foo": {"foo": false}}
            ,
            true,
        },
        .{
            \\{"bar": false}
            ,
            false,
        },
        .{
            \\{"foo": {"bar": false}}
            ,
            false,
        },
    });
}

test "dependentRequired - trigger present requires dependents (draft 2020-12)" {
    const schema_str =
        \\{
        \\  "dependentRequired": {
        \\    "credit_card": ["billing_address"]
        \\  }
        \\}
    ;
    try expect_validation_cases(schema_str, .draft2020_12, &.{
        .{ "{}", true },
        .{
            \\{"billing_address": "123 Main St"}
            ,
            true,
        },
        .{
            \\{"credit_card": 1234, "billing_address": "123 Main St"}
            ,
            true,
        },
        .{
            \\{"credit_card": 1234}
            ,
            false,
        },
    });
}

test "dependentRequired - trigger checks presence only (draft 2020-12)" {
    const schema_str =
        \\{
        \\  "dependentRequired": {
        \\    "credit_card": ["billing_address"]
        \\  }
        \\}
    ;
    try expect_validation_cases(schema_str, .draft2020_12, &.{
        .{
            \\{"credit_card": null}
            ,
            false,
        },
        .{
            \\{"credit_card": false, "billing_address": "123 Main St"}
            ,
            true,
        },
    });
}

test "dependentRequired - non-objects are valid (draft 2020-12)" {
    const schema_str =
        \\{
        \\  "dependentRequired": {
        \\    "credit_card": ["billing_address"]
        \\  }
        \\}
    ;
    try expect_validation_cases(schema_str, .draft2020_12, &.{
        .{ "42", true },
        .{
            \\"hello"
            ,
            true,
        },
        .{ "true", true },
        .{ "[]", true },
        .{ "null", true },
    });
}

test "dependentRequired - multiple dependencies (draft 2019-09)" {
    const schema_str =
        \\{
        \\  "dependentRequired": {
        \\    "name": ["surname", "given_name"]
        \\  }
        \\}
    ;
    try expect_validation_cases(schema_str, .draft2019_09, &.{
        .{ "{}", true },
        .{
            \\{"surname": "Doe"}
            ,
            true,
        },
        .{
            \\{"name": "X", "surname": "Doe"}
            ,
            false,
        },
        .{
            \\{"name": "X", "surname": "Doe", "given_name": "John"}
            ,
            true,
        },
    });
}

test "dependentRequired - transitive dependencies (draft 2019-09)" {
    const schema_str =
        \\{
        \\  "dependentRequired": {
        \\    "foo": ["bar"],
        \\    "bar": ["baz"]
        \\  }
        \\}
    ;
    try expect_validation_cases(schema_str, .draft2019_09, &.{
        .{
            \\{"foo": 1}
            ,
            false,
        },
        .{
            \\{"foo": 1, "bar": 2}
            ,
            false,
        },
        .{
            \\{"foo": 1, "bar": 2, "baz": 3}
            ,
            true,
        },
        .{
            \\{"bar": 2, "baz": 3}
            ,
            true,
        },
    });
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
    try expect_validation_cases(schema_str, null, &.{
        .{ "1", true },
        .{
            \\"text"
            ,
            true,
        },
        .{ "true", true },
        .{ "null", true },
        .{ "[]", true },
        .{ "{}", true },
    });
}
