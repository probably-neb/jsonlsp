# exclusiveMaximum

- Original: [https://www.learnjsonschema.com/draft3/core/exclusivemaximum/](https://www.learnjsonschema.com/draft3/core/exclusivemaximum/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft3/core/exclusiveMaximum.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft3/core/exclusiveMaximum.markdown)
- Specification: [https://json-schema.org/draft-03/draft-zyp-json-schema-03.pdf#5.12](https://json-schema.org/draft-03/draft-zyp-json-schema-03.pdf#5.12)
- Metaschema: `http://json-schema.org/draft-03/schema#`
- Introduced in: `draft3`

When [`maximum`](/draft3/core/maximum) is present and this keyword is set to true, the numeric instance must be less than the value in [`maximum`](/draft3/core/maximum).
## Examples

### Schema: Schema with 'exclusiveMaximum' keyword

```json
{
  "$schema": "http://json-schema.org/draft-03/schema#",
  "type": "number",
  "maximum": 3.0,
  "exclusiveMaximum": true
}
```

### Valid instance: A numeric instance less than the maximum with the exclusiveMaximum keyword defined is valid

```json
2.2
```

### Invalid instance: A numeric instance greater than or equal to the maximum with the exclusiveMaximum keyword defined is invalid

```json
3.0
```
