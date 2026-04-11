# allOf

- Original: [https://www.learnjsonschema.com/draft7/validation/allof/](https://www.learnjsonschema.com/draft7/validation/allof/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/allOf.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/validation/allOf.markdown)
- Specification: [https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.7.1](https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.6.7.1)
- Metaschema: `http://json-schema.org/draft-07/schema#`
- Introduced in: `draft4`

An instance validates successfully against this keyword if it validates successfully against all schemas defined by this keyword's value.

The [`allOf`](index.md) keyword restricts
instances to validate against _every_ given subschema. This keyword can be
thought of as a [logical
conjunction](https://en.wikipedia.org/wiki/Logical_conjunction) (AND)
operation, as instances are valid if they satisfy every constraint of every
subschema (the intersection of the constraints).

> **Best Practice:**
> This keyword typically has a single use case: serving as an
> artificial wrapper for [`$ref`](../../core/ref/index.md) keywords, to
> avoid references overriding sibling keywords. If this is not the case, prefer
> elevating the keywords of every subschema to the outer schema and avoid using
> this keyword.  

This keyword is equivalent to the `&&` operator found in most programming
languages. For example:

```c
bool valid = A && B && C;
```

As a reference, the following boolean [truth
table](https://en.wikipedia.org/wiki/Truth_table) considers the evaluation
result of this keyword given 3 subschemas: A, B, and C.

<table class="table table-borderless border">
  <thead>
    <tr class="table-light">
      <th><code>allOf</code></th>
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
    <tr class="table-danger">
      <td class="fw-bold"><i class="bi bi-x-circle-fill me-1"></i> Invalid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
    </tr>
    <tr class="table-danger">
      <td class="fw-bold"><i class="bi bi-x-circle-fill me-1"></i> Invalid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
    </tr>
    <tr class="table-danger">
      <td class="fw-bold"><i class="bi bi-x-circle-fill me-1"></i> Invalid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
    </tr>
    <tr class="table-danger">
      <td class="fw-bold"><i class="bi bi-x-circle-fill me-1"></i> Invalid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
    </tr>
    <tr class="table-danger">
      <td class="fw-bold"><i class="bi bi-x-circle-fill me-1"></i> Invalid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-x-circle"></i> Invalid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
    </tr>
    <tr class="table-danger">
      <td class="fw-bold"><i class="bi bi-x-circle-fill me-1"></i> Invalid</td>
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

### Schema: A schema that constrains instances with two internally referenced schemas

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "allOf": [
    { "$ref": "#/definitions/foo" },
    { "$ref": "#/definitions/bar" }
  ],
  "definitions": {
    "foo": { "type": "number" },
    "bar": { "type": "integer" }
  }
}
```

### Valid instance: A value that matches both subschemas is valid

```json
12345
```

### Invalid instance: A value that only matches one of the subschemas is invalid

```json
3.14
```

### Invalid instance: A value that does not match any of the subschemas is invalid

```json
"Hello World"
```
