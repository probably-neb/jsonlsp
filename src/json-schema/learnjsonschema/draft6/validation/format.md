# format

- Original: [https://www.learnjsonschema.com/draft6/validation/format/](https://www.learnjsonschema.com/draft6/validation/format/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/format.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/format.markdown)
- Specification: [https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.8](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.8)
- Metaschema: `http://json-schema.org/draft-06/schema#`
- Introduced in: `draft1`

Define semantic information about a string instance.

The [`format`](format.md) keyword communicates
that string instances are of the given logical type.

> **Common Pitfall:**
>  By default, this keyword does not perform validation, as
> validating formats is considered optional by the official JSON Schema Test
> Suite. As a consequence, not many implementations support it. If validation is
> desired, the best practice is to combine this keyword with the [`pattern`](pattern.md) keyword. This guarantees interoperable
> and unambiguous behavior across JSON Schema implementations.

> **Best Practice:**
>  While [technically
> allowed](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.8)
> by the JSON Schema specification, extending this keyword with custom formats is
> considered to be an anti-pattern that can introduce interoperability issues and
> undefined behavior. As a best practice, stick to standardised formats. If
> needed, introduce a new keyword for custom string logical
> types.

> **Digging Deeper:**
>  This keyword and its validation guarantees are a common
> source of confusion of the JSON Schema specification across versions.
>
> Since the introduction of this keyword, the JSON Schema specifications
> clarified that validation was not mandatory. However, the majority of older
> Schema implementations did support validation, leading schema-writers to rely
> on it. At the same time, a second problem emerged: implementations often didn't
> agree on the strictness of validation, mainly on complex logical types like
> e-mail addresses, leading to various interoperability issues.
>
> To avoid the gray areas of this keyword, we recommend only treating it as
> semantic metadata, never enabling validation support at the implementation
> level (even if supported), and performing validation using the [`pattern`](pattern.md) keyword.  

The supported formats are the following.

| Format            | Category             | Specification |
|-------------------|----------------------|---------------|
| `"date-time"`     | Time                 | [JSON Schema Draft 6 Validation Section 8.3.1](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.8.3.1) |
| `"email"`         | Emails               | [JSON Schema Draft 6 Validation Section 8.3.2](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.8.3.2) |
| `"hostname"`      | Hostnames            | [JSON Schema Draft 6 Validation Section 8.3.3](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.8.3.3) |
| `"ipv4"`          | IP Addresses         | [JSON Schema Draft 6 Validation Section 8.3.4](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.8.3.4) |
| `"ipv6"`          | IP Addresses         | [JSON Schema Draft 6 Validation Section 8.3.5](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.8.3.5) |
| `"uri"`           | Resource Identifiers | [JSON Schema Draft 6 Validation Section 8.3.6](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.8.3.6) |
| `"uri-reference"` | Resource Identifiers | [JSON Schema Draft 6 Validation Section 8.3.7](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.8.3.7) |
| `"uri-template"`  | Resource Identifiers | [JSON Schema Draft 6 Validation Section 8.3.8](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.8.3.8) |
| `"json-pointer"`  | JSON Pointer         | [JSON Schema Draft 6 Validation Section 8.3.9](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.8.3.9) |

## Examples

### Schema: A schema that describes string instances as e-mail addresses

```json
{
  "$schema": "http://json-schema.org/draft-06/schema#",
  "format": "email"
}
```

### Valid instance: A string value that represents a valid e-mail address is valid

```json
"john.doe@example.com"
```

### Valid instance: A string value that represents an invalid e-mail address is typically valid (implementation dependent)

```json
"foo-bar"
```

### Valid instance: Any non-string value is valid

```json
45
```
