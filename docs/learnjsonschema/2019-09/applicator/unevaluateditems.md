# unevaluatedItems

- Original: [https://www.learnjsonschema.com/2019-09/applicator/unevaluateditems/](https://www.learnjsonschema.com/2019-09/applicator/unevaluateditems/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/unevaluatedItems.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/unevaluatedItems.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.3.1.3](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.3.1.3)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/applicator`
- Introduced in: `2019-09`

Validates array elements that did not successfully validate against other standard array applicators.
The [`unevaluatedItems`](unevaluateditems.md)
keyword is a generalisation of the [`additionalItems`](additionalitems.md) keyword that considers related
keywords even when they are not direct siblings of this keyword. More
specifically, this keyword is affected by occurrences of [`items`](items.md), [`additionalItems`](additionalitems.md), and [`unevaluatedItems`](unevaluateditems.md) itself, as long as the evaluate path
that led to [`unevaluatedItems`](unevaluateditems.md) is a _prefix_ of the evaluate path of the others.

Given its evaluation-dependent nature, this keyword is evaluated after every
other keyword from every other vocabulary.

> **Best Practice:**
> There are two common use cases for this keyword, both for reducing duplication:
> (1) Elegantly describing additional array items while declaring the
> [`items`](items.md) or [`additionalItems`](additionalitems.md) keywords behind conditional logic
> without duplicating these keywords in every possible branch. (2) Reusing
> helpers that consist of the [`items`](items.md)
> or [`additionalItems`](additionalitems.md)
> keywords, while specialising the helpers as needed in specific locations
> without having to inline the entire contents of the helper.

> **Digging Deeper:**
> The JSON Schema specification defines the relationship between this keyword
> and the ones that affect it in terms of annotations. However, in practice,
> most implementations avoid the use of annotations for performance reasons, as
> emitting annotations and checking the annotation values of other keywords
> often involves significant memory allocation and complex data structure
> traversals.
>
> The paper [Elimination of annotation dependencies in validation for Modern
> JSON Schema](https://arxiv.org/abs/2503.11288) is a comprehensive
> mathematical study of how applicators can be automatically re-written to avoid
> annotation dependencies, leading to schemas that are simpler to evaluate.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that conditionally constrains array instances to contain certain items, with number additional items in both cases

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "if": { "maxItems": 3 },
  "then": { "items": [ { "type": "string" } ] },
  "else": { "items": { "type": "boolean" } },
  "unevaluatedItems": { "type": "number" }
}
```

### Valid instance: An array value that contains a string property and other number items is valid

```json
[ "foo", 1, 2 ]
```

### Annotation

```json
{ "keyword": "/then/items", "instance": "", "value": 0 }
{ "keyword": "/unevaluatedItems", "instance": "", "value": true }
```

### Valid instance: An array value that contains only boolean items is valid

```json
[ true, false, true ]
```

### Annotation

```json
{ "keyword": "/else/items", "instance": "", "value": true }
```

### Invalid instance: An array value that contains a string property and other non-number items is invalid

```json
[ "foo", "bar", "baz" ]
```

### Invalid instance: An array value that contains multiple boolean and number items is invalid

```json
[ true, 2, false ]
```

### Valid instance: An empty array value is valid

```json
[]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```

### Schema: A schema that constraints array instances to only allow a single string item using a helper

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "$ref": "#/$defs/string-first-item",
  "unevaluatedItems": false,
  "$defs": {
    "string-first-item": {
      "items": [ { "type": "string" } ]
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
{ "keyword": "/$defs/string-first-item/items", "instance": "", "value": 0 }
```

### Invalid instance: An array value that contains a string item and other items is invalid

```json
[ "foo", 2, 3 ]
```

### Valid instance: An empty array value is valid

```json
[]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```

### Schema: A schema that constraints array instances to not define any items, as both array keywords are cousins

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
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
  "$schema": "https://json-schema.org/draft/2019-09/schema",
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
[]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```
