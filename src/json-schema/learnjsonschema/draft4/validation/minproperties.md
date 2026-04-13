# minProperties

- Original: [https://www.learnjsonschema.com/draft4/validation/minproperties/](https://www.learnjsonschema.com/draft4/validation/minproperties/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/minProperties.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/minProperties.markdown)
- Specification: [https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.4.2](https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.4.2)
- Metaschema: `http://json-schema.org/draft-04/schema#`
- Introduced in: `draft4`

An object instance is valid if its number of properties is greater than, or equal to, the value of this keyword.

The [`minProperties`](minproperties.md) keyword restricts object instances to consists of an
inclusive minimum numbers of properties.

> **Common Pitfall:**
>  The presence of this keyword does not depend on the
> presence of the [`properties`](properties.md)
> keyword.  

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains object instances to define at least 2 properties

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
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
