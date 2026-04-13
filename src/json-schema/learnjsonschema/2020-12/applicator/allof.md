# allOf

- Original: [https://www.learnjsonschema.com/2020-12/applicator/allof/](https://www.learnjsonschema.com/2020-12/applicator/allof/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/applicator/allOf.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/applicator/allOf.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-core.html#section-10.2.1.1](https://json-schema.org/draft/2020-12/json-schema-core.html#section-10.2.1.1)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/applicator`
- Introduced in: `draft4`

An instance validates successfully against this keyword if it validates successfully against all schemas defined by this keyword's value.

The [`allOf`](allof.md) keyword restricts
instances to validate against _every_ given subschema. This keyword can be
thought of as a [logical
conjunction](https://en.wikipedia.org/wiki/Logical_conjunction) (AND)
operation, as instances are valid if they satisfy every constraint of every
subschema (the intersection of the constraints).

> **Common Pitfall:**
>  Wrapping a single instance of the
> [`$ref`](../core/ref.md) or [`$dynamicRef`](../core/dynamicref.md) keyword in an [`allOf`](allof.md) operator is an anti-pattern.
>
> This practice has historical roots. In JSON Schema [Draft 7](/draft7) and
> earlier versions, any subschema declaring the [`$ref`](../core/ref.md) keyword was considered to be a _reference object_ and
> any other sibling keyword was silently ignored. As a consequence, subschemas
> with references that made use of other keywords had to artificially wrap the
> reference into its own subschema. 

> **Best Practice:**
> This keyword typically has a single use case: combining
> _multiple_ schemas through the use of (internal or external) references. If
> this is not the case, prefer elevating the keywords of every subschema to the
> outer schema and avoid using this keyword.  

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

### Schema: A schema that constrains instances with two internally referenced
schemas

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "allOf": [
    { "$ref": "#/$defs/foo" },
    { "$ref": "#/$defs/bar" }
  ],
  "$defs": {
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
