# minContains

- Original: [https://www.learnjsonschema.com/2019-09/validation/mincontains/](https://www.learnjsonschema.com/2019-09/validation/mincontains/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/validation/minContains.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/validation/minContains.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.6.4.5](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.6.4.5)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/validation`
- Introduced in: `2019-09`

The number of times that the [`contains`](/2019-09/applicator/contains) keyword (if set) successfully validates against the instance must be greater than or equal to the given integer.

The [`minContains`](mincontains.md) keyword
modifies the [`contains`](../applicator/contains.md) keyword to
constrain array instances to the given minimum number of containment matches.
This keyword has no effect if the [`contains`](../applicator/contains.md) keyword is not declared.

> **Common Pitfall:**
> Keep in mind that when collecting annotations, the
> evaluator might need to exhaustively check every item in the array past the
> containment lower bound instead of short-circuiting validation, potentially
> introducing additional computational overhead.
>
> For example, consider an array of 10 items where 5 of its items validate
> against the [`contains`](../applicator/contains.md) subschema
> and [`minContains`](mincontains.md) is set to to
> 2. When not collecting annotations, validation will stop after encountering the
> second match. However, when collecting annotations, validation will have to
> proceed past the second match to report the 5 matching
> indexes.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains array instances to contain at least two even numbers

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "minContains": 2,
  "contains": {
    "type": "number",
    "multipleOf": 2
  }
}
```

### Valid instance: An array value with two even numbers is valid

```json
[ "foo", 2, false, 3, 4, [ "bar" ], -5 ]
```

### Annotation

```json
{ "keyword": "/contains", "instance": "", "value": [ 1, 4 ] }
```

### Valid instance: An array value with more than two even numbers is valid

```json
[ "foo", 2, false, 3, 4, [ "bar" ], -5, -3.0 ]
```

### Annotation

```json
{ "keyword": "/contains", "instance": "", "value": [ 1, 4, 7 ] }
```

### Invalid instance: An array value with one even number is invalid

```json
[ "foo", 2, false, [ "bar" ], -5 ]
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

### Schema: A schema that incorrectly constrains minimum containment without constrainining containment

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "minContains": 2
}
```

### Valid instance: An array value with arbitrary items is valid

```json
[ "John", false, 29, { "foo": "bar" }, [ 5, 7 ] ]
```

### Valid instance: An empty array is valid

```json
[]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```
