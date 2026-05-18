# maxItems

- Original: [https://www.learnjsonschema.com/draft7/validation/maxitems/](https://www.learnjsonschema.com/draft7/validation/maxitems/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/maxItems.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/maxItems.markdown)
- Specification: [https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.4.3](https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.4.3)
- Metaschema: `http://json-schema.org/draft-07/schema#`
- Introduced in: `draft1`

An array instance is valid if its size is less than, or equal to, the value of this keyword.
The [`maxItems`](maxitems.md) keyword restricts array instances to consists of an inclusive
maximum numbers of items.

> **Common Pitfall:**
>  The presence of this keyword does not depend on the
> presence of the [`items`](items.md) keyword.

> **Best Practice:**
> To restrict array instances to the empty array, prefer using
> the [`const`](const.md) keyword instead of
> setting this keyword to `0`. 

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains array instances to contain at most 3 items

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "maxItems": 3
}
```

### Invalid instance: An array value with more than 3 items is invalid

```json
[ 1, 2, 3, 4 ]
```

### Valid instance: An array value with 3 items is valid

```json
[ 1, true, "hello" ]
```

### Valid instance: An array value with less than 3 items is valid

```json
[ false, "foo" ]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```
