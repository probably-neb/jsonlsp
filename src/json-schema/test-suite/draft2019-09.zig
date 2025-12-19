const std = @import("std");
const JSONSchema = @import("json-schema");

fn check_valid(schema_str: []const u8, case: []const u8, is_valid: bool) !void {
    const schema = JSONSchema.parse(schema_str) catch |err| std.debug.panic("Failed to parse JSON schema: {}\n", .{err});
    if (schema.is_valid(case) == is_valid) return;
    std.debug.print("\nReason:\nExpected Schema:\n{s}\nTo {s} Case:\n{s}\nBut it was {s}!\n", .{
        schema_str,
        if (is_valid) "ACCEPT" else "REJECT",
        case,
        if (is_valid) "REJECTED" else "ACCEPTED",
    });
    return error.FailedTest;
}
test "unevaluatedItems.unevaluatedItems-true.with-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": true
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-true.with-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": true
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-false.with-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-false.with-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-as-schema.with-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": {
        \\         "type": "string"
        \\     }
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-as-schema.with-valid-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": {
        \\         "type": "string"
        \\     }
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-as-schema.with-invalid-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": {
        \\         "type": "string"
        \\     }
        \\ }
    ,
        \\ [
        \\     42
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-uniform-items.unevaluatedItems-doesn't-apply" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": {
        \\         "type": "string"
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-tuple.with-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-tuple.with-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-items-and-additionalItems.unevaluatedItems-doesn't-apply" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "additionalItems": true,
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     42
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-ignored-additionalItems.invalid-under-unevaluatedItems" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "additionalItems": {
        \\         "type": "number"
        \\     },
        \\     "unevaluatedItems": {
        \\         "type": "string"
        \\     }
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     1
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-ignored-additionalItems.all-valid-under-unevaluatedItems" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "additionalItems": {
        \\         "type": "number"
        \\     },
        \\     "unevaluatedItems": {
        \\         "type": "string"
        \\     }
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "baz"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-ignored-applicator-additionalItems.invalid-under-unevaluatedItems" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "additionalItems": {
        \\                 "type": "number"
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedItems": {
        \\         "type": "string"
        \\     }
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     1
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-ignored-applicator-additionalItems.all-valid-under-unevaluatedItems" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "additionalItems": {
        \\                 "type": "number"
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedItems": {
        \\         "type": "string"
        \\     }
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "baz"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-nested-tuple.with-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "allOf": [
        \\         {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "type": "number"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     42
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-nested-tuple.with-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "allOf": [
        \\         {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "type": "number"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     42,
        \\     true
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-nested-items.with-only-(valid)-additional-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": {
        \\         "type": "boolean"
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "items": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         true
        \\     ]
        \\ }
    ,
        \\ [
        \\     true,
        \\     false
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-nested-items.with-no-additional-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": {
        \\         "type": "boolean"
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "items": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         true
        \\     ]
        \\ }
    ,
        \\ [
        \\     "yes",
        \\     "no"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-nested-items.with-invalid-additional-item" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": {
        \\         "type": "boolean"
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "items": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         true
        \\     ]
        \\ }
    ,
        \\ [
        \\     "yes",
        \\     false
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-nested-items-and-additionalItems.with-no-additional-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "items": [
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ],
        \\             "additionalItems": true
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-nested-items-and-additionalItems.with-additional-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "items": [
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ],
        \\             "additionalItems": true
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     42,
        \\     true
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-nested-unevaluatedItems.with-no-additional-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "items": [
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "unevaluatedItems": true
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-nested-unevaluatedItems.with-additional-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "items": [
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "unevaluatedItems": true
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     42,
        \\     true
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-anyOf.when-one-schema-matches-and-has-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "items": [
        \\                 true,
        \\                 true,
        \\                 {
        \\                     "const": "baz"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-anyOf.when-one-schema-matches-and-has-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "items": [
        \\                 true,
        \\                 true,
        \\                 {
        \\                     "const": "baz"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar",
        \\     42
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-anyOf.when-two-schemas-match-and-has-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "items": [
        \\                 true,
        \\                 true,
        \\                 {
        \\                     "const": "baz"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "baz"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-anyOf.when-two-schemas-match-and-has-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "items": [
        \\                 true,
        \\                 true,
        \\                 {
        \\                     "const": "baz"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "baz",
        \\     42
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-oneOf.with-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "oneOf": [
        \\         {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "const": "baz"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-oneOf.with-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "oneOf": [
        \\         {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "const": "baz"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar",
        \\     42
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-not.with-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "not": {
        \\         "not": {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-if/then/else.when-if-matches-and-it-has-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "if": {
        \\         "items": [
        \\             true,
        \\             {
        \\                 "const": "bar"
        \\             }
        \\         ]
        \\     },
        \\     "then": {
        \\         "items": [
        \\             true,
        \\             true,
        \\             {
        \\                 "const": "then"
        \\             }
        \\         ]
        \\     },
        \\     "else": {
        \\         "items": [
        \\             true,
        \\             true,
        \\             true,
        \\             {
        \\                 "const": "else"
        \\             }
        \\         ]
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "then"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-if/then/else.when-if-matches-and-it-has-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "if": {
        \\         "items": [
        \\             true,
        \\             {
        \\                 "const": "bar"
        \\             }
        \\         ]
        \\     },
        \\     "then": {
        \\         "items": [
        \\             true,
        \\             true,
        \\             {
        \\                 "const": "then"
        \\             }
        \\         ]
        \\     },
        \\     "else": {
        \\         "items": [
        \\             true,
        \\             true,
        \\             true,
        \\             {
        \\                 "const": "else"
        \\             }
        \\         ]
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "then",
        \\     "else"
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-if/then/else.when-if-doesn't-match-and-it-has-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "if": {
        \\         "items": [
        \\             true,
        \\             {
        \\                 "const": "bar"
        \\             }
        \\         ]
        \\     },
        \\     "then": {
        \\         "items": [
        \\             true,
        \\             true,
        \\             {
        \\                 "const": "then"
        \\             }
        \\         ]
        \\     },
        \\     "else": {
        \\         "items": [
        \\             true,
        \\             true,
        \\             true,
        \\             {
        \\                 "const": "else"
        \\             }
        \\         ]
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     42,
        \\     42,
        \\     "else"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-if/then/else.when-if-doesn't-match-and-it-has-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "if": {
        \\         "items": [
        \\             true,
        \\             {
        \\                 "const": "bar"
        \\             }
        \\         ]
        \\     },
        \\     "then": {
        \\         "items": [
        \\             true,
        \\             true,
        \\             {
        \\                 "const": "then"
        \\             }
        \\         ]
        \\     },
        \\     "else": {
        \\         "items": [
        \\             true,
        \\             true,
        \\             true,
        \\             {
        \\                 "const": "else"
        \\             }
        \\         ]
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     42,
        \\     42,
        \\     "else",
        \\     42
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-boolean-schemas.with-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         true
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-boolean-schemas.with-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         true
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-$ref.with-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "#/$defs/bar",
        \\     "items": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "unevaluatedItems": false,
        \\     "$defs": {
        \\         "bar": {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-$ref.with-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "#/$defs/bar",
        \\     "items": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "unevaluatedItems": false,
        \\     "$defs": {
        \\         "bar": {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "baz"
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-before-$ref.with-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": false,
        \\     "items": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "$ref": "#/$defs/bar",
        \\     "$defs": {
        \\         "bar": {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-before-$ref.with-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": false,
        \\     "items": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "$ref": "#/$defs/bar",
        \\     "$defs": {
        \\         "bar": {
        \\             "items": [
        \\                 true,
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "baz"
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-with-$recursiveRef.with-no-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "https://example.com/unevaluated-items-with-recursive-ref/extended-tree",
        \\     "$recursiveAnchor": true,
        \\     "$ref": "./tree",
        \\     "items": [
        \\         true,
        \\         true,
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "$defs": {
        \\         "tree": {
        \\             "$id": "./tree",
        \\             "$recursiveAnchor": true,
        \\             "type": "array",
        \\             "items": [
        \\                 {
        \\                     "type": "number"
        \\                 },
        \\                 {
        \\                     "$comment": "unevaluatedItems comes first so it's more likely to catch bugs with implementations that are sensitive to keyword ordering",
        \\                     "unevaluatedItems": false,
        \\                     "$recursiveRef": "#"
        \\                 }
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ [
        \\     1,
        \\     [
        \\         2,
        \\         [],
        \\         "b"
        \\     ],
        \\     "a"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-$recursiveRef.with-unevaluated-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "https://example.com/unevaluated-items-with-recursive-ref/extended-tree",
        \\     "$recursiveAnchor": true,
        \\     "$ref": "./tree",
        \\     "items": [
        \\         true,
        \\         true,
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "$defs": {
        \\         "tree": {
        \\             "$id": "./tree",
        \\             "$recursiveAnchor": true,
        \\             "type": "array",
        \\             "items": [
        \\                 {
        \\                     "type": "number"
        \\                 },
        \\                 {
        \\                     "$comment": "unevaluatedItems comes first so it's more likely to catch bugs with implementations that are sensitive to keyword ordering",
        \\                     "unevaluatedItems": false,
        \\                     "$recursiveRef": "#"
        \\                 }
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ [
        \\     1,
        \\     [
        \\         2,
        \\         [],
        \\         "b",
        \\         "too many"
        \\     ],
        \\     "a"
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.unevaluatedItems-can't-see-inside-cousins.always-fails" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "items": [
        \\                 true
        \\             ]
        \\         },
        \\         {
        \\             "unevaluatedItems": false
        \\         }
        \\     ]
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        false,
    );
}
test "unevaluatedItems.item-is-evaluated-in-an-uncle-schema-to-unevaluatedItems.no-extra-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "items": [
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ],
        \\             "unevaluatedItems": false
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "items": [
        \\                         true,
        \\                         {
        \\                             "type": "string"
        \\                         }
        \\                     ]
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": [
        \\         "test"
        \\     ]
        \\ }
    ,
        true,
    );
}
test "unevaluatedItems.item-is-evaluated-in-an-uncle-schema-to-unevaluatedItems.uncle-keyword-evaluation-is-not-significant" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "items": [
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ],
        \\             "unevaluatedItems": false
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "items": [
        \\                         true,
        \\                         {
        \\                             "type": "string"
        \\                         }
        \\                     ]
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": [
        \\         "test",
        \\         "test"
        \\     ]
        \\ }
    ,
        false,
    );
}
test "unevaluatedItems.non-array-instances-are-valid.ignores-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ true
    ,
        true,
    );
}
test "unevaluatedItems.non-array-instances-are-valid.ignores-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ 123
    ,
        true,
    );
}
test "unevaluatedItems.non-array-instances-are-valid.ignores-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "unevaluatedItems.non-array-instances-are-valid.ignores-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "unevaluatedItems.non-array-instances-are-valid.ignores-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "unevaluatedItems.non-array-instances-are-valid.ignores-null" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-with-null-instance-elements.allows-null-elements" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedItems": {
        \\         "type": "null"
        \\     }
        \\ }
    ,
        \\ [
        \\     null
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-can-see-annotations-from-if-without-then-and-else.valid-in-case-if-is-evaluated" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "items": [
        \\             {
        \\                 "const": "a"
        \\             }
        \\         ]
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "a"
        \\ ]
    ,
        true,
    );
}
test "unevaluatedItems.unevaluatedItems-can-see-annotations-from-if-without-then-and-else.invalid-in-case-if-is-evaluated" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "items": [
        \\             {
        \\                 "const": "a"
        \\             }
        \\         ]
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    ,
        \\ [
        \\     "b"
        \\ ]
    ,
        false,
    );
}
test "maxLength.maxLength-validation.shorter-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxLength": 2
        \\ }
    ,
        \\ "f"
    ,
        true,
    );
}
test "maxLength.maxLength-validation.exact-length-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxLength": 2
        \\ }
    ,
        \\ "fo"
    ,
        true,
    );
}
test "maxLength.maxLength-validation.too-long-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxLength": 2
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "maxLength.maxLength-validation.ignores-non-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxLength": 2
        \\ }
    ,
        \\ 100
    ,
        true,
    );
}
test "maxLength.maxLength-validation.two-graphemes-is-long-enough" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxLength": 2
        \\ }
    ,
        \\ "💩💩"
    ,
        true,
    );
}
test "maxLength.maxLength-validation-with-a-decimal.shorter-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxLength": 2
        \\ }
    ,
        \\ "f"
    ,
        true,
    );
}
test "maxLength.maxLength-validation-with-a-decimal.too-long-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxLength": 2
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "refRemote.remote-ref.remote-ref-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/integer.json"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "refRemote.remote-ref.remote-ref-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/integer.json"
        \\ }
    ,
        \\ "a"
    ,
        false,
    );
}
test "refRemote.fragment-within-remote-ref.remote-fragment-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/subSchemas.json#/$defs/integer"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "refRemote.fragment-within-remote-ref.remote-fragment-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/subSchemas.json#/$defs/integer"
        \\ }
    ,
        \\ "a"
    ,
        false,
    );
}
test "refRemote.anchor-within-remote-ref.remote-anchor-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/locationIndependentIdentifier.json#foo"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "refRemote.anchor-within-remote-ref.remote-anchor-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/locationIndependentIdentifier.json#foo"
        \\ }
    ,
        \\ "a"
    ,
        false,
    );
}
test "refRemote.ref-within-remote-ref.ref-within-ref-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/subSchemas.json#/$defs/refToInteger"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "refRemote.ref-within-remote-ref.ref-within-ref-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/subSchemas.json#/$defs/refToInteger"
        \\ }
    ,
        \\ "a"
    ,
        false,
    );
}
test "refRemote.base-URI-change.base-URI-change-ref-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/",
        \\     "items": {
        \\         "$id": "baseUriChange/",
        \\         "items": {
        \\             "$ref": "folderInteger.json"
        \\         }
        \\     }
        \\ }
    ,
        \\ [
        \\     [
        \\         1
        \\     ]
        \\ ]
    ,
        true,
    );
}
test "refRemote.base-URI-change.base-URI-change-ref-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/",
        \\     "items": {
        \\         "$id": "baseUriChange/",
        \\         "items": {
        \\             "$ref": "folderInteger.json"
        \\         }
        \\     }
        \\ }
    ,
        \\ [
        \\     [
        \\         "a"
        \\     ]
        \\ ]
    ,
        false,
    );
}
test "refRemote.base-URI-change---change-folder.number-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/scope_change_defs1.json",
        \\     "type": "object",
        \\     "properties": {
        \\         "list": {
        \\             "$ref": "baseUriChangeFolder/"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "baz": {
        \\             "$id": "baseUriChangeFolder/",
        \\             "type": "array",
        \\             "items": {
        \\                 "$ref": "folderInteger.json"
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "list": [
        \\         1
        \\     ]
        \\ }
    ,
        true,
    );
}
test "refRemote.base-URI-change---change-folder.string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/scope_change_defs1.json",
        \\     "type": "object",
        \\     "properties": {
        \\         "list": {
        \\             "$ref": "baseUriChangeFolder/"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "baz": {
        \\             "$id": "baseUriChangeFolder/",
        \\             "type": "array",
        \\             "items": {
        \\                 "$ref": "folderInteger.json"
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "list": [
        \\         "a"
        \\     ]
        \\ }
    ,
        false,
    );
}
test "refRemote.base-URI-change---change-folder-in-subschema.number-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/scope_change_defs2.json",
        \\     "type": "object",
        \\     "properties": {
        \\         "list": {
        \\             "$ref": "baseUriChangeFolderInSubschema/#/$defs/bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "baz": {
        \\             "$id": "baseUriChangeFolderInSubschema/",
        \\             "$defs": {
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
    ,
        \\ {
        \\     "list": [
        \\         1
        \\     ]
        \\ }
    ,
        true,
    );
}
test "refRemote.base-URI-change---change-folder-in-subschema.string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/scope_change_defs2.json",
        \\     "type": "object",
        \\     "properties": {
        \\         "list": {
        \\             "$ref": "baseUriChangeFolderInSubschema/#/$defs/bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "baz": {
        \\             "$id": "baseUriChangeFolderInSubschema/",
        \\             "$defs": {
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
    ,
        \\ {
        \\     "list": [
        \\         "a"
        \\     ]
        \\ }
    ,
        false,
    );
}
test "refRemote.root-ref-in-remote-ref.string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/object",
        \\     "type": "object",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "name-defs.json#/$defs/orNull"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "name": "foo"
        \\ }
    ,
        true,
    );
}
test "refRemote.root-ref-in-remote-ref.null-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/object",
        \\     "type": "object",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "name-defs.json#/$defs/orNull"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "name": null
        \\ }
    ,
        true,
    );
}
test "refRemote.root-ref-in-remote-ref.object-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/object",
        \\     "type": "object",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "name-defs.json#/$defs/orNull"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "name": {
        \\         "name": null
        \\     }
        \\ }
    ,
        false,
    );
}
test "refRemote.remote-ref-with-ref-to-defs.invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/schema-remote-ref-ref-defs1.json",
        \\     "$ref": "ref-and-defs.json"
        \\ }
    ,
        \\ {
        \\     "bar": 1
        \\ }
    ,
        false,
    );
}
test "refRemote.remote-ref-with-ref-to-defs.valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/schema-remote-ref-ref-defs1.json",
        \\     "$ref": "ref-and-defs.json"
        \\ }
    ,
        \\ {
        \\     "bar": "a"
        \\ }
    ,
        true,
    );
}
test "refRemote.Location-independent-identifier-in-remote-ref.integer-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/locationIndependentIdentifier.json#/$defs/refToInteger"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "refRemote.Location-independent-identifier-in-remote-ref.string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/locationIndependentIdentifier.json#/$defs/refToInteger"
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "refRemote.retrieved-nested-refs-resolve-relative-to-their-URI-not-$id.number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/some-id",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "nested/foo-ref-string.json"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "name": {
        \\         "foo": 1
        \\     }
        \\ }
    ,
        false,
    );
}
test "refRemote.retrieved-nested-refs-resolve-relative-to-their-URI-not-$id.string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/some-id",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "nested/foo-ref-string.json"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "name": {
        \\         "foo": "a"
        \\     }
        \\ }
    ,
        true,
    );
}
test "refRemote.remote-HTTP-ref-with-different-$id.number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/different-id-ref-string.json"
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "refRemote.remote-HTTP-ref-with-different-$id.string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/different-id-ref-string.json"
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "refRemote.remote-HTTP-ref-with-different-URN-$id.number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/urn-ref-string.json"
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "refRemote.remote-HTTP-ref-with-different-URN-$id.string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/urn-ref-string.json"
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "refRemote.remote-HTTP-ref-with-nested-absolute-ref.number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/nested-absolute-ref-to-string.json"
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "refRemote.remote-HTTP-ref-with-nested-absolute-ref.string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/nested-absolute-ref-to-string.json"
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "refRemote.$ref-to-$ref-finds-detached-$anchor.number-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/detached-ref.json#/$defs/foo"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "refRemote.$ref-to-$ref-finds-detached-$anchor.non-number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/detached-ref.json#/$defs/foo"
        \\ }
    ,
        \\ "a"
    ,
        false,
    );
}
test "if-then-else.ignore-if-without-then-or-else.valid-when-valid-against-lone-if" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "const": 0
        \\     }
        \\ }
    ,
        \\ 0
    ,
        true,
    );
}
test "if-then-else.ignore-if-without-then-or-else.valid-when-invalid-against-lone-if" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "const": 0
        \\     }
        \\ }
    ,
        \\ "hello"
    ,
        true,
    );
}
test "if-then-else.ignore-then-without-if.valid-when-valid-against-lone-then" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "then": {
        \\         "const": 0
        \\     }
        \\ }
    ,
        \\ 0
    ,
        true,
    );
}
test "if-then-else.ignore-then-without-if.valid-when-invalid-against-lone-then" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "then": {
        \\         "const": 0
        \\     }
        \\ }
    ,
        \\ "hello"
    ,
        true,
    );
}
test "if-then-else.ignore-else-without-if.valid-when-valid-against-lone-else" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "else": {
        \\         "const": 0
        \\     }
        \\ }
    ,
        \\ 0
    ,
        true,
    );
}
test "if-then-else.ignore-else-without-if.valid-when-invalid-against-lone-else" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "else": {
        \\         "const": 0
        \\     }
        \\ }
    ,
        \\ "hello"
    ,
        true,
    );
}
test "if-then-else.if-and-then-without-else.valid-through-then" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "then": {
        \\         "minimum": -10
        \\     }
        \\ }
    ,
        \\ -1
    ,
        true,
    );
}
test "if-then-else.if-and-then-without-else.invalid-through-then" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "then": {
        \\         "minimum": -10
        \\     }
        \\ }
    ,
        \\ -100
    ,
        false,
    );
}
test "if-then-else.if-and-then-without-else.valid-when-if-test-fails" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "then": {
        \\         "minimum": -10
        \\     }
        \\ }
    ,
        \\ 3
    ,
        true,
    );
}
test "if-then-else.if-and-else-without-then.valid-when-if-test-passes" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "else": {
        \\         "multipleOf": 2
        \\     }
        \\ }
    ,
        \\ -1
    ,
        true,
    );
}
test "if-then-else.if-and-else-without-then.valid-through-else" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "else": {
        \\         "multipleOf": 2
        \\     }
        \\ }
    ,
        \\ 4
    ,
        true,
    );
}
test "if-then-else.if-and-else-without-then.invalid-through-else" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "else": {
        \\         "multipleOf": 2
        \\     }
        \\ }
    ,
        \\ 3
    ,
        false,
    );
}
test "if-then-else.validate-against-correct-branch,-then-vs-else.valid-through-then" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "then": {
        \\         "minimum": -10
        \\     },
        \\     "else": {
        \\         "multipleOf": 2
        \\     }
        \\ }
    ,
        \\ -1
    ,
        true,
    );
}
test "if-then-else.validate-against-correct-branch,-then-vs-else.invalid-through-then" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "then": {
        \\         "minimum": -10
        \\     },
        \\     "else": {
        \\         "multipleOf": 2
        \\     }
        \\ }
    ,
        \\ -100
    ,
        false,
    );
}
test "if-then-else.validate-against-correct-branch,-then-vs-else.valid-through-else" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "then": {
        \\         "minimum": -10
        \\     },
        \\     "else": {
        \\         "multipleOf": 2
        \\     }
        \\ }
    ,
        \\ 4
    ,
        true,
    );
}
test "if-then-else.validate-against-correct-branch,-then-vs-else.invalid-through-else" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "then": {
        \\         "minimum": -10
        \\     },
        \\     "else": {
        \\         "multipleOf": 2
        \\     }
        \\ }
    ,
        \\ 3
    ,
        false,
    );
}
test "if-then-else.non-interference-across-combined-schemas.valid,-but-would-have-been-invalid-through-then" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "if": {
        \\                 "exclusiveMaximum": 0
        \\             }
        \\         },
        \\         {
        \\             "then": {
        \\                 "minimum": -10
        \\             }
        \\         },
        \\         {
        \\             "else": {
        \\                 "multipleOf": 2
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ -100
    ,
        true,
    );
}
test "if-then-else.non-interference-across-combined-schemas.valid,-but-would-have-been-invalid-through-else" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "if": {
        \\                 "exclusiveMaximum": 0
        \\             }
        \\         },
        \\         {
        \\             "then": {
        \\                 "minimum": -10
        \\             }
        \\         },
        \\         {
        \\             "else": {
        \\                 "multipleOf": 2
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ 3
    ,
        true,
    );
}
test "if-then-else.if-with-boolean-schema-true.boolean-schema-true-in-if-always-chooses-the-then-path-(valid)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": true,
        \\     "then": {
        \\         "const": "then"
        \\     },
        \\     "else": {
        \\         "const": "else"
        \\     }
        \\ }
    ,
        \\ "then"
    ,
        true,
    );
}
test "if-then-else.if-with-boolean-schema-true.boolean-schema-true-in-if-always-chooses-the-then-path-(invalid)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": true,
        \\     "then": {
        \\         "const": "then"
        \\     },
        \\     "else": {
        \\         "const": "else"
        \\     }
        \\ }
    ,
        \\ "else"
    ,
        false,
    );
}
test "if-then-else.if-with-boolean-schema-false.boolean-schema-false-in-if-always-chooses-the-else-path-(invalid)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": false,
        \\     "then": {
        \\         "const": "then"
        \\     },
        \\     "else": {
        \\         "const": "else"
        \\     }
        \\ }
    ,
        \\ "then"
    ,
        false,
    );
}
test "if-then-else.if-with-boolean-schema-false.boolean-schema-false-in-if-always-chooses-the-else-path-(valid)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": false,
        \\     "then": {
        \\         "const": "then"
        \\     },
        \\     "else": {
        \\         "const": "else"
        \\     }
        \\ }
    ,
        \\ "else"
    ,
        true,
    );
}
test "if-then-else.if-appears-at-the-end-when-serialized-(keyword-processing-sequence).yes-redirects-to-then-and-passes" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "then": {
        \\         "const": "yes"
        \\     },
        \\     "else": {
        \\         "const": "other"
        \\     },
        \\     "if": {
        \\         "maxLength": 4
        \\     }
        \\ }
    ,
        \\ "yes"
    ,
        true,
    );
}
test "if-then-else.if-appears-at-the-end-when-serialized-(keyword-processing-sequence).other-redirects-to-else-and-passes" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "then": {
        \\         "const": "yes"
        \\     },
        \\     "else": {
        \\         "const": "other"
        \\     },
        \\     "if": {
        \\         "maxLength": 4
        \\     }
        \\ }
    ,
        \\ "other"
    ,
        true,
    );
}
test "if-then-else.if-appears-at-the-end-when-serialized-(keyword-processing-sequence).no-redirects-to-then-and-fails" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "then": {
        \\         "const": "yes"
        \\     },
        \\     "else": {
        \\         "const": "other"
        \\     },
        \\     "if": {
        \\         "maxLength": 4
        \\     }
        \\ }
    ,
        \\ "no"
    ,
        false,
    );
}
test "if-then-else.if-appears-at-the-end-when-serialized-(keyword-processing-sequence).invalid-redirects-to-else-and-fails" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "then": {
        \\         "const": "yes"
        \\     },
        \\     "else": {
        \\         "const": "other"
        \\     },
        \\     "if": {
        \\         "maxLength": 4
        \\     }
        \\ }
    ,
        \\ "invalid"
    ,
        false,
    );
}
test "infinite-loop-detection.evaluating-the-same-schema-location-against-the-same-data-location-twice-is-not-a-sign-of-an-infinite-loop.passing-case" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "int": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "$ref": "#/$defs/int"
        \\                 }
        \\             }
        \\         },
        \\         {
        \\             "additionalProperties": {
        \\                 "$ref": "#/$defs/int"
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "infinite-loop-detection.evaluating-the-same-schema-location-against-the-same-data-location-twice-is-not-a-sign-of-an-infinite-loop.failing-case" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "int": {
        \\             "type": "integer"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "$ref": "#/$defs/int"
        \\                 }
        \\             }
        \\         },
        \\         {
        \\             "additionalProperties": {
        \\                 "$ref": "#/$defs/int"
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": "a string"
        \\ }
    ,
        false,
    );
}
test "dependentRequired.single-dependency.neither" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "bar": [
        \\             "foo"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "dependentRequired.single-dependency.nondependant" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "bar": [
        \\             "foo"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "dependentRequired.single-dependency.with-dependency" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "bar": [
        \\             "foo"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        true,
    );
}
test "dependentRequired.single-dependency.missing-dependency" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "bar": [
        \\             "foo"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "dependentRequired.single-dependency.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "bar": [
        \\             "foo"
        \\         ]
        \\     }
        \\ }
    ,
        \\ [
        \\     "bar"
        \\ ]
    ,
        true,
    );
}
test "dependentRequired.single-dependency.ignores-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "bar": [
        \\             "foo"
        \\         ]
        \\     }
        \\ }
    ,
        \\ "foobar"
    ,
        true,
    );
}
test "dependentRequired.single-dependency.ignores-other-non-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "bar": [
        \\             "foo"
        \\         ]
        \\     }
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "dependentRequired.empty-dependents.empty-object" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "bar": []
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "dependentRequired.empty-dependents.object-with-one-property" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "bar": []
        \\     }
        \\ }
    ,
        \\ {
        \\     "bar": 2
        \\ }
    ,
        true,
    );
}
test "dependentRequired.empty-dependents.non-object-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "bar": []
        \\     }
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "dependentRequired.multiple-dependents-required.neither" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "quux": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "dependentRequired.multiple-dependents-required.nondependants" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "quux": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        true,
    );
}
test "dependentRequired.multiple-dependents-required.with-dependencies" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "quux": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "quux": 3
        \\ }
    ,
        true,
    );
}
test "dependentRequired.multiple-dependents-required.missing-dependency" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "quux": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "quux": 2
        \\ }
    ,
        false,
    );
}
test "dependentRequired.multiple-dependents-required.missing-other-dependency" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "quux": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "bar": 1,
        \\     "quux": 2
        \\ }
    ,
        false,
    );
}
test "dependentRequired.multiple-dependents-required.missing-both-dependencies" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "quux": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "quux": 1
        \\ }
    ,
        false,
    );
}
test "dependentRequired.dependencies-with-escaped-characters.CRLF" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
        \\         "foo\"bar": [
        \\             "foo'bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo\nbar": 1,
        \\     "foo\rbar": 2
        \\ }
    ,
        true,
    );
}
test "dependentRequired.dependencies-with-escaped-characters.quoted-quotes" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
        \\         "foo\"bar": [
        \\             "foo'bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo'bar": 1,
        \\     "foo\"bar": 2
        \\ }
    ,
        true,
    );
}
test "dependentRequired.dependencies-with-escaped-characters.CRLF-missing-dependent" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
        \\         "foo\"bar": [
        \\             "foo'bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo\nbar": 1,
        \\     "foo": 2
        \\ }
    ,
        false,
    );
}
test "dependentRequired.dependencies-with-escaped-characters.quoted-quotes-missing-dependent" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentRequired": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
        \\         "foo\"bar": [
        \\             "foo'bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo\"bar": 2
        \\ }
    ,
        false,
    );
}
test "vocabulary.schema-that-uses-custom-metaschema-with-with-no-validation-vocabulary.applicator-vocabulary-still-works" {
    try check_valid(
        \\ {
        \\     "$id": "https://schema/using/no/validation",
        \\     "$schema": "http://localhost:1234/draft2019-09/metaschema-no-validation.json",
        \\     "properties": {
        \\         "badProperty": false,
        \\         "numberProperty": {
        \\             "minimum": 10
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "badProperty": "this property should not exist"
        \\ }
    ,
        false,
    );
}
test "vocabulary.schema-that-uses-custom-metaschema-with-with-no-validation-vocabulary.no-validation:-valid-number" {
    try check_valid(
        \\ {
        \\     "$id": "https://schema/using/no/validation",
        \\     "$schema": "http://localhost:1234/draft2019-09/metaschema-no-validation.json",
        \\     "properties": {
        \\         "badProperty": false,
        \\         "numberProperty": {
        \\             "minimum": 10
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "numberProperty": 20
        \\ }
    ,
        true,
    );
}
test "vocabulary.schema-that-uses-custom-metaschema-with-with-no-validation-vocabulary.no-validation:-invalid-number,-but-it-still-validates" {
    try check_valid(
        \\ {
        \\     "$id": "https://schema/using/no/validation",
        \\     "$schema": "http://localhost:1234/draft2019-09/metaschema-no-validation.json",
        \\     "properties": {
        \\         "badProperty": false,
        \\         "numberProperty": {
        \\             "minimum": 10
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "numberProperty": 1
        \\ }
    ,
        true,
    );
}
test "vocabulary.ignore-unrecognized-optional-vocabulary.string-value" {
    try check_valid(
        \\ {
        \\     "$schema": "http://localhost:1234/draft2019-09/metaschema-optional-vocabulary.json",
        \\     "type": "number"
        \\ }
    ,
        \\ "foobar"
    ,
        false,
    );
}
test "vocabulary.ignore-unrecognized-optional-vocabulary.number-value" {
    try check_valid(
        \\ {
        \\     "$schema": "http://localhost:1234/draft2019-09/metaschema-optional-vocabulary.json",
        \\     "type": "number"
        \\ }
    ,
        \\ 20
    ,
        true,
    );
}
test "ref.root-pointer-ref.match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": false
        \\ }
    ,
        true,
    );
}
test "ref.root-pointer-ref.recursive-match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "foo": false
        \\     }
        \\ }
    ,
        true,
    );
}
test "ref.root-pointer-ref.mismatch" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "bar": false
        \\ }
    ,
        false,
    );
}
test "ref.root-pointer-ref.recursive-mismatch" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": false
        \\     }
        \\ }
    ,
        false,
    );
}
test "ref.relative-pointer-ref-to-object.match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "$ref": "#/properties/foo"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "bar": 3
        \\ }
    ,
        true,
    );
}
test "ref.relative-pointer-ref-to-object.mismatch" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "$ref": "#/properties/foo"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "bar": true
        \\ }
    ,
        false,
    );
}
test "ref.relative-pointer-ref-to-array.match-array" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/items/0"
        \\         }
        \\     ]
        \\ }
    ,
        \\ [
        \\     1,
        \\     2
        \\ ]
    ,
        true,
    );
}
test "ref.relative-pointer-ref-to-array.mismatch-array" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/items/0"
        \\         }
        \\     ]
        \\ }
    ,
        \\ [
        \\     1,
        \\     "foo"
        \\ ]
    ,
        false,
    );
}
test "ref.escaped-pointer-ref.slash-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
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
        \\             "$ref": "#/$defs/tilde~0field"
        \\         },
        \\         "slash": {
        \\             "$ref": "#/$defs/slash~1field"
        \\         },
        \\         "percent": {
        \\             "$ref": "#/$defs/percent%25field"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "slash": "aoeu"
        \\ }
    ,
        false,
    );
}
test "ref.escaped-pointer-ref.tilde-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
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
        \\             "$ref": "#/$defs/tilde~0field"
        \\         },
        \\         "slash": {
        \\             "$ref": "#/$defs/slash~1field"
        \\         },
        \\         "percent": {
        \\             "$ref": "#/$defs/percent%25field"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "tilde": "aoeu"
        \\ }
    ,
        false,
    );
}
test "ref.escaped-pointer-ref.percent-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
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
        \\             "$ref": "#/$defs/tilde~0field"
        \\         },
        \\         "slash": {
        \\             "$ref": "#/$defs/slash~1field"
        \\         },
        \\         "percent": {
        \\             "$ref": "#/$defs/percent%25field"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "percent": "aoeu"
        \\ }
    ,
        false,
    );
}
test "ref.escaped-pointer-ref.slash-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
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
        \\             "$ref": "#/$defs/tilde~0field"
        \\         },
        \\         "slash": {
        \\             "$ref": "#/$defs/slash~1field"
        \\         },
        \\         "percent": {
        \\             "$ref": "#/$defs/percent%25field"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "slash": 123
        \\ }
    ,
        true,
    );
}
test "ref.escaped-pointer-ref.tilde-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
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
        \\             "$ref": "#/$defs/tilde~0field"
        \\         },
        \\         "slash": {
        \\             "$ref": "#/$defs/slash~1field"
        \\         },
        \\         "percent": {
        \\             "$ref": "#/$defs/percent%25field"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "tilde": 123
        \\ }
    ,
        true,
    );
}
test "ref.escaped-pointer-ref.percent-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
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
        \\             "$ref": "#/$defs/tilde~0field"
        \\         },
        \\         "slash": {
        \\             "$ref": "#/$defs/slash~1field"
        \\         },
        \\         "percent": {
        \\             "$ref": "#/$defs/percent%25field"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "percent": 123
        \\ }
    ,
        true,
    );
}
test "ref.nested-refs.nested-ref-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "a": {
        \\             "type": "integer"
        \\         },
        \\         "b": {
        \\             "$ref": "#/$defs/a"
        \\         },
        \\         "c": {
        \\             "$ref": "#/$defs/b"
        \\         }
        \\     },
        \\     "$ref": "#/$defs/c"
        \\ }
    ,
        \\ 5
    ,
        true,
    );
}
test "ref.nested-refs.nested-ref-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "a": {
        \\             "type": "integer"
        \\         },
        \\         "b": {
        \\             "$ref": "#/$defs/a"
        \\         },
        \\         "c": {
        \\             "$ref": "#/$defs/b"
        \\         }
        \\     },
        \\     "$ref": "#/$defs/c"
        \\ }
    ,
        \\ "a"
    ,
        false,
    );
}
test "ref.ref-applies-alongside-sibling-keywords.ref-valid,-maxItems-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "reffed": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/$defs/reffed",
        \\             "maxItems": 2
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": []
        \\ }
    ,
        true,
    );
}
test "ref.ref-applies-alongside-sibling-keywords.ref-valid,-maxItems-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "reffed": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/$defs/reffed",
        \\             "maxItems": 2
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": [
        \\         1,
        \\         2,
        \\         3
        \\     ]
        \\ }
    ,
        false,
    );
}
test "ref.ref-applies-alongside-sibling-keywords.ref-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "reffed": {
        \\             "type": "array"
        \\         }
        \\     },
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/$defs/reffed",
        \\             "maxItems": 2
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "string"
        \\ }
    ,
        false,
    );
}
test "ref.remote-ref,-containing-refs-itself.remote-ref-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "https://json-schema.org/draft/2019-09/schema"
        \\ }
    ,
        \\ {
        \\     "minLength": 1
        \\ }
    ,
        true,
    );
}
test "ref.remote-ref,-containing-refs-itself.remote-ref-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "https://json-schema.org/draft/2019-09/schema"
        \\ }
    ,
        \\ {
        \\     "minLength": -1
        \\ }
    ,
        false,
    );
}
test "ref.property-named-$ref-that-is-not-a-reference.property-named-$ref-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "$ref": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "$ref": "a"
        \\ }
    ,
        true,
    );
}
test "ref.property-named-$ref-that-is-not-a-reference.property-named-$ref-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "$ref": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "$ref": 2
        \\ }
    ,
        false,
    );
}
test "ref.property-named-$ref,-containing-an-actual-$ref.property-named-$ref-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "$ref": {
        \\             "$ref": "#/$defs/is-string"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "is-string": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "$ref": "a"
        \\ }
    ,
        true,
    );
}
test "ref.property-named-$ref,-containing-an-actual-$ref.property-named-$ref-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "$ref": {
        \\             "$ref": "#/$defs/is-string"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "is-string": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "$ref": 2
        \\ }
    ,
        false,
    );
}
test "ref.$ref-to-boolean-schema-true.any-value-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "#/$defs/bool",
        \\     "$defs": {
        \\         "bool": true
        \\     }
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "ref.$ref-to-boolean-schema-false.any-value-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "#/$defs/bool",
        \\     "$defs": {
        \\         "bool": false
        \\     }
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "ref.Recursive-references-between-schemas.valid-tree" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/tree",
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
        \\     "$defs": {
        \\         "node": {
        \\             "$id": "http://localhost:1234/draft2019-09/node",
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
    ,
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
    ,
        true,
    );
}
test "ref.Recursive-references-between-schemas.invalid-tree" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/tree",
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
        \\     "$defs": {
        \\         "node": {
        \\             "$id": "http://localhost:1234/draft2019-09/node",
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
    ,
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
    ,
        false,
    );
}
test "ref.refs-with-quote.object-with-numbers-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo\"bar": {
        \\             "$ref": "#/$defs/foo%22bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "foo\"bar": {
        \\             "type": "number"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo\"bar": 1
        \\ }
    ,
        true,
    );
}
test "ref.refs-with-quote.object-with-strings-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo\"bar": {
        \\             "$ref": "#/$defs/foo%22bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "foo\"bar": {
        \\             "type": "number"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo\"bar": "1"
        \\ }
    ,
        false,
    );
}
test "ref.ref-creates-new-scope-when-adjacent-to-keywords.referenced-subschema-doesn't-see-annotations-from-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "A": {
        \\             "unevaluatedProperties": false
        \\         }
        \\     },
        \\     "properties": {
        \\         "prop1": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "$ref": "#/$defs/A"
        \\ }
    ,
        \\ {
        \\     "prop1": "match"
        \\ }
    ,
        false,
    );
}
test "ref.naive-replacement-of-$ref-with-its-destination-is-not-correct.do-not-evaluate-the-$ref-inside-the-enum,-matching-any-string" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "a_string": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "enum": [
        \\         {
        \\             "$ref": "#/$defs/a_string"
        \\         }
        \\     ]
        \\ }
    ,
        \\ "this is a string"
    ,
        false,
    );
}
test "ref.naive-replacement-of-$ref-with-its-destination-is-not-correct.do-not-evaluate-the-$ref-inside-the-enum,-definition-exact-match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "a_string": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "enum": [
        \\         {
        \\             "$ref": "#/$defs/a_string"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "type": "string"
        \\ }
    ,
        false,
    );
}
test "ref.naive-replacement-of-$ref-with-its-destination-is-not-correct.match-the-enum-exactly" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "a_string": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "enum": [
        \\         {
        \\             "$ref": "#/$defs/a_string"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "$ref": "#/$defs/a_string"
        \\ }
    ,
        true,
    );
}
test "ref.refs-with-relative-uris-and-defs.invalid-on-inner-field" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://example.com/schema-relative-uri-defs1.json",
        \\     "properties": {
        \\         "foo": {
        \\             "$id": "schema-relative-uri-defs2.json",
        \\             "$defs": {
        \\                 "inner": {
        \\                     "properties": {
        \\                         "bar": {
        \\                             "type": "string"
        \\                         }
        \\                     }
        \\                 }
        \\             },
        \\             "$ref": "#/$defs/inner"
        \\         }
        \\     },
        \\     "$ref": "schema-relative-uri-defs2.json"
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": 1
        \\     },
        \\     "bar": "a"
        \\ }
    ,
        false,
    );
}
test "ref.refs-with-relative-uris-and-defs.invalid-on-outer-field" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://example.com/schema-relative-uri-defs1.json",
        \\     "properties": {
        \\         "foo": {
        \\             "$id": "schema-relative-uri-defs2.json",
        \\             "$defs": {
        \\                 "inner": {
        \\                     "properties": {
        \\                         "bar": {
        \\                             "type": "string"
        \\                         }
        \\                     }
        \\                 }
        \\             },
        \\             "$ref": "#/$defs/inner"
        \\         }
        \\     },
        \\     "$ref": "schema-relative-uri-defs2.json"
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": "a"
        \\     },
        \\     "bar": 1
        \\ }
    ,
        false,
    );
}
test "ref.refs-with-relative-uris-and-defs.valid-on-both-fields" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://example.com/schema-relative-uri-defs1.json",
        \\     "properties": {
        \\         "foo": {
        \\             "$id": "schema-relative-uri-defs2.json",
        \\             "$defs": {
        \\                 "inner": {
        \\                     "properties": {
        \\                         "bar": {
        \\                             "type": "string"
        \\                         }
        \\                     }
        \\                 }
        \\             },
        \\             "$ref": "#/$defs/inner"
        \\         }
        \\     },
        \\     "$ref": "schema-relative-uri-defs2.json"
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": "a"
        \\     },
        \\     "bar": "a"
        \\ }
    ,
        true,
    );
}
test "ref.relative-refs-with-absolute-uris-and-defs.invalid-on-inner-field" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://example.com/schema-refs-absolute-uris-defs1.json",
        \\     "properties": {
        \\         "foo": {
        \\             "$id": "http://example.com/schema-refs-absolute-uris-defs2.json",
        \\             "$defs": {
        \\                 "inner": {
        \\                     "properties": {
        \\                         "bar": {
        \\                             "type": "string"
        \\                         }
        \\                     }
        \\                 }
        \\             },
        \\             "$ref": "#/$defs/inner"
        \\         }
        \\     },
        \\     "$ref": "schema-refs-absolute-uris-defs2.json"
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": 1
        \\     },
        \\     "bar": "a"
        \\ }
    ,
        false,
    );
}
test "ref.relative-refs-with-absolute-uris-and-defs.invalid-on-outer-field" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://example.com/schema-refs-absolute-uris-defs1.json",
        \\     "properties": {
        \\         "foo": {
        \\             "$id": "http://example.com/schema-refs-absolute-uris-defs2.json",
        \\             "$defs": {
        \\                 "inner": {
        \\                     "properties": {
        \\                         "bar": {
        \\                             "type": "string"
        \\                         }
        \\                     }
        \\                 }
        \\             },
        \\             "$ref": "#/$defs/inner"
        \\         }
        \\     },
        \\     "$ref": "schema-refs-absolute-uris-defs2.json"
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": "a"
        \\     },
        \\     "bar": 1
        \\ }
    ,
        false,
    );
}
test "ref.relative-refs-with-absolute-uris-and-defs.valid-on-both-fields" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://example.com/schema-refs-absolute-uris-defs1.json",
        \\     "properties": {
        \\         "foo": {
        \\             "$id": "http://example.com/schema-refs-absolute-uris-defs2.json",
        \\             "$defs": {
        \\                 "inner": {
        \\                     "properties": {
        \\                         "bar": {
        \\                             "type": "string"
        \\                         }
        \\                     }
        \\                 }
        \\             },
        \\             "$ref": "#/$defs/inner"
        \\         }
        \\     },
        \\     "$ref": "schema-refs-absolute-uris-defs2.json"
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": "a"
        \\     },
        \\     "bar": "a"
        \\ }
    ,
        true,
    );
}
test "ref.$id-must-be-resolved-against-nearest-parent,-not-just-immediate-parent.number-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://example.com/a.json",
        \\     "$defs": {
        \\         "x": {
        \\             "$id": "http://example.com/b/c.json",
        \\             "not": {
        \\                 "$defs": {
        \\                     "y": {
        \\                         "$id": "d.json",
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
    ,
        \\ 1
    ,
        true,
    );
}
test "ref.$id-must-be-resolved-against-nearest-parent,-not-just-immediate-parent.non-number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://example.com/a.json",
        \\     "$defs": {
        \\         "x": {
        \\             "$id": "http://example.com/b/c.json",
        \\             "not": {
        \\                 "$defs": {
        \\                     "y": {
        \\                         "$id": "d.json",
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
    ,
        \\ "a"
    ,
        false,
    );
}
test "ref.order-of-evaluation:-$id-and-$ref.data-is-valid-against-first-definition" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "$id must be evaluated before $ref to get the proper $ref destination",
        \\     "$id": "https://example.com/draft2019-09/ref-and-id1/base.json",
        \\     "$ref": "int.json",
        \\     "$defs": {
        \\         "bigint": {
        \\             "$comment": "canonical uri: https://example.com/draft2019-09/ref-and-id1/int.json",
        \\             "$id": "int.json",
        \\             "maximum": 10
        \\         },
        \\         "smallint": {
        \\             "$comment": "canonical uri: https://example.com/draft2019-09/ref-and-id1-int.json",
        \\             "$id": "/draft2019-09/ref-and-id1-int.json",
        \\             "maximum": 2
        \\         }
        \\     }
        \\ }
    ,
        \\ 5
    ,
        true,
    );
}
test "ref.order-of-evaluation:-$id-and-$ref.data-is-invalid-against-first-definition" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "$id must be evaluated before $ref to get the proper $ref destination",
        \\     "$id": "https://example.com/draft2019-09/ref-and-id1/base.json",
        \\     "$ref": "int.json",
        \\     "$defs": {
        \\         "bigint": {
        \\             "$comment": "canonical uri: https://example.com/draft2019-09/ref-and-id1/int.json",
        \\             "$id": "int.json",
        \\             "maximum": 10
        \\         },
        \\         "smallint": {
        \\             "$comment": "canonical uri: https://example.com/draft2019-09/ref-and-id1-int.json",
        \\             "$id": "/draft2019-09/ref-and-id1-int.json",
        \\             "maximum": 2
        \\         }
        \\     }
        \\ }
    ,
        \\ 50
    ,
        false,
    );
}
test "ref.order-of-evaluation:-$id-and-$anchor-and-$ref.data-is-valid-against-first-definition" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "$id must be evaluated before $ref to get the proper $ref destination",
        \\     "$id": "https://example.com/draft2019-09/ref-and-id2/base.json",
        \\     "$ref": "#bigint",
        \\     "$defs": {
        \\         "bigint": {
        \\             "$comment": "canonical uri: https://example.com/draft2019-09/ref-and-id2/base.json#/$defs/bigint; another valid uri for this location: https://example.com/ref-and-id2/base.json#bigint",
        \\             "$anchor": "bigint",
        \\             "maximum": 10
        \\         },
        \\         "smallint": {
        \\             "$comment": "canonical uri: https://example.com/draft2019-09/ref-and-id2#/$defs/smallint; another valid uri for this location: https://example.com/ref-and-id2/#bigint",
        \\             "$id": "/draft2019-09/ref-and-id2/",
        \\             "$anchor": "bigint",
        \\             "maximum": 2
        \\         }
        \\     }
        \\ }
    ,
        \\ 5
    ,
        true,
    );
}
test "ref.order-of-evaluation:-$id-and-$anchor-and-$ref.data-is-invalid-against-first-definition" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "$id must be evaluated before $ref to get the proper $ref destination",
        \\     "$id": "https://example.com/draft2019-09/ref-and-id2/base.json",
        \\     "$ref": "#bigint",
        \\     "$defs": {
        \\         "bigint": {
        \\             "$comment": "canonical uri: https://example.com/draft2019-09/ref-and-id2/base.json#/$defs/bigint; another valid uri for this location: https://example.com/ref-and-id2/base.json#bigint",
        \\             "$anchor": "bigint",
        \\             "maximum": 10
        \\         },
        \\         "smallint": {
        \\             "$comment": "canonical uri: https://example.com/draft2019-09/ref-and-id2#/$defs/smallint; another valid uri for this location: https://example.com/ref-and-id2/#bigint",
        \\             "$id": "/draft2019-09/ref-and-id2/",
        \\             "$anchor": "bigint",
        \\             "maximum": 2
        \\         }
        \\     }
        \\ }
    ,
        \\ 50
    ,
        false,
    );
}
test "ref.simple-URN-base-URI-with-$ref-via-the-URN.valid-under-the-URN-IDed-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "URIs do not have to have HTTP(s) schemes",
        \\     "$id": "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed",
        \\     "minimum": 30,
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 37
        \\ }
    ,
        true,
    );
}
test "ref.simple-URN-base-URI-with-$ref-via-the-URN.invalid-under-the-URN-IDed-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "URIs do not have to have HTTP(s) schemes",
        \\     "$id": "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed",
        \\     "minimum": 30,
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 12
        \\ }
    ,
        false,
    );
}
test "ref.simple-URN-base-URI-with-JSON-pointer.a-string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "URIs do not have to have HTTP(s) schemes",
        \\     "$id": "urn:uuid:deadbeef-1234-00ff-ff00-4321feebdaed",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/$defs/bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        true,
    );
}
test "ref.simple-URN-base-URI-with-JSON-pointer.a-non-string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "URIs do not have to have HTTP(s) schemes",
        \\     "$id": "urn:uuid:deadbeef-1234-00ff-ff00-4321feebdaed",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/$defs/bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 12
        \\ }
    ,
        false,
    );
}
test "ref.URN-base-URI-with-NSS.a-string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "RFC 8141 §2.2",
        \\     "$id": "urn:example:1/406/47452/2",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/$defs/bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        true,
    );
}
test "ref.URN-base-URI-with-NSS.a-non-string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "RFC 8141 §2.2",
        \\     "$id": "urn:example:1/406/47452/2",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/$defs/bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 12
        \\ }
    ,
        false,
    );
}
test "ref.URN-base-URI-with-r-component.a-string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "RFC 8141 §2.3.1",
        \\     "$id": "urn:example:foo-bar-baz-qux?+CCResolve:cc=uk",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/$defs/bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        true,
    );
}
test "ref.URN-base-URI-with-r-component.a-non-string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "RFC 8141 §2.3.1",
        \\     "$id": "urn:example:foo-bar-baz-qux?+CCResolve:cc=uk",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/$defs/bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 12
        \\ }
    ,
        false,
    );
}
test "ref.URN-base-URI-with-q-component.a-string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "RFC 8141 §2.3.2",
        \\     "$id": "urn:example:weather?=op=map&lat=39.56&lon=-104.85&datetime=1969-07-21T02:56:15Z",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/$defs/bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        true,
    );
}
test "ref.URN-base-URI-with-q-component.a-non-string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$comment": "RFC 8141 §2.3.2",
        \\     "$id": "urn:example:weather?=op=map&lat=39.56&lon=-104.85&datetime=1969-07-21T02:56:15Z",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "#/$defs/bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 12
        \\ }
    ,
        false,
    );
}
test "ref.URN-base-URI-with-URN-and-JSON-pointer-ref.a-string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "urn:uuid:deadbeef-1234-0000-0000-4321feebdaed",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "urn:uuid:deadbeef-1234-0000-0000-4321feebdaed#/$defs/bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        true,
    );
}
test "ref.URN-base-URI-with-URN-and-JSON-pointer-ref.a-non-string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "urn:uuid:deadbeef-1234-0000-0000-4321feebdaed",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "urn:uuid:deadbeef-1234-0000-0000-4321feebdaed#/$defs/bar"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 12
        \\ }
    ,
        false,
    );
}
test "ref.URN-base-URI-with-URN-and-anchor-ref.a-string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "urn:uuid:deadbeef-1234-ff00-00ff-4321feebdaed",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "urn:uuid:deadbeef-1234-ff00-00ff-4321feebdaed#something"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "$anchor": "something",
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        true,
    );
}
test "ref.URN-base-URI-with-URN-and-anchor-ref.a-non-string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "urn:uuid:deadbeef-1234-ff00-00ff-4321feebdaed",
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "urn:uuid:deadbeef-1234-ff00-00ff-4321feebdaed#something"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "$anchor": "something",
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 12
        \\ }
    ,
        false,
    );
}
test "ref.URN-ref-with-nested-pointer-ref.a-string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "urn:uuid:deadbeef-4321-ffff-ffff-1234feebdaed",
        \\     "$defs": {
        \\         "foo": {
        \\             "$id": "urn:uuid:deadbeef-4321-ffff-ffff-1234feebdaed",
        \\             "$defs": {
        \\                 "bar": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "$ref": "#/$defs/bar"
        \\         }
        \\     }
        \\ }
    ,
        \\ "bar"
    ,
        true,
    );
}
test "ref.URN-ref-with-nested-pointer-ref.a-non-string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "urn:uuid:deadbeef-4321-ffff-ffff-1234feebdaed",
        \\     "$defs": {
        \\         "foo": {
        \\             "$id": "urn:uuid:deadbeef-4321-ffff-ffff-1234feebdaed",
        \\             "$defs": {
        \\                 "bar": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "$ref": "#/$defs/bar"
        \\         }
        \\     }
        \\ }
    ,
        \\ 12
    ,
        false,
    );
}
test "ref.ref-to-if.a-non-integer-is-invalid-due-to-the-$ref" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://example.com/ref/if",
        \\     "if": {
        \\         "$id": "http://example.com/ref/if",
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "ref.ref-to-if.an-integer-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://example.com/ref/if",
        \\     "if": {
        \\         "$id": "http://example.com/ref/if",
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "ref.ref-to-then.a-non-integer-is-invalid-due-to-the-$ref" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://example.com/ref/then",
        \\     "then": {
        \\         "$id": "http://example.com/ref/then",
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "ref.ref-to-then.an-integer-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://example.com/ref/then",
        \\     "then": {
        \\         "$id": "http://example.com/ref/then",
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "ref.ref-to-else.a-non-integer-is-invalid-due-to-the-$ref" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://example.com/ref/else",
        \\     "else": {
        \\         "$id": "http://example.com/ref/else",
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "ref.ref-to-else.an-integer-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://example.com/ref/else",
        \\     "else": {
        \\         "$id": "http://example.com/ref/else",
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "ref.ref-with-absolute-path-reference.a-string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://example.com/ref/absref.json",
        \\     "$defs": {
        \\         "a": {
        \\             "$id": "http://example.com/ref/absref/foobar.json",
        \\             "type": "number"
        \\         },
        \\         "b": {
        \\             "$id": "http://example.com/absref/foobar.json",
        \\             "type": "string"
        \\         }
        \\     },
        \\     "$ref": "/absref/foobar.json"
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "ref.ref-with-absolute-path-reference.an-integer-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://example.com/ref/absref.json",
        \\     "$defs": {
        \\         "a": {
        \\             "$id": "http://example.com/ref/absref/foobar.json",
        \\             "type": "number"
        \\         },
        \\         "b": {
        \\             "$id": "http://example.com/absref/foobar.json",
        \\             "type": "string"
        \\         }
        \\     },
        \\     "$ref": "/absref/foobar.json"
        \\ }
    ,
        \\ 12
    ,
        false,
    );
}
test "ref.$id-with-file-URI-still-resolves-pointers---*nix.number-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "file:///folder/file.json",
        \\     "$defs": {
        \\         "foo": {
        \\             "type": "number"
        \\         }
        \\     },
        \\     "$ref": "#/$defs/foo"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "ref.$id-with-file-URI-still-resolves-pointers---*nix.non-number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "file:///folder/file.json",
        \\     "$defs": {
        \\         "foo": {
        \\             "type": "number"
        \\         }
        \\     },
        \\     "$ref": "#/$defs/foo"
        \\ }
    ,
        \\ "a"
    ,
        false,
    );
}
test "ref.$id-with-file-URI-still-resolves-pointers---windows.number-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "file:///c:/folder/file.json",
        \\     "$defs": {
        \\         "foo": {
        \\             "type": "number"
        \\         }
        \\     },
        \\     "$ref": "#/$defs/foo"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "ref.$id-with-file-URI-still-resolves-pointers---windows.non-number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "file:///c:/folder/file.json",
        \\     "$defs": {
        \\         "foo": {
        \\             "type": "number"
        \\         }
        \\     },
        \\     "$ref": "#/$defs/foo"
        \\ }
    ,
        \\ "a"
    ,
        false,
    );
}
test "ref.empty-tokens-in-$ref-json-pointer.number-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "": {
        \\             "$defs": {
        \\                 "": {
        \\                     "type": "number"
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/$defs//$defs/"
        \\         }
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "ref.empty-tokens-in-$ref-json-pointer.non-number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "": {
        \\             "$defs": {
        \\                 "": {
        \\                     "type": "number"
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/$defs//$defs/"
        \\         }
        \\     ]
        \\ }
    ,
        \\ "a"
    ,
        false,
    );
}
test "ref.$ref-with-$recursiveAnchor.extra-items-allowed-for-inner-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "https://example.com/schemas/unevaluated-items-are-disallowed",
        \\     "$ref": "/schemas/unevaluated-items-are-allowed",
        \\     "$recursiveAnchor": true,
        \\     "unevaluatedItems": false,
        \\     "$defs": {
        \\         "/schemas/unevaluated-items-are-allowed": {
        \\             "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\             "$id": "/schemas/unevaluated-items-are-allowed",
        \\             "$recursiveAnchor": true,
        \\             "type": "array",
        \\             "items": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "$ref": "#"
        \\                 }
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     [
        \\         "bar",
        \\         [],
        \\         8
        \\     ]
        \\ ]
    ,
        true,
    );
}
test "ref.$ref-with-$recursiveAnchor.extra-items-disallowed-for-root" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "https://example.com/schemas/unevaluated-items-are-disallowed",
        \\     "$ref": "/schemas/unevaluated-items-are-allowed",
        \\     "$recursiveAnchor": true,
        \\     "unevaluatedItems": false,
        \\     "$defs": {
        \\         "/schemas/unevaluated-items-are-allowed": {
        \\             "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\             "$id": "/schemas/unevaluated-items-are-allowed",
        \\             "$recursiveAnchor": true,
        \\             "type": "array",
        \\             "items": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "$ref": "#"
        \\                 }
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     [
        \\         "bar",
        \\         [],
        \\         8
        \\     ],
        \\     8
        \\ ]
    ,
        false,
    );
}
test "contains.contains-keyword-validation.array-with-item-matching-schema-(5)-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "minimum": 5
        \\     }
        \\ }
    ,
        \\ [
        \\     3,
        \\     4,
        \\     5
        \\ ]
    ,
        true,
    );
}
test "contains.contains-keyword-validation.array-with-item-matching-schema-(6)-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "minimum": 5
        \\     }
        \\ }
    ,
        \\ [
        \\     3,
        \\     4,
        \\     6
        \\ ]
    ,
        true,
    );
}
test "contains.contains-keyword-validation.array-with-two-items-matching-schema-(5,-6)-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "minimum": 5
        \\     }
        \\ }
    ,
        \\ [
        \\     3,
        \\     4,
        \\     5,
        \\     6
        \\ ]
    ,
        true,
    );
}
test "contains.contains-keyword-validation.array-without-items-matching-schema-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "minimum": 5
        \\     }
        \\ }
    ,
        \\ [
        \\     2,
        \\     3,
        \\     4
        \\ ]
    ,
        false,
    );
}
test "contains.contains-keyword-validation.empty-array-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "minimum": 5
        \\     }
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "contains.contains-keyword-validation.not-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "minimum": 5
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "contains.contains-keyword-with-const-keyword.array-with-item-5-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 5
        \\     }
        \\ }
    ,
        \\ [
        \\     3,
        \\     4,
        \\     5
        \\ ]
    ,
        true,
    );
}
test "contains.contains-keyword-with-const-keyword.array-with-two-items-5-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 5
        \\     }
        \\ }
    ,
        \\ [
        \\     3,
        \\     4,
        \\     5,
        \\     5
        \\ ]
    ,
        true,
    );
}
test "contains.contains-keyword-with-const-keyword.array-without-item-5-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 5
        \\     }
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3,
        \\     4
        \\ ]
    ,
        false,
    );
}
test "contains.contains-keyword-with-boolean-schema-true.any-non-empty-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": true
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        true,
    );
}
test "contains.contains-keyword-with-boolean-schema-true.empty-array-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": true
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "contains.contains-keyword-with-boolean-schema-false.any-non-empty-array-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": false
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        false,
    );
}
test "contains.contains-keyword-with-boolean-schema-false.empty-array-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": false
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "contains.contains-keyword-with-boolean-schema-false.non-arrays-are-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": false
        \\ }
    ,
        \\ "contains does not apply to strings"
    ,
        true,
    );
}
test "contains.items-+-contains.matches-items,-does-not-match-contains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": {
        \\         "multipleOf": 2
        \\     },
        \\     "contains": {
        \\         "multipleOf": 3
        \\     }
        \\ }
    ,
        \\ [
        \\     2,
        \\     4,
        \\     8
        \\ ]
    ,
        false,
    );
}
test "contains.items-+-contains.does-not-match-items,-matches-contains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": {
        \\         "multipleOf": 2
        \\     },
        \\     "contains": {
        \\         "multipleOf": 3
        \\     }
        \\ }
    ,
        \\ [
        \\     3,
        \\     6,
        \\     9
        \\ ]
    ,
        false,
    );
}
test "contains.items-+-contains.matches-both-items-and-contains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": {
        \\         "multipleOf": 2
        \\     },
        \\     "contains": {
        \\         "multipleOf": 3
        \\     }
        \\ }
    ,
        \\ [
        \\     6,
        \\     12
        \\ ]
    ,
        true,
    );
}
test "contains.items-+-contains.matches-neither-items-nor-contains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": {
        \\         "multipleOf": 2
        \\     },
        \\     "contains": {
        \\         "multipleOf": 3
        \\     }
        \\ }
    ,
        \\ [
        \\     1,
        \\     5
        \\ ]
    ,
        false,
    );
}
test "contains.contains-with-false-if-subschema.any-non-empty-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "if": false,
        \\         "else": true
        \\     }
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        true,
    );
}
test "contains.contains-with-false-if-subschema.empty-array-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "if": false,
        \\         "else": true
        \\     }
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "contains.contains-with-null-instance-elements.allows-null-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "type": "null"
        \\     }
        \\ }
    ,
        \\ [
        \\     null
        \\ ]
    ,
        true,
    );
}
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.no-additional-properties-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "patternProperties": {
        \\         "^v": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.an-additional-property-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "patternProperties": {
        \\         "^v": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "quux": "boom"
        \\ }
    ,
        false,
    );
}
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "patternProperties": {
        \\         "^v": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ,
        true,
    );
}
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.ignores-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "patternProperties": {
        \\         "^v": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ "foobarbaz"
    ,
        true,
    );
}
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.ignores-other-non-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "patternProperties": {
        \\         "^v": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.patternProperties-are-not-additional-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "patternProperties": {
        \\         "^v": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "vroom": 2
        \\ }
    ,
        true,
    );
}
test "additionalProperties.non-ASCII-pattern-with-additionalProperties.matching-the-pattern-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "^á": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "ármányos": 2
        \\ }
    ,
        true,
    );
}
test "additionalProperties.non-ASCII-pattern-with-additionalProperties.not-matching-the-pattern-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "^á": {}
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "élmény": 2
        \\ }
    ,
        false,
    );
}
test "additionalProperties.additionalProperties-with-schema.no-additional-properties-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "additionalProperties": {
        \\         "type": "boolean"
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "additionalProperties.additionalProperties-with-schema.an-additional-valid-property-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "additionalProperties": {
        \\         "type": "boolean"
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "quux": true
        \\ }
    ,
        true,
    );
}
test "additionalProperties.additionalProperties-with-schema.an-additional-invalid-property-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "additionalProperties": {
        \\         "type": "boolean"
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "quux": 12
        \\ }
    ,
        false,
    );
}
test "additionalProperties.additionalProperties-can-exist-by-itself.an-additional-valid-property-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "additionalProperties": {
        \\         "type": "boolean"
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": true
        \\ }
    ,
        true,
    );
}
test "additionalProperties.additionalProperties-can-exist-by-itself.an-additional-invalid-property-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "additionalProperties": {
        \\         "type": "boolean"
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        false,
    );
}
test "additionalProperties.additionalProperties-are-allowed-by-default.additional-properties-are-allowed" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "quux": true
        \\ }
    ,
        true,
    );
}
test "additionalProperties.additionalProperties-does-not-look-in-applicators.properties-defined-in-allOf-are-not-examined" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": true
        \\ }
    ,
        false,
    );
}
test "additionalProperties.additionalProperties-with-null-valued-instance-properties.allows-null-values" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "additionalProperties": {
        \\         "type": "null"
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": null
        \\ }
    ,
        true,
    );
}
test "additionalProperties.additionalProperties-with-propertyNames.Valid-against-both-keywords" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "maxLength": 5
        \\     },
        \\     "additionalProperties": {
        \\         "type": "number"
        \\     }
        \\ }
    ,
        \\ {
        \\     "apple": 4
        \\ }
    ,
        true,
    );
}
test "additionalProperties.additionalProperties-with-propertyNames.Valid-against-propertyNames,-but-not-additionalProperties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "maxLength": 5
        \\     },
        \\     "additionalProperties": {
        \\         "type": "number"
        \\     }
        \\ }
    ,
        \\ {
        \\     "fig": 2,
        \\     "pear": "available"
        \\ }
    ,
        false,
    );
}
test "additionalProperties.dependentSchemas-with-additionalProperties.additionalProperties-doesn't-consider-dependentSchemas" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo2": {}
        \\     },
        \\     "dependentSchemas": {
        \\         "foo": {},
        \\         "foo2": {
        \\             "properties": {
        \\                 "bar": {}
        \\             }
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": ""
        \\ }
    ,
        false,
    );
}
test "additionalProperties.dependentSchemas-with-additionalProperties.additionalProperties-can't-see-bar" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo2": {}
        \\     },
        \\     "dependentSchemas": {
        \\         "foo": {},
        \\         "foo2": {
        \\             "properties": {
        \\                 "bar": {}
        \\             }
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "bar": ""
        \\ }
    ,
        false,
    );
}
test "additionalProperties.dependentSchemas-with-additionalProperties.additionalProperties-can't-see-bar-even-when-foo2-is-present" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo2": {}
        \\     },
        \\     "dependentSchemas": {
        \\         "foo": {},
        \\         "foo2": {
        \\             "properties": {
        \\                 "bar": {}
        \\             }
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "foo2": "",
        \\     "bar": ""
        \\ }
    ,
        false,
    );
}
test "format.email-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "email"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.email-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "email"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.email-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "email"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.email-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "email"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.email-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "email"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.email-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "email"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.idn-email-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "idn-email"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.idn-email-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "idn-email"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.idn-email-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "idn-email"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.idn-email-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "idn-email"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.idn-email-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "idn-email"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.idn-email-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "idn-email"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.regex-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "regex"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.regex-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "regex"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.regex-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "regex"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.regex-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "regex"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.regex-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "regex"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.regex-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "regex"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.ipv4-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "ipv4"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.ipv4-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "ipv4"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.ipv4-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "ipv4"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.ipv4-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "ipv4"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.ipv4-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "ipv4"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.ipv4-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "ipv4"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.ipv6-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "ipv6"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.ipv6-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "ipv6"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.ipv6-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "ipv6"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.ipv6-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "ipv6"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.ipv6-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "ipv6"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.ipv6-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "ipv6"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.idn-hostname-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "idn-hostname"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.idn-hostname-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "idn-hostname"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.idn-hostname-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "idn-hostname"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.idn-hostname-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "idn-hostname"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.idn-hostname-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "idn-hostname"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.idn-hostname-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "idn-hostname"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.hostname-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "hostname"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.hostname-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "hostname"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.hostname-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "hostname"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.hostname-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "hostname"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.hostname-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "hostname"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.hostname-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "hostname"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.date-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "date"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.date-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "date"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.date-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "date"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.date-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "date"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.date-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "date"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.date-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "date"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.date-time-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "date-time"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.date-time-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "date-time"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.date-time-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "date-time"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.date-time-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "date-time"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.date-time-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "date-time"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.date-time-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "date-time"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.time-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "time"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.time-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "time"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.time-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "time"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.time-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "time"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.time-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "time"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.time-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "time"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.json-pointer-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "json-pointer"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.json-pointer-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "json-pointer"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.json-pointer-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "json-pointer"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.json-pointer-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "json-pointer"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.json-pointer-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "json-pointer"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.json-pointer-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "json-pointer"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.relative-json-pointer-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "relative-json-pointer"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.relative-json-pointer-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "relative-json-pointer"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.relative-json-pointer-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "relative-json-pointer"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.relative-json-pointer-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "relative-json-pointer"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.relative-json-pointer-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "relative-json-pointer"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.relative-json-pointer-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "relative-json-pointer"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.iri-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "iri"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.iri-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "iri"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.iri-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "iri"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.iri-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "iri"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.iri-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "iri"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.iri-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "iri"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.iri-reference-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "iri-reference"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.iri-reference-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "iri-reference"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.iri-reference-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "iri-reference"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.iri-reference-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "iri-reference"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.iri-reference-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "iri-reference"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.iri-reference-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "iri-reference"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.uri-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.uri-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.uri-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.uri-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.uri-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.uri-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.uri-reference-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri-reference"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.uri-reference-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri-reference"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.uri-reference-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri-reference"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.uri-reference-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri-reference"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.uri-reference-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri-reference"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.uri-reference-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri-reference"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.uri-template-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri-template"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.uri-template-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri-template"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.uri-template-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri-template"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.uri-template-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri-template"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.uri-template-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri-template"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.uri-template-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uri-template"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.uuid-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uuid"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.uuid-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uuid"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.uuid-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uuid"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.uuid-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uuid"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.uuid-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uuid"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.uuid-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "uuid"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "format.duration-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "duration"
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "format.duration-format.all-string-formats-ignore-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "duration"
        \\ }
    ,
        \\ 13.7
    ,
        true,
    );
}
test "format.duration-format.all-string-formats-ignore-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "duration"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "format.duration-format.all-string-formats-ignore-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "duration"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "format.duration-format.all-string-formats-ignore-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "duration"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "format.duration-format.all-string-formats-ignore-nulls" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "format": "duration"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "not.not.allowed" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "not.not.disallowed" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "not.not-multiple-types.valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {
        \\         "type": [
        \\             "integer",
        \\             "boolean"
        \\         ]
        \\     }
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "not.not-multiple-types.mismatch" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {
        \\         "type": [
        \\             "integer",
        \\             "boolean"
        \\         ]
        \\     }
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "not.not-multiple-types.other-mismatch" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {
        \\         "type": [
        \\             "integer",
        \\             "boolean"
        \\         ]
        \\     }
        \\ }
    ,
        \\ true
    ,
        false,
    );
}
test "not.not-more-complex-schema.match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {
        \\         "type": "object",
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "not.not-more-complex-schema.other-match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {
        \\         "type": "object",
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "not.not-more-complex-schema.mismatch" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {
        \\         "type": "object",
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        false,
    );
}
test "not.forbidden-property.property-present" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "not": {}
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "not.forbidden-property.property-absent" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "not": {}
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "bar": 1,
        \\     "baz": 2
        \\ }
    ,
        true,
    );
}
test "not.forbid-everything-with-empty-schema.number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {}
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "not.forbid-everything-with-empty-schema.string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {}
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "not.forbid-everything-with-empty-schema.boolean-true-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {}
        \\ }
    ,
        \\ true
    ,
        false,
    );
}
test "not.forbid-everything-with-empty-schema.boolean-false-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {}
        \\ }
    ,
        \\ false
    ,
        false,
    );
}
test "not.forbid-everything-with-empty-schema.null-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {}
        \\ }
    ,
        \\ null
    ,
        false,
    );
}
test "not.forbid-everything-with-empty-schema.object-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {}
        \\ }
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        false,
    );
}
test "not.forbid-everything-with-empty-schema.empty-object-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {}
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "not.forbid-everything-with-empty-schema.array-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {}
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        false,
    );
}
test "not.forbid-everything-with-empty-schema.empty-array-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {}
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "not.forbid-everything-with-boolean-schema-true.number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": true
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "not.forbid-everything-with-boolean-schema-true.string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": true
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "not.forbid-everything-with-boolean-schema-true.boolean-true-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": true
        \\ }
    ,
        \\ true
    ,
        false,
    );
}
test "not.forbid-everything-with-boolean-schema-true.boolean-false-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": true
        \\ }
    ,
        \\ false
    ,
        false,
    );
}
test "not.forbid-everything-with-boolean-schema-true.null-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": true
        \\ }
    ,
        \\ null
    ,
        false,
    );
}
test "not.forbid-everything-with-boolean-schema-true.object-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": true
        \\ }
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        false,
    );
}
test "not.forbid-everything-with-boolean-schema-true.empty-object-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": true
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "not.forbid-everything-with-boolean-schema-true.array-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": true
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        false,
    );
}
test "not.forbid-everything-with-boolean-schema-true.empty-array-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": true
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "not.allow-everything-with-boolean-schema-false.number-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": false
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "not.allow-everything-with-boolean-schema-false.string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": false
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "not.allow-everything-with-boolean-schema-false.boolean-true-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": false
        \\ }
    ,
        \\ true
    ,
        true,
    );
}
test "not.allow-everything-with-boolean-schema-false.boolean-false-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": false
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "not.allow-everything-with-boolean-schema-false.null-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": false
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "not.allow-everything-with-boolean-schema-false.object-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": false
        \\ }
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        true,
    );
}
test "not.allow-everything-with-boolean-schema-false.empty-object-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": false
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "not.allow-everything-with-boolean-schema-false.array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": false
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        true,
    );
}
test "not.allow-everything-with-boolean-schema-false.empty-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": false
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "not.double-negation.any-value-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {
        \\         "not": {}
        \\     }
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "not.collect-annotations-inside-a-'not',-even-if-collection-is-disabled.unevaluated-property" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {
        \\         "$comment": "this subschema must still produce annotations internally, even though the 'not' will ultimately discard them",
        \\         "anyOf": [
        \\             true,
        \\             {
        \\                 "properties": {
        \\                     "foo": true
        \\                 }
        \\             }
        \\         ],
        \\         "unevaluatedProperties": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "bar": 1
        \\ }
    ,
        true,
    );
}
test "not.collect-annotations-inside-a-'not',-even-if-collection-is-disabled.annotations-are-still-collected-inside-a-'not'" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "not": {
        \\         "$comment": "this subschema must still produce annotations internally, even though the 'not' will ultimately discard them",
        \\         "anyOf": [
        \\             true,
        \\             {
        \\                 "properties": {
        \\                     "foo": true
        \\                 }
        \\             }
        \\         ],
        \\         "unevaluatedProperties": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        false,
    );
}
test "maximum.maximum-validation.below-the-maximum-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maximum": 3
        \\ }
    ,
        \\ 2.6
    ,
        true,
    );
}
test "maximum.maximum-validation.boundary-point-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maximum": 3
        \\ }
    ,
        \\ 3
    ,
        true,
    );
}
test "maximum.maximum-validation.above-the-maximum-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maximum": 3
        \\ }
    ,
        \\ 3.5
    ,
        false,
    );
}
test "maximum.maximum-validation.ignores-non-numbers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maximum": 3
        \\ }
    ,
        \\ "x"
    ,
        true,
    );
}
test "maximum.maximum-validation-with-unsigned-integer.below-the-maximum-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maximum": 300
        \\ }
    ,
        \\ 299.97
    ,
        true,
    );
}
test "maximum.maximum-validation-with-unsigned-integer.boundary-point-integer-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maximum": 300
        \\ }
    ,
        \\ 300
    ,
        true,
    );
}
test "maximum.maximum-validation-with-unsigned-integer.boundary-point-float-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maximum": 300
        \\ }
    ,
        \\ 300
    ,
        true,
    );
}
test "maximum.maximum-validation-with-unsigned-integer.above-the-maximum-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maximum": 300
        \\ }
    ,
        \\ 300.5
    ,
        false,
    );
}
test "minItems.minItems-validation.longer-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minItems": 1
        \\ }
    ,
        \\ [
        \\     1,
        \\     2
        \\ ]
    ,
        true,
    );
}
test "minItems.minItems-validation.exact-length-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minItems": 1
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "minItems.minItems-validation.too-short-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minItems": 1
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "minItems.minItems-validation.ignores-non-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minItems": 1
        \\ }
    ,
        \\ ""
    ,
        true,
    );
}
test "minItems.minItems-validation-with-a-decimal.longer-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minItems": 1
        \\ }
    ,
        \\ [
        \\     1,
        \\     2
        \\ ]
    ,
        true,
    );
}
test "minItems.minItems-validation-with-a-decimal.too-short-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minItems": 1
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "minLength.minLength-validation.longer-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minLength": 2
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "minLength.minLength-validation.exact-length-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minLength": 2
        \\ }
    ,
        \\ "fo"
    ,
        true,
    );
}
test "minLength.minLength-validation.too-short-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minLength": 2
        \\ }
    ,
        \\ "f"
    ,
        false,
    );
}
test "minLength.minLength-validation.ignores-non-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minLength": 2
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "minLength.minLength-validation.one-grapheme-is-not-long-enough" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minLength": 2
        \\ }
    ,
        \\ "💩"
    ,
        false,
    );
}
test "minLength.minLength-validation-with-a-decimal.longer-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minLength": 2
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "minLength.minLength-validation-with-a-decimal.too-short-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minLength": 2
        \\ }
    ,
        \\ "f"
    ,
        false,
    );
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.a-single-valid-match-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.multiple-valid-matches-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "foooooo": 2
        \\ }
    ,
        true,
    );
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.a-single-invalid-match-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "bar",
        \\     "fooooo": 2
        \\ }
    ,
        false,
    );
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.multiple-invalid-matches-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "bar",
        \\     "foooooo": "baz"
        \\ }
    ,
        false,
    );
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        true,
    );
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.ignores-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.ignores-other-non-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "patternProperties.multiple-simultaneous-patternProperties-are-validated.a-single-valid-match-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "a*": {
        \\             "type": "integer"
        \\         },
        \\         "aaa*": {
        \\             "maximum": 20
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "a": 21
        \\ }
    ,
        true,
    );
}
test "patternProperties.multiple-simultaneous-patternProperties-are-validated.a-simultaneous-match-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "a*": {
        \\             "type": "integer"
        \\         },
        \\         "aaa*": {
        \\             "maximum": 20
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "aaaa": 18
        \\ }
    ,
        true,
    );
}
test "patternProperties.multiple-simultaneous-patternProperties-are-validated.multiple-matches-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "a*": {
        \\             "type": "integer"
        \\         },
        \\         "aaa*": {
        \\             "maximum": 20
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "a": 21,
        \\     "aaaa": 18
        \\ }
    ,
        true,
    );
}
test "patternProperties.multiple-simultaneous-patternProperties-are-validated.an-invalid-due-to-one-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "a*": {
        \\             "type": "integer"
        \\         },
        \\         "aaa*": {
        \\             "maximum": 20
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "a": "bar"
        \\ }
    ,
        false,
    );
}
test "patternProperties.multiple-simultaneous-patternProperties-are-validated.an-invalid-due-to-the-other-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "a*": {
        \\             "type": "integer"
        \\         },
        \\         "aaa*": {
        \\             "maximum": 20
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "aaaa": 31
        \\ }
    ,
        false,
    );
}
test "patternProperties.multiple-simultaneous-patternProperties-are-validated.an-invalid-due-to-both-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "a*": {
        \\             "type": "integer"
        \\         },
        \\         "aaa*": {
        \\             "maximum": 20
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "aaa": "foo",
        \\     "aaaa": 31
        \\ }
    ,
        false,
    );
}
test "patternProperties.regexes-are-not-anchored-by-default-and-are-case-sensitive.non-recognized-members-are-ignored" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "[0-9]{2,}": {
        \\             "type": "boolean"
        \\         },
        \\         "X_": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "answer 1": "42"
        \\ }
    ,
        true,
    );
}
test "patternProperties.regexes-are-not-anchored-by-default-and-are-case-sensitive.recognized-members-are-accounted-for" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "[0-9]{2,}": {
        \\             "type": "boolean"
        \\         },
        \\         "X_": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "a31b": null
        \\ }
    ,
        false,
    );
}
test "patternProperties.regexes-are-not-anchored-by-default-and-are-case-sensitive.regexes-are-case-sensitive" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "[0-9]{2,}": {
        \\             "type": "boolean"
        \\         },
        \\         "X_": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "a_x_3": 3
        \\ }
    ,
        true,
    );
}
test "patternProperties.regexes-are-not-anchored-by-default-and-are-case-sensitive.regexes-are-case-sensitive,-2" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "[0-9]{2,}": {
        \\             "type": "boolean"
        \\         },
        \\         "X_": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "a_X_3": 3
        \\ }
    ,
        false,
    );
}
test "patternProperties.patternProperties-with-boolean-schemas.object-with-property-matching-schema-true-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "f.*": true,
        \\         "b.*": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "patternProperties.patternProperties-with-boolean-schemas.object-with-property-matching-schema-false-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "f.*": true,
        \\         "b.*": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "patternProperties.patternProperties-with-boolean-schemas.object-with-both-properties-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "f.*": true,
        \\         "b.*": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "patternProperties.patternProperties-with-boolean-schemas.object-with-a-property-matching-both-true-and-false-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "f.*": true,
        \\         "b.*": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "foobar": 1
        \\ }
    ,
        false,
    );
}
test "patternProperties.patternProperties-with-boolean-schemas.empty-object-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "f.*": true,
        \\         "b.*": false
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "patternProperties.patternProperties-with-null-valued-instance-properties.allows-null-values" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "patternProperties": {
        \\         "^.*bar$": {
        \\             "type": "null"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foobar": null
        \\ }
    ,
        true,
    );
}
test "dependentSchemas.single-dependency.valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
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
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        true,
    );
}
test "dependentSchemas.single-dependency.no-dependency" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
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
    ,
        \\ {
        \\     "foo": "quux"
        \\ }
    ,
        true,
    );
}
test "dependentSchemas.single-dependency.wrong-type" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
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
    ,
        \\ {
        \\     "foo": "quux",
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "dependentSchemas.single-dependency.wrong-type-other" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
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
    ,
        \\ {
        \\     "foo": 2,
        \\     "bar": "quux"
        \\ }
    ,
        false,
    );
}
test "dependentSchemas.single-dependency.wrong-type-both" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
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
    ,
        \\ {
        \\     "foo": "quux",
        \\     "bar": "quux"
        \\ }
    ,
        false,
    );
}
test "dependentSchemas.single-dependency.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
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
    ,
        \\ [
        \\     "bar"
        \\ ]
    ,
        true,
    );
}
test "dependentSchemas.single-dependency.ignores-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
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
    ,
        \\ "foobar"
    ,
        true,
    );
}
test "dependentSchemas.single-dependency.ignores-other-non-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
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
    ,
        \\ 12
    ,
        true,
    );
}
test "dependentSchemas.boolean-subschemas.object-with-property-having-schema-true-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
        \\         "foo": true,
        \\         "bar": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "dependentSchemas.boolean-subschemas.object-with-property-having-schema-false-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
        \\         "foo": true,
        \\         "bar": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "dependentSchemas.boolean-subschemas.object-with-both-properties-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
        \\         "foo": true,
        \\         "bar": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "dependentSchemas.boolean-subschemas.empty-object-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
        \\         "foo": true,
        \\         "bar": false
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "dependentSchemas.dependencies-with-escaped-characters.quoted-tab" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
        \\         "foo\tbar": {
        \\             "minProperties": 4
        \\         },
        \\         "foo'bar": {
        \\             "required": [
        \\                 "foo\"bar"
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo\tbar": 1,
        \\     "a": 2,
        \\     "b": 3,
        \\     "c": 4
        \\ }
    ,
        true,
    );
}
test "dependentSchemas.dependencies-with-escaped-characters.quoted-quote" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
        \\         "foo\tbar": {
        \\             "minProperties": 4
        \\         },
        \\         "foo'bar": {
        \\             "required": [
        \\                 "foo\"bar"
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo'bar": {
        \\         "foo\"bar": 1
        \\     }
        \\ }
    ,
        false,
    );
}
test "dependentSchemas.dependencies-with-escaped-characters.quoted-tab-invalid-under-dependent-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
        \\         "foo\tbar": {
        \\             "minProperties": 4
        \\         },
        \\         "foo'bar": {
        \\             "required": [
        \\                 "foo\"bar"
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo\tbar": 1,
        \\     "a": 2
        \\ }
    ,
        false,
    );
}
test "dependentSchemas.dependencies-with-escaped-characters.quoted-quote-invalid-under-dependent-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "dependentSchemas": {
        \\         "foo\tbar": {
        \\             "minProperties": 4
        \\         },
        \\         "foo'bar": {
        \\             "required": [
        \\                 "foo\"bar"
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo'bar": 1
        \\ }
    ,
        false,
    );
}
test "dependentSchemas.dependent-subschema-incompatible-with-root.matches-root" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {}
        \\     },
        \\     "dependentSchemas": {
        \\         "foo": {
        \\             "properties": {
        \\                 "bar": {}
        \\             },
        \\             "additionalProperties": false
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        false,
    );
}
test "dependentSchemas.dependent-subschema-incompatible-with-root.matches-dependency" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {}
        \\     },
        \\     "dependentSchemas": {
        \\         "foo": {
        \\             "properties": {
        \\                 "bar": {}
        \\             },
        \\             "additionalProperties": false
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "bar": 1
        \\ }
    ,
        true,
    );
}
test "dependentSchemas.dependent-subschema-incompatible-with-root.matches-both" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {}
        \\     },
        \\     "dependentSchemas": {
        \\         "foo": {
        \\             "properties": {
        \\                 "bar": {}
        \\             },
        \\             "additionalProperties": false
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "dependentSchemas.dependent-subschema-incompatible-with-root.no-dependency" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {}
        \\     },
        \\     "dependentSchemas": {
        \\         "foo": {
        \\             "properties": {
        \\                 "bar": {}
        \\             },
        \\             "additionalProperties": false
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "baz": 1
        \\ }
    ,
        true,
    );
}
test "boolean_schema.boolean-schema-'true'.number-is-valid" {
    try check_valid(
        \\ true
    ,
        \\ 1
    ,
        true,
    );
}
test "boolean_schema.boolean-schema-'true'.string-is-valid" {
    try check_valid(
        \\ true
    ,
        \\ "foo"
    ,
        true,
    );
}
test "boolean_schema.boolean-schema-'true'.boolean-true-is-valid" {
    try check_valid(
        \\ true
    ,
        \\ true
    ,
        true,
    );
}
test "boolean_schema.boolean-schema-'true'.boolean-false-is-valid" {
    try check_valid(
        \\ true
    ,
        \\ false
    ,
        true,
    );
}
test "boolean_schema.boolean-schema-'true'.null-is-valid" {
    try check_valid(
        \\ true
    ,
        \\ null
    ,
        true,
    );
}
test "boolean_schema.boolean-schema-'true'.object-is-valid" {
    try check_valid(
        \\ true
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        true,
    );
}
test "boolean_schema.boolean-schema-'true'.empty-object-is-valid" {
    try check_valid(
        \\ true
    ,
        \\ {}
    ,
        true,
    );
}
test "boolean_schema.boolean-schema-'true'.array-is-valid" {
    try check_valid(
        \\ true
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        true,
    );
}
test "boolean_schema.boolean-schema-'true'.empty-array-is-valid" {
    try check_valid(
        \\ true
    ,
        \\ []
    ,
        true,
    );
}
test "boolean_schema.boolean-schema-'false'.number-is-invalid" {
    try check_valid(
        \\ false
    ,
        \\ 1
    ,
        false,
    );
}
test "boolean_schema.boolean-schema-'false'.string-is-invalid" {
    try check_valid(
        \\ false
    ,
        \\ "foo"
    ,
        false,
    );
}
test "boolean_schema.boolean-schema-'false'.boolean-true-is-invalid" {
    try check_valid(
        \\ false
    ,
        \\ true
    ,
        false,
    );
}
test "boolean_schema.boolean-schema-'false'.boolean-false-is-invalid" {
    try check_valid(
        \\ false
    ,
        \\ false
    ,
        false,
    );
}
test "boolean_schema.boolean-schema-'false'.null-is-invalid" {
    try check_valid(
        \\ false
    ,
        \\ null
    ,
        false,
    );
}
test "boolean_schema.boolean-schema-'false'.object-is-invalid" {
    try check_valid(
        \\ false
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        false,
    );
}
test "boolean_schema.boolean-schema-'false'.empty-object-is-invalid" {
    try check_valid(
        \\ false
    ,
        \\ {}
    ,
        false,
    );
}
test "boolean_schema.boolean-schema-'false'.array-is-invalid" {
    try check_valid(
        \\ false
    ,
        \\ [
        \\     "foo"
        \\ ]
    ,
        false,
    );
}
test "boolean_schema.boolean-schema-'false'.empty-array-is-invalid" {
    try check_valid(
        \\ false
    ,
        \\ []
    ,
        false,
    );
}
test "minimum.minimum-validation.above-the-minimum-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minimum": 1.1
        \\ }
    ,
        \\ 2.6
    ,
        true,
    );
}
test "minimum.minimum-validation.boundary-point-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minimum": 1.1
        \\ }
    ,
        \\ 1.1
    ,
        true,
    );
}
test "minimum.minimum-validation.below-the-minimum-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minimum": 1.1
        \\ }
    ,
        \\ 0.6
    ,
        false,
    );
}
test "minimum.minimum-validation.ignores-non-numbers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minimum": 1.1
        \\ }
    ,
        \\ "x"
    ,
        true,
    );
}
test "minimum.minimum-validation-with-signed-integer.negative-above-the-minimum-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minimum": -2
        \\ }
    ,
        \\ -1
    ,
        true,
    );
}
test "minimum.minimum-validation-with-signed-integer.positive-above-the-minimum-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minimum": -2
        \\ }
    ,
        \\ 0
    ,
        true,
    );
}
test "minimum.minimum-validation-with-signed-integer.boundary-point-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minimum": -2
        \\ }
    ,
        \\ -2
    ,
        true,
    );
}
test "minimum.minimum-validation-with-signed-integer.boundary-point-with-float-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minimum": -2
        \\ }
    ,
        \\ -2
    ,
        true,
    );
}
test "minimum.minimum-validation-with-signed-integer.float-below-the-minimum-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minimum": -2
        \\ }
    ,
        \\ -2.0001
    ,
        false,
    );
}
test "minimum.minimum-validation-with-signed-integer.int-below-the-minimum-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minimum": -2
        \\ }
    ,
        \\ -3
    ,
        false,
    );
}
test "minimum.minimum-validation-with-signed-integer.ignores-non-numbers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minimum": -2
        \\ }
    ,
        \\ "x"
    ,
        true,
    );
}
test "type.integer-type-matches-integers.an-integer-is-an-integer" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "integer"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "type.integer-type-matches-integers.a-float-with-zero-fractional-part-is-an-integer" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "integer"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "type.integer-type-matches-integers.a-float-is-not-an-integer" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "integer"
        \\ }
    ,
        \\ 1.1
    ,
        false,
    );
}
test "type.integer-type-matches-integers.a-string-is-not-an-integer" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "integer"
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "type.integer-type-matches-integers.a-string-is-still-not-an-integer,-even-if-it-looks-like-one" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "integer"
        \\ }
    ,
        \\ "1"
    ,
        false,
    );
}
test "type.integer-type-matches-integers.an-object-is-not-an-integer" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "integer"
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "type.integer-type-matches-integers.an-array-is-not-an-integer" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "integer"
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "type.integer-type-matches-integers.a-boolean-is-not-an-integer" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "integer"
        \\ }
    ,
        \\ true
    ,
        false,
    );
}
test "type.integer-type-matches-integers.null-is-not-an-integer" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "integer"
        \\ }
    ,
        \\ null
    ,
        false,
    );
}
test "type.number-type-matches-numbers.an-integer-is-a-number" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "number"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "type.number-type-matches-numbers.a-float-with-zero-fractional-part-is-a-number-(and-an-integer)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "number"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "type.number-type-matches-numbers.a-float-is-a-number" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "number"
        \\ }
    ,
        \\ 1.1
    ,
        true,
    );
}
test "type.number-type-matches-numbers.a-string-is-not-a-number" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "number"
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "type.number-type-matches-numbers.a-string-is-still-not-a-number,-even-if-it-looks-like-one" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "number"
        \\ }
    ,
        \\ "1"
    ,
        false,
    );
}
test "type.number-type-matches-numbers.an-object-is-not-a-number" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "number"
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "type.number-type-matches-numbers.an-array-is-not-a-number" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "number"
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "type.number-type-matches-numbers.a-boolean-is-not-a-number" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "number"
        \\ }
    ,
        \\ true
    ,
        false,
    );
}
test "type.number-type-matches-numbers.null-is-not-a-number" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "number"
        \\ }
    ,
        \\ null
    ,
        false,
    );
}
test "type.string-type-matches-strings.1-is-not-a-string" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "string"
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "type.string-type-matches-strings.a-float-is-not-a-string" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "string"
        \\ }
    ,
        \\ 1.1
    ,
        false,
    );
}
test "type.string-type-matches-strings.a-string-is-a-string" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "string"
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "type.string-type-matches-strings.a-string-is-still-a-string,-even-if-it-looks-like-a-number" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "string"
        \\ }
    ,
        \\ "1"
    ,
        true,
    );
}
test "type.string-type-matches-strings.an-empty-string-is-still-a-string" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "string"
        \\ }
    ,
        \\ ""
    ,
        true,
    );
}
test "type.string-type-matches-strings.an-object-is-not-a-string" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "string"
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "type.string-type-matches-strings.an-array-is-not-a-string" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "string"
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "type.string-type-matches-strings.a-boolean-is-not-a-string" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "string"
        \\ }
    ,
        \\ true
    ,
        false,
    );
}
test "type.string-type-matches-strings.null-is-not-a-string" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "string"
        \\ }
    ,
        \\ null
    ,
        false,
    );
}
test "type.object-type-matches-objects.an-integer-is-not-an-object" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object"
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "type.object-type-matches-objects.a-float-is-not-an-object" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object"
        \\ }
    ,
        \\ 1.1
    ,
        false,
    );
}
test "type.object-type-matches-objects.a-string-is-not-an-object" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object"
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "type.object-type-matches-objects.an-object-is-an-object" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "type.object-type-matches-objects.an-array-is-not-an-object" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object"
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "type.object-type-matches-objects.a-boolean-is-not-an-object" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object"
        \\ }
    ,
        \\ true
    ,
        false,
    );
}
test "type.object-type-matches-objects.null-is-not-an-object" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object"
        \\ }
    ,
        \\ null
    ,
        false,
    );
}
test "type.array-type-matches-arrays.an-integer-is-not-an-array" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "array"
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "type.array-type-matches-arrays.a-float-is-not-an-array" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "array"
        \\ }
    ,
        \\ 1.1
    ,
        false,
    );
}
test "type.array-type-matches-arrays.a-string-is-not-an-array" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "array"
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "type.array-type-matches-arrays.an-object-is-not-an-array" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "array"
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "type.array-type-matches-arrays.an-array-is-an-array" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "array"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "type.array-type-matches-arrays.a-boolean-is-not-an-array" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "array"
        \\ }
    ,
        \\ true
    ,
        false,
    );
}
test "type.array-type-matches-arrays.null-is-not-an-array" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "array"
        \\ }
    ,
        \\ null
    ,
        false,
    );
}
test "type.boolean-type-matches-booleans.an-integer-is-not-a-boolean" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "boolean"
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "type.boolean-type-matches-booleans.zero-is-not-a-boolean" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "boolean"
        \\ }
    ,
        \\ 0
    ,
        false,
    );
}
test "type.boolean-type-matches-booleans.a-float-is-not-a-boolean" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "boolean"
        \\ }
    ,
        \\ 1.1
    ,
        false,
    );
}
test "type.boolean-type-matches-booleans.a-string-is-not-a-boolean" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "boolean"
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "type.boolean-type-matches-booleans.an-empty-string-is-not-a-boolean" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "boolean"
        \\ }
    ,
        \\ ""
    ,
        false,
    );
}
test "type.boolean-type-matches-booleans.an-object-is-not-a-boolean" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "boolean"
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "type.boolean-type-matches-booleans.an-array-is-not-a-boolean" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "boolean"
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "type.boolean-type-matches-booleans.true-is-a-boolean" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "boolean"
        \\ }
    ,
        \\ true
    ,
        true,
    );
}
test "type.boolean-type-matches-booleans.false-is-a-boolean" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "boolean"
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "type.boolean-type-matches-booleans.null-is-not-a-boolean" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "boolean"
        \\ }
    ,
        \\ null
    ,
        false,
    );
}
test "type.null-type-matches-only-the-null-object.an-integer-is-not-null" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "null"
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "type.null-type-matches-only-the-null-object.a-float-is-not-null" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "null"
        \\ }
    ,
        \\ 1.1
    ,
        false,
    );
}
test "type.null-type-matches-only-the-null-object.zero-is-not-null" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "null"
        \\ }
    ,
        \\ 0
    ,
        false,
    );
}
test "type.null-type-matches-only-the-null-object.a-string-is-not-null" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "null"
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "type.null-type-matches-only-the-null-object.an-empty-string-is-not-null" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "null"
        \\ }
    ,
        \\ ""
    ,
        false,
    );
}
test "type.null-type-matches-only-the-null-object.an-object-is-not-null" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "null"
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "type.null-type-matches-only-the-null-object.an-array-is-not-null" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "null"
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "type.null-type-matches-only-the-null-object.true-is-not-null" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "null"
        \\ }
    ,
        \\ true
    ,
        false,
    );
}
test "type.null-type-matches-only-the-null-object.false-is-not-null" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "null"
        \\ }
    ,
        \\ false
    ,
        false,
    );
}
test "type.null-type-matches-only-the-null-object.null-is-null" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "null"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "type.multiple-types-can-be-specified-in-an-array.an-integer-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "type.multiple-types-can-be-specified-in-an-array.a-string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "type.multiple-types-can-be-specified-in-an-array.a-float-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    ,
        \\ 1.1
    ,
        false,
    );
}
test "type.multiple-types-can-be-specified-in-an-array.an-object-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "type.multiple-types-can-be-specified-in-an-array.an-array-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "type.multiple-types-can-be-specified-in-an-array.a-boolean-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    ,
        \\ true
    ,
        false,
    );
}
test "type.multiple-types-can-be-specified-in-an-array.null-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "integer",
        \\         "string"
        \\     ]
        \\ }
    ,
        \\ null
    ,
        false,
    );
}
test "type.type-as-array-with-one-item.string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "string"
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "type.type-as-array-with-one-item.number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "string"
        \\     ]
        \\ }
    ,
        \\ 123
    ,
        false,
    );
}
test "type.type:-array-or-object.array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "array",
        \\         "object"
        \\     ]
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ,
        true,
    );
}
test "type.type:-array-or-object.object-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "array",
        \\         "object"
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 123
        \\ }
    ,
        true,
    );
}
test "type.type:-array-or-object.number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "array",
        \\         "object"
        \\     ]
        \\ }
    ,
        \\ 123
    ,
        false,
    );
}
test "type.type:-array-or-object.string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "array",
        \\         "object"
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "type.type:-array-or-object.null-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "array",
        \\         "object"
        \\     ]
        \\ }
    ,
        \\ null
    ,
        false,
    );
}
test "type.type:-array,-object-or-null.array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "array",
        \\         "object",
        \\         "null"
        \\     ]
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ,
        true,
    );
}
test "type.type:-array,-object-or-null.object-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "array",
        \\         "object",
        \\         "null"
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 123
        \\ }
    ,
        true,
    );
}
test "type.type:-array,-object-or-null.null-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "array",
        \\         "object",
        \\         "null"
        \\     ]
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "type.type:-array,-object-or-null.number-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "array",
        \\         "object",
        \\         "null"
        \\     ]
        \\ }
    ,
        \\ 123
    ,
        false,
    );
}
test "type.type:-array,-object-or-null.string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": [
        \\         "array",
        \\         "object",
        \\         "null"
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "minContains.minContains-without-contains-is-ignored.one-item-valid-against-lone-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minContains": 1
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "minContains.minContains-without-contains-is-ignored.zero-items-still-valid-against-lone-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minContains": 1
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "minContains.minContains=1-with-contains.empty-data" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "minContains.minContains=1-with-contains.no-elements-match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1
        \\ }
    ,
        \\ [
        \\     2
        \\ ]
    ,
        false,
    );
}
test "minContains.minContains=1-with-contains.single-element-matches,-valid-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "minContains.minContains=1-with-contains.some-elements-match,-valid-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1
        \\ }
    ,
        \\ [
        \\     1,
        \\     2
        \\ ]
    ,
        true,
    );
}
test "minContains.minContains=1-with-contains.all-elements-match,-valid-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1
        \\ }
    ,
        \\ [
        \\     1,
        \\     1
        \\ ]
    ,
        true,
    );
}
test "minContains.minContains=2-with-contains.empty-data" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "minContains.minContains=2-with-contains.all-elements-match,-invalid-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        false,
    );
}
test "minContains.minContains=2-with-contains.some-elements-match,-invalid-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
        \\ }
    ,
        \\ [
        \\     1,
        \\     2
        \\ ]
    ,
        false,
    );
}
test "minContains.minContains=2-with-contains.all-elements-match,-valid-minContains-(exactly-as-needed)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
        \\ }
    ,
        \\ [
        \\     1,
        \\     1
        \\ ]
    ,
        true,
    );
}
test "minContains.minContains=2-with-contains.all-elements-match,-valid-minContains-(more-than-needed)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
        \\ }
    ,
        \\ [
        \\     1,
        \\     1,
        \\     1
        \\ ]
    ,
        true,
    );
}
test "minContains.minContains=2-with-contains.some-elements-match,-valid-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     1
        \\ ]
    ,
        true,
    );
}
test "minContains.minContains=2-with-contains-with-a-decimal-value.one-element-matches,-invalid-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        false,
    );
}
test "minContains.minContains=2-with-contains-with-a-decimal-value.both-elements-match,-valid-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
        \\ }
    ,
        \\ [
        \\     1,
        \\     1
        \\ ]
    ,
        true,
    );
}
test "minContains.maxContains-=-minContains.empty-data" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 2,
        \\     "minContains": 2
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "minContains.maxContains-=-minContains.all-elements-match,-invalid-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 2,
        \\     "minContains": 2
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        false,
    );
}
test "minContains.maxContains-=-minContains.all-elements-match,-invalid-maxContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 2,
        \\     "minContains": 2
        \\ }
    ,
        \\ [
        \\     1,
        \\     1,
        \\     1
        \\ ]
    ,
        false,
    );
}
test "minContains.maxContains-=-minContains.all-elements-match,-valid-maxContains-and-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 2,
        \\     "minContains": 2
        \\ }
    ,
        \\ [
        \\     1,
        \\     1
        \\ ]
    ,
        true,
    );
}
test "minContains.maxContains-<-minContains.empty-data" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1,
        \\     "minContains": 3
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "minContains.maxContains-<-minContains.invalid-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1,
        \\     "minContains": 3
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        false,
    );
}
test "minContains.maxContains-<-minContains.invalid-maxContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1,
        \\     "minContains": 3
        \\ }
    ,
        \\ [
        \\     1,
        \\     1,
        \\     1
        \\ ]
    ,
        false,
    );
}
test "minContains.maxContains-<-minContains.invalid-maxContains-and-minContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1,
        \\     "minContains": 3
        \\ }
    ,
        \\ [
        \\     1,
        \\     1
        \\ ]
    ,
        false,
    );
}
test "minContains.minContains-=-0-with-no-maxContains.empty-data" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 0
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "minContains.minContains-=-0-with-no-maxContains.minContains-=-0-makes-contains-always-pass" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 0
        \\ }
    ,
        \\ [
        \\     2
        \\ ]
    ,
        true,
    );
}
test "minContains.minContains-=-0-with-maxContains.empty-data" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 0,
        \\     "maxContains": 1
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "minContains.minContains-=-0-with-maxContains.not-more-than-maxContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 0,
        \\     "maxContains": 1
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "minContains.minContains-=-0-with-maxContains.too-many" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 0,
        \\     "maxContains": 1
        \\ }
    ,
        \\ [
        \\     1,
        \\     1
        \\ ]
    ,
        false,
    );
}
test "properties.object-properties-validation.both-properties-present-and-valid-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": "baz"
        \\ }
    ,
        true,
    );
}
test "properties.object-properties-validation.one-property-invalid-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": {}
        \\ }
    ,
        false,
    );
}
test "properties.object-properties-validation.both-properties-invalid-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": [],
        \\     "bar": {}
        \\ }
    ,
        false,
    );
}
test "properties.object-properties-validation.doesn't-invalidate-other-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "quux": []
        \\ }
    ,
        true,
    );
}
test "properties.object-properties-validation.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "properties.object-properties-validation.ignores-other-non-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer"
        \\         },
        \\         "bar": {
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.property-validates-property" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": [
        \\         1,
        \\         2
        \\     ]
        \\ }
    ,
        true,
    );
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.property-invalidates-property" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": [
        \\         1,
        \\         2,
        \\         3,
        \\         4
        \\     ]
        \\ }
    ,
        false,
    );
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.patternProperty-invalidates-property" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": []
        \\ }
    ,
        false,
    );
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.patternProperty-validates-nonproperty" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "fxo": [
        \\         1,
        \\         2
        \\     ]
        \\ }
    ,
        true,
    );
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.patternProperty-invalidates-nonproperty" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "fxo": []
        \\ }
    ,
        false,
    );
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.additionalProperty-ignores-property" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "bar": []
        \\ }
    ,
        true,
    );
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.additionalProperty-validates-others" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "quux": 3
        \\ }
    ,
        true,
    );
}
test "properties.properties,-patternProperties,-additionalProperties-interaction.additionalProperty-invalidates-others" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "quux": "foo"
        \\ }
    ,
        false,
    );
}
test "properties.properties-with-boolean-schema.no-property-present-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": true,
        \\         "bar": false
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "properties.properties-with-boolean-schema.only-'true'-property-present-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": true,
        \\         "bar": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "properties.properties-with-boolean-schema.only-'false'-property-present-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": true,
        \\         "bar": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "properties.properties-with-boolean-schema.both-properties-present-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": true,
        \\         "bar": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "properties.properties-with-escaped-characters.object-with-all-numbers-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo\nbar": 1,
        \\     "foo\"bar": 1,
        \\     "foo\\bar": 1,
        \\     "foo\rbar": 1,
        \\     "foo\tbar": 1,
        \\     "foo\fbar": 1
        \\ }
    ,
        true,
    );
}
test "properties.properties-with-escaped-characters.object-with-strings-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo\nbar": "1",
        \\     "foo\"bar": "1",
        \\     "foo\\bar": "1",
        \\     "foo\rbar": "1",
        \\     "foo\tbar": "1",
        \\     "foo\fbar": "1"
        \\ }
    ,
        false,
    );
}
test "properties.properties-with-null-valued-instance-properties.allows-null-values" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "null"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": null
        \\ }
    ,
        true,
    );
}
test "properties.properties-whose-names-are-Javascript-object-property-names.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ []
    ,
        true,
    );
}
test "properties.properties-whose-names-are-Javascript-object-property-names.ignores-other-non-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 12
    ,
        true,
    );
}
test "properties.properties-whose-names-are-Javascript-object-property-names.none-of-the-properties-mentioned" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {}
    ,
        true,
    );
}
test "properties.properties-whose-names-are-Javascript-object-property-names.__proto__-not-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "__proto__": "foo"
        \\ }
    ,
        false,
    );
}
test "properties.properties-whose-names-are-Javascript-object-property-names.toString-not-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "toString": {
        \\         "length": 37
        \\     }
        \\ }
    ,
        false,
    );
}
test "properties.properties-whose-names-are-Javascript-object-property-names.constructor-not-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "constructor": {
        \\         "length": 37
        \\     }
        \\ }
    ,
        false,
    );
}
test "properties.properties-whose-names-are-Javascript-object-property-names.all-present-and-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "__proto__": 12,
        \\     "toString": {
        \\         "length": "foo"
        \\     },
        \\     "constructor": 37
        \\ }
    ,
        true,
    );
}
test "items.a-schema-given-for-items.valid-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": {
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ,
        true,
    );
}
test "items.a-schema-given-for-items.wrong-type-of-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": {
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ [
        \\     1,
        \\     "x"
        \\ ]
    ,
        false,
    );
}
test "items.a-schema-given-for-items.ignores-non-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": {
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        true,
    );
}
test "items.a-schema-given-for-items.JavaScript-pseudo-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": {
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ {
        \\     "0": "invalid",
        \\     "length": 1
        \\ }
    ,
        true,
    );
}
test "items.an-array-of-schemas-for-items.correct-types" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "type": "string"
        \\         }
        \\     ]
        \\ }
    ,
        \\ [
        \\     1,
        \\     "foo"
        \\ ]
    ,
        true,
    );
}
test "items.an-array-of-schemas-for-items.wrong-types" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "type": "string"
        \\         }
        \\     ]
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     1
        \\ ]
    ,
        false,
    );
}
test "items.an-array-of-schemas-for-items.incomplete-array-of-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "type": "string"
        \\         }
        \\     ]
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "items.an-array-of-schemas-for-items.array-with-additional-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "type": "string"
        \\         }
        \\     ]
        \\ }
    ,
        \\ [
        \\     1,
        \\     "foo",
        \\     true
        \\ ]
    ,
        true,
    );
}
test "items.an-array-of-schemas-for-items.empty-array" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "type": "string"
        \\         }
        \\     ]
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "items.an-array-of-schemas-for-items.JavaScript-pseudo-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "type": "string"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "0": "invalid",
        \\     "1": "valid",
        \\     "length": 2
        \\ }
    ,
        true,
    );
}
test "items.items-with-boolean-schema-(true).any-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": true
        \\ }
    ,
        \\ [
        \\     1,
        \\     "foo",
        \\     true
        \\ ]
    ,
        true,
    );
}
test "items.items-with-boolean-schema-(true).empty-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": true
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "items.items-with-boolean-schema-(false).any-non-empty-array-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": false
        \\ }
    ,
        \\ [
        \\     1,
        \\     "foo",
        \\     true
        \\ ]
    ,
        false,
    );
}
test "items.items-with-boolean-schema-(false).empty-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": false
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "items.items-with-boolean-schemas.array-with-one-item-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         true,
        \\         false
        \\     ]
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "items.items-with-boolean-schemas.array-with-two-items-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         true,
        \\         false
        \\     ]
        \\ }
    ,
        \\ [
        \\     1,
        \\     "foo"
        \\ ]
    ,
        false,
    );
}
test "items.items-with-boolean-schemas.empty-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         true,
        \\         false
        \\     ]
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "items.items-and-subitems.valid-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "item": {
        \\             "type": "array",
        \\             "additionalItems": false,
        \\             "items": [
        \\                 {
        \\                     "$ref": "#/$defs/sub-item"
        \\                 },
        \\                 {
        \\                     "$ref": "#/$defs/sub-item"
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
        \\             "$ref": "#/$defs/item"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/item"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/item"
        \\         }
        \\     ]
        \\ }
    ,
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
    ,
        true,
    );
}
test "items.items-and-subitems.too-many-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "item": {
        \\             "type": "array",
        \\             "additionalItems": false,
        \\             "items": [
        \\                 {
        \\                     "$ref": "#/$defs/sub-item"
        \\                 },
        \\                 {
        \\                     "$ref": "#/$defs/sub-item"
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
        \\             "$ref": "#/$defs/item"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/item"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/item"
        \\         }
        \\     ]
        \\ }
    ,
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
    ,
        false,
    );
}
test "items.items-and-subitems.too-many-sub-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "item": {
        \\             "type": "array",
        \\             "additionalItems": false,
        \\             "items": [
        \\                 {
        \\                     "$ref": "#/$defs/sub-item"
        \\                 },
        \\                 {
        \\                     "$ref": "#/$defs/sub-item"
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
        \\             "$ref": "#/$defs/item"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/item"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/item"
        \\         }
        \\     ]
        \\ }
    ,
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
    ,
        false,
    );
}
test "items.items-and-subitems.wrong-item" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "item": {
        \\             "type": "array",
        \\             "additionalItems": false,
        \\             "items": [
        \\                 {
        \\                     "$ref": "#/$defs/sub-item"
        \\                 },
        \\                 {
        \\                     "$ref": "#/$defs/sub-item"
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
        \\             "$ref": "#/$defs/item"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/item"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/item"
        \\         }
        \\     ]
        \\ }
    ,
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
    ,
        false,
    );
}
test "items.items-and-subitems.wrong-sub-item" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "item": {
        \\             "type": "array",
        \\             "additionalItems": false,
        \\             "items": [
        \\                 {
        \\                     "$ref": "#/$defs/sub-item"
        \\                 },
        \\                 {
        \\                     "$ref": "#/$defs/sub-item"
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
        \\             "$ref": "#/$defs/item"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/item"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/item"
        \\         }
        \\     ]
        \\ }
    ,
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
    ,
        false,
    );
}
test "items.items-and-subitems.fewer-items-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "item": {
        \\             "type": "array",
        \\             "additionalItems": false,
        \\             "items": [
        \\                 {
        \\                     "$ref": "#/$defs/sub-item"
        \\                 },
        \\                 {
        \\                     "$ref": "#/$defs/sub-item"
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
        \\             "$ref": "#/$defs/item"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/item"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/item"
        \\         }
        \\     ]
        \\ }
    ,
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
    ,
        true,
    );
}
test "items.nested-items.valid-nested-array" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
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
    ,
        true,
    );
}
test "items.nested-items.nested-array-with-invalid-type" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
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
    ,
        false,
    );
}
test "items.nested-items.not-deep-enough" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
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
    ,
        false,
    );
}
test "items.single-form-items-with-null-instance-elements.allows-null-elements" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": {
        \\         "type": "null"
        \\     }
        \\ }
    ,
        \\ [
        \\     null
        \\ ]
    ,
        true,
    );
}
test "items.array-form-items-with-null-instance-elements.allows-null-elements" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "null"
        \\         }
        \\     ]
        \\ }
    ,
        \\ [
        \\     null
        \\ ]
    ,
        true,
    );
}
test "oneOf.oneOf.first-oneOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "oneOf.oneOf.second-oneOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    ,
        \\ 2.5
    ,
        true,
    );
}
test "oneOf.oneOf.both-oneOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    ,
        \\ 3
    ,
        false,
    );
}
test "oneOf.oneOf.neither-oneOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    ,
        \\ 1.5
    ,
        false,
    );
}
test "oneOf.oneOf-with-base-schema.mismatch-base-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 3
    ,
        false,
    );
}
test "oneOf.oneOf-with-base-schema.one-oneOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ "foobar"
    ,
        true,
    );
}
test "oneOf.oneOf-with-base-schema.both-oneOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ "foo"
    ,
        false,
    );
}
test "oneOf.oneOf-with-boolean-schemas,-all-true.any-value-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         true,
        \\         true,
        \\         true
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "oneOf.oneOf-with-boolean-schemas,-one-true.any-value-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         true,
        \\         false,
        \\         false
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "oneOf.oneOf-with-boolean-schemas,-more-than-one-true.any-value-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         true,
        \\         true,
        \\         false
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "oneOf.oneOf-with-boolean-schemas,-all-false.any-value-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         false,
        \\         false,
        \\         false
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "oneOf.oneOf-complex-types.first-oneOf-valid-(complex)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "bar": 2
        \\ }
    ,
        true,
    );
}
test "oneOf.oneOf-complex-types.second-oneOf-valid-(complex)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "baz"
        \\ }
    ,
        true,
    );
}
test "oneOf.oneOf-complex-types.both-oneOf-valid-(complex)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "baz",
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "oneOf.oneOf-complex-types.neither-oneOf-valid-(complex)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": 2,
        \\     "bar": "quux"
        \\ }
    ,
        false,
    );
}
test "oneOf.oneOf-with-empty-schema.one-valid---valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         {
        \\             "type": "number"
        \\         },
        \\         {}
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "oneOf.oneOf-with-empty-schema.both-valid---invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         {
        \\             "type": "number"
        \\         },
        \\         {}
        \\     ]
        \\ }
    ,
        \\ 123
    ,
        false,
    );
}
test "oneOf.oneOf-with-required.both-invalid---invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "oneOf.oneOf-with-required.first-valid---valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        true,
    );
}
test "oneOf.oneOf-with-required.second-valid---valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": 1,
        \\     "baz": 3
        \\ }
    ,
        true,
    );
}
test "oneOf.oneOf-with-required.both-valid---invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "baz": 3
        \\ }
    ,
        false,
    );
}
test "oneOf.oneOf-with-missing-optional-property.first-oneOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": true,
        \\                 "baz": true
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": true
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "bar": 8
        \\ }
    ,
        true,
    );
}
test "oneOf.oneOf-with-missing-optional-property.second-oneOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": true,
        \\                 "baz": true
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": true
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        true,
    );
}
test "oneOf.oneOf-with-missing-optional-property.both-oneOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": true,
        \\                 "baz": true
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": true
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": 8
        \\ }
    ,
        false,
    );
}
test "oneOf.oneOf-with-missing-optional-property.neither-oneOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": true,
        \\                 "baz": true
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": true
        \\             },
        \\             "required": [
        \\                 "foo"
        \\             ]
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "baz": "quux"
        \\ }
    ,
        false,
    );
}
test "oneOf.nested-oneOf,-to-check-validation-semantics.null-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ null
    ,
        true,
    );
}
test "oneOf.nested-oneOf,-to-check-validation-semantics.anything-non-null-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 123
    ,
        false,
    );
}
test "exclusiveMinimum.exclusiveMinimum-validation.above-the-exclusiveMinimum-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "exclusiveMinimum": 1.1
        \\ }
    ,
        \\ 1.2
    ,
        true,
    );
}
test "exclusiveMinimum.exclusiveMinimum-validation.boundary-point-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "exclusiveMinimum": 1.1
        \\ }
    ,
        \\ 1.1
    ,
        false,
    );
}
test "exclusiveMinimum.exclusiveMinimum-validation.below-the-exclusiveMinimum-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "exclusiveMinimum": 1.1
        \\ }
    ,
        \\ 0.6
    ,
        false,
    );
}
test "exclusiveMinimum.exclusiveMinimum-validation.ignores-non-numbers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "exclusiveMinimum": 1.1
        \\ }
    ,
        \\ "x"
    ,
        true,
    );
}
test "multipleOf.by-int.int-by-int" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "multipleOf": 2
        \\ }
    ,
        \\ 10
    ,
        true,
    );
}
test "multipleOf.by-int.int-by-int-fail" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "multipleOf": 2
        \\ }
    ,
        \\ 7
    ,
        false,
    );
}
test "multipleOf.by-int.ignores-non-numbers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "multipleOf": 2
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "multipleOf.by-number.zero-is-multiple-of-anything" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "multipleOf": 1.5
        \\ }
    ,
        \\ 0
    ,
        true,
    );
}
test "multipleOf.by-number.4.5-is-multiple-of-1.5" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "multipleOf": 1.5
        \\ }
    ,
        \\ 4.5
    ,
        true,
    );
}
test "multipleOf.by-number.35-is-not-multiple-of-1.5" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "multipleOf": 1.5
        \\ }
    ,
        \\ 35
    ,
        false,
    );
}
test "multipleOf.by-small-number.0.0075-is-multiple-of-0.0001" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "multipleOf": 0.0001
        \\ }
    ,
        \\ 0.0075
    ,
        true,
    );
}
test "multipleOf.by-small-number.0.00751-is-not-multiple-of-0.0001" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "multipleOf": 0.0001
        \\ }
    ,
        \\ 0.00751
    ,
        false,
    );
}
test "multipleOf.float-division-=-inf.always-invalid,-but-naive-implementations-may-raise-an-overflow-error" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "integer",
        \\     "multipleOf": 0.123456789
        \\ }
    ,
        \\ 100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    ,
        false,
    );
}
test "multipleOf.small-multiple-of-large-integer.any-integer-is-a-multiple-of-1e-8" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "integer",
        \\     "multipleOf": 0.00000001
        \\ }
    ,
        \\ 12391239123
    ,
        true,
    );
}
test "propertyNames.propertyNames-validation.all-property-names-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "maxLength": 3
        \\     }
        \\ }
    ,
        \\ {
        \\     "f": {},
        \\     "foo": {}
        \\ }
    ,
        true,
    );
}
test "propertyNames.propertyNames-validation.some-property-names-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "maxLength": 3
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": {},
        \\     "foobar": {}
        \\ }
    ,
        false,
    );
}
test "propertyNames.propertyNames-validation.object-without-properties-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "maxLength": 3
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "propertyNames.propertyNames-validation.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "maxLength": 3
        \\     }
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3,
        \\     4
        \\ ]
    ,
        true,
    );
}
test "propertyNames.propertyNames-validation.ignores-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "maxLength": 3
        \\     }
        \\ }
    ,
        \\ "foobar"
    ,
        true,
    );
}
test "propertyNames.propertyNames-validation.ignores-other-non-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "maxLength": 3
        \\     }
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "propertyNames.propertyNames-validation-with-pattern.matching-property-names-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "pattern": "^a+$"
        \\     }
        \\ }
    ,
        \\ {
        \\     "a": {},
        \\     "aa": {},
        \\     "aaa": {}
        \\ }
    ,
        true,
    );
}
test "propertyNames.propertyNames-validation-with-pattern.non-matching-property-name-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "pattern": "^a+$"
        \\     }
        \\ }
    ,
        \\ {
        \\     "aaA": {}
        \\ }
    ,
        false,
    );
}
test "propertyNames.propertyNames-validation-with-pattern.object-without-properties-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "pattern": "^a+$"
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "propertyNames.propertyNames-with-boolean-schema-true.object-with-any-properties-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": true
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "propertyNames.propertyNames-with-boolean-schema-true.empty-object-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": true
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "propertyNames.propertyNames-with-boolean-schema-false.object-with-any-properties-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": false
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        false,
    );
}
test "propertyNames.propertyNames-with-boolean-schema-false.empty-object-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": false
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "propertyNames.propertyNames-with-const.object-with-property-foo-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "const": "foo"
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "propertyNames.propertyNames-with-const.object-with-any-other-property-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "const": "foo"
        \\     }
        \\ }
    ,
        \\ {
        \\     "bar": 1
        \\ }
    ,
        false,
    );
}
test "propertyNames.propertyNames-with-const.empty-object-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "const": "foo"
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "propertyNames.propertyNames-with-enum.object-with-property-foo-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "enum": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "propertyNames.propertyNames-with-enum.object-with-property-foo-and-bar-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "enum": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 1
        \\ }
    ,
        true,
    );
}
test "propertyNames.propertyNames-with-enum.object-with-any-other-property-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "enum": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {
        \\     "baz": 1
        \\ }
    ,
        false,
    );
}
test "propertyNames.propertyNames-with-enum.empty-object-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "enum": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-without-$recursiveAnchor-works-like-$ref.match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "$recursiveRef": "#"
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": false
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-without-$recursiveAnchor-works-like-$ref.recursive-match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "$recursiveRef": "#"
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "foo": false
        \\     }
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-without-$recursiveAnchor-works-like-$ref.mismatch" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "$recursiveRef": "#"
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "bar": false
        \\ }
    ,
        false,
    );
}
test "recursiveRef.$recursiveRef-without-$recursiveAnchor-works-like-$ref.recursive-mismatch" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "$recursiveRef": "#"
        \\         }
        \\     },
        \\     "additionalProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": false
        \\     }
        \\ }
    ,
        false,
    );
}
test "recursiveRef.$recursiveRef-without-using-nesting.integer-matches-at-the-outer-level" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef2/schema.json",
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": true,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-without-using-nesting.single-level-match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef2/schema.json",
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": true,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": "hi"
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-without-using-nesting.integer-does-not-match-as-a-property-value" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef2/schema.json",
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": true,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        false,
    );
}
test "recursiveRef.$recursiveRef-without-using-nesting.two-levels,-properties-match-with-inner-definition" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef2/schema.json",
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": true,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": "hi"
        \\     }
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-without-using-nesting.two-levels,-no-match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef2/schema.json",
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": true,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": 1
        \\     }
        \\ }
    ,
        false,
    );
}
test "recursiveRef.$recursiveRef-with-nesting.integer-matches-at-the-outer-level" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef3/schema.json",
        \\     "$recursiveAnchor": true,
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": true,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-with-nesting.single-level-match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef3/schema.json",
        \\     "$recursiveAnchor": true,
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": true,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": "hi"
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-with-nesting.integer-now-matches-as-a-property-value" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef3/schema.json",
        \\     "$recursiveAnchor": true,
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": true,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-with-nesting.two-levels,-properties-match-with-inner-definition" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef3/schema.json",
        \\     "$recursiveAnchor": true,
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": true,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": "hi"
        \\     }
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-with-nesting.two-levels,-properties-match-with-$recursiveRef" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef3/schema.json",
        \\     "$recursiveAnchor": true,
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": true,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": 1
        \\     }
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-with-$recursiveAnchor:-false-works-like-$ref.integer-matches-at-the-outer-level" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef4/schema.json",
        \\     "$recursiveAnchor": false,
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": false,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-with-$recursiveAnchor:-false-works-like-$ref.single-level-match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef4/schema.json",
        \\     "$recursiveAnchor": false,
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": false,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": "hi"
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-with-$recursiveAnchor:-false-works-like-$ref.integer-does-not-match-as-a-property-value" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef4/schema.json",
        \\     "$recursiveAnchor": false,
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": false,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        false,
    );
}
test "recursiveRef.$recursiveRef-with-$recursiveAnchor:-false-works-like-$ref.two-levels,-properties-match-with-inner-definition" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef4/schema.json",
        \\     "$recursiveAnchor": false,
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": false,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": "hi"
        \\     }
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-with-$recursiveAnchor:-false-works-like-$ref.two-levels,-integer-does-not-match-as-a-property-value" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef4/schema.json",
        \\     "$recursiveAnchor": false,
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": false,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": 1
        \\     }
        \\ }
    ,
        false,
    );
}
test "recursiveRef.$recursiveRef-with-no-$recursiveAnchor-works-like-$ref.integer-matches-at-the-outer-level" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef5/schema.json",
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": false,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-with-no-$recursiveAnchor-works-like-$ref.single-level-match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef5/schema.json",
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": false,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": "hi"
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-with-no-$recursiveAnchor-works-like-$ref.integer-does-not-match-as-a-property-value" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef5/schema.json",
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": false,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        false,
    );
}
test "recursiveRef.$recursiveRef-with-no-$recursiveAnchor-works-like-$ref.two-levels,-properties-match-with-inner-definition" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef5/schema.json",
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": false,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": "hi"
        \\     }
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-with-no-$recursiveAnchor-works-like-$ref.two-levels,-integer-does-not-match-as-a-property-value" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef5/schema.json",
        \\     "$defs": {
        \\         "myobject": {
        \\             "$id": "myobject.json",
        \\             "$recursiveAnchor": false,
        \\             "anyOf": [
        \\                 {
        \\                     "type": "string"
        \\                 },
        \\                 {
        \\                     "type": "object",
        \\                     "additionalProperties": {
        \\                         "$recursiveRef": "#"
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/$defs/myobject"
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": 1
        \\     }
        \\ }
    ,
        false,
    );
}
test "recursiveRef.$recursiveRef-with-no-$recursiveAnchor-in-the-initial-target-schema-resource.leaf-node-does-not-match;-no-recursion" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef6/base.json",
        \\     "$recursiveAnchor": true,
        \\     "anyOf": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "object",
        \\             "additionalProperties": {
        \\                 "$id": "http://localhost:4242/draft2019-09/recursiveRef6/inner.json",
        \\                 "$comment": "there is no $recursiveAnchor: true here, so we do NOT recurse to the base",
        \\                 "anyOf": [
        \\                     {
        \\                         "type": "integer"
        \\                     },
        \\                     {
        \\                         "type": "object",
        \\                         "additionalProperties": {
        \\                             "$recursiveRef": "#"
        \\                         }
        \\                     }
        \\                 ]
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": true
        \\ }
    ,
        false,
    );
}
test "recursiveRef.$recursiveRef-with-no-$recursiveAnchor-in-the-initial-target-schema-resource.leaf-node-matches:-recursion-uses-the-inner-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef6/base.json",
        \\     "$recursiveAnchor": true,
        \\     "anyOf": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "object",
        \\             "additionalProperties": {
        \\                 "$id": "http://localhost:4242/draft2019-09/recursiveRef6/inner.json",
        \\                 "$comment": "there is no $recursiveAnchor: true here, so we do NOT recurse to the base",
        \\                 "anyOf": [
        \\                     {
        \\                         "type": "integer"
        \\                     },
        \\                     {
        \\                         "type": "object",
        \\                         "additionalProperties": {
        \\                             "$recursiveRef": "#"
        \\                         }
        \\                     }
        \\                 ]
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": 1
        \\     }
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-with-no-$recursiveAnchor-in-the-initial-target-schema-resource.leaf-node-does-not-match:-recursion-uses-the-inner-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef6/base.json",
        \\     "$recursiveAnchor": true,
        \\     "anyOf": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "object",
        \\             "additionalProperties": {
        \\                 "$id": "http://localhost:4242/draft2019-09/recursiveRef6/inner.json",
        \\                 "$comment": "there is no $recursiveAnchor: true here, so we do NOT recurse to the base",
        \\                 "anyOf": [
        \\                     {
        \\                         "type": "integer"
        \\                     },
        \\                     {
        \\                         "type": "object",
        \\                         "additionalProperties": {
        \\                             "$recursiveRef": "#"
        \\                         }
        \\                     }
        \\                 ]
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": true
        \\     }
        \\ }
    ,
        false,
    );
}
test "recursiveRef.$recursiveRef-with-no-$recursiveAnchor-in-the-outer-schema-resource.leaf-node-does-not-match;-no-recursion" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef7/base.json",
        \\     "anyOf": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "object",
        \\             "additionalProperties": {
        \\                 "$id": "http://localhost:4242/draft2019-09/recursiveRef7/inner.json",
        \\                 "$recursiveAnchor": true,
        \\                 "anyOf": [
        \\                     {
        \\                         "type": "integer"
        \\                     },
        \\                     {
        \\                         "type": "object",
        \\                         "additionalProperties": {
        \\                             "$recursiveRef": "#"
        \\                         }
        \\                     }
        \\                 ]
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": true
        \\ }
    ,
        false,
    );
}
test "recursiveRef.$recursiveRef-with-no-$recursiveAnchor-in-the-outer-schema-resource.leaf-node-matches:-recursion-only-uses-inner-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef7/base.json",
        \\     "anyOf": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "object",
        \\             "additionalProperties": {
        \\                 "$id": "http://localhost:4242/draft2019-09/recursiveRef7/inner.json",
        \\                 "$recursiveAnchor": true,
        \\                 "anyOf": [
        \\                     {
        \\                         "type": "integer"
        \\                     },
        \\                     {
        \\                         "type": "object",
        \\                         "additionalProperties": {
        \\                             "$recursiveRef": "#"
        \\                         }
        \\                     }
        \\                 ]
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": 1
        \\     }
        \\ }
    ,
        true,
    );
}
test "recursiveRef.$recursiveRef-with-no-$recursiveAnchor-in-the-outer-schema-resource.leaf-node-does-not-match:-recursion-only-uses-inner-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:4242/draft2019-09/recursiveRef7/base.json",
        \\     "anyOf": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "object",
        \\             "additionalProperties": {
        \\                 "$id": "http://localhost:4242/draft2019-09/recursiveRef7/inner.json",
        \\                 "$recursiveAnchor": true,
        \\                 "anyOf": [
        \\                     {
        \\                         "type": "integer"
        \\                     },
        \\                     {
        \\                         "type": "object",
        \\                         "additionalProperties": {
        \\                             "$recursiveRef": "#"
        \\                         }
        \\                     }
        \\                 ]
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": true
        \\     }
        \\ }
    ,
        false,
    );
}
test "recursiveRef.multiple-dynamic-paths-to-the-$recursiveRef-keyword.recurse-to-anyLeafNode---floats-are-allowed" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "https://example.com/recursiveRef8_main.json",
        \\     "$defs": {
        \\         "inner": {
        \\             "$id": "recursiveRef8_inner.json",
        \\             "$recursiveAnchor": true,
        \\             "title": "inner",
        \\             "additionalProperties": {
        \\                 "$recursiveRef": "#"
        \\             }
        \\         }
        \\     },
        \\     "if": {
        \\         "propertyNames": {
        \\             "pattern": "^[a-m]"
        \\         }
        \\     },
        \\     "then": {
        \\         "title": "any type of node",
        \\         "$id": "recursiveRef8_anyLeafNode.json",
        \\         "$recursiveAnchor": true,
        \\         "$ref": "recursiveRef8_inner.json"
        \\     },
        \\     "else": {
        \\         "title": "integer node",
        \\         "$id": "recursiveRef8_integerNode.json",
        \\         "$recursiveAnchor": true,
        \\         "type": [
        \\             "object",
        \\             "integer"
        \\         ],
        \\         "$ref": "recursiveRef8_inner.json"
        \\     }
        \\ }
    ,
        \\ {
        \\     "alpha": 1.1
        \\ }
    ,
        true,
    );
}
test "recursiveRef.multiple-dynamic-paths-to-the-$recursiveRef-keyword.recurse-to-integerNode---floats-are-not-allowed" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "https://example.com/recursiveRef8_main.json",
        \\     "$defs": {
        \\         "inner": {
        \\             "$id": "recursiveRef8_inner.json",
        \\             "$recursiveAnchor": true,
        \\             "title": "inner",
        \\             "additionalProperties": {
        \\                 "$recursiveRef": "#"
        \\             }
        \\         }
        \\     },
        \\     "if": {
        \\         "propertyNames": {
        \\             "pattern": "^[a-m]"
        \\         }
        \\     },
        \\     "then": {
        \\         "title": "any type of node",
        \\         "$id": "recursiveRef8_anyLeafNode.json",
        \\         "$recursiveAnchor": true,
        \\         "$ref": "recursiveRef8_inner.json"
        \\     },
        \\     "else": {
        \\         "title": "integer node",
        \\         "$id": "recursiveRef8_integerNode.json",
        \\         "$recursiveAnchor": true,
        \\         "type": [
        \\             "object",
        \\             "integer"
        \\         ],
        \\         "$ref": "recursiveRef8_inner.json"
        \\     }
        \\ }
    ,
        \\ {
        \\     "november": 1.1
        \\ }
    ,
        false,
    );
}
test "recursiveRef.dynamic-$recursiveRef-destination-(not-predictable-at-schema-compile-time).numeric-node" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "https://example.com/main.json",
        \\     "$defs": {
        \\         "inner": {
        \\             "$id": "inner.json",
        \\             "$recursiveAnchor": true,
        \\             "title": "inner",
        \\             "additionalProperties": {
        \\                 "$recursiveRef": "#"
        \\             }
        \\         }
        \\     },
        \\     "if": {
        \\         "propertyNames": {
        \\             "pattern": "^[a-m]"
        \\         }
        \\     },
        \\     "then": {
        \\         "title": "any type of node",
        \\         "$id": "anyLeafNode.json",
        \\         "$recursiveAnchor": true,
        \\         "$ref": "main.json#/$defs/inner"
        \\     },
        \\     "else": {
        \\         "title": "integer node",
        \\         "$id": "integerNode.json",
        \\         "$recursiveAnchor": true,
        \\         "type": [
        \\             "object",
        \\             "integer"
        \\         ],
        \\         "$ref": "main.json#/$defs/inner"
        \\     }
        \\ }
    ,
        \\ {
        \\     "alpha": 1.1
        \\ }
    ,
        true,
    );
}
test "recursiveRef.dynamic-$recursiveRef-destination-(not-predictable-at-schema-compile-time).integer-node" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "https://example.com/main.json",
        \\     "$defs": {
        \\         "inner": {
        \\             "$id": "inner.json",
        \\             "$recursiveAnchor": true,
        \\             "title": "inner",
        \\             "additionalProperties": {
        \\                 "$recursiveRef": "#"
        \\             }
        \\         }
        \\     },
        \\     "if": {
        \\         "propertyNames": {
        \\             "pattern": "^[a-m]"
        \\         }
        \\     },
        \\     "then": {
        \\         "title": "any type of node",
        \\         "$id": "anyLeafNode.json",
        \\         "$recursiveAnchor": true,
        \\         "$ref": "main.json#/$defs/inner"
        \\     },
        \\     "else": {
        \\         "title": "integer node",
        \\         "$id": "integerNode.json",
        \\         "$recursiveAnchor": true,
        \\         "type": [
        \\             "object",
        \\             "integer"
        \\         ],
        \\         "$ref": "main.json#/$defs/inner"
        \\     }
        \\ }
    ,
        \\ {
        \\     "november": 1.1
        \\ }
    ,
        false,
    );
}
test "const.const-validation.same-value-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 2
        \\ }
    ,
        \\ 2
    ,
        true,
    );
}
test "const.const-validation.another-value-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 2
        \\ }
    ,
        \\ 5
    ,
        false,
    );
}
test "const.const-validation.another-type-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 2
        \\ }
    ,
        \\ "a"
    ,
        false,
    );
}
test "const.const-with-object.same-object-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": {
        \\         "foo": "bar",
        \\         "baz": "bax"
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "bar",
        \\     "baz": "bax"
        \\ }
    ,
        true,
    );
}
test "const.const-with-object.same-object-with-different-property-order-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": {
        \\         "foo": "bar",
        \\         "baz": "bax"
        \\     }
        \\ }
    ,
        \\ {
        \\     "baz": "bax",
        \\     "foo": "bar"
        \\ }
    ,
        true,
    );
}
test "const.const-with-object.another-object-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": {
        \\         "foo": "bar",
        \\         "baz": "bax"
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        false,
    );
}
test "const.const-with-object.another-type-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": {
        \\         "foo": "bar",
        \\         "baz": "bax"
        \\     }
        \\ }
    ,
        \\ [
        \\     1,
        \\     2
        \\ ]
    ,
        false,
    );
}
test "const.const-with-array.same-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": [
        \\         {
        \\             "foo": "bar"
        \\         }
        \\     ]
        \\ }
    ,
        \\ [
        \\     {
        \\         "foo": "bar"
        \\     }
        \\ ]
    ,
        true,
    );
}
test "const.const-with-array.another-array-item-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": [
        \\         {
        \\             "foo": "bar"
        \\         }
        \\     ]
        \\ }
    ,
        \\ [
        \\     2
        \\ ]
    ,
        false,
    );
}
test "const.const-with-array.array-with-additional-items-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": [
        \\         {
        \\             "foo": "bar"
        \\         }
        \\     ]
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ,
        false,
    );
}
test "const.const-with-null.null-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": null
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "const.const-with-null.not-null-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": null
        \\ }
    ,
        \\ 0
    ,
        false,
    );
}
test "const.const-with-false-does-not-match-0.false-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": false
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "const.const-with-false-does-not-match-0.integer-zero-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": false
        \\ }
    ,
        \\ 0
    ,
        false,
    );
}
test "const.const-with-false-does-not-match-0.float-zero-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": false
        \\ }
    ,
        \\ 0
    ,
        false,
    );
}
test "const.const-with-true-does-not-match-1.true-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": true
        \\ }
    ,
        \\ true
    ,
        true,
    );
}
test "const.const-with-true-does-not-match-1.integer-one-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": true
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "const.const-with-true-does-not-match-1.float-one-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": true
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "const.const-with-[false]-does-not-match-[0].[false]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": [
        \\         false
        \\     ]
        \\ }
    ,
        \\ [
        \\     false
        \\ ]
    ,
        true,
    );
}
test "const.const-with-[false]-does-not-match-[0].[0]-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": [
        \\         false
        \\     ]
        \\ }
    ,
        \\ [
        \\     0
        \\ ]
    ,
        false,
    );
}
test "const.const-with-[false]-does-not-match-[0].[0.0]-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": [
        \\         false
        \\     ]
        \\ }
    ,
        \\ [
        \\     0
        \\ ]
    ,
        false,
    );
}
test "const.const-with-[true]-does-not-match-[1].[true]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": [
        \\         true
        \\     ]
        \\ }
    ,
        \\ [
        \\     true
        \\ ]
    ,
        true,
    );
}
test "const.const-with-[true]-does-not-match-[1].[1]-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": [
        \\         true
        \\     ]
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        false,
    );
}
test "const.const-with-[true]-does-not-match-[1].[1.0]-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": [
        \\         true
        \\     ]
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        false,
    );
}
test "const.const-with-{'a':-false}-does-not-match-{'a':-0}.{'a':-false}-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": {
        \\         "a": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "a": false
        \\ }
    ,
        true,
    );
}
test "const.const-with-{'a':-false}-does-not-match-{'a':-0}.{'a':-0}-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": {
        \\         "a": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "a": 0
        \\ }
    ,
        false,
    );
}
test "const.const-with-{'a':-false}-does-not-match-{'a':-0}.{'a':-0.0}-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": {
        \\         "a": false
        \\     }
        \\ }
    ,
        \\ {
        \\     "a": 0
        \\ }
    ,
        false,
    );
}
test "const.const-with-{'a':-true}-does-not-match-{'a':-1}.{'a':-true}-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": {
        \\         "a": true
        \\     }
        \\ }
    ,
        \\ {
        \\     "a": true
        \\ }
    ,
        true,
    );
}
test "const.const-with-{'a':-true}-does-not-match-{'a':-1}.{'a':-1}-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": {
        \\         "a": true
        \\     }
        \\ }
    ,
        \\ {
        \\     "a": 1
        \\ }
    ,
        false,
    );
}
test "const.const-with-{'a':-true}-does-not-match-{'a':-1}.{'a':-1.0}-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": {
        \\         "a": true
        \\     }
        \\ }
    ,
        \\ {
        \\     "a": 1
        \\ }
    ,
        false,
    );
}
test "const.const-with-0-does-not-match-other-zero-like-types.false-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 0
        \\ }
    ,
        \\ false
    ,
        false,
    );
}
test "const.const-with-0-does-not-match-other-zero-like-types.integer-zero-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 0
        \\ }
    ,
        \\ 0
    ,
        true,
    );
}
test "const.const-with-0-does-not-match-other-zero-like-types.float-zero-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 0
        \\ }
    ,
        \\ 0
    ,
        true,
    );
}
test "const.const-with-0-does-not-match-other-zero-like-types.empty-object-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 0
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "const.const-with-0-does-not-match-other-zero-like-types.empty-array-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 0
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "const.const-with-0-does-not-match-other-zero-like-types.empty-string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 0
        \\ }
    ,
        \\ ""
    ,
        false,
    );
}
test "const.const-with-1-does-not-match-true.true-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 1
        \\ }
    ,
        \\ true
    ,
        false,
    );
}
test "const.const-with-1-does-not-match-true.integer-one-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 1
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "const.const-with-1-does-not-match-true.float-one-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 1
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "const.const-with--2.0-matches-integer-and-float-types.integer--2-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": -2
        \\ }
    ,
        \\ -2
    ,
        true,
    );
}
test "const.const-with--2.0-matches-integer-and-float-types.integer-2-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": -2
        \\ }
    ,
        \\ 2
    ,
        false,
    );
}
test "const.const-with--2.0-matches-integer-and-float-types.float--2.0-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": -2
        \\ }
    ,
        \\ -2
    ,
        true,
    );
}
test "const.const-with--2.0-matches-integer-and-float-types.float-2.0-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": -2
        \\ }
    ,
        \\ 2
    ,
        false,
    );
}
test "const.const-with--2.0-matches-integer-and-float-types.float--2.00001-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": -2
        \\ }
    ,
        \\ -2.00001
    ,
        false,
    );
}
test "const.float-and-integers-are-equal-up-to-64-bit-representation-limits.integer-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 9007199254740992
        \\ }
    ,
        \\ 9007199254740992
    ,
        true,
    );
}
test "const.float-and-integers-are-equal-up-to-64-bit-representation-limits.integer-minus-one-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 9007199254740992
        \\ }
    ,
        \\ 9007199254740991
    ,
        false,
    );
}
test "const.float-and-integers-are-equal-up-to-64-bit-representation-limits.float-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 9007199254740992
        \\ }
    ,
        \\ 9007199254740992
    ,
        true,
    );
}
test "const.float-and-integers-are-equal-up-to-64-bit-representation-limits.float-minus-one-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": 9007199254740992
        \\ }
    ,
        \\ 9007199254740991
    ,
        false,
    );
}
test "const.nul-characters-in-strings.match-string-with-nul" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": "hello\u0000there"
        \\ }
    ,
        \\ "hello\u0000there"
    ,
        true,
    );
}
test "const.nul-characters-in-strings.do-not-match-string-lacking-nul" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "const": "hello\u0000there"
        \\ }
    ,
        \\ "hellothere"
    ,
        false,
    );
}
test "required.required-validation.present-required-property-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "required": [
        \\         "foo"
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "required.required-validation.non-present-required-property-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "required": [
        \\         "foo"
        \\     ]
        \\ }
    ,
        \\ {
        \\     "bar": 1
        \\ }
    ,
        false,
    );
}
test "required.required-validation.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "required": [
        \\         "foo"
        \\     ]
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "required.required-validation.ignores-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "required": [
        \\         "foo"
        \\     ]
        \\ }
    ,
        \\ ""
    ,
        true,
    );
}
test "required.required-validation.ignores-other-non-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {},
        \\         "bar": {}
        \\     },
        \\     "required": [
        \\         "foo"
        \\     ]
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "required.required-default-validation.not-required-by-default" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {}
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "required.required-with-empty-array.property-not-required" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {}
        \\     },
        \\     "required": []
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "required.required-with-escaped-characters.object-with-all-properties-present-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "required": [
        \\         "foo\nbar",
        \\         "foo\"bar",
        \\         "foo\\bar",
        \\         "foo\rbar",
        \\         "foo\tbar",
        \\         "foo\fbar"
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo\nbar": 1,
        \\     "foo\"bar": 1,
        \\     "foo\\bar": 1,
        \\     "foo\rbar": 1,
        \\     "foo\tbar": 1,
        \\     "foo\fbar": 1
        \\ }
    ,
        true,
    );
}
test "required.required-with-escaped-characters.object-with-some-properties-missing-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "required": [
        \\         "foo\nbar",
        \\         "foo\"bar",
        \\         "foo\\bar",
        \\         "foo\rbar",
        \\         "foo\tbar",
        \\         "foo\fbar"
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo\nbar": "1",
        \\     "foo\"bar": "1"
        \\ }
    ,
        false,
    );
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.ignores-other-non-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.none-of-the-properties-mentioned" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.__proto__-present" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    ,
        \\ {
        \\     "__proto__": "foo"
        \\ }
    ,
        false,
    );
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.toString-present" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    ,
        \\ {
        \\     "toString": {
        \\         "length": 37
        \\     }
        \\ }
    ,
        false,
    );
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.constructor-present" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    ,
        \\ {
        \\     "constructor": {
        \\         "length": 37
        \\     }
        \\ }
    ,
        false,
    );
}
test "required.required-properties-whose-names-are-Javascript-object-property-names.all-present" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "required": [
        \\         "__proto__",
        \\         "toString",
        \\         "constructor"
        \\     ]
        \\ }
    ,
        \\ {
        \\     "__proto__": 12,
        \\     "toString": {
        \\         "length": "foo"
        \\     },
        \\     "constructor": 37
        \\ }
    ,
        true,
    );
}
test "default.invalid-type-for-default.valid-when-property-is-specified" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer",
        \\             "default": []
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": 13
        \\ }
    ,
        true,
    );
}
test "default.invalid-type-for-default.still-valid-when-the-invalid-default-is-used" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "integer",
        \\             "default": []
        \\         }
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "default.invalid-string-value-for-default.valid-when-property-is-specified" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "bar": {
        \\             "type": "string",
        \\             "minLength": 4,
        \\             "default": "bad"
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "bar": "good"
        \\ }
    ,
        true,
    );
}
test "default.invalid-string-value-for-default.still-valid-when-the-invalid-default-is-used" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "bar": {
        \\             "type": "string",
        \\             "minLength": 4,
        \\             "default": "bad"
        \\         }
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "default.the-default-keyword-does-not-do-anything-if-the-property-is-missing.an-explicit-property-value-is-checked-against-maximum-(passing)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "alpha": {
        \\             "type": "number",
        \\             "maximum": 3,
        \\             "default": 5
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "alpha": 1
        \\ }
    ,
        true,
    );
}
test "default.the-default-keyword-does-not-do-anything-if-the-property-is-missing.an-explicit-property-value-is-checked-against-maximum-(failing)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "alpha": {
        \\             "type": "number",
        \\             "maximum": 3,
        \\             "default": 5
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "alpha": 5
        \\ }
    ,
        false,
    );
}
test "default.the-default-keyword-does-not-do-anything-if-the-property-is-missing.missing-properties-are-not-filled-in-with-the-default" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "alpha": {
        \\             "type": "number",
        \\             "maximum": 3,
        \\             "default": 5
        \\         }
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.unique-array-of-integers-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     1,
        \\     2
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-integers-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     1,
        \\     1
        \\ ]
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-more-than-two-integers-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     1
        \\ ]
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-validation.numbers-are-unique-if-mathematically-unequal" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     1,
        \\     1,
        \\     1
        \\ ]
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-validation.false-is-not-equal-to-zero" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     0,
        \\     false
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.true-is-not-equal-to-one" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     1,
        \\     true
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.unique-array-of-strings-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "baz"
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-strings-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "foo"
        \\ ]
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-validation.unique-array-of-objects-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     {
        \\         "foo": "bar"
        \\     },
        \\     {
        \\         "foo": "baz"
        \\     }
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-objects-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     {
        \\         "foo": "bar"
        \\     },
        \\     {
        \\         "foo": "bar"
        \\     }
        \\ ]
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-validation.property-order-of-array-of-objects-is-ignored" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
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
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-validation.unique-array-of-nested-objects-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
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
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-nested-objects-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
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
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-validation.unique-array-of-arrays-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     [
        \\         "foo"
        \\     ],
        \\     [
        \\         "bar"
        \\     ]
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-arrays-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     [
        \\         "foo"
        \\     ],
        \\     [
        \\         "foo"
        \\     ]
        \\ ]
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-validation.non-unique-array-of-more-than-two-arrays-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
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
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-validation.1-and-true-are-unique" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     1,
        \\     true
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.0-and-false-are-unique" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     0,
        \\     false
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.[1]-and-[true]-are-unique" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     [
        \\         1
        \\     ],
        \\     [
        \\         true
        \\     ]
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.[0]-and-[false]-are-unique" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     [
        \\         0
        \\     ],
        \\     [
        \\         false
        \\     ]
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.nested-[1]-and-[true]-are-unique" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
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
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.nested-[0]-and-[false]-are-unique" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
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
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.unique-heterogeneous-types-are-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
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
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.non-unique-heterogeneous-types-are-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
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
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-validation.different-objects-are-unique" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
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
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.objects-are-non-unique-despite-key-order" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
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
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-validation.{'a':-false}-and-{'a':-0}-are-unique" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     {
        \\         "a": false
        \\     },
        \\     {
        \\         "a": 0
        \\     }
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-validation.{'a':-true}-and-{'a':-1}-are-unique" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": true
        \\ }
    ,
        \\ [
        \\     {
        \\         "a": true
        \\     },
        \\     {
        \\         "a": 1
        \\     }
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-with-an-array-of-items.[false,-true]-from-items-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     true
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-with-an-array-of-items.[true,-false]-from-items-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     true,
        \\     false
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-with-an-array-of-items.[false,-false]-from-items-array-is-not-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     false
        \\ ]
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-with-an-array-of-items.[true,-true]-from-items-array-is-not-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     true,
        \\     true
        \\ ]
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-with-an-array-of-items.unique-array-extended-from-[false,-true]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     true,
        \\     "foo",
        \\     "bar"
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-with-an-array-of-items.unique-array-extended-from-[true,-false]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     true,
        \\     false,
        \\     "foo",
        \\     "bar"
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-with-an-array-of-items.non-unique-array-extended-from-[false,-true]-is-not-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     true,
        \\     "foo",
        \\     "foo"
        \\ ]
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-with-an-array-of-items.non-unique-array-extended-from-[true,-false]-is-not-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     true,
        \\     false,
        \\     "foo",
        \\     "foo"
        \\ ]
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-with-an-array-of-items-and-additionalItems=false.[false,-true]-from-items-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     true
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-with-an-array-of-items-and-additionalItems=false.[true,-false]-from-items-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     true,
        \\     false
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems-with-an-array-of-items-and-additionalItems=false.[false,-false]-from-items-array-is-not-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     false
        \\ ]
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-with-an-array-of-items-and-additionalItems=false.[true,-true]-from-items-array-is-not-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     true,
        \\     true
        \\ ]
    ,
        false,
    );
}
test "uniqueItems.uniqueItems-with-an-array-of-items-and-additionalItems=false.extra-items-are-invalid-even-if-unique" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     true,
        \\     null
        \\ ]
    ,
        false,
    );
}
test "uniqueItems.uniqueItems=false-validation.unique-array-of-integers-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
        \\ [
        \\     1,
        \\     2
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.non-unique-array-of-integers-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
        \\ [
        \\     1,
        \\     1
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.numbers-are-unique-if-mathematically-unequal" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
        \\ [
        \\     1,
        \\     1,
        \\     1
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.false-is-not-equal-to-zero" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
        \\ [
        \\     0,
        \\     false
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.true-is-not-equal-to-one" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
        \\ [
        \\     1,
        \\     true
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.unique-array-of-objects-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
        \\ [
        \\     {
        \\         "foo": "bar"
        \\     },
        \\     {
        \\         "foo": "baz"
        \\     }
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.non-unique-array-of-objects-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
        \\ [
        \\     {
        \\         "foo": "bar"
        \\     },
        \\     {
        \\         "foo": "bar"
        \\     }
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.unique-array-of-nested-objects-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
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
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.non-unique-array-of-nested-objects-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
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
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.unique-array-of-arrays-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
        \\ [
        \\     [
        \\         "foo"
        \\     ],
        \\     [
        \\         "bar"
        \\     ]
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.non-unique-array-of-arrays-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
        \\ [
        \\     [
        \\         "foo"
        \\     ],
        \\     [
        \\         "foo"
        \\     ]
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.1-and-true-are-unique" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
        \\ [
        \\     1,
        \\     true
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.0-and-false-are-unique" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
        \\ [
        \\     0,
        \\     false
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.unique-heterogeneous-types-are-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
        \\ [
        \\     {},
        \\     [
        \\         1
        \\     ],
        \\     true,
        \\     null,
        \\     1
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-validation.non-unique-heterogeneous-types-are-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "uniqueItems": false
        \\ }
    ,
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
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.[false,-true]-from-items-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     true
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.[true,-false]-from-items-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     true,
        \\     false
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.[false,-false]-from-items-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     false
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.[true,-true]-from-items-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     true,
        \\     true
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.unique-array-extended-from-[false,-true]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     true,
        \\     "foo",
        \\     "bar"
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.unique-array-extended-from-[true,-false]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     true,
        \\     false,
        \\     "foo",
        \\     "bar"
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.non-unique-array-extended-from-[false,-true]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     true,
        \\     "foo",
        \\     "foo"
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items.non-unique-array-extended-from-[true,-false]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     true,
        \\     false,
        \\     "foo",
        \\     "foo"
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items-and-additionalItems=false.[false,-true]-from-items-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     true
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items-and-additionalItems=false.[true,-false]-from-items-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     true,
        \\     false
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items-and-additionalItems=false.[false,-false]-from-items-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     false
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items-and-additionalItems=false.[true,-true]-from-items-array-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     true,
        \\     true
        \\ ]
    ,
        true,
    );
}
test "uniqueItems.uniqueItems=false-with-an-array-of-items-and-additionalItems=false.extra-items-are-invalid-even-if-unique" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     false,
        \\     true,
        \\     null
        \\ ]
    ,
        false,
    );
}
test "maxContains.maxContains-without-contains-is-ignored.one-item-valid-against-lone-maxContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxContains": 1
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "maxContains.maxContains-without-contains-is-ignored.two-items-still-valid-against-lone-maxContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxContains": 1
        \\ }
    ,
        \\ [
        \\     1,
        \\     2
        \\ ]
    ,
        true,
    );
}
test "maxContains.maxContains-with-contains.empty-data" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "maxContains.maxContains-with-contains.all-elements-match,-valid-maxContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "maxContains.maxContains-with-contains.all-elements-match,-invalid-maxContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
        \\ }
    ,
        \\ [
        \\     1,
        \\     1
        \\ ]
    ,
        false,
    );
}
test "maxContains.maxContains-with-contains.some-elements-match,-valid-maxContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
        \\ }
    ,
        \\ [
        \\     1,
        \\     2
        \\ ]
    ,
        true,
    );
}
test "maxContains.maxContains-with-contains.some-elements-match,-invalid-maxContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     1
        \\ ]
    ,
        false,
    );
}
test "maxContains.maxContains-with-contains,-value-with-a-decimal.one-element-matches,-valid-maxContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "maxContains.maxContains-with-contains,-value-with-a-decimal.too-many-elements-match,-invalid-maxContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
        \\ }
    ,
        \\ [
        \\     1,
        \\     1
        \\ ]
    ,
        false,
    );
}
test "maxContains.minContains-<-maxContains.actual-<-minContains-<-maxContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1,
        \\     "maxContains": 3
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "maxContains.minContains-<-maxContains.minContains-<-actual-<-maxContains" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1,
        \\     "maxContains": 3
        \\ }
    ,
        \\ [
        \\     1,
        \\     1
        \\ ]
    ,
        true,
    );
}
test "maxContains.minContains-<-maxContains.minContains-<-maxContains-<-actual" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1,
        \\     "maxContains": 3
        \\ }
    ,
        \\ [
        \\     1,
        \\     1,
        \\     1,
        \\     1
        \\ ]
    ,
        false,
    );
}
test "maxProperties.maxProperties-validation.shorter-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxProperties": 2
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "maxProperties.maxProperties-validation.exact-length-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxProperties": 2
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        true,
    );
}
test "maxProperties.maxProperties-validation.too-long-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxProperties": 2
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "baz": 3
        \\ }
    ,
        false,
    );
}
test "maxProperties.maxProperties-validation.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxProperties": 2
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ,
        true,
    );
}
test "maxProperties.maxProperties-validation.ignores-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxProperties": 2
        \\ }
    ,
        \\ "foobar"
    ,
        true,
    );
}
test "maxProperties.maxProperties-validation.ignores-other-non-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxProperties": 2
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "maxProperties.maxProperties-validation-with-a-decimal.shorter-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxProperties": 2
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "maxProperties.maxProperties-validation-with-a-decimal.too-long-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxProperties": 2
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2,
        \\     "baz": 3
        \\ }
    ,
        false,
    );
}
test "maxProperties.maxProperties-=-0-means-the-object-is-empty.no-properties-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxProperties": 0
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "maxProperties.maxProperties-=-0-means-the-object-is-empty.one-property-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxProperties": 0
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        false,
    );
}
test "allOf.allOf.allOf" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "baz",
        \\     "bar": 2
        \\ }
    ,
        true,
    );
}
test "allOf.allOf.mismatch-second" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "baz"
        \\ }
    ,
        false,
    );
}
test "allOf.allOf.mismatch-first" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "allOf.allOf.wrong-type" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "baz",
        \\     "bar": "quux"
        \\ }
    ,
        false,
    );
}
test "allOf.allOf-with-base-schema.valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "quux",
        \\     "bar": 2,
        \\     "baz": null
        \\ }
    ,
        true,
    );
}
test "allOf.allOf-with-base-schema.mismatch-base-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "quux",
        \\     "baz": null
        \\ }
    ,
        false,
    );
}
test "allOf.allOf-with-base-schema.mismatch-first-allOf" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "bar": 2,
        \\     "baz": null
        \\ }
    ,
        false,
    );
}
test "allOf.allOf-with-base-schema.mismatch-second-allOf" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "quux",
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "allOf.allOf-with-base-schema.mismatch-both" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "allOf.allOf-simple-types.valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "maximum": 30
        \\         },
        \\         {
        \\             "minimum": 20
        \\         }
        \\     ]
        \\ }
    ,
        \\ 25
    ,
        true,
    );
}
test "allOf.allOf-simple-types.mismatch-one" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "maximum": 30
        \\         },
        \\         {
        \\             "minimum": 20
        \\         }
        \\     ]
        \\ }
    ,
        \\ 35
    ,
        false,
    );
}
test "allOf.allOf-with-boolean-schemas,-all-true.any-value-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         true,
        \\         true
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "allOf.allOf-with-boolean-schemas,-some-false.any-value-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         true,
        \\         false
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "allOf.allOf-with-boolean-schemas,-all-false.any-value-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         false,
        \\         false
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "allOf.allOf-with-one-empty-schema.any-data-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {}
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "allOf.allOf-with-two-empty-schemas.any-data-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {},
        \\         {}
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "allOf.allOf-with-the-first-empty-schema.number-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {},
        \\         {
        \\             "type": "number"
        \\         }
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "allOf.allOf-with-the-first-empty-schema.string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {},
        \\         {
        \\             "type": "number"
        \\         }
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "allOf.allOf-with-the-last-empty-schema.number-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "type": "number"
        \\         },
        \\         {}
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "allOf.allOf-with-the-last-empty-schema.string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "type": "number"
        \\         },
        \\         {}
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "allOf.nested-allOf,-to-check-validation-semantics.null-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ null
    ,
        true,
    );
}
test "allOf.nested-allOf,-to-check-validation-semantics.anything-non-null-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 123
    ,
        false,
    );
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-false,-anyOf:-false,-oneOf:-false" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 1
    ,
        false,
    );
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-false,-anyOf:-false,-oneOf:-true" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 5
    ,
        false,
    );
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-false,-anyOf:-true,-oneOf:-false" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 3
    ,
        false,
    );
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-false,-anyOf:-true,-oneOf:-true" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 15
    ,
        false,
    );
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-true,-anyOf:-false,-oneOf:-false" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 2
    ,
        false,
    );
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-true,-anyOf:-false,-oneOf:-true" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 10
    ,
        false,
    );
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-true,-anyOf:-true,-oneOf:-false" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 6
    ,
        false,
    );
}
test "allOf.allOf-combined-with-anyOf,-oneOf.allOf:-true,-anyOf:-true,-oneOf:-true" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 30
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-true.with-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "unevaluatedProperties": true
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-true.with-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "unevaluatedProperties": true
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-schema.with-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "unevaluatedProperties": {
        \\         "type": "string",
        \\         "minLength": 3
        \\     }
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-schema.with-valid-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "unevaluatedProperties": {
        \\         "type": "string",
        \\         "minLength": 3
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-schema.with-invalid-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "unevaluatedProperties": {
        \\         "type": "string",
        \\         "minLength": 3
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "fo"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-false.with-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-false.with-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-properties.with-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-properties.with-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-patternProperties.with-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "patternProperties": {
        \\         "^foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-patternProperties.with-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "patternProperties": {
        \\         "^foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-additionalProperties.with-no-additional-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "additionalProperties": true,
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-additionalProperties.with-additional-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "additionalProperties": true,
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-properties.with-no-additional-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-properties.with-additional-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-patternProperties.with-no-additional-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "patternProperties": {
        \\                 "^bar": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-patternProperties.with-additional-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "patternProperties": {
        \\                 "^bar": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-additionalProperties.with-no-additional-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "additionalProperties": true
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-additionalProperties.with-additional-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "additionalProperties": true
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-unevaluatedProperties.with-no-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "unevaluatedProperties": true
        \\         }
        \\     ],
        \\     "unevaluatedProperties": {
        \\         "type": "string",
        \\         "maxLength": 2
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-unevaluatedProperties.with-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "unevaluatedProperties": true
        \\         }
        \\     ],
        \\     "unevaluatedProperties": {
        \\         "type": "string",
        \\         "maxLength": 2
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-anyOf.when-one-matches-and-has-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "const": "bar"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "const": "baz"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "baz"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "quux": {
        \\                     "const": "quux"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "quux"
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-anyOf.when-one-matches-and-has-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "const": "bar"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "const": "baz"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "baz"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "quux": {
        \\                     "const": "quux"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "quux"
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "not-baz"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-anyOf.when-two-match-and-has-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "const": "bar"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "const": "baz"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "baz"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "quux": {
        \\                     "const": "quux"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "quux"
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-anyOf.when-two-match-and-has-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "const": "bar"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "const": "baz"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "baz"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "quux": {
        \\                     "const": "quux"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "quux"
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "baz",
        \\     "quux": "not-quux"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-oneOf.with-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "const": "bar"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "const": "baz"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "baz"
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-oneOf.with-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": {
        \\                     "const": "bar"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         },
        \\         {
        \\             "properties": {
        \\                 "baz": {
        \\                     "const": "baz"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "baz"
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "quux": "quux"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-not.with-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "not": {
        \\         "not": {
        \\             "properties": {
        \\                 "bar": {
        \\                     "const": "bar"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else.when-if-is-true-and-has-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "if": {
        \\         "properties": {
        \\             "foo": {
        \\                 "const": "then"
        \\             }
        \\         },
        \\         "required": [
        \\             "foo"
        \\         ]
        \\     },
        \\     "then": {
        \\         "properties": {
        \\             "bar": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "bar"
        \\         ]
        \\     },
        \\     "else": {
        \\         "properties": {
        \\             "baz": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "baz"
        \\         ]
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "then",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else.when-if-is-true-and-has-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "if": {
        \\         "properties": {
        \\             "foo": {
        \\                 "const": "then"
        \\             }
        \\         },
        \\         "required": [
        \\             "foo"
        \\         ]
        \\     },
        \\     "then": {
        \\         "properties": {
        \\             "bar": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "bar"
        \\         ]
        \\     },
        \\     "else": {
        \\         "properties": {
        \\             "baz": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "baz"
        \\         ]
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "then",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else.when-if-is-false-and-has-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "if": {
        \\         "properties": {
        \\             "foo": {
        \\                 "const": "then"
        \\             }
        \\         },
        \\         "required": [
        \\             "foo"
        \\         ]
        \\     },
        \\     "then": {
        \\         "properties": {
        \\             "bar": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "bar"
        \\         ]
        \\     },
        \\     "else": {
        \\         "properties": {
        \\             "baz": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "baz"
        \\         ]
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "baz": "baz"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else.when-if-is-false-and-has-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "if": {
        \\         "properties": {
        \\             "foo": {
        \\                 "const": "then"
        \\             }
        \\         },
        \\         "required": [
        \\             "foo"
        \\         ]
        \\     },
        \\     "then": {
        \\         "properties": {
        \\             "bar": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "bar"
        \\         ]
        \\     },
        \\     "else": {
        \\         "properties": {
        \\             "baz": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "baz"
        \\         ]
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "else",
        \\     "baz": "baz"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-then-not-defined.when-if-is-true-and-has-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "if": {
        \\         "properties": {
        \\             "foo": {
        \\                 "const": "then"
        \\             }
        \\         },
        \\         "required": [
        \\             "foo"
        \\         ]
        \\     },
        \\     "else": {
        \\         "properties": {
        \\             "baz": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "baz"
        \\         ]
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "then",
        \\     "bar": "bar"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-then-not-defined.when-if-is-true-and-has-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "if": {
        \\         "properties": {
        \\             "foo": {
        \\                 "const": "then"
        \\             }
        \\         },
        \\         "required": [
        \\             "foo"
        \\         ]
        \\     },
        \\     "else": {
        \\         "properties": {
        \\             "baz": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "baz"
        \\         ]
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "then",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-then-not-defined.when-if-is-false-and-has-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "if": {
        \\         "properties": {
        \\             "foo": {
        \\                 "const": "then"
        \\             }
        \\         },
        \\         "required": [
        \\             "foo"
        \\         ]
        \\     },
        \\     "else": {
        \\         "properties": {
        \\             "baz": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "baz"
        \\         ]
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "baz": "baz"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-then-not-defined.when-if-is-false-and-has-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "if": {
        \\         "properties": {
        \\             "foo": {
        \\                 "const": "then"
        \\             }
        \\         },
        \\         "required": [
        \\             "foo"
        \\         ]
        \\     },
        \\     "else": {
        \\         "properties": {
        \\             "baz": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "baz"
        \\         ]
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "else",
        \\     "baz": "baz"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-else-not-defined.when-if-is-true-and-has-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "if": {
        \\         "properties": {
        \\             "foo": {
        \\                 "const": "then"
        \\             }
        \\         },
        \\         "required": [
        \\             "foo"
        \\         ]
        \\     },
        \\     "then": {
        \\         "properties": {
        \\             "bar": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "bar"
        \\         ]
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "then",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-else-not-defined.when-if-is-true-and-has-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "if": {
        \\         "properties": {
        \\             "foo": {
        \\                 "const": "then"
        \\             }
        \\         },
        \\         "required": [
        \\             "foo"
        \\         ]
        \\     },
        \\     "then": {
        \\         "properties": {
        \\             "bar": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "bar"
        \\         ]
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "then",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-else-not-defined.when-if-is-false-and-has-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "if": {
        \\         "properties": {
        \\             "foo": {
        \\                 "const": "then"
        \\             }
        \\         },
        \\         "required": [
        \\             "foo"
        \\         ]
        \\     },
        \\     "then": {
        \\         "properties": {
        \\             "bar": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "bar"
        \\         ]
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "baz": "baz"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-else-not-defined.when-if-is-false-and-has-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "if": {
        \\         "properties": {
        \\             "foo": {
        \\                 "const": "then"
        \\             }
        \\         },
        \\         "required": [
        \\             "foo"
        \\         ]
        \\     },
        \\     "then": {
        \\         "properties": {
        \\             "bar": {
        \\                 "type": "string"
        \\             }
        \\         },
        \\         "required": [
        \\             "bar"
        \\         ]
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "else",
        \\     "baz": "baz"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-dependentSchemas.with-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "dependentSchemas": {
        \\         "foo": {
        \\             "properties": {
        \\                 "bar": {
        \\                     "const": "bar"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-dependentSchemas.with-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "dependentSchemas": {
        \\         "foo": {
        \\             "properties": {
        \\                 "bar": {
        \\                     "const": "bar"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "bar"
        \\             ]
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "bar": "bar"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-boolean-schemas.with-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         true
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-boolean-schemas.with-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         true
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "bar": "bar"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-$ref.with-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "$ref": "#/$defs/bar",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false,
        \\     "$defs": {
        \\         "bar": {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-$ref.with-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "$ref": "#/$defs/bar",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false,
        \\     "$defs": {
        \\         "bar": {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-before-$ref.with-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "unevaluatedProperties": false,
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "$ref": "#/$defs/bar",
        \\     "$defs": {
        \\         "bar": {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-before-$ref.with-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "unevaluatedProperties": false,
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "$ref": "#/$defs/bar",
        \\     "$defs": {
        \\         "bar": {
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-$recursiveRef.with-no-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "https://example.com/unevaluated-properties-with-recursive-ref/extended-tree",
        \\     "$recursiveAnchor": true,
        \\     "$ref": "./tree",
        \\     "properties": {
        \\         "name": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "tree": {
        \\             "$id": "./tree",
        \\             "$recursiveAnchor": true,
        \\             "type": "object",
        \\             "properties": {
        \\                 "node": true,
        \\                 "branches": {
        \\                     "$comment": "unevaluatedProperties comes first so it's more likely to bugs errors with implementations that are sensitive to keyword ordering",
        \\                     "unevaluatedProperties": false,
        \\                     "$recursiveRef": "#"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "node"
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "name": "a",
        \\     "node": 1,
        \\     "branches": {
        \\         "name": "b",
        \\         "node": 2
        \\     }
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-$recursiveRef.with-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "https://example.com/unevaluated-properties-with-recursive-ref/extended-tree",
        \\     "$recursiveAnchor": true,
        \\     "$ref": "./tree",
        \\     "properties": {
        \\         "name": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "tree": {
        \\             "$id": "./tree",
        \\             "$recursiveAnchor": true,
        \\             "type": "object",
        \\             "properties": {
        \\                 "node": true,
        \\                 "branches": {
        \\                     "$comment": "unevaluatedProperties comes first so it's more likely to bugs errors with implementations that are sensitive to keyword ordering",
        \\                     "unevaluatedProperties": false,
        \\                     "$recursiveRef": "#"
        \\                 }
        \\             },
        \\             "required": [
        \\                 "node"
        \\             ]
        \\         }
        \\     }
        \\ }
    ,
        \\ {
        \\     "name": "a",
        \\     "node": 1,
        \\     "branches": {
        \\         "foo": "b",
        \\         "node": 2
        \\     }
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-can't-see-inside-cousins.always-fails" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": true
        \\             }
        \\         },
        \\         {
        \\             "unevaluatedProperties": false
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-can't-see-inside-cousins-(reverse-order).always-fails" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "allOf": [
        \\         {
        \\             "unevaluatedProperties": false
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": true
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-false,-inner-true,-properties-outside.with-no-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "unevaluatedProperties": true
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-false,-inner-true,-properties-outside.with-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "unevaluatedProperties": true
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-false,-inner-true,-properties-inside.with-no-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "unevaluatedProperties": true
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-false,-inner-true,-properties-inside.with-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "unevaluatedProperties": true
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-true,-inner-false,-properties-outside.with-no-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "unevaluatedProperties": false
        \\         }
        \\     ],
        \\     "unevaluatedProperties": true
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-true,-inner-false,-properties-outside.with-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "unevaluatedProperties": false
        \\         }
        \\     ],
        \\     "unevaluatedProperties": true
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-true,-inner-false,-properties-inside.with-no-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "unevaluatedProperties": false
        \\         }
        \\     ],
        \\     "unevaluatedProperties": true
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-true,-inner-false,-properties-inside.with-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "unevaluatedProperties": false
        \\         }
        \\     ],
        \\     "unevaluatedProperties": true
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.cousin-unevaluatedProperties,-true-and-false,-true-with-properties.with-no-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "unevaluatedProperties": true
        \\         },
        \\         {
        \\             "unevaluatedProperties": false
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.cousin-unevaluatedProperties,-true-and-false,-true-with-properties.with-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "unevaluatedProperties": true
        \\         },
        \\         {
        \\             "unevaluatedProperties": false
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.cousin-unevaluatedProperties,-true-and-false,-false-with-properties.with-no-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "unevaluatedProperties": true
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "unevaluatedProperties": false
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.cousin-unevaluatedProperties,-true-and-false,-false-with-properties.with-nested-unevaluated-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "unevaluatedProperties": true
        \\         },
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "unevaluatedProperties": false
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.property-is-evaluated-in-an-uncle-schema-to-unevaluatedProperties.no-extra-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "object",
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "unevaluatedProperties": false
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "properties": {
        \\                         "faz": {
        \\                             "type": "string"
        \\                         }
        \\                     }
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": "test"
        \\     }
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.property-is-evaluated-in-an-uncle-schema-to-unevaluatedProperties.uncle-keyword-evaluation-is-not-significant" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "object",
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "unevaluatedProperties": false
        \\         }
        \\     },
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": {
        \\                     "properties": {
        \\                         "faz": {
        \\                             "type": "string"
        \\                         }
        \\                     }
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": {
        \\         "bar": "test",
        \\         "faz": "test"
        \\     }
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.in-place-applicator-siblings,-allOf-has-unevaluated.base-case:-both-properties-present" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": true
        \\             },
        \\             "unevaluatedProperties": false
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": true
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.in-place-applicator-siblings,-allOf-has-unevaluated.in-place-applicator-siblings,-bar-is-missing" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": true
        \\             },
        \\             "unevaluatedProperties": false
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": true
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.in-place-applicator-siblings,-allOf-has-unevaluated.in-place-applicator-siblings,-foo-is-missing" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": true
        \\             },
        \\             "unevaluatedProperties": false
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": true
        \\             }
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "bar": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.in-place-applicator-siblings,-anyOf-has-unevaluated.base-case:-both-properties-present" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": true
        \\             }
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": true
        \\             },
        \\             "unevaluatedProperties": false
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.in-place-applicator-siblings,-anyOf-has-unevaluated.in-place-applicator-siblings,-bar-is-missing" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": true
        \\             }
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": true
        \\             },
        \\             "unevaluatedProperties": false
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.in-place-applicator-siblings,-anyOf-has-unevaluated.in-place-applicator-siblings,-foo-is-missing" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "allOf": [
        \\         {
        \\             "properties": {
        \\                 "foo": true
        \\             }
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "properties": {
        \\                 "bar": true
        \\             },
        \\             "unevaluatedProperties": false
        \\         }
        \\     ]
        \\ }
    ,
        \\ {
        \\     "bar": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Empty-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Single-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "x": {}
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Unevaluated-on-1st-level-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "x": {},
        \\     "y": {}
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Nested-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "x": {
        \\         "x": {}
        \\     }
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Unevaluated-on-2nd-level-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "x": {
        \\         "x": {},
        \\         "y": {}
        \\     }
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Deep-nested-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "x": {
        \\         "x": {
        \\             "x": {}
        \\         }
        \\     }
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Unevaluated-on-3rd-level-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "type": "object",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "x": {
        \\         "x": {
        \\             "x": {},
        \\             "y": {}
        \\         }
        \\     }
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.Empty-is-invalid-(no-x-or-y)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         },
        \\         "two": {
        \\             "required": [
        \\                 "x"
        \\             ],
        \\             "properties": {
        \\                 "x": true
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "properties": {
        \\                 "b": true
        \\             }
        \\         },
        \\         {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "y"
        \\                     ],
        \\                     "properties": {
        \\                         "y": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.a-and-b-are-invalid-(no-x-or-y)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         },
        \\         "two": {
        \\             "required": [
        \\                 "x"
        \\             ],
        \\             "properties": {
        \\                 "x": true
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "properties": {
        \\                 "b": true
        \\             }
        \\         },
        \\         {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "y"
        \\                     ],
        \\                     "properties": {
        \\                         "y": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "a": 1,
        \\     "b": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.x-and-y-are-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         },
        \\         "two": {
        \\             "required": [
        \\                 "x"
        \\             ],
        \\             "properties": {
        \\                 "x": true
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "properties": {
        \\                 "b": true
        \\             }
        \\         },
        \\         {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "y"
        \\                     ],
        \\                     "properties": {
        \\                         "y": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "x": 1,
        \\     "y": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.a-and-x-are-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         },
        \\         "two": {
        \\             "required": [
        \\                 "x"
        \\             ],
        \\             "properties": {
        \\                 "x": true
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "properties": {
        \\                 "b": true
        \\             }
        \\         },
        \\         {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "y"
        \\                     ],
        \\                     "properties": {
        \\                         "y": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "a": 1,
        \\     "x": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.a-and-y-are-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         },
        \\         "two": {
        \\             "required": [
        \\                 "x"
        \\             ],
        \\             "properties": {
        \\                 "x": true
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "properties": {
        \\                 "b": true
        \\             }
        \\         },
        \\         {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "y"
        \\                     ],
        \\                     "properties": {
        \\                         "y": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "a": 1,
        \\     "y": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.a-and-b-and-x-are-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         },
        \\         "two": {
        \\             "required": [
        \\                 "x"
        \\             ],
        \\             "properties": {
        \\                 "x": true
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "properties": {
        \\                 "b": true
        \\             }
        \\         },
        \\         {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "y"
        \\                     ],
        \\                     "properties": {
        \\                         "y": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "a": 1,
        \\     "b": 1,
        \\     "x": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.a-and-b-and-y-are-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         },
        \\         "two": {
        \\             "required": [
        \\                 "x"
        \\             ],
        \\             "properties": {
        \\                 "x": true
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "properties": {
        \\                 "b": true
        \\             }
        \\         },
        \\         {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "y"
        \\                     ],
        \\                     "properties": {
        \\                         "y": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "a": 1,
        \\     "b": 1,
        \\     "y": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.a-and-b-and-x-and-y-are-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         },
        \\         "two": {
        \\             "required": [
        \\                 "x"
        \\             ],
        \\             "properties": {
        \\                 "x": true
        \\             }
        \\         }
        \\     },
        \\     "allOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "properties": {
        \\                 "b": true
        \\             }
        \\         },
        \\         {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "y"
        \\                     ],
        \\                     "properties": {
        \\                         "y": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "a": 1,
        \\     "b": 1,
        \\     "x": 1,
        \\     "y": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.Empty-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.a-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "a": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.b-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "b": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.c-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "c": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.d-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "d": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.a-+-b-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "a": 1,
        \\     "b": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.a-+-c-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "a": 1,
        \\     "c": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.a-+-d-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "a": 1,
        \\     "d": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.b-+-c-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "b": 1,
        \\     "c": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.b-+-d-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "b": 1,
        \\     "d": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.c-+-d-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "c": 1,
        \\     "d": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "xx": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-+-foox-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "xx": 1,
        \\     "foox": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-+-foo-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "xx": 1,
        \\     "foo": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-+-a-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "xx": 1,
        \\     "a": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-+-b-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "xx": 1,
        \\     "b": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-+-c-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "xx": 1,
        \\     "c": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-+-d-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "xx": 1,
        \\     "d": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.all-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "all": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.all-+-foo-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "all": 1,
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.all-+-a-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$defs": {
        \\         "one": {
        \\             "oneOf": [
        \\                 {
        \\                     "$ref": "#/$defs/two"
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "b"
        \\                     ],
        \\                     "properties": {
        \\                         "b": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "xx"
        \\                     ],
        \\                     "patternProperties": {
        \\                         "x": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "all"
        \\                     ],
        \\                     "unevaluatedProperties": true
        \\                 }
        \\             ]
        \\         },
        \\         "two": {
        \\             "oneOf": [
        \\                 {
        \\                     "required": [
        \\                         "c"
        \\                     ],
        \\                     "properties": {
        \\                         "c": true
        \\                     }
        \\                 },
        \\                 {
        \\                     "required": [
        \\                         "d"
        \\                     ],
        \\                     "properties": {
        \\                         "d": true
        \\                     }
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "oneOf": [
        \\         {
        \\             "$ref": "#/$defs/one"
        \\         },
        \\         {
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "properties": {
        \\                 "a": true
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "all": 1,
        \\     "a": 1
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.non-object-instances-are-valid.ignores-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ true
    ,
        true,
    );
}
test "unevaluatedProperties.non-object-instances-are-valid.ignores-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ 123
    ,
        true,
    );
}
test "unevaluatedProperties.non-object-instances-are-valid.ignores-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "unevaluatedProperties.non-object-instances-are-valid.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "unevaluatedProperties.non-object-instances-are-valid.ignores-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "unevaluatedProperties.non-object-instances-are-valid.ignores-null" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-with-null-valued-instance-properties.allows-null-valued-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "unevaluatedProperties": {
        \\         "type": "null"
        \\     }
        \\ }
    ,
        \\ {
        \\     "foo": null
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-not-affected-by-propertyNames.allows-only-number-properties" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "maxLength": 1
        \\     },
        \\     "unevaluatedProperties": {
        \\         "type": "number"
        \\     }
        \\ }
    ,
        \\ {
        \\     "a": 1
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-not-affected-by-propertyNames.string-property-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "propertyNames": {
        \\         "maxLength": 1
        \\     },
        \\     "unevaluatedProperties": {
        \\         "type": "number"
        \\     }
        \\ }
    ,
        \\ {
        \\     "a": "b"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.unevaluatedProperties-can-see-annotations-from-if-without-then-and-else.valid-in-case-if-is-evaluated" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "patternProperties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": "a"
        \\ }
    ,
        true,
    );
}
test "unevaluatedProperties.unevaluatedProperties-can-see-annotations-from-if-without-then-and-else.invalid-in-case-if-is-evaluated" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "if": {
        \\         "patternProperties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "bar": "a"
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dependentSchemas-with-unevaluatedProperties.unevaluatedProperties-doesn't-consider-dependentSchemas" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo2": {}
        \\     },
        \\     "dependentSchemas": {
        \\         "foo": {},
        \\         "foo2": {
        \\             "properties": {
        \\                 "bar": {}
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo": ""
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dependentSchemas-with-unevaluatedProperties.unevaluatedProperties-doesn't-see-bar-when-foo2-is-absent" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo2": {}
        \\     },
        \\     "dependentSchemas": {
        \\         "foo": {},
        \\         "foo2": {
        \\             "properties": {
        \\                 "bar": {}
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "bar": ""
        \\ }
    ,
        false,
    );
}
test "unevaluatedProperties.dependentSchemas-with-unevaluatedProperties.unevaluatedProperties-sees-bar-when-foo2-is-present" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "properties": {
        \\         "foo2": {}
        \\     },
        \\     "dependentSchemas": {
        \\         "foo": {},
        \\         "foo2": {
        \\             "properties": {
        \\                 "bar": {}
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    ,
        \\ {
        \\     "foo2": "",
        \\     "bar": ""
        \\ }
    ,
        true,
    );
}
test "maxItems.maxItems-validation.shorter-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxItems": 2
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "maxItems.maxItems-validation.exact-length-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxItems": 2
        \\ }
    ,
        \\ [
        \\     1,
        \\     2
        \\ ]
    ,
        true,
    );
}
test "maxItems.maxItems-validation.too-long-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxItems": 2
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ,
        false,
    );
}
test "maxItems.maxItems-validation.ignores-non-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxItems": 2
        \\ }
    ,
        \\ "foobar"
    ,
        true,
    );
}
test "maxItems.maxItems-validation-with-a-decimal.shorter-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxItems": 2
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "maxItems.maxItems-validation-with-a-decimal.too-long-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "maxItems": 2
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ,
        false,
    );
}
test "pattern.pattern-validation.a-matching-pattern-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "pattern": "^a*$"
        \\ }
    ,
        \\ "aaa"
    ,
        true,
    );
}
test "pattern.pattern-validation.a-non-matching-pattern-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "pattern": "^a*$"
        \\ }
    ,
        \\ "abc"
    ,
        false,
    );
}
test "pattern.pattern-validation.ignores-booleans" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "pattern": "^a*$"
        \\ }
    ,
        \\ true
    ,
        true,
    );
}
test "pattern.pattern-validation.ignores-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "pattern": "^a*$"
        \\ }
    ,
        \\ 123
    ,
        true,
    );
}
test "pattern.pattern-validation.ignores-floats" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "pattern": "^a*$"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "pattern.pattern-validation.ignores-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "pattern": "^a*$"
        \\ }
    ,
        \\ {}
    ,
        true,
    );
}
test "pattern.pattern-validation.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "pattern": "^a*$"
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "pattern.pattern-validation.ignores-null" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "pattern": "^a*$"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "pattern.pattern-is-not-anchored.matches-a-substring" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "pattern": "a+"
        \\ }
    ,
        \\ "xxaayy"
    ,
        true,
    );
}
test "minProperties.minProperties-validation.longer-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minProperties": 1
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        true,
    );
}
test "minProperties.minProperties-validation.exact-length-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minProperties": 1
        \\ }
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        true,
    );
}
test "minProperties.minProperties-validation.too-short-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minProperties": 1
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "minProperties.minProperties-validation.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minProperties": 1
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "minProperties.minProperties-validation.ignores-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minProperties": 1
        \\ }
    ,
        \\ ""
    ,
        true,
    );
}
test "minProperties.minProperties-validation.ignores-other-non-objects" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minProperties": 1
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "minProperties.minProperties-validation-with-a-decimal.longer-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minProperties": 1
        \\ }
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        true,
    );
}
test "minProperties.minProperties-validation-with-a-decimal.too-short-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "minProperties": 1
        \\ }
    ,
        \\ {}
    ,
        false,
    );
}
test "anchor.Location-independent-identifier.match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "#foo",
        \\     "$defs": {
        \\         "A": {
        \\             "$anchor": "foo",
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "anchor.Location-independent-identifier.mismatch" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "#foo",
        \\     "$defs": {
        \\         "A": {
        \\             "$anchor": "foo",
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        \\ "a"
    ,
        false,
    );
}
test "anchor.Location-independent-identifier-with-absolute-URI.match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/bar#foo",
        \\     "$defs": {
        \\         "A": {
        \\             "$id": "http://localhost:1234/draft2019-09/bar",
        \\             "$anchor": "foo",
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "anchor.Location-independent-identifier-with-absolute-URI.mismatch" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "http://localhost:1234/draft2019-09/bar#foo",
        \\     "$defs": {
        \\         "A": {
        \\             "$id": "http://localhost:1234/draft2019-09/bar",
        \\             "$anchor": "foo",
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        \\ "a"
    ,
        false,
    );
}
test "anchor.Location-independent-identifier-with-base-URI-change-in-subschema.match" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/root",
        \\     "$ref": "http://localhost:1234/draft2019-09/nested.json#foo",
        \\     "$defs": {
        \\         "A": {
        \\             "$id": "nested.json",
        \\             "$defs": {
        \\                 "B": {
        \\                     "$anchor": "foo",
        \\                     "type": "integer"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "anchor.Location-independent-identifier-with-base-URI-change-in-subschema.mismatch" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/root",
        \\     "$ref": "http://localhost:1234/draft2019-09/nested.json#foo",
        \\     "$defs": {
        \\         "A": {
        \\             "$id": "nested.json",
        \\             "$defs": {
        \\                 "B": {
        \\                     "$anchor": "foo",
        \\                     "type": "integer"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ "a"
    ,
        false,
    );
}
test "anchor.same-$anchor-with-different-base-uri.$ref-resolves-to-/$defs/A/allOf/1" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/foobar",
        \\     "$defs": {
        \\         "A": {
        \\             "$id": "child1",
        \\             "allOf": [
        \\                 {
        \\                     "$id": "child2",
        \\                     "$anchor": "my_anchor",
        \\                     "type": "number"
        \\                 },
        \\                 {
        \\                     "$anchor": "my_anchor",
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "$ref": "child1#my_anchor"
        \\ }
    ,
        \\ "a"
    ,
        true,
    );
}
test "anchor.same-$anchor-with-different-base-uri.$ref-does-not-resolve-to-/$defs/A/allOf/0" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$id": "http://localhost:1234/draft2019-09/foobar",
        \\     "$defs": {
        \\         "A": {
        \\             "$id": "child1",
        \\             "allOf": [
        \\                 {
        \\                     "$id": "child2",
        \\                     "$anchor": "my_anchor",
        \\                     "type": "number"
        \\                 },
        \\                 {
        \\                     "$anchor": "my_anchor",
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "$ref": "child1#my_anchor"
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "enum.simple-enum-validation.one-of-the-enum-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         1,
        \\         2,
        \\         3
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "enum.simple-enum-validation.something-else-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         1,
        \\         2,
        \\         3
        \\     ]
        \\ }
    ,
        \\ 4
    ,
        false,
    );
}
test "enum.heterogeneous-enum-validation.one-of-the-enum-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ []
    ,
        true,
    );
}
test "enum.heterogeneous-enum-validation.something-else-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ null
    ,
        false,
    );
}
test "enum.heterogeneous-enum-validation.objects-are-deep-compared" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": false
        \\ }
    ,
        false,
    );
}
test "enum.heterogeneous-enum-validation.valid-object-matches" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": 12
        \\ }
    ,
        true,
    );
}
test "enum.heterogeneous-enum-validation.extra-properties-in-object-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": 12,
        \\     "boo": 42
        \\ }
    ,
        false,
    );
}
test "enum.heterogeneous-enum-with-null-validation.null-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         6,
        \\         null
        \\     ]
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "enum.heterogeneous-enum-with-null-validation.number-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         6,
        \\         null
        \\     ]
        \\ }
    ,
        \\ 6
    ,
        true,
    );
}
test "enum.heterogeneous-enum-with-null-validation.something-else-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         6,
        \\         null
        \\     ]
        \\ }
    ,
        \\ "test"
    ,
        false,
    );
}
test "enum.enums-in-properties.both-properties-are-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "enum.enums-in-properties.wrong-foo-value" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "foot",
        \\     "bar": "bar"
        \\ }
    ,
        false,
    );
}
test "enum.enums-in-properties.wrong-bar-value" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bart"
        \\ }
    ,
        false,
    );
}
test "enum.enums-in-properties.missing-optional-property-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "bar": "bar"
        \\ }
    ,
        true,
    );
}
test "enum.enums-in-properties.missing-required-property-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "foo"
        \\ }
    ,
        false,
    );
}
test "enum.enums-in-properties.missing-all-properties-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {}
    ,
        false,
    );
}
test "enum.enum-with-escaped-characters.member-1-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         "foo\nbar",
        \\         "foo\rbar"
        \\     ]
        \\ }
    ,
        \\ "foo\nbar"
    ,
        true,
    );
}
test "enum.enum-with-escaped-characters.member-2-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         "foo\nbar",
        \\         "foo\rbar"
        \\     ]
        \\ }
    ,
        \\ "foo\rbar"
    ,
        true,
    );
}
test "enum.enum-with-escaped-characters.another-string-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         "foo\nbar",
        \\         "foo\rbar"
        \\     ]
        \\ }
    ,
        \\ "abc"
    ,
        false,
    );
}
test "enum.enum-with-false-does-not-match-0.false-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         false
        \\     ]
        \\ }
    ,
        \\ false
    ,
        true,
    );
}
test "enum.enum-with-false-does-not-match-0.integer-zero-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         false
        \\     ]
        \\ }
    ,
        \\ 0
    ,
        false,
    );
}
test "enum.enum-with-false-does-not-match-0.float-zero-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         false
        \\     ]
        \\ }
    ,
        \\ 0
    ,
        false,
    );
}
test "enum.enum-with-[false]-does-not-match-[0].[false]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         [
        \\             false
        \\         ]
        \\     ]
        \\ }
    ,
        \\ [
        \\     false
        \\ ]
    ,
        true,
    );
}
test "enum.enum-with-[false]-does-not-match-[0].[0]-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         [
        \\             false
        \\         ]
        \\     ]
        \\ }
    ,
        \\ [
        \\     0
        \\ ]
    ,
        false,
    );
}
test "enum.enum-with-[false]-does-not-match-[0].[0.0]-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         [
        \\             false
        \\         ]
        \\     ]
        \\ }
    ,
        \\ [
        \\     0
        \\ ]
    ,
        false,
    );
}
test "enum.enum-with-true-does-not-match-1.true-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         true
        \\     ]
        \\ }
    ,
        \\ true
    ,
        true,
    );
}
test "enum.enum-with-true-does-not-match-1.integer-one-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         true
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "enum.enum-with-true-does-not-match-1.float-one-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         true
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        false,
    );
}
test "enum.enum-with-[true]-does-not-match-[1].[true]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         [
        \\             true
        \\         ]
        \\     ]
        \\ }
    ,
        \\ [
        \\     true
        \\ ]
    ,
        true,
    );
}
test "enum.enum-with-[true]-does-not-match-[1].[1]-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         [
        \\             true
        \\         ]
        \\     ]
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        false,
    );
}
test "enum.enum-with-[true]-does-not-match-[1].[1.0]-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         [
        \\             true
        \\         ]
        \\     ]
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        false,
    );
}
test "enum.enum-with-0-does-not-match-false.false-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         0
        \\     ]
        \\ }
    ,
        \\ false
    ,
        false,
    );
}
test "enum.enum-with-0-does-not-match-false.integer-zero-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         0
        \\     ]
        \\ }
    ,
        \\ 0
    ,
        true,
    );
}
test "enum.enum-with-0-does-not-match-false.float-zero-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         0
        \\     ]
        \\ }
    ,
        \\ 0
    ,
        true,
    );
}
test "enum.enum-with-[0]-does-not-match-[false].[false]-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         [
        \\             0
        \\         ]
        \\     ]
        \\ }
    ,
        \\ [
        \\     false
        \\ ]
    ,
        false,
    );
}
test "enum.enum-with-[0]-does-not-match-[false].[0]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         [
        \\             0
        \\         ]
        \\     ]
        \\ }
    ,
        \\ [
        \\     0
        \\ ]
    ,
        true,
    );
}
test "enum.enum-with-[0]-does-not-match-[false].[0.0]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         [
        \\             0
        \\         ]
        \\     ]
        \\ }
    ,
        \\ [
        \\     0
        \\ ]
    ,
        true,
    );
}
test "enum.enum-with-1-does-not-match-true.true-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         1
        \\     ]
        \\ }
    ,
        \\ true
    ,
        false,
    );
}
test "enum.enum-with-1-does-not-match-true.integer-one-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         1
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "enum.enum-with-1-does-not-match-true.float-one-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         1
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "enum.enum-with-[1]-does-not-match-[true].[true]-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         [
        \\             1
        \\         ]
        \\     ]
        \\ }
    ,
        \\ [
        \\     true
        \\ ]
    ,
        false,
    );
}
test "enum.enum-with-[1]-does-not-match-[true].[1]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         [
        \\             1
        \\         ]
        \\     ]
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "enum.enum-with-[1]-does-not-match-[true].[1.0]-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         [
        \\             1
        \\         ]
        \\     ]
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "enum.nul-characters-in-strings.match-string-with-nul" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         "hello\u0000there"
        \\     ]
        \\ }
    ,
        \\ "hello\u0000there"
    ,
        true,
    );
}
test "enum.nul-characters-in-strings.do-not-match-string-lacking-nul" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "enum": [
        \\         "hello\u0000there"
        \\     ]
        \\ }
    ,
        \\ "hellothere"
    ,
        false,
    );
}
test "additionalItems.additionalItems-as-schema.additional-items-match-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {}
        \\     ],
        \\     "additionalItems": {
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ [
        \\     null,
        \\     2,
        \\     3,
        \\     4
        \\ ]
    ,
        true,
    );
}
test "additionalItems.additionalItems-as-schema.additional-items-do-not-match-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {}
        \\     ],
        \\     "additionalItems": {
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ [
        \\     null,
        \\     2,
        \\     3,
        \\     "foo"
        \\ ]
    ,
        false,
    );
}
test "additionalItems.when-items-is-schema,-additionalItems-does-nothing.valid-with-a-array-of-type-integers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": {
        \\         "type": "integer"
        \\     },
        \\     "additionalItems": {
        \\         "type": "string"
        \\     }
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ,
        true,
    );
}
test "additionalItems.when-items-is-schema,-additionalItems-does-nothing.invalid-with-a-array-of-mixed-types" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": {
        \\         "type": "integer"
        \\     },
        \\     "additionalItems": {
        \\         "type": "string"
        \\     }
        \\ }
    ,
        \\ [
        \\     1,
        \\     "2",
        \\     "3"
        \\ ]
    ,
        false,
    );
}
test "additionalItems.when-items-is-schema,-boolean-additionalItems-does-nothing.all-items-match-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": {},
        \\     "additionalItems": false
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3,
        \\     4,
        \\     5
        \\ ]
    ,
        true,
    );
}
test "additionalItems.array-of-items-with-no-additionalItems-permitted.empty-array" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "additionalItems.array-of-items-with-no-additionalItems-permitted.fewer-number-of-items-present-(1)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    ,
        \\ [
        \\     1
        \\ ]
    ,
        true,
    );
}
test "additionalItems.array-of-items-with-no-additionalItems-permitted.fewer-number-of-items-present-(2)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    ,
        \\ [
        \\     1,
        \\     2
        \\ ]
    ,
        true,
    );
}
test "additionalItems.array-of-items-with-no-additionalItems-permitted.equal-number-of-items-present" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3
        \\ ]
    ,
        true,
    );
}
test "additionalItems.array-of-items-with-no-additionalItems-permitted.additional-items-are-not-permitted" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3,
        \\     4
        \\ ]
    ,
        false,
    );
}
test "additionalItems.additionalItems-as-false-without-items.items-defaults-to-empty-schema-so-everything-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "additionalItems": false
        \\ }
    ,
        \\ [
        \\     1,
        \\     2,
        \\     3,
        \\     4,
        \\     5
        \\ ]
    ,
        true,
    );
}
test "additionalItems.additionalItems-as-false-without-items.ignores-non-arrays" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "additionalItems": false
        \\ }
    ,
        \\ {
        \\     "foo": "bar"
        \\ }
    ,
        true,
    );
}
test "additionalItems.additionalItems-are-allowed-by-default.only-the-first-item-is-validated" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "integer"
        \\         }
        \\     ]
        \\ }
    ,
        \\ [
        \\     1,
        \\     "foo",
        \\     false
        \\ ]
    ,
        true,
    );
}
test "additionalItems.additionalItems-does-not-look-in-applicators,-valid-case.items-defined-in-allOf-are-not-examined" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     1,
        \\     null
        \\ ]
    ,
        true,
    );
}
test "additionalItems.additionalItems-does-not-look-in-applicators,-invalid-case.items-defined-in-allOf-are-not-examined" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ [
        \\     1,
        \\     "hello"
        \\ ]
    ,
        false,
    );
}
test "additionalItems.items-validation-adjusts-the-starting-index-for-additionalItems.valid-items" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "additionalItems": {
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ [
        \\     "x",
        \\     2,
        \\     3
        \\ ]
    ,
        true,
    );
}
test "additionalItems.items-validation-adjusts-the-starting-index-for-additionalItems.wrong-type-of-second-item" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "additionalItems": {
        \\         "type": "integer"
        \\     }
        \\ }
    ,
        \\ [
        \\     "x",
        \\     "y"
        \\ ]
    ,
        false,
    );
}
test "additionalItems.additionalItems-with-heterogeneous-array.heterogeneous-invalid-instance" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    ,
        \\ [
        \\     "foo",
        \\     "bar",
        \\     37
        \\ ]
    ,
        false,
    );
}
test "additionalItems.additionalItems-with-heterogeneous-array.valid-instance" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "items": [
        \\         {}
        \\     ],
        \\     "additionalItems": false
        \\ }
    ,
        \\ [
        \\     null
        \\ ]
    ,
        true,
    );
}
test "additionalItems.additionalItems-with-null-instance-elements.allows-null-elements" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "additionalItems": {
        \\         "type": "null"
        \\     }
        \\ }
    ,
        \\ [
        \\     null
        \\ ]
    ,
        true,
    );
}
test "exclusiveMaximum.exclusiveMaximum-validation.below-the-exclusiveMaximum-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "exclusiveMaximum": 3
        \\ }
    ,
        \\ 2.2
    ,
        true,
    );
}
test "exclusiveMaximum.exclusiveMaximum-validation.boundary-point-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "exclusiveMaximum": 3
        \\ }
    ,
        \\ 3
    ,
        false,
    );
}
test "exclusiveMaximum.exclusiveMaximum-validation.above-the-exclusiveMaximum-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "exclusiveMaximum": 3
        \\ }
    ,
        \\ 3.5
    ,
        false,
    );
}
test "exclusiveMaximum.exclusiveMaximum-validation.ignores-non-numbers" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "exclusiveMaximum": 3
        \\ }
    ,
        \\ "x"
    ,
        true,
    );
}
test "anyOf.anyOf.first-anyOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "anyOf.anyOf.second-anyOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    ,
        \\ 2.5
    ,
        true,
    );
}
test "anyOf.anyOf.both-anyOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    ,
        \\ 3
    ,
        true,
    );
}
test "anyOf.anyOf.neither-anyOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "anyOf": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "minimum": 2
        \\         }
        \\     ]
        \\ }
    ,
        \\ 1.5
    ,
        false,
    );
}
test "anyOf.anyOf-with-base-schema.mismatch-base-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 3
    ,
        false,
    );
}
test "anyOf.anyOf-with-base-schema.one-anyOf-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ "foobar"
    ,
        true,
    );
}
test "anyOf.anyOf-with-base-schema.both-anyOf-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ "foo"
    ,
        false,
    );
}
test "anyOf.anyOf-with-boolean-schemas,-all-true.any-value-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "anyOf": [
        \\         true,
        \\         true
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "anyOf.anyOf-with-boolean-schemas,-some-true.any-value-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "anyOf": [
        \\         true,
        \\         false
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "anyOf.anyOf-with-boolean-schemas,-all-false.any-value-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "anyOf": [
        \\         false,
        \\         false
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "anyOf.anyOf-complex-types.first-anyOf-valid-(complex)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "bar": 2
        \\ }
    ,
        true,
    );
}
test "anyOf.anyOf-complex-types.second-anyOf-valid-(complex)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "baz"
        \\ }
    ,
        true,
    );
}
test "anyOf.anyOf-complex-types.both-anyOf-valid-(complex)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": "baz",
        \\     "bar": 2
        \\ }
    ,
        true,
    );
}
test "anyOf.anyOf-complex-types.neither-anyOf-valid-(complex)" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ {
        \\     "foo": 2,
        \\     "bar": "quux"
        \\ }
    ,
        false,
    );
}
test "anyOf.anyOf-with-one-empty-schema.string-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "anyOf": [
        \\         {
        \\             "type": "number"
        \\         },
        \\         {}
        \\     ]
        \\ }
    ,
        \\ "foo"
    ,
        true,
    );
}
test "anyOf.anyOf-with-one-empty-schema.number-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "anyOf": [
        \\         {
        \\             "type": "number"
        \\         },
        \\         {}
        \\     ]
        \\ }
    ,
        \\ 123
    ,
        true,
    );
}
test "anyOf.nested-anyOf,-to-check-validation-semantics.null-is-valid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ null
    ,
        true,
    );
}
test "anyOf.nested-anyOf,-to-check-validation-semantics.anything-non-null-is-invalid" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
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
    ,
        \\ 123
    ,
        false,
    );
}
test "content.validation-of-string-encoded-content-based-on-media-type.a-valid-JSON-document" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json"
        \\ }
    ,
        \\ "{\"foo\": \"bar\"}"
    ,
        true,
    );
}
test "content.validation-of-string-encoded-content-based-on-media-type.an-invalid-JSON-document;-validates-true" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json"
        \\ }
    ,
        \\ "{:}"
    ,
        true,
    );
}
test "content.validation-of-string-encoded-content-based-on-media-type.ignores-non-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json"
        \\ }
    ,
        \\ 100
    ,
        true,
    );
}
test "content.validation-of-binary-string-encoding.a-valid-base64-string" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentEncoding": "base64"
        \\ }
    ,
        \\ "eyJmb28iOiAiYmFyIn0K"
    ,
        true,
    );
}
test "content.validation-of-binary-string-encoding.an-invalid-base64-string-(%-is-not-a-valid-character);-validates-true" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentEncoding": "base64"
        \\ }
    ,
        \\ "eyJmb28iOi%iYmFyIn0K"
    ,
        true,
    );
}
test "content.validation-of-binary-string-encoding.ignores-non-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentEncoding": "base64"
        \\ }
    ,
        \\ 100
    ,
        true,
    );
}
test "content.validation-of-binary-encoded-media-type-documents.a-valid-base64-encoded-JSON-document" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64"
        \\ }
    ,
        \\ "eyJmb28iOiAiYmFyIn0K"
    ,
        true,
    );
}
test "content.validation-of-binary-encoded-media-type-documents.a-validly-encoded-invalid-JSON-document;-validates-true" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64"
        \\ }
    ,
        \\ "ezp9Cg=="
    ,
        true,
    );
}
test "content.validation-of-binary-encoded-media-type-documents.an-invalid-base64-string-that-is-valid-JSON;-validates-true" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64"
        \\ }
    ,
        \\ "{}"
    ,
        true,
    );
}
test "content.validation-of-binary-encoded-media-type-documents.ignores-non-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64"
        \\ }
    ,
        \\ 100
    ,
        true,
    );
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.a-valid-base64-encoded-JSON-document" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64",
        \\     "contentSchema": {
        \\         "type": "object",
        \\         "required": [
        \\             "foo"
        \\         ],
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ "eyJmb28iOiAiYmFyIn0K"
    ,
        true,
    );
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.another-valid-base64-encoded-JSON-document" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64",
        \\     "contentSchema": {
        \\         "type": "object",
        \\         "required": [
        \\             "foo"
        \\         ],
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ "eyJib28iOiAyMCwgImZvbyI6ICJiYXoifQ=="
    ,
        true,
    );
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.an-invalid-base64-encoded-JSON-document;-validates-true" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64",
        \\     "contentSchema": {
        \\         "type": "object",
        \\         "required": [
        \\             "foo"
        \\         ],
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ "eyJib28iOiAyMH0="
    ,
        true,
    );
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.an-empty-object-as-a-base64-encoded-JSON-document;-validates-true" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64",
        \\     "contentSchema": {
        \\         "type": "object",
        \\         "required": [
        \\             "foo"
        \\         ],
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ "e30="
    ,
        true,
    );
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.an-empty-array-as-a-base64-encoded-JSON-document" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64",
        \\     "contentSchema": {
        \\         "type": "object",
        \\         "required": [
        \\             "foo"
        \\         ],
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ "W10="
    ,
        true,
    );
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.a-validly-encoded-invalid-JSON-document;-validates-true" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64",
        \\     "contentSchema": {
        \\         "type": "object",
        \\         "required": [
        \\             "foo"
        \\         ],
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ "ezp9Cg=="
    ,
        true,
    );
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.an-invalid-base64-string-that-is-valid-JSON;-validates-true" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64",
        \\     "contentSchema": {
        \\         "type": "object",
        \\         "required": [
        \\             "foo"
        \\         ],
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ "{}"
    ,
        true,
    );
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.ignores-non-strings" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64",
        \\     "contentSchema": {
        \\         "type": "object",
        \\         "required": [
        \\             "foo"
        \\         ],
        \\         "properties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     }
        \\ }
    ,
        \\ 100
    ,
        true,
    );
}
test "defs.validate-definition-against-metaschema.valid-definition-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "https://json-schema.org/draft/2019-09/schema"
        \\ }
    ,
        \\ {
        \\     "$defs": {
        \\         "foo": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        true,
    );
}
test "defs.validate-definition-against-metaschema.invalid-definition-schema" {
    try check_valid(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2019-09/schema",
        \\     "$ref": "https://json-schema.org/draft/2019-09/schema"
        \\ }
    ,
        \\ {
        \\     "$defs": {
        \\         "foo": {
        \\             "type": 1
        \\         }
        \\     }
        \\ }
    ,
        false,
    );
}
