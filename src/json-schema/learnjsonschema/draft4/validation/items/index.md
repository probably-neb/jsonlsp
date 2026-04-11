# items

- Original: [https://www.learnjsonschema.com/draft4/validation/items/](https://www.learnjsonschema.com/draft4/validation/items/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/items.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/items.markdown)
- Specification: [https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.3.1](https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.3.1)
- Metaschema: `http://json-schema.org/draft-04/schema#`
- Introduced in: `draft1`

If set to a schema, validation succeeds if each element of the instance validates against it, otherwise validation succeeds if each element of the instance validates against the schema at the same position, if any

The [`items`](index.md) keyword is used to
validate array items and has two different modes of operation depending on the
type of its value:

- **Schema**: When set to a schema, [`items`](index.md) validates that all items in the array instance validate against the
  given subschema.

- **Array**: When set to an array of schemas, [`items`](index.md) validates each item in the array instance
  against the subschema at the corresponding position. Items beyond the length
  of the [`items`](index.md) array can be
  validated using the [`additionalItems`](../additionalitems/index.md) keyword.

> **Common Pitfall:**
> This keyword does not prevent an array instance from being
> empty. If needed, use the [`minItems`](../minitems/index.md) to assert on the minimum bounds of the array.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains array instances to consist of number items

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "items": { "type": "number" }
}
```

### Valid instance: An array value that only consists of number items is valid

```json
[ 1, -3.4, 54 ]
```

### Valid instance: An empty array value is valid

```json
[]
```

### Invalid instance: An array value that includes a non-number item is invalid

```json
[ 1, -3.4, 54, "foo" ]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```

### Schema: A schema that constrains array instances to start with a boolean item followed by a number item

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "items": [ { "type": "boolean" }, { "type": "number" } ]
}
```

### Valid instance: An array value that consists of a boolean item followed by a number item is valid

```json
[ false, 35 ]
```

### Valid instance: An array value with additional items beyond the tuple is valid

```json
[ false, 35, "foo", "bar" ]
```

### Invalid instance: An array value where the first item is not a boolean is invalid

```json
[ "not a boolean", 35 ]
```

### Invalid instance: An array value where the second item is not a number is invalid

```json
[ false, "not a number" ]
```

### Valid instance: An empty array value is valid

```json
[]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```

### Schema: A schema that constrains array instances to start with a boolean item followed by a number item, with only string items allowed beyond that

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "items": [ { "type": "boolean" }, { "type": "number" } ],
  "additionalItems": { "type": "string" }
}
```

### Valid instance: An array value that consists of a boolean item followed by a number item is valid

```json
[ false, 35 ]
```

### Valid instance: An array value that consists of a boolean item followed by a number item and string items is valid

```json
[ false, 35, "foo", "bar" ]
```

### Invalid instance: An array value that consists of a boolean item followed by a number item and non-string items is invalid

```json
[ false, 35, { "foo": "bar" } ]
```

### Valid instance: An empty array value is valid

```json
[]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```
