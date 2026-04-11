# minItems

- Original: [https://www.learnjsonschema.com/draft4/validation/minitems/](https://www.learnjsonschema.com/draft4/validation/minitems/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/minItems.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/minItems.markdown)
- Specification: [https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.3.3](https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.3.3)
- Metaschema: `http://json-schema.org/draft-04/schema#`
- Introduced in: `draft1`

An array instance is valid if its size is greater than, or equal to, the value of this keyword.

The [`minItems`](index.md) keyword restricts array instances to consists of an inclusive
minimum numbers of items.

> **Common Pitfall:**
>  The presence of this keyword does not depend on the
> presence of the [`items`](../items/index.md) keyword.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains array instances to contain at least 3 items

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
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
