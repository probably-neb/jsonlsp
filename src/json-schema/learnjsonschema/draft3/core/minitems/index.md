# minItems

- Original: [https://www.learnjsonschema.com/draft3/core/minitems/](https://www.learnjsonschema.com/draft3/core/minitems/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft3/core/minItems.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft3/core/minItems.markdown)
- Specification: [https://json-schema.org/draft-03/draft-zyp-json-schema-03.pdf#5.13](https://json-schema.org/draft-03/draft-zyp-json-schema-03.pdf#5.13)
- Metaschema: `http://json-schema.org/draft-03/schema#`
- Introduced in: `draft1`

An array instance is valid if its size is greater than, or equal to, the value of this keyword.

## Examples

### Schema: Schema with 'minItems' keyword

```json
{
  "$schema": "http://json-schema.org/draft-03/schema#",
  "type": "array",
  "minItems": 1,
  "items": {
    "type": "string"
  }
}
```

### Valid instance: An array instance with greater than or equal to the minItems value is valid

```json
["learn"]
```

### Invalid instance: An array instance with less than the minItems value is invalid

```json
[]
```
