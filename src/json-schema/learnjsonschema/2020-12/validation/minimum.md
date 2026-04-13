# minimum

- Original: [https://www.learnjsonschema.com/2020-12/validation/minimum/](https://www.learnjsonschema.com/2020-12/validation/minimum/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/validation/minimum.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/validation/minimum.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-6.2.4](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-6.2.4)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/validation`
- Introduced in: `draft1`

Validation succeeds if the numeric instance is greater than or equal to the given number.

The [`minimum`](minimum.md) keyword restricts number instances to be greater than or equal to
the given number.

> **Type constraint:** Non-`number` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains number instances to be greater than or equal to the positive integer 10

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "minimum": 10
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

### Schema: A schema that constrains number instances to be greater than or equal to the negative real number -2.1

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "minimum": -2.1
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

### Valid instance: The real number value -2.1 is valid

```json
-2.1
```

### Valid instance: A non-number value is valid

```json
"100000"
```
