# exclusiveMaximum

- Original: [https://www.learnjsonschema.com/draft7/validation/exclusivemaximum/](https://www.learnjsonschema.com/draft7/validation/exclusivemaximum/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/exclusiveMaximum.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/exclusiveMaximum.markdown)
- Specification: [https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.2.3](https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.2.3)
- Metaschema: `http://json-schema.org/draft-07/schema#`
- Introduced in: `draft3`

Validation succeeds if the numeric instance is less than the given number.

The [`exclusiveMaximum`](exclusivemaximum.md) keyword restricts number instances to be strictly less
than the given number.

> **Type constraint:** Non-`number` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains number instances to be less than the positive integer 10

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "exclusiveMaximum": 10
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

### Schema: A schema that constrains number instances to be less than the negative real number -2.1

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "exclusiveMaximum": -2.1
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

### Invalid instance: The real number value -2.1 is invalid

```json
-2.1
```

### Valid instance: A non-number value is valid

```json
"100000"
```
