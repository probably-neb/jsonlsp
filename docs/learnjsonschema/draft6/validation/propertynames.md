# propertyNames

- Original: [https://www.learnjsonschema.com/draft6/validation/propertynames/](https://www.learnjsonschema.com/draft6/validation/propertynames/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/propertyNames.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/propertyNames.markdown)
- Specification: [https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.6.22](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.6.22)
- Metaschema: `http://json-schema.org/draft-06/schema#`
- Introduced in: `draft6`

Validation succeeds if the schema validates against every property name in the instance.
The [`propertyNames`](propertynames.md) keyword
restricts object instances to only define properties whose names match the given
schema. This keyword is evaluated against _every_ property of the object
instance, independently of keywords that indirectly introduce property names
such as [`properties`](properties.md) and
[`patternProperties`](patternproperties.md).

> **Common Pitfall:**
>  As per the JSON grammar, the name of an object property
> must be a string. Therefore, setting this keyword to a schema that makes use
> of keywords that only apply to types other than strings (such as the
> [`properties`](properties.md) keyword) is
> either meaningless or leads to unsatisfiable schemas. Conversely, explicitly
> setting the [`type`](type.md) keyword to
> `string` is redundant.  

> **Best Practice:**
>  This keyword is useful when describing JSON objects whose
> properties cannot be known in advance. For example, allowing extensions that
> must adhere to a certain name convention. If that's not the case, prefer
> explicitly listing every permitted property using the [`properties`](properties.md) or [`patternProperties`](patternproperties.md) keywords, and potentially closing
> the object by setting the [`additionalProperties`](additionalproperties.md) keyword to `false`.

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains object instances to define lowercase properties

```json
{
  "$schema": "http://json-schema.org/draft-06/schema#",
  "propertyNames": { "pattern": "^[a-z]*$" }
}
```

### Valid instance: An object value with lowercase properties is valid

```json
{ "foo": "bar" }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Invalid instance: An object value with uppercase or alphanumeric properties is invalid

```json
{ "CamelCase": true, "alphanumeric123": false }
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that incorrectly constrains object property names to an impossible type

```json
{
  "$schema": "http://json-schema.org/draft-06/schema#",
  "propertyNames": { "type": "array" }
}
```

### Invalid instance: Any non-empty object value is invalid

```json
{ "foo": "bar" }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema with a property name unsatisfiable collision between keywords

```json
{
  "$schema": "http://json-schema.org/draft-06/schema#",
  "propertyNames": { "pattern": "^b" },
  "properties": {
    "foo": { "type": "integer" },
    "bar": { "type": "integer" }
  }
}
```

### Invalid instance: An object value with a defined property that does not match every name constraint is invalid

```json
{ "foo": 1 }
```

### Invalid instance: An object value with a property that matches every name constraint but does not match its declaration is invalid

```json
{ "bar": "should have been an integer" }
```

### Valid instance: An object value with a non-defined property that matches every name constraint is valid

```json
{ "baz": "qux" }
```
