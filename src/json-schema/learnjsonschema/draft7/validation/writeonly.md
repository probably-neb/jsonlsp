# writeOnly

- Original: [https://www.learnjsonschema.com/draft7/validation/writeonly/](https://www.learnjsonschema.com/draft7/validation/writeonly/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/writeOnly.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/writeOnly.markdown)
- Specification: [https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.10.3](https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.10.3)
- Metaschema: `http://json-schema.org/draft-07/schema#`
- Introduced in: `draft7`

This keyword indicates that the value is never present when the instance is retrieved from the owning authority.

The [`writeOnly`](writeonly.md) keyword, when set
to `true`, signifies that an instance value (such as a specific object
property) can be modified or removed but not read, whatever that means in the
context of the system. For example, form generators may rely on this keyword to
mark the corresponding input as as a password field. This keyword provides
metadata for documentation purposes and does not affect validation.

> **Best Practice:**
> Avoid setting this keyword to the default value `false`. If an instance value
> is not considered to be write only, the best practice is to omit the use of
> this keyword altogether.
>
> Also avoid simultaneously setting this keyword and the [`readOnly`](readonly.md) keyword to `true` for the same instance
> location, resulting in ambiguous semantics.

> **Common Pitfall:**
> Tooling makers must be careful when statically traversing schemas in search of
> occurrences of this keyword. It is possible for schemas to make use of this
> keyword behind conditional operators, references, or any other type of keyword
> that makes it hard or even impossible to correctly locate these values in all
> cases.
>
> For example, an instance property might only be write only under certain
> conditions determined by a dynamic operator like [`anyOf`](anyof.md).

## Examples

### Schema: A schema that statically marks the password optional object property as write only

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "properties": {
    "username": { "type": "string" },
    "password": { "type": "string", "writeOnly": true }
  }
}
```

### Valid instance: An object value that defines the write only property is valid

```json
{ "username": "jviotti", "password": "mysupersecretpassword" }
```

### Valid instance: An object value that does not define the write only property is valid

```json
{ "username": "jviotti" }
```

### Invalid instance: An object value that does not match the schema is invalid

```json
{ "password": null }
```

### Schema: A schema that dynamically marks the password optional object property as write only based on the presence of the username property

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "properties": {
    "username": { "type": "string" },
    "password": { "type": "string" }
  },
  "dependencies": {
    "username": {
      "properties": { "password": { "writeOnly": true } }
    }
  }
}
```

### Valid instance: An object value that defines both properties is valid

```json
{ "username": "jviotti", "password": "mysupersecretpassword" }
```

### Valid instance: An object value that only defines the username property is valid

```json
{ "username": "jviotti" }
```

### Valid instance: An object value that only defines the password property is valid

```json
{ "password": "mysupersecretpassword" }
```

### Invalid instance: An object value that does not match the schema is invalid

```json
{ "password": null }
```
