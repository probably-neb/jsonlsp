# contains

- Original: [https://www.learnjsonschema.com/draft6/validation/contains/](https://www.learnjsonschema.com/draft6/validation/contains/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/contains.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/contains.markdown)
- Specification: [https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.6.14](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.6.14)
- Metaschema: `http://json-schema.org/draft-06/schema#`
- Introduced in: `draft6`

Validation succeeds if the instance contains an element that validates against this schema.
The [`contains`](contains.md) keyword restricts
array instances to include one or more items (at any location of the array)
that validate against the given subschema.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains array instances to contain at least one even number

```json
{
  "$schema": "http://json-schema.org/draft-06/schema#",
  "contains": {
    "type": "number",
    "multipleOf": 2
  }
}
```

### Valid instance: An array value with one even number is valid

```json
[ "foo", 2, false, [ "bar" ], -5 ]
```

### Valid instance: An array value with multiple even numbers is valid

```json
[ "foo", 2, false, 3, 4, [ "bar" ], -5, -3.0 ]
```

### Valid instance: An array value that solely consists of even numbers is valid

```json
[ 2, 4, 6, 8, 10, 12 ]
```

### Invalid instance: An array value without any even number is invalid

```json
[ "foo", true ]
```

### Invalid instance: An empty array value is invalid

```json
[]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```
