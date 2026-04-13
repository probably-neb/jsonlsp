# maxLength

- Original: [https://www.learnjsonschema.com/draft6/validation/maxlength/](https://www.learnjsonschema.com/draft6/validation/maxlength/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/maxLength.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/maxLength.markdown)
- Specification: [https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.6.6](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.6.6)
- Metaschema: `http://json-schema.org/draft-06/schema#`
- Introduced in: `draft1`

A string instance is valid against this keyword if its length is less than, or equal to, the value of this keyword.

The [`maxLength`](maxlength.md) keyword restricts string instances to consists of an inclusive
maximum number of [Unicode](https://unicode.org) code-points (logical
characters), which is not necessarily the same as the number of bytes in the
string.

> **Digging Deeper:**
>  While the [IETF RFC
> 8259](https://www.rfc-editor.org/rfc/rfc8259) JSON standard recommends the use
> of [UTF-8](https://en.wikipedia.org/wiki/UTF-8), other Unicode encodings are
> permitted. Therefore a JSON string may be represented in up to 4x the number of
> bytes as its number of code-points (assuming
> [UTF-32](https://en.wikipedia.org/wiki/UTF-32) as the upper bound).
>
> JSON Schema does not provide a mechanism to assert on the byte size of a JSON
> string, as this is an implementation-dependent property of the JSON parser in
> use.  

> **Common Pitfall:**
>  Be careful when making use of this keyword to
> inadvertently assert on the byte length of JSON strings before inserting them
> into byte-sensitive destinations like fixed-size buffers. Always assume that
> the byte length of a JSON string can arbitrary larger that the number of
> logical characters.

> **Best Practice:**
> To restrict string instances to the empty string, prefer
> using the [`const`](const.md) keyword instead of
> setting this keyword to `0`. 

> **Type constraint:** Non-`string` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains string instances to contain at most 3 code points

```json
{
  "$schema": "http://json-schema.org/draft-06/schema#",
  "maxLength": 3
}
```

### Valid instance: A string value that consists of 3 code-points is valid

```json
"foo"
```

### Invalid instance: A string value that consists of more than 3 code-points is invalid

```json
"こんにちは"
```

### Valid instance: A string value that consists of less than 3 code-points is valid

```json
"hi"
```

### Valid instance: A non-string value is valid

```json
55
```
