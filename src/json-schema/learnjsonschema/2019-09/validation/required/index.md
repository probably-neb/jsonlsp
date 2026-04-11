# required

- Original: [https://www.learnjsonschema.com/2019-09/validation/required/](https://www.learnjsonschema.com/2019-09/validation/required/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/validation/required.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/validation/required.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.6.5.3](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.6.5.3)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/validation`
- Introduced in: `draft3`

An object instance is valid against this keyword if every item in the array is the name of a property in the instance.

The [`required`](index.md) keyword restricts
object instances to define the given set of properties.

> **Common Pitfall:**
>  The presence of this keyword does not depend on the
> presence of the [`properties`](../../applicator/properties/index.md)
> keyword. The [`required`](index.md) keyword
> mandates that certain properties are present (independently of their value),
> while the [`properties`](../../applicator/properties/index.md) keyword
> describes the value of such properties when present.

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains object instances to define certain properties

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "required": [ "foo", "bar", "baz" ]
}
```

### Valid instance: An object value that defines the required properties to any values is valid

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Valid instance: An object value that defines a superset of the required properties is valid

```json
{ "foo": 1, "bar": 2, "baz": 3, "extra": true }
```

### Invalid instance: An object value that only defines a subset of the required properties is invalid

```json
{ "foo": 1, "bar": 2, "extra": true }
```

### Invalid instance: An empty object is invalid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constrains object instances to define certain properties and to describe their value

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "required": [ "name", "age" ],
  "properties": {
    "name": { "type": "string" },
    "age": { "type": "integer" }
  }
}
```

### Valid instance: An object value that defines the required properties and matches their definition is valid

```json
{ "name": "John Doe", "age": 30 }
```

### Annotation

```json
{ "keyword": "/properties", "instance": "", "value": [ "name", "age" ] }
```

### Valid instance: An object value that defines a superset of the required properties and matches their definition is valid

```json
{ "name": "John Doe", "age": 30, "extra": true }
```

### Annotation

```json
{ "keyword": "/properties", "instance": "", "value": [ "name", "age" ] }
```

### Invalid instance: An object value that only defines a subset of the required properties and matches their definition is invalid

```json
{ "name": "John Doe" }
```

### Invalid instance: An object value that defines the required properties but does not match their definition is invalid

```json
{ "name": 123, "age": "foo" }
```

### Invalid instance: An empty object is invalid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```
