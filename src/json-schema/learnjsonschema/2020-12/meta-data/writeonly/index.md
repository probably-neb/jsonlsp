# writeOnly

- Original: [https://www.learnjsonschema.com/2020-12/meta-data/writeonly/](https://www.learnjsonschema.com/2020-12/meta-data/writeonly/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/meta-data/writeOnly.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/meta-data/writeOnly.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-9.4](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-9.4)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/meta-data`
- Introduced in: `draft7`

This keyword indicates that the value is never present when the instance is retrieved from the owning authority.

The [`writeOnly`](../writeOnly/index.md) keyword, when set to `true`, signifies that an instance value
(such as a specific object property) can be modified or removed but not read,
whatever that means in the context of the system. For example, form generators
may rely on this keyword to mark the corresponding input as as a password
field. This keyword does not affect validation, but the evaluator will collect
its value as an annotation.

> **Best Practice:**
> Avoid setting this keyword to the default value `false`. If an instance value
> is not considered to be write only, the best practice is to omit the use of
> this keyword altogether. This prevents unnecessarily generating and collecting
> an annotation that does not carry any additional meaning.
>
> Also avoid simultaneously setting this keyword and the [`readOnly`](../readonly/index.md) keyword to `true` for the same instance
> location, resulting in ambiguous semantics.

> **Common Pitfall:**
> Tooling makers must be careful when statically traversing schemas in search of
> occurrences of this keyword. It is possible for schemas to make use of this
> keyword behind conditional operators, references, or any other type of keyword
> that makes it hard or even impossible to correctly locate these values without
> fully evaluating the schema against an instance. The only bullet proof method
> is through annotation collection.
>
> For example, an instance property might only be write only under certain
> conditions determined by a dynamic operator like [`anyOf`](../../applicator/anyof/index.md).

## Examples

### Schema: A schema that statically marks the password optional object property as write only

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "properties": {
    "username": { "type": "string" }
    "password": { "type": "string", "writeOnly": true },
  }
}
```

### Valid instance: An object value that defines the write only property is valid but an annotation is emitted

```json
{ "username": "jviotti", "password": "mysupersecretpassword" }
```

### Annotation

```json
{ "keyword": "/properties/password/writeOnly", "instance": "/password", "value": true }
```

### Valid instance: An object value that does not define the write only property is valid and no annotation is emitted

```json
{ "username": "jviotti" }
```

### Invalid instance: An object value that does not match the schema is invalid and no annotations are emitted

```json
{ "password": null }
```

### Schema: A schema that dynamically marks the password optional object property as write only based on the presence of the username property

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "properties": {
    "username": { "type": "string" }
    "password": { "type": "string" },
  }
  "dependentSchemas": {
    "username": {
      "properties": { "password": { "writeOnly": true } }
    }
  }
}
```

### Valid instance: An object value that defines both properties is valid but an annotation is emitted

```json
{ "username": "jviotti", "password": "mysupersecretpassword" }
```

### Annotation

```json
{ "keyword": "/dependentSchemas/username/properties/password/writeOnly", "instance": "/password", "value": true }
```

### Valid instance: An object value that only defines the username property is valid and no annotation is emitted

```json
{ "username": "jviotti" }
```

### Valid instance: An object value that only defines the password property is valid and no annotation is emitted

```json
{ "password": "mysupersecretpassword" }
```

### Invalid instance: An object value that does not match the schema is invalid and no annotations are emitted

```json
{ "password": null }
```
