# description

- Original: [https://www.learnjsonschema.com/draft6/validation/description/](https://www.learnjsonschema.com/draft6/validation/description/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/description.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft6/validation/description.markdown)
- Specification: [https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.7.2](https://json-schema.org/draft-06/draft-wright-json-schema-validation-01#rfc.section.7.2)
- Metaschema: `http://json-schema.org/draft-06/schema#`
- Introduced in: `draft1`

An explanation about the purpose of the instance described by the schema.

The [`description`](index.md) keyword is a
placeholder for a longer human-readable string summary of what a schema or any
of its subschemas are about. This keyword is merely descriptive and does not
affect validation.

> **Best Practice:**
> We heavily recommend to declare this keyword at the top level of every schema,
> as a human-readable longer description of what the schema is about.
> Note that this keyword is meant to be to be used in conjunction with the
> [`title`](../title/index.md) keyword. The idea is to
> augment the short summary with a longer description, and not to avoid the
> concise summary altogether.

> **Common Pitfall:**
> Tooling makers must be careful when statically traversing schemas in search of
> occurrences of this keyword. It is possible for schemas to make use of this
> keyword behind conditional operators, references, or any other type of keyword
> that makes it hard or even impossible to correctly locate these values in all
> cases.

## Examples

### Schema: A schema that declares a top level description alongside a short title

```json
{
  "$schema": "http://json-schema.org/draft-06/schema#",
  "title": "Even Number",
  "description": "This schema describes an even number",
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

### Schema: A schema that declares conditional descriptions alongside a top level title

```json
{
  "$schema": "http://json-schema.org/draft-06/schema#",
  "title": "Number",
  "type": "number",
  "anyOf": [
    {
      "description": "This is an even number",
      "multipleOf": 2
    },
    {
      "description": "This is an odd number",
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
