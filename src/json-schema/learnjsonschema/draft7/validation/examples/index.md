# examples

- Original: [https://www.learnjsonschema.com/draft7/validation/examples/](https://www.learnjsonschema.com/draft7/validation/examples/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/examples.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/examples.markdown)
- Specification: [https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.10.4](https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.10.4)
- Metaschema: `http://json-schema.org/draft-07/schema#`
- Introduced in: `draft6`

This keyword is used to provide sample JSON values associated with a particular schema, for the purpose of illustrating usage.

The [`examples`](index.md) keyword declares a
set of example instances for a schema or any of its subschemas, typically for
documentation purposes. This keyword is merely descriptive and does not affect
validation.

> **Best Practice:**
> Meta-schema validation will not check that the examples you declare are
> actually valid against their respective schemas, as JSON Schema does not offer
> a mechanism for meta-schemas to declare that instances validate against parts
> of the same instance being evaluated. As a consequence, it is not rare for
> schemas to declare invalid examples that go undetected for a long time.
>
> It is recommended to use the [`jsonschema
> lint`](https://github.com/sourcemeta/jsonschema/blob/main/docs/lint.markdown)
> command, as this linter performs further checks to detect many corner cases,
> including this one.

## Examples

### Schema: A schema that describes name and age properties and declares top level and nested valid examples

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "examples": [
    { "name": "John Doe", "age": 23 }
  ],
  "properties": {
    "name": {
      "type": "string",
      "examples": [ "John Doe", "Jane Doe" ]
    },
    "age": {
      "type": "integer",
      "examples": [ 1, 18, 55 ]
    }
  }
}
```

### Valid instance: An object value that defines name and age is valid

```json
{ "name": "Juan Cruz Viotti", "age": 30 }
```

### Valid instance: An object value that omits some properties is valid

```json
{ "age": 50 }
```

### Invalid instance: A value that does not match the schema is invalid

```json
{ "name": 1, "age": true }
```
