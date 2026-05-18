# definitions

- Original: [https://www.learnjsonschema.com/draft4/validation/definitions/](https://www.learnjsonschema.com/draft4/validation/definitions/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/definitions.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/definitions.markdown)
- Specification: [https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.5.7](https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.5.7)
- Metaschema: `http://json-schema.org/draft-04/schema#`
- Introduced in: `draft4`

This keyword reserves a location for schema authors to inline reusable JSON Schemas into a more general schema.
The [`definitions`](definitions.md) keyword is a
container for storing reusable schemas within a schema resource, which can be
referenced using the [`$ref`](../core/ref.md) keyword. From a
software engineering point of view, this keyword is analogous to defining
_internal_ helper functions as part of a larger program.

> **Best Practice:**
> Use this keyword to reduce duplication of internal declarations within a
> schema. However, **prefer extracting standalone entities that represent more
> than just internal helpers into separate schema files**, and externally
> referencing them instead. Otherwise, you will end up with big monolithic
> schemas that are challenging to understand and maintain.
>
> If you need to resolve external references in advance (for distribution or
> analysis), look at the [`jsonschema
> bundle`](https://github.com/sourcemeta/jsonschema/blob/main/docs/bundle.markdown)
> command.

> **Common Pitfall:**
> This keyword declares helper schemas for use _within_ the same schema file or
> resource.  Defining schema files or resources that use this keyword (and
> typically no other keyword) to group common definitions for _other_ schema
> files or resources to reference is considered to be an anti-pattern. If you
> want to share a schema across multiple schema files or resources, that common
> schema should be a standalone schema file or resource itself.

## Examples

### Schema: A schema that declares a helper schema to reduce duplication when defining multiple properties

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "properties": {
    "firstName": { "$ref": "#/definitions/nonEmptyString" },
    "lastName": { "$ref": "#/definitions/nonEmptyString" }
  },
  "definitions": {
    "nonEmptyString": {
      "type": "string",
      "minLength": 1
    }
  }
}
```

### Valid instance: An object value with non-empty first and last names is valid

```json
{ "firstName": "John", "lastName": "Doe" }
```

### Invalid instance: An object value with empty first and last names is invalid

```json
{ "firstName": "", "lastName": "" }
```
