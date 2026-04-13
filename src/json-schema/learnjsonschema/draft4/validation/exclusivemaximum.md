# exclusiveMaximum

- Original: [https://www.learnjsonschema.com/draft4/validation/exclusivemaximum/](https://www.learnjsonschema.com/draft4/validation/exclusivemaximum/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/exclusiveMaximum.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/exclusiveMaximum.markdown)
- Specification: [https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.1.2](https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.1.2)
- Metaschema: `http://json-schema.org/draft-04/schema#`
- Introduced in: `draft3`

When [`maximum`](/draft4/validation/maximum) is present and this keyword is set to true, the numeric instance must be less than the value in [`maximum`](/draft4/validation/maximum).

The [`exclusiveMaximum`](exclusivemaximum.md)
keyword is a boolean modifier for the [`maximum`](maximum.md) keyword. When set to `true`, it changes the
validation behavior of the [`maximum`](maximum.md)
keyword from _less than or equal to_ to _strictly less than_. This keyword has
no effect if the [`maximum`](maximum.md) keyword
is not present in the same schema.

> **Type constraint:** Non-`number` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains number instances to be less than 10

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "maximum": 10,
  "exclusiveMaximum": true
}
```

### Valid instance: A number value less than 10 is valid

```json
9.9
```

### Valid instance: An integer value less than 10 is valid

```json
9
```

### Invalid instance: A number value greater than 10 is invalid

```json
10.001
```

### Invalid instance: An integer value greater than 10 is invalid

```json
11
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

### Schema: A schema with exclusive semantics but no upper bound

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "exclusiveMaximum": true
}
```

### Valid instance: Any number value is valid

```json
10
```

### Valid instance: Any number value is valid

```json
999999999
```

### Schema: A schema that explicitly constrains number instances to be less than or equal to 10

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "maximum": 10,
  "exclusiveMaximum": false
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

### Valid instance: A number value less than 10 is valid

```json
9.9
```

### Invalid instance: A number value greater than 10 is invalid

```json
10.1
```
