# properties

- Original: [https://www.learnjsonschema.com/2019-09/applicator/properties/](https://www.learnjsonschema.com/2019-09/applicator/properties/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/properties.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/properties.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.3.2.1](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.3.2.1)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/applicator`
- Introduced in: `draft1`

Validation succeeds if, for each name that appears in both the instance and as a name within this keyword's value, the child instance for that name successfully validates against the corresponding schema.

The [`properties`](index.md) keyword
restricts properties of an object instance, when present, to match their
corresponding subschemas definitions. Information about the properties that this
keyword was evaluated for is reported using annotations.

> **Common Pitfall:**
> The use of this keyword **does not prevent the presence of
> other properties** in the object instance and **does not enforce the presence
> of the declared properties**. In other words, additional data that is not
> explicitly prohibited is permitted by default. This is intended behaviour to
> ease schema evolution (open schemas are backwards compatible by default) and to
> enable highly-expressive constraint-driven schemas.
>
> If you want to restrict instances to only contain the properties you declared,
> you must set the [`additionalProperties`](../additionalproperties/index.md) keyword to the boolean schema
> `false`, and if you want to enforce the presence of certain properties, you
> must use the [`required`](../../validation/required/index.md) keyword
> accordingly.  

> **Digging Deeper:**
> Setting properties defined by this keyword to the boolean
> schema `false` is an common trick to express that such properties are
> forbidden. This is considered more elegant (and usually more performant) than
> using the [`not`](../not/index.md) applicator to negate
> the [`required`](../../validation/required/index.md) keyword. However,
> setting properties defined by this keyword to the boolean `true` is considered
> to be redundant and an anti-pattern, as additional properties are permitted by
> default.  

> **Common Pitfall:**
>  This keyword is evaluated independently of the
> [`patternProperties`](../patternproperties/index.md)
> keyword. If an object property is described by both keywords, then both schemas
> must successfully validate against the given property for validation to
> succeed.  

> **Best Practice:**
>  While JSON Schema allows property names to contain any
> characters (including spaces, special characters, and even empty strings),
> consider restricting property names to match the regular expression
> `[A-Za-z_][A-Za-z0-9_]*`, as suggested by the [JSON Structure
> specification](https://json-structure.github.io/core/draft-vasters-json-structure-core.html#section-3.6).
> This makes it easier to convert your schemas into programming language type
> definitions (such as classes or structs), database schemas (such as SQL
> tables), and other systems that have stricter naming requirements.

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains object instances to a string and integer property

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "properties": {
    "name": { "type": "string" },
    "age": { "type": "integer" }
  }
}
```

### Valid instance: An object value that defines both declared properties and matches the corresponding schemas is valid

```json
{ "name": "John Doe", "age": 50 }
```

### Annotation

```json
{ "keyword": "/properties", "instance": "", "value": [ "name", "age" ] }
```

### Valid instance: An object value that defines one of the declared properties and matches the corresponding schema is valid

```json
{ "name": "John Doe" }
```

### Annotation

```json
{ "keyword": "/properties", "instance": "", "value": [ "name" ] }
```

### Valid instance: An empty object value is valid as properties are optional by default

```json
{}
```

### Invalid instance: An object value that defines both declared properties but does not match one of the corresponding schemas is invalid

```json
{ "name": "John Doe", "age": "this should have been an integer" }
```

### Invalid instance: An object value that defines one of the declared properties but does not match its corresponding schema is invalid

```json
{ "name": 999 }
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constrains object instances to forbid a specific property

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "properties": {
    "forbidden": false,
    "permitted": true
  }
}
```

### Valid instance: An object value that only defines the permitted property is valid

```json
{ "permitted": "anything is valid" }
```

### Annotation

```json
{ "keyword": "/properties", "instance": "", "value": [ "foo", "permitted" ] }
```

### Valid instance: An object value that defines any additional property is valid as additional properties are permitted by default

```json
{ "foo": "bar", "baz": 2 }
```

### Annotation

```json
{ "keyword": "/properties", "instance": "", "value": [ "foo", "baz" ] }
```

### Invalid instance: An object value that only defines the forbidden property is invalid

```json
{ "forbidden": 1 }
```

### Invalid instance: An object value that defines the forbidden property alongside other properties is invalid

```json
{ "forbidden": 1, "permitted": 2 }
```
