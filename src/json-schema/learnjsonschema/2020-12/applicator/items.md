# items

- Original: [https://www.learnjsonschema.com/2020-12/applicator/items/](https://www.learnjsonschema.com/2020-12/applicator/items/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/applicator/items.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/applicator/items.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-core.html#section-10.3.1.2](https://json-schema.org/draft/2020-12/json-schema-core.html#section-10.3.1.2)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/applicator`
- Introduced in: `draft1`

Validation succeeds if each element of the instance not covered by [`prefixItems`](/2020-12/applicator/prefixitems) validates against this schema.

The [`items`](items.md) keyword restricts array instance
items not described by the _sibling_ [`prefixItems`](prefixitems.md) keyword (if any), to validate against the
given subschema. Whether this keyword was evaluated against any item of the
array instance is reported using annotations.

> **Common Pitfall:**
> This keyword does not prevent an array instance from being
> empty. If needed, use the [`minItems`](../validation/minitems.md) keyword to assert on the minimum bounds of the array.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains array instances to consist of number items

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "items": { "type": "number" }
}
```

### Valid instance: An array value that only consists of number items is valid

```json
[ 1, -3.4, 54 ]
```

### Annotation

```json
{ "keyword": "/items", "instance": "", "value": true }
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

### Schema: A schema that constrains array instances to start with a boolean item followed by a number item followed by strings

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "prefixItems": [ { "type": "boolean" }, { "type": "number" } ],
  "items": { "type": "string" }
}
```

### Valid instance: An array value that consists of a boolean item followed by a number item is valid

```json
[ false, 35 ]
```

### Annotation

```json
{ "keyword": "/prefixItems", "instance": "", "value": true }
```

### Valid instance: An array value that consists of a boolean item followed by a number item and other string items is valid

```json
[ false, 35, "foo", "bar" ]
```

### Annotation

```json
{ "keyword": "/prefixItems", "instance": "", "value": 2 }
{ "keyword": "/items", "instance": "", "value": true }
```

### Invalid instance: An array value that consists of a boolean item followed by a number item and other non-string items is invalid

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
