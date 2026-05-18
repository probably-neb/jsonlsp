# prefixItems

- Original: [https://www.learnjsonschema.com/2020-12/applicator/prefixitems/](https://www.learnjsonschema.com/2020-12/applicator/prefixitems/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/applicator/prefixItems.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/applicator/prefixItems.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-core.html#section-10.3.1.1](https://json-schema.org/draft/2020-12/json-schema-core.html#section-10.3.1.1)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/applicator`
- Introduced in: `2020-12`

Validation succeeds if each element of the instance validates against the schema at the same position, if any.
The [`prefixItems`](prefixItems.md) keyword restricts a
number of items from the start of an array instance to validate against the
given sequence of subschemas, where the item at a given index in the array
instance is evaluated against the subschema at the given index in the
[`prefixItems`](prefixItems.md) array, if any.  Information
about the number of subschemas that were evaluated against the array instance
is reported using annotations.

Array items outside the range described by the
[`prefixItems`](prefixItems.md) keyword is evaluated against
the [`items`](items.md) keyword, if present.

> **Common Pitfall:**
> This keyword does not restrict the size of the array. If
> the array instance has fewer number of items that the given subschemas, only
> such items will be validated. If needed, use the [`minItems`](../validation/minitems.md) and the [`maxItems`](../validation/maxitems.md) keywords to assert on the bounds of the
> array.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains array instances to start with a boolean item followed by a number item

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "prefixItems": [ { "type": "boolean" }, { "type": "number" } ]
}
```

### Valid instance: An empty array value is valid

```json
[]
```

### Valid instance: An array value that consists of a boolean item is valid

```json
[ false ]
```

### Annotation

```json
{ "keyword": "/prefixItems", "instance": "", "value": 0 }
```

### Valid instance: An array value that consists of a boolean item followed by a number item is valid

```json
[ false, 35 ]
```

### Annotation

```json
{ "keyword": "/prefixItems", "instance": "", "value": true }
```

### Valid instance: An array value that consists of a boolean item followed by a number item and other items is valid

```json
[ false, 35, "something", "else" ]
```

### Annotation

```json
{ "keyword": "/prefixItems", "instance": "", "value": 1 }
```

### Invalid instance: An array value that does not consist of a boolean item followed by a number item is invalid

```json
[ true, false ]
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

### Valid instance: An empty array value is valid

```json
[]
```

### Valid instance: An array value that consists of a boolean item is valid

```json
[ false ]
```

### Annotation

```json
{ "keyword": "/prefixItems", "instance": "", "value": 0 }
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
{ "keyword": "/prefixItems", "instance": "", "value": 1 }
{ "keyword": "/items", "instance": "", "value": true }
```

### Invalid instance: An array value that consists of a boolean item followed by a number item and other non-string items is invalid

```json
[ false, 35, { "foo": "bar" } ]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```
