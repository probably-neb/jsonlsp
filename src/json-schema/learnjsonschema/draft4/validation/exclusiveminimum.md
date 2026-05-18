# exclusiveMinimum

- Original: [https://www.learnjsonschema.com/draft4/validation/exclusiveminimum/](https://www.learnjsonschema.com/draft4/validation/exclusiveminimum/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/exclusiveMinimum.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/exclusiveMinimum.markdown)
- Specification: [https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.1.3](https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.1.3)
- Metaschema: `http://json-schema.org/draft-04/schema#`
- Introduced in: `draft3`

When [`minimum`](/draft4/validation/minimum) is present and this keyword is set to true, the numeric instance must be greater than the value in [`minimum`](/draft4/validation/minimum).
The [`exclusiveMinimum`](exclusiveminimum.md)
keyword is a boolean modifier for the [`minimum`](minimum.md) keyword. When set to `true`, it changes the
validation behavior of the [`minimum`](minimum.md)
keyword from _greater than or equal to_ to _strictly greater than_. This
keyword has no effect if the [`minimum`](minimum.md) keyword is not present in the same schema.

> **Type constraint:** Non-`number` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains number instances to be greater than 10 (exclusive)

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "minimum": 10,
  "exclusiveMinimum": true
}
```

### Valid instance: A number value greater than 10 is valid

```json
10.1
```

### Valid instance: An integer value greater than 10 is valid

```json
11
```

### Invalid instance: A number value less than 10 is invalid

```json
9.9
```

### Invalid instance: An integer value less than 10 is invalid

```json
9
```

### Invalid instance: The real representation of the integer value 10 is invalid

```json
10.0
```

### Invalid instance: The integer value 10 is invalid

```json
10
```

### Valid instance: A non-number value is valid

```json
"100000"
```

### Schema: A schema with exclusive semantics but no lower bound

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "exclusiveMinimum": true
}
```

### Valid instance: Any number value is valid when minimum is not present

```json
10
```

### Valid instance: Any number value is valid when minimum is not present

```json
-999999999
```

### Schema: A schema that explicitly constrains number instances to be greater than or equal to 10

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "minimum": 10,
  "exclusiveMinimum": false
}
```

### Valid instance: The integer value 10 is valid

```json
10
```

### Valid instance: The real representation of the integer value 10 is valid

```json
10.0
```

### Valid instance: A number value greater than 10 is valid

```json
10.1
```

### Invalid instance: A number value less than 10 is invalid

```json
9.9
```
