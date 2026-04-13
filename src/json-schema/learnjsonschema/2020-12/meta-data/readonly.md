# readOnly

- Original: [https://www.learnjsonschema.com/2020-12/meta-data/readonly/](https://www.learnjsonschema.com/2020-12/meta-data/readonly/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/meta-data/readOnly.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/meta-data/readOnly.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-9.4](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-9.4)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/meta-data`
- Introduced in: `draft7`

This keyword indicates that the value of the instance is managed exclusively by the owning authority, and attempts by an application to modify the value of this property are expected to be ignored or rejected by that owning authority.

The [`readOnly`](readOnly.md) keyword, when set to `true`, signifies that an instance value
(such as a specific object property) cannot be modified or removed, whatever
that means in the context of the system. For example, form generators may rely
on this keyword to mark the corresponding input as read only. This keyword does
not affect validation, but the evaluator will collect its value as an
annotation.

> **Best Practice:**
> Avoid setting this keyword to the default value `false`. If an instance value
> is not considered to be read only, the best practice is to omit the use of this
> keyword altogether. This prevents unnecessarily generating and collecting an
> annotation that does not carry any additional meaning.
>
> Also avoid simultaneously setting this keyword and the [`writeOnly`](writeonly.md) keyword to `true` for the same instance
> location, resulting in ambiguous semantics.

> **Common Pitfall:**
> Tooling makers must be careful when statically traversing schemas in search of
> occurrences of this keyword. It is possible for schemas to make use of this
> keyword behind conditional operators, references, or any other type of keyword
> that makes it hard or even impossible to correctly locate these values without
> fully evaluating the schema against an instance. The only bullet proof method
> is through annotation collection.
>
> For example, an instance property might only be read only under certain
> conditions determined by a dynamic operator like [`anyOf`](../applicator/anyof.md).

## Examples

### Schema: A schema that statically marks the id optional object property as read only

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "properties": {
    "id": { "type": "integer", "readOnly": true },
    "value": { "type": "integer" }
  }
}
```

### Valid instance: An object value that defines the read only property is valid but an annotation is emitted

```json
{ "id": 1234, "value": 5 }
```

### Annotation

```json
{ "keyword": "/properties/id/readOnly", "instance": "/id", "value": true }
```

### Valid instance: An object value that does not define the read only property is valid and no annotation is emitted

```json
{ "value": 5 }
```

### Invalid instance: An object value that does not match the schema is invalid and no annotations are emitted

```json
{ "id": 1234, "value": null }
```

### Schema: A schema that dynamically marks the id optional object property as read only based on the presence of the data property

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "properties": {
    "id": { "type": "integer" },
    "value": { "type": "integer" }
  },
  "dependentSchemas": {
    "value": {
      "properties": { "id": { "readOnly": true } }
    }
  }
}
```

### Valid instance: An object value that defines both properties is valid but an annotation is emitted

```json
{ "id": 1234, "value": 5 }
```

### Annotation

```json
{ "keyword": "/dependentSchemas/value/properties/id/readOnly", "instance": "/id", "value": true }
```

### Valid instance: An object value that only defines the value property is valid and no annotation is emitted

```json
{ "value": 5 }
```

### Valid instance: An object value that only defines the id property is valid and no annotation is emitted

```json
{ "id": 1234 }
```

### Invalid instance: An object value that does not match the schema is invalid and no annotations are emitted

```json
{ "value": null }
```
