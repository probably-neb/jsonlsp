# const

- Original: [https://www.learnjsonschema.com/2019-09/validation/const/](https://www.learnjsonschema.com/2019-09/validation/const/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/validation/const.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/validation/const.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.6.1.3](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.6.1.3)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/validation`
- Introduced in: `draft6`

Validation succeeds if the instance is equal to this keyword's value.

The [`const`](const.md) keyword (short for
"constant") restricts instances to a single specific JSON value of any type.

> **Best Practice:**
>  Constraining instances to a constant value by definition
> implies the given JSON type. Therefore, combining this keyword with the
> [`type`](type.md) keyword is redundant (or even
> invalid if types don't agree), and considered an
> anti-pattern.

> **Common Pitfall:**
>  There are programming languages, such as JavaScript, that
> [cannot distinguish between integers and real
> numbers](https://2ality.com/2012/04/number-encoding.html). To accommodate for
> those cases, JSON Schema considers a real number with a zero fractional part to
> be equal to the corresponding integer. For example, in JSON Schema, `1` is
> considered to be equal to `1.0`.

## Examples

### Schema: A schema that constrains instances to an integer constant value

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "const": 5
}
```

### Valid instance: The desired integer value is valid

```json
5
```

### Valid instance: The real value representation of the desired integer value is valid

```json
5.0
```

### Invalid instance: Any other number value is invalid

```json
1234
```

### Invalid instance: Any other non-number value is invalid

```json
"Hello"
```

### Schema: A schema that constrains instances to a complex object value

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "const": { "name": "John Doe", "age": 30 }
}
```

### Valid instance: The object instance that equals the desired value is valid

```json
{ "name": "John Doe", "age": 30 }
```

### Invalid instance: Any other object value is invalid

```json
{ "name": "Jane Doe", "age": 30 }
```

### Invalid instance: Any other non-object value is invalid

```json
30
```
