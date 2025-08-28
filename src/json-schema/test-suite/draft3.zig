const std = @import("std");
const JSONSchema = @import("json-schema");

test "extends.extends.extends" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "integer",
        \\             "required": true
        \\         }
        \\     },
        \\     "extends": {
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string",
        \\                 "required": true
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "baz",
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "extends.extends.mismatch-extends" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "integer",
        \\             "required": true
        \\         }
        \\     },
        \\     "extends": {
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string",
        \\                 "required": true
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "extends.extends.mismatch-extended" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "integer",
        \\             "required": true
        \\         }
        \\     },
        \\     "extends": {
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string",
        \\                 "required": true
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "extends.extends.wrong-type" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "integer",
        \\             "required": true
        \\         }
        \\     },
        \\     "extends": {
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string",
        \\                 "required": true
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "baz",
        \\     "bar": "quux"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "extends.multiple-extends.valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "integer",
        \\             "required": true
        \\         }
        \\     },
        \\     "extends": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string",
        \\                     "required": true
        \\                 }
        \\             }
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "type": "null",
        \\                     "required": true
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "quux",
        \\     "bar": 2,
        \\     "baz": null
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "extends.multiple-extends.mismatch-first-extends" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "integer",
        \\             "required": true
        \\         }
        \\     },
        \\     "extends": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string",
        \\                     "required": true
        \\                 }
        \\             }
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "type": "null",
        \\                     "required": true
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 2,
        \\     "baz": null
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "extends.multiple-extends.mismatch-second-extends" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "integer",
        \\             "required": true
        \\         }
        \\     },
        \\     "extends": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string",
        \\                     "required": true
        \\                 }
        \\             }
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "type": "null",
        \\                     "required": true
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "quux",
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "extends.multiple-extends.mismatch-both" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "integer",
        \\             "required": true
        \\         }
        \\     },
        \\     "extends": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string",
        \\                     "required": true
        \\                 }
        \\             }
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "type": "null",
        \\                     "required": true
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "extends.extends-simple-types.valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": 20,
        \\     "extends": {
        \\         "maximum": 30
        \\     }
        \\ }
    );

    const case =
        \\ 25
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "extends.extends-simple-types.mismatch-extends" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": 20,
        \\     "extends": {
        \\         "maximum": 30
        \\     }
        \\ }
    );

    const case =
        \\ 35
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "maxLength.maxLength-validation.shorter-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxLength": 2
        \\ }
    );

    const case =
        \\ "f"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxLength.maxLength-validation.exact-length-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxLength": 2
        \\ }
    );

    const case =
        \\ "fo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxLength.maxLength-validation.too-long-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxLength": 2
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "maxLength.maxLength-validation.ignores-non-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxLength": 2
        \\ }
    );

    const case =
        \\ 10
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxLength.maxLength-validation.two-graphemes-is-long-enough" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxLength": 2
        \\ }
    );

    const case =
        \\ "💩💩"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.remote-ref.remote-ref-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://localhost:1234/integer.json"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.remote-ref.remote-ref-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://localhost:1234/integer.json"
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.fragment-within-remote-ref.remote-fragment-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://localhost:1234/draft3/subSchemas.json#/definitions/integer"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.fragment-within-remote-ref.remote-fragment-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://localhost:1234/draft3/subSchemas.json#/definitions/integer"
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.ref-within-remote-ref.ref-within-ref-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://localhost:1234/draft3/subSchemas.json#/definitions/refToInteger"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.ref-within-remote-ref.ref-within-ref-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://localhost:1234/draft3/subSchemas.json#/definitions/refToInteger"
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.change-resolution-scope.changed-scope-ref-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/",
        \\     "items": {
        \\         "id": "baseUriChange/",
        \\         "items": {
        \\             "$ref": "folderInteger.json"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         1
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.change-resolution-scope.changed-scope-ref-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/",
        \\     "items": {
        \\         "id": "baseUriChange/",
        \\         "items": {
        \\             "$ref": "folderInteger.json"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         "a"
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "divisibleBy.by-int.int-by-int" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "divisibleBy": 2
        \\ }
    );

    const case =
        \\ 10
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "divisibleBy.by-int.int-by-int-fail" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "divisibleBy": 2
        \\ }
    );

    const case =
        \\ 7
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "divisibleBy.by-int.ignores-non-numbers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "divisibleBy": 2
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "divisibleBy.by-number.zero-is-divisible-by-anything-(except-0)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "divisibleBy": 1.5
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "divisibleBy.by-number.4.5-is-divisible-by-1.5" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "divisibleBy": 1.5
        \\ }
    );

    const case =
        \\ 4.5
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "divisibleBy.by-number.35-is-not-divisible-by-1.5" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "divisibleBy": 1.5
        \\ }
    );

    const case =
        \\ 35
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "divisibleBy.by-small-number.0.0075-is-divisible-by-0.0001" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "divisibleBy": 0.0001
        \\ }
    );

    const case =
        \\ 0.0075
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "divisibleBy.by-small-number.0.00751-is-not-divisible-by-0.0001" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "divisibleBy": 0.0001
        \\ }
    );

    const case =
        \\ 0.00751
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "infinite-loop-detection.evaluating-the-same-schema-location-against-the-same-data-location-twice-is-not-a-sign-of-an-infinite-loop.passing-case" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "int": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/definitions/int"
        \\         }
        \\     },
        \\     "extends": {
        \\         "additionalProperties": {
        \\             "$ref": "#/definitions/int"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "infinite-loop-detection.evaluating-the-same-schema-location-against-the-same-data-location-twice-is-not-a-sign-of-an-infinite-loop.failing-case" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "int": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/definitions/int"
        \\         }
        \\     },
        \\     "extends": {
        \\         "additionalProperties": {
        \\             "$ref": "#/definitions/int"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "a string"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.root-pointer-ref.match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": false
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.root-pointer-ref.recursive-match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": {
        \\         "foo": false
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.root-pointer-ref.mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "bar": false
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.root-pointer-ref.recursive-mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": {
        \\         "bar": false
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.relative-pointer-ref-to-object.match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "$ref": "#/properties/foo"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 3
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.relative-pointer-ref-to-object.mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "$ref": "#/properties/foo"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar": true
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.relative-pointer-ref-to-array.match-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/items/0"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.relative-pointer-ref-to-array.mismatch-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/items/0"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.escaped-pointer-ref.slash-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "tilde~field": {
        \\             "type": "integer"
        \\         },
        \\         "slash/field": {
        \\             "type": "integer"
        \\         },
        \\         "percent%field": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "properties": {
        \\         "tilde": {
        \\             "$ref": "#/definitions/tilde~0field"
        \\         },
        \\         "slash": {
        \\             "$ref": "#/definitions/slash~1field"
        \\         },
        \\         "percent": {
        \\             "$ref": "#/definitions/percent%25field"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "slash": "aoeu"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.escaped-pointer-ref.tilde-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "tilde~field": {
        \\             "type": "integer"
        \\         },
        \\         "slash/field": {
        \\             "type": "integer"
        \\         },
        \\         "percent%field": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "properties": {
        \\         "tilde": {
        \\             "$ref": "#/definitions/tilde~0field"
        \\         },
        \\         "slash": {
        \\             "$ref": "#/definitions/slash~1field"
        \\         },
        \\         "percent": {
        \\             "$ref": "#/definitions/percent%25field"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "tilde": "aoeu"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.escaped-pointer-ref.percent-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "tilde~field": {
        \\             "type": "integer"
        \\         },
        \\         "slash/field": {
        \\             "type": "integer"
        \\         },
        \\         "percent%field": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "properties": {
        \\         "tilde": {
        \\             "$ref": "#/definitions/tilde~0field"
        \\         },
        \\         "slash": {
        \\             "$ref": "#/definitions/slash~1field"
        \\         },
        \\         "percent": {
        \\             "$ref": "#/definitions/percent%25field"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "percent": "aoeu"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.escaped-pointer-ref.slash-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "tilde~field": {
        \\             "type": "integer"
        \\         },
        \\         "slash/field": {
        \\             "type": "integer"
        \\         },
        \\         "percent%field": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "properties": {
        \\         "tilde": {
        \\             "$ref": "#/definitions/tilde~0field"
        \\         },
        \\         "slash": {
        \\             "$ref": "#/definitions/slash~1field"
        \\         },
        \\         "percent": {
        \\             "$ref": "#/definitions/percent%25field"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "slash": 123
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.escaped-pointer-ref.tilde-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "tilde~field": {
        \\             "type": "integer"
        \\         },
        \\         "slash/field": {
        \\             "type": "integer"
        \\         },
        \\         "percent%field": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "properties": {
        \\         "tilde": {
        \\             "$ref": "#/definitions/tilde~0field"
        \\         },
        \\         "slash": {
        \\             "$ref": "#/definitions/slash~1field"
        \\         },
        \\         "percent": {
        \\             "$ref": "#/definitions/percent%25field"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "tilde": 123
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.escaped-pointer-ref.percent-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "tilde~field": {
        \\             "type": "integer"
        \\         },
        \\         "slash/field": {
        \\             "type": "integer"
        \\         },
        \\         "percent%field": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "properties": {
        \\         "tilde": {
        \\             "$ref": "#/definitions/tilde~0field"
        \\         },
        \\         "slash": {
        \\             "$ref": "#/definitions/slash~1field"
        \\         },
        \\         "percent": {
        \\             "$ref": "#/definitions/percent%25field"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "percent": 123
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.nested-refs.nested-ref-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "a": {
        \\             "type": "integer"
        \\         },
        \\         "b": {
        \\             "$ref": "#/definitions/a"
        \\         },
        \\         "c": {
        \\             "$ref": "#/definitions/b"
        \\         }
        \\     },
        \\     "$ref": "#/definitions/c"
        \\ }
    );

    const case =
        \\ 5
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.nested-refs.nested-ref-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "a": {
        \\             "type": "integer"
        \\         },
        \\         "b": {
        \\             "$ref": "#/definitions/a"
        \\         },
        \\         "c": {
        \\             "$ref": "#/definitions/b"
        \\         }
        \\     },
        \\     "$ref": "#/definitions/c"
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.ref-overrides-any-sibling-keywords.remote-ref-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "reffed": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/definitions/reffed",
        \\             "maxItems": 2
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": []
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.ref-overrides-any-sibling-keywords.remote-ref-valid,-maxItems-ignored" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "reffed": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/definitions/reffed",
        \\             "maxItems": 2
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": [
        \\         1,
        \\         2,
        \\         3
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.ref-overrides-any-sibling-keywords.ref-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "reffed": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/definitions/reffed",
        \\             "maxItems": 2
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "string"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.property-named-$ref,-containing-an-actual-$ref.property-named-$ref-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "$ref": {
        \\             "$ref": "#/definitions/is-string"
        \\         }
        \\     },
        \\     "definitions": {
        \\         "is-string": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "$ref": "a"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.property-named-$ref,-containing-an-actual-$ref.property-named-$ref-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "$ref": {
        \\             "$ref": "#/definitions/is-string"
        \\         }
        \\     },
        \\     "definitions": {
        \\         "is-string": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "$ref": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.$ref-prevents-a-sibling-id-from-changing-the-base-uri.$ref-resolves-to-/definitions/base_foo,-data-does-not-validate" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/sibling_id/base/",
        \\     "definitions": {
        \\         "foo": {
        \\             "id": "http://localhost:1234/sibling_id/foo.json",
        \\             "type": "string"
        \\         },
        \\         "base_foo": {
        \\             "$comment": "this canonical uri is http://localhost:1234/sibling_id/base/foo.json",
        \\             "id": "foo.json",
        \\             "type": "number"
        \\         }
        \\     },
        \\     "extends": [
        \\         {
        \\             "$comment": "$ref resolves to http://localhost:1234/sibling_id/base/foo.json, not http://localhost:1234/sibling_id/foo.json",
        \\             "id": "http://localhost:1234/sibling_id/",
        \\             "$ref": "foo.json"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.$ref-prevents-a-sibling-id-from-changing-the-base-uri.$ref-resolves-to-/definitions/base_foo,-data-validates" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/sibling_id/base/",
        \\     "definitions": {
        \\         "foo": {
        \\             "id": "http://localhost:1234/sibling_id/foo.json",
        \\             "type": "string"
        \\         },
        \\         "base_foo": {
        \\             "$comment": "this canonical uri is http://localhost:1234/sibling_id/base/foo.json",
        \\             "id": "foo.json",
        \\             "type": "number"
        \\         }
        \\     },
        \\     "extends": [
        \\         {
        \\             "$comment": "$ref resolves to http://localhost:1234/sibling_id/base/foo.json, not http://localhost:1234/sibling_id/foo.json",
        \\             "id": "http://localhost:1234/sibling_id/",
        \\             "$ref": "foo.json"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.remote-ref,-containing-refs-itself.remote-ref-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://json-schema.org/draft-03/schema#"
        \\ }
    );

    const case =
        \\ {
        \\     "items": {
        \\         "type": "integer"
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.remote-ref,-containing-refs-itself.remote-ref-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://json-schema.org/draft-03/schema#"
        \\ }
    );

    const case =
        \\ {
        \\     "items": {
        \\         "type": 1
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.naive-replacement-of-$ref-with-its-destination-is-not-correct.do-not-evaluate-the-$ref-inside-the-enum,-matching-any-string" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "a_string": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "enum": [
        \\         {
        \\             "$ref": "#/definitions/a_string"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "this is a string"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.naive-replacement-of-$ref-with-its-destination-is-not-correct.match-the-enum-exactly" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "a_string": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "enum": [
        \\         {
        \\             "$ref": "#/definitions/a_string"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "$ref": "#/definitions/a_string"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.no-additional-properties-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "patternProperties": {
        \\         "^v": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.an-additional-property-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "patternProperties": {
        \\         "^v": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "quux": "boom"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "patternProperties": {
        \\         "^v": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.ignores-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "patternProperties": {
        \\         "^v": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    );

    const case =
        \\ "foobarbaz"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.ignores-other-non-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "patternProperties": {
        \\         "^v": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.patternProperties-are-not-additional-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "patternProperties": {
        \\         "^v": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "vroom": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalProperties.non-ASCII-pattern-with-additionalProperties.matching-the-pattern-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "^á": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "ármányos": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalProperties.non-ASCII-pattern-with-additionalProperties.not-matching-the-pattern-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "^á": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "élmény": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "additionalProperties.additionalProperties-with-schema.no-additional-properties-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "additionalProperties": {
        \\         "type": "boolean"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalProperties.additionalProperties-with-schema.an-additional-valid-property-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "additionalProperties": {
        \\         "type": "boolean"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "quux": true
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalProperties.additionalProperties-with-schema.an-additional-invalid-property-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "additionalProperties": {
        \\         "type": "boolean"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "quux": 12
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "additionalProperties.additionalProperties-can-exist-by-itself.an-additional-valid-property-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "additionalProperties": {
        \\         "type": "boolean"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": true
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalProperties.additionalProperties-can-exist-by-itself.an-additional-invalid-property-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "additionalProperties": {
        \\         "type": "boolean"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "additionalProperties.additionalProperties-are-allowed-by-default.additional-properties-are-allowed" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "quux": true
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalProperties.additionalProperties-does-not-look-in-applicators.properties-defined-in-extends-are-not-examined" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "extends": [
        \\         {
        \\             "properties": {
        \\                 "foo": {}
        \\             }
        \\         }
        \\     ],
        \\     "additionalProperties": {
        \\         "type": "boolean"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": true
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "additionalProperties.additionalProperties-with-null-valued-instance-properties.allows-null-values" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "additionalProperties": {
        \\         "type": "null"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": null
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.email-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "email"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.email-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "email"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.email-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "email"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.email-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "email"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.email-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "email"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.email-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "email"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ip-address-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ip-address"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ip-address-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ip-address"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ip-address-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ip-address"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ip-address-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ip-address"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ip-address-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ip-address"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ip-address-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ip-address"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv6-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ipv6"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv6-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ipv6"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv6-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ipv6"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv6-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ipv6"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv6-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ipv6"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv6-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ipv6"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.host-name-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "host-name"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.host-name-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "host-name"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.host-name-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "host-name"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.host-name-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "host-name"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.host-name-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "host-name"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.host-name-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "host-name"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-time-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "date-time"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-time-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "date-time"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-time-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "date-time"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-time-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "date-time"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-time-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "date-time"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-time-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "date-time"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.regex-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "regex"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.regex-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "regex"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.regex-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "regex"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.regex-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "regex"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.regex-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "regex"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.regex-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "regex"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "date"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "date"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "date"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "date"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "date"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "date"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.time-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "time"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.time-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "time"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.time-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "time"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.time-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "time"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.time-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "time"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.time-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "time"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.color-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "color"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.color-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "color"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.color-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "color"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.color-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "color"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.color-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "color"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.color-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "color"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "uri"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "uri"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "uri"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "uri"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "uri"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "uri"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maximum.maximum-validation.below-the-maximum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 3
        \\ }
    );

    const case =
        \\ 2.6
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maximum.maximum-validation.boundary-point-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 3
        \\ }
    );

    const case =
        \\ 3
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maximum.maximum-validation.above-the-maximum-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 3
        \\ }
    );

    const case =
        \\ 3.5
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "maximum.maximum-validation.ignores-non-numbers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 3
        \\ }
    );

    const case =
        \\ "x"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maximum.maximum-validation-with-unsigned-integer.below-the-maximum-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 300
        \\ }
    );

    const case =
        \\ 299.97
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maximum.maximum-validation-with-unsigned-integer.boundary-point-integer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 300
        \\ }
    );

    const case =
        \\ 300
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maximum.maximum-validation-with-unsigned-integer.boundary-point-float-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 300
        \\ }
    );

    const case =
        \\ 300
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maximum.maximum-validation-with-unsigned-integer.above-the-maximum-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 300
        \\ }
    );

    const case =
        \\ 300.5
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "maximum.maximum-validation-(explicit-false-exclusivity).below-the-maximum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 3,
        \\     "exclusiveMaximum": false
        \\ }
    );

    const case =
        \\ 2.6
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maximum.maximum-validation-(explicit-false-exclusivity).boundary-point-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 3,
        \\     "exclusiveMaximum": false
        \\ }
    );

    const case =
        \\ 3
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maximum.maximum-validation-(explicit-false-exclusivity).above-the-maximum-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 3,
        \\     "exclusiveMaximum": false
        \\ }
    );

    const case =
        \\ 3.5
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "maximum.maximum-validation-(explicit-false-exclusivity).ignores-non-numbers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 3,
        \\     "exclusiveMaximum": false
        \\ }
    );

    const case =
        \\ "x"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maximum.exclusiveMaximum-validation.below-the-maximum-is-still-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 3,
        \\     "exclusiveMaximum": true
        \\ }
    );

    const case =
        \\ 2.2
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maximum.exclusiveMaximum-validation.boundary-point-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maximum": 3,
        \\     "exclusiveMaximum": true
        \\ }
    );

    const case =
        \\ 3
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minItems.minItems-validation.longer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minItems": 1
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minItems.minItems-validation.exact-length-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minItems": 1
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minItems.minItems-validation.too-short-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minItems": 1
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minItems.minItems-validation.ignores-non-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minItems": 1
        \\ }
    );

    const case =
        \\ ""
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minLength.minLength-validation.longer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minLength": 2
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minLength.minLength-validation.exact-length-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minLength": 2
        \\ }
    );

    const case =
        \\ "fo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minLength.minLength-validation.too-short-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minLength": 2
        \\ }
    );

    const case =
        \\ "f"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minLength.minLength-validation.ignores-non-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minLength": 2
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minLength.minLength-validation.one-grapheme-is-not-long-enough" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minLength": 2
        \\ }
    );

    const case =
        \\ "💩"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.a-single-valid-match-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.multiple-valid-matches-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "foooooo": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.a-single-invalid-match-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "bar",
        \\     "fooooo": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.multiple-invalid-matches-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "bar",
        \\     "foooooo": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.ignores-other-non-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "patternProperties.multiple-simultaneous-patternProperties-are-validated.a-single-valid-match-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "a*": {
        \\             "type": "integer"
        \\         },
        \\         "aaa*": {
        \\             "maximum": 20
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a": 21
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "patternProperties.multiple-simultaneous-patternProperties-are-validated.a-simultaneous-match-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "a*": {
        \\             "type": "integer"
        \\         },
        \\         "aaa*": {
        \\             "maximum": 20
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "aaaa": 18
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "patternProperties.multiple-simultaneous-patternProperties-are-validated.multiple-matches-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "a*": {
        \\             "type": "integer"
        \\         },
        \\         "aaa*": {
        \\             "maximum": 20
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a": 21,
        \\     "aaaa": 18
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "patternProperties.multiple-simultaneous-patternProperties-are-validated.an-invalid-due-to-one-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "a*": {
        \\             "type": "integer"
        \\         },
        \\         "aaa*": {
        \\             "maximum": 20
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "patternProperties.multiple-simultaneous-patternProperties-are-validated.an-invalid-due-to-the-other-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "a*": {
        \\             "type": "integer"
        \\         },
        \\         "aaa*": {
        \\             "maximum": 20
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "aaaa": 31
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "patternProperties.multiple-simultaneous-patternProperties-are-validated.an-invalid-due-to-both-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "a*": {
        \\             "type": "integer"
        \\         },
        \\         "aaa*": {
        \\             "maximum": 20
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "aaa": "foo",
        \\     "aaaa": 31
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "patternProperties.regexes-are-not-anchored-by-default-and-are-case-sensitive.non-recognized-members-are-ignored" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "[0-9]{2,}": {
        \\             "type": "boolean"
        \\         },
        \\         "X_": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "answer 1": "42"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "patternProperties.regexes-are-not-anchored-by-default-and-are-case-sensitive.recognized-members-are-accounted-for" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "[0-9]{2,}": {
        \\             "type": "boolean"
        \\         },
        \\         "X_": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a31b": null
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "patternProperties.regexes-are-not-anchored-by-default-and-are-case-sensitive.regexes-are-case-sensitive" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "[0-9]{2,}": {
        \\             "type": "boolean"
        \\         },
        \\         "X_": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a_x_3": 3
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "patternProperties.regexes-are-not-anchored-by-default-and-are-case-sensitive.regexes-are-case-sensitive,-2" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "[0-9]{2,}": {
        \\             "type": "boolean"
        \\         },
        \\         "X_": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a_X_3": 3
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "patternProperties.patternProperties-with-null-valued-instance-properties.allows-null-values" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "patternProperties": {
        \\         "^.*bar$": {
        \\             "type": "null"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foobar": null
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minimum.minimum-validation.above-the-minimum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": 1.1
        \\ }
    );

    const case =
        \\ 2.6
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minimum.minimum-validation.boundary-point-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": 1.1
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minimum.minimum-validation.below-the-minimum-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": 1.1
        \\ }
    );

    const case =
        \\ 0.6
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minimum.minimum-validation.ignores-non-numbers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": 1.1
        \\ }
    );

    const case =
        \\ "x"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minimum.exclusiveMinimum-validation.above-the-minimum-is-still-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": 1.1,
        \\     "exclusiveMinimum": true
        \\ }
    );

    const case =
        \\ 1.2
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minimum.exclusiveMinimum-validation.boundary-point-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": 1.1,
        \\     "exclusiveMinimum": true
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minimum.minimum-validation-with-signed-integer.negative-above-the-minimum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": -2
        \\ }
    );

    const case =
        \\ -1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minimum.minimum-validation-with-signed-integer.positive-above-the-minimum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": -2
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minimum.minimum-validation-with-signed-integer.boundary-point-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": -2
        \\ }
    );

    const case =
        \\ -2
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minimum.minimum-validation-with-signed-integer.boundary-point-with-float-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": -2
        \\ }
    );

    const case =
        \\ -2
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minimum.minimum-validation-with-signed-integer.float-below-the-minimum-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": -2
        \\ }
    );

    const case =
        \\ -2.0001
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minimum.minimum-validation-with-signed-integer.int-below-the-minimum-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": -2
        \\ }
    );

    const case =
        \\ -3
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minimum.minimum-validation-with-signed-integer.ignores-non-numbers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": -2
        \\ }
    );

    const case =
        \\ "x"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.integer-type-matches-integers.an-integer-is-an-integer" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "integer"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.integer-type-matches-integers.a-float-is-not-an-integer" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "integer"
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.integer-type-matches-integers.a-string-is-not-an-integer" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "integer"
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.integer-type-matches-integers.a-string-is-still-not-an-integer,-even-if-it-looks-like-one" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "integer"
        \\ }
    );

    const case =
        \\ "1"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.integer-type-matches-integers.an-object-is-not-an-integer" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "integer"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.integer-type-matches-integers.an-array-is-not-an-integer" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "integer"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.integer-type-matches-integers.a-boolean-is-not-an-integer" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "integer"
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.integer-type-matches-integers.null-is-not-an-integer" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "integer"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.number-type-matches-numbers.an-integer-is-a-number" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "number"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.number-type-matches-numbers.a-float-with-zero-fractional-part-is-a-number" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "number"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.number-type-matches-numbers.a-float-is-a-number" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "number"
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.number-type-matches-numbers.a-string-is-not-a-number" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "number"
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.number-type-matches-numbers.a-string-is-still-not-a-number,-even-if-it-looks-like-one" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "number"
        \\ }
    );

    const case =
        \\ "1"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.number-type-matches-numbers.an-object-is-not-a-number" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "number"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.number-type-matches-numbers.an-array-is-not-a-number" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "number"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.number-type-matches-numbers.a-boolean-is-not-a-number" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "number"
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.number-type-matches-numbers.null-is-not-a-number" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "number"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.string-type-matches-strings.1-is-not-a-string" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.string-type-matches-strings.a-float-is-not-a-string" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string"
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.string-type-matches-strings.a-string-is-a-string" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string"
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.string-type-matches-strings.a-string-is-still-a-string,-even-if-it-looks-like-a-number" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string"
        \\ }
    );

    const case =
        \\ "1"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.string-type-matches-strings.an-object-is-not-a-string" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.string-type-matches-strings.an-array-is-not-a-string" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.string-type-matches-strings.a-boolean-is-not-a-string" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string"
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.string-type-matches-strings.null-is-not-a-string" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.object-type-matches-objects.an-integer-is-not-an-object" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.object-type-matches-objects.a-float-is-not-an-object" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object"
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.object-type-matches-objects.a-string-is-not-an-object" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object"
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.object-type-matches-objects.an-object-is-an-object" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.object-type-matches-objects.an-array-is-not-an-object" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.object-type-matches-objects.a-boolean-is-not-an-object" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object"
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.object-type-matches-objects.null-is-not-an-object" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.array-type-matches-arrays.an-integer-is-not-an-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "array"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.array-type-matches-arrays.a-float-is-not-an-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "array"
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.array-type-matches-arrays.a-string-is-not-an-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "array"
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.array-type-matches-arrays.an-object-is-not-an-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "array"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.array-type-matches-arrays.an-array-is-an-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "array"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.array-type-matches-arrays.a-boolean-is-not-an-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "array"
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.array-type-matches-arrays.null-is-not-an-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "array"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.boolean-type-matches-booleans.an-integer-is-not-a-boolean" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "boolean"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.boolean-type-matches-booleans.a-float-is-not-a-boolean" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "boolean"
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.boolean-type-matches-booleans.a-string-is-not-a-boolean" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "boolean"
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.boolean-type-matches-booleans.an-object-is-not-a-boolean" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "boolean"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.boolean-type-matches-booleans.an-array-is-not-a-boolean" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "boolean"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.boolean-type-matches-booleans.a-boolean-is-a-boolean" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "boolean"
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.boolean-type-matches-booleans.null-is-not-a-boolean" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "boolean"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.null-type-matches-only-the-null-object.an-integer-is-not-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "null"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.null-type-matches-only-the-null-object.a-float-is-not-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "null"
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.null-type-matches-only-the-null-object.a-string-is-not-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "null"
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.null-type-matches-only-the-null-object.an-object-is-not-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "null"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.null-type-matches-only-the-null-object.an-array-is-not-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "null"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.null-type-matches-only-the-null-object.a-boolean-is-not-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "null"
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.null-type-matches-only-the-null-object.null-is-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "null"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.any-type-matches-any-type.any-type-includes-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "any"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.any-type-matches-any-type.any-type-includes-float" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "any"
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.any-type-matches-any-type.any-type-includes-string" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "any"
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.any-type-matches-any-type.any-type-includes-object" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "any"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.any-type-matches-any-type.any-type-includes-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "any"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.any-type-matches-any-type.any-type-includes-boolean" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "any"
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.any-type-matches-any-type.any-type-includes-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "any"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.multiple-types-can-be-specified-in-an-array.an-integer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.multiple-types-can-be-specified-in-an-array.a-string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.multiple-types-can-be-specified-in-an-array.a-float-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.multiple-types-can-be-specified-in-an-array.an-object-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.multiple-types-can-be-specified-in-an-array.an-array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.multiple-types-can-be-specified-in-an-array.a-boolean-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.multiple-types-can-be-specified-in-an-array.null-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.types-can-include-schemas.an-integer-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         {
        \\             "type": "object"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.types-can-include-schemas.a-string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         {
        \\             "type": "object"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.types-can-include-schemas.a-float-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         {
        \\             "type": "object"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.types-can-include-schemas.an-object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         {
        \\             "type": "object"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.types-can-include-schemas.an-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         {
        \\             "type": "object"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.types-can-include-schemas.a-boolean-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         {
        \\             "type": "object"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.types-can-include-schemas.null-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         {
        \\             "type": "object"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.applies-a-nested-schema.an-integer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "integer",
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "null"
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.applies-a-nested-schema.an-object-is-valid-only-if-it-is-fully-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "integer",
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "null"
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": null
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.applies-a-nested-schema.an-object-is-invalid-otherwise" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "integer",
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "null"
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.types-from-separate-schemas-are-merged.an-integer-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         {
        \\             "type": [
        \\                 "string"
        \\             ]
        \\         },
        \\         {
        \\             "type": [
        \\                 "array",
        \\                 "null"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.types-from-separate-schemas-are-merged.a-string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         {
        \\             "type": [
        \\                 "string"
        \\             ]
        \\         },
        \\         {
        \\             "type": [
        \\                 "array",
        \\                 "null"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.types-from-separate-schemas-are-merged.an-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         {
        \\             "type": [
        \\                 "string"
        \\             ]
        \\         },
        \\         {
        \\             "type": [
        \\                 "array",
        \\                 "null"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.object-properties-validation.both-properties-present-and-valid-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.object-properties-validation.one-property-invalid-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": {}
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "properties.object-properties-validation.both-properties-invalid-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": [],
        \\     "bar": {}
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "properties.object-properties-validation.doesn't-invalidate-other-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "quux": []
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.object-properties-validation.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.object-properties-validation.ignores-other-non-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.property-validates-property" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "array",
        \\             "maxItems": 3
        \\         },
        \\         "bar": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "patternProperties": {
        \\         "f.o": {
        \\             "minItems": 2
        \\         }
        \\     },
        \\     "additionalProperties": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": [
        \\         1,
        \\         2
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.property-invalidates-property" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "array",
        \\             "maxItems": 3
        \\         },
        \\         "bar": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "patternProperties": {
        \\         "f.o": {
        \\             "minItems": 2
        \\         }
        \\     },
        \\     "additionalProperties": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": [
        \\         1,
        \\         2,
        \\         3,
        \\         4
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.patternProperty-invalidates-property" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "array",
        \\             "maxItems": 3
        \\         },
        \\         "bar": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "patternProperties": {
        \\         "f.o": {
        \\             "minItems": 2
        \\         }
        \\     },
        \\     "additionalProperties": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": []
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.patternProperty-validates-nonproperty" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "array",
        \\             "maxItems": 3
        \\         },
        \\         "bar": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "patternProperties": {
        \\         "f.o": {
        \\             "minItems": 2
        \\         }
        \\     },
        \\     "additionalProperties": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "fxo": [
        \\         1,
        \\         2
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.patternProperty-invalidates-nonproperty" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "array",
        \\             "maxItems": 3
        \\         },
        \\         "bar": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "patternProperties": {
        \\         "f.o": {
        \\             "minItems": 2
        \\         }
        \\     },
        \\     "additionalProperties": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "fxo": []
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.additionalProperty-ignores-property" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "array",
        \\             "maxItems": 3
        \\         },
        \\         "bar": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "patternProperties": {
        \\         "f.o": {
        \\             "minItems": 2
        \\         }
        \\     },
        \\     "additionalProperties": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar": []
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.additionalProperty-validates-others" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "array",
        \\             "maxItems": 3
        \\         },
        \\         "bar": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "patternProperties": {
        \\         "f.o": {
        \\             "minItems": 2
        \\         }
        \\     },
        \\     "additionalProperties": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "quux": 3
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.additionalProperty-invalidates-others" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "array",
        \\             "maxItems": 3
        \\         },
        \\         "bar": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "patternProperties": {
        \\         "f.o": {
        \\             "minItems": 2
        \\         }
        \\     },
        \\     "additionalProperties": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "quux": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "properties.properties-with-null-valued-instance-properties.allows-null-values" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "null"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": null
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.a-schema-given-for-items.valid-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.a-schema-given-for-items.wrong-type-of-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     "x"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "items.a-schema-given-for-items.ignores-non-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.an-array-of-schemas-for-items.correct-types" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "type": "string"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.an-array-of-schemas-for-items.wrong-types" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "type": "string"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "items.items-with-null-instance-elements.allows-null-elements" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": {
        \\         "type": "null"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     null
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.array-form-items-with-null-instance-elements.allows-null-elements" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "null"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     null
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.dependencies.neither" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": "foo"
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.dependencies.nondependant" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": "foo"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.dependencies.with-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": "foo"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.dependencies.missing-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": "foo"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependencies.dependencies.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": "foo"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.dependencies.ignores-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": "foo"
        \\     }
        \\ }
    );

    const case =
        \\ "foobar"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.dependencies.ignores-other-non-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": "foo"
        \\     }
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.multiple-dependencies.neither" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "quux": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.multiple-dependencies.nondependants" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "quux": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.multiple-dependencies.with-dependencies" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "quux": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "quux": 3
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.multiple-dependencies.missing-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "quux": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "quux": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependencies.multiple-dependencies.missing-other-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "quux": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 1,
        \\     "quux": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependencies.multiple-dependencies.missing-both-dependencies" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "quux": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "quux": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependencies.multiple-dependencies-subschema.valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "integer"
        \\                 },
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.multiple-dependencies-subschema.no-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "integer"
        \\                 },
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "quux"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.multiple-dependencies-subschema.wrong-type" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "integer"
        \\                 },
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "quux",
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependencies.multiple-dependencies-subschema.wrong-type-other" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "integer"
        \\                 },
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 2,
        \\     "bar": "quux"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependencies.multiple-dependencies-subschema.wrong-type-both" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "integer"
        \\                 },
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "quux",
        \\     "bar": "quux"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "required.required-validation.present-required-property-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "required": true
        \\         },
        \\         "bar": {}
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "required.required-validation.non-present-required-property-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "required": true
        \\         },
        \\         "bar": {}
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "required.required-default-validation.not-required-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {}
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "required.required-explicitly-false-validation.not-required-if-required-is-false" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "required": false
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "default.invalid-type-for-default.valid-when-property-is-specified" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer",
        \\             "default": []
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 13
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "default.invalid-type-for-default.still-valid-when-the-invalid-default-is-used" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer",
        \\             "default": []
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "default.invalid-string-value-for-default.valid-when-property-is-specified" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "string",
        \\             "minLength": 4,
        \\             "default": "bad"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar": "good"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "default.invalid-string-value-for-default.still-valid-when-the-invalid-default-is-used" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "string",
        \\             "minLength": 4,
        \\             "default": "bad"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "default.the-default-keyword-does-not-do-anything-if-the-property-is-missing.an-explicit-property-value-is-checked-against-maximum-(passing)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object",
        \\     "properties": {
        \\         "alpha": {
        \\             "type": "number",
        \\             "maximum": 3,
        \\             "default": 5
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "alpha": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "default.the-default-keyword-does-not-do-anything-if-the-property-is-missing.an-explicit-property-value-is-checked-against-maximum-(failing)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object",
        \\     "properties": {
        \\         "alpha": {
        \\             "type": "number",
        \\             "maximum": 3,
        \\             "default": 5
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "alpha": 5
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "default.the-default-keyword-does-not-do-anything-if-the-property-is-missing.missing-properties-are-not-filled-in-with-the-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object",
        \\     "properties": {
        \\         "alpha": {
        \\             "type": "number",
        \\             "maximum": 3,
        \\             "default": 5
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.unique-array-of-integers-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-integers-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-more-than-two-integers-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2,
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-validation.numbers-are-unique-if-mathematically-unequal" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     1,
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-validation.unique-array-of-strings-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "baz"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-strings-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-validation.unique-array-of-objects-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "foo": "bar"
        \\     },
        \\     {
        \\         "foo": "baz"
        \\     }
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-objects-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "foo": "bar"
        \\     },
        \\     {
        \\         "foo": "bar"
        \\     }
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-validation.unique-array-of-nested-objects-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "foo": {
        \\             "bar": {
        \\                 "baz": true
        \\             }
        \\         }
        \\     },
        \\     {
        \\         "foo": {
        \\             "bar": {
        \\                 "baz": false
        \\             }
        \\         }
        \\     }
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-nested-objects-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "foo": {
        \\             "bar": {
        \\                 "baz": true
        \\             }
        \\         }
        \\     },
        \\     {
        \\         "foo": {
        \\             "bar": {
        \\                 "baz": true
        \\             }
        \\         }
        \\     }
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-validation.unique-array-of-arrays-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         "foo"
        \\     ],
        \\     [
        \\         "bar"
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-arrays-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         "foo"
        \\     ],
        \\     [
        \\         "foo"
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-more-than-two-arrays-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         "foo"
        \\     ],
        \\     [
        \\         "bar"
        \\     ],
        \\     [
        \\         "foo"
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-validation.1-and-true-are-unique" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.0-and-false-are-unique" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     0,
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.[1]-and-[true]-are-unique" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         1
        \\     ],
        \\     [
        \\         true
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.[0]-and-[false]-are-unique" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         0
        \\     ],
        \\     [
        \\         false
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.nested-[1]-and-[true]-are-unique" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         [
        \\             1
        \\         ],
        \\         "foo"
        \\     ],
        \\     [
        \\         [
        \\             true
        \\         ],
        \\         "foo"
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.nested-[0]-and-[false]-are-unique" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         [
        \\             0
        \\         ],
        \\         "foo"
        \\     ],
        \\     [
        \\         [
        \\             false
        \\         ],
        \\         "foo"
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.unique-heterogeneous-types-are-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     {},
        \\     [
        \\         1
        \\     ],
        \\     true,
        \\     null,
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.non-unique-heterogeneous-types-are-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     {},
        \\     [
        \\         1
        \\     ],
        \\     true,
        \\     null,
        \\     {},
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-validation.{'a':-false}-and-{'a':-0}-are-unique" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "a": false
        \\     },
        \\     {
        \\         "a": 0
        \\     }
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.{'a':-true}-and-{'a':-1}-are-unique" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "a": true
        \\     },
        \\     {
        \\         "a": 1
        \\     }
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-with-an-array-of-items.[false,-true]-from-items-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-with-an-array-of-items.[true,-false]-from-items-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     true,
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-with-an-array-of-items.[false,-false]-from-items-array-is-not-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-with-an-array-of-items.[true,-true]-from-items-array-is-not-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     true,
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-with-an-array-of-items.unique-array-extended-from-[false,-true]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     true,
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-with-an-array-of-items.unique-array-extended-from-[true,-false]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     true,
        \\     false,
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-with-an-array-of-items.non-unique-array-extended-from-[false,-true]-is-not-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     true,
        \\     "foo",
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-with-an-array-of-items.non-unique-array-extended-from-[true,-false]-is-not-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     true,
        \\     false,
        \\     "foo",
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-with-an-array-of-items-and-additionalItems=false.[false,-true]-from-items-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true,
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-with-an-array-of-items-and-additionalItems=false.[true,-false]-from-items-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true,
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     true,
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-with-an-array-of-items-and-additionalItems=false.[false,-false]-from-items-array-is-not-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true,
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-with-an-array-of-items-and-additionalItems=false.[true,-true]-from-items-array-is-not-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true,
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     true,
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems-with-an-array-of-items-and-additionalItems=false.extra-items-are-invalid-even-if-unique" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true,
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     true,
        \\     null
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "uniqueItems.uniqueItems=false-validation.unique-array-of-integers-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-validation.non-unique-array-of-integers-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-validation.numbers-are-unique-if-mathematically-unequal" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     1,
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-validation.unique-array-of-objects-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "foo": "bar"
        \\     },
        \\     {
        \\         "foo": "baz"
        \\     }
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-validation.non-unique-array-of-objects-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "foo": "bar"
        \\     },
        \\     {
        \\         "foo": "bar"
        \\     }
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-validation.unique-array-of-nested-objects-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "foo": {
        \\             "bar": {
        \\                 "baz": true
        \\             }
        \\         }
        \\     },
        \\     {
        \\         "foo": {
        \\             "bar": {
        \\                 "baz": false
        \\             }
        \\         }
        \\     }
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-validation.non-unique-array-of-nested-objects-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "foo": {
        \\             "bar": {
        \\                 "baz": true
        \\             }
        \\         }
        \\     },
        \\     {
        \\         "foo": {
        \\             "bar": {
        \\                 "baz": true
        \\             }
        \\         }
        \\     }
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-validation.unique-array-of-arrays-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         "foo"
        \\     ],
        \\     [
        \\         "bar"
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-validation.non-unique-array-of-arrays-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         "foo"
        \\     ],
        \\     [
        \\         "foo"
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-validation.1-and-true-are-unique" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-validation.0-and-false-are-unique" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     0,
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-validation.unique-heterogeneous-types-are-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     {},
        \\     [
        \\         1
        \\     ],
        \\     true,
        \\     null,
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-validation.non-unique-heterogeneous-types-are-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     {},
        \\     [
        \\         1
        \\     ],
        \\     true,
        \\     null,
        \\     {},
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.[false,-true]-from-items-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.[true,-false]-from-items-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     true,
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.[false,-false]-from-items-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.[true,-true]-from-items-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     true,
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.unique-array-extended-from-[false,-true]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     true,
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.unique-array-extended-from-[true,-false]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     true,
        \\     false,
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.non-unique-array-extended-from-[false,-true]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     true,
        \\     "foo",
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.non-unique-array-extended-from-[true,-false]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false
        \\ }
    );

    const case =
        \\ [
        \\     true,
        \\     false,
        \\     "foo",
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items-and-additionalItems=false.[false,-true]-from-items-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false,
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items-and-additionalItems=false.[true,-false]-from-items-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false,
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     true,
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items-and-additionalItems=false.[false,-false]-from-items-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false,
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items-and-additionalItems=false.[true,-true]-from-items-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false,
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     true,
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items-and-additionalItems=false.extra-items-are-invalid-even-if-unique" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false,
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     false,
        \\     true,
        \\     null
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "maxItems.maxItems-validation.shorter-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxItems": 2
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxItems.maxItems-validation.exact-length-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxItems": 2
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxItems.maxItems-validation.too-long-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxItems": 2
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "maxItems.maxItems-validation.ignores-non-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxItems": 2
        \\ }
    );

    const case =
        \\ "foobar"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "pattern.pattern-validation.a-matching-pattern-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "pattern": "^a*$"
        \\ }
    );

    const case =
        \\ "aaa"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "pattern.pattern-validation.a-non-matching-pattern-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "pattern": "^a*$"
        \\ }
    );

    const case =
        \\ "abc"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "pattern.pattern-validation.ignores-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "pattern": "^a*$"
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "pattern.pattern-validation.ignores-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "pattern": "^a*$"
        \\ }
    );

    const case =
        \\ 123
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "pattern.pattern-validation.ignores-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "pattern": "^a*$"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "pattern.pattern-validation.ignores-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "pattern": "^a*$"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "pattern.pattern-validation.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "pattern": "^a*$"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "pattern.pattern-validation.ignores-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "pattern": "^a*$"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "pattern.pattern-is-not-anchored.matches-a-substring" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "pattern": "a+"
        \\ }
    );

    const case =
        \\ "xxaayy"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.simple-enum-validation.one-of-the-enum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         1,
        \\         2,
        \\         3
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.simple-enum-validation.something-else-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         1,
        \\         2,
        \\         3
        \\     ]
        \\ }
    );

    const case =
        \\ 4
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.heterogeneous-enum-validation.one-of-the-enum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         6,
        \\         "foo",
        \\         [],
        \\         true,
        \\         {
        \\             "foo": 12
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.heterogeneous-enum-validation.something-else-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         6,
        \\         "foo",
        \\         [],
        \\         true,
        \\         {
        \\             "foo": 12
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.heterogeneous-enum-validation.objects-are-deep-compared" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         6,
        \\         "foo",
        \\         [],
        \\         true,
        \\         {
        \\             "foo": 12
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": false
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.heterogeneous-enum-with-null-validation.null-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         6,
        \\         null
        \\     ]
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.heterogeneous-enum-with-null-validation.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         6,
        \\         null
        \\     ]
        \\ }
    );

    const case =
        \\ 6
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.heterogeneous-enum-with-null-validation.something-else-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         6,
        \\         null
        \\     ]
        \\ }
    );

    const case =
        \\ "test"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enums-in-properties.both-properties-are-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "enum": [
        \\                 "foo"
        \\             ]
        \\         },
        \\         "bar": {
        \\             "enum": [
        \\                 "bar"
        \\             ],
        \\             "required": true
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enums-in-properties.wrong-foo-value" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "enum": [
        \\                 "foo"
        \\             ]
        \\         },
        \\         "bar": {
        \\             "enum": [
        \\                 "bar"
        \\             ],
        \\             "required": true
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foot",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enums-in-properties.wrong-bar-value" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "enum": [
        \\                 "foo"
        \\             ]
        \\         },
        \\         "bar": {
        \\             "enum": [
        \\                 "bar"
        \\             ],
        \\             "required": true
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bart"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enums-in-properties.missing-optional-property-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "enum": [
        \\                 "foo"
        \\             ]
        \\         },
        \\         "bar": {
        \\             "enum": [
        \\                 "bar"
        \\             ],
        \\             "required": true
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enums-in-properties.missing-required-property-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "enum": [
        \\                 "foo"
        \\             ]
        \\         },
        \\         "bar": {
        \\             "enum": [
        \\                 "bar"
        \\             ],
        \\             "required": true
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enums-in-properties.missing-all-properties-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "enum": [
        \\                 "foo"
        \\             ]
        \\         },
        \\         "bar": {
        \\             "enum": [
        \\                 "bar"
        \\             ],
        \\             "required": true
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.nul-characters-in-strings.match-string-with-nul" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         "hello\u0000there"
        \\     ]
        \\ }
    );

    const case =
        \\ "hello\u0000there"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.nul-characters-in-strings.do-not-match-string-lacking-nul" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         "hello\u0000there"
        \\     ]
        \\ }
    );

    const case =
        \\ "hellothere"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "additionalItems.additionalItems-as-schema.additional-items-match-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [],
        \\     "additionalItems": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2,
        \\     3,
        \\     4
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalItems.additionalItems-as-schema.additional-items-do-not-match-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [],
        \\     "additionalItems": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2,
        \\     3,
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "additionalItems.when-items-is-schema,-additionalItems-does-nothing.all-items-match-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": {},
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2,
        \\     3,
        \\     4,
        \\     5
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalItems.array-of-items-with-no-additionalItems-permitted.empty-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalItems.array-of-items-with-no-additionalItems-permitted.fewer-number-of-items-present-(1)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalItems.array-of-items-with-no-additionalItems-permitted.fewer-number-of-items-present-(2)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalItems.array-of-items-with-no-additionalItems-permitted.equal-number-of-items-present" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalItems.array-of-items-with-no-additionalItems-permitted.additional-items-are-not-permitted" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2,
        \\     3,
        \\     4
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "additionalItems.additionalItems-as-false-without-items.items-defaults-to-empty-schema-so-everything-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2,
        \\     3,
        \\     4,
        \\     5
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalItems.additionalItems-as-false-without-items.ignores-non-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalItems.additionalItems-are-allowed-by-default.only-the-first-item-is-validated" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     "foo",
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalItems.additionalItems-does-not-look-in-applicators.items-defined-in-extends-are-not-examined" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "extends": [
        \\         {
        \\             "items": [
        \\                 {
        \\                     "type": "integer"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "additionalItems": {
        \\         "type": "boolean"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     null
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalItems.additionalItems-with-heterogeneous-array.heterogeneous-invalid-instance" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar",
        \\     37
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "additionalItems.additionalItems-with-heterogeneous-array.valid-instance" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    );

    const case =
        \\ [
        \\     null
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalItems.additionalItems-with-null-instance-elements.allows-null-elements" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "additionalItems": {
        \\         "type": "null"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     null
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "disallow.disallow.allowed" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "disallow": "integer"
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "disallow.disallow.disallowed" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "disallow": "integer"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "disallow.multiple-disallow.valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "disallow": [
        \\         "integer",
        \\         "boolean"
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "disallow.multiple-disallow.mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "disallow": [
        \\         "integer",
        \\         "boolean"
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "disallow.multiple-disallow.other-mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "disallow": [
        \\         "integer",
        \\         "boolean"
        \\     ]
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "disallow.multiple-disallow-subschema.match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "disallow": [
        \\         "string",
        \\         {
        \\             "type": "object",
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "disallow.multiple-disallow-subschema.other-match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "disallow": [
        \\         "string",
        \\         {
        \\             "type": "object",
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "disallow.multiple-disallow-subschema.mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "disallow": [
        \\         "string",
        \\         {
        \\             "type": "object",
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "disallow.multiple-disallow-subschema.other-mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "disallow": [
        \\         "string",
        \\         {
        \\             "type": "object",
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
