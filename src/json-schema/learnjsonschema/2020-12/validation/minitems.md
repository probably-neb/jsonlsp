# minItems

- Original: [https://www.learnjsonschema.com/2020-12/validation/minitems/](https://www.learnjsonschema.com/2020-12/validation/minitems/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/validation/minItems.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/validation/minItems.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-6.4.2](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-6.4.2)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/validation`
- Introduced in: `draft1`

An array instance is valid if its size is greater than, or equal to, the value of this keyword.

The [`minItems`](minItems.md) keyword restricts array instances to consists of an inclusive
minimum numbers of items.

> **Common Pitfall:**
>  The presence of this keyword does not depend on the
> presence of the [`items`](../applicator/items.md) keyword.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains array instances to contain at least 3 items

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "minItems": 3
}
```

### Valid instance: An array value with more than 3 items is valid

```json
[ 1, 2, 3, 4 ]
```

### Valid instance: An array value with 3 items is valid

```json
[ 1, true, "hello" ]
```

### Invalid instance: An array value with less than 3 items is invalid

```json
[ false, "foo" ]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```
