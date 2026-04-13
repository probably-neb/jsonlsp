# $vocabulary

- Original: [https://www.learnjsonschema.com/2020-12/core/vocabulary/](https://www.learnjsonschema.com/2020-12/core/vocabulary/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/core/vocabulary.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/core/vocabulary.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-core.html#section-8.1.2](https://json-schema.org/draft/2020-12/json-schema-core.html#section-8.1.2)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/core`
- Introduced in: `2019-09`

This keyword is used in dialect meta-schemas to identify the required and optional vocabularies available for use in schemas described by that dialect.

The [`$vocabulary`](vocabulary.md) keyword is a _mandatory_ component of a dialect meta-schema
to list the required and optional vocabularies available for use by the schema
instances of such dialect. The vocabularies declared by a dialect meta-schema
are not inherited by meta-schemas that derive from it. Each dialect meta-schema
must explicitly state the vocabularies it imports using the [`$vocabulary`](vocabulary.md)
keyword.

> **Common Pitfall:**
> Declaring the [`$vocabulary`](vocabulary.md) keyword in a schema does not
> grant that same schema access to such vocabularies. Instead, the [`$vocabulary`](vocabulary.md)
> keyword must be set in the dialect meta-schema that describes the desired
> schema.

If a vocabulary is marked as required, JSON Schema implementations that do not
recognise the given vocabulary must refuse to process schemas described by such
dialect. As a notable exception, every dialect must list the [Core](../core.md) vocabulary as required, as it is the foundational
vocabulary that implements the vocabulary system itself.

> **Digging Deeper:**
>  By convention, every official JSON Schema dialect defines a
> [dynamic anchor](dynamicanchor.md) called `meta`. This
> serves as an extensibility point for arbitrary vocabularies to register
> syntactic constraints that are automatically applied to every JSON Schema
> subschema apart from the top-level one.  

## Examples

### Schema: The seven required vocabularies declared by the JSON Schema 2020-12 official dialect

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://json-schema.org/draft/2020-12/schema",
  "$dynamicAnchor": "meta",
  "$vocabulary": {
    "https://json-schema.org/draft/2020-12/vocab/core": true,
    "https://json-schema.org/draft/2020-12/vocab/applicator": true,
    "https://json-schema.org/draft/2020-12/vocab/unevaluated": true,
    "https://json-schema.org/draft/2020-12/vocab/validation": true,
    "https://json-schema.org/draft/2020-12/vocab/meta-data": true,
    "https://json-schema.org/draft/2020-12/vocab/format-annotation": true,
    "https://json-schema.org/draft/2020-12/vocab/content": true
  },
  // ...
}
```

### Schema: An example dialect meta-schema that opts-in to the JSON Schema 2020-12 format assertion vocabulary

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://example.com/2020-12-with-format-assertion",
  "$dynamicAnchor": "meta",
  "$vocabulary": {
    "https://json-schema.org/draft/2020-12/vocab/core": true,
    "https://json-schema.org/draft/2020-12/vocab/applicator": true,
    "https://json-schema.org/draft/2020-12/vocab/unevaluated": true,
    "https://json-schema.org/draft/2020-12/vocab/validation": true,
    "https://json-schema.org/draft/2020-12/vocab/meta-data": true,
    "https://json-schema.org/draft/2020-12/vocab/format-assertion": true,
    "https://json-schema.org/draft/2020-12/vocab/content": true
  },
  "allOf": [
    { "$ref": "https://json-schema.org/draft/2020-12/meta/core" },
    { "$ref": "https://json-schema.org/draft/2020-12/meta/applicator" },
    { "$ref": "https://json-schema.org/draft/2020-12/meta/unevaluated" },
    { "$ref": "https://json-schema.org/draft/2020-12/meta/validation" },
    { "$ref": "https://json-schema.org/draft/2020-12/meta/meta-data" },
    { "$ref": "https://json-schema.org/draft/2020-12/meta/format-assertion" },
    { "$ref": "https://json-schema.org/draft/2020-12/meta/content" }
  ]
}
```

### Schema: An example dialect meta-schema that imports the Core vocabulary as required and the Validation vocabulary as optional

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://example.com/simple-2020-12",
  "$dynamicAnchor": "meta",
  "$vocabulary": {
    "https://json-schema.org/draft/2020-12/vocab/core": true,
    "https://json-schema.org/draft/2020-12/vocab/validation": false
  },
  "allOf": [
    { "$ref": "https://json-schema.org/draft/2020-12/meta/core" },
    { "$ref": "https://json-schema.org/draft/2020-12/meta/validation" }
  ]
}
```
