# anyOf

- Original: [https://www.learnjsonschema.com/2020-12/applicator/anyof/](https://www.learnjsonschema.com/2020-12/applicator/anyof/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/applicator/anyOf.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/applicator/anyOf.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-core.html#section-10.2.1.2](https://json-schema.org/draft/2020-12/json-schema-core.html#section-10.2.1.2)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/applicator`
- Introduced in: `draft4`

An instance validates successfully against this keyword if it validates successfully against at least one schema defined by this keyword's value.
The [`anyOf`](anyof.md) keyword restricts
instances to validate against _at least one_ (but potentially multiple) of the
given subschemas. This keyword represents a [logical
disjunction](https://en.wikipedia.org/wiki/Logical_disjunction) (OR) operation,
as instances are valid if they satisfy the constraints of one or more
subschemas (the union of the constraints).

> **Digging Deeper:**
> Keep in mind that when collecting annotations, the JSON
> Schema implementation will need to exhaustively evaluate every subschema past
> the first match instead of short-circuiting validation, potentially introducing
> additional computational overhead.
>
> For example, consider 3 subschemas where the instance validates against the
> first. When not collecting annotations, validation will stop after evaluating
> the first subschema. However, when collecting annotations, evaluation will have
> to proceed past the first subschema in case the others emit
> annotations.

This keyword is equivalent to the `||` operator found in most programming
languages. For example:

```c
bool valid = A || B || C;
```

As a reference, the following boolean [truth
table](https://en.wikipedia.org/wiki/Truth_table) considers the evaluation
result of this keyword given 3 subschemas: A, B, and C.

<table class="table table-borderless border">
  <thead>
    <tr class="table-light">
      <th><code>anyOf</code></th>
      <th>Subschema A</th>
      <th>Subschema B</th>
      <th>Subschema C</th>
    </tr>
  </thead>
  <tbody>
    <tr class="table-danger">
      <td class="fw-bold"><i class="bi bi-x-circle-fill me-1"></i> Invalid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
    </tr>
    <tr class="table-success">
      <td class="fw-bold"><i class="bi bi-check-circle-fill me-1"></i> Valid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
    </tr>
    <tr class="table-success">
      <td class="fw-bold"><i class="bi bi-check-circle-fill me-1"></i> Valid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
    </tr>
    <tr class="table-success">
      <td class="fw-bold"><i class="bi bi-check-circle-fill me-1"></i> Valid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
    </tr>
    <tr class="table-success">
      <td class="fw-bold"><i class="bi bi-check-circle-fill me-1"></i> Valid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
    </tr>
    <tr class="table-success">
      <td class="fw-bold"><i class="bi bi-check-circle-fill me-1"></i> Valid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
    </tr>
    <tr class="table-success">
      <td class="fw-bold"><i class="bi bi-check-circle-fill me-1"></i> Valid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
    </tr>
    <tr class="table-success">
      <td class="fw-bold"><i class="bi bi-check-circle-fill me-1"></i> Valid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
    </tr>
  </tbody>
</table>

## Examples

### Schema: A schema that constrains object instances to require at least one of the given properties

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "anyOf": [
    { "required": [ "foo" ] },
    { "required": [ "bar" ] }
  ]
}
```

### Valid instance: A value that only matches the first subschema is valid

```json
{ "foo": 1 }
```

### Valid instance: A value that only matches the second subschema is valid

```json
{ "bar": 2 }
```

### Valid instance: A value that matches every subschema is valid

```json
{ "foo": 1, "bar": 2 }
```

### Invalid instance: A value that does not match any of the subschemas is invalid

```json
{ "extra": 4 }
```

### Schema: A schema that constrains instances with logical disjunctions that emit annotations

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "anyOf": [
    { "title": "Branch #1", "type": "number" },
    { "title": "Branch #2", "type": "string" },
    { "title": "Branch #3", "type": "integer" }
  ]
}
```

### Valid instance: A value that only matches the first subschema receives the first annotation

```json
3.14
```

### Annotation

```json
{ "keyword": "/anyOf/0/title", "instance": "", "value": [ "Branch #1" ] }
```

### Valid instance: A value that matches two subschemas receives both annotations

```json
12345
```

### Annotation

```json
{ "keyword": "/anyOf/0/title", "instance": "", "value": [ "Branch #1" ] }
{ "keyword": "/anyOf/2/title", "instance": "", "value": [ "Branch #3" ] }
```

### Invalid instance: A value that does not match any of the subschemas is invalid and receives no annotations

```json
{ "foo": 1 }
```
