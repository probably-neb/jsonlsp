# dependencies

- Original: [https://www.learnjsonschema.com/draft4/validation/dependencies/](https://www.learnjsonschema.com/draft4/validation/dependencies/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/dependencies.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/dependencies.markdown)
- Specification: [https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.4.5](https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.4.5)
- Metaschema: `http://json-schema.org/draft-04/schema#`
- Introduced in: `draft3`

Validation succeeds if, for each name that appears in both the instance and as a name within this keyword's value, either every item in the corresponding array is also the name of a property in the instance or the corresponding subschema successfully evaluates against the instance.

The [`dependencies`](index.md) keyword is
used to express property-based constraints on object instances. It has two
different modes of operation depending on the type of each dependency value:

- **Property Dependencies (Array)**: When a dependency value is set to an array
  of strings, [`dependencies`](index.md)
  restricts object instances to define certain properties if the corresponding
  property key is also defined.

- **Schema Dependencies (Schema)**: When a dependency value is set to a schema,
  [`dependencies`](index.md) restricts
  object instances to validate against the given subschema if the corresponding
  property key is defined. Note that the given subschema is evaluated against
  the object that defines the property dependency.

> **Common Pitfall:**
>  Note that multiple potentially interrelated dependencies
> can be declared at once, in which case every dependency must be transitively
> fulfilled for the object instance to be valid. For example, if a schema marks
> the property `B` as required if the property `A` is present and also marks the
> property `C` as required if the property `B` is present, defining the property
> `A` transitively requires _both_ the `B` and `C` properties to be present in
> the object instance.  

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains object instances with a single property dependency

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "dependencies": {
    "foo": [ "bar", "baz" ]
  }
}
```

### Valid instance: An object value that defines the dependency and all of the required properties is valid

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Invalid instance: An object value that defines the dependency and some of the required properties is invalid

```json
{ "foo": 1, "bar": 2 }
```

### Invalid instance: An object value that defines the dependency and none of the required properties is invalid

```json
{ "foo": 1 }
```

### Valid instance: An object value that does not define the dependency is valid

```json
{ "qux": 4 }
```

### Valid instance: An empty object value is valid as no dependencies apply

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constrains object instances with transitive property dependencies

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "dependencies": {
    "foo": [ "bar" ],
    "bar": [ "baz" ]
  }
}
```

### Valid instance: An object value that satisfies the transitive dependency is valid

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Invalid instance: An object value that only satisfies the first part of the transitive dependency is invalid

```json
{ "foo": 1, "bar": 2 }
```

### Valid instance: An object value that only satisfies the second part of the transitive dependency is valid

```json
{ "bar": 2, "baz": 3 }
```

### Valid instance: An empty object value is valid as no dependencies apply

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constrains object instances with a single schema dependency

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "dependencies": {
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

### Schema: A schema that constrains object instances with multiple schema dependencies

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "dependencies": {
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

### Schema: A schema that combines property and schema dependencies

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "dependencies": {
    "creditCard": [ "billingAddress" ],
    "billingAddress": { "required": [ "street", "city", "zipcode" ] }
  }
}
```

### Valid instance: An object value that defines the credit card with billing address having all required fields is valid

```json
{
  "creditCard": "1234-5678-9012-3456",
  "billingAddress": {
    "street": "123 Main St",
    "city": "Anytown",
    "zipcode": "12345"
  }
}
```

### Invalid instance: An object value that defines the credit card but missing the billing address is invalid

```json
{ "creditCard": "1234-5678-9012-3456" }
```

### Invalid instance: An object value with billing address that does not have all required fields is invalid

```json
{
  "billingAddress": {
    "street": "123 Main St"
  }
}
```

### Valid instance: An object value that defines neither dependency is valid

```json
{ "name": "John Doe" }
```

### Valid instance: An empty object value is valid as no dependencies apply

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```
