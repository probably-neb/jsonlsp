# default

- Original: [https://www.learnjsonschema.com/2020-12/meta-data/default/](https://www.learnjsonschema.com/2020-12/meta-data/default/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/meta-data/default.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/meta-data/default.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-9.2](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-9.2)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/meta-data`
- Introduced in: `draft1`

This keyword can be used to supply a default JSON value associated with a particular schema.

The [`default`](default.md) keyword declares a default instance value for a schema or any of
its subschemas, typically to support specialised tooling like documentation and
form generators. This keyword does not affect validation, but the evaluator
will collect its value as an annotation.

> **Common Pitfall:**
> The standard evaluation process will not automatically use these values to fill
> in missing parts of the instance. Furthermore, the JSON Schema specification
> does not provide any guidance on how this keyword should be used.
>
> Consult the documentation of any JSON Schema tooling you rely on to check if
> and how it makes use of this keyword.

> **Best Practice:**
> Meta-schema validation will not check that the default values you declare are
> actually valid against their respective schemas, as JSON Schema does not offer
> a mechanism for meta-schemas to declare that instances validate against parts
> of the same instance being evaluated. As a consequence, it is not rare for
> schemas to declare invalid default values that go undetected for a long time.
>
> It is recommended to use the [`jsonschema
> lint`](https://github.com/sourcemeta/jsonschema/blob/main/docs/lint.markdown)
> command, as this linter performs further checks to detect many corner cases,
> including this one.

> **Digging Deeper:**
> You might be tempted to evaluate a schema against an instance and rely on
> [`default`](default.md) annotations to feed back the missing values back to it.  However,
> there is a known limitation that prevents this approach: in JSON Schema,
> annotations are collected when a subschema is evaluated, which means that the
> default value annotation is only emitted when the corresponding instance
> location is present (and thus a default value is not required).
>
> There is a
> [discussion](https://github.com/json-schema-org/json-schema-spec/issues/867) to
> introduce new variants of this keyword (`propertyDefaults` and `itemDefaults`)
> to properly support this use case.

## Examples

### Schema: A schema that declares top level and nested default values

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "default": {},
  "properties": {
    "language": { "default": "en" },
    "notifications": { "default": true }
  }
}
```

### Valid instance: An object value that defines both properties is valid and annotations are emitted

```json
{ "language": "es", "notifications": false }
```

### Annotation

```json
{ "keyword": "/default", "instance": "", "value": {} }
{ "keyword": "/properties/language/default", "instance": "/language", "value": "en" }
{ "keyword": "/properties/notifications/default", "instance": "/notifications", "value": true }
```

### Valid instance: An object value that omits both properties is valid but their default values are (perhaps counter-intuitively) not emitted

```json
{}
```

### Annotation

```json
{ "keyword": "/default", "instance": "", "value": {} }
```

### Invalid instance: A non-object value is invalid and no annotations are emitted

```json
"Hello World"
```

### Schema: A schema that declares multiple default values for the same instance location

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "properties": {
    "email": {
      "default": "johndoe@acme.com",
      "$ref": "#/$defs/email-address"
    }
  },
  "$defs": {
    "email-address": {
      "type": "string",
      "format": "email",
      "default": "example@example.org"
    }
  }
}
```

### Valid instance: An object value that defines an email property is valid and both annotations are emitted

```json
{ "email": "jane@foo.com" }
```

### Annotation

```json
{ "keyword": "/properties/email/default", "instance": "/email", "value": "johndoe@acme.com" }
{ "keyword": "/$defs/email-address/default", "instance": "/email", "value": "example@example.org" }
```

### Valid instance: An object value that omits the email property is valid but the default values are (perhaps counter-intuitively) not emitted

```json
{}
```

### Invalid instance: An object value with a non-string email property is invalid and no annotations are emitted

```json
{ "email": 1 }
```
