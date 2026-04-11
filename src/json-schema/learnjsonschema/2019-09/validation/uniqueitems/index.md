# uniqueItems

- Original: [https://www.learnjsonschema.com/2019-09/validation/uniqueitems/](https://www.learnjsonschema.com/2019-09/validation/uniqueitems/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/validation/uniqueItems.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/validation/uniqueItems.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.6.4.3](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.6.4.3)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/validation`
- Introduced in: `draft2`

If this keyword is set to the boolean value `true`, the instance validates successfully if all of its elements are unique.

When set to `true`, the [`uniqueItems`](index.md) keyword restricts array instances to
items that only occur once in the array. Note that empty arrays and arrays that
consist of a single item satisfy uniqueness by definition.

> **Common Pitfall:**
>  Keep in mind that depending on the size and complexity of
> arrays, this keyword may introduce significant validation overhead. The paper
> [JSON: data model, query languages and schema
> specification](https://arxiv.org/abs/1701.02221) also noted how the presence of
> this keyword can negatively impact satisfiability analysis of
> schemas.

> **Digging Deeper:**
>  While the official vocabularies do not offer a way to
> ensure uniqueness of array items based a given key, the
> [json-everything](https://json-everything.net) project defines a third-party
> [Extended Validation of
> Arrays](https://docs.json-everything.net/schema/vocabs/array-ext/) vocabulary
> that introduces a
> [`uniqueKeys`](https://docs.json-everything.net/schema/vocabs/array-ext/#uniquekeys)
> keyword for this purpose. However, keep in mind that third-party vocabularies
> are often not widely supported by implementations.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains array instances to not contain duplicate items

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "uniqueItems": true
}
```

### Valid instance: An array value without duplicate items is valid

```json
[ 1, "hello", true, { "name": "John" } ]
```

### Invalid instance: An array value with duplicate elements is invalid

```json
[ { "name": "John" }, 1, "hello", true, { "name": "John" } ]
```

### Valid instance: An empty array value is valid

```json
[]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```

### Schema: A schema that allows array instances to contain duplicate items

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "uniqueItems": false
}
```

### Valid instance: An array value without duplicate items is valid

```json
[ 1, "hello", true, { "name": "John" } ]
```

### Valid instance: An array value with duplicate elements is valid

```json
[ { "name": "John" }, 1, "hello", true, { "name": "John" } ]
```

### Valid instance: An empty array value is valid

```json
[]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```
