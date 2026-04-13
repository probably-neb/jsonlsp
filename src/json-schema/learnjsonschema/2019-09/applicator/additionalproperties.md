# additionalProperties

- Original: [https://www.learnjsonschema.com/2019-09/applicator/additionalproperties/](https://www.learnjsonschema.com/2019-09/applicator/additionalproperties/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/additionalProperties.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/additionalProperties.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.3.2.3](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.3.2.3)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/applicator`
- Introduced in: `draft0`

Validation succeeds if the schema validates against each value not matched by other object applicators in this vocabulary.

The [`additionalProperties`](additionalproperties.md) keyword restricts object instance
properties not described by the _sibling_ [`properties`](properties.md) and [`patternProperties`](patternproperties.md) keywords (if any), to validate
against the given subschema. Information about the properties that this keyword
was evaluated for is reported using annotations.

> **Common Pitfall:**
> The use of the [`properties`](properties.md) keyword **does not prevent the presence
> of other properties** in the object instance and **does not enforce the
> presence of the declared properties**. In other words, additional data that
> is not explicitly prohibited is permitted by default. This is intended
> behaviour to ease schema evolution (open schemas are backwards compatible by
> default) and to enable highly-expressive constraint-driven schemas.
>
> If you want to restrict instances to only contain the properties you
> declared, you must set this keyword to the boolean schema `false`, and if you
> want to enforce the presence of certain properties, you must use the
> [`required`](../validation/required.md) keyword accordingly.

> **Digging Deeper:**
> While the most common use of this keyword is setting it to
> the boolean schema `false` to prevent additional properties, it is possible
> to set it to a satisfiable schema. Doing this, while omitting the
> [`properties`](properties.md) and
> [`patternProperties`](patternproperties.md)
> keywords, is an elegant way of describing how the value of every property in
> the object instance must look like independently of its name.

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains object instances to not define additional properties

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
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

### Annotation

```json
{ "keyword": "/properties", "instance": "", "value": [ "foo" ] }
{ "keyword": "/patternProperties", "instance": "", "value": [ "x-test" ] }
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
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "additionalProperties": { "type": "integer" }
}
```

### Valid instance: An object value that only defines integer properties is valid

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Annotation

```json
{ "keyword": "/additionalProperties", "instance": "", "value": [ "foo", "bar", "baz" ] }
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
  "$schema": "https://json-schema.org/draft/2019-09/schema",
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

### Annotation

```json
{ "keyword": "/properties", "instance": "", "value": [ "foo" ] }
{ "keyword": "/patternProperties", "instance": "", "value": [ "x-test" ] }
{ "keyword": "/additionalProperties", "instance": "", "value": [ "extra" ] }
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
