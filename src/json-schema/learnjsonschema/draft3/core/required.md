# required

- Original: [https://www.learnjsonschema.com/draft3/core/required/](https://www.learnjsonschema.com/draft3/core/required/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft3/core/required.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft3/core/required.markdown)
- Specification: [https://json-schema.org/draft-03/draft-zyp-json-schema-03.pdf#5.7](https://json-schema.org/draft-03/draft-zyp-json-schema-03.pdf#5.7)
- Metaschema: `http://json-schema.org/draft-03/schema#`
- Introduced in: `draft3`

An object instance is valid if the name of the required property exists in the instance.
## Examples

### Schema: Schema with 'required' keyword

```json
{
  "$schema": "http://json-schema.org/draft-03/schema#",
  "type": "object",
  "properties": { 
    "person": {
        "type": "string",
        "required": true
    }
  }
}
```

### Valid instance: An object instance with the required property defined is valid

```json
{ "person": "John Doe" }
```

### Invalid instance: An object instance not containing the required property is invalid

```json
{ "age": 10 }
```
