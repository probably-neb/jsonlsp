# $defs

- Original: [https://www.learnjsonschema.com/2020-12/core/defs/](https://www.learnjsonschema.com/2020-12/core/defs/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/core/defs.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/core/defs.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-core.html#section-8.2.4](https://json-schema.org/draft/2020-12/json-schema-core.html#section-8.2.4)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/core`
- Introduced in: `2019-09`

This keyword reserves a location for schema authors to inline reusable JSON Schemas into a more general schema.

The [`$defs`](defs.md) keyword is a container for storing reusable
schemas within a schema resource, which can be referenced using the
[`$ref`](ref.md) or [`$dynamicRef`](dynamicref.md) keywords. From a software engineering point of
view, this keyword is analogous to defining _internal_ helper functions as part
of a larger program.

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
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "properties": {
    "firstName": { "$ref": "#/$defs/nonEmptyString" },
    "lastName": { "$ref": "#/$defs/nonEmptyString" }
  },
  "$defs": {
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
