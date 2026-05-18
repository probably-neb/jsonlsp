# exclusiveMinimum

- Original: [https://www.learnjsonschema.com/draft3/core/exclusiveminimum/](https://www.learnjsonschema.com/draft3/core/exclusiveminimum/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft3/core/exclusiveMinimum.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft3/core/exclusiveMinimum.markdown)
- Specification: [https://json-schema.org/draft-03/draft-zyp-json-schema-03.pdf#5.11](https://json-schema.org/draft-03/draft-zyp-json-schema-03.pdf#5.11)
- Metaschema: `http://json-schema.org/draft-03/schema#`
- Introduced in: `draft3`

When [`minimum`](/draft3/core/minimum) is present and this keyword is set to true, the numeric instance must be greater than the value in [`minimum`](/draft3/core/minimum).
## Examples

### Schema: Schema with 'exclusiveMinimum' keyword

```json
{
  "$schema": "http://json-schema.org/draft-03/schema#",
  "type": "number",
  "minimum": 1.1,
  "exclusiveMinimum": true
}
```

### Valid instance: A numeric instance greater than the minimum with the exclusiveMinimum keyword defined is valid

```json
1.2
```

### Invalid instance: A numeric instance less than or equal to the minimum with the exclusiveMinimum keyword defined is invalid

```json
1.1
```
