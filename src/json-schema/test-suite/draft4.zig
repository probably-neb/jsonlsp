const std = @import("std");
const JSONSchema = @import("json-schema");

fn check_valid(schema_str: []const u8, case: []const u8, is_valid: bool) !void {
    var schema = JSONSchema.parseWithRevision(schema_str, .draft4) catch |err| std.debug.panic("Failed to parse JSON schema: {}\n", .{err});
    defer schema.arena.release();
    if (schema.is_valid(case) == is_valid) return;
    std.debug.print("\nReason:\nExpected Schema:\n{s}\nTo {s} Case:\n{s}\nBut it was {s}!\n", .{
        schema_str,
        if (is_valid) "ACCEPT" else "REJECT",
        case,
        if (is_valid) "REJECTED" else "ACCEPTED",
    });
    return error.FailedTest;
}
test "dependencies.dependencies.neither" {
    try check_valid(
        \\ {
        \\     "dependencies": {
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
test "dependencies.dependencies.nondependant" {
    try check_valid(
        \\ {
        \\     "dependencies": {
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
test "dependencies.dependencies.with-dependency" {
    try check_valid(
        \\ {
        \\     "dependencies": {
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
test "dependencies.dependencies.missing-dependency" {
    try check_valid(
        \\ {
        \\     "dependencies": {
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
test "dependencies.dependencies.ignores-arrays" {
    try check_valid(
        \\ {
        \\     "dependencies": {
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
test "dependencies.dependencies.ignores-strings" {
    try check_valid(
        \\ {
        \\     "dependencies": {
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
test "dependencies.dependencies.ignores-other-non-objects" {
    try check_valid(
        \\ {
        \\     "dependencies": {
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
test "dependencies.multiple-dependencies.neither" {
    try check_valid(
        \\ {
        \\     "dependencies": {
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
test "dependencies.multiple-dependencies.nondependants" {
    try check_valid(
        \\ {
        \\     "dependencies": {
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
test "dependencies.multiple-dependencies.with-dependencies" {
    try check_valid(
        \\ {
        \\     "dependencies": {
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
test "dependencies.multiple-dependencies.missing-dependency" {
    try check_valid(
        \\ {
        \\     "dependencies": {
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
test "dependencies.multiple-dependencies.missing-other-dependency" {
    try check_valid(
        \\ {
        \\     "dependencies": {
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
test "dependencies.multiple-dependencies.missing-both-dependencies" {
    try check_valid(
        \\ {
        \\     "dependencies": {
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
test "dependencies.multiple-dependencies-subschema.valid" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        true,
    );
}
test "dependencies.multiple-dependencies-subschema.no-dependency" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo": "quux"
        \\ }
    ,
        true,
    );
}
test "dependencies.multiple-dependencies-subschema.wrong-type" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo": "quux",
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "dependencies.multiple-dependencies-subschema.wrong-type-other" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo": 2,
        \\     "bar": "quux"
        \\ }
    ,
        false,
    );
}
test "dependencies.multiple-dependencies-subschema.wrong-type-both" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo": "quux",
        \\     "bar": "quux"
        \\ }
    ,
        false,
    );
}
test "dependencies.dependencies-with-escaped-characters.valid-object-1" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo\nbar": 1,
        \\     "foo\rbar": 2
        \\ }
    ,
        true,
    );
}
test "dependencies.dependencies-with-escaped-characters.valid-object-2" {
    try check_valid(
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
test "dependencies.dependencies-with-escaped-characters.valid-object-3" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo'bar": 1,
        \\     "foo\"bar": 2
        \\ }
    ,
        true,
    );
}
test "dependencies.dependencies-with-escaped-characters.invalid-object-1" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo\nbar": 1,
        \\     "foo": 2
        \\ }
    ,
        false,
    );
}
test "dependencies.dependencies-with-escaped-characters.invalid-object-2" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo\tbar": 1,
        \\     "a": 2
        \\ }
    ,
        false,
    );
}
test "dependencies.dependencies-with-escaped-characters.invalid-object-3" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo'bar": 1
        \\ }
    ,
        false,
    );
}
test "dependencies.dependencies-with-escaped-characters.invalid-object-4" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo\"bar": 2
        \\ }
    ,
        false,
    );
}
test "dependencies.dependent-subschema-incompatible-with-root.matches-root" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo": 1
        \\ }
    ,
        false,
    );
}
test "dependencies.dependent-subschema-incompatible-with-root.matches-dependency" {
    try check_valid(
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
    ,
        \\ {
        \\     "bar": 1
        \\ }
    ,
        true,
    );
}
test "dependencies.dependent-subschema-incompatible-with-root.matches-both" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo": 1,
        \\     "bar": 2
        \\ }
    ,
        false,
    );
}
test "dependencies.dependent-subschema-incompatible-with-root.no-dependency" {
    try check_valid(
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
    ,
        \\ {
        \\     "baz": 1
        \\ }
    ,
        true,
    );
}
test "required.required-validation.present-required-property-is-valid" {
    try check_valid(
        \\ {
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
test "required.required-with-escaped-characters.object-with-all-properties-present-is-valid" {
    try check_valid(
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
test "maxLength.maxLength-validation.shorter-is-valid" {
    try check_valid(
        \\ {
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
        \\     "maxLength": 2
        \\ }
    ,
        \\ "💩💩"
    ,
        true,
    );
}
test "minLength.minLength-validation.longer-is-valid" {
    try check_valid(
        \\ {
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
        \\     "minLength": 2
        \\ }
    ,
        \\ "💩"
    ,
        false,
    );
}
test "enum.simple-enum-validation.one-of-the-enum-is-valid" {
    try check_valid(
        \\ {
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
test "minimum.minimum-validation.above-the-minimum-is-valid" {
    try check_valid(
        \\ {
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
        \\     "minimum": 1.1
        \\ }
    ,
        \\ "x"
    ,
        true,
    );
}
test "minimum.minimum-validation-(explicit-false-exclusivity).above-the-minimum-is-valid" {
    try check_valid(
        \\ {
        \\     "minimum": 1.1,
        \\     "exclusiveMinimum": false
        \\ }
    ,
        \\ 2.6
    ,
        true,
    );
}
test "minimum.minimum-validation-(explicit-false-exclusivity).boundary-point-is-valid" {
    try check_valid(
        \\ {
        \\     "minimum": 1.1,
        \\     "exclusiveMinimum": false
        \\ }
    ,
        \\ 1.1
    ,
        true,
    );
}
test "minimum.minimum-validation-(explicit-false-exclusivity).below-the-minimum-is-invalid" {
    try check_valid(
        \\ {
        \\     "minimum": 1.1,
        \\     "exclusiveMinimum": false
        \\ }
    ,
        \\ 0.6
    ,
        false,
    );
}
test "minimum.minimum-validation-(explicit-false-exclusivity).ignores-non-numbers" {
    try check_valid(
        \\ {
        \\     "minimum": 1.1,
        \\     "exclusiveMinimum": false
        \\ }
    ,
        \\ "x"
    ,
        true,
    );
}
test "minimum.exclusiveMinimum-validation.above-the-minimum-is-still-valid" {
    try check_valid(
        \\ {
        \\     "minimum": 1.1,
        \\     "exclusiveMinimum": true
        \\ }
    ,
        \\ 1.2
    ,
        true,
    );
}
test "minimum.exclusiveMinimum-validation.boundary-point-is-invalid" {
    try check_valid(
        \\ {
        \\     "minimum": 1.1,
        \\     "exclusiveMinimum": true
        \\ }
    ,
        \\ 1.1
    ,
        false,
    );
}
test "minimum.minimum-validation-with-signed-integer.negative-above-the-minimum-is-valid" {
    try check_valid(
        \\ {
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
        \\     "minimum": -2
        \\ }
    ,
        \\ "x"
    ,
        true,
    );
}
test "pattern.pattern-validation.a-matching-pattern-is-valid" {
    try check_valid(
        \\ {
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
        \\     "minProperties": 1
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.a-single-valid-match-is-valid" {
    try check_valid(
        \\ {
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
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        \\ []
    ,
        true,
    );
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.ignores-strings" {
    try check_valid(
        \\ {
        \\     "patternProperties": {
        \\         "f.*o": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        \\ ""
    ,
        true,
    );
}
test "patternProperties.patternProperties-validates-properties-matching-a-regex.ignores-other-non-objects" {
    try check_valid(
        \\ {
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
test "patternProperties.patternProperties-with-null-valued-instance-properties.allows-null-values" {
    try check_valid(
        \\ {
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
test "items.a-schema-given-for-items.valid-items" {
    try check_valid(
        \\ {
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
test "items.items-and-subitems.valid-items" {
    try check_valid(
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
test "items.items-with-null-instance-elements.allows-null-elements" {
    try check_valid(
        \\ {
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
test "allOf.allOf.allOf" {
    try check_valid(
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
test "allOf.allOf-with-one-empty-schema.any-data-is-valid" {
    try check_valid(
        \\ {
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
test "not.not.allowed" {
    try check_valid(
        \\ {
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
        \\     "not": {}
        \\ }
    ,
        \\ []
    ,
        false,
    );
}
test "not.double-negation.any-value-is-valid" {
    try check_valid(
        \\ {
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
test "uniqueItems.uniqueItems-validation.unique-array-of-integers-is-valid" {
    try check_valid(
        \\ {
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
test "maxItems.maxItems-validation.shorter-is-valid" {
    try check_valid(
        \\ {
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
        \\     "maxItems": 2
        \\ }
    ,
        \\ "foobar"
    ,
        true,
    );
}
test "maximum.maximum-validation.below-the-maximum-is-valid" {
    try check_valid(
        \\ {
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
        \\     "maximum": 300
        \\ }
    ,
        \\ 300.5
    ,
        false,
    );
}
test "maximum.maximum-validation-(explicit-false-exclusivity).below-the-maximum-is-valid" {
    try check_valid(
        \\ {
        \\     "maximum": 3,
        \\     "exclusiveMaximum": false
        \\ }
    ,
        \\ 2.6
    ,
        true,
    );
}
test "maximum.maximum-validation-(explicit-false-exclusivity).boundary-point-is-valid" {
    try check_valid(
        \\ {
        \\     "maximum": 3,
        \\     "exclusiveMaximum": false
        \\ }
    ,
        \\ 3
    ,
        true,
    );
}
test "maximum.maximum-validation-(explicit-false-exclusivity).above-the-maximum-is-invalid" {
    try check_valid(
        \\ {
        \\     "maximum": 3,
        \\     "exclusiveMaximum": false
        \\ }
    ,
        \\ 3.5
    ,
        false,
    );
}
test "maximum.maximum-validation-(explicit-false-exclusivity).ignores-non-numbers" {
    try check_valid(
        \\ {
        \\     "maximum": 3,
        \\     "exclusiveMaximum": false
        \\ }
    ,
        \\ "x"
    ,
        true,
    );
}
test "maximum.exclusiveMaximum-validation.below-the-maximum-is-still-valid" {
    try check_valid(
        \\ {
        \\     "maximum": 3,
        \\     "exclusiveMaximum": true
        \\ }
    ,
        \\ 2.2
    ,
        true,
    );
}
test "maximum.exclusiveMaximum-validation.boundary-point-is-invalid" {
    try check_valid(
        \\ {
        \\     "maximum": 3,
        \\     "exclusiveMaximum": true
        \\ }
    ,
        \\ 3
    ,
        false,
    );
}
test "maxProperties.maxProperties-validation.shorter-is-valid" {
    try check_valid(
        \\ {
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
        \\     "maxProperties": 2
        \\ }
    ,
        \\ 12
    ,
        true,
    );
}
test "maxProperties.maxProperties-=-0-means-the-object-is-empty.no-properties-is-valid" {
    try check_valid(
        \\ {
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
test "minItems.minItems-validation.longer-is-valid" {
    try check_valid(
        \\ {
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
        \\     "minItems": 1
        \\ }
    ,
        \\ ""
    ,
        true,
    );
}
test "additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.no-additional-properties-is-valid" {
    try check_valid(
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
test "oneOf.oneOf.first-oneOf-valid" {
    try check_valid(
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
    ,
        \\ 1
    ,
        true,
    );
}
test "oneOf.oneOf.second-oneOf-valid" {
    try check_valid(
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
    ,
        \\ 2.5
    ,
        true,
    );
}
test "oneOf.oneOf.both-oneOf-valid" {
    try check_valid(
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
    ,
        \\ 3
    ,
        false,
    );
}
test "oneOf.oneOf.neither-oneOf-valid" {
    try check_valid(
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
    ,
        \\ 1.5
    ,
        false,
    );
}
test "oneOf.oneOf-with-base-schema.mismatch-base-schema" {
    try check_valid(
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
    ,
        \\ 3
    ,
        false,
    );
}
test "oneOf.oneOf-with-base-schema.one-oneOf-valid" {
    try check_valid(
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
    ,
        \\ "foobar"
    ,
        true,
    );
}
test "oneOf.oneOf-with-base-schema.both-oneOf-valid" {
    try check_valid(
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
    ,
        \\ "foo"
    ,
        false,
    );
}
test "oneOf.oneOf-complex-types.first-oneOf-valid-(complex)" {
    try check_valid(
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
test "additionalItems.additionalItems-as-schema.additional-items-match-schema" {
    try check_valid(
        \\ {
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
test "additionalItems.when-items-is-schema,-additionalItems-does-nothing.all-items-match-schema" {
    try check_valid(
        \\ {
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
test "refRemote.remote-ref.remote-ref-valid" {
    try check_valid(
        \\ {
        \\     "$ref": "http://localhost:1234/integer.json"
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
        \\     "$ref": "http://localhost:1234/integer.json"
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
        \\     "$ref": "http://localhost:1234/draft4/subSchemas.json#/definitions/integer"
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
        \\     "$ref": "http://localhost:1234/draft4/subSchemas.json#/definitions/integer"
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
        \\     "$ref": "http://localhost:1234/draft4/subSchemas.json#/definitions/refToInteger"
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
        \\     "$ref": "http://localhost:1234/draft4/subSchemas.json#/definitions/refToInteger"
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
        \\     "id": "http://localhost:1234/",
        \\     "items": {
        \\         "id": "baseUriChange/",
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
        \\     "id": "http://localhost:1234/",
        \\     "items": {
        \\         "id": "baseUriChange/",
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
        \\     "id": "http://localhost:1234/object",
        \\     "type": "object",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "draft4/name.json#/definitions/orNull"
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
        \\     "id": "http://localhost:1234/object",
        \\     "type": "object",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "draft4/name.json#/definitions/orNull"
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
        \\     "id": "http://localhost:1234/object",
        \\     "type": "object",
        \\     "properties": {
        \\         "name": {
        \\             "$ref": "draft4/name.json#/definitions/orNull"
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
test "refRemote.Location-independent-identifier-in-remote-ref.integer-is-valid" {
    try check_valid(
        \\ {
        \\     "$ref": "http://localhost:1234/draft4/locationIndependentIdentifier.json#/definitions/refToInteger"
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
        \\     "$ref": "http://localhost:1234/draft4/locationIndependentIdentifier.json#/definitions/refToInteger"
        \\ }
    ,
        \\ "foo"
    ,
        false,
    );
}
test "anyOf.anyOf.first-anyOf-valid" {
    try check_valid(
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
    ,
        \\ 1
    ,
        true,
    );
}
test "anyOf.anyOf.second-anyOf-valid" {
    try check_valid(
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
    ,
        \\ 2.5
    ,
        true,
    );
}
test "anyOf.anyOf.both-anyOf-valid" {
    try check_valid(
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
    ,
        \\ 3
    ,
        true,
    );
}
test "anyOf.anyOf.neither-anyOf-valid" {
    try check_valid(
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
    ,
        \\ 1.5
    ,
        false,
    );
}
test "anyOf.anyOf-with-base-schema.mismatch-base-schema" {
    try check_valid(
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
    ,
        \\ 3
    ,
        false,
    );
}
test "anyOf.anyOf-with-base-schema.one-anyOf-valid" {
    try check_valid(
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
    ,
        \\ "foobar"
    ,
        true,
    );
}
test "anyOf.anyOf-with-base-schema.both-anyOf-invalid" {
    try check_valid(
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
    ,
        \\ "foo"
    ,
        false,
    );
}
test "anyOf.anyOf-complex-types.first-anyOf-valid-(complex)" {
    try check_valid(
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
test "format.email-format.all-string-formats-ignore-integers" {
    try check_valid(
        \\ {
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
        \\     "format": "email"
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
        \\     "format": "ipv6"
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
        \\     "format": "hostname"
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
        \\     "format": "date-time"
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
        \\     "format": "uri"
        \\ }
    ,
        \\ null
    ,
        true,
    );
}
test "multipleOf.by-int.int-by-int" {
    try check_valid(
        \\ {
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
        \\     "multipleOf": 0.0001
        \\ }
    ,
        \\ 0.00751
    ,
        false,
    );
}
test "multipleOf.float-division-=-inf.invalid,-but-naive-implementations-may-raise-an-overflow-error" {
    try check_valid(
        \\ {
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
        \\     "type": "integer",
        \\     "multipleOf": 0.00000001
        \\ }
    ,
        \\ 12391239123
    ,
        true,
    );
}
test "definitions.validate-definition-against-metaschema.valid-definition-schema" {
    try check_valid(
        \\ {
        \\     "$ref": "http://json-schema.org/draft-04/schema#"
        \\ }
    ,
        \\ {
        \\     "definitions": {
        \\         "foo": {
        \\             "type": "integer"
        \\         }
        \\     }
        \\ }
    ,
        true,
    );
}
test "definitions.validate-definition-against-metaschema.invalid-definition-schema" {
    try check_valid(
        \\ {
        \\     "$ref": "http://json-schema.org/draft-04/schema#"
        \\ }
    ,
        \\ {
        \\     "definitions": {
        \\         "foo": {
        \\             "type": 1
        \\         }
        \\     }
        \\ }
    ,
        false,
    );
}
test "ref.root-pointer-ref.match" {
    try check_valid(
        \\ {
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
    ,
        \\ 5
    ,
        true,
    );
}
test "ref.nested-refs.nested-ref-invalid" {
    try check_valid(
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
    ,
        \\ "a"
    ,
        false,
    );
}
test "ref.ref-overrides-any-sibling-keywords.ref-valid" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo": []
        \\ }
    ,
        true,
    );
}
test "ref.ref-overrides-any-sibling-keywords.ref-valid,-maxItems-ignored" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo": [
        \\         1,
        \\         2,
        \\         3
        \\     ]
        \\ }
    ,
        true,
    );
}
test "ref.ref-overrides-any-sibling-keywords.ref-invalid" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo": "string"
        \\ }
    ,
        false,
    );
}
test "ref.$ref-prevents-a-sibling-id-from-changing-the-base-uri.$ref-resolves-to-/definitions/base_foo,-data-does-not-validate" {
    try check_valid(
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
    ,
        \\ "a"
    ,
        false,
    );
}
test "ref.$ref-prevents-a-sibling-id-from-changing-the-base-uri.$ref-resolves-to-/definitions/base_foo,-data-validates" {
    try check_valid(
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
    ,
        \\ 1
    ,
        true,
    );
}
test "ref.remote-ref,-containing-refs-itself.remote-ref-valid" {
    try check_valid(
        \\ {
        \\     "$ref": "http://json-schema.org/draft-04/schema#"
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
        \\     "$ref": "http://json-schema.org/draft-04/schema#"
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
    ,
        \\ {
        \\     "$ref": 2
        \\ }
    ,
        false,
    );
}
test "ref.Recursive-references-between-schemas.valid-tree" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo\"bar": "1"
        \\ }
    ,
        false,
    );
}
test "ref.Location-independent-identifier.match" {
    try check_valid(
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
    ,
        \\ 1
    ,
        true,
    );
}
test "ref.Location-independent-identifier.mismatch" {
    try check_valid(
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
    ,
        \\ "a"
    ,
        false,
    );
}
test "ref.Location-independent-identifier-with-base-URI-change-in-subschema.match" {
    try check_valid(
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
    ,
        \\ 1
    ,
        true,
    );
}
test "ref.Location-independent-identifier-with-base-URI-change-in-subschema.mismatch" {
    try check_valid(
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
    ,
        \\ "a"
    ,
        false,
    );
}
test "ref.naive-replacement-of-$ref-with-its-destination-is-not-correct.do-not-evaluate-the-$ref-inside-the-enum,-matching-any-string" {
    try check_valid(
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
    ,
        \\ "this is a string"
    ,
        false,
    );
}
test "ref.naive-replacement-of-$ref-with-its-destination-is-not-correct.match-the-enum-exactly" {
    try check_valid(
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
    ,
        \\ {
        \\     "$ref": "#/definitions/a_string"
        \\ }
    ,
        true,
    );
}
test "ref.id-must-be-resolved-against-nearest-parent,-not-just-immediate-parent.number-is-valid" {
    try check_valid(
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
    ,
        \\ 1
    ,
        true,
    );
}
test "ref.id-must-be-resolved-against-nearest-parent,-not-just-immediate-parent.non-number-is-invalid" {
    try check_valid(
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
    ,
        \\ "a"
    ,
        false,
    );
}
test "ref.id-with-file-URI-still-resolves-pointers---*nix.number-is-valid" {
    try check_valid(
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
    ,
        \\ 1
    ,
        true,
    );
}
test "ref.id-with-file-URI-still-resolves-pointers---*nix.non-number-is-invalid" {
    try check_valid(
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
    ,
        \\ "a"
    ,
        false,
    );
}
test "ref.id-with-file-URI-still-resolves-pointers---windows.number-is-valid" {
    try check_valid(
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
    ,
        \\ 1
    ,
        true,
    );
}
test "ref.id-with-file-URI-still-resolves-pointers---windows.non-number-is-invalid" {
    try check_valid(
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
    ,
        \\ "a"
    ,
        false,
    );
}
test "ref.empty-tokens-in-$ref-json-pointer.number-is-valid" {
    try check_valid(
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
    ,
        \\ 1
    ,
        true,
    );
}
test "ref.empty-tokens-in-$ref-json-pointer.non-number-is-invalid" {
    try check_valid(
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
    ,
        \\ "a"
    ,
        false,
    );
}
test "properties.object-properties-validation.both-properties-present-and-valid-is-valid" {
    try check_valid(
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
test "properties.properties-with-escaped-characters.object-with-all-numbers-is-valid" {
    try check_valid(
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
test "infinite-loop-detection.evaluating-the-same-schema-location-against-the-same-data-location-twice-is-not-a-sign-of-an-infinite-loop.passing-case" {
    try check_valid(
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
    ,
        \\ {
        \\     "foo": "a string"
        \\ }
    ,
        false,
    );
}
test "type.integer-type-matches-integers.an-integer-is-an-integer" {
    try check_valid(
        \\ {
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
        \\     "type": "number"
        \\ }
    ,
        \\ 1
    ,
        true,
    );
}
test "type.number-type-matches-numbers.a-float-with-zero-fractional-part-is-a-number" {
    try check_valid(
        \\ {
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
