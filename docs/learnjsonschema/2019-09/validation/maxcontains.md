# maxContains

- Original: [https://www.learnjsonschema.com/2019-09/validation/maxcontains/](https://www.learnjsonschema.com/2019-09/validation/maxcontains/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/validation/maxContains.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/validation/maxContains.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.6.4.4](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.6.4.4)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/validation`
- Introduced in: `2019-09`

The number of times that the [`contains`](/2019-09/applicator/contains) keyword (if set) successfully validates against the instance must be less than or equal to the given integer.
The [`maxContains`](maxcontains.md) keyword
modifies the [`contains`](../applicator/contains.md) keyword to
constrain array instances to the given maximum number of containment matches.
This keyword has no effect if the [`contains`](../applicator/contains.md) keyword is not declared.

> **Digging Deeper:**
> Using [`contains`](../applicator/contains.md) with both
> [`minContains`](mincontains.md) and
> [`maxContains`](maxcontains.md) set to the same
> value restricts arrays to contain exactly that number of items that match the
> given subschema. Furthermore, setting these keywords to zero is a common trick
> to restrict arrays to not contain an item that matches the given subschema
> without making use of the [`not`](../applicator/not.md)
> applicator.

> **Type constraint:** Non-`array` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains array instances to contain at most two even numbers

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "maxContains": 2,
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

### Valid instance: An array value with one even number is valid

```json
[ "foo", 2, false, [ "bar" ], -5 ]
```

### Annotation

```json
{ "keyword": "/contains", "instance": "", "value": [ 1 ] }
```

### Invalid instance: An array value with more than two even numbers is invalid

```json
[ "foo", 2, false, 3, 4, [ "bar" ], -5, -3.0 ]
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

### Schema: A schema that constrains array instances to not contain an even number

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "minContains": 0,
  "maxContains": 0,
  "contains": {
    "multipleOf": 2
  }
}
```

### Valid instance: An array value with no even number is valid

```json
[ "foo", 3, false ]
```

### Invalid instance: An array value with one even number is invalid

```json
[ "foo", 2, false ]
```

### Invalid instance: An array value with multiple even numbers is invalid

```json
[ "foo", 2, 4 ]
```

### Valid instance: An empty array value is invalid

```json
[]
```

### Valid instance: A non-array value is valid

```json
"Hello World"
```

### Schema: A schema that incorrectly constrains maximum containment without constrainining containment

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "maxContains": 2
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
