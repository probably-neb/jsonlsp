const std = @import("std");
const JSONSchema = @import("json-schema");

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
        \\ 100
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
        \\     "$ref": "http://localhost:1234/draft4/subSchemas.json#/definitions/integer"
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
        \\     "$ref": "http://localhost:1234/draft4/subSchemas.json#/definitions/integer"
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
        \\     "$ref": "http://localhost:1234/draft4/subSchemas.json#/definitions/refToInteger"
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
        \\     "$ref": "http://localhost:1234/draft4/subSchemas.json#/definitions/refToInteger"
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.base-URI-change.base-URI-change-ref-valid" {
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
test "refRemote.base-URI-change.base-URI-change-ref-invalid" {
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
test "refRemote.base-URI-change---change-folder.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/scope_change_defs1.json",
        \\     "type": "object",
        \\     "properties": {
        \\         "list": {
        \\             "$ref": "#/definitions/baz"
        \\         }
        \\     },
        \\     "definitions": {
        \\         "baz": {
        \\             "id": "baseUriChangeFolder/",
        \\             "type": "array",
        \\             "items": {
        \\                 "$ref": "folderInteger.json"
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "list": [
        \\         1
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.base-URI-change---change-folder.string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/scope_change_defs1.json",
        \\     "type": "object",
        \\     "properties": {
        \\         "list": {
        \\             "$ref": "#/definitions/baz"
        \\         }
        \\     },
        \\     "definitions": {
        \\         "baz": {
        \\             "id": "baseUriChangeFolder/",
        \\             "type": "array",
        \\             "items": {
        \\                 "$ref": "folderInteger.json"
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "list": [
        \\         "a"
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.base-URI-change---change-folder-in-subschema.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/scope_change_defs2.json",
        \\     "type": "object",
        \\     "properties": {
        \\         "list": {
        \\             "$ref": "#/definitions/baz/definitions/bar"
        \\         }
        \\     },
        \\     "definitions": {
        \\         "baz": {
        \\             "id": "baseUriChangeFolderInSubschema/",
        \\             "definitions": {
        \\                 "bar": {
        \\                     "type": "array",
        \\                     "items": {
        \\                         "$ref": "folderInteger.json"
        \\                     }
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "list": [
        \\         1
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.base-URI-change---change-folder-in-subschema.string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/scope_change_defs2.json",
        \\     "type": "object",
        \\     "properties": {
        \\         "list": {
        \\             "$ref": "#/definitions/baz/definitions/bar"
        \\         }
        \\     },
        \\     "definitions": {
        \\         "baz": {
        \\             "id": "baseUriChangeFolderInSubschema/",
        \\             "definitions": {
        \\                 "bar": {
        \\                     "type": "array",
        \\                     "items": {
        \\                         "$ref": "folderInteger.json"
        \\                     }
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "list": [
        \\         "a"
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.root-ref-in-remote-ref.string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/object",
        \\     "type": "object",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "draft4/name.json#/definitions/orNull"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "name": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.root-ref-in-remote-ref.null-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/object",
        \\     "type": "object",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "draft4/name.json#/definitions/orNull"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "name": null
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.root-ref-in-remote-ref.object-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/object",
        \\     "type": "object",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "draft4/name.json#/definitions/orNull"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "name": {
        \\         "name": null
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.Location-independent-identifier-in-remote-ref.integer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://localhost:1234/draft4/locationIndependentIdentifier.json#/definitions/refToInteger"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.Location-independent-identifier-in-remote-ref.string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://localhost:1234/draft4/locationIndependentIdentifier.json#/definitions/refToInteger"
        \\ }
    );

    const case =
        \\ "foo"
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
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "$ref": "#/definitions/int"
        \\                 }
        \\             }
        \\         },
        \\         {
        \\             "additionalProperties": {
        \\                 "$ref": "#/definitions/int"
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
test "infinite-loop-detection.evaluating-the-same-schema-location-against-the-same-data-location-twice-is-not-a-sign-of-an-infinite-loop.failing-case" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "int": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "$ref": "#/definitions/int"
        \\                 }
        \\             }
        \\         },
        \\         {
        \\             "additionalProperties": {
        \\                 "$ref": "#/definitions/int"
        \\             }
        \\         }
        \\     ]
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
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/definitions/c"
        \\         }
        \\     ]
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
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/definitions/c"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.ref-overrides-any-sibling-keywords.ref-valid" {
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
test "ref.ref-overrides-any-sibling-keywords.ref-valid,-maxItems-ignored" {
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
        \\     "allOf": [
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
        \\     "allOf": [
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
        \\     "$ref": "http://json-schema.org/draft-04/schema#"
        \\ }
    );

    const case =
        \\ {
        \\     "minLength": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.remote-ref,-containing-refs-itself.remote-ref-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://json-schema.org/draft-04/schema#"
        \\ }
    );

    const case =
        \\ {
        \\     "minLength": -1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.property-named-$ref-that-is-not-a-reference.property-named-$ref-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "$ref": {
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
test "ref.property-named-$ref-that-is-not-a-reference.property-named-$ref-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "$ref": {
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
test "ref.Recursive-references-between-schemas.valid-tree" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/tree",
        \\     "description": "tree of nodes",
        \\     "type": "object",
        \\     "properties": {
        \\         "meta": {
        \\             "type": "string"
        \\         },
        \\         "nodes": {
        \\             "type": "array",
        \\             "items": {
        \\                 "$ref": "node"
        \\             }
        \\         }
        \\     },
        \\     "required": [
        \\         "meta",
        \\         "nodes"
        \\     ],
        \\     "definitions": {
        \\         "node": {
        \\             "id": "http://localhost:1234/node",
        \\             "description": "node",
        \\             "type": "object",
        \\             "properties": {
        \\                 "value": {
        \\                     "type": "number"
        \\                 },
        \\                 "subtree": {
        \\                     "$ref": "tree"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "value"
        \\             ]
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "meta": "root",
        \\     "nodes": [
        \\         {
        \\             "value": 1,
        \\             "subtree": {
        \\                 "meta": "child",
        \\                 "nodes": [
        \\                     {
        \\                         "value": 1.1
        \\                     },
        \\                     {
        \\                         "value": 1.2
        \\                     }
        \\                 ]
        \\             }
        \\         },
        \\         {
        \\             "value": 2,
        \\             "subtree": {
        \\                 "meta": "child",
        \\                 "nodes": [
        \\                     {
        \\                         "value": 2.1
        \\                     },
        \\                     {
        \\                         "value": 2.2
        \\                     }
        \\                 ]
        \\             }
        \\         }
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.Recursive-references-between-schemas.invalid-tree" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/tree",
        \\     "description": "tree of nodes",
        \\     "type": "object",
        \\     "properties": {
        \\         "meta": {
        \\             "type": "string"
        \\         },
        \\         "nodes": {
        \\             "type": "array",
        \\             "items": {
        \\                 "$ref": "node"
        \\             }
        \\         }
        \\     },
        \\     "required": [
        \\         "meta",
        \\         "nodes"
        \\     ],
        \\     "definitions": {
        \\         "node": {
        \\             "id": "http://localhost:1234/node",
        \\             "description": "node",
        \\             "type": "object",
        \\             "properties": {
        \\                 "value": {
        \\                     "type": "number"
        \\                 },
        \\                 "subtree": {
        \\                     "$ref": "tree"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "value"
        \\             ]
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "meta": "root",
        \\     "nodes": [
        \\         {
        \\             "value": 1,
        \\             "subtree": {
        \\                 "meta": "child",
        \\                 "nodes": [
        \\                     {
        \\                         "value": "string is invalid"
        \\                     },
        \\                     {
        \\                         "value": 1.2
        \\                     }
        \\                 ]
        \\             }
        \\         },
        \\         {
        \\             "value": 2,
        \\             "subtree": {
        \\                 "meta": "child",
        \\                 "nodes": [
        \\                     {
        \\                         "value": 2.1
        \\                     },
        \\                     {
        \\                         "value": 2.2
        \\                     }
        \\                 ]
        \\             }
        \\         }
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.refs-with-quote.object-with-numbers-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo\"bar": {
        \\             "$ref": "#/definitions/foo%22bar"
        \\         }
        \\     },
        \\     "definitions": {
        \\         "foo\"bar": {
        \\             "type": "number"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo\"bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.refs-with-quote.object-with-strings-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo\"bar": {
        \\             "$ref": "#/definitions/foo%22bar"
        \\         }
        \\     },
        \\     "definitions": {
        \\         "foo\"bar": {
        \\             "type": "number"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo\"bar": "1"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.Location-independent-identifier.match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "$ref": "#foo"
        \\         }
        \\     ],
        \\     "definitions": {
        \\         "A": {
        \\             "id": "#foo",
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.Location-independent-identifier.mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "$ref": "#foo"
        \\         }
        \\     ],
        \\     "definitions": {
        \\         "A": {
        \\             "id": "#foo",
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.Location-independent-identifier-with-base-URI-change-in-subschema.match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/root",
        \\     "allOf": [
        \\         {
        \\             "$ref": "http://localhost:1234/nested.json#foo"
        \\         }
        \\     ],
        \\     "definitions": {
        \\         "A": {
        \\             "id": "nested.json",
        \\             "definitions": {
        \\                 "B": {
        \\                     "id": "#foo",
        \\                     "type": "integer"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.Location-independent-identifier-with-base-URI-change-in-subschema.mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://localhost:1234/root",
        \\     "allOf": [
        \\         {
        \\             "$ref": "http://localhost:1234/nested.json#foo"
        \\         }
        \\     ],
        \\     "definitions": {
        \\         "A": {
        \\             "id": "nested.json",
        \\             "definitions": {
        \\                 "B": {
        \\                     "id": "#foo",
        \\                     "type": "integer"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ "a"
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
test "ref.id-must-be-resolved-against-nearest-parent,-not-just-immediate-parent.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://example.com/a.json",
        \\     "definitions": {
        \\         "x": {
        \\             "id": "http://example.com/b/c.json",
        \\             "not": {
        \\                 "definitions": {
        \\                     "y": {
        \\                         "id": "d.json",
        \\                         "type": "number"
        \\                     }
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "http://example.com/b/d.json"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.id-must-be-resolved-against-nearest-parent,-not-just-immediate-parent.non-number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "http://example.com/a.json",
        \\     "definitions": {
        \\         "x": {
        \\             "id": "http://example.com/b/c.json",
        \\             "not": {
        \\                 "definitions": {
        \\                     "y": {
        \\                         "id": "d.json",
        \\                         "type": "number"
        \\                     }
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "http://example.com/b/d.json"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.id-with-file-URI-still-resolves-pointers---*nix.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "file:///folder/file.json",
        \\     "definitions": {
        \\         "foo": {
        \\             "type": "number"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/definitions/foo"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.id-with-file-URI-still-resolves-pointers---*nix.non-number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "file:///folder/file.json",
        \\     "definitions": {
        \\         "foo": {
        \\             "type": "number"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/definitions/foo"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.id-with-file-URI-still-resolves-pointers---windows.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "file:///c:/folder/file.json",
        \\     "definitions": {
        \\         "foo": {
        \\             "type": "number"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/definitions/foo"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.id-with-file-URI-still-resolves-pointers---windows.non-number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "id": "file:///c:/folder/file.json",
        \\     "definitions": {
        \\         "foo": {
        \\             "type": "number"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/definitions/foo"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.empty-tokens-in-$ref-json-pointer.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "": {
        \\             "definitions": {
        \\                 "": {
        \\                     "type": "number"
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/definitions//definitions/"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.empty-tokens-in-$ref-json-pointer.non-number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "": {
        \\             "definitions": {
        \\                 "": {
        \\                     "type": "number"
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/definitions//definitions/"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
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
test "additionalProperties.additionalProperties-does-not-look-in-applicators.properties-defined-in-allOf-are-not-examined" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
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
test "format.ipv4-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ipv4"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv4-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ipv4"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv4-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ipv4"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv4-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ipv4"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv4-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ipv4"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv4-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "ipv4"
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
test "format.hostname-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "hostname"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.hostname-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "hostname"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.hostname-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "hostname"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.hostname-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "hostname"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.hostname-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "hostname"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.hostname-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "format": "hostname"
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
test "not.not.allowed" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.not.disallowed" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.not-multiple-types.valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {
        \\         "type": [
        \\             "integer",
        \\             "boolean"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.not-multiple-types.mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {
        \\         "type": [
        \\             "integer",
        \\             "boolean"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.not-multiple-types.other-mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {
        \\         "type": [
        \\             "integer",
        \\             "boolean"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.not-more-complex-schema.match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {
        \\         "type": "object",
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.not-more-complex-schema.other-match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {
        \\         "type": "object",
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
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
test "not.not-more-complex-schema.mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {
        \\         "type": "object",
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbidden-property.property-present" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "not": {}
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
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbidden-property.property-absent" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {
        \\             "not": {}
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 1,
        \\     "baz": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.forbid-everything-with-empty-schema.number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {}
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-empty-schema.string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {}
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-empty-schema.boolean-true-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {}
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-empty-schema.boolean-false-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {}
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-empty-schema.null-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {}
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-empty-schema.object-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {}
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-empty-schema.empty-object-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {}
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-empty-schema.array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {}
        \\ }
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-empty-schema.empty-array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {}
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.double-negation.any-value-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "not": {
        \\         "not": {}
        \\     }
        \\ }
    );

    const case =
        \\ "foo"
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
test "definitions.validate-definition-against-metaschema.valid-definition-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://json-schema.org/draft-04/schema#"
        \\ }
    );

    const case =
        \\ {
        \\     "definitions": {
        \\         "foo": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "definitions.validate-definition-against-metaschema.invalid-definition-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://json-schema.org/draft-04/schema#"
        \\ }
    );

    const case =
        \\ {
        \\     "definitions": {
        \\         "foo": {
        \\             "type": 1
        \\         }
        \\     }
        \\ }
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
test "patternProperties.patternProperties-validates-properties-matching-a-regex.ignores-strings" {
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
        \\ ""
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
test "minimum.minimum-validation-(explicit-false-exclusivity).above-the-minimum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": 1.1,
        \\     "exclusiveMinimum": false
        \\ }
    );

    const case =
        \\ 2.6
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minimum.minimum-validation-(explicit-false-exclusivity).boundary-point-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": 1.1,
        \\     "exclusiveMinimum": false
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minimum.minimum-validation-(explicit-false-exclusivity).below-the-minimum-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": 1.1,
        \\     "exclusiveMinimum": false
        \\ }
    );

    const case =
        \\ 0.6
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minimum.minimum-validation-(explicit-false-exclusivity).ignores-non-numbers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minimum": 1.1,
        \\     "exclusiveMinimum": false
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
test "type.string-type-matches-strings.an-empty-string-is-still-a-string" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string"
        \\ }
    );

    const case =
        \\ ""
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
test "type.boolean-type-matches-booleans.zero-is-not-a-boolean" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "boolean"
        \\ }
    );

    const case =
        \\ 0
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
test "type.boolean-type-matches-booleans.an-empty-string-is-not-a-boolean" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "boolean"
        \\ }
    );

    const case =
        \\ ""
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
test "type.boolean-type-matches-booleans.true-is-a-boolean" {
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
test "type.boolean-type-matches-booleans.false-is-a-boolean" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "boolean"
        \\ }
    );

    const case =
        \\ false
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
test "type.null-type-matches-only-the-null-object.zero-is-not-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "null"
        \\ }
    );

    const case =
        \\ 0
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
test "type.null-type-matches-only-the-null-object.an-empty-string-is-not-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "null"
        \\ }
    );

    const case =
        \\ ""
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
test "type.null-type-matches-only-the-null-object.true-is-not-null" {
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
test "type.null-type-matches-only-the-null-object.false-is-not-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "null"
        \\ }
    );

    const case =
        \\ false
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
test "type.type-as-array-with-one-item.string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "string"
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.type-as-array-with-one-item.number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "string"
        \\     ]
        \\ }
    );

    const case =
        \\ 123
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.type:-array-or-object.array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         "object"
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
test "type.type:-array-or-object.object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         "object"
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 123
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.type:-array-or-object.number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         "object"
        \\     ]
        \\ }
    );

    const case =
        \\ 123
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.type:-array-or-object.string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         "object"
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.type:-array-or-object.null-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         "object"
        \\     ]
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.type:-array,-object-or-null.array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         "object",
        \\         "null"
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
test "type.type:-array,-object-or-null.object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         "object",
        \\         "null"
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 123
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.type:-array,-object-or-null.null-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         "object",
        \\         "null"
        \\     ]
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.type:-array,-object-or-null.number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         "object",
        \\         "null"
        \\     ]
        \\ }
    );

    const case =
        \\ 123
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.type:-array,-object-or-null.string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": [
        \\         "array",
        \\         "object",
        \\         "null"
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
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
test "properties.properties-with-escaped-characters.object-with-all-numbers-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo\nbar": {
        \\             "type": "number"
        \\         },
        \\         "foo\"bar": {
        \\             "type": "number"
        \\         },
        \\         "foo\\bar": {
        \\             "type": "number"
        \\         },
        \\         "foo\rbar": {
        \\             "type": "number"
        \\         },
        \\         "foo\tbar": {
        \\             "type": "number"
        \\         },
        \\         "foo\fbar": {
        \\             "type": "number"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo\nbar": 1,
        \\     "foo\"bar": 1,
        \\     "foo\\bar": 1,
        \\     "foo\rbar": 1,
        \\     "foo\tbar": 1,
        \\     "foo\fbar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.properties-with-escaped-characters.object-with-strings-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo\nbar": {
        \\             "type": "number"
        \\         },
        \\         "foo\"bar": {
        \\             "type": "number"
        \\         },
        \\         "foo\\bar": {
        \\             "type": "number"
        \\         },
        \\         "foo\rbar": {
        \\             "type": "number"
        \\         },
        \\         "foo\tbar": {
        \\             "type": "number"
        \\         },
        \\         "foo\fbar": {
        \\             "type": "number"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo\nbar": "1",
        \\     "foo\"bar": "1",
        \\     "foo\\bar": "1",
        \\     "foo\rbar": "1",
        \\     "foo\tbar": "1",
        \\     "foo\fbar": "1"
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
test "properties.properties-whose-names-are-Javascript-object-property-names.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "__proto__": {
        \\             "type": "number"
        \\         },
        \\         "toString": {
        \\             "properties": {
        \\                 "length": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         },
        \\         "constructor": {
        \\             "type": "number"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.properties-whose-names-are-Javascript-object-property-names.ignores-other-non-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "__proto__": {
        \\             "type": "number"
        \\         },
        \\         "toString": {
        \\             "properties": {
        \\                 "length": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         },
        \\         "constructor": {
        \\             "type": "number"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.properties-whose-names-are-Javascript-object-property-names.none-of-the-properties-mentioned" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "__proto__": {
        \\             "type": "number"
        \\         },
        \\         "toString": {
        \\             "properties": {
        \\                 "length": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         },
        \\         "constructor": {
        \\             "type": "number"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.properties-whose-names-are-Javascript-object-property-names.__proto__-not-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "__proto__": {
        \\             "type": "number"
        \\         },
        \\         "toString": {
        \\             "properties": {
        \\                 "length": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         },
        \\         "constructor": {
        \\             "type": "number"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "__proto__": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "properties.properties-whose-names-are-Javascript-object-property-names.toString-not-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "__proto__": {
        \\             "type": "number"
        \\         },
        \\         "toString": {
        \\             "properties": {
        \\                 "length": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         },
        \\         "constructor": {
        \\             "type": "number"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "toString": {
        \\         "length": 37
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "properties.properties-whose-names-are-Javascript-object-property-names.constructor-not-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "__proto__": {
        \\             "type": "number"
        \\         },
        \\         "toString": {
        \\             "properties": {
        \\                 "length": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         },
        \\         "constructor": {
        \\             "type": "number"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "constructor": {
        \\         "length": 37
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "properties.properties-whose-names-are-Javascript-object-property-names.all-present-and-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "__proto__": {
        \\             "type": "number"
        \\         },
        \\         "toString": {
        \\             "properties": {
        \\                 "length": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         },
        \\         "constructor": {
        \\             "type": "number"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "__proto__": 12,
        \\     "toString": {
        \\         "length": "foo"
        \\     },
        \\     "constructor": 37
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
test "items.a-schema-given-for-items.JavaScript-pseudo-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "0": "invalid",
        \\     "length": 1
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
test "items.an-array-of-schemas-for-items.incomplete-array-of-items" {
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
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.an-array-of-schemas-for-items.array-with-additional-items" {
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
        \\     "foo",
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.an-array-of-schemas-for-items.empty-array" {
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
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.an-array-of-schemas-for-items.JavaScript-pseudo-array-is-valid" {
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
        \\ {
        \\     "0": "invalid",
        \\     "1": "valid",
        \\     "length": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.items-and-subitems.valid-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "item": {
        \\             "type": "array",
        \\             "additionalItems": false,
        \\             "items": [
        \\                 {
        \\                     "$ref": "#/definitions/sub-item"
        \\                 },
        \\                 {
        \\                     "$ref": "#/definitions/sub-item"
        \\                 }
        \\             ]
        \\         },
        \\         "sub-item": {
        \\             "type": "object",
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     },
        \\     "type": "array",
        \\     "additionalItems": false,
        \\     "items": [
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         },
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         },
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ],
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ],
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.items-and-subitems.too-many-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "item": {
        \\             "type": "array",
        \\             "additionalItems": false,
        \\             "items": [
        \\                 {
        \\                     "$ref": "#/definitions/sub-item"
        \\                 },
        \\                 {
        \\                     "$ref": "#/definitions/sub-item"
        \\                 }
        \\             ]
        \\         },
        \\         "sub-item": {
        \\             "type": "object",
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     },
        \\     "type": "array",
        \\     "additionalItems": false,
        \\     "items": [
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         },
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         },
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ],
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ],
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ],
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "items.items-and-subitems.too-many-sub-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "item": {
        \\             "type": "array",
        \\             "additionalItems": false,
        \\             "items": [
        \\                 {
        \\                     "$ref": "#/definitions/sub-item"
        \\                 },
        \\                 {
        \\                     "$ref": "#/definitions/sub-item"
        \\                 }
        \\             ]
        \\         },
        \\         "sub-item": {
        \\             "type": "object",
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     },
        \\     "type": "array",
        \\     "additionalItems": false,
        \\     "items": [
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         },
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         },
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ],
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ],
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "items.items-and-subitems.wrong-item" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "item": {
        \\             "type": "array",
        \\             "additionalItems": false,
        \\             "items": [
        \\                 {
        \\                     "$ref": "#/definitions/sub-item"
        \\                 },
        \\                 {
        \\                     "$ref": "#/definitions/sub-item"
        \\                 }
        \\             ]
        \\         },
        \\         "sub-item": {
        \\             "type": "object",
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     },
        \\     "type": "array",
        \\     "additionalItems": false,
        \\     "items": [
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         },
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         },
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "foo": null
        \\     },
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ],
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "items.items-and-subitems.wrong-sub-item" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "item": {
        \\             "type": "array",
        \\             "additionalItems": false,
        \\             "items": [
        \\                 {
        \\                     "$ref": "#/definitions/sub-item"
        \\                 },
        \\                 {
        \\                     "$ref": "#/definitions/sub-item"
        \\                 }
        \\             ]
        \\         },
        \\         "sub-item": {
        \\             "type": "object",
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     },
        \\     "type": "array",
        \\     "additionalItems": false,
        \\     "items": [
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         },
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         },
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         {},
        \\         {
        \\             "foo": null
        \\         }
        \\     ],
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ],
        \\     [
        \\         {
        \\             "foo": null
        \\         },
        \\         {
        \\             "foo": null
        \\         }
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "items.items-and-subitems.fewer-items-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "definitions": {
        \\         "item": {
        \\             "type": "array",
        \\             "additionalItems": false,
        \\             "items": [
        \\                 {
        \\                     "$ref": "#/definitions/sub-item"
        \\                 },
        \\                 {
        \\                     "$ref": "#/definitions/sub-item"
        \\                 }
        \\             ]
        \\         },
        \\         "sub-item": {
        \\             "type": "object",
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     },
        \\     "type": "array",
        \\     "additionalItems": false,
        \\     "items": [
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         },
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         },
        \\         {
        \\             "$ref": "#/definitions/item"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         {
        \\             "foo": null
        \\         }
        \\     ],
        \\     [
        \\         {
        \\             "foo": null
        \\         }
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.nested-items.valid-nested-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "array",
        \\     "items": {
        \\         "type": "array",
        \\         "items": {
        \\             "type": "array",
        \\             "items": {
        \\                 "type": "array",
        \\                 "items": {
        \\                     "type": "number"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         [
        \\             [
        \\                 1
        \\             ]
        \\         ],
        \\         [
        \\             [
        \\                 2
        \\             ],
        \\             [
        \\                 3
        \\             ]
        \\         ]
        \\     ],
        \\     [
        \\         [
        \\             [
        \\                 4
        \\             ],
        \\             [
        \\                 5
        \\             ],
        \\             [
        \\                 6
        \\             ]
        \\         ]
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.nested-items.nested-array-with-invalid-type" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "array",
        \\     "items": {
        \\         "type": "array",
        \\         "items": {
        \\             "type": "array",
        \\             "items": {
        \\                 "type": "array",
        \\                 "items": {
        \\                     "type": "number"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         [
        \\             [
        \\                 "1"
        \\             ]
        \\         ],
        \\         [
        \\             [
        \\                 2
        \\             ],
        \\             [
        \\                 3
        \\             ]
        \\         ]
        \\     ],
        \\     [
        \\         [
        \\             [
        \\                 4
        \\             ],
        \\             [
        \\                 5
        \\             ],
        \\             [
        \\                 6
        \\             ]
        \\         ]
        \\     ]
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "items.nested-items.not-deep-enough" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "array",
        \\     "items": {
        \\         "type": "array",
        \\         "items": {
        \\             "type": "array",
        \\             "items": {
        \\                 "type": "array",
        \\                 "items": {
        \\                     "type": "number"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     [
        \\         [
        \\             1
        \\         ],
        \\         [
        \\             2
        \\         ],
        \\         [
        \\             3
        \\         ]
        \\     ],
        \\     [
        \\         [
        \\             4
        \\         ],
        \\         [
        \\             5
        \\         ],
        \\         [
        \\             6
        \\         ]
        \\     ]
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
test "oneOf.oneOf.first-oneOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "oneOf.oneOf.second-oneOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 2.5
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "oneOf.oneOf.both-oneOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 3
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "oneOf.oneOf.neither-oneOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1.5
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "oneOf.oneOf-with-base-schema.mismatch-base-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string",
        \\     "oneOf": [
        \\         {
        \\             "minLength": 2
        \\         },
        \\         {
        \\             "maxLength": 4
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 3
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "oneOf.oneOf-with-base-schema.one-oneOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string",
        \\     "oneOf": [
        \\         {
        \\             "minLength": 2
        \\         },
        \\         {
        \\             "maxLength": 4
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "foobar"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "oneOf.oneOf-with-base-schema.both-oneOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string",
        \\     "oneOf": [
        \\         {
        \\             "minLength": 2
        \\         },
        \\         {
        \\             "maxLength": 4
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "oneOf.oneOf-complex-types.first-oneOf-valid-(complex)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "oneOf.oneOf-complex-types.second-oneOf-valid-(complex)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "oneOf.oneOf-complex-types.both-oneOf-valid-(complex)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "baz",
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "oneOf.oneOf-complex-types.neither-oneOf-valid-(complex)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
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
test "oneOf.oneOf-with-empty-schema.one-valid---valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "type": "number"
        \\         },
        \\         {}
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "oneOf.oneOf-with-empty-schema.both-valid---invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "type": "number"
        \\         },
        \\         {}
        \\     ]
        \\ }
    );

    const case =
        \\ 123
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "oneOf.oneOf-with-required.both-invalid---invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object",
        \\     "oneOf": [
        \\         {
        \\             "required": [
        \\                 "foo",
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "required": [
        \\                 "foo",
        \\                 "baz"
        \\             ]
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
test "oneOf.oneOf-with-required.first-valid---valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object",
        \\     "oneOf": [
        \\         {
        \\             "required": [
        \\                 "foo",
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "required": [
        \\                 "foo",
        \\                 "baz"
        \\             ]
        \\         }
        \\     ]
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
test "oneOf.oneOf-with-required.second-valid---valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object",
        \\     "oneOf": [
        \\         {
        \\             "required": [
        \\                 "foo",
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "required": [
        \\                 "foo",
        \\                 "baz"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "baz": 3
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "oneOf.oneOf-with-required.both-valid---invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "object",
        \\     "oneOf": [
        \\         {
        \\             "required": [
        \\                 "foo",
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "required": [
        \\                 "foo",
        \\                 "baz"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "baz": 3
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "oneOf.oneOf-with-missing-optional-property.first-oneOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {},
        \\                 "baz": {}
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {}
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 8
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "oneOf.oneOf-with-missing-optional-property.second-oneOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {},
        \\                 "baz": {}
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {}
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "oneOf.oneOf-with-missing-optional-property.both-oneOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {},
        \\                 "baz": {}
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {}
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": 8
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "oneOf.oneOf-with-missing-optional-property.neither-oneOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {},
        \\                 "baz": {}
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {}
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "baz": "quux"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "oneOf.nested-oneOf,-to-check-validation-semantics.null-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "oneOf": [
        \\                 {
        \\                     "type": "null"
        \\                 }
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "oneOf.nested-oneOf,-to-check-validation-semantics.anything-non-null-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "oneOf": [
        \\         {
        \\             "oneOf": [
        \\                 {
        \\                     "type": "null"
        \\                 }
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 123
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "multipleOf.by-int.int-by-int" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "multipleOf": 2
        \\ }
    );

    const case =
        \\ 10
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "multipleOf.by-int.int-by-int-fail" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "multipleOf": 2
        \\ }
    );

    const case =
        \\ 7
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "multipleOf.by-int.ignores-non-numbers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "multipleOf": 2
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "multipleOf.by-number.zero-is-multiple-of-anything" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "multipleOf": 1.5
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "multipleOf.by-number.4.5-is-multiple-of-1.5" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "multipleOf": 1.5
        \\ }
    );

    const case =
        \\ 4.5
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "multipleOf.by-number.35-is-not-multiple-of-1.5" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "multipleOf": 1.5
        \\ }
    );

    const case =
        \\ 35
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "multipleOf.by-small-number.0.0075-is-multiple-of-0.0001" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "multipleOf": 0.0001
        \\ }
    );

    const case =
        \\ 0.0075
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "multipleOf.by-small-number.0.00751-is-not-multiple-of-0.0001" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "multipleOf": 0.0001
        \\ }
    );

    const case =
        \\ 0.00751
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "multipleOf.float-division-=-inf.invalid,-but-naive-implementations-may-raise-an-overflow-error" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "integer",
        \\     "multipleOf": 0.123456789
        \\ }
    );

    const case =
        \\ 100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "multipleOf.small-multiple-of-large-integer.any-integer-is-a-multiple-of-1e-8" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "integer",
        \\     "multipleOf": 0.00000001
        \\ }
    );

    const case =
        \\ 12391239123
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.dependencies.neither" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": [
        \\             "foo"
        \\         ]
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
        \\         "bar": [
        \\             "foo"
        \\         ]
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
        \\         "bar": [
        \\             "foo"
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
test "dependencies.dependencies.missing-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "bar": [
        \\             "foo"
        \\         ]
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
        \\         "bar": [
        \\             "foo"
        \\         ]
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
        \\         "bar": [
        \\             "foo"
        \\         ]
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
        \\         "bar": [
        \\             "foo"
        \\         ]
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
test "dependencies.dependencies-with-escaped-characters.valid-object-1" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
        \\         "foo\tbar": {
        \\             "minProperties": 4
        \\         },
        \\         "foo'bar": {
        \\             "required": [
        \\                 "foo\"bar"
        \\             ]
        \\         },
        \\         "foo\"bar": [
        \\             "foo'bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo\nbar": 1,
        \\     "foo\rbar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.dependencies-with-escaped-characters.valid-object-2" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
        \\         "foo\tbar": {
        \\             "minProperties": 4
        \\         },
        \\         "foo'bar": {
        \\             "required": [
        \\                 "foo\"bar"
        \\             ]
        \\         },
        \\         "foo\"bar": [
        \\             "foo'bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo\tbar": 1,
        \\     "a": 2,
        \\     "b": 3,
        \\     "c": 4
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.dependencies-with-escaped-characters.valid-object-3" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
        \\         "foo\tbar": {
        \\             "minProperties": 4
        \\         },
        \\         "foo'bar": {
        \\             "required": [
        \\                 "foo\"bar"
        \\             ]
        \\         },
        \\         "foo\"bar": [
        \\             "foo'bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo'bar": 1,
        \\     "foo\"bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.dependencies-with-escaped-characters.invalid-object-1" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
        \\         "foo\tbar": {
        \\             "minProperties": 4
        \\         },
        \\         "foo'bar": {
        \\             "required": [
        \\                 "foo\"bar"
        \\             ]
        \\         },
        \\         "foo\"bar": [
        \\             "foo'bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo\nbar": 1,
        \\     "foo": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependencies.dependencies-with-escaped-characters.invalid-object-2" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
        \\         "foo\tbar": {
        \\             "minProperties": 4
        \\         },
        \\         "foo'bar": {
        \\             "required": [
        \\                 "foo\"bar"
        \\             ]
        \\         },
        \\         "foo\"bar": [
        \\             "foo'bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo\tbar": 1,
        \\     "a": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependencies.dependencies-with-escaped-characters.invalid-object-3" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
        \\         "foo\tbar": {
        \\             "minProperties": 4
        \\         },
        \\         "foo'bar": {
        \\             "required": [
        \\                 "foo\"bar"
        \\             ]
        \\         },
        \\         "foo\"bar": [
        \\             "foo'bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo'bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependencies.dependencies-with-escaped-characters.invalid-object-4" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "dependencies": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
        \\         "foo\tbar": {
        \\             "minProperties": 4
        \\         },
        \\         "foo'bar": {
        \\             "required": [
        \\                 "foo\"bar"
        \\             ]
        \\         },
        \\         "foo\"bar": [
        \\             "foo'bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo\"bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependencies.dependent-subschema-incompatible-with-root.matches-root" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {}
        \\     },
        \\     "dependencies": {
        \\         "foo": {
        \\             "properties": {
        \\                 "bar": {}
        \\             },
        \\             "additionalProperties": false
        \\         }
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
test "dependencies.dependent-subschema-incompatible-with-root.matches-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {}
        \\     },
        \\     "dependencies": {
        \\         "foo": {
        \\             "properties": {
        \\                 "bar": {}
        \\             },
        \\             "additionalProperties": false
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependencies.dependent-subschema-incompatible-with-root.matches-both" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {}
        \\     },
        \\     "dependencies": {
        \\         "foo": {
        \\             "properties": {
        \\                 "bar": {}
        \\             },
        \\             "additionalProperties": false
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
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependencies.dependent-subschema-incompatible-with-root.no-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {}
        \\     },
        \\     "dependencies": {
        \\         "foo": {
        \\             "properties": {
        \\                 "bar": {}
        \\             },
        \\             "additionalProperties": false
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "baz": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "required.required-validation.present-required-property-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "required": [
        \\         "foo"
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
test "required.required-validation.non-present-required-property-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "required": [
        \\         "foo"
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "required.required-validation.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "required": [
        \\         "foo"
        \\     ]
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "required.required-validation.ignores-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "required": [
        \\         "foo"
        \\     ]
        \\ }
    );

    const case =
        \\ ""
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "required.required-validation.ignores-other-non-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "required": [
        \\         "foo"
        \\     ]
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
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
test "required.required-with-escaped-characters.object-with-all-properties-present-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "required": [
        \\         "foo\nbar",
        \\         "foo\"bar",
        \\         "foo\\bar",
        \\         "foo\rbar",
        \\         "foo\tbar",
        \\         "foo\fbar"
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo\nbar": 1,
        \\     "foo\"bar": 1,
        \\     "foo\\bar": 1,
        \\     "foo\rbar": 1,
        \\     "foo\tbar": 1,
        \\     "foo\fbar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "required.required-with-escaped-characters.object-with-some-properties-missing-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "required": [
        \\         "foo\nbar",
        \\         "foo\"bar",
        \\         "foo\\bar",
        \\         "foo\rbar",
        \\         "foo\tbar",
        \\         "foo\fbar"
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo\nbar": "1",
        \\     "foo\"bar": "1"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.ignores-other-non-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.none-of-the-properties-mentioned" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.__proto__-present" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "__proto__": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.toString-present" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "toString": {
        \\         "length": 37
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.constructor-present" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "constructor": {
        \\         "length": 37
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.all-present" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "__proto__": 12,
        \\     "toString": {
        \\         "length": "foo"
        \\     },
        \\     "constructor": 37
        \\ }
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
test "uniqueItems.uniqueItems-validation.false-is-not-equal-to-zero" {
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
test "uniqueItems.uniqueItems-validation.true-is-not-equal-to-one" {
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
test "uniqueItems.uniqueItems-validation.property-order-of-array-of-objects-is-ignored" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "foo": "bar",
        \\         "bar": "foo"
        \\     },
        \\     {
        \\         "bar": "foo",
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
        \\     1,
        \\     "{}"
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
test "uniqueItems.uniqueItems-validation.different-objects-are-unique" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "a": 1,
        \\         "b": 2
        \\     },
        \\     {
        \\         "a": 2,
        \\         "b": 1
        \\     }
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "uniqueItems.uniqueItems-validation.objects-are-non-unique-despite-key-order" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "uniqueItems": true
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "a": 1,
        \\         "b": 2
        \\     },
        \\     {
        \\         "b": 2,
        \\         "a": 1
        \\     }
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
test "uniqueItems.uniqueItems=false-validation.false-is-not-equal-to-zero" {
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
test "uniqueItems.uniqueItems=false-validation.true-is-not-equal-to-one" {
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
test "maxProperties.maxProperties-validation.shorter-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxProperties": 2
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxProperties.maxProperties-validation.exact-length-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxProperties": 2
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
test "maxProperties.maxProperties-validation.too-long-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxProperties": 2
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "baz": 3
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "maxProperties.maxProperties-validation.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxProperties": 2
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
test "maxProperties.maxProperties-validation.ignores-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxProperties": 2
        \\ }
    );

    const case =
        \\ "foobar"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxProperties.maxProperties-validation.ignores-other-non-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxProperties": 2
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxProperties.maxProperties-=-0-means-the-object-is-empty.no-properties-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxProperties": 0
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxProperties.maxProperties-=-0-means-the-object-is-empty.one-property-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "maxProperties": 0
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf.allOf" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
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
test "allOf.allOf.mismatch-second" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf.mismatch-first" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
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
test "allOf.allOf.wrong-type" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
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
test "allOf.allOf-with-base-schema.valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "required": [
        \\         "bar"
        \\     ],
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "type": "null"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "baz"
        \\             ]
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
test "allOf.allOf-with-base-schema.mismatch-base-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "required": [
        \\         "bar"
        \\     ],
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "type": "null"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "baz"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "quux",
        \\     "baz": null
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf-with-base-schema.mismatch-first-allOf" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "required": [
        \\         "bar"
        \\     ],
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "type": "null"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "baz"
        \\             ]
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
test "allOf.allOf-with-base-schema.mismatch-second-allOf" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "required": [
        \\         "bar"
        \\     ],
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "type": "null"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "baz"
        \\             ]
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
test "allOf.allOf-with-base-schema.mismatch-both" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "properties": {
        \\         "bar": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "required": [
        \\         "bar"
        \\     ],
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "type": "null"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "baz"
        \\             ]
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
test "allOf.allOf-simple-types.valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "maximum": 30
        \\         },
        \\         {
        \\             "minimum": 20
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 25
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "allOf.allOf-simple-types.mismatch-one" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "maximum": 30
        \\         },
        \\         {
        \\             "minimum": 20
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 35
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf-with-one-empty-schema.any-data-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {}
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "allOf.allOf-with-two-empty-schemas.any-data-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {},
        \\         {}
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "allOf.allOf-with-the-first-empty-schema.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {},
        \\         {
        \\             "type": "number"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "allOf.allOf-with-the-first-empty-schema.string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {},
        \\         {
        \\             "type": "number"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf-with-the-last-empty-schema.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "type": "number"
        \\         },
        \\         {}
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "allOf.allOf-with-the-last-empty-schema.string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "type": "number"
        \\         },
        \\         {}
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.nested-allOf,-to-check-validation-semantics.null-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "allOf": [
        \\                 {
        \\                     "type": "null"
        \\                 }
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "allOf.nested-allOf,-to-check-validation-semantics.anything-non-null-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "allOf": [
        \\                 {
        \\                     "type": "null"
        \\                 }
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 123
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-false,-anyOf:-false,-oneOf:-false" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "multipleOf": 2
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "multipleOf": 3
        \\         }
        \\     ],
        \\     "oneOf": [
        \\         {
        \\             "multipleOf": 5
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-false,-anyOf:-false,-oneOf:-true" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "multipleOf": 2
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "multipleOf": 3
        \\         }
        \\     ],
        \\     "oneOf": [
        \\         {
        \\             "multipleOf": 5
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 5
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-false,-anyOf:-true,-oneOf:-false" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "multipleOf": 2
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "multipleOf": 3
        \\         }
        \\     ],
        \\     "oneOf": [
        \\         {
        \\             "multipleOf": 5
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 3
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-false,-anyOf:-true,-oneOf:-true" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "multipleOf": 2
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "multipleOf": 3
        \\         }
        \\     ],
        \\     "oneOf": [
        \\         {
        \\             "multipleOf": 5
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 15
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-true,-anyOf:-false,-oneOf:-false" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "multipleOf": 2
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "multipleOf": 3
        \\         }
        \\     ],
        \\     "oneOf": [
        \\         {
        \\             "multipleOf": 5
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 2
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-true,-anyOf:-false,-oneOf:-true" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "multipleOf": 2
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "multipleOf": 3
        \\         }
        \\     ],
        \\     "oneOf": [
        \\         {
        \\             "multipleOf": 5
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 10
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-true,-anyOf:-true,-oneOf:-false" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "multipleOf": 2
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "multipleOf": 3
        \\         }
        \\     ],
        \\     "oneOf": [
        \\         {
        \\             "multipleOf": 5
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 6
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-true,-anyOf:-true,-oneOf:-true" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "multipleOf": 2
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "multipleOf": 3
        \\         }
        \\     ],
        \\     "oneOf": [
        \\         {
        \\             "multipleOf": 5
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 30
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
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
test "minProperties.minProperties-validation.longer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minProperties": 1
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
test "minProperties.minProperties-validation.exact-length-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minProperties": 1
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minProperties.minProperties-validation.too-short-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minProperties": 1
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minProperties.minProperties-validation.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minProperties": 1
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minProperties.minProperties-validation.ignores-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minProperties": 1
        \\ }
    );

    const case =
        \\ ""
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minProperties.minProperties-validation.ignores-other-non-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "minProperties": 1
        \\ }
    );

    const case =
        \\ 12
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
test "enum.heterogeneous-enum-validation.valid-object-matches" {
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
        \\     "foo": 12
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.heterogeneous-enum-validation.extra-properties-in-object-is-invalid" {
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
        \\     "foo": 12,
        \\     "boo": 42
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
        \\             ]
        \\         }
        \\     },
        \\     "required": [
        \\         "bar"
        \\     ]
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
        \\             ]
        \\         }
        \\     },
        \\     "required": [
        \\         "bar"
        \\     ]
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
        \\             ]
        \\         }
        \\     },
        \\     "required": [
        \\         "bar"
        \\     ]
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
        \\             ]
        \\         }
        \\     },
        \\     "required": [
        \\         "bar"
        \\     ]
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
        \\             ]
        \\         }
        \\     },
        \\     "required": [
        \\         "bar"
        \\     ]
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
        \\             ]
        \\         }
        \\     },
        \\     "required": [
        \\         "bar"
        \\     ]
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-escaped-characters.member-1-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         "foo\nbar",
        \\         "foo\rbar"
        \\     ]
        \\ }
    );

    const case =
        \\ "foo\nbar"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enum-with-escaped-characters.member-2-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         "foo\nbar",
        \\         "foo\rbar"
        \\     ]
        \\ }
    );

    const case =
        \\ "foo\rbar"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enum-with-escaped-characters.another-string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         "foo\nbar",
        \\         "foo\rbar"
        \\     ]
        \\ }
    );

    const case =
        \\ "abc"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-false-does-not-match-0.false-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         false
        \\     ]
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enum-with-false-does-not-match-0.integer-zero-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         false
        \\     ]
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-false-does-not-match-0.float-zero-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         false
        \\     ]
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-[false]-does-not-match-[0].[false]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         [
        \\             false
        \\         ]
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enum-with-[false]-does-not-match-[0].[0]-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         [
        \\             false
        \\         ]
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     0
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-[false]-does-not-match-[0].[0.0]-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         [
        \\             false
        \\         ]
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     0
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-true-does-not-match-1.true-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         true
        \\     ]
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enum-with-true-does-not-match-1.integer-one-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         true
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-true-does-not-match-1.float-one-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         true
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-[true]-does-not-match-[1].[true]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         [
        \\             true
        \\         ]
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enum-with-[true]-does-not-match-[1].[1]-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         [
        \\             true
        \\         ]
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-[true]-does-not-match-[1].[1.0]-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         [
        \\             true
        \\         ]
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-0-does-not-match-false.false-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         0
        \\     ]
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-0-does-not-match-false.integer-zero-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         0
        \\     ]
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enum-with-0-does-not-match-false.float-zero-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         0
        \\     ]
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enum-with-[0]-does-not-match-[false].[false]-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         [
        \\             0
        \\         ]
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-[0]-does-not-match-[false].[0]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         [
        \\             0
        \\         ]
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     0
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enum-with-[0]-does-not-match-[false].[0.0]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         [
        \\             0
        \\         ]
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     0
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enum-with-1-does-not-match-true.true-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         1
        \\     ]
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-1-does-not-match-true.integer-one-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         1
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enum-with-1-does-not-match-true.float-one-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         1
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enum-with-[1]-does-not-match-[true].[true]-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         [
        \\             1
        \\         ]
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.enum-with-[1]-does-not-match-[true].[1]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         [
        \\             1
        \\         ]
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "enum.enum-with-[1]-does-not-match-[true].[1.0]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "enum": [
        \\         [
        \\             1
        \\         ]
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
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
        \\     "items": [
        \\         {}
        \\     ],
        \\     "additionalItems": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     null,
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
        \\     "items": [
        \\         {}
        \\     ],
        \\     "additionalItems": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     null,
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
test "additionalItems.additionalItems-does-not-look-in-applicators,-valid-case.items-defined-in-allOf-are-not-examined" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
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
test "additionalItems.additionalItems-does-not-look-in-applicators,-invalid-case.items-defined-in-allOf-are-not-examined" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "allOf": [
        \\         {
        \\             "items": [
        \\                 {
        \\                     "type": "integer"
        \\                 },
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "items": [
        \\         {
        \\             "type": "integer"
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
        \\     "hello"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "additionalItems.items-validation-adjusts-the-starting-index-for-additionalItems.valid-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "additionalItems": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "x",
        \\     2,
        \\     3
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalItems.items-validation-adjusts-the-starting-index-for-additionalItems.wrong-type-of-second-item" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "items": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "additionalItems": {
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "x",
        \\     "y"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
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
test "anyOf.anyOf.first-anyOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anyOf.anyOf.second-anyOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 2.5
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anyOf.anyOf.both-anyOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 3
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anyOf.anyOf.neither-anyOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 1.5
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "anyOf.anyOf-with-base-schema.mismatch-base-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string",
        \\     "anyOf": [
        \\         {
        \\             "maxLength": 2
        \\         },
        \\         {
        \\             "minLength": 4
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 3
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "anyOf.anyOf-with-base-schema.one-anyOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string",
        \\     "anyOf": [
        \\         {
        \\             "maxLength": 2
        \\         },
        \\         {
        \\             "minLength": 4
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "foobar"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anyOf.anyOf-with-base-schema.both-anyOf-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "type": "string",
        \\     "anyOf": [
        \\         {
        \\             "maxLength": 2
        \\         },
        \\         {
        \\             "minLength": 4
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "anyOf.anyOf-complex-types.first-anyOf-valid-(complex)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anyOf.anyOf-complex-types.second-anyOf-valid-(complex)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anyOf.anyOf-complex-types.both-anyOf-valid-(complex)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
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
test "anyOf.anyOf-complex-types.neither-anyOf-valid-(complex)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "integer"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
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
test "anyOf.anyOf-with-one-empty-schema.string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "anyOf": [
        \\         {
        \\             "type": "number"
        \\         },
        \\         {}
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anyOf.anyOf-with-one-empty-schema.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "anyOf": [
        \\         {
        \\             "type": "number"
        \\         },
        \\         {}
        \\     ]
        \\ }
    );

    const case =
        \\ 123
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anyOf.nested-anyOf,-to-check-validation-semantics.null-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "anyOf": [
        \\         {
        \\             "anyOf": [
        \\                 {
        \\                     "type": "null"
        \\                 }
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anyOf.nested-anyOf,-to-check-validation-semantics.anything-non-null-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "anyOf": [
        \\         {
        \\             "anyOf": [
        \\                 {
        \\                     "type": "null"
        \\                 }
        \\             ]
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ 123
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
