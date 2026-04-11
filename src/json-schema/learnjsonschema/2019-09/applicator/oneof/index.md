# oneOf

- Original: [https://www.learnjsonschema.com/2019-09/applicator/oneof/](https://www.learnjsonschema.com/2019-09/applicator/oneof/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/oneOf.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/applicator/oneOf.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.2.1.3](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.9.2.1.3)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/applicator`
- Introduced in: `draft4`

An instance validates successfully against this keyword if it validates successfully against exactly one schema defined by this keyword's value.

The [`oneOf`](index.md) keyword restricts
instances to validate against _exactly one_ (and only one) of the given
subschemas and fail on the rest. This keyword represents a [logical exclusive
disjunction](https://en.wikipedia.org/wiki/Exclusive_or) (XOR) operation.
In practice, the vast majority of schemas don't require exclusive disjunction
semantics but a simple disjunction. If you are not sure, the [`anyOf`](../anyof/index.md) keyword is probably a better fit.

> **Common Pitfall:**
> Avoid this keyword unless you absolutely need exclusive disjunction
> semantics, which is rarely the case. As its name implies, this keyword
> enforces the instance to be valid against **only one of its subschemas**.
> Therefore, a JSON Schema implementation will exhaustively evaluate every
> subschema to make sure the rest fails, potentially introducing unnecessary
> computational overhead.

This keyword is equivalent to the following complex boolean construct that
combines the `||`, `&&`, and `!` operators found in most programming
languages:

```c
bool valid = (A && !B && !C) || (!A && B && !C) || (!A && !B && C);
```

As a reference, the following boolean [truth
table](https://en.wikipedia.org/wiki/Truth_table) considers the evaluation
result of this keyword given 3 subschemas: A, B, and C.

<table class="table table-borderless border">
  <thead>
    <tr class="table-light">
      <th><code>oneOf</code></th>
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
    <tr class="table-danger">
      <td class="fw-bold"><i class="bi bi-x-circle-fill me-1"></i> Invalid</td>
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
    <tr class="table-danger">
      <td class="fw-bold"><i class="bi bi-x-circle-fill me-1"></i> Invalid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
      <td><i class="bi bi-check-circle"></i> Valid</td>
    </tr>
  </tbody>
</table>

## Examples

### Schema: A schema that constrains object instances to require only one of the given properties

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "oneOf": [
    { "required": [ "foo" ] },
    { "required": [ "bar" ] },
    { "required": [ "baz" ] }
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

### Invalid instance: A value that matches more than one subschema is invalid

```json
{ "foo": 1, "bar": 2 }
```

### Invalid instance: A value that matches every subschema is invalid

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Invalid instance: A value that does not match any of the subschemas is invalid

```json
{ "extra": 4 }
```
