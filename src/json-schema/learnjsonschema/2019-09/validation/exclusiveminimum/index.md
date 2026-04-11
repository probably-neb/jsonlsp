# exclusiveMinimum

- Original: [https://www.learnjsonschema.com/2019-09/validation/exclusiveminimum/](https://www.learnjsonschema.com/2019-09/validation/exclusiveminimum/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/validation/exclusiveMinimum.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/validation/exclusiveMinimum.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.6.2.5](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.6.2.5)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/validation`
- Introduced in: `draft3`

Validation succeeds if the numeric instance is greater than the given number.

The [`exclusiveMinimum`](index.md) keyword restricts number instances to be strictly
greater than the given number.

> **Type constraint:** Non-`number` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains number instances to be greater than the positive integer 10

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "exclusiveMinimum": 10
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

### Schema: A schema that constrains number instances to be greater than the negative real number -2.1

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "exclusiveMinimum": -2.1
}
```

### Valid instance: A number value greater than -2.1 is valid

```json
-2.09
```

### Valid instance: An integer value greater than -2.1 is valid

```json
-2
```

### Invalid instance: A number value less than -2.1 is invalid

```json
-2.11
```

### Invalid instance: An integer value less than -2.1 is invalid

```json
-3
```

### Invalid instance: The real number value -2.1 is invalid

```json
-2.1
```

### Valid instance: A non-number value is valid

```json
"100000"
```
