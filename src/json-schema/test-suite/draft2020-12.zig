const std = @import("std");
const JSONSchema = @import("json-schema");

test "unevaluatedItems.unevaluatedItems-true.with-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": true
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-true.with-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": true
        \\ }
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-false.with-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-false.with-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-as-schema.with-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": {
        \\         "type": "string"
        \\     }
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-as-schema.with-valid-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": {
        \\         "type": "string"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-as-schema.with-invalid-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": {
        \\         "type": "string"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-uniform-items.unevaluatedItems-doesn't-apply" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "items": {
        \\         "type": "string"
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-tuple.with-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-tuple.with-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-items-and-prefixItems.unevaluatedItems-doesn't-apply" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "items": true,
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-items.valid-under-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "items": {
        \\         "type": "number"
        \\     },
        \\     "unevaluatedItems": {
        \\         "type": "string"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     5,
        \\     6,
        \\     7,
        \\     8
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-items.invalid-under-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "items": {
        \\         "type": "number"
        \\     },
        \\     "unevaluatedItems": {
        \\         "type": "string"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "baz"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-nested-tuple.with-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "allOf": [
        \\         {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "type": "number"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-nested-tuple.with-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "allOf": [
        \\         {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "type": "number"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     42,
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-nested-items.with-only-(valid)-additional-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ [
        \\     true,
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-nested-items.with-no-additional-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ [
        \\     "yes",
        \\     "no"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-nested-items.with-invalid-additional-item" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ [
        \\     "yes",
        \\     false
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-nested-prefixItems-and-items.with-no-additional-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         {
        \\             "prefixItems": [
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ],
        \\             "items": true
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-nested-prefixItems-and-items.with-additional-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         {
        \\             "prefixItems": [
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ],
        \\             "items": true
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     42,
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-nested-unevaluatedItems.with-no-additional-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         {
        \\             "prefixItems": [
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
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-nested-unevaluatedItems.with-additional-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         {
        \\             "prefixItems": [
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
    );

    const case =
        \\ [
        \\     "foo",
        \\     42,
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-anyOf.when-one-schema-matches-and-has-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "prefixItems": [
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
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-anyOf.when-one-schema-matches-and-has-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "prefixItems": [
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
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-anyOf.when-two-schemas-match-and-has-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "prefixItems": [
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
test "unevaluatedItems.unevaluatedItems-with-anyOf.when-two-schemas-match-and-has-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "anyOf": [
        \\         {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "prefixItems": [
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
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "baz",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-oneOf.with-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "oneOf": [
        \\         {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "const": "baz"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-oneOf.with-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "oneOf": [
        \\         {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         },
        \\         {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "const": "baz"
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-not.with-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "not": {
        \\         "not": {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "const": "bar"
        \\                 }
        \\             ]
        \\         }
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-if/then/else.when-if-matches-and-it-has-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "if": {
        \\         "prefixItems": [
        \\             true,
        \\             {
        \\                 "const": "bar"
        \\             }
        \\         ]
        \\     },
        \\     "then": {
        \\         "prefixItems": [
        \\             true,
        \\             true,
        \\             {
        \\                 "const": "then"
        \\             }
        \\         ]
        \\     },
        \\     "else": {
        \\         "prefixItems": [
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
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "then"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-if/then/else.when-if-matches-and-it-has-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "if": {
        \\         "prefixItems": [
        \\             true,
        \\             {
        \\                 "const": "bar"
        \\             }
        \\         ]
        \\     },
        \\     "then": {
        \\         "prefixItems": [
        \\             true,
        \\             true,
        \\             {
        \\                 "const": "then"
        \\             }
        \\         ]
        \\     },
        \\     "else": {
        \\         "prefixItems": [
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
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "then",
        \\     "else"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-if/then/else.when-if-doesn't-match-and-it-has-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "if": {
        \\         "prefixItems": [
        \\             true,
        \\             {
        \\                 "const": "bar"
        \\             }
        \\         ]
        \\     },
        \\     "then": {
        \\         "prefixItems": [
        \\             true,
        \\             true,
        \\             {
        \\                 "const": "then"
        \\             }
        \\         ]
        \\     },
        \\     "else": {
        \\         "prefixItems": [
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
    );

    const case =
        \\ [
        \\     "foo",
        \\     42,
        \\     42,
        \\     "else"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-if/then/else.when-if-doesn't-match-and-it-has-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "const": "foo"
        \\         }
        \\     ],
        \\     "if": {
        \\         "prefixItems": [
        \\             true,
        \\             {
        \\                 "const": "bar"
        \\             }
        \\         ]
        \\     },
        \\     "then": {
        \\         "prefixItems": [
        \\             true,
        \\             true,
        \\             {
        \\                 "const": "then"
        \\             }
        \\         ]
        \\     },
        \\     "else": {
        \\         "prefixItems": [
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
    );

    const case =
        \\ [
        \\     "foo",
        \\     42,
        \\     42,
        \\     "else",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-boolean-schemas.with-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         true
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-boolean-schemas.with-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         true
        \\     ],
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-$ref.with-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "#/$defs/bar",
        \\     "prefixItems": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "unevaluatedItems": false,
        \\     "$defs": {
        \\         "bar": {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-$ref.with-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "#/$defs/bar",
        \\     "prefixItems": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "unevaluatedItems": false,
        \\     "$defs": {
        \\         "bar": {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "baz"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-before-$ref.with-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": false,
        \\     "prefixItems": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "$ref": "#/$defs/bar",
        \\     "$defs": {
        \\         "bar": {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-before-$ref.with-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": false,
        \\     "prefixItems": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "$ref": "#/$defs/bar",
        \\     "$defs": {
        \\         "bar": {
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "baz"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-$dynamicRef.with-no-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://example.com/unevaluated-items-with-dynamic-ref/derived",
        \\     "$ref": "./baseSchema",
        \\     "$defs": {
        \\         "derived": {
        \\             "$dynamicAnchor": "addons",
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         },
        \\         "baseSchema": {
        \\             "$id": "./baseSchema",
        \\             "$comment": "unevaluatedItems comes first so it's more likely to catch bugs with implementations that are sensitive to keyword ordering",
        \\             "unevaluatedItems": false,
        \\             "type": "array",
        \\             "prefixItems": [
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ],
        \\             "$dynamicRef": "#addons",
        \\             "$defs": {
        \\                 "defaultAddons": {
        \\                     "$comment": "Needed to satisfy the bookending requirement",
        \\                     "$dynamicAnchor": "addons"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-$dynamicRef.with-unevaluated-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://example.com/unevaluated-items-with-dynamic-ref/derived",
        \\     "$ref": "./baseSchema",
        \\     "$defs": {
        \\         "derived": {
        \\             "$dynamicAnchor": "addons",
        \\             "prefixItems": [
        \\                 true,
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ]
        \\         },
        \\         "baseSchema": {
        \\             "$id": "./baseSchema",
        \\             "$comment": "unevaluatedItems comes first so it's more likely to catch bugs with implementations that are sensitive to keyword ordering",
        \\             "unevaluatedItems": false,
        \\             "type": "array",
        \\             "prefixItems": [
        \\                 {
        \\                     "type": "string"
        \\                 }
        \\             ],
        \\             "$dynamicRef": "#addons",
        \\             "$defs": {
        \\                 "defaultAddons": {
        \\                     "$comment": "Needed to satisfy the bookending requirement",
        \\                     "$dynamicAnchor": "addons"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar",
        \\     "baz"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-can't-see-inside-cousins.always-fails" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         {
        \\             "prefixItems": [
        \\                 true
        \\             ]
        \\         },
        \\         {
        \\             "unevaluatedItems": false
        \\         }
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
test "unevaluatedItems.item-is-evaluated-in-an-uncle-schema-to-unevaluatedItems.no-extra-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "prefixItems": [
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
        \\                     "prefixItems": [
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
    );

    const case =
        \\ {
        \\     "foo": [
        \\         "test"
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.item-is-evaluated-in-an-uncle-schema-to-unevaluatedItems.uncle-keyword-evaluation-is-not-significant" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "prefixItems": [
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
        \\                     "prefixItems": [
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
    );

    const case =
        \\ {
        \\     "foo": [
        \\         "test",
        \\         "test"
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-depends-on-adjacent-contains.second-item-is-evaluated-by-contains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         true
        \\     ],
        \\     "contains": {
        \\         "type": "string"
        \\     },
        \\     "unevaluatedItems": false
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
test "unevaluatedItems.unevaluatedItems-depends-on-adjacent-contains.contains-fails,-second-item-is-not-evaluated" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         true
        \\     ],
        \\     "contains": {
        \\         "type": "string"
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-depends-on-adjacent-contains.contains-passes,-second-item-is-not-evaluated" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         true
        \\     ],
        \\     "contains": {
        \\         "type": "string"
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2,
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-depends-on-multiple-nested-contains.5-not-evaluated,-passes-unevaluatedItems" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         {
        \\             "contains": {
        \\                 "multipleOf": 2
        \\             }
        \\         },
        \\         {
        \\             "contains": {
        \\                 "multipleOf": 3
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedItems": {
        \\         "multipleOf": 5
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     2,
        \\     3,
        \\     4,
        \\     5,
        \\     6
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-depends-on-multiple-nested-contains.7-not-evaluated,-fails-unevaluatedItems" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         {
        \\             "contains": {
        \\                 "multipleOf": 2
        \\             }
        \\         },
        \\         {
        \\             "contains": {
        \\                 "multipleOf": 3
        \\             }
        \\         }
        \\     ],
        \\     "unevaluatedItems": {
        \\         "multipleOf": 5
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     2,
        \\     3,
        \\     4,
        \\     7,
        \\     8
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-and-contains-interact-to-control-item-dependency-relationship.empty-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "contains": {
        \\             "const": "a"
        \\         }
        \\     },
        \\     "then": {
        \\         "if": {
        \\             "contains": {
        \\                 "const": "b"
        \\             }
        \\         },
        \\         "then": {
        \\             "if": {
        \\                 "contains": {
        \\                     "const": "c"
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-and-contains-interact-to-control-item-dependency-relationship.only-a's-are-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "contains": {
        \\             "const": "a"
        \\         }
        \\     },
        \\     "then": {
        \\         "if": {
        \\             "contains": {
        \\                 "const": "b"
        \\             }
        \\         },
        \\         "then": {
        \\             "if": {
        \\                 "contains": {
        \\                     "const": "c"
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "a",
        \\     "a"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-and-contains-interact-to-control-item-dependency-relationship.a's-and-b's-are-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "contains": {
        \\             "const": "a"
        \\         }
        \\     },
        \\     "then": {
        \\         "if": {
        \\             "contains": {
        \\                 "const": "b"
        \\             }
        \\         },
        \\         "then": {
        \\             "if": {
        \\                 "contains": {
        \\                     "const": "c"
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "a",
        \\     "b",
        \\     "a",
        \\     "b",
        \\     "a"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-and-contains-interact-to-control-item-dependency-relationship.a's,-b's-and-c's-are-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "contains": {
        \\             "const": "a"
        \\         }
        \\     },
        \\     "then": {
        \\         "if": {
        \\             "contains": {
        \\                 "const": "b"
        \\             }
        \\         },
        \\         "then": {
        \\             "if": {
        \\                 "contains": {
        \\                     "const": "c"
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "c",
        \\     "a",
        \\     "c",
        \\     "c",
        \\     "b",
        \\     "a"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-and-contains-interact-to-control-item-dependency-relationship.only-b's-are-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "contains": {
        \\             "const": "a"
        \\         }
        \\     },
        \\     "then": {
        \\         "if": {
        \\             "contains": {
        \\                 "const": "b"
        \\             }
        \\         },
        \\         "then": {
        \\             "if": {
        \\                 "contains": {
        \\                     "const": "c"
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "b",
        \\     "b"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-and-contains-interact-to-control-item-dependency-relationship.only-c's-are-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "contains": {
        \\             "const": "a"
        \\         }
        \\     },
        \\     "then": {
        \\         "if": {
        \\             "contains": {
        \\                 "const": "b"
        \\             }
        \\         },
        \\         "then": {
        \\             "if": {
        \\                 "contains": {
        \\                     "const": "c"
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "c",
        \\     "c"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-and-contains-interact-to-control-item-dependency-relationship.only-b's-and-c's-are-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "contains": {
        \\             "const": "a"
        \\         }
        \\     },
        \\     "then": {
        \\         "if": {
        \\             "contains": {
        \\                 "const": "b"
        \\             }
        \\         },
        \\         "then": {
        \\             "if": {
        \\                 "contains": {
        \\                     "const": "c"
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "c",
        \\     "b",
        \\     "c",
        \\     "b",
        \\     "c"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-and-contains-interact-to-control-item-dependency-relationship.only-a's-and-c's-are-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "contains": {
        \\             "const": "a"
        \\         }
        \\     },
        \\     "then": {
        \\         "if": {
        \\             "contains": {
        \\                 "const": "b"
        \\             }
        \\         },
        \\         "then": {
        \\             "if": {
        \\                 "contains": {
        \\                     "const": "c"
        \\                 }
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "c",
        \\     "a",
        \\     "c",
        \\     "a",
        \\     "c"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-minContains-=-0.empty-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "type": "string"
        \\     },
        \\     "minContains": 0,
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-minContains-=-0.no-items-evaluated-by-contains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "type": "string"
        \\     },
        \\     "minContains": 0,
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     0
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-minContains-=-0.some-but-not-all-items-evaluated-by-contains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "type": "string"
        \\     },
        \\     "minContains": 0,
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     0
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedItems.unevaluatedItems-with-minContains-=-0.all-items-evaluated-by-contains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "type": "string"
        \\     },
        \\     "minContains": 0,
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.non-array-instances-are-valid.ignores-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.non-array-instances-are-valid.ignores-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ 123
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.non-array-instances-are-valid.ignores-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.non-array-instances-are-valid.ignores-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.non-array-instances-are-valid.ignores-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.non-array-instances-are-valid.ignores-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-with-null-instance-elements.allows-null-elements" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedItems": {
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
test "unevaluatedItems.unevaluatedItems-can-see-annotations-from-if-without-then-and-else.valid-in-case-if-is-evaluated" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "prefixItems": [
        \\             {
        \\                 "const": "a"
        \\             }
        \\         ]
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "a"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedItems.unevaluatedItems-can-see-annotations-from-if-without-then-and-else.invalid-in-case-if-is-evaluated" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "prefixItems": [
        \\             {
        \\                 "const": "a"
        \\             }
        \\         ]
        \\     },
        \\     "unevaluatedItems": false
        \\ }
    );

    const case =
        \\ [
        \\     "b"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "maxLength.maxLength-validation.shorter-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "maxLength": 2
        \\ }
    );

    const case =
        \\ "💩💩"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxLength.maxLength-validation-with-a-decimal.shorter-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "maxLength": 2
        \\ }
    );

    const case =
        \\ "f"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxLength.maxLength-validation-with-a-decimal.too-long-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "maxLength": 2
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.remote-ref.remote-ref-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/integer.json"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/integer.json"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/subSchemas.json#/$defs/integer"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/subSchemas.json#/$defs/integer"
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.anchor-within-remote-ref.remote-anchor-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/locationIndependentIdentifier.json#foo"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.anchor-within-remote-ref.remote-anchor-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/locationIndependentIdentifier.json#foo"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/subSchemas.json#/$defs/refToInteger"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/subSchemas.json#/$defs/refToInteger"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/",
        \\     "items": {
        \\         "$id": "baseUriChange/",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/",
        \\     "items": {
        \\         "$id": "baseUriChange/",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/scope_change_defs1.json",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/scope_change_defs1.json",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/scope_change_defs2.json",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/scope_change_defs2.json",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/object",
        \\     "type": "object",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "name-defs.json#/$defs/orNull"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/object",
        \\     "type": "object",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "name-defs.json#/$defs/orNull"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/object",
        \\     "type": "object",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "name-defs.json#/$defs/orNull"
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
test "refRemote.remote-ref-with-ref-to-defs.invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/schema-remote-ref-ref-defs1.json",
        \\     "$ref": "ref-and-defs.json"
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.remote-ref-with-ref-to-defs.valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/schema-remote-ref-ref-defs1.json",
        \\     "$ref": "ref-and-defs.json"
        \\ }
    );

    const case =
        \\ {
        \\     "bar": "a"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.Location-independent-identifier-in-remote-ref.integer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/locationIndependentIdentifier.json#/$defs/refToInteger"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/locationIndependentIdentifier.json#/$defs/refToInteger"
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.retrieved-nested-refs-resolve-relative-to-their-URI-not-$id.number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/some-id",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "nested/foo-ref-string.json"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "name": {
        \\         "foo": 1
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.retrieved-nested-refs-resolve-relative-to-their-URI-not-$id.string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/some-id",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "nested/foo-ref-string.json"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "name": {
        \\         "foo": "a"
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.remote-HTTP-ref-with-different-$id.number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/different-id-ref-string.json"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.remote-HTTP-ref-with-different-$id.string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/different-id-ref-string.json"
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.remote-HTTP-ref-with-different-URN-$id.number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/urn-ref-string.json"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.remote-HTTP-ref-with-different-URN-$id.string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/urn-ref-string.json"
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.remote-HTTP-ref-with-nested-absolute-ref.number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/nested-absolute-ref-to-string.json"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "refRemote.remote-HTTP-ref-with-nested-absolute-ref.string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/nested-absolute-ref-to-string.json"
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.$ref-to-$ref-finds-detached-$anchor.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/detached-ref.json#/$defs/foo"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "refRemote.$ref-to-$ref-finds-detached-$anchor.non-number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/detached-ref.json#/$defs/foo"
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "if-then-else.ignore-if-without-then-or-else.valid-when-valid-against-lone-if" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "const": 0
        \\     }
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.ignore-if-without-then-or-else.valid-when-invalid-against-lone-if" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "const": 0
        \\     }
        \\ }
    );

    const case =
        \\ "hello"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.ignore-then-without-if.valid-when-valid-against-lone-then" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "then": {
        \\         "const": 0
        \\     }
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.ignore-then-without-if.valid-when-invalid-against-lone-then" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "then": {
        \\         "const": 0
        \\     }
        \\ }
    );

    const case =
        \\ "hello"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.ignore-else-without-if.valid-when-valid-against-lone-else" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "else": {
        \\         "const": 0
        \\     }
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.ignore-else-without-if.valid-when-invalid-against-lone-else" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "else": {
        \\         "const": 0
        \\     }
        \\ }
    );

    const case =
        \\ "hello"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.if-and-then-without-else.valid-through-then" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "then": {
        \\         "minimum": -10
        \\     }
        \\ }
    );

    const case =
        \\ -1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.if-and-then-without-else.invalid-through-then" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "then": {
        \\         "minimum": -10
        \\     }
        \\ }
    );

    const case =
        \\ -100
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "if-then-else.if-and-then-without-else.valid-when-if-test-fails" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "then": {
        \\         "minimum": -10
        \\     }
        \\ }
    );

    const case =
        \\ 3
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.if-and-else-without-then.valid-when-if-test-passes" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "else": {
        \\         "multipleOf": 2
        \\     }
        \\ }
    );

    const case =
        \\ -1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.if-and-else-without-then.valid-through-else" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "else": {
        \\         "multipleOf": 2
        \\     }
        \\ }
    );

    const case =
        \\ 4
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.if-and-else-without-then.invalid-through-else" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "exclusiveMaximum": 0
        \\     },
        \\     "else": {
        \\         "multipleOf": 2
        \\     }
        \\ }
    );

    const case =
        \\ 3
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "if-then-else.validate-against-correct-branch,-then-vs-else.valid-through-then" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ -1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.validate-against-correct-branch,-then-vs-else.invalid-through-then" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ -100
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "if-then-else.validate-against-correct-branch,-then-vs-else.valid-through-else" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ 4
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.validate-against-correct-branch,-then-vs-else.invalid-through-else" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ 3
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "if-then-else.non-interference-across-combined-schemas.valid,-but-would-have-been-invalid-through-then" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ -100
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.non-interference-across-combined-schemas.valid,-but-would-have-been-invalid-through-else" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ 3
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.if-with-boolean-schema-true.boolean-schema-true-in-if-always-chooses-the-then-path-(valid)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": true,
        \\     "then": {
        \\         "const": "then"
        \\     },
        \\     "else": {
        \\         "const": "else"
        \\     }
        \\ }
    );

    const case =
        \\ "then"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.if-with-boolean-schema-true.boolean-schema-true-in-if-always-chooses-the-then-path-(invalid)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": true,
        \\     "then": {
        \\         "const": "then"
        \\     },
        \\     "else": {
        \\         "const": "else"
        \\     }
        \\ }
    );

    const case =
        \\ "else"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "if-then-else.if-with-boolean-schema-false.boolean-schema-false-in-if-always-chooses-the-else-path-(invalid)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": false,
        \\     "then": {
        \\         "const": "then"
        \\     },
        \\     "else": {
        \\         "const": "else"
        \\     }
        \\ }
    );

    const case =
        \\ "then"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "if-then-else.if-with-boolean-schema-false.boolean-schema-false-in-if-always-chooses-the-else-path-(valid)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": false,
        \\     "then": {
        \\         "const": "then"
        \\     },
        \\     "else": {
        \\         "const": "else"
        \\     }
        \\ }
    );

    const case =
        \\ "else"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.if-appears-at-the-end-when-serialized-(keyword-processing-sequence).yes-redirects-to-then-and-passes" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "yes"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.if-appears-at-the-end-when-serialized-(keyword-processing-sequence).other-redirects-to-else-and-passes" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "other"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "if-then-else.if-appears-at-the-end-when-serialized-(keyword-processing-sequence).no-redirects-to-then-and-fails" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "no"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "if-then-else.if-appears-at-the-end-when-serialized-(keyword-processing-sequence).invalid-redirects-to-else-and-fails" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "invalid"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "infinite-loop-detection.evaluating-the-same-schema-location-against-the-same-data-location-twice-is-not-a-sign-of-an-infinite-loop.passing-case" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "a string"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependentRequired.single-dependency.neither" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
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
test "dependentRequired.single-dependency.nondependant" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
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
test "dependentRequired.single-dependency.with-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
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
test "dependentRequired.single-dependency.missing-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
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
test "dependentRequired.single-dependency.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
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
test "dependentRequired.single-dependency.ignores-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
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
test "dependentRequired.single-dependency.ignores-other-non-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
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
test "dependentRequired.empty-dependents.empty-object" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
        \\         "bar": []
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependentRequired.empty-dependents.object-with-one-property" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
        \\         "bar": []
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependentRequired.empty-dependents.non-object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
        \\         "bar": []
        \\     }
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependentRequired.multiple-dependents-required.neither" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
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
test "dependentRequired.multiple-dependents-required.nondependants" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
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
test "dependentRequired.multiple-dependents-required.with-dependencies" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
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
test "dependentRequired.multiple-dependents-required.missing-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
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
test "dependentRequired.multiple-dependents-required.missing-other-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
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
test "dependentRequired.multiple-dependents-required.missing-both-dependencies" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
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
test "dependentRequired.dependencies-with-escaped-characters.CRLF" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
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
test "dependentRequired.dependencies-with-escaped-characters.quoted-quotes" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
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
test "dependentRequired.dependencies-with-escaped-characters.CRLF-missing-dependent" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
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
test "dependentRequired.dependencies-with-escaped-characters.quoted-quotes-missing-dependent" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentRequired": {
        \\         "foo\nbar": [
        \\             "foo\rbar"
        \\         ],
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
test "vocabulary.schema-that-uses-custom-metaschema-with-with-no-validation-vocabulary.applicator-vocabulary-still-works" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$id": "https://schema/using/no/validation",
        \\     "$schema": "http://localhost:1234/draft2020-12/metaschema-no-validation.json",
        \\     "properties": {
        \\         "badProperty": false,
        \\         "numberProperty": {
        \\             "minimum": 10
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "badProperty": "this property should not exist"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "vocabulary.schema-that-uses-custom-metaschema-with-with-no-validation-vocabulary.no-validation:-valid-number" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$id": "https://schema/using/no/validation",
        \\     "$schema": "http://localhost:1234/draft2020-12/metaschema-no-validation.json",
        \\     "properties": {
        \\         "badProperty": false,
        \\         "numberProperty": {
        \\             "minimum": 10
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "numberProperty": 20
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "vocabulary.schema-that-uses-custom-metaschema-with-with-no-validation-vocabulary.no-validation:-invalid-number,-but-it-still-validates" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$id": "https://schema/using/no/validation",
        \\     "$schema": "http://localhost:1234/draft2020-12/metaschema-no-validation.json",
        \\     "properties": {
        \\         "badProperty": false,
        \\         "numberProperty": {
        \\             "minimum": 10
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "numberProperty": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "vocabulary.ignore-unrecognized-optional-vocabulary.string-value" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "http://localhost:1234/draft2020-12/metaschema-optional-vocabulary.json",
        \\     "type": "number"
        \\ }
    );

    const case =
        \\ "foobar"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "vocabulary.ignore-unrecognized-optional-vocabulary.number-value" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "http://localhost:1234/draft2020-12/metaschema-optional-vocabulary.json",
        \\     "type": "number"
        \\ }
    );

    const case =
        \\ 20
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.root-pointer-ref.match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/prefixItems/0"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "integer"
        \\         },
        \\         {
        \\             "$ref": "#/prefixItems/0"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ 5
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.nested-refs.nested-ref-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.ref-applies-alongside-sibling-keywords.ref-valid,-maxItems-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": []
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.ref-applies-alongside-sibling-keywords.ref-valid,-maxItems-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.ref-applies-alongside-sibling-keywords.ref-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "string"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.remote-ref,-containing-refs-itself.remote-ref-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "https://json-schema.org/draft/2020-12/schema"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "https://json-schema.org/draft/2020-12/schema"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "$ref": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.$ref-to-boolean-schema-true.any-value-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "#/$defs/bool",
        \\     "$defs": {
        \\         "bool": true
        \\     }
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.$ref-to-boolean-schema-false.any-value-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "#/$defs/bool",
        \\     "$defs": {
        \\         "bool": false
        \\     }
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.Recursive-references-between-schemas.valid-tree" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/tree",
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
        \\             "$id": "http://localhost:1234/draft2020-12/node",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/tree",
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
        \\             "$id": "http://localhost:1234/draft2020-12/node",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo\"bar": "1"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.ref-creates-new-scope-when-adjacent-to-keywords.referenced-subschema-doesn't-see-annotations-from-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "prop1": "match"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.naive-replacement-of-$ref-with-its-destination-is-not-correct.do-not-evaluate-the-$ref-inside-the-enum,-matching-any-string" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "this is a string"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.naive-replacement-of-$ref-with-its-destination-is-not-correct.do-not-evaluate-the-$ref-inside-the-enum,-definition-exact-match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "type": "string"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.naive-replacement-of-$ref-with-its-destination-is-not-correct.match-the-enum-exactly" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "$ref": "#/$defs/a_string"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.refs-with-relative-uris-and-defs.invalid-on-inner-field" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": {
        \\         "bar": 1
        \\     },
        \\     "bar": "a"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.refs-with-relative-uris-and-defs.invalid-on-outer-field" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": {
        \\         "bar": "a"
        \\     },
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.refs-with-relative-uris-and-defs.valid-on-both-fields" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": {
        \\         "bar": "a"
        \\     },
        \\     "bar": "a"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.relative-refs-with-absolute-uris-and-defs.invalid-on-inner-field" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": {
        \\         "bar": 1
        \\     },
        \\     "bar": "a"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.relative-refs-with-absolute-uris-and-defs.invalid-on-outer-field" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": {
        \\         "bar": "a"
        \\     },
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.relative-refs-with-absolute-uris-and-defs.valid-on-both-fields" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": {
        \\         "bar": "a"
        \\     },
        \\     "bar": "a"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.$id-must-be-resolved-against-nearest-parent,-not-just-immediate-parent.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.$id-must-be-resolved-against-nearest-parent,-not-just-immediate-parent.non-number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.order-of-evaluation:-$id-and-$ref.data-is-valid-against-first-definition" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "$id must be evaluated before $ref to get the proper $ref destination",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://example.com/draft2020-12/ref-and-id1/base.json",
        \\     "$ref": "int.json",
        \\     "$defs": {
        \\         "bigint": {
        \\             "$comment": "canonical uri: https://example.com/ref-and-id1/int.json",
        \\             "$id": "int.json",
        \\             "maximum": 10
        \\         },
        \\         "smallint": {
        \\             "$comment": "canonical uri: https://example.com/ref-and-id1-int.json",
        \\             "$id": "/draft2020-12/ref-and-id1-int.json",
        \\             "maximum": 2
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ 5
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.order-of-evaluation:-$id-and-$ref.data-is-invalid-against-first-definition" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "$id must be evaluated before $ref to get the proper $ref destination",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://example.com/draft2020-12/ref-and-id1/base.json",
        \\     "$ref": "int.json",
        \\     "$defs": {
        \\         "bigint": {
        \\             "$comment": "canonical uri: https://example.com/ref-and-id1/int.json",
        \\             "$id": "int.json",
        \\             "maximum": 10
        \\         },
        \\         "smallint": {
        \\             "$comment": "canonical uri: https://example.com/ref-and-id1-int.json",
        \\             "$id": "/draft2020-12/ref-and-id1-int.json",
        \\             "maximum": 2
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ 50
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.order-of-evaluation:-$id-and-$anchor-and-$ref.data-is-valid-against-first-definition" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "$id must be evaluated before $ref to get the proper $ref destination",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://example.com/draft2020-12/ref-and-id2/base.json",
        \\     "$ref": "#bigint",
        \\     "$defs": {
        \\         "bigint": {
        \\             "$comment": "canonical uri: /ref-and-id2/base.json#/$defs/bigint; another valid uri for this location: /ref-and-id2/base.json#bigint",
        \\             "$anchor": "bigint",
        \\             "maximum": 10
        \\         },
        \\         "smallint": {
        \\             "$comment": "canonical uri: https://example.com/ref-and-id2#/$defs/smallint; another valid uri for this location: https://example.com/ref-and-id2/#bigint",
        \\             "$id": "https://example.com/draft2020-12/ref-and-id2/",
        \\             "$anchor": "bigint",
        \\             "maximum": 2
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ 5
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.order-of-evaluation:-$id-and-$anchor-and-$ref.data-is-invalid-against-first-definition" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "$id must be evaluated before $ref to get the proper $ref destination",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://example.com/draft2020-12/ref-and-id2/base.json",
        \\     "$ref": "#bigint",
        \\     "$defs": {
        \\         "bigint": {
        \\             "$comment": "canonical uri: /ref-and-id2/base.json#/$defs/bigint; another valid uri for this location: /ref-and-id2/base.json#bigint",
        \\             "$anchor": "bigint",
        \\             "maximum": 10
        \\         },
        \\         "smallint": {
        \\             "$comment": "canonical uri: https://example.com/ref-and-id2#/$defs/smallint; another valid uri for this location: https://example.com/ref-and-id2/#bigint",
        \\             "$id": "https://example.com/draft2020-12/ref-and-id2/",
        \\             "$anchor": "bigint",
        \\             "maximum": 2
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ 50
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.simple-URN-base-URI-with-$ref-via-the-URN.valid-under-the-URN-IDed-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "URIs do not have to have HTTP(s) schemes",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed",
        \\     "minimum": 30,
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 37
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.simple-URN-base-URI-with-$ref-via-the-URN.invalid-under-the-URN-IDed-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "URIs do not have to have HTTP(s) schemes",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed",
        \\     "minimum": 30,
        \\     "properties": {
        \\         "foo": {
        \\             "$ref": "urn:uuid:deadbeef-1234-ffff-ffff-4321feebdaed"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 12
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.simple-URN-base-URI-with-JSON-pointer.a-string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "URIs do not have to have HTTP(s) schemes",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.simple-URN-base-URI-with-JSON-pointer.a-non-string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "URIs do not have to have HTTP(s) schemes",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 12
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.URN-base-URI-with-NSS.a-string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "RFC 8141 §2.2",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.URN-base-URI-with-NSS.a-non-string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "RFC 8141 §2.2",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 12
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.URN-base-URI-with-r-component.a-string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "RFC 8141 §2.3.1",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.URN-base-URI-with-r-component.a-non-string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "RFC 8141 §2.3.1",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 12
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.URN-base-URI-with-q-component.a-string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "RFC 8141 §2.3.2",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.URN-base-URI-with-q-component.a-non-string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$comment": "RFC 8141 §2.3.2",
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 12
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.URN-base-URI-with-URN-and-JSON-pointer-ref.a-string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.URN-base-URI-with-URN-and-JSON-pointer-ref.a-non-string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 12
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.URN-base-URI-with-URN-and-anchor-ref.a-string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.URN-base-URI-with-URN-and-anchor-ref.a-non-string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 12
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.URN-ref-with-nested-pointer-ref.a-string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "bar"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.URN-ref-with-nested-pointer-ref.a-non-string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.ref-to-if.a-non-integer-is-invalid-due-to-the-$ref" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://example.com/ref/if",
        \\     "if": {
        \\         "$id": "http://example.com/ref/if",
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.ref-to-if.an-integer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://example.com/ref/if",
        \\     "if": {
        \\         "$id": "http://example.com/ref/if",
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.ref-to-then.a-non-integer-is-invalid-due-to-the-$ref" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://example.com/ref/then",
        \\     "then": {
        \\         "$id": "http://example.com/ref/then",
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.ref-to-then.an-integer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://example.com/ref/then",
        \\     "then": {
        \\         "$id": "http://example.com/ref/then",
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.ref-to-else.a-non-integer-is-invalid-due-to-the-$ref" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://example.com/ref/else",
        \\     "else": {
        \\         "$id": "http://example.com/ref/else",
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.ref-to-else.an-integer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://example.com/ref/else",
        \\     "else": {
        \\         "$id": "http://example.com/ref/else",
        \\         "type": "integer"
        \\     }
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.ref-with-absolute-path-reference.a-string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.ref-with-absolute-path-reference.an-integer-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.$id-with-file-URI-still-resolves-pointers---*nix.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "file:///folder/file.json",
        \\     "$defs": {
        \\         "foo": {
        \\             "type": "number"
        \\         }
        \\     },
        \\     "$ref": "#/$defs/foo"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.$id-with-file-URI-still-resolves-pointers---*nix.non-number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "file:///folder/file.json",
        \\     "$defs": {
        \\         "foo": {
        \\             "type": "number"
        \\         }
        \\     },
        \\     "$ref": "#/$defs/foo"
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "ref.$id-with-file-URI-still-resolves-pointers---windows.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "file:///c:/folder/file.json",
        \\     "$defs": {
        \\         "foo": {
        \\             "type": "number"
        \\         }
        \\     },
        \\     "$ref": "#/$defs/foo"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.$id-with-file-URI-still-resolves-pointers---windows.non-number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "file:///c:/folder/file.json",
        \\     "$defs": {
        \\         "foo": {
        \\             "type": "number"
        \\         }
        \\     },
        \\     "$ref": "#/$defs/foo"
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "ref.empty-tokens-in-$ref-json-pointer.non-number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "contains.contains-keyword-validation.array-with-item-matching-schema-(5)-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "minimum": 5
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     3,
        \\     4,
        \\     5
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "contains.contains-keyword-validation.array-with-item-matching-schema-(6)-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "minimum": 5
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     3,
        \\     4,
        \\     6
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "contains.contains-keyword-validation.array-with-two-items-matching-schema-(5,-6)-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "minimum": 5
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     3,
        \\     4,
        \\     5,
        \\     6
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "contains.contains-keyword-validation.array-without-items-matching-schema-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "minimum": 5
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     2,
        \\     3,
        \\     4
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "contains.contains-keyword-validation.empty-array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "minimum": 5
        \\     }
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "contains.contains-keyword-validation.not-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "minimum": 5
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "contains.contains-keyword-with-const-keyword.array-with-item-5-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 5
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     3,
        \\     4,
        \\     5
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "contains.contains-keyword-with-const-keyword.array-with-two-items-5-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 5
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     3,
        \\     4,
        \\     5,
        \\     5
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "contains.contains-keyword-with-const-keyword.array-without-item-5-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 5
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
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "contains.contains-keyword-with-boolean-schema-true.any-non-empty-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": true
        \\ }
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "contains.contains-keyword-with-boolean-schema-true.empty-array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": true
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "contains.contains-keyword-with-boolean-schema-false.any-non-empty-array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "contains.contains-keyword-with-boolean-schema-false.empty-array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": false
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "contains.contains-keyword-with-boolean-schema-false.non-arrays-are-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": false
        \\ }
    );

    const case =
        \\ "contains does not apply to strings"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "contains.items-+-contains.matches-items,-does-not-match-contains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "items": {
        \\         "multipleOf": 2
        \\     },
        \\     "contains": {
        \\         "multipleOf": 3
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     2,
        \\     4,
        \\     8
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "contains.items-+-contains.does-not-match-items,-matches-contains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "items": {
        \\         "multipleOf": 2
        \\     },
        \\     "contains": {
        \\         "multipleOf": 3
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     3,
        \\     6,
        \\     9
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "contains.items-+-contains.matches-both-items-and-contains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "items": {
        \\         "multipleOf": 2
        \\     },
        \\     "contains": {
        \\         "multipleOf": 3
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     6,
        \\     12
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "contains.items-+-contains.matches-neither-items-nor-contains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "items": {
        \\         "multipleOf": 2
        \\     },
        \\     "contains": {
        \\         "multipleOf": 3
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     5
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "contains.contains-with-false-if-subschema.any-non-empty-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "if": false,
        \\         "else": true
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "contains.contains-with-false-if-subschema.empty-array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "if": false,
        \\         "else": true
        \\     }
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "contains.contains-with-null-instance-elements.allows-null-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
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
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.no-additional-properties-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "additionalProperties.additionalProperties-with-propertyNames.Valid-against-both-keywords" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "maxLength": 5
        \\     },
        \\     "additionalProperties": {
        \\         "type": "number"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "apple": 4
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "additionalProperties.additionalProperties-with-propertyNames.Valid-against-propertyNames,-but-not-additionalProperties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "maxLength": 5
        \\     },
        \\     "additionalProperties": {
        \\         "type": "number"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "fig": 2,
        \\     "pear": "available"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "additionalProperties.dependentSchemas-with-additionalProperties.additionalProperties-doesn't-consider-dependentSchemas" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": ""
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "additionalProperties.dependentSchemas-with-additionalProperties.additionalProperties-can't-see-bar" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "bar": ""
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "additionalProperties.dependentSchemas-with-additionalProperties.additionalProperties-can't-see-bar-even-when-foo2-is-present" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo2": "",
        \\     "bar": ""
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "format.email-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "email"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.email-format.invalid-email-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "email"
        \\ }
    );

    const case =
        \\ "2962"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-email-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-email"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-email-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-email"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-email-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-email"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-email-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-email"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-email-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-email"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-email-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-email"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-email-format.invalid-idn-email-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-email"
        \\ }
    );

    const case =
        \\ "2962"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.regex-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "regex"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.regex-format.invalid-regex-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "regex"
        \\ }
    );

    const case =
        \\ "^(abc]"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv4-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "ipv4"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv4-format.invalid-ipv4-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "ipv4"
        \\ }
    );

    const case =
        \\ "127.0.0.0.1"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv6-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "ipv6"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.ipv6-format.invalid-ipv6-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "ipv6"
        \\ }
    );

    const case =
        \\ "12345::"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-hostname-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-hostname"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-hostname-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-hostname"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-hostname-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-hostname"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-hostname-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-hostname"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-hostname-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-hostname"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-hostname-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-hostname"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.idn-hostname-format.invalid-idn-hostname-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "idn-hostname"
        \\ }
    );

    const case =
        \\ "〮실례.테스트"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.hostname-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "hostname"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.hostname-format.invalid-hostname-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "hostname"
        \\ }
    );

    const case =
        \\ "-a-host-name-that-starts-with--"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "date"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-format.invalid-date-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "date"
        \\ }
    );

    const case =
        \\ "06/19/1963"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-time-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "date-time"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.date-time-format.invalid-date-time-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "date-time"
        \\ }
    );

    const case =
        \\ "1990-02-31T15:59:60.123-08:00"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.time-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "time"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.time-format.invalid-time-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "time"
        \\ }
    );

    const case =
        \\ "08:30:06 PST"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.json-pointer-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "json-pointer"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.json-pointer-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "json-pointer"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.json-pointer-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "json-pointer"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.json-pointer-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "json-pointer"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.json-pointer-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "json-pointer"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.json-pointer-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "json-pointer"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.json-pointer-format.invalid-json-pointer-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "json-pointer"
        \\ }
    );

    const case =
        \\ "/foo/bar~"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.relative-json-pointer-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "relative-json-pointer"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.relative-json-pointer-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "relative-json-pointer"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.relative-json-pointer-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "relative-json-pointer"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.relative-json-pointer-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "relative-json-pointer"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.relative-json-pointer-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "relative-json-pointer"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.relative-json-pointer-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "relative-json-pointer"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.relative-json-pointer-format.invalid-relative-json-pointer-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "relative-json-pointer"
        \\ }
    );

    const case =
        \\ "/foo/bar"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-format.invalid-iri-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri"
        \\ }
    );

    const case =
        \\ "http://2001:0db8:85a3:0000:0000:8a2e:0370:7334"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-reference-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri-reference"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-reference-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri-reference"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-reference-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri-reference"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-reference-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri-reference"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-reference-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri-reference"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-reference-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri-reference"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.iri-reference-format.invalid-iri-reference-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "iri-reference"
        \\ }
    );

    const case =
        \\ "\\\\WINDOWS\\filëßåré"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-format.invalid-uri-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri"
        \\ }
    );

    const case =
        \\ "//foo.bar/?baz=qux#quux"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-reference-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-reference"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-reference-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-reference"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-reference-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-reference"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-reference-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-reference"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-reference-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-reference"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-reference-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-reference"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-reference-format.invalid-uri-reference-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-reference"
        \\ }
    );

    const case =
        \\ "\\\\WINDOWS\\fileshare"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-template-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-template"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-template-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-template"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-template-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-template"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-template-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-template"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-template-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-template"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-template-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-template"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uri-template-format.invalid-uri-template-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uri-template"
        \\ }
    );

    const case =
        \\ "http://example.com/dictionary/{term:1}/{term"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uuid-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uuid"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uuid-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uuid"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uuid-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uuid"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uuid-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uuid"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uuid-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uuid"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uuid-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uuid"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.uuid-format.invalid-uuid-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "uuid"
        \\ }
    );

    const case =
        \\ "2eb8aa08-aa98-11ea-b4aa-73b441d1638"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.duration-format.all-string-formats-ignore-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "duration"
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.duration-format.all-string-formats-ignore-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "duration"
        \\ }
    );

    const case =
        \\ 13.7
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.duration-format.all-string-formats-ignore-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "duration"
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.duration-format.all-string-formats-ignore-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "duration"
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.duration-format.all-string-formats-ignore-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "duration"
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.duration-format.all-string-formats-ignore-nulls" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "duration"
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "format.duration-format.invalid-duration-string-is-only-an-annotation-by-default" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "format": "duration"
        \\ }
    );

    const case =
        \\ "PT1D"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.not.allowed" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": {}
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-boolean-schema-true.number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": true
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-boolean-schema-true.string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": true
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-boolean-schema-true.boolean-true-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": true
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-boolean-schema-true.boolean-false-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": true
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-boolean-schema-true.null-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": true
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-boolean-schema-true.object-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": true
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-boolean-schema-true.empty-object-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": true
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-boolean-schema-true.array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": true
        \\ }
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.forbid-everything-with-boolean-schema-true.empty-array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": true
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "not.allow-everything-with-boolean-schema-false.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": false
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.allow-everything-with-boolean-schema-false.string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": false
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.allow-everything-with-boolean-schema-false.boolean-true-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": false
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.allow-everything-with-boolean-schema-false.boolean-false-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": false
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.allow-everything-with-boolean-schema-false.null-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": false
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.allow-everything-with-boolean-schema-false.object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.allow-everything-with-boolean-schema-false.empty-object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": false
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.allow-everything-with-boolean-schema-false.array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": false
        \\ }
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.allow-everything-with-boolean-schema-false.empty-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "not": false
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.double-negation.any-value-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "not.collect-annotations-inside-a-'not',-even-if-collection-is-disabled.unevaluated-property" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "not.collect-annotations-inside-a-'not',-even-if-collection-is-disabled.annotations-are-still-collected-inside-a-'not'" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "maximum.maximum-validation.below-the-maximum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "maximum": 300
        \\ }
    );

    const case =
        \\ 300.5
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minItems.minItems-validation.longer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "minItems": 1
        \\ }
    );

    const case =
        \\ ""
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minItems.minItems-validation-with-a-decimal.longer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "minItems.minItems-validation-with-a-decimal.too-short-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "minItems": 1
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minLength.minLength-validation.longer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "minLength": 2
        \\ }
    );

    const case =
        \\ "💩"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minLength.minLength-validation-with-a-decimal.longer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "minLength": 2
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minLength.minLength-validation-with-a-decimal.too-short-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "minLength": 2
        \\ }
    );

    const case =
        \\ "f"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.a-single-valid-match-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.ignores-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.ignores-other-non-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "patternProperties.patternProperties-with-boolean-schemas.object-with-property-matching-schema-true-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "patternProperties": {
        \\         "f.*": true,
        \\         "b.*": false
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
test "patternProperties.patternProperties-with-boolean-schemas.object-with-property-matching-schema-false-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "patternProperties": {
        \\         "f.*": true,
        \\         "b.*": false
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
test "patternProperties.patternProperties-with-boolean-schemas.object-with-both-properties-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "patternProperties": {
        \\         "f.*": true,
        \\         "b.*": false
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
test "patternProperties.patternProperties-with-boolean-schemas.object-with-a-property-matching-both-true-and-false-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "patternProperties": {
        \\         "f.*": true,
        \\         "b.*": false
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foobar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "patternProperties.patternProperties-with-boolean-schemas.empty-object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "patternProperties": {
        \\         "f.*": true,
        \\         "b.*": false
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "patternProperties.patternProperties-with-null-valued-instance-properties.allows-null-values" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "dependentSchemas.single-dependency.valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependentSchemas.single-dependency.no-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "quux"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependentSchemas.single-dependency.wrong-type" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "quux",
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependentSchemas.single-dependency.wrong-type-other" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 2,
        \\     "bar": "quux"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependentSchemas.single-dependency.wrong-type-both" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "quux",
        \\     "bar": "quux"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependentSchemas.single-dependency.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ [
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependentSchemas.single-dependency.ignores-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "foobar"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependentSchemas.single-dependency.ignores-other-non-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependentSchemas.boolean-subschemas.object-with-property-having-schema-true-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentSchemas": {
        \\         "foo": true,
        \\         "bar": false
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
test "dependentSchemas.boolean-subschemas.object-with-property-having-schema-false-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentSchemas": {
        \\         "foo": true,
        \\         "bar": false
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
test "dependentSchemas.boolean-subschemas.object-with-both-properties-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentSchemas": {
        \\         "foo": true,
        \\         "bar": false
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
test "dependentSchemas.boolean-subschemas.empty-object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "dependentSchemas": {
        \\         "foo": true,
        \\         "bar": false
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependentSchemas.dependencies-with-escaped-characters.quoted-tab" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "dependentSchemas.dependencies-with-escaped-characters.quoted-quote" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo'bar": {
        \\         "foo\"bar": 1
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependentSchemas.dependencies-with-escaped-characters.quoted-tab-invalid-under-dependent-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo\tbar": 1,
        \\     "a": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependentSchemas.dependencies-with-escaped-characters.quoted-quote-invalid-under-dependent-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo'bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependentSchemas.dependent-subschema-incompatible-with-root.matches-root" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependentSchemas.dependent-subschema-incompatible-with-root.matches-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dependentSchemas.dependent-subschema-incompatible-with-root.matches-both" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dependentSchemas.dependent-subschema-incompatible-with-root.no-dependency" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "baz": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "boolean_schema.boolean-schema-'true'.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ true
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "boolean_schema.boolean-schema-'true'.string-is-valid" {
    const schema = try JSONSchema.parse(
        \\ true
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "boolean_schema.boolean-schema-'true'.boolean-true-is-valid" {
    const schema = try JSONSchema.parse(
        \\ true
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "boolean_schema.boolean-schema-'true'.boolean-false-is-valid" {
    const schema = try JSONSchema.parse(
        \\ true
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "boolean_schema.boolean-schema-'true'.null-is-valid" {
    const schema = try JSONSchema.parse(
        \\ true
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "boolean_schema.boolean-schema-'true'.object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ true
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "boolean_schema.boolean-schema-'true'.empty-object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ true
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "boolean_schema.boolean-schema-'true'.array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ true
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "boolean_schema.boolean-schema-'true'.empty-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ true
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "boolean_schema.boolean-schema-'false'.number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ false
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "boolean_schema.boolean-schema-'false'.string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ false
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "boolean_schema.boolean-schema-'false'.boolean-true-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ false
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "boolean_schema.boolean-schema-'false'.boolean-false-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ false
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "boolean_schema.boolean-schema-'false'.null-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ false
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "boolean_schema.boolean-schema-'false'.object-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ false
    );

    const case =
        \\ {
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "boolean_schema.boolean-schema-'false'.empty-object-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ false
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "boolean_schema.boolean-schema-'false'.array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ false
    );

    const case =
        \\ [
        \\     "foo"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "boolean_schema.boolean-schema-'false'.empty-array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ false
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minimum.minimum-validation.above-the-minimum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "minimum": 1.1
        \\ }
    );

    const case =
        \\ "x"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minimum.minimum-validation-with-signed-integer.negative-above-the-minimum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "minimum": -2
        \\ }
    );

    const case =
        \\ "x"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.A-$dynamicRef-to-a-$dynamicAnchor-in-the-same-schema-resource-behaves-like-a-normal-$ref-to-an-$anchor.An-array-of-strings-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamicRef-dynamicAnchor-same-schema/root",
        \\     "type": "array",
        \\     "items": {
        \\         "$dynamicRef": "#items"
        \\     },
        \\     "$defs": {
        \\         "foo": {
        \\             "$dynamicAnchor": "items",
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.A-$dynamicRef-to-a-$dynamicAnchor-in-the-same-schema-resource-behaves-like-a-normal-$ref-to-an-$anchor.An-array-containing-non-strings-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamicRef-dynamicAnchor-same-schema/root",
        \\     "type": "array",
        \\     "items": {
        \\         "$dynamicRef": "#items"
        \\     },
        \\     "$defs": {
        \\         "foo": {
        \\             "$dynamicAnchor": "items",
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.A-$dynamicRef-to-an-$anchor-in-the-same-schema-resource-behaves-like-a-normal-$ref-to-an-$anchor.An-array-of-strings-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamicRef-anchor-same-schema/root",
        \\     "type": "array",
        \\     "items": {
        \\         "$dynamicRef": "#items"
        \\     },
        \\     "$defs": {
        \\         "foo": {
        \\             "$anchor": "items",
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.A-$dynamicRef-to-an-$anchor-in-the-same-schema-resource-behaves-like-a-normal-$ref-to-an-$anchor.An-array-containing-non-strings-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamicRef-anchor-same-schema/root",
        \\     "type": "array",
        \\     "items": {
        \\         "$dynamicRef": "#items"
        \\     },
        \\     "$defs": {
        \\         "foo": {
        \\             "$anchor": "items",
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.A-$ref-to-a-$dynamicAnchor-in-the-same-schema-resource-behaves-like-a-normal-$ref-to-an-$anchor.An-array-of-strings-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/ref-dynamicAnchor-same-schema/root",
        \\     "type": "array",
        \\     "items": {
        \\         "$ref": "#items"
        \\     },
        \\     "$defs": {
        \\         "foo": {
        \\             "$dynamicAnchor": "items",
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.A-$ref-to-a-$dynamicAnchor-in-the-same-schema-resource-behaves-like-a-normal-$ref-to-an-$anchor.An-array-containing-non-strings-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/ref-dynamicAnchor-same-schema/root",
        \\     "type": "array",
        \\     "items": {
        \\         "$ref": "#items"
        \\     },
        \\     "$defs": {
        \\         "foo": {
        \\             "$dynamicAnchor": "items",
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.A-$dynamicRef-resolves-to-the-first-$dynamicAnchor-still-in-scope-that-is-encountered-when-the-schema-is-evaluated.An-array-of-strings-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/typical-dynamic-resolution/root",
        \\     "$ref": "list",
        \\     "$defs": {
        \\         "foo": {
        \\             "$dynamicAnchor": "items",
        \\             "type": "string"
        \\         },
        \\         "list": {
        \\             "$id": "list",
        \\             "type": "array",
        \\             "items": {
        \\                 "$dynamicRef": "#items"
        \\             },
        \\             "$defs": {
        \\                 "items": {
        \\                     "$comment": "This is only needed to satisfy the bookending requirement",
        \\                     "$dynamicAnchor": "items"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.A-$dynamicRef-resolves-to-the-first-$dynamicAnchor-still-in-scope-that-is-encountered-when-the-schema-is-evaluated.An-array-containing-non-strings-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/typical-dynamic-resolution/root",
        \\     "$ref": "list",
        \\     "$defs": {
        \\         "foo": {
        \\             "$dynamicAnchor": "items",
        \\             "type": "string"
        \\         },
        \\         "list": {
        \\             "$id": "list",
        \\             "type": "array",
        \\             "items": {
        \\                 "$dynamicRef": "#items"
        \\             },
        \\             "$defs": {
        \\                 "items": {
        \\                     "$comment": "This is only needed to satisfy the bookending requirement",
        \\                     "$dynamicAnchor": "items"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.A-$dynamicRef-without-anchor-in-fragment-behaves-identical-to-$ref.An-array-of-strings-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamicRef-without-anchor/root",
        \\     "$ref": "list",
        \\     "$defs": {
        \\         "foo": {
        \\             "$dynamicAnchor": "items",
        \\             "type": "string"
        \\         },
        \\         "list": {
        \\             "$id": "list",
        \\             "type": "array",
        \\             "items": {
        \\                 "$dynamicRef": "#/$defs/items"
        \\             },
        \\             "$defs": {
        \\                 "items": {
        \\                     "$comment": "This is only needed to satisfy the bookending requirement",
        \\                     "$dynamicAnchor": "items",
        \\                     "type": "number"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.A-$dynamicRef-without-anchor-in-fragment-behaves-identical-to-$ref.An-array-of-numbers-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamicRef-without-anchor/root",
        \\     "$ref": "list",
        \\     "$defs": {
        \\         "foo": {
        \\             "$dynamicAnchor": "items",
        \\             "type": "string"
        \\         },
        \\         "list": {
        \\             "$id": "list",
        \\             "type": "array",
        \\             "items": {
        \\                 "$dynamicRef": "#/$defs/items"
        \\             },
        \\             "$defs": {
        \\                 "items": {
        \\                     "$comment": "This is only needed to satisfy the bookending requirement",
        \\                     "$dynamicAnchor": "items",
        \\                     "type": "number"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     24,
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.A-$dynamicRef-with-intermediate-scopes-that-don't-include-a-matching-$dynamicAnchor-does-not-affect-dynamic-scope-resolution.An-array-of-strings-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamic-resolution-with-intermediate-scopes/root",
        \\     "$ref": "intermediate-scope",
        \\     "$defs": {
        \\         "foo": {
        \\             "$dynamicAnchor": "items",
        \\             "type": "string"
        \\         },
        \\         "intermediate-scope": {
        \\             "$id": "intermediate-scope",
        \\             "$ref": "list"
        \\         },
        \\         "list": {
        \\             "$id": "list",
        \\             "type": "array",
        \\             "items": {
        \\                 "$dynamicRef": "#items"
        \\             },
        \\             "$defs": {
        \\                 "items": {
        \\                     "$comment": "This is only needed to satisfy the bookending requirement",
        \\                     "$dynamicAnchor": "items"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     "bar"
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.A-$dynamicRef-with-intermediate-scopes-that-don't-include-a-matching-$dynamicAnchor-does-not-affect-dynamic-scope-resolution.An-array-containing-non-strings-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamic-resolution-with-intermediate-scopes/root",
        \\     "$ref": "intermediate-scope",
        \\     "$defs": {
        \\         "foo": {
        \\             "$dynamicAnchor": "items",
        \\             "type": "string"
        \\         },
        \\         "intermediate-scope": {
        \\             "$id": "intermediate-scope",
        \\             "$ref": "list"
        \\         },
        \\         "list": {
        \\             "$id": "list",
        \\             "type": "array",
        \\             "items": {
        \\                 "$dynamicRef": "#items"
        \\             },
        \\             "$defs": {
        \\                 "items": {
        \\                     "$comment": "This is only needed to satisfy the bookending requirement",
        \\                     "$dynamicAnchor": "items"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.An-$anchor-with-the-same-name-as-a-$dynamicAnchor-is-not-used-for-dynamic-scope-resolution.Any-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamic-resolution-ignores-anchors/root",
        \\     "$ref": "list",
        \\     "$defs": {
        \\         "foo": {
        \\             "$anchor": "items",
        \\             "type": "string"
        \\         },
        \\         "list": {
        \\             "$id": "list",
        \\             "type": "array",
        \\             "items": {
        \\                 "$dynamicRef": "#items"
        \\             },
        \\             "$defs": {
        \\                 "items": {
        \\                     "$comment": "This is only needed to satisfy the bookending requirement",
        \\                     "$dynamicAnchor": "items"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.A-$dynamicRef-without-a-matching-$dynamicAnchor-in-the-same-schema-resource-behaves-like-a-normal-$ref-to-$anchor.Any-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamic-resolution-without-bookend/root",
        \\     "$ref": "list",
        \\     "$defs": {
        \\         "foo": {
        \\             "$dynamicAnchor": "items",
        \\             "type": "string"
        \\         },
        \\         "list": {
        \\             "$id": "list",
        \\             "type": "array",
        \\             "items": {
        \\                 "$dynamicRef": "#items"
        \\             },
        \\             "$defs": {
        \\                 "items": {
        \\                     "$comment": "This is only needed to give the reference somewhere to resolve to when it behaves like $ref",
        \\                     "$anchor": "items"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.A-$dynamicRef-with-a-non-matching-$dynamicAnchor-in-the-same-schema-resource-behaves-like-a-normal-$ref-to-$anchor.Any-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/unmatched-dynamic-anchor/root",
        \\     "$ref": "list",
        \\     "$defs": {
        \\         "foo": {
        \\             "$dynamicAnchor": "items",
        \\             "type": "string"
        \\         },
        \\         "list": {
        \\             "$id": "list",
        \\             "type": "array",
        \\             "items": {
        \\                 "$dynamicRef": "#items"
        \\             },
        \\             "$defs": {
        \\                 "items": {
        \\                     "$comment": "This is only needed to give the reference somewhere to resolve to when it behaves like $ref",
        \\                     "$anchor": "items",
        \\                     "$dynamicAnchor": "foo"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     "foo",
        \\     42
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.A-$dynamicRef-that-initially-resolves-to-a-schema-with-a-matching-$dynamicAnchor-resolves-to-the-first-$dynamicAnchor-in-the-dynamic-scope.The-recursive-part-is-valid-against-the-root" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/relative-dynamic-reference/root",
        \\     "$dynamicAnchor": "meta",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "const": "pass"
        \\         }
        \\     },
        \\     "$ref": "extended",
        \\     "$defs": {
        \\         "extended": {
        \\             "$id": "extended",
        \\             "$dynamicAnchor": "meta",
        \\             "type": "object",
        \\             "properties": {
        \\                 "bar": {
        \\                     "$ref": "bar"
        \\                 }
        \\             }
        \\         },
        \\         "bar": {
        \\             "$id": "bar",
        \\             "type": "object",
        \\             "properties": {
        \\                 "baz": {
        \\                     "$dynamicRef": "extended#meta"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "pass",
        \\     "bar": {
        \\         "baz": {
        \\             "foo": "pass"
        \\         }
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.A-$dynamicRef-that-initially-resolves-to-a-schema-with-a-matching-$dynamicAnchor-resolves-to-the-first-$dynamicAnchor-in-the-dynamic-scope.The-recursive-part-is-not-valid-against-the-root" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/relative-dynamic-reference/root",
        \\     "$dynamicAnchor": "meta",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "const": "pass"
        \\         }
        \\     },
        \\     "$ref": "extended",
        \\     "$defs": {
        \\         "extended": {
        \\             "$id": "extended",
        \\             "$dynamicAnchor": "meta",
        \\             "type": "object",
        \\             "properties": {
        \\                 "bar": {
        \\                     "$ref": "bar"
        \\                 }
        \\             }
        \\         },
        \\         "bar": {
        \\             "$id": "bar",
        \\             "type": "object",
        \\             "properties": {
        \\                 "baz": {
        \\                     "$dynamicRef": "extended#meta"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "pass",
        \\     "bar": {
        \\         "baz": {
        \\             "foo": "fail"
        \\         }
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.A-$dynamicRef-that-initially-resolves-to-a-schema-without-a-matching-$dynamicAnchor-behaves-like-a-normal-$ref-to-$anchor.The-recursive-part-doesn't-need-to-validate-against-the-root" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/relative-dynamic-reference-without-bookend/root",
        \\     "$dynamicAnchor": "meta",
        \\     "type": "object",
        \\     "properties": {
        \\         "foo": {
        \\             "const": "pass"
        \\         }
        \\     },
        \\     "$ref": "extended",
        \\     "$defs": {
        \\         "extended": {
        \\             "$id": "extended",
        \\             "$anchor": "meta",
        \\             "type": "object",
        \\             "properties": {
        \\                 "bar": {
        \\                     "$ref": "bar"
        \\                 }
        \\             }
        \\         },
        \\         "bar": {
        \\             "$id": "bar",
        \\             "type": "object",
        \\             "properties": {
        \\                 "baz": {
        \\                     "$dynamicRef": "extended#meta"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "pass",
        \\     "bar": {
        \\         "baz": {
        \\             "foo": "fail"
        \\         }
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.multiple-dynamic-paths-to-the-$dynamicRef-keyword.number-list-with-number-values" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamic-ref-with-multiple-paths/main",
        \\     "if": {
        \\         "properties": {
        \\             "kindOfList": {
        \\                 "const": "numbers"
        \\             }
        \\         },
        \\         "required": [
        \\             "kindOfList"
        \\         ]
        \\     },
        \\     "then": {
        \\         "$ref": "numberList"
        \\     },
        \\     "else": {
        \\         "$ref": "stringList"
        \\     },
        \\     "$defs": {
        \\         "genericList": {
        \\             "$id": "genericList",
        \\             "properties": {
        \\                 "list": {
        \\                     "items": {
        \\                         "$dynamicRef": "#itemType"
        \\                     }
        \\                 }
        \\             },
        \\             "$defs": {
        \\                 "defaultItemType": {
        \\                     "$comment": "Only needed to satisfy bookending requirement",
        \\                     "$dynamicAnchor": "itemType"
        \\                 }
        \\             }
        \\         },
        \\         "numberList": {
        \\             "$id": "numberList",
        \\             "$defs": {
        \\                 "itemType": {
        \\                     "$dynamicAnchor": "itemType",
        \\                     "type": "number"
        \\                 }
        \\             },
        \\             "$ref": "genericList"
        \\         },
        \\         "stringList": {
        \\             "$id": "stringList",
        \\             "$defs": {
        \\                 "itemType": {
        \\                     "$dynamicAnchor": "itemType",
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "$ref": "genericList"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "kindOfList": "numbers",
        \\     "list": [
        \\         1.1
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.multiple-dynamic-paths-to-the-$dynamicRef-keyword.number-list-with-string-values" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamic-ref-with-multiple-paths/main",
        \\     "if": {
        \\         "properties": {
        \\             "kindOfList": {
        \\                 "const": "numbers"
        \\             }
        \\         },
        \\         "required": [
        \\             "kindOfList"
        \\         ]
        \\     },
        \\     "then": {
        \\         "$ref": "numberList"
        \\     },
        \\     "else": {
        \\         "$ref": "stringList"
        \\     },
        \\     "$defs": {
        \\         "genericList": {
        \\             "$id": "genericList",
        \\             "properties": {
        \\                 "list": {
        \\                     "items": {
        \\                         "$dynamicRef": "#itemType"
        \\                     }
        \\                 }
        \\             },
        \\             "$defs": {
        \\                 "defaultItemType": {
        \\                     "$comment": "Only needed to satisfy bookending requirement",
        \\                     "$dynamicAnchor": "itemType"
        \\                 }
        \\             }
        \\         },
        \\         "numberList": {
        \\             "$id": "numberList",
        \\             "$defs": {
        \\                 "itemType": {
        \\                     "$dynamicAnchor": "itemType",
        \\                     "type": "number"
        \\                 }
        \\             },
        \\             "$ref": "genericList"
        \\         },
        \\         "stringList": {
        \\             "$id": "stringList",
        \\             "$defs": {
        \\                 "itemType": {
        \\                     "$dynamicAnchor": "itemType",
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "$ref": "genericList"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "kindOfList": "numbers",
        \\     "list": [
        \\         "foo"
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.multiple-dynamic-paths-to-the-$dynamicRef-keyword.string-list-with-number-values" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamic-ref-with-multiple-paths/main",
        \\     "if": {
        \\         "properties": {
        \\             "kindOfList": {
        \\                 "const": "numbers"
        \\             }
        \\         },
        \\         "required": [
        \\             "kindOfList"
        \\         ]
        \\     },
        \\     "then": {
        \\         "$ref": "numberList"
        \\     },
        \\     "else": {
        \\         "$ref": "stringList"
        \\     },
        \\     "$defs": {
        \\         "genericList": {
        \\             "$id": "genericList",
        \\             "properties": {
        \\                 "list": {
        \\                     "items": {
        \\                         "$dynamicRef": "#itemType"
        \\                     }
        \\                 }
        \\             },
        \\             "$defs": {
        \\                 "defaultItemType": {
        \\                     "$comment": "Only needed to satisfy bookending requirement",
        \\                     "$dynamicAnchor": "itemType"
        \\                 }
        \\             }
        \\         },
        \\         "numberList": {
        \\             "$id": "numberList",
        \\             "$defs": {
        \\                 "itemType": {
        \\                     "$dynamicAnchor": "itemType",
        \\                     "type": "number"
        \\                 }
        \\             },
        \\             "$ref": "genericList"
        \\         },
        \\         "stringList": {
        \\             "$id": "stringList",
        \\             "$defs": {
        \\                 "itemType": {
        \\                     "$dynamicAnchor": "itemType",
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "$ref": "genericList"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "kindOfList": "strings",
        \\     "list": [
        \\         1.1
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.multiple-dynamic-paths-to-the-$dynamicRef-keyword.string-list-with-string-values" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamic-ref-with-multiple-paths/main",
        \\     "if": {
        \\         "properties": {
        \\             "kindOfList": {
        \\                 "const": "numbers"
        \\             }
        \\         },
        \\         "required": [
        \\             "kindOfList"
        \\         ]
        \\     },
        \\     "then": {
        \\         "$ref": "numberList"
        \\     },
        \\     "else": {
        \\         "$ref": "stringList"
        \\     },
        \\     "$defs": {
        \\         "genericList": {
        \\             "$id": "genericList",
        \\             "properties": {
        \\                 "list": {
        \\                     "items": {
        \\                         "$dynamicRef": "#itemType"
        \\                     }
        \\                 }
        \\             },
        \\             "$defs": {
        \\                 "defaultItemType": {
        \\                     "$comment": "Only needed to satisfy bookending requirement",
        \\                     "$dynamicAnchor": "itemType"
        \\                 }
        \\             }
        \\         },
        \\         "numberList": {
        \\             "$id": "numberList",
        \\             "$defs": {
        \\                 "itemType": {
        \\                     "$dynamicAnchor": "itemType",
        \\                     "type": "number"
        \\                 }
        \\             },
        \\             "$ref": "genericList"
        \\         },
        \\         "stringList": {
        \\             "$id": "stringList",
        \\             "$defs": {
        \\                 "itemType": {
        \\                     "$dynamicAnchor": "itemType",
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "$ref": "genericList"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "kindOfList": "strings",
        \\     "list": [
        \\         "foo"
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.after-leaving-a-dynamic-scope,-it-is-not-used-by-a-$dynamicRef.string-matches-/$defs/thingy,-but-the-$dynamicRef-does-not-stop-here" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamic-ref-leaving-dynamic-scope/main",
        \\     "if": {
        \\         "$id": "first_scope",
        \\         "$defs": {
        \\             "thingy": {
        \\                 "$comment": "this is first_scope#thingy",
        \\                 "$dynamicAnchor": "thingy",
        \\                 "type": "number"
        \\             }
        \\         }
        \\     },
        \\     "then": {
        \\         "$id": "second_scope",
        \\         "$ref": "start",
        \\         "$defs": {
        \\             "thingy": {
        \\                 "$comment": "this is second_scope#thingy, the final destination of the $dynamicRef",
        \\                 "$dynamicAnchor": "thingy",
        \\                 "type": "null"
        \\             }
        \\         }
        \\     },
        \\     "$defs": {
        \\         "start": {
        \\             "$comment": "this is the landing spot from $ref",
        \\             "$id": "start",
        \\             "$dynamicRef": "inner_scope#thingy"
        \\         },
        \\         "thingy": {
        \\             "$comment": "this is the first stop for the $dynamicRef",
        \\             "$id": "inner_scope",
        \\             "$dynamicAnchor": "thingy",
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ "a string"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.after-leaving-a-dynamic-scope,-it-is-not-used-by-a-$dynamicRef.first_scope-is-not-in-dynamic-scope-for-the-$dynamicRef" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamic-ref-leaving-dynamic-scope/main",
        \\     "if": {
        \\         "$id": "first_scope",
        \\         "$defs": {
        \\             "thingy": {
        \\                 "$comment": "this is first_scope#thingy",
        \\                 "$dynamicAnchor": "thingy",
        \\                 "type": "number"
        \\             }
        \\         }
        \\     },
        \\     "then": {
        \\         "$id": "second_scope",
        \\         "$ref": "start",
        \\         "$defs": {
        \\             "thingy": {
        \\                 "$comment": "this is second_scope#thingy, the final destination of the $dynamicRef",
        \\                 "$dynamicAnchor": "thingy",
        \\                 "type": "null"
        \\             }
        \\         }
        \\     },
        \\     "$defs": {
        \\         "start": {
        \\             "$comment": "this is the landing spot from $ref",
        \\             "$id": "start",
        \\             "$dynamicRef": "inner_scope#thingy"
        \\         },
        \\         "thingy": {
        \\             "$comment": "this is the first stop for the $dynamicRef",
        \\             "$id": "inner_scope",
        \\             "$dynamicAnchor": "thingy",
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ 42
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.after-leaving-a-dynamic-scope,-it-is-not-used-by-a-$dynamicRef./then/$defs/thingy-is-the-final-stop-for-the-$dynamicRef" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamic-ref-leaving-dynamic-scope/main",
        \\     "if": {
        \\         "$id": "first_scope",
        \\         "$defs": {
        \\             "thingy": {
        \\                 "$comment": "this is first_scope#thingy",
        \\                 "$dynamicAnchor": "thingy",
        \\                 "type": "number"
        \\             }
        \\         }
        \\     },
        \\     "then": {
        \\         "$id": "second_scope",
        \\         "$ref": "start",
        \\         "$defs": {
        \\             "thingy": {
        \\                 "$comment": "this is second_scope#thingy, the final destination of the $dynamicRef",
        \\                 "$dynamicAnchor": "thingy",
        \\                 "type": "null"
        \\             }
        \\         }
        \\     },
        \\     "$defs": {
        \\         "start": {
        \\             "$comment": "this is the landing spot from $ref",
        \\             "$id": "start",
        \\             "$dynamicRef": "inner_scope#thingy"
        \\         },
        \\         "thingy": {
        \\             "$comment": "this is the first stop for the $dynamicRef",
        \\             "$id": "inner_scope",
        \\             "$dynamicAnchor": "thingy",
        \\             "type": "string"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.strict-tree-schema,-guards-against-misspelled-properties.instance-with-misspelled-field" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/strict-tree.json",
        \\     "$dynamicAnchor": "node",
        \\     "$ref": "tree.json",
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "children": [
        \\         {
        \\             "daat": 1
        \\         }
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.strict-tree-schema,-guards-against-misspelled-properties.instance-with-correct-field" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/strict-tree.json",
        \\     "$dynamicAnchor": "node",
        \\     "$ref": "tree.json",
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "children": [
        \\         {
        \\             "data": 1
        \\         }
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.tests-for-implementation-dynamic-anchor-and-reference-link.incorrect-parent-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/strict-extendible.json",
        \\     "$ref": "extendible-dynamic-ref.json",
        \\     "$defs": {
        \\         "elements": {
        \\             "$dynamicAnchor": "elements",
        \\             "properties": {
        \\                 "a": true
        \\             },
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "additionalProperties": false
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a": true
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.tests-for-implementation-dynamic-anchor-and-reference-link.incorrect-extended-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/strict-extendible.json",
        \\     "$ref": "extendible-dynamic-ref.json",
        \\     "$defs": {
        \\         "elements": {
        \\             "$dynamicAnchor": "elements",
        \\             "properties": {
        \\                 "a": true
        \\             },
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "additionalProperties": false
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "elements": [
        \\         {
        \\             "b": 1
        \\         }
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.tests-for-implementation-dynamic-anchor-and-reference-link.correct-extended-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/strict-extendible.json",
        \\     "$ref": "extendible-dynamic-ref.json",
        \\     "$defs": {
        \\         "elements": {
        \\             "$dynamicAnchor": "elements",
        \\             "properties": {
        \\                 "a": true
        \\             },
        \\             "required": [
        \\                 "a"
        \\             ],
        \\             "additionalProperties": false
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "elements": [
        \\         {
        \\             "a": 1
        \\         }
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.$ref-and-$dynamicAnchor-are-independent-of-order---$defs-first.incorrect-parent-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/strict-extendible-allof-defs-first.json",
        \\     "allOf": [
        \\         {
        \\             "$ref": "extendible-dynamic-ref.json"
        \\         },
        \\         {
        \\             "$defs": {
        \\                 "elements": {
        \\                     "$dynamicAnchor": "elements",
        \\                     "properties": {
        \\                         "a": true
        \\                     },
        \\                     "required": [
        \\                         "a"
        \\                     ],
        \\                     "additionalProperties": false
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "a": true
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.$ref-and-$dynamicAnchor-are-independent-of-order---$defs-first.incorrect-extended-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/strict-extendible-allof-defs-first.json",
        \\     "allOf": [
        \\         {
        \\             "$ref": "extendible-dynamic-ref.json"
        \\         },
        \\         {
        \\             "$defs": {
        \\                 "elements": {
        \\                     "$dynamicAnchor": "elements",
        \\                     "properties": {
        \\                         "a": true
        \\                     },
        \\                     "required": [
        \\                         "a"
        \\                     ],
        \\                     "additionalProperties": false
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "elements": [
        \\         {
        \\             "b": 1
        \\         }
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.$ref-and-$dynamicAnchor-are-independent-of-order---$defs-first.correct-extended-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/strict-extendible-allof-defs-first.json",
        \\     "allOf": [
        \\         {
        \\             "$ref": "extendible-dynamic-ref.json"
        \\         },
        \\         {
        \\             "$defs": {
        \\                 "elements": {
        \\                     "$dynamicAnchor": "elements",
        \\                     "properties": {
        \\                         "a": true
        \\                     },
        \\                     "required": [
        \\                         "a"
        \\                     ],
        \\                     "additionalProperties": false
        \\                 }
        \\             }
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "elements": [
        \\         {
        \\             "a": 1
        \\         }
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.$ref-and-$dynamicAnchor-are-independent-of-order---$ref-first.incorrect-parent-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/strict-extendible-allof-ref-first.json",
        \\     "allOf": [
        \\         {
        \\             "$defs": {
        \\                 "elements": {
        \\                     "$dynamicAnchor": "elements",
        \\                     "properties": {
        \\                         "a": true
        \\                     },
        \\                     "required": [
        \\                         "a"
        \\                     ],
        \\                     "additionalProperties": false
        \\                 }
        \\             }
        \\         },
        \\         {
        \\             "$ref": "extendible-dynamic-ref.json"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "a": true
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.$ref-and-$dynamicAnchor-are-independent-of-order---$ref-first.incorrect-extended-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/strict-extendible-allof-ref-first.json",
        \\     "allOf": [
        \\         {
        \\             "$defs": {
        \\                 "elements": {
        \\                     "$dynamicAnchor": "elements",
        \\                     "properties": {
        \\                         "a": true
        \\                     },
        \\                     "required": [
        \\                         "a"
        \\                     ],
        \\                     "additionalProperties": false
        \\                 }
        \\             }
        \\         },
        \\         {
        \\             "$ref": "extendible-dynamic-ref.json"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "elements": [
        \\         {
        \\             "b": 1
        \\         }
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.$ref-and-$dynamicAnchor-are-independent-of-order---$ref-first.correct-extended-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/strict-extendible-allof-ref-first.json",
        \\     "allOf": [
        \\         {
        \\             "$defs": {
        \\                 "elements": {
        \\                     "$dynamicAnchor": "elements",
        \\                     "properties": {
        \\                         "a": true
        \\                     },
        \\                     "required": [
        \\                         "a"
        \\                     ],
        \\                     "additionalProperties": false
        \\                 }
        \\             }
        \\         },
        \\         {
        \\             "$ref": "extendible-dynamic-ref.json"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ {
        \\     "elements": [
        \\         {
        \\             "a": 1
        \\         }
        \\     ]
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.$ref-to-$dynamicRef-finds-detached-$dynamicAnchor.number-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://localhost:1234/draft2020-12/detached-dynamicref.json#/$defs/foo"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.$ref-to-$dynamicRef-finds-detached-$dynamicAnchor.non-number-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$ref": "http://localhost:1234/draft2020-12/detached-dynamicref.json#/$defs/foo"
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.$dynamicRef-points-to-a-boolean-schema.follow-$dynamicRef-to-a-true-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$defs": {
        \\         "true": true,
        \\         "false": false
        \\     },
        \\     "properties": {
        \\         "true": {
        \\             "$dynamicRef": "#/$defs/true"
        \\         },
        \\         "false": {
        \\             "$dynamicRef": "#/$defs/false"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "true": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.$dynamicRef-points-to-a-boolean-schema.follow-$dynamicRef-to-a-false-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$defs": {
        \\         "true": true,
        \\         "false": false
        \\     },
        \\     "properties": {
        \\         "true": {
        \\             "$dynamicRef": "#/$defs/true"
        \\         },
        \\         "false": {
        \\             "$dynamicRef": "#/$defs/false"
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "false": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "dynamicRef.$dynamicRef-skips-over-intermediate-resources---direct-reference.integer-property-passes" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamic-ref-skips-intermediate-resource/main",
        \\     "type": "object",
        \\     "properties": {
        \\         "bar-item": {
        \\             "$ref": "item"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "$id": "bar",
        \\             "type": "array",
        \\             "items": {
        \\                 "$ref": "item"
        \\             },
        \\             "$defs": {
        \\                 "item": {
        \\                     "$id": "item",
        \\                     "type": "object",
        \\                     "properties": {
        \\                         "content": {
        \\                             "$dynamicRef": "#content"
        \\                         }
        \\                     },
        \\                     "$defs": {
        \\                         "defaultContent": {
        \\                             "$dynamicAnchor": "content",
        \\                             "type": "integer"
        \\                         }
        \\                     }
        \\                 },
        \\                 "content": {
        \\                     "$dynamicAnchor": "content",
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar-item": {
        \\         "content": 42
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "dynamicRef.$dynamicRef-skips-over-intermediate-resources---direct-reference.string-property-fails" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://test.json-schema.org/dynamic-ref-skips-intermediate-resource/main",
        \\     "type": "object",
        \\     "properties": {
        \\         "bar-item": {
        \\             "$ref": "item"
        \\         }
        \\     },
        \\     "$defs": {
        \\         "bar": {
        \\             "$id": "bar",
        \\             "type": "array",
        \\             "items": {
        \\                 "$ref": "item"
        \\             },
        \\             "$defs": {
        \\                 "item": {
        \\                     "$id": "item",
        \\                     "type": "object",
        \\                     "properties": {
        \\                         "content": {
        \\                             "$dynamicRef": "#content"
        \\                         }
        \\                     },
        \\                     "$defs": {
        \\                         "defaultContent": {
        \\                             "$dynamicAnchor": "content",
        \\                             "type": "integer"
        \\                         }
        \\                     }
        \\                 },
        \\                 "content": {
        \\                     "$dynamicAnchor": "content",
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "bar-item": {
        \\         "content": "value"
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "type.integer-type-matches-integers.an-integer-is-an-integer" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "type": "integer"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.integer-type-matches-integers.a-float-with-zero-fractional-part-is-an-integer" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "type": "number"
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "type.number-type-matches-numbers.a-float-with-zero-fractional-part-is-a-number-(and-an-integer)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "minContains.minContains-without-contains-is-ignored.one-item-valid-against-lone-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "minContains": 1
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minContains.minContains-without-contains-is-ignored.zero-items-still-valid-against-lone-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "minContains": 1
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minContains.minContains=1-with-contains.empty-data" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minContains.minContains=1-with-contains.no-elements-match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1
        \\ }
    );

    const case =
        \\ [
        \\     2
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minContains.minContains=1-with-contains.single-element-matches,-valid-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minContains.minContains=1-with-contains.some-elements-match,-valid-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1
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
test "minContains.minContains=1-with-contains.all-elements-match,-valid-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1
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
test "minContains.minContains=2-with-contains.empty-data" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minContains.minContains=2-with-contains.all-elements-match,-invalid-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minContains.minContains=2-with-contains.some-elements-match,-invalid-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minContains.minContains=2-with-contains.all-elements-match,-valid-minContains-(exactly-as-needed)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
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
test "minContains.minContains=2-with-contains.all-elements-match,-valid-minContains-(more-than-needed)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
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
test "minContains.minContains=2-with-contains.some-elements-match,-valid-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2,
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minContains.minContains=2-with-contains-with-a-decimal-value.one-element-matches,-invalid-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minContains.minContains=2-with-contains-with-a-decimal-value.both-elements-match,-valid-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 2
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
test "minContains.maxContains-=-minContains.empty-data" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 2,
        \\     "minContains": 2
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minContains.maxContains-=-minContains.all-elements-match,-invalid-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 2,
        \\     "minContains": 2
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minContains.maxContains-=-minContains.all-elements-match,-invalid-maxContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 2,
        \\     "minContains": 2
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
test "minContains.maxContains-=-minContains.all-elements-match,-valid-maxContains-and-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 2,
        \\     "minContains": 2
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
test "minContains.maxContains-<-minContains.empty-data" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1,
        \\     "minContains": 3
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minContains.maxContains-<-minContains.invalid-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1,
        \\     "minContains": 3
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "minContains.maxContains-<-minContains.invalid-maxContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1,
        \\     "minContains": 3
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
test "minContains.maxContains-<-minContains.invalid-maxContains-and-minContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1,
        \\     "minContains": 3
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
test "minContains.minContains-=-0.empty-data" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 0
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minContains.minContains-=-0.minContains-=-0-makes-contains-always-pass" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 0
        \\ }
    );

    const case =
        \\ [
        \\     2
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minContains.minContains-=-0-with-maxContains.empty-data" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 0,
        \\     "maxContains": 1
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minContains.minContains-=-0-with-maxContains.not-more-than-maxContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 0,
        \\     "maxContains": 1
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minContains.minContains-=-0-with-maxContains.too-many" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 0,
        \\     "maxContains": 1
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
test "properties.object-properties-validation.both-properties-present-and-valid-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "properties.properties-with-boolean-schema.no-property-present-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "foo": true,
        \\         "bar": false
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "properties.properties-with-boolean-schema.only-'true'-property-present-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "foo": true,
        \\         "bar": false
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
test "properties.properties-with-boolean-schema.only-'false'-property-present-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "foo": true,
        \\         "bar": false
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
test "properties.properties-with-boolean-schema.both-properties-present-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "foo": true,
        \\         "bar": false
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
test "properties.properties-with-escaped-characters.object-with-all-numbers-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "items.items-with-boolean-schema-(true).any-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "items": true
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
test "items.items-with-boolean-schema-(true).empty-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "items": true
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.items-with-boolean-schema-(false).any-non-empty-array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "items": false
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     "foo",
        \\     true
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "items.items-with-boolean-schema-(false).empty-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "items": false
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.items-and-subitems.valid-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$defs": {
        \\         "item": {
        \\             "type": "array",
        \\             "items": false,
        \\             "prefixItems": [
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
        \\     "items": false,
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$defs": {
        \\         "item": {
        \\             "type": "array",
        \\             "items": false,
        \\             "prefixItems": [
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
        \\     "items": false,
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$defs": {
        \\         "item": {
        \\             "type": "array",
        \\             "items": false,
        \\             "prefixItems": [
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
        \\     "items": false,
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$defs": {
        \\         "item": {
        \\             "type": "array",
        \\             "items": false,
        \\             "prefixItems": [
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
        \\     "items": false,
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$defs": {
        \\         "item": {
        \\             "type": "array",
        \\             "items": false,
        \\             "prefixItems": [
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
        \\     "items": false,
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$defs": {
        \\         "item": {
        \\             "type": "array",
        \\             "items": false,
        \\             "prefixItems": [
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
        \\     "items": false,
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "items.prefixItems-with-no-additional-items-allowed.empty-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "items": false
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.prefixItems-with-no-additional-items-allowed.fewer-number-of-items-present-(1)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "items": false
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.prefixItems-with-no-additional-items-allowed.fewer-number-of-items-present-(2)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "items": false
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
test "items.prefixItems-with-no-additional-items-allowed.equal-number-of-items-present" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "items": false
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
test "items.prefixItems-with-no-additional-items-allowed.additional-items-are-not-permitted" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {},
        \\         {},
        \\         {}
        \\     ],
        \\     "items": false
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
test "items.items-does-not-look-in-applicators,-valid-case.prefixItems-in-allOf-does-not-constrain-items,-invalid-case" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         {
        \\             "prefixItems": [
        \\                 {
        \\                     "minimum": 3
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "items": {
        \\         "minimum": 5
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     3,
        \\     5
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "items.items-does-not-look-in-applicators,-valid-case.prefixItems-in-allOf-does-not-constrain-items,-valid-case" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         {
        \\             "prefixItems": [
        \\                 {
        \\                     "minimum": 3
        \\                 }
        \\             ]
        \\         }
        \\     ],
        \\     "items": {
        \\         "minimum": 5
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     5,
        \\     5
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.prefixItems-validation-adjusts-the-starting-index-for-items.valid-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "items": {
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
test "items.prefixItems-validation-adjusts-the-starting-index-for-items.wrong-type-of-second-item" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "string"
        \\         }
        \\     ],
        \\     "items": {
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
test "items.items-with-heterogeneous-array.heterogeneous-invalid-instance" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {}
        \\     ],
        \\     "items": false
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
test "items.items-with-heterogeneous-array.valid-instance" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {}
        \\     ],
        \\     "items": false
        \\ }
    );

    const case =
        \\ [
        \\     null
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "items.items-with-null-instance-elements.allows-null-elements" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "oneOf.oneOf.first-oneOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "oneOf.oneOf-with-boolean-schemas,-all-true.any-value-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "oneOf": [
        \\         true,
        \\         true,
        \\         true
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "oneOf.oneOf-with-boolean-schemas,-one-true.any-value-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "oneOf": [
        \\         true,
        \\         false,
        \\         false
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "oneOf.oneOf-with-boolean-schemas,-more-than-one-true.any-value-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "oneOf": [
        \\         true,
        \\         true,
        \\         false
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "oneOf.oneOf-with-boolean-schemas,-all-false.any-value-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "oneOf": [
        \\         false,
        \\         false,
        \\         false
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "exclusiveMinimum.exclusiveMinimum-validation.above-the-exclusiveMinimum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "exclusiveMinimum": 1.1
        \\ }
    );

    const case =
        \\ 1.2
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "exclusiveMinimum.exclusiveMinimum-validation.boundary-point-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "exclusiveMinimum": 1.1
        \\ }
    );

    const case =
        \\ 1.1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "exclusiveMinimum.exclusiveMinimum-validation.below-the-exclusiveMinimum-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "exclusiveMinimum": 1.1
        \\ }
    );

    const case =
        \\ 0.6
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "exclusiveMinimum.exclusiveMinimum-validation.ignores-non-numbers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "exclusiveMinimum": 1.1
        \\ }
    );

    const case =
        \\ "x"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "multipleOf.by-int.int-by-int" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "multipleOf": 0.0001
        \\ }
    );

    const case =
        \\ 0.00751
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "multipleOf.float-division-=-inf.always-invalid,-but-naive-implementations-may-raise-an-overflow-error" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "type": "integer",
        \\     "multipleOf": 0.00000001
        \\ }
    );

    const case =
        \\ 12391239123
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "propertyNames.propertyNames-validation.all-property-names-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "maxLength": 3
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "f": {},
        \\     "foo": {}
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "propertyNames.propertyNames-validation.some-property-names-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "maxLength": 3
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": {},
        \\     "foobar": {}
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "propertyNames.propertyNames-validation.object-without-properties-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "maxLength": 3
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "propertyNames.propertyNames-validation.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "maxLength": 3
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
test "propertyNames.propertyNames-validation.ignores-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "maxLength": 3
        \\     }
        \\ }
    );

    const case =
        \\ "foobar"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "propertyNames.propertyNames-validation.ignores-other-non-objects" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "maxLength": 3
        \\     }
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "propertyNames.propertyNames-validation-with-pattern.matching-property-names-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "pattern": "^a+$"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a": {},
        \\     "aa": {},
        \\     "aaa": {}
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "propertyNames.propertyNames-validation-with-pattern.non-matching-property-name-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "pattern": "^a+$"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "aaA": {}
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "propertyNames.propertyNames-validation-with-pattern.object-without-properties-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "pattern": "^a+$"
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "propertyNames.propertyNames-with-boolean-schema-true.object-with-any-properties-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": true
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "propertyNames.propertyNames-with-boolean-schema-true.empty-object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": true
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "propertyNames.propertyNames-with-boolean-schema-false.object-with-any-properties-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "propertyNames.propertyNames-with-boolean-schema-false.empty-object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": false
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "propertyNames.propertyNames-with-const.object-with-property-foo-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "const": "foo"
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
test "propertyNames.propertyNames-with-const.object-with-any-other-property-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "const": "foo"
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
test "propertyNames.propertyNames-with-const.empty-object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "const": "foo"
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "propertyNames.propertyNames-with-enum.object-with-property-foo-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "enum": [
        \\             "foo",
        \\             "bar"
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
test "propertyNames.propertyNames-with-enum.object-with-property-foo-and-bar-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "enum": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "propertyNames.propertyNames-with-enum.object-with-any-other-property-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "enum": [
        \\             "foo",
        \\             "bar"
        \\         ]
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "baz": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "propertyNames.propertyNames-with-enum.empty-object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "enum": [
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
test "const.const-validation.same-value-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 2
        \\ }
    );

    const case =
        \\ 2
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-validation.another-value-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 2
        \\ }
    );

    const case =
        \\ 5
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-validation.another-type-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 2
        \\ }
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-object.same-object-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": {
        \\         "foo": "bar",
        \\         "baz": "bax"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "bar",
        \\     "baz": "bax"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with-object.same-object-with-different-property-order-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": {
        \\         "foo": "bar",
        \\         "baz": "bax"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "baz": "bax",
        \\     "foo": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with-object.another-object-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": {
        \\         "foo": "bar",
        \\         "baz": "bax"
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
test "const.const-with-object.another-type-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": {
        \\         "foo": "bar",
        \\         "baz": "bax"
        \\     }
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     2
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-array.same-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": [
        \\         {
        \\             "foo": "bar"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     {
        \\         "foo": "bar"
        \\     }
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with-array.another-array-item-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": [
        \\         {
        \\             "foo": "bar"
        \\         }
        \\     ]
        \\ }
    );

    const case =
        \\ [
        \\     2
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-array.array-with-additional-items-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": [
        \\         {
        \\             "foo": "bar"
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
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-null.null-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": null
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with-null.not-null-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": null
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-false-does-not-match-0.false-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": false
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with-false-does-not-match-0.integer-zero-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": false
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-false-does-not-match-0.float-zero-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": false
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-true-does-not-match-1.true-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": true
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with-true-does-not-match-1.integer-one-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": true
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-true-does-not-match-1.float-one-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": true
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-[false]-does-not-match-[0].[false]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": [
        \\         false
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
test "const.const-with-[false]-does-not-match-[0].[0]-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": [
        \\         false
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
test "const.const-with-[false]-does-not-match-[0].[0.0]-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": [
        \\         false
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
test "const.const-with-[true]-does-not-match-[1].[true]-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": [
        \\         true
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
test "const.const-with-[true]-does-not-match-[1].[1]-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": [
        \\         true
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
test "const.const-with-[true]-does-not-match-[1].[1.0]-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": [
        \\         true
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
test "const.const-with-{'a':-false}-does-not-match-{'a':-0}.{'a':-false}-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": {
        \\         "a": false
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a": false
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with-{'a':-false}-does-not-match-{'a':-0}.{'a':-0}-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": {
        \\         "a": false
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a": 0
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-{'a':-false}-does-not-match-{'a':-0}.{'a':-0.0}-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": {
        \\         "a": false
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a": 0
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-{'a':-true}-does-not-match-{'a':-1}.{'a':-true}-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": {
        \\         "a": true
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a": true
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with-{'a':-true}-does-not-match-{'a':-1}.{'a':-1}-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": {
        \\         "a": true
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-{'a':-true}-does-not-match-{'a':-1}.{'a':-1.0}-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": {
        \\         "a": true
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-0-does-not-match-other-zero-like-types.false-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 0
        \\ }
    );

    const case =
        \\ false
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-0-does-not-match-other-zero-like-types.integer-zero-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 0
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with-0-does-not-match-other-zero-like-types.float-zero-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 0
        \\ }
    );

    const case =
        \\ 0
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with-0-does-not-match-other-zero-like-types.empty-object-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 0
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-0-does-not-match-other-zero-like-types.empty-array-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 0
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-0-does-not-match-other-zero-like-types.empty-string-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 0
        \\ }
    );

    const case =
        \\ ""
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-1-does-not-match-true.true-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 1
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with-1-does-not-match-true.integer-one-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 1
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with-1-does-not-match-true.float-one-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 1
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with--2.0-matches-integer-and-float-types.integer--2-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": -2
        \\ }
    );

    const case =
        \\ -2
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with--2.0-matches-integer-and-float-types.integer-2-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": -2
        \\ }
    );

    const case =
        \\ 2
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with--2.0-matches-integer-and-float-types.float--2.0-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": -2
        \\ }
    );

    const case =
        \\ -2
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.const-with--2.0-matches-integer-and-float-types.float-2.0-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": -2
        \\ }
    );

    const case =
        \\ 2
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.const-with--2.0-matches-integer-and-float-types.float--2.00001-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": -2
        \\ }
    );

    const case =
        \\ -2.00001
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.float-and-integers-are-equal-up-to-64-bit-representation-limits.integer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 9007199254740992
        \\ }
    );

    const case =
        \\ 9007199254740992
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.float-and-integers-are-equal-up-to-64-bit-representation-limits.integer-minus-one-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 9007199254740992
        \\ }
    );

    const case =
        \\ 9007199254740991
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.float-and-integers-are-equal-up-to-64-bit-representation-limits.float-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 9007199254740992
        \\ }
    );

    const case =
        \\ 9007199254740992
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.float-and-integers-are-equal-up-to-64-bit-representation-limits.float-minus-one-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": 9007199254740992
        \\ }
    );

    const case =
        \\ 9007199254740991
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "const.nul-characters-in-strings.match-string-with-nul" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": "hello\u0000there"
        \\ }
    );

    const case =
        \\ "hello\u0000there"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "const.nul-characters-in-strings.do-not-match-string-lacking-nul" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "const": "hello\u0000there"
        \\ }
    );

    const case =
        \\ "hellothere"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "required.required-validation.present-required-property-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "required.required-with-empty-array.property-not-required" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "foo": {}
        \\     },
        \\     "required": []
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true,
        \\     "items": false
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true,
        \\     "items": false
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true,
        \\     "items": false
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true,
        \\     "items": false
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": true,
        \\     "items": false
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false,
        \\     "items": false
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false,
        \\     "items": false
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false,
        \\     "items": false
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false,
        \\     "items": false
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         {
        \\             "type": "boolean"
        \\         },
        \\         {
        \\             "type": "boolean"
        \\         }
        \\     ],
        \\     "uniqueItems": false,
        \\     "items": false
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
test "maxContains.maxContains-without-contains-is-ignored.one-item-valid-against-lone-maxContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "maxContains": 1
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxContains.maxContains-without-contains-is-ignored.two-items-still-valid-against-lone-maxContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "maxContains": 1
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
test "maxContains.maxContains-with-contains.empty-data" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "maxContains.maxContains-with-contains.all-elements-match,-valid-maxContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxContains.maxContains-with-contains.all-elements-match,-invalid-maxContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
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
test "maxContains.maxContains-with-contains.some-elements-match,-valid-maxContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
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
test "maxContains.maxContains-with-contains.some-elements-match,-invalid-maxContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
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
test "maxContains.maxContains-with-contains,-value-with-a-decimal.one-element-matches,-valid-maxContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
        \\ }
    );

    const case =
        \\ [
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxContains.maxContains-with-contains,-value-with-a-decimal.too-many-elements-match,-invalid-maxContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "maxContains": 1
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
test "maxContains.minContains-<-maxContains.actual-<-minContains-<-maxContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1,
        \\     "maxContains": 3
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "maxContains.minContains-<-maxContains.minContains-<-actual-<-maxContains" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1,
        \\     "maxContains": 3
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
test "maxContains.minContains-<-maxContains.minContains-<-maxContains-<-actual" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contains": {
        \\         "const": 1
        \\     },
        \\     "minContains": 1,
        \\     "maxContains": 3
        \\ }
    );

    const case =
        \\ [
        \\     1,
        \\     1,
        \\     1,
        \\     1
        \\ ]
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "prefixItems.a-schema-given-for-prefixItems.correct-types" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
test "prefixItems.a-schema-given-for-prefixItems.wrong-types" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
test "prefixItems.a-schema-given-for-prefixItems.incomplete-array-of-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
test "prefixItems.a-schema-given-for-prefixItems.array-with-additional-items" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
test "prefixItems.a-schema-given-for-prefixItems.empty-array" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
test "prefixItems.a-schema-given-for-prefixItems.JavaScript-pseudo-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
test "prefixItems.prefixItems-with-boolean-schemas.array-with-one-item-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         true,
        \\         false
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
test "prefixItems.prefixItems-with-boolean-schemas.array-with-two-items-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         true,
        \\         false
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
test "prefixItems.prefixItems-with-boolean-schemas.empty-array-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
        \\         true,
        \\         false
        \\     ]
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "prefixItems.additional-items-are-allowed-by-default.only-the-first-item-is-validated" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
test "prefixItems.prefixItems-with-null-instance-elements.allows-null-elements" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "prefixItems": [
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
test "maxProperties.maxProperties-validation.shorter-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "maxProperties": 2
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxProperties.maxProperties-validation-with-a-decimal.shorter-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "maxProperties.maxProperties-validation-with-a-decimal.too-long-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "maxProperties.maxProperties-=-0-means-the-object-is-empty.no-properties-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "allOf.allOf-with-boolean-schemas,-all-true.any-value-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         true,
        \\         true
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "allOf.allOf-with-boolean-schemas,-some-false.any-value-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         true,
        \\         false
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf-with-boolean-schemas,-all-false.any-value-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "allOf": [
        \\         false,
        \\         false
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "allOf.allOf-with-one-empty-schema.any-data-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "unevaluatedProperties.unevaluatedProperties-true.with-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": true
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-true.with-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": true
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-schema.with-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": {
        \\         "type": "string",
        \\         "minLength": 3
        \\     }
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-schema.with-valid-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": {
        \\         "type": "string",
        \\         "minLength": 3
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-schema.with-invalid-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": {
        \\         "type": "string",
        \\         "minLength": 3
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "fo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-false.with-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-false.with-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-properties.with-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-properties.with-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-patternProperties.with-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "patternProperties": {
        \\         "^foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-patternProperties.with-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "patternProperties": {
        \\         "^foo": {
        \\             "type": "string"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-bool-additionalProperties.with-no-additional-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "additionalProperties": true,
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-bool-additionalProperties.with-additional-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "additionalProperties": true,
        \\     "unevaluatedProperties": false
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
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-non-bool-additionalProperties.with-only-valid-additional-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "additionalProperties": {
        \\         "type": "string"
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-adjacent-non-bool-additionalProperties.with-invalid-additional-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "additionalProperties": {
        \\         "type": "string"
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-properties.with-no-additional-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-properties.with-additional-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-patternProperties.with-no-additional-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-patternProperties.with-additional-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-additionalProperties.with-no-additional-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-additionalProperties.with-additional-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-unevaluatedProperties.with-no-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-nested-unevaluatedProperties.with-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-anyOf.when-one-matches-and-has-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-anyOf.when-one-matches-and-has-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "not-baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-anyOf.when-two-match-and-has-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-anyOf.when-two-match-and-has-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "baz",
        \\     "quux": "not-quux"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-oneOf.with-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-oneOf.with-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "quux": "quux"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-not.with-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else.when-if-is-true-and-has-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "then",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else.when-if-is-true-and-has-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "then",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else.when-if-is-false-and-has-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else.when-if-is-false-and-has-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "else",
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-then-not-defined.when-if-is-true-and-has-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "then",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-then-not-defined.when-if-is-true-and-has-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "then",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-then-not-defined.when-if-is-false-and-has-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-then-not-defined.when-if-is-false-and-has-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "else",
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-else-not-defined.when-if-is-true-and-has-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "then",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-else-not-defined.when-if-is-true-and-has-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "then",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-else-not-defined.when-if-is-false-and-has-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-if/then/else,-else-not-defined.when-if-is-false-and-has-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "else",
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-dependentSchemas.with-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-dependentSchemas.with-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-boolean-schemas.with-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-boolean-schemas.with-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-$ref.with-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-$ref.with-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-before-$ref.with-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-before-$ref.with-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-with-$dynamicRef.with-no-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://example.com/unevaluated-properties-with-dynamic-ref/derived",
        \\     "$ref": "./baseSchema",
        \\     "$defs": {
        \\         "derived": {
        \\             "$dynamicAnchor": "addons",
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         },
        \\         "baseSchema": {
        \\             "$id": "./baseSchema",
        \\             "$comment": "unevaluatedProperties comes first so it's more likely to catch bugs with implementations that are sensitive to keyword ordering",
        \\             "unevaluatedProperties": false,
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "$dynamicRef": "#addons",
        \\             "$defs": {
        \\                 "defaultAddons": {
        \\                     "$comment": "Needed to satisfy the bookending requirement",
        \\                     "$dynamicAnchor": "addons"
        \\                 }
        \\             }
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
test "unevaluatedProperties.unevaluatedProperties-with-$dynamicRef.with-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "https://example.com/unevaluated-properties-with-dynamic-ref/derived",
        \\     "$ref": "./baseSchema",
        \\     "$defs": {
        \\         "derived": {
        \\             "$dynamicAnchor": "addons",
        \\             "properties": {
        \\                 "bar": {
        \\                     "type": "string"
        \\                 }
        \\             }
        \\         },
        \\         "baseSchema": {
        \\             "$id": "./baseSchema",
        \\             "$comment": "unevaluatedProperties comes first so it's more likely to catch bugs with implementations that are sensitive to keyword ordering",
        \\             "unevaluatedProperties": false,
        \\             "properties": {
        \\                 "foo": {
        \\                     "type": "string"
        \\                 }
        \\             },
        \\             "$dynamicRef": "#addons",
        \\             "$defs": {
        \\                 "defaultAddons": {
        \\                     "$comment": "Needed to satisfy the bookending requirement",
        \\                     "$dynamicAnchor": "addons"
        \\                 }
        \\             }
        \\         }
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar",
        \\     "baz": "baz"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-can't-see-inside-cousins.always-fails" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-can't-see-inside-cousins-(reverse-order).always-fails" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-false,-inner-true,-properties-outside.with-no-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-false,-inner-true,-properties-outside.with-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-false,-inner-true,-properties-inside.with-no-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-false,-inner-true,-properties-inside.with-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-true,-inner-false,-properties-outside.with-no-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-true,-inner-false,-properties-outside.with-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-true,-inner-false,-properties-inside.with-no-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.nested-unevaluatedProperties,-outer-true,-inner-false,-properties-inside.with-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.cousin-unevaluatedProperties,-true-and-false,-true-with-properties.with-no-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.cousin-unevaluatedProperties,-true-and-false,-true-with-properties.with-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.cousin-unevaluatedProperties,-true-and-false,-false-with-properties.with-no-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.cousin-unevaluatedProperties,-true-and-false,-false-with-properties.with-nested-unevaluated-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": "foo",
        \\     "bar": "bar"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.property-is-evaluated-in-an-uncle-schema-to-unevaluatedProperties.no-extra-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "foo": {
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
    );

    const case =
        \\ {
        \\     "foo": {
        \\         "bar": "test"
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.property-is-evaluated-in-an-uncle-schema-to-unevaluatedProperties.uncle-keyword-evaluation-is-not-significant" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "foo": {
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
    );

    const case =
        \\ {
        \\     "foo": {
        \\         "bar": "test",
        \\         "faz": "test"
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.in-place-applicator-siblings,-allOf-has-unevaluated.base-case:-both-properties-present" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.in-place-applicator-siblings,-allOf-has-unevaluated.in-place-applicator-siblings,-bar-is-missing" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.in-place-applicator-siblings,-allOf-has-unevaluated.in-place-applicator-siblings,-foo-is-missing" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.in-place-applicator-siblings,-anyOf-has-unevaluated.base-case:-both-properties-present" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 1,
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.in-place-applicator-siblings,-anyOf-has-unevaluated.in-place-applicator-siblings,-bar-is-missing" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.in-place-applicator-siblings,-anyOf-has-unevaluated.in-place-applicator-siblings,-foo-is-missing" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "bar": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Empty-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Single-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "x": {}
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Unevaluated-on-1st-level-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "x": {},
        \\     "y": {}
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Nested-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "x": {
        \\         "x": {}
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Unevaluated-on-2nd-level-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "x": {
        \\         "x": {},
        \\         "y": {}
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Deep-nested-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "x": {
        \\         "x": {
        \\             "x": {}
        \\         }
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-+-single-cyclic-ref.Unevaluated-on-3rd-level-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "properties": {
        \\         "x": {
        \\             "$ref": "#"
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "x": {
        \\         "x": {
        \\             "x": {},
        \\             "y": {}
        \\         }
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.Empty-is-invalid-(no-x-or-y)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.a-and-b-are-invalid-(no-x-or-y)" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "a": 1,
        \\     "b": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.x-and-y-are-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "x": 1,
        \\     "y": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.a-and-x-are-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "a": 1,
        \\     "x": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.a-and-y-are-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "a": 1,
        \\     "y": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.a-and-b-and-x-are-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "a": 1,
        \\     "b": 1,
        \\     "x": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.a-and-b-and-y-are-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "a": 1,
        \\     "b": 1,
        \\     "y": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-+-ref-inside-allOf-/-oneOf.a-and-b-and-x-and-y-are-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "a": 1,
        \\     "b": 1,
        \\     "x": 1,
        \\     "y": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.Empty-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.a-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "a": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.b-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "b": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.c-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "c": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.d-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "d": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.a-+-b-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "a": 1,
        \\     "b": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.a-+-c-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "a": 1,
        \\     "c": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.a-+-d-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "a": 1,
        \\     "d": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.b-+-c-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "b": 1,
        \\     "c": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.b-+-d-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "b": 1,
        \\     "d": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.c-+-d-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "c": 1,
        \\     "d": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "xx": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-+-foox-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "xx": 1,
        \\     "foox": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-+-foo-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "xx": 1,
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-+-a-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "xx": 1,
        \\     "a": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-+-b-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "xx": 1,
        \\     "b": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-+-c-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "xx": 1,
        \\     "c": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.xx-+-d-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "xx": 1,
        \\     "d": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.all-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "all": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.all-+-foo-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "all": 1,
        \\     "foo": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.dynamic-evalation-inside-nested-refs.all-+-a-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "all": 1,
        \\     "a": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.non-object-instances-are-valid.ignores-booleans" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ true
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.non-object-instances-are-valid.ignores-integers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ 123
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.non-object-instances-are-valid.ignores-floats" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.non-object-instances-are-valid.ignores-arrays" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ []
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.non-object-instances-are-valid.ignores-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.non-object-instances-are-valid.ignores-null" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ null
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-with-null-valued-instance-properties.allows-null-valued-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "unevaluatedProperties": {
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
test "unevaluatedProperties.unevaluatedProperties-not-affected-by-propertyNames.allows-only-number-properties" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "maxLength": 1
        \\     },
        \\     "unevaluatedProperties": {
        \\         "type": "number"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a": 1
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-not-affected-by-propertyNames.string-property-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "propertyNames": {
        \\         "maxLength": 1
        \\     },
        \\     "unevaluatedProperties": {
        \\         "type": "number"
        \\     }
        \\ }
    );

    const case =
        \\ {
        \\     "a": "b"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.unevaluatedProperties-can-see-annotations-from-if-without-then-and-else.valid-in-case-if-is-evaluated" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "patternProperties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "foo": "a"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "unevaluatedProperties.unevaluatedProperties-can-see-annotations-from-if-without-then-and-else.invalid-in-case-if-is-evaluated" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "if": {
        \\         "patternProperties": {
        \\             "foo": {
        \\                 "type": "string"
        \\             }
        \\         }
        \\     },
        \\     "unevaluatedProperties": false
        \\ }
    );

    const case =
        \\ {
        \\     "bar": "a"
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dependentSchemas-with-unevaluatedProperties.unevaluatedProperties-doesn't-consider-dependentSchemas" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo": ""
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dependentSchemas-with-unevaluatedProperties.unevaluatedProperties-doesn't-see-bar-when-foo2-is-absent" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "bar": ""
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "unevaluatedProperties.dependentSchemas-with-unevaluatedProperties.unevaluatedProperties-sees-bar-when-foo2-is-present" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ {
        \\     "foo2": "",
        \\     "bar": ""
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxItems.maxItems-validation.shorter-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "maxItems": 2
        \\ }
    );

    const case =
        \\ "foobar"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "maxItems.maxItems-validation-with-a-decimal.shorter-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "maxItems.maxItems-validation-with-a-decimal.too-long-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "pattern.pattern-validation.a-matching-pattern-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "minProperties": 1
        \\ }
    );

    const case =
        \\ 12
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "minProperties.minProperties-validation-with-a-decimal.longer-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "minProperties.minProperties-validation-with-a-decimal.too-short-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "minProperties": 1
        \\ }
    );

    const case =
        \\ {}
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "anchor.Location-independent-identifier.match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "#foo",
        \\     "$defs": {
        \\         "A": {
        \\             "$anchor": "foo",
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
test "anchor.Location-independent-identifier.mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "#foo",
        \\     "$defs": {
        \\         "A": {
        \\             "$anchor": "foo",
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
test "anchor.Location-independent-identifier-with-absolute-URI.match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/bar#foo",
        \\     "$defs": {
        \\         "A": {
        \\             "$id": "http://localhost:1234/draft2020-12/bar",
        \\             "$anchor": "foo",
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
test "anchor.Location-independent-identifier-with-absolute-URI.mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "http://localhost:1234/draft2020-12/bar#foo",
        \\     "$defs": {
        \\         "A": {
        \\             "$id": "http://localhost:1234/draft2020-12/bar",
        \\             "$anchor": "foo",
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
test "anchor.Location-independent-identifier-with-base-URI-change-in-subschema.match" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/root",
        \\     "$ref": "http://localhost:1234/draft2020-12/nested.json#foo",
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
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anchor.Location-independent-identifier-with-base-URI-change-in-subschema.mismatch" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/root",
        \\     "$ref": "http://localhost:1234/draft2020-12/nested.json#foo",
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
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "anchor.same-$anchor-with-different-base-uri.$ref-resolves-to-/$defs/A/allOf/1" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/foobar",
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
    );

    const case =
        \\ "a"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anchor.same-$anchor-with-different-base-uri.$ref-does-not-resolve-to-/$defs/A/allOf/0" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$id": "http://localhost:1234/draft2020-12/foobar",
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
    );

    const case =
        \\ 1
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "enum.simple-enum-validation.one-of-the-enum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "exclusiveMaximum.exclusiveMaximum-validation.below-the-exclusiveMaximum-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "exclusiveMaximum": 3
        \\ }
    );

    const case =
        \\ 2.2
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "exclusiveMaximum.exclusiveMaximum-validation.boundary-point-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "exclusiveMaximum": 3
        \\ }
    );

    const case =
        \\ 3
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "exclusiveMaximum.exclusiveMaximum-validation.above-the-exclusiveMaximum-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "exclusiveMaximum": 3
        \\ }
    );

    const case =
        \\ 3.5
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
test "exclusiveMaximum.exclusiveMaximum-validation.ignores-non-numbers" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "exclusiveMaximum": 3
        \\ }
    );

    const case =
        \\ "x"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anyOf.anyOf.first-anyOf-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "anyOf.anyOf-with-boolean-schemas,-all-true.any-value-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "anyOf": [
        \\         true,
        \\         true
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anyOf.anyOf-with-boolean-schemas,-some-true.any-value-is-valid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "anyOf": [
        \\         true,
        \\         false
        \\     ]
        \\ }
    );

    const case =
        \\ "foo"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "anyOf.anyOf-with-boolean-schemas,-all-false.any-value-is-invalid" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "anyOf": [
        \\         false,
        \\         false
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
test "content.validation-of-string-encoded-content-based-on-media-type.a-valid-JSON-document" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contentMediaType": "application/json"
        \\ }
    );

    const case =
        \\ "{\"foo\": \"bar\"}"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-string-encoded-content-based-on-media-type.an-invalid-JSON-document;-validates-true" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contentMediaType": "application/json"
        \\ }
    );

    const case =
        \\ "{:}"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-string-encoded-content-based-on-media-type.ignores-non-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contentMediaType": "application/json"
        \\ }
    );

    const case =
        \\ 100
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-string-encoding.a-valid-base64-string" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contentEncoding": "base64"
        \\ }
    );

    const case =
        \\ "eyJmb28iOiAiYmFyIn0K"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-string-encoding.an-invalid-base64-string-(%-is-not-a-valid-character);-validates-true" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contentEncoding": "base64"
        \\ }
    );

    const case =
        \\ "eyJmb28iOi%iYmFyIn0K"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-string-encoding.ignores-non-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contentEncoding": "base64"
        \\ }
    );

    const case =
        \\ 100
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-encoded-media-type-documents.a-valid-base64-encoded-JSON-document" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64"
        \\ }
    );

    const case =
        \\ "eyJmb28iOiAiYmFyIn0K"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-encoded-media-type-documents.a-validly-encoded-invalid-JSON-document;-validates-true" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64"
        \\ }
    );

    const case =
        \\ "ezp9Cg=="
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-encoded-media-type-documents.an-invalid-base64-string-that-is-valid-JSON;-validates-true" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64"
        \\ }
    );

    const case =
        \\ "{}"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-encoded-media-type-documents.ignores-non-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "contentMediaType": "application/json",
        \\     "contentEncoding": "base64"
        \\ }
    );

    const case =
        \\ 100
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.a-valid-base64-encoded-JSON-document" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "eyJmb28iOiAiYmFyIn0K"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.another-valid-base64-encoded-JSON-document" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "eyJib28iOiAyMCwgImZvbyI6ICJiYXoifQ=="
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.an-invalid-base64-encoded-JSON-document;-validates-true" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "eyJib28iOiAyMH0="
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.an-empty-object-as-a-base64-encoded-JSON-document;-validates-true" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "e30="
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.an-empty-array-as-a-base64-encoded-JSON-document" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "W10="
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.a-validly-encoded-invalid-JSON-document;-validates-true" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "ezp9Cg=="
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.an-invalid-base64-string-that-is-valid-JSON;-validates-true" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ "{}"
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "content.validation-of-binary-encoded-media-type-documents-with-schema.ignores-non-strings" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
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
    );

    const case =
        \\ 100
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "defs.validate-definition-against-metaschema.valid-definition-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "https://json-schema.org/draft/2020-12/schema"
        \\ }
    );

    const case =
        \\ {
        \\     "$defs": {
        \\         "foo": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), true);
}
test "defs.validate-definition-against-metaschema.invalid-definition-schema" {
    const schema = try JSONSchema.parse(
        \\ {
        \\     "$schema": "https://json-schema.org/draft/2020-12/schema",
        \\     "$ref": "https://json-schema.org/draft/2020-12/schema"
        \\ }
    );

    const case =
        \\ {
        \\     "$defs": {
        \\         "foo": {
        \\             "type": 1
        \\         }
        \\     }
        \\ }
    ;
    try std.testing.expectEqual(schema.is_valid(case), false);
}
