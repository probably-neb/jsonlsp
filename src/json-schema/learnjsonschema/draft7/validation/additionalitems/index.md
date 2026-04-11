# additionalItems

- Original: [https://www.learnjsonschema.com/draft7/validation/additionalitems/](https://www.learnjsonschema.com/draft7/validation/additionalitems/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/additionalItems.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/additionalItems.markdown)
- Specification: [https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.4.2](https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.4.2)
- Metaschema: `http://json-schema.org/draft-07/schema#`
- Introduced in: `draft3`

If [`items`](/draft7/validation/items) is set to an array of schemas, validation succeeds if each element of the instance not covered by it validates against this schema.

The [`additionalItems`](index.md)
keyword restricts array instance items not described by the _sibling_
[`items`](../items/index.md) keyword (when [`items`](../items/index.md) is in array form), to validate against the
given subschema.

> **Common Pitfall:**
> This keyword **only** has an effect when the sibling
> [`items`](../items/index.md) keyword is set to an array of
> schemas. If [`items`](../items/index.md) is not present or
> is set to a schema (not an array of schemas), [`additionalItems`](index.md) has no effect and is
> ignored.

> **Common Pitfall:**
> This keyword does not prevent an array instance from being
> empty or having fewer items than the [`items`](../items/index.md) array. If needed, use the [`minItems`](../minitems/index.md) keyword to assert on the minimum bounds of the
> array.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains array instances to start with a boolean item followed by a number item, with only string items allowed beyond that

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
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

### Schema: A schema that prevents additional items beyond the tuple

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "items": [ { "type": "boolean" }, { "type": "number" } ],
  "additionalItems": false
}
```

### Valid instance: An array value with exactly two items matching the tuple is valid

```json
[ false, 35 ]
```

### Invalid instance: An array value with items beyond the tuple is invalid

```json
[ false, 35, "foo" ]
```

### Schema: A schema that describes open items and additional items leads to the additional items schema being ignored

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "items": { "type": "number" },
  "additionalItems": { "type": "string" }
}
```

### Valid instance: An array value with only numbers is valid

```json
[ 1, 2, 3 ]
```

### Valid instance: An array value with numbers and strings is valid as the keyword is ignored

```json
[ 1, 2, "foo" ]
```
### Schema: A schema with only additional items definitions leads to the additional items schema being ignored

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "additionalItems": { "type": "string" }
}
```

### Valid instance: Any array is valid

```json
[ 1, 2, 3 ]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```
