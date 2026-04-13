# default

- Original: [https://www.learnjsonschema.com/draft6/validation/default/](https://www.learnjsonschema.com/draft6/validation/default/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/default.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/default.markdown)
- Specification: [https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.7.3](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.7.3)
- Metaschema: `http://json-schema.org/draft-06/schema#`
- Introduced in: `draft1`

This keyword can be used to supply a default JSON value associated with a particular schema.

The [`default`](default.md) keyword declares a
default instance value for a schema or any of its subschemas, typically to
support specialised tooling like documentation and form generators. This
keyword is merely descriptive and does not affect validation.

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

## Examples

### Schema: A schema that declares top level and nested default values

```json
{
  "$schema": "http://json-schema.org/draft-06/schema#",
  "type": "object",
  "default": {},
  "properties": {
    "language": { "default": "en" },
    "notifications": { "default": true }
  }
}
```

### Valid instance: An object value that defines both properties is valid

```json
{ "language": "es", "notifications": false }
```

### Valid instance: An object value that omits both properties is valid

```json
{}
```

### Invalid instance: A non-object value is invalid

```json
"Hello World"
```

### Schema: A schema that declares multiple default values for the same instance location

```json
{
  "$schema": "http://json-schema.org/draft-06/schema#",
  "properties": {
    "email": {
      "default": "johndoe@acme.com",
      "$ref": "#/definitions/email-address"
    }
  },
  "definitions": {
    "email-address": {
      "type": "string",
      "format": "email",
      "default": "example@example.org"
    }
  }
}
```

### Valid instance: An object value that defines an email property is valid

```json
{ "email": "jane@foo.com" }
```

### Valid instance: An object value that omits the email property is valid

```json
{}
```

### Invalid instance: An object value with a non-string email property is invalid

```json
{ "email": 1 }
```
