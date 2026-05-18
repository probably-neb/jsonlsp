# if

- Original: [https://www.learnjsonschema.com/2019-09/applicator/if/](https://www.learnjsonschema.com/2019-09/applicator/if/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/if.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/if.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.2.2.1](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.2.2.1)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/applicator`
- Introduced in: `draft7`

This keyword declares a condition based on the validation result of the given schema.
The [`if`](if.md) keyword introduces a
subschema whose evaluation result restricts instances to validate against the
[`then`](then.md) or [`else`](else.md) sibling subschemas (if present). Note that the
evaluation outcome of this subschema controls which other subschema to apply
(if any) but has no direct effect on the overall validation result.

> **Best Practice:**
>  The [`if`](if.md),
> [`then`](then.md), and [`else`](else.md) keywords can be thought of as imperative variants
> of the [`anyOf`](anyof.md) keyword, and both
> approaches are equally capable of describing arbitrary conditions. Choose the
> one that more elegantly describes your desired
> constraints.

> **Digging Deeper:**
>  This keyword has no effect if neither the [`then`](then.md) nor [`else`](else.md) keywords are declared within the same subschema.
> However, when collecting annotations, the JSON Schema implementation will still
> need to evaluate the [`if`](if.md) keyword in
> case its subschema emits annotations. 

The [`if`](if.md), [`then`](then.md), and [`else`](else.md) keywords are equivalent to the `?` and `:` ternary
conditional operators found in most programming languages. For example:

```c
bool valid = if_schema ? then_schema : else_schema;
```

JSON Schema is a [constraint-driven
language](https://modern-json-schema.com/json-schema-is-a-constraint-system).
Therefore, omitting either the [`then`](then.md) or the [`else`](else.md) keywords is equivalent to setting the
corresponding part of the ternary conditional operation to the boolean true.
In other words, undefined consequent or alternative paths lead to success.
For example:

```c
// If `then` is missing
bool valid = if_schema ? true : else_schema;
// If `else` is missing
bool valid = if_schema ? then_schema : true;
```

## Examples

### Schema: A schema that constrains numeric instances to be positive when they are even numbers and negative otherwise

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "if": { "multipleOf": 2 },
  "then": { "minimum": 0 },
  "else": { "exclusiveMaximum": 0 }
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

### Invalid instance: An odd number value that is positive is invalid

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

### Schema: A schema that constrains numeric instances to be positive when they are even numbers

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
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

### Schema: A schema that constrains numeric instances to be positive when they are odd numbers

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "if": { "multipleOf": 2 },
  "else": { "minimum": 0 }
}
```

### Valid instance: An even number value that is positive is valid

```json
10
```

### Valid instance: An even number value that is negative is valid

```json
-2
```

### Valid instance: An odd number value that is positive is valid

```json
7
```

### Invalid instance: An odd number value that is negative is invalid

```json
-3
```

### Schema: A conditional schema that emits an annotation without a consequent or alternative

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "if": { "items": { "type": "string" } }
}
```

### Valid instance: A value that matches the conditional subschema is valid and receives the annotation

```json
[ "foo", "bar", "baz" ]
```

### Annotation

```json
{ "keyword": "/if/items", "instance": "", "value": true }
```

### Valid instance: A value that does not match the conditional subschema is still valid but receives no annotation

```json
[ 1, 2, 3 ]
```
