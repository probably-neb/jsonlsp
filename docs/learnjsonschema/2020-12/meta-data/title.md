# title

- Original: [https://www.learnjsonschema.com/2020-12/meta-data/title/](https://www.learnjsonschema.com/2020-12/meta-data/title/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/meta-data/title.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/meta-data/title.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-9.1](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-9.1)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/meta-data`
- Introduced in: `draft1`

A preferably short description about the purpose of the instance described by the schema.
The [`title`](title.md) keyword is a placeholder for a concise human-readable string
summary of what a schema or any of its subschemas are about. This keyword does
not affect validation, but the evaluator will collect its value as an
annotation.

> **Best Practice:**
> We heavily recommend to declare this keyword at the top level of every schema,
> as a human-readable introduction to what the schema is about.
>
> When doing so, note that the JSON Schema specification does not impose or
> recommend a maximum length for this keyword. However, it is common practice to
> stick to [Git commit message
> title](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
> conventions and set it to a capitalised string of *50 characters or less*. If
> you run out of space, you can move the additional information to the
> [`description`](description.md) keyword.

> **Common Pitfall:**
> Tooling makers must be careful when statically traversing schemas in search of
> occurrences of this keyword. It is possible for schemas to make use of this
> keyword behind conditional operators, references, or any other type of keyword
> that makes it hard or even impossible to correctly locate these values without
> fully evaluating the schema against an instance. The only bullet proof method
> is through annotation collection.

## Examples

### Schema: A schema that declares a top level title

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Even Number",
  "type": "number",
  "multipleOf": 2
}
```

### Valid instance: An even number value is valid and annotations are emitted

```json
10
```

### Annotation

```json
{ "keyword": "/title", "instance": "", "value": "Even number" }
```

### Invalid instance: An odd number value is invalid and no annotations are emitted

```json
7
```

### Schema: A schema that declares conditional refined titles for the same instance location

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Number",
  "type": "number",
  "if": { "multipleOf": 2 },
  "then": { "title": "Even Number" },
  "else": { "title": "Odd Number" }
}
```

### Valid instance: An even number value is valid and both the top level and even annotations are emitted

```json
10
```

### Annotation

```json
{ "keyword": "/title", "instance": "", "value": "Number" }
{ "keyword": "/then/title", "instance": "", "value": "Even Number" }
```

### Valid instance: An odd number value is valid and both the top level and odd annotations are emitted

```json
7
```

### Annotation

```json
{ "keyword": "/title", "instance": "", "value": "Number" }
{ "keyword": "/else/title", "instance": "", "value": "Odd Number" }
```

### Invalid instance: A non-number value is invalid and no annotations are emitted

```json
"Hello World"
```
