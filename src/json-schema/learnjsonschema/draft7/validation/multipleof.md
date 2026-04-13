# multipleOf

- Original: [https://www.learnjsonschema.com/draft7/validation/multipleof/](https://www.learnjsonschema.com/draft7/validation/multipleof/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/multipleOf.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/multipleOf.markdown)
- Specification: [https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.2.1](https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.2.1)
- Metaschema: `http://json-schema.org/draft-07/schema#`
- Introduced in: `draft4`

A numeric instance is valid only if division by this keyword's value results in an integer.

The [`multipleOf`](multipleof.md) keyword
restricts number instances to be multiples of the given number. Note that the
number `0` is a multiple of every number, as for every number `k`, the
multiplication `0 * k` yield an integer value (in this case always 0). This case
is not to be confused with [division by
zero](https://en.wikipedia.org/wiki/Division_by_zero), which is not a permitted
operation in most computer systems.

> **Digging Deeper:**
> Setting this keyword to negative powers of 10, such as
> `0.01` (10^-2), `0.001` (10^-3), and `0.0001` (10^-4), is a common mechanism to
> control the maximum number of digits in the fractional part of a real number.
> For example, `1.2` and `-12.34` are multiples of `0.01`, but `1.234` is
> not.

> **Type constraint:** Non-`number` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains number instances to be multiples of the integer 5

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "multipleOf": 5
}
```

### Valid instance: An integer value that is a positive multiple of 5 is valid

```json
10
```

### Valid instance: An integer value that is a negative multiple of 5 is valid

```json
-5
```

### Valid instance: The real number representation of an integer value that is a positive multiple of 5 is valid

```json
15.0
```

### Invalid instance: An integer value that is not a multiple of 5 is invalid

```json
8
```

### Valid instance: The zero integer value is a multiple of every number

```json
0
```

### Valid instance: A non-number value is valid

```json
"100000"
```

### Schema: A schema that constrains number instances to be multiples of the real number 2.3

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "multipleOf": 2.3
}
```

### Valid instance: A number value that is a positive multiple of 2.3 is valid

```json
6.9
```

### Valid instance: A number value that is a negative multiple of 2.3 is valid

```json
-4.6
```

### Invalid instance: A number value that is not a multiple of 2.3 is invalid

```json
2.4
```

### Valid instance: The zero integer value is a multiple of every number

```json
0
```

### Valid instance: A non-number value is valid

```json
"100000"
```

### Schema: A schema that constrains number instances to have up to 2 digits in the fractional part

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "multipleOf": 0.01
}
```

### Valid instance: Any integer value is valid

```json
2
```

### Valid instance: A number value with 1 digit in the fractional part is valid

```json
5.1
```

### Valid instance: A number value with 2 digits in the fractional part is valid

```json
-12.34
```

### Invalid instance: A number value with 3 digits in the fractional part is invalid

```json
1.234
```

### Valid instance: The zero integer value is a multiple of every number

```json
0
```

### Valid instance: A non-number value is valid

```json
"100000"
```
