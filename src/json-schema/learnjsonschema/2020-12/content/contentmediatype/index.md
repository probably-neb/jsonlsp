# contentMediaType

- Original: [https://www.learnjsonschema.com/2020-12/content/contentmediatype/](https://www.learnjsonschema.com/2020-12/content/contentmediatype/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/content/contentMediaType.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/content/contentMediaType.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-8.4](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-8.4)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/content`
- Introduced in: `draft7`

This keyword declares the media type of the string instance.

When the [`contentEncoding`](../contentencoding/index.md)
keyword is set, the [`contentMediaType`](../contentMediaType/index.md) keyword signifies that a string instance
value (such as a specific object property) should be considered binary data
that represents the given type. This keyword does not affect validation, but
the evaluator will collect its value as an annotation.  The use of this and
related keywords is a common technique to encode and describe arbitrary binary
data (such as image, audio, and video) in JSON.

> **Best Practice:**
> It is recommended to set this keyword along with the [`contentEncoding`](../contentencoding/index.md) keyword to declare the encoding used
> to serialised the data (for example, Base 64 encoding).  Otherwise, the
> receiver must treat the instance value as a binary blob without knowing for
> sure how to decode it.

> **Common Pitfall:**
> The JSON Schema specification prohibits implementations, for security reasons,
> from automatically attempting to decode, parse, or validate encoded data
> without the consumer explicitly opting in to such behaviour. If you require
> this feature, consult the documentation of your tooling of choice to see if it
> supports content encoding/decoding and how to enable it.

> **Digging Deeper:**
> This keyword is inspired by the
> [`Content-Type`](https://www.rfc-editor.org/rfc/rfc2045.html#section-5) MIME
> header used in conjunction with the
> [`Content-Transfer-Encoding`](https://www.rfc-editor.org/rfc/rfc2045.html#section-6)
> header to transmit non-ASCII data over e-mail. For example, if you send a PNG
> image as an e-mail attachment, your e-mail client will likely send a multipart
> message that includes the Base64-encoded image, sets the
> [`Content-Type`](https://www.rfc-editor.org/rfc/rfc2045.html#section-5) header
> to [`image/png`](https://www.iana.org/assignments/media-types/image/png), and
> sets the
> [`Content-Transfer-Encoding`](https://www.rfc-editor.org/rfc/rfc2045.html#section-6)
> header to
> [`base64`](https://datatracker.ietf.org/doc/html/rfc2045#section-6.1).

The Internet Assigned Numbers Authority (IANA) standards organization is the
source of truth for the exhaustive official list of registered content media
types. You can find the complete list at
[https://www.iana.org/assignments/media-types/media-types.xhtml](https://www.iana.org/assignments/media-types/media-types.xhtml).

In the interest of interoperability, avoid using custom unregistered content
media types. If required, register a new content media type with the IANA
[here](https://www.iana.org/form/media-types).  Alternatively, [RFC 2046
Section 6](https://datatracker.ietf.org/doc/html/rfc2046#section-6) suggests
that if a custom unregistered content media type is really needed, it must live
within a registered category and prefixed with `x-`.  For example,
`application/x-my-custom-media-type`.

> **Type constraint:** Non-`string` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that describes HTML data encoded using Base 64

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "contentEncoding": "base64",
  "contentMediaType": "text/html"
}
```

### Valid instance: A string value that represents a valid HTML document encoded in Base 64 is valid and an annotations are emitted

```json
"PHA+SlNPTiBTY2hlbWE8L3A+" // <p>JSON Schema</p>
```

### Annotation

```json
{ "keyword": "/contentEncoding", "instance": "", "value": "base64" }
{ "keyword": "/contentMediaType", "instance": "", "value": "text/html" }
```

### Valid instance: A string value that represents an invalid HTML document encoded in Base 64 is valid and an annotations are still emitted

```json
"PFwvZm9v" // <\/foo
```

### Annotation

```json
{ "keyword": "/contentEncoding", "instance": "", "value": "base64" }
{ "keyword": "/contentMediaType", "instance": "", "value": "application/json" }
```

### Valid instance: A non-string value is valid but no annotations are emitted

```json
1234
```
