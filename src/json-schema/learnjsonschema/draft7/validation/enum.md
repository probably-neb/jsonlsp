# enum

- Original: [https://www.learnjsonschema.com/draft7/validation/enum/](https://www.learnjsonschema.com/draft7/validation/enum/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/enum.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/enum.markdown)
- Specification: [https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.1.2](https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.1.2)
- Metaschema: `http://json-schema.org/draft-07/schema#`
- Introduced in: `draft1`

Validation succeeds if the instance is equal to one of the elements in this keyword's array value.

The [`enum`](enum.md) keyword restricts instances
to a finite set of possible values, which may be of different types.

> **Best Practice:**
>  Constraining instances to a set of possible values by
> definition implies the given JSON types. Therefore, combining this keyword with
> the [`type`](type.md) keyword is redundant (or
> even invalid if types don't agree), and considered an
> anti-pattern.

> **Common Pitfall:**
>  There are programming languages, such as JavaScript, that
> [cannot distinguish between integers and real
> numbers](https://2ality.com/2012/04/number-encoding.html). To accommodate for
> those cases, JSON Schema considers a real number with a zero fractional part to
> be equal to the corresponding integer. For example, in JSON Schema, `1` is
> considered to be equal to `1.0`.

## Examples

### Schema: A schema that constrains instances to an homogeneous string enumeration

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "enum": [ "red", "green", "blue" ]
}
```

### Valid instance: A string value that equals a value in the enumeration is valid

```json
"green"
```

### Invalid instance: A string value that does not equal a value in the enumeration is invalid

```json
"black"
```

### Invalid instance: Any other value is invalid

```json
2
```

### Schema: A schema that constrains instances to an homogeneous numeric enumeration

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "enum": [ 1, 2.0, 3 ]
}
```

### Valid instance: An integer value that equals a value in the enumeration is valid

```json
1
```

### Valid instance: An integer representation of a real value that equals a value in the enumeration is valid

```json
2
```

### Invalid instance: Any other number value is invalid

```json
5
```

### Invalid instance: Any other non-number value is invalid

```json
"Hello"
```

### Schema: A schema that constrains instances to an heterogeneous enumeration

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "enum": [ "red", 123, true, { "foo": "bar" }, [ 1, 2 ], null ]
}
```

### Valid instance: A boolean value that equals a value in the enumeration is valid

```json
true
```

### Valid instance: An object value that equals a value in the enumeration is valid

```json
{ "foo": "bar" }
```

### Invalid instance: An object value that does not equal a value in the enumeration is invalid

```json
{ "foo": "baz" }
```
