# title

- Original: [https://www.learnjsonschema.com/draft4/validation/title/](https://www.learnjsonschema.com/draft4/validation/title/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/title.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/title.markdown)
- Specification: [https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.6.1](https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.6.1)
- Metaschema: `http://json-schema.org/draft-04/schema#`
- Introduced in: `draft1`

A preferably short description about the purpose of the instance described by the schema.

The [`title`](title.md) keyword is a placeholder
for a concise human-readable string summary of what a schema or any of its
subschemas are about. This keyword is merely descriptive and does not affect
validation.

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

## Examples

### Schema: A schema that declares a top level title

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "Even Number",
  "type": "number",
  "multipleOf": 2
}
```

### Valid instance: An even number value is valid

```json
10
```

### Invalid instance: An odd number value is invalid

```json
7
```

### Schema: A schema that declares conditional refined titles for the same instance location

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "Number",
  "type": "number",
  "anyOf": [
    {
      "title": "Even Number",
      "multipleOf": 2
    },
    {
      "title": "Odd Number",
      "not": {
        "multipleOf": 2
      }
    }
  ]
}
```

### Valid instance: An even number value is valid

```json
10
```

### Valid instance: An odd number value is valid

```json
7
```

### Invalid instance: A non-number value is invalid

```json
"Hello World"
```
