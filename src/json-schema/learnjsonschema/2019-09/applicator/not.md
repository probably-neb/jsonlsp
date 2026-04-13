# not

- Original: [https://www.learnjsonschema.com/2019-09/applicator/not/](https://www.learnjsonschema.com/2019-09/applicator/not/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/not.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/not.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.2.1.4](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.2.1.4)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/applicator`
- Introduced in: `draft4`

An instance is valid against this keyword if it fails to validate successfully against the schema defined by this keyword.

The [`not`](not.md) keyword restricts
instances to fail validation against the given subschema. This keyword
represents a [logical negation](https://en.wikipedia.org/wiki/Negation) (NOT)
operation. In other words, the instance successfully validates against the
schema only if it does not match the given subschema.

> **Digging Deeper:**
>  After evaluating this keyword, any annotation emitted by
> its subschema is discarded, independently of whether the subschema was
> successful or not, as annotations are always discarded on failure. While this
> might seem counter-intuitive, consider the following cases:
>
> - If the subschema successfully validates against the instance, then the
>   negation keyword itself fails and annotations are discarded
> - If the subschema fails to validate against the instance, then annotations are
>   discarded before bubbling up to the outer negation keyword

> **Best Practice:**
>  Avoid the use of this keyword (usually negating the
> [`required`](../validation/required.md) keyword) to prohibit
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
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "not": {
    "title": "I will never be emitted as an annotation",
    "const": "Prohibited"
  }
}
```

### Valid instance: A value that does not equal the prohibited value is valid and no annotation is emitted

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
  "$schema": "https://json-schema.org/draft/2019-09/schema",
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
