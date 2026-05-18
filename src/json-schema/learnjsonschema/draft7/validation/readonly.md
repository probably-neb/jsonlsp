# readOnly

- Original: [https://www.learnjsonschema.com/draft7/validation/readonly/](https://www.learnjsonschema.com/draft7/validation/readonly/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/readOnly.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/readOnly.markdown)
- Specification: [https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.10.3](https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.10.3)
- Metaschema: `http://json-schema.org/draft-07/schema#`
- Introduced in: `draft7`

This keyword indicates that the value of the instance is managed exclusively by the owning authority, and attempts by an application to modify the value of this property are expected to be ignored or rejected by that owning authority.
The [`readOnly`](readonly.md) keyword, when set to `true`, signifies that an instance value
(such as a specific object property) cannot be modified or removed, whatever
that means in the context of the system. For example, form generators may rely
on this keyword to mark the corresponding input as read only. This keyword provides metadata for documentation purposes and does not affect validation.

> **Best Practice:**
> Avoid setting this keyword to the default value `false`. If an instance value
> is not considered to be read only, the best practice is to omit the use of this
> keyword altogether.
>
> Also avoid simultaneously setting this keyword and the [`writeOnly`](writeonly.md) keyword to `true` for the same instance
> location, resulting in ambiguous semantics.

> **Common Pitfall:**
> Tooling makers must be careful when statically traversing schemas in search of
> occurrences of this keyword. It is possible for schemas to make use of this
> keyword behind conditional operators, references, or any other type of keyword
> that makes it hard or even impossible to correctly locate these values in all
> cases.
>
> For example, an instance property might only be read only under certain
> conditions determined by a dynamic operator like [`anyOf`](anyof.md).

## Examples

### Schema: A schema that statically marks the id optional object property as read only

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "properties": {
    "id": { "type": "integer", "readOnly": true },
    "value": { "type": "integer" }
  }
}
```

### Valid instance: An object value that defines the read only property is valid

```json
{ "id": 1234, "value": 5 }
```

### Valid instance: An object value that does not define the read only property is valid

```json
{ "value": 5 }
```

### Invalid instance: An object value that does not match the schema is invalid

```json
{ "id": 1234, "value": null }
```

### Schema: A schema that dynamically marks the id optional object property as read only based on the presence of the data property

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "properties": {
    "id": { "type": "integer" },
    "value": { "type": "integer" }
  },
  "dependencies": {
    "value": {
      "properties": { "id": { "readOnly": true } }
    }
  }
}
```

### Valid instance: An object value that defines both properties is valid

```json
{ "id": 1234, "value": 5 }
```

### Valid instance: An object value that only defines the value property is valid

```json
{ "value": 5 }
```

### Valid instance: An object value that only defines the id property is valid

```json
{ "id": 1234 }
```

### Invalid instance: An object value that does not match the schema is invalid

```json
{ "value": null }
```
