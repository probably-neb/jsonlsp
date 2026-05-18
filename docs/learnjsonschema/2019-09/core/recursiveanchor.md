# $recursiveAnchor

- Original: [https://www.learnjsonschema.com/2019-09/core/recursiveanchor/](https://www.learnjsonschema.com/2019-09/core/recursiveanchor/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/core/recursiveAnchor.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2019-09/core/recursiveAnchor.markdown)
- Specification: [https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.8.2.4.2.2](https://json-schema.org/draft/2019-09/draft-handrews-json-schema-02#rfc.section.8.2.4.2.2)
- Metaschema: `https://json-schema.org/draft/2019-09/meta/core`
- Introduced in: `2019-09`

This keyword is used to dynamically identify a base URI at runtime by marking where such a calculation can start, and where it stops.
The [`$recursiveAnchor`](recursiveanchor.md) keyword is
an extension of the [`$anchor`](anchor.md) keyword
that, when set to `true`, associates a subschema with a special _empty_ URI
fragment identifier and records this association in the [dynamic
scope](https://json-schema.org/blog/posts/dynamicref-and-generics).  When
resolving this anchor using the [`$recursiveRef`](recursiveref.md) keyword, the base URI of the origin is not
considered. Instead, evaluation jumps to the first encountered occurrence of the
given recursive anchor in the [stack of schema
resources](https://json-schema.org/blog/posts/understanding-lexical-dynamic-scopes#the-dynamic-scope-as-a-stack)
traversed so far.

> **Best Practice:**
>  This advanced feature was only designed for supporting
> meta-schemas.  Avoid using this keyword if you are not defining a meta-schema.

> **Digging Deeper:**
> The official JSON Schema meta-schemas all define the recursive anchor.  as a
> fundamental building block for schema extensibility.  The meta-schema of every
> vocabulary (official or third-party) hooks into the recursive anchor to extend
> the recursive definition of what constitutes a valid schema for the given
> dialect.
>
> More specifically, by relying on the recursive anchor, a vocabulary
> meta-schema can validate the presence of a new keyword and have those
> constraints be automatically discovered and applied by any applicator of any
> other vocabulary (even future ones).

> **Common Pitfall:**
> The schema resource from where the recursive anchor lookup originates _must_
> declare the recursive anchor. Otherwise, the schema would be unusable until
> another schema provides a definition for the recursive anchor. This rule is
> informally referred to as the _bookending requirement_.

To debug which recursive anchor the evaluation process is jumping to, try the
[`jsonschema
validate`](https://github.com/sourcemeta/jsonschema/blob/main/docs/validate.markdown)
command with the `--trace` option. This option prints a trace of every step in
the evaluation process alongside the corresponding keywords and their
respective locations, letting you know which destination was preferred when
encountering a recursive reference. For example:

```sh
$ jsonschema validate custom-metaschema.json schema.json --trace
...

-> (push) "/$ref/allOf/1/$ref/properties/additionalProperties/$recursiveRef" (ControlDynamicAnchorJump)
   at "/additionalProperties"
   at keyword location "https://json-schema.org/draft/2019-09/meta/applicator#/properties/additionalProperties/$recursiveRef"
   at vocabulary "https://json-schema.org/draft/2019-09/vocab/core"

-> (push) "/$ref/allOf/1/$ref/properties/additionalProperties/$recursiveRef/properties" (LogicalWhenType)
   at "/additionalProperties"
   at keyword location "https://example.com/custom-metaschema#/properties"
   at vocabulary "https://json-schema.org/draft/2019-09/vocab/applicator"
...
```

## Examples

### Schema: A custom meta-schema that extends the JSON Schema 2019-09 dialect with a custom keyword

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "$id": "https://example.com/custom-metaschema",
  "$recursiveAnchor": true,
  "$ref": "https://json-schema.org/draft/2019-09/schema",
  "properties": {
    "my-custom-keyword": { "type": "string" }
  }
}
```

### Valid instance: An object with a top-level occurrence of the custom keyword is valid

```json
{ "my-custom-keyword": "foo" }
```

### Annotation

```json
{ "keyword": "/properties", "instance": "", "value": [ "my-custom-keyword" ] }
```

### Valid instance: An object with a nested occurrence of the custom keyword is valid

```json
{ "additionalProperties": { "my-custom-keyword": "foo" } }
```

### Annotation

```json
{ "keyword": "/properties", "instance": "/additionalProperties", "value": [ "my-custom-keyword" ] }
```

### Invalid instance: An object with an incorrect nested occurrence of the custom keyword is invalid

```json
{ "additionalProperties": { "my-custom-keyword": 1 } }
```
