# minLength

- Original: [https://www.learnjsonschema.com/2020-12/validation/minlength/](https://www.learnjsonschema.com/2020-12/validation/minlength/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/validation/minLength.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/validation/minLength.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-6.3.2](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-6.3.2)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/validation`
- Introduced in: `draft1`

A string instance is valid against this keyword if its length is greater than, or equal to, the value of this keyword.

The [`minLength`](minLength.md) keyword restricts string instances to consists of an inclusive
minimum number of [Unicode](https://unicode.org) code-points (logical
characters), which is not necessarily the same as the number of bytes in the
string.

> **Digging Deeper:**
>  While the [IETF RFC
> 8259](https://www.rfc-editor.org/rfc/rfc8259) JSON standard recommends the use
> of [UTF-8](https://en.wikipedia.org/wiki/UTF-8), other Unicode encodings are
> permitted. Therefore a JSON string may be represented in more bytes than its
> number of code-points.
>
> JSON Schema does not provide a mechanism to assert on the byte size of a JSON
> string, as this is an implementation-dependent property of the JSON parser in
> use.  

> **Type constraint:** Non-`string` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains string instances to contain at least 3 code points

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "minLength": 3
}
```

### Valid instance: A string value that consists of 3 code-points is valid

```json
"foo"
```

### Valid instance: A string value that consists of more than 3 code-points is valid

```json
"こんにちは"
```

### Invalid instance: A string value that consists of less than 3 code-points is invalid

```json
"hi"
```

### Valid instance: A non-string value is valid

```json
55
```
