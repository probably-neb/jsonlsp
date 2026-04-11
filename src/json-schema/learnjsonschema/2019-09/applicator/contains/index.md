# contains

- Original: [https://www.learnjsonschema.com/2019-09/applicator/contains/](https://www.learnjsonschema.com/2019-09/applicator/contains/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/contains.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/contains.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.3.1.4](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.3.1.4)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/applicator`
- Introduced in: `draft6`

Validation succeeds if the instance contains an element that validates against this schema.

The [`contains`](index.md) keyword restricts
array instances to include one or more items (at any location of the array) that
validate against the given subschema. The lower and upper bounds that are
allowed to validate against the given subschema can be controlled using the
[`minContains`](../../validation/mincontains/index.md) and
[`maxContains`](../../validation/maxcontains/index.md) keywords.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains array instances to contain at least one even number

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
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
