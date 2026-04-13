# additionalProperties

- Original: [https://www.learnjsonschema.com/draft4/validation/additionalproperties/](https://www.learnjsonschema.com/draft4/validation/additionalproperties/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/additionalProperties.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/additionalProperties.markdown)
- Specification: [https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.4.4](https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.4.4)
- Metaschema: `http://json-schema.org/draft-04/schema#`
- Introduced in: `draft0`

Validation succeeds if the schema validates against each value not matched by other object applicators in this vocabulary. If set to `false`, no additional properties are allowed in the instance.

The `additionalProperties` keyword restricts object instance properties not
described by the _sibling_ [`properties`](properties.md) and [`patternProperties`](patternproperties.md) keywords (if any), to validate against the given subschema.

> **Common Pitfall:**
> The use of the [`properties`](properties.md) keyword **does not prevent the presence of
> other properties** in the object instance and **does not enforce the presence
> of the declared properties**. In other words, additional data that is not
> explicitly prohibited is permitted by default. This is intended behaviour to
> ease schema evolution (open schemas are backwards compatible by default) and to
> enable highly-expressive constraint-driven schemas.
>
> If you want to restrict instances to only contain the properties you declared,
> you must set this keyword to the boolean schema `false`, and if you want to
> enforce the presence of certain properties, you must use the [`required`](required.md) keyword accordingly.

> **Digging Deeper:**
> While the most common use of this keyword is setting it to
> the boolean schema `false` to prevent additional properties, it is possible to
> set it to a satisfiable schema. Doing this, while omitting the
> [`properties`](properties.md) and
> [`patternProperties`](patternproperties.md)
> keywords, is an elegant way of describing how the value of every property in
> the object instance must look like independently of its
> name.

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains object instances to not define additional properties

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "properties": {
    "foo": { "type": "string" }
  },
  "patternProperties": {
    "^x-": { "type": "integer" }
  },
  "additionalProperties": false
}
```

### Valid instance: An object value that defines properties that only match static and regular expression definitions is valid

```json
{ "foo": "bar", "x-test": 2 }
```

### Invalid instance: An object value that defines valid properties and also defines additional properties is invalid

```json
{ "foo": "bar", "x-test": 2, "extra": true }
```

### Invalid instance: An object value that only defines additional properties is invalid

```json
{ "extra": true, "random": 1234 }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constrains object instances to only define integer properties

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "additionalProperties": { "type": "integer" }
}
```

### Valid instance: An object value that only defines integer properties is valid

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Invalid instance: An object value that defines at least one non-integer property is invalid

```json
{ "foo": 1, "name": "John Doe" }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constrains object instances to define boolean additional properties

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "properties": {
    "foo": { "type": "string" }
  },
  "patternProperties": {
    "^x-": { "type": "integer" }
  },
  "additionalProperties": {
    "type": "boolean"
  }
}
```

### Valid instance: An object value that defines valid properties and boolean additional properties is valid

```json
{ "foo": "bar", "x-test": 2, "extra": true }
```

### Invalid instance: An object value that defines valid properties and also defines non-boolean additional properties is invalid

```json
{ "foo": "bar", "x-test": 2, "extra": "should be a boolean" }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

The [`additionalProperties`](additionalproperties.md) keyword restricts object instance properties not described by the
_sibling_ [`properties`](properties.md) and
[`patternProperties`](patternproperties.md)
keywords (if any), to validate against the given subschema.

> **Common Pitfall:**
> The use of the [`properties`](properties.md) keyword **does not prevent the presence of
> other properties** in the object instance and **does not enforce the presence
> of the declared properties**. In other words, additional data that is not
> explicitly prohibited is permitted by default. This is intended behaviour to
> ease schema evolution (open schemas are backwards compatible by default) and to
> enable highly-expressive constraint-driven schemas.
>
> If you want to restrict instances to only contain the properties you declared,
> you must set this keyword to the boolean schema `false`, and if you want to
> enforce the presence of certain properties, you must use the [`required`](required.md) keyword accordingly.

> **Digging Deeper:**
> While the most common use of this keyword is setting it to
> the boolean schema `false` to prevent additional properties, it is possible to
> set it to a satisfiable schema. Doing this, while omitting the
> [`properties`](properties.md) and
> [`patternProperties`](patternproperties.md)
> keywords, is an elegant way of describing how the value of every property in
> the object instance must look like independently of its
> name.

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains object instances to not define additional properties

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "properties": {
    "foo": { "type": "string" }
  },
  "patternProperties": {
    "^x-": { "type": "integer" }
  },
  "additionalProperties": false
}
```

### Valid instance: An object value that defines properties that only match static and regular expression definitions is valid

```json
{ "foo": "bar", "x-test": 2 }
```

### Invalid instance: An object value that defines valid properties and also defines additional properties is invalid

```json
{ "foo": "bar", "x-test": 2, "extra": true }
```

### Invalid instance: An object value that only defines additional properties is invalid

```json
{ "extra": true, "random": 1234 }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constrains object instances to only define integer properties

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "additionalProperties": { "type": "integer" }
}
```

### Valid instance: An object value that only defines integer properties is valid

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Invalid instance: An object value that defines at least one non-integer property is invalid

```json
{ "foo": 1, "name": "John Doe" }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constrains object instances to define boolean additional properties

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "properties": {
    "foo": { "type": "string" }
  },
  "patternProperties": {
    "^x-": { "type": "integer" }
  },
  "additionalProperties": {
    "type": "boolean"
  }
}
```

### Valid instance: An object value that defines valid properties and boolean additional properties is valid

```json
{ "foo": "bar", "x-test": 2, "extra": true }
```

### Invalid instance: An object value that defines valid properties and also defines non-boolean additional properties is invalid

```json
{ "foo": "bar", "x-test": 2, "extra": "should be a boolean" }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```
