# not

- Original: [https://www.learnjsonschema.com/draft4/validation/not/](https://www.learnjsonschema.com/draft4/validation/not/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/not.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/not.markdown)
- Specification: [https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.5.6](https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.5.6)
- Metaschema: `http://json-schema.org/draft-04/schema#`
- Introduced in: `draft4`

An instance is valid against this keyword if it fails to validate successfully against the schema defined by this keyword.
The [`not`](not.md) keyword restricts
instances to fail validation against the given subschema. This keyword
represents a [logical negation](https://en.wikipedia.org/wiki/Negation) (NOT)
operation. In other words, the instance successfully validates against the
schema only if it does not match the given subschema.

> **Best Practice:**
>  Avoid the use of this keyword (usually negating the
> [`required`](required.md) keyword) to prohibit
> specific object properties from being defined. Instead, use the
> [`properties`](properties.md) keyword and set
> the disallowed object properties to the `false` boolean
> schema.

This keyword is equivalent to the `!` operator found in most programming
languages. For example:

```c
bool valid = !not_schema;
```

## Examples

### Schema: A schema that constrains instances to not be a specific value

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "not": {
    "const": "Prohibited"
  }
}
```

### Valid instance: A value that does not equal the prohibited value is valid

```json
"Hello World"
```

### Invalid instance: A value that equals the prohibited value is invalid

```json
"Prohibited"
```

### Schema: A schema that negates an unsatisfiable schema matches every possible instance

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "not": {
    "type": "string",
    "minLength": 10,
    "maxLength": 9
  }
}
```

### Valid instance: Any value is valid

```json
"Hello World"
```
