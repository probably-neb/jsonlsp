# examples

- Original: [https://www.learnjsonschema.com/2020-12/meta-data/examples/](https://www.learnjsonschema.com/2020-12/meta-data/examples/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/meta-data/examples.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/meta-data/examples.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-9.5](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-9.5)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/meta-data`
- Introduced in: `draft6`

This keyword is used to provide sample JSON values associated with a particular schema, for the purpose of illustrating usage.

The [`examples`](examples.md) keyword declares a set of example instances for a schema or any
of its subschemas, typically for documentation purposes. This keyword does not
affect validation, but the evaluator will collect its set of values as an
annotation.

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
  "$schema": "https://json-schema.org/draft/2020-12/schema",
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

### Valid instance: An object value that defines name and age is valid and the corresponding annotations are emitted

```json
{ "name": "Juan Cruz Viotti", "age": 30 }
```

### Annotation

```json
{ "keyword": "/examples", "instance": "", "value": [ { "name": "John Doe", "age": 23 } ] }
{ "keyword": "/properties/name/examples", "instance": "/name", "value": [ "John Doe", "Jane Doe" ] }
{ "keyword": "/properties/age/examples", "instance": "/age", "value": [ 1, 18, 55 ] }
```

### Valid instance: An object value that omits some properties is valid and only the corresponding annotations are emitted

```json
{ "age": 50 }
```

### Annotation

```json
{ "keyword": "/examples", "instance": "", "value": [ { "name": "John Doe", "age": 23 } ] }
{ "keyword": "/properties/age/examples", "instance": "/age", "value": [ 1, 18, 55 ] }
```

### Invalid instance: A value that does not match the schema is invalid and no annotations are emitted

```json
{ "name": 1, "age": true }
```
