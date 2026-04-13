# then

- Original: [https://www.learnjsonschema.com/draft7/validation/then/](https://www.learnjsonschema.com/draft7/validation/then/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/then.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/then.markdown)
- Specification: [https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.6.2](https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.6.2)
- Metaschema: `http://json-schema.org/draft-07/schema#`
- Introduced in: `draft7`

When [`if`](/draft7/validation/if) is present, and the instance successfully validates against its subschema, then validation succeeds if the instance also successfully validates against this keyword's subschema.

The [`then`](then.md) keyword restricts instances
to validate against the given subschema if the [`if`](if.md) sibling keyword successfully validated against the
instance.

> **Common Pitfall:**
>  This keyword has no effect if the [`if`](if.md) keyword is not declared within the same
> subschema. 

> **Best Practice:**
>  The [`if`](if.md),
> [`then`](then.md), and [`else`](else.md) keywords can be thought of as imperative variants
> of the [`anyOf`](anyof.md) keyword, and both
> approaches are equally capable of describing arbitrary conditions. Choose the
> one that more elegantly describes your desired
> constraints.

## Examples

### Schema: A schema that constrains numeric instances to be positive when they are even numbers

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
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

### Schema: A schema that uses a title for even numbers

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "if": { "multipleOf": 2 },
  "then": { "title": "The value is an even number" }
}
```

### Valid instance: An even number value is valid

```json
10
```

### Valid instance: An odd number value is valid

```json
5
```
