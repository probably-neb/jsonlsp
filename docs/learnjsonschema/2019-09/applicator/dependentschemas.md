# dependentSchemas

- Original: [https://www.learnjsonschema.com/2019-09/applicator/dependentschemas/](https://www.learnjsonschema.com/2019-09/applicator/dependentschemas/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/dependentSchemas.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/dependentSchemas.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.2.2.4](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.2.2.4)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/applicator`
- Introduced in: `2019-09`

This keyword specifies subschemas that are evaluated if the instance is an object and contains a certain property.
The [`dependentSchemas`](dependentschemas.md)
keyword restricts object instances to validate against one or more of the given
subschemas if the corresponding properties are defined.  Note that the given
subschemas are evaluated against the object that defines the property
dependency.

> **Digging Deeper:**
> The [`dependentRequired`](../validation/dependentrequired.md) keyword is a specialisation of
> this keyword to describe object dependencies that only consist in property
> requirement.

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains object instances with a single property schema dependency

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "dependentSchemas": {
    "foo": { "maxProperties": 2 }
  }
}
```

### Valid instance: An object value that defines the property dependency and matches the dependent schema is valid

```json
{ "foo": 1, "bar": 2 }
```

### Invalid instance: An object value that defines the property dependency but does not match the dependent schema is invalid

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Valid instance: An object value that does not define the property dependency is valid

```json
{ "firstName": "John", "lastName": "Doe", "age": 50 }
```

### Valid instance: An empty object value is valid as no dependencies apply

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constrains object instances with multiple property schema dependencies

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "dependentSchemas": {
    "foo": { "maxProperties": 2 },
    "bar": { "minProperties": 2 }
  }
}
```

### Valid instance: An object value that defines both property dependencies and has exactly 2 properties is valid

```json
{ "foo": 1, "bar": 2 }
```

### Invalid instance: An object value that defines both property dependencies but has more than 2 properties is invalid

```json
{ "foo": 1, "bar": 2, "extra": true }
```

### Valid instance: An object value that defines the first property dependency and has less than 2 properties is valid

```json
{ "foo": 1 }
```

### Invalid instance: An object value that defines the first property dependency and has more than 2 properties is invalid

```json
{ "foo": 1, "name": "John Doe", "age": 50 }
```

### Invalid instance: An object value that defines the second property dependency and has less than 2 properties is invalid

```json
{ "bar": 2 }
```

### Valid instance: An empty object value is valid as no dependencies apply

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```
