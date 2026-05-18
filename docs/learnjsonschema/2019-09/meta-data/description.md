# description

- Original: [https://www.learnjsonschema.com/2019-09/meta-data/description/](https://www.learnjsonschema.com/2019-09/meta-data/description/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/meta-data/description.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/meta-data/description.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.9.1](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-validation-02#rfc.section.9.1)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/meta-data`
- Introduced in: `draft1`

An explanation about the purpose of the instance described by the schema.
The [`description`](description.md) keyword is a placeholder for a longer human-readable string
summary of what a schema or any of its subschemas are about. This keyword does
not affect validation, but the evaluator will collect its value as an
annotation.

> **Best Practice:**
> We heavily recommend to declare this keyword at the top level of every schema,
> as a human-readable longer description of what the schema is about.
> Note that this keyword is meant to be to be used in conjunction with the
> [`title`](title.md) keyword. The idea is to
> augment the short summary with a longer description, and not to avoid the
> concise summary altogether.

> **Common Pitfall:**
> Tooling makers must be careful when statically traversing schemas in search of
> occurrences of this keyword. It is possible for schemas to make use of this
> keyword behind conditional operators, references, or any other type of keyword
> that makes it hard or even impossible to correctly locate these values without
> fully evaluating the schema against an instance. The only bullet proof method
> is through annotation collection.

## Examples

### Schema: A schema that declares a top level description alongside a short title

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "title": "Even Number",
  "description": "This schema describes an even number",
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
{ "keyword": "/description", "instance": "", "value": "This schema describes an even number" }
```

### Invalid instance: An odd number value is invalid and no annotations are emitted

```json
7
```

### Schema: A schema that declares conditional descriptions alongside a top level title

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "title": "Number",
  "type": "number",
  "if": { "multipleOf": 2 },
  "then": { "description": "This is an even number" },
  "else": { "description": "This is an odd number" }
}
```

### Valid instance: An even number value is valid and the corresponding description annotation is emitted

```json
10
```

### Annotation

```json
{ "keyword": "/title", "instance": "", "value": "Number" }
{ "keyword": "/then/description", "instance": "", "value": "This is an even number" }
```

### Valid instance: An odd number value is valid and the corresponding description annotation is emitted

```json
7
```

### Annotation

```json
{ "keyword": "/title", "instance": "", "value": "Number" }
{ "keyword": "/else/description", "instance": "", "value": "This is an odd number" }
```

### Invalid instance: A non-number value is invalid and no annotations are emitted

```json
"Hello World"
```
