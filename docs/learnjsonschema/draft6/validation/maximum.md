# maximum

- Original: [https://www.learnjsonschema.com/draft6/validation/maximum/](https://www.learnjsonschema.com/draft6/validation/maximum/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/maximum.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/maximum.markdown)
- Specification: [https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.6.2](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.6.2)
- Metaschema: `http://json-schema.org/draft-06/schema#`
- Introduced in: `draft1`

Validation succeeds if the numeric instance is less than or equal to the given number.
The [`maximum`](maximum.md) keyword restricts number instances to be less than or equal to
the given number.

> **Type constraint:** Non-`number` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains number instances to be less than or equal to the positive integer 10

```json
{
  "$schema": "http://json-schema.org/draft-06/schema#",
  "maximum": 10
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

### Valid instance: The real representation of the integer value 10 is valid

```json
10.0
```

### Valid instance: The integer value 10 is valid

```json
10
```

### Valid instance: A non-number value is valid

```json
"100000"
```

### Schema: A schema that constrains number instances to be less than or equal to the negative real number -2.1

```json
{
  "$schema": "http://json-schema.org/draft-06/schema#",
  "maximum": -2.1
}
```

### Valid instance: A number value less than -2.1 is valid

```json
-2.2
```

### Valid instance: An integer value less than -2.1 is valid

```json
-3
```

### Invalid instance: A number value greater than -2.1 is invalid

```json
-2.01
```

### Invalid instance: An integer value greater than -2.1 is invalid

```json
-2
```

### Valid instance: The real number value -2.1 is valid

```json
-2.1
```

### Valid instance: A non-number value is valid

```json
"100000"
```
