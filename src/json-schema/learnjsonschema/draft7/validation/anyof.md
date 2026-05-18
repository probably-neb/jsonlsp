# anyOf

- Original: [https://www.learnjsonschema.com/draft7/validation/anyof/](https://www.learnjsonschema.com/draft7/validation/anyof/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/anyOf.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/anyOf.markdown)
- Specification: [https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.7.2](https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.7.2)
- Metaschema: `http://json-schema.org/draft-07/schema#`
- Introduced in: `draft4`

An instance validates successfully against this keyword if it validates successfully against at least one schema defined by this keyword's value.
The [`anyOf`](anyof.md) keyword restricts
instances to validate against _at least one_ (but potentially multiple) of the
given subschemas. This keyword represents a [logical
disjunction](https://en.wikipedia.org/wiki/Logical_disjunction) (OR)
operation, as instances are valid if they satisfy the constraints of one or
more subschemas (the union of the constraints).

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
  "$schema": "http://json-schema.org/draft-07/schema#",
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
