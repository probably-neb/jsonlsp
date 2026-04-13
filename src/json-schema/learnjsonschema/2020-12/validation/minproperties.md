# minProperties

- Original: [https://www.learnjsonschema.com/2020-12/validation/minproperties/](https://www.learnjsonschema.com/2020-12/validation/minproperties/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/validation/minProperties.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/validation/minProperties.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-6.5.2](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-6.5.2)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/validation`
- Introduced in: `draft4`

An object instance is valid if its number of properties is greater than, or equal to, the value of this keyword.

The [`minProperties`](minProperties.md) keyword restricts object instances to consists of an
inclusive minimum numbers of properties.

> **Common Pitfall:**
>  The presence of this keyword does not depend on the
> presence of the [`properties`](../applicator/properties.md)
> keyword.  

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains object instances to define at least 2 properties

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "minProperties": 2
}
```

### Valid instance: An object value with more than 2 properties is valid

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Valid instance: An object value with 2 properties is valid

```json
{ "foo": 1, "bar": 2 }
```

### Invalid instance: An object value with less than 2 properties is invalid

```json
{ "foo": 1 }
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```
