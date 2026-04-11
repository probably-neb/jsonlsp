# unevaluatedItems

- Original: [https://www.learnjsonschema.com/2020-12/unevaluated/unevaluateditems/](https://www.learnjsonschema.com/2020-12/unevaluated/unevaluateditems/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/unevaluated/unevaluatedItems.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/unevaluated/unevaluatedItems.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-core.html#section-11.2](https://json-schema.org/draft/2020-12/json-schema-core.html#section-11.2)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/unevaluated`
- Introduced in: `2019-09`

Validates array elements that did not successfully validate against other standard array applicators.

The [`unevaluatedItems`](index.md)
keyword is a generalisation of the [`items`](../../applicator/items/index.md) keyword that considers related keywords even when they are not direct
siblings of this keyword. More specifically, this keyword is affected by
occurrences of [`prefixItems`](../../applicator/prefixitems/index.md),
[`items`](../../applicator/items/index.md), [`contains`](../../applicator/contains/index.md), and [`unevaluatedItems`](index.md) itself, as long as the evaluate path that led to
[`unevaluatedItems`](index.md) is a _prefix_ of the evaluate path of the others.

Given its evaluation-dependent nature, this keyword is evaluated after every
other keyword from every other vocabulary.

> **Best Practice:**
> There are two common use cases for this keyword, both for reducing duplication:
> (1) Elegantly describing additional array items while declaring the
> [`prefixItems`](../../applicator/prefixitems/index.md) or
> [`contains`](../../applicator/contains/index.md) keywords behind
> conditional logic without duplicating the [`items`](../../applicator/items/index.md) keyword in every possible branch. (2) Reusing
> helpers that consist of the [`prefixItems`](../../applicator/prefixitems/index.md), [`items`](../../applicator/items/index.md), or [`contains`](../../applicator/contains/index.md) keywords, while specialising the helpers as
> needed in specific locations without having to inline the entire contents of
> the helper.

> **Digging Deeper:**
> The JSON Schema specification defines the relationship between this keyword and
> the ones that affect it in terms of annotations. However, in practice, most
> implementations avoid the use of annotations for performance reasons, as
> emitting annotations and checking the annotation values of other keywords often
> involves significant memory allocation and complex data structure traversals.
>
> The paper [Elimination of annotation dependencies in validation for Modern JSON
> Schema](https://arxiv.org/abs/2503.11288) is a comprehensive mathematical study
> of how applicators can be automatically re-written to avoid annotation
> dependencies, leading to schemas that are simpler to evaluate.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that conditionally constrains array instances to contain certain items, with number additional items in both cases

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "if": { "maxItems": 3 },
  "then": { "prefixItems": [ { "type": "string" } ] },
  "else": { "contains": { "type": "boolean" } },
  "unevaluatedItems": { "type": "number" }
}
```

### Valid instance: An array value that contains a string property and other number items is valid

```json
[ "foo", 1, 2 ]
```

### Annotation

```json
{ "keyword": "/then/prefixItems", "instance": "", "value": 0 }
{ "keyword": "/unevaluatedItems", "instance": "", "value": true }
```

### Valid instance: An array value that contains multiple boolean and number items is valid

```json
[ true, 1, false, 2, true, 3 ]
```

### Annotation

```json
{ "keyword": "/else/contains", "instance": "", "value": [ 0, 2, 4 ] }
{ "keyword": "/unevaluatedItems", "instance": "", "value": true }
```

### Invalid instance: An array value that contains a string property and other non-number items is invalid

```json
[ "foo", "bar", "baz" ]
```

### Invalid instance: An array value that contains multiple boolean and number items, and string additional items is invalid

```json
[ true, 2, "foo", "bar" ]
```

### Valid instance: An empty array value is valid

```json
{}
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```

### Schema: A schema that constraints array instances to only allow a single string item using a helper

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$ref": "#/$defs/string-first-item",
  "unevaluatedItems": false,
  "$defs": {
    "string-first-item": {
      "prefixItems": [ { "type": "string" } ]
    }
  }
}
```

### Valid instance: An array value that only contains a string item is valid

```json
[ "foo" ]
```

### Annotation

```json
{ "keyword": "/$defs/string-first-item/prefixItems", "instance": "", "value": 0 }
```

### Invalid instance: An array value that contains a string item and other items is invalid

```json
[ "foo", 2, 3 ]
```

### Valid instance: An empty array value is valid

```json
{}
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```

### Schema: A schema that constraints array instances to not define any items, as both array keywords are cousins

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "allOf": [
    { "items": true },
    { "unevaluatedItems": false }
  ]
}
```

### Invalid instance: An array value that contains any item is invalid as the schema prohibits unevaluated items

```json
[ 1, 2, 3 ]
```

### Valid instance: An empty array value is valid

```json
[]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```

### Schema: A schema that constraints array instances to define arbitrary items

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "allOf": [ { "unevaluatedItems": true } ],
  "unevaluatedItems": false
}
```

### Valid instance: An array value that contains any item is valid as the nested applicator takes precedence

```json
[ 1, 2, 3 ]
```

### Annotation

```json
{ "keyword": "/allOf/0/unevaluatedItems", "instance": "", "value": true }
```

### Valid instance: An empty array value is valid

```json
{}
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```
