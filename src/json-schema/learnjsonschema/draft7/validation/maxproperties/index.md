# maxProperties

- Original: [https://www.learnjsonschema.com/draft7/validation/maxproperties/](https://www.learnjsonschema.com/draft7/validation/maxproperties/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/maxProperties.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/maxProperties.markdown)
- Specification: [https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.5.1](https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.5.1)
- Metaschema: `http://json-schema.org/draft-07/schema#`
- Introduced in: `draft4`

An object instance is valid if its number of properties is less than, or equal to, the value of this keyword.

The [`maxProperties`](index.md) keyword restricts object instances to consists of an
inclusive maximum numbers of properties.

> **Common Pitfall:**
>  The presence of this keyword does not depend on the
> presence of the [`properties`](../properties/index.md)
> keyword.  

> **Best Practice:**
> To restrict object instances to the empty object, prefer
> using the [`const`](../const/index.md) keyword instead of
> setting this keyword to `0`. 

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains object instances to define at most 2 properties

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "maxProperties": 2
}
```

### Invalid instance: An object value with more than 2 properties is invalid

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Valid instance: An object value with 2 properties is valid

```json
{ "foo": 1, "bar": 2 }
```

### Valid instance: An object value with less than 2 properties is valid

```json
{ "foo": 1 }
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```
