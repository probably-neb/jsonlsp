# format

- Original: [https://www.learnjsonschema.com/2020-12/format-assertion/format/](https://www.learnjsonschema.com/2020-12/format-assertion/format/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/format-assertion/format.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/format-assertion/format.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.2.2](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.2.2)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/format-assertion`
- Introduced in: `draft1`

Define and assert semantic information about a string instance.

The [`format`](../format-annotation/format.md) keyword restricts string instances to the given logical type and
produces an annotation value.

However, this vocabulary is not used by default in the JSON Schema 2020-12
dialect. To use it, a custom dialect that includes this vocabulary is required.
As a consequence, not many JSON Schema implementations support it. In most
cases, it is advised to stick to the [`Format-Annotation`](../format-annotation/format.md) variant of this keyword.

> **Best Practice:**
>  While [technically
> allowed](https://json-schema.org/draft/2020-12/json-schema-validation#section-7.2.3)
> by the JSON Schema specification, extending this keyword with custom formats is
> considered to be an anti-pattern that can introduce interoperability issues and
> undefined behavior. As a best practice, stick to standardised formats. If
> needed, introduce a new keyword for custom string logical
> types.

The supported formats are the following.

| Format                    | Category             | Specification |
|---------------------------|----------------------|---------------|
| `"date-time"`             | Time                 | [JSON Schema 2020-12 Validation Section 7.3.1](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.1) |
| `"date"`                  | Time                 | [JSON Schema 2020-12 Validation Section 7.3.1](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.1) |
| `"time"`                  | Time                 | [JSON Schema 2020-12 Validation Section 7.3.1](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.1) |
| `"duration"`              | Time                 | [JSON Schema 2020-12 Validation Section 7.3.1](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.1) |
| `"email"`                 | Emails               | [JSON Schema 2020-12 Validation Section 7.3.2](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.2) |
| `"idn-email"`             | Emails               | [JSON Schema 2020-12 Validation Section 7.3.2](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.2) |
| `"hostname"`              | Hostnames            | [JSON Schema 2020-12 Validation Section 7.3.3](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.3) |
| `"idn-hostname"`          | Hostnames            | [JSON Schema 2020-12 Validation Section 7.3.3](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.3) |
| `"ipv4"`                  | IP Addresses         | [JSON Schema 2020-12 Validation Section 7.3.4](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.4) |
| `"ipv6"`                  | IP Addresses         | [JSON Schema 2020-12 Validation Section 7.3.4](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.4) |
| `"uri"`                   | Resource Identifiers | [JSON Schema 2020-12 Validation Section 7.3.5](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.5) |
| `"uri-reference"`         | Resource Identifiers | [JSON Schema 2020-12 Validation Section 7.3.5](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.5) |
| `"iri"`                   | Resource Identifiers | [JSON Schema 2020-12 Validation Section 7.3.5](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.5) |
| `"iri-reference"`         | Resource Identifiers | [JSON Schema 2020-12 Validation Section 7.3.5](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.5) |
| `"uuid"`                  | Resource Identifiers | [JSON Schema 2020-12 Validation Section 7.3.5](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.5) |
| `"uri-template"`          | Resource Identifiers | [JSON Schema 2020-12 Validation Section 7.3.6](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.6) |
| `"json-pointer"`          | JSON Pointer         | [JSON Schema 2020-12 Validation Section 7.3.7](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.7) |
| `"relative-json-pointer"` | JSON Pointer         | [JSON Schema 2020-12 Validation Section 7.3.7](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.7) |
| `"regex"`                 | Regular Expressions  | [JSON Schema 2020-12 Validation Section 7.3.8](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-7.3.8) |

> **Type constraint:** Non-`string` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A custom dialect meta-schema that opts-in to the Format Assertion vocabulary

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://example.com/my-dialect",
  "$dynamicAnchor": "meta",
  "$vocabulary": {
    "https://json-schema.org/draft/2020-12/vocab/core": true,
    "https://json-schema.org/draft/2020-12/vocab/format-assertion": true
  },
  "allOf": [
    { "$ref": "https://json-schema.org/draft/2020-12/meta/core" },
    { "$ref": "https://json-schema.org/draft/2020-12/meta/format-assertion" }
  ]
}
```

### Schema: A schema that validates string instances as e-mail addresses

```json
{
  "$schema": "https://example.com/custom-meta-schema",
  "format": "email"
}
```

### Valid instance: A string value that represents a valid e-mail address is valid

```json
"john.doe@example.com"
```

### Annotation

```json
{ "keyword": "/format", "instance": "", "value": "email" }
```

### Invalid instance: A string value that represents an invalid e-mail address is invalid

```json
"foo-bar"
```

### Valid instance: Any non-string value is valid but no annotation is produced

```json
45
```
