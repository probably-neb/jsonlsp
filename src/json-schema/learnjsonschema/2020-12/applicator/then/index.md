# then

- Original: [https://www.learnjsonschema.com/2020-12/applicator/then/](https://www.learnjsonschema.com/2020-12/applicator/then/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/applicator/then.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/applicator/then.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-core.html#section-10.2.2.2](https://json-schema.org/draft/2020-12/json-schema-core.html#section-10.2.2.2)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/applicator`
- Introduced in: `draft7`

When [`if`](/2020-12/applicator/if) is present, and the instance successfully validates against its subschema, then validation succeeds if the instance also successfully validates against this keyword's subschema.

The [`then`](index.md) keyword restricts
instances to validate against the given subschema if the {{<link keyword="if"
vocabulary="applicator">}} sibling keyword successfully validated against the
instance.

> **Common Pitfall:**
>  This keyword has no effect if the [`if`](../../../if/index.md)
> keyword is not declared within the same subschema.  

> **Best Practice:**
>  The [`if`](../../../if/index.md), [`then`](../../../then/index.md),
> and [`else`](../../../else/index.md) keywords can be thought of as imperative
> variants of the [`anyOf`](../../../anyOf/index.md) keyword, and both approaches are
> equally capable of describing arbitrary conditions. Choose the one that more
> elegantly describes your desired constraints.

## Examples

### Schema: A schema that constrains numeric instances to be positive when they are even numbers

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "if": { "multipleOf": 2 },
  "then": { "minimum": 0 }
}
```

### Valid instance: An even number value that is positive is valid

```json
10
```

### Invalid instance: An even number value that is negative is invalid

```json
-2
```

### Valid instance: An odd number value that is positive is valid

```json
7
```

### Valid instance: An odd number value that is negative is valid

```json
-3
```

### Valid instance: A non-number value is valid

```json
"Hello World"
```

### Schema: A schema that emits a simple annotation when a numeric value is even

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "if": { "multipleOf": 2 },
  "then": { "title": "The value is an even number" }
}
```

### Valid instance: An even number value is valid and emits an annotation

```json
10
```

### Annotation

```json
{ "keyword": "/then/title", "instance": "", "value": [ "The value is an even number" ] }
```

### Valid instance: An odd number value is valid but does not emit an annotation

```json
5
```
