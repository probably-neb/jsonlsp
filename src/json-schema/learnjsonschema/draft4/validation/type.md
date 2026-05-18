# type

- Original: [https://www.learnjsonschema.com/draft4/validation/type/](https://www.learnjsonschema.com/draft4/validation/type/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/type.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/type.markdown)
- Specification: [https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.5.2](https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.5.2)
- Metaschema: `http://json-schema.org/draft-04/schema#`
- Introduced in: `draft1`

Validation succeeds if the type of the instance matches the type represented by the given type, or matches at least one of the given types.
The supported types are the following. Note that while the [ECMA
404](https://ecma-international.org/publications-and-standards/standards/ecma-404/)
JSON standard defines the JSON grammar without mention of encodings, the [IETF
RFC 8259](https://www.rfc-editor.org/rfc/rfc8259) JSON standard provides
specific guidance for JSON numbers and JSON strings which are documented in the
*Interoperable Encoding* column. Other encodings will likely not be accepted by
JSON parsers.

| Type        | Description                              | Interoperable Encoding                                                                                   |
|-------------|------------------------------------------|----------------------------------------------------------------------------------------------------------|
| `"null"`    | The JSON null constant                   | N/A                                                                                                      |
| `"boolean"` | The JSON true or false constants         | N/A                                                                                                      |
| `"object"`  | A JSON object                            | N/A                                                                                                      |
| `"array"`   | A JSON array                             | N/A                                                                                                      |
| `"number"`  | A JSON number                            | [IEEE 764](https://ieeexplore.ieee.org/document/8766229) 64-bit double-precision floating point encoding (except `NaN`, `Infinity`, and `+0`) |
| `"integer"` | A JSON number _without a fractional component_ | 64-bit signed integer encoding (from `-(2^53)+1` to `(2^53)-1`)                                          |
| `"string"`  | A JSON string                            | [UTF-8](https://en.wikipedia.org/wiki/UTF-8) Unicode encoding                                            |

> **Common Pitfall:**
>  The `integer` logical type does not consider real numbers
> with a zero fractional component as integers. For example, `2` is considered to
> be an integer, but `2.0` is not.

Note that while the JSON grammar does not distinguish between integer and real
numbers, JSON Schema provides the `integer` logical type that matches numbers
without a fractional component.  Additionally, numeric constructs inherent to
floating point encodings (like `NaN` and `Infinity`) are not permitted in JSON.
However, the negative zero (`-0`) is permitted.

> **Best Practice:**
>  To avoid interoperability issues, do not produce JSON
> documents with numbers that exceed the [IETF RFC
> 8259](https://www.rfc-editor.org/rfc/rfc8259) limits described in the
> *Interoperable Encodings* column of the table above.
>
> If more numeric precision is required, consider representing numbers as JSON
> strings or as multiple numbers. For example, fixed-precision real numbers can
> be represented as an array of two integers for the integral and fractional
> components.

> **Common Pitfall:**
>  The JavaScript programming language (and by extension
> languages such as TypeScript) represent all numbers, including integers, using
> the [IEEE 764](https://ieeexplore.ieee.org/document/8766229) floating-point
> encoding. As a result, parsing JSON documents with integers beyond the 53-bit
> range is prone to precision problems. Read [How numbers are encoded in
> JavaScript](https://2ality.com/2012/04/number-encoding.html) by Dr. Axel
> Rauschmayer for a more detailed overview of JavaScript's numeric
> limitations.

> **Digging Deeper:**
> JSON allows numbers to be represented in [scientific
> exponential
> notation](https://en.wikipedia.org/wiki/Scientific_notation#E_notation). For
> example, numbers like `1.0e+28` (equivalent to 10000000000000000000000000000.0)
> are valid according to the JSON grammar. This notation is convenient for
> expressing long numbers. However, be careful with not accidentally exceeding
> the interoperable limits described by the [IETF RFC
> 8259](https://www.rfc-editor.org/rfc/rfc8259) JSON
> standard.

## Examples

### Schema: A schema that describes numeric instances

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "number"
}
```

### Valid instance: An integer is valid

```json
42
```

### Valid instance: A real number is valid

```json
3.14
```

### Valid instance: A number in scientific exponential notation is valid

```json
1.0e+28
```

### Invalid instance: A string is not valid

```json
"foo"
```

### Schema: A schema that describes boolean or array instances

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": [ "boolean", "array" ]
}
```

### Valid instance: The true boolean is valid

```json
true
```

### Invalid instance: A number is invalid

```json
1234
```

### Valid instance: An arbitrary array is valid

```json
[ 1, 2, 3 ]
```

### Schema: A schema that describes integer instances

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "integer"
}
```

### Valid instance: An integer is valid

```json
42
```

### Invalid instance: A real number with a zero fractional component is invalid

```json
3.0
```

### Invalid instance: A real number with a non-zero fractional component is invalid

```json
3.14
```
