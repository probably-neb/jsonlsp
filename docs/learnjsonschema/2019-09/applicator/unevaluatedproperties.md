# unevaluatedProperties

- Original: [https://www.learnjsonschema.com/2019-09/applicator/unevaluatedproperties/](https://www.learnjsonschema.com/2019-09/applicator/unevaluatedproperties/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/unevaluatedProperties.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/unevaluatedProperties.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.3.2.4](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.3.2.4)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/unevaluated`
- Introduced in: `2019-09`

Validates object properties that did not successfully validate against other standard object applicators.
The [`unevaluatedProperties`](unevaluatedproperties.md) keyword is a generalisation
of the [`additionalProperties`](additionalproperties.md) keyword that considers related
keywords even when they are not direct siblings of this keyword. More
specifically, this keyword is affected by occurrences of [`properties`](properties.md), [`patternProperties`](patternproperties.md), [`additionalProperties`](additionalproperties.md), and
[`unevaluatedProperties`](unevaluatedproperties.md) itself, as long as the evaluate path that led to
[`unevaluatedProperties`](unevaluatedproperties.md) is a _prefix_ of the evaluate path of the others.

Given its evaluation-dependent nature, this keyword is evaluated after every
other keyword from every other vocabulary.

> **Best Practice:**
> There are two common use cases for this keyword, both for reducing
> duplication: (1) Elegantly describing additional object properties while
> declaring the [`properties`](properties.md) or
> [`patternProperties`](patternproperties.md)
> keywords behind conditional logic without duplicating the
> [`additionalProperties`](additionalproperties.md) keyword in every possible branch. (2) Reusing helpers that consist of
> the [`properties`](properties.md),
> [`patternProperties`](patternproperties.md), or
> [`additionalProperties`](additionalproperties.md) keywords, while specialising the helpers as needed in specific locations
> without having to inline the entire contents of the helper.

> **Digging Deeper:**
> The JSON Schema specification defines the relationship between this keyword
> and the ones that affect it in terms of annotations. However, in practice,
> most implementations avoid the use of annotations for performance reasons, as
> emitting annotations and checking the annotation values of other keywords
> often involves significant memory allocation and complex data structure
> traversals.
>
> The paper [Elimination of annotation dependencies in validation for Modern
> JSON Schema](https://arxiv.org/abs/2503.11288) is a comprehensive
> mathematical study of how applicators can be automatically re-written to avoid
> annotation dependencies, leading to schemas that are simpler to evaluate.

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that conditionally constrains object instances to define certain properties, with string additional properties in both cases

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "if": { "maxProperties": 2 },
  "then": { "properties": { "foo": true } },
  "else": { "patternProperties": { "^@": true } },
  "unevaluatedProperties": { "type": "string" }
}
```

### Valid instance: An object value that defines a "foo" property and other string properties is valid

```json
{ "foo": 1, "bar": "baz" }
```

### Annotation

```json
{ "keyword": "/then/properties", "instance": "", "value": [ "foo" ] }
{ "keyword": "/unevaluatedProperties", "instance": "", "value": [ "bar" ] }
```

### Valid instance: An object value that defines multiple properties that start with "@" and other string properties is valid

```json
{ "@foo": 1, "@bar": 2, "baz": "qux" }
```

### Annotation

```json
{ "keyword": "/else/patternProperties", "instance": "", "value": [ "@foo", "@bar" ] }
{ "keyword": "/unevaluatedProperties", "instance": "", "value": [ "baz" ] }
```

### Invalid instance: An object value that defines a "foo" property and other non-string properties is invalid

```json
{ "foo": 1, "bar": 2 }
```

### Invalid instance: An object value that defines multiple properties that start with "@" and other non-string properties is invalid

```json
{ "@foo": 1, "@bar": 2, "baz": 3 }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constraints object instances to only allow extension keywords that start with "@" using a helper

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "properties": { "foo": true },
  "$ref": "#/$defs/allow-extensions",
  "unevaluatedProperties": false,
  "$defs": {
    "allow-extensions": {
      "patternProperties": { "^@": true }
    }
  }
}
```

### Valid instance: An object value that only defines a "foo" property is valid

```json
{ "foo": 1 }
```

### Annotation

```json
{ "keyword": "/properties", "instance": "", "value": [ "foo" ] }
```

### Valid instance: An object value that only defines a "foo" property and other properties that start with "@" is valid

```json
{ "foo": 1, "@bar": 2, "@baz": 3 }
```

### Annotation

```json
{ "keyword": "/properties", "instance": "", "value": [ "foo" ] }
{ "keyword": "/$defs/allow-extensions/patternProperties", "instance": "", "value": [ "@bar", "@baz" ] }
```

### Valid instance: An object value that only defines properties that start with "@" is valid

```json
{ "@foo": 1, "@bar": 2, "@baz": 3 }
```

### Annotation

```json
{ "keyword": "/$defs/allow-extensions/patternProperties", "instance": "", "value": [ "@foo", "@bar", "@baz" ] }
```

### Invalid instance: An object value that only defines a "foo" property and other properties that do not start with "@" is invalid

```json
{ "foo": 1, "bar": 2 }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constraints object instances to not define any properties, as both object keywords are cousins

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "allOf": [
    { "properties": { "foo": true } },
    { "unevaluatedProperties": false }
  ]
}
```

### Invalid instance: An object value that only defines a "foo" property is invalid as the schema prohibits unevaluated properties

```json
{ "foo": 1 }
```

### Invalid instance: An object value that defines any other property is invalid as the schema prohibits unevaluated properties

```json
{ "bar": 2 }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constraints object instances to define arbitrary properties

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "allOf": [ { "unevaluatedProperties": true } ],
  "unevaluatedProperties": false
}
```

### Valid instance: An object value that defines any property is valid as the nested applicator takes precedence

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Annotation

```json
{ "keyword": "/allOf/0/unevaluatedProperties", "instance": "", "value": [ "foo", "bar", "baz" ] }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```
