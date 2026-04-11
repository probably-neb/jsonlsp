# deprecated

- Original: [https://www.learnjsonschema.com/2020-12/meta-data/deprecated/](https://www.learnjsonschema.com/2020-12/meta-data/deprecated/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/meta-data/deprecated.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/meta-data/deprecated.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-9.3](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-9.3)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/meta-data`
- Introduced in: `2019-09`

This keyword indicates that applications should refrain from using the declared property.

The [`deprecated`](index.md) keyword, when set to `true`, signifies that an instance value
(such as a specific object property) should not be used and may be removed or
rejected in the future. This keyword does not affect validation, but the
evaluator will collect its value as an annotation.

> **Best Practice:**
> Avoid setting this keyword to the default value `false`. If an instance value
> is not considered to be deprecated, the best practice is to omit the use of
> this keyword altogether. This prevents unnecessarily generating and collecting
> an annotation that does not carry any additional meaning.

> **Common Pitfall:**
> Tooling makers must be careful when statically traversing schemas in search of
> occurrences of this keyword. It is possible for schemas to make use of this
> keyword behind conditional operators, references, or any other type of keyword
> that makes it hard or even impossible to correctly locate these values without
> fully evaluating the schema against an instance. The only bullet proof method
> is through annotation collection.
>
> For example, an instance property might only be deprecated under certain
> conditions determined by a dynamic operator like [`anyOf`](../../applicator/anyof/index.md).

## Examples

### Schema: A schema that statically marks the city optional object property as deprecated

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "properties": {
    "country": { "type": "string" },
    "city": { "type": "string", "deprecated": true }
  }
}
```

### Valid instance: An object value that defines the deprecated property is valid but an annotation is emitted

```json
{ "country": "United Kingdom", "city": "London" }
```

### Annotation

```json
{ "keyword": "/properties/city/deprecated", "instance": "/city", "value": true }
```

### Valid instance: An object value that does not define the deprecated property is valid and no annotation is emitted

```json
{ "country": "United Kingdom" }
```

### Invalid instance: An object value that does not match the schema is invalid and no annotations are emitted

```json
{ "city": 1 }
```

### Schema: A schema that dynamically marks the city optional object property as deprecated based on the presence of the country property

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "properties": {
    "country": { "type": "string" },
    "city": { "type": "string" }
  },
  "dependentSchemas": {
    "country": {
      "properties": { "city": { "deprecated": true } }
    }
  }
}
```

### Valid instance: An object value that defines both properties is valid but an annotation is emitted

```json
{ "country": "United Kingdom", "city": "London" }
```

### Annotation

```json
{ "keyword": "/dependentSchemas/country/properties/city/deprecated", "instance": "/city", "value": true }
```

### Valid instance: An object value that only defines the city property is valid and no annotation is emitted

```json
{ "city": "London" }
```

### Valid instance: An object value that only defines the country property is valid and no annotation is emitted

```json
{ "country": "United Kingdom" }
```

### Invalid instance: An object value that does not match the schema is invalid and no annotations are emitted

```json
{ "city": 1 }
```
