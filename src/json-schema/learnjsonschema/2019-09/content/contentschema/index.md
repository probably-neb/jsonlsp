# contentSchema

- Original: [https://www.learnjsonschema.com/2019-09/content/contentschema/](https://www.learnjsonschema.com/2019-09/content/contentschema/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/content/contentSchema.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/content/contentSchema.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.8.5](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.8.5)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/content`
- Introduced in: `2019-09`

This keyword declares a schema which describes the structure of the string.

When the [`contentMediaType`](../contentmediatype/index.md)
keyword is set to a media type that adheres to the JSON data model (like JSON
itself, [YAML](https://yaml.org) or [UBJSON](https://ubjson.org)), the
[`contentSchema`](index.md) keyword declares the schema that describes the corresponding
string instance value _after_ decoding it. This keyword does not affect
validation, but the evaluator will collect its value as an annotation.

> **Common Pitfall:**
> The JSON Schema specification prohibits implementations, for security reasons,
> from automatically attempting to decode, parse, or validate encoded data
> without the consumer explicitly opting in to such behaviour. If you require
> this feature, consult the documentation of your tooling of choice to see if it
> supports content encoding/decoding and how to enable it.

> **Type constraint:** Non-`string` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that describes JSON object values encoded using Base 64

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "contentMediaType": "application/json",
  "contentEncoding": "base64",
  "contentSchema": { "type": "object" }
}
```

### Valid instance: A string value that represents a valid JSON object encoded in Base 64 is valid and an annotations are emitted

```json
"eyAibmFtZSI6ICJKb2huIERvZSIgfQ==" // { "name": "John Doe" }
```

### Annotation

```json
{ "keyword": "/contentMediaType", "instance": "", "value": "application/json" }
{ "keyword": "/contentEncoding", "instance": "", "value": "base64" }
{ "keyword": "/contentSchema", "instance": "", "value": { "type": "object" } }
```

### Valid instance: A string value that represents an invalid JSON object encoded in Base 64 is valid and an annotations are still emitted

```json
"eyAibmFtZSI6IH0=" // { "name": }
```

### Annotation

```json
{ "keyword": "/contentMediaType", "instance": "", "value": "application/json" }
{ "keyword": "/contentEncoding", "instance": "", "value": "base64" }
{ "keyword": "/contentSchema", "instance": "", "value": { "type": "object" } }
```

### Valid instance: A string value that represents a valid JSON number encoded in Base 64 is valid and an annotations are still emitted

```json
"MTIzNA==" // 1234
```

### Annotation

```json
{ "keyword": "/contentMediaType", "instance": "", "value": "application/json" }
{ "keyword": "/contentEncoding", "instance": "", "value": "base64" }
{ "keyword": "/contentSchema", "instance": "", "value": { "type": "object" } }
```

### Valid instance: A non-string value is valid but no annotations are emitted

```json
1234
```
