# maxItems

- Original: [https://www.learnjsonschema.com/draft3/core/maxitems/](https://www.learnjsonschema.com/draft3/core/maxitems/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft3/core/maxItems.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft3/core/maxItems.markdown)
- Specification: [https://json-schema.org/draft-03/draft-zyp-json-schema-03.pdf#5.14](https://json-schema.org/draft-03/draft-zyp-json-schema-03.pdf#5.14)
- Metaschema: `http://json-schema.org/draft-03/schema#`
- Introduced in: `draft1`

An array instance is valid if its size is less than, or equal to, the value of this keyword.

## Examples

### Schema: Schema with 'maxItems' keyword

```json
{
  "$schema": "http://json-schema.org/draft-03/schema#",
  "type": "array",
  "maxItems": 3,
  "items": {
    "type": "string"
  }
}
```

### Valid instance: An array instance with less than or equal to the maxItems value is valid

```json
["learn", "json", "schema"]
```

### Invalid instance: An array instance with greater than the maxItems value is invalid

```json
["learn", "json", "schema", "draft3"]
```
