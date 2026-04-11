# contains

- Original: [https://www.learnjsonschema.com/2020-12/applicator/contains/](https://www.learnjsonschema.com/2020-12/applicator/contains/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/applicator/contains.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/applicator/contains.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-core.html#section-10.3.1.3](https://json-schema.org/draft/2020-12/json-schema-core.html#section-10.3.1.3)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/applicator`
- Introduced in: `draft6`

Validation succeeds if the instance contains an element that validates against this schema.

The [`contains`](index.md) keyword restricts array
instances to include one or more items (at any location of the array) that
validate against the given subschema. The lower and upper bounds that are
allowed to validate against the given subschema can be controlled using the
[`minContains`](../../validation/mincontains/index.md) and
[`maxContains`](../../validation/maxcontains/index.md) keywords.
Information about the items that were successfully validated against the given
subschema is reported using annotations.

> **Digging Deeper:**
> Keep in mind that when collecting annotations, the
> evaluator might need to exhaustively check every item in the array past the
> containment lower bound instead of short-circuiting validation, potentially
> introducing additional computational overhead.
>
> For example, consider an array of 10 items where 5 of its items validate
> against the [`contains`](index.md) subschema (and neither
> [`minContains`](../../validation/mincontains/index.md) nor
> [`maxContains`](../../validation/maxcontains/index.md) are declared, for
> simplicity). When not collecting annotations, validation will stop after
> encountering the first match. However, when collecting annotations, validation
> will have to proceed past the first match to report the 5 matching indexes.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains array instances to contain at least one even number

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "contains": {
    "type": "number",
    "multipleOf": 2
  }
}
```

### Valid instance: An array value with one even number is valid

```json
[ "foo", 2, false, [ "bar" ], -5 ]
```

### Annotation

```json
{ "keyword": "/contains", "instance": "", "value": [ 1 ] }
```

### Valid instance: An array value with multiple even numbers is valid

```json
[ "foo", 2, false, 3, 4, [ "bar" ], -5, -3.0 ]
```

### Annotation

```json
{ "keyword": "/contains", "instance": "", "value": [ 1, 4, 7 ] }
```

### Valid instance: An array value that solely consists of even numbers is valid

```json
[ 2, 4, 6, 8, 10, 12 ]
```

### Annotation

```json
{ "keyword": "/contains", "instance": "", "value": true }
```

### Invalid instance: An array value without any even number is invalid

```json
[ "foo", true ]
```

### Invalid instance: An empty array value is invalid

```json
[]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```
