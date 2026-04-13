# $dynamicRef

- Original: [https://www.learnjsonschema.com/2020-12/core/dynamicref/](https://www.learnjsonschema.com/2020-12/core/dynamicref/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/core/dynamicRef.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/core/dynamicRef.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-core.html#section-8.2.3.1](https://json-schema.org/draft/2020-12/json-schema-core.html#section-8.2.3.1)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/core`
- Introduced in: `2020-12`

This keyword is used to reference an identified schema, deferring the full resolution until runtime, at which point it is resolved each time it is encountered while evaluating an instance.

The [`$dynamicRef`](dynamicref.md) keyword is an
extension of the [`$ref`](ref.md) keyword that enables
a schema to reference another schema by its dynamic anchor, as declared by the
[`$dynamicAnchor`](dynamicanchor.md) keyword.  When
resolving a dynamic anchor using this keyword, the base URI of the origin is
not considered. Instead, the evaluator looks in the [dynamic
scope](https://json-schema.org/blog/posts/dynamicref-and-generics) and jumps to
the first encountered occurrence of the given dynamic anchor in the [stack of
schema
resources](https://json-schema.org/blog/posts/understanding-lexical-dynamic-scopes#the-dynamic-scope-as-a-stack)
traversed so far.

In other words, **think of a schema declaring a dynamic reference as a
reference that considers that its destination might have been re-defined by a
parent schema**.  For example, a schema that dynamically references an anchor
`foo` says: _"jump to the location set by the `foo` anchor, but if there are
overridden variants of it, jump to the first of those instead"_.

> **Best Practice:**
> Use dynamic references when you need to define generic and extensible schemas.
> In fact, the dynamic referencing mechanism is a direct translation of generic
> programming facilities like [C++ template
> parameters](https://en.cppreference.com/w/cpp/language/template_parameters) and
> [Java generics](https://en.wikipedia.org/wiki/Generics_in_Java) to JSON Schema.
> See the blog post [Using Dynamic References to Support Generic
> Types](https://json-schema.org/blog/posts/dynamicref-and-generics#using-dynamic-references-to-support-generic-types)
> by Greg Dennis (co-author of the JSON Schema specification) for a hands-on
> discussion of this concept.

> **Digging Deeper:**
> The official JSON Schema meta-schemas define, by convention, a dynamic anchor
> called `meta`. This is a fundamental building block for schema extensibility.
> The meta-schema of every vocabulary (official or third-party) hooks into this
> dynamic anchor to extend the recursive definition of what constitutes a valid
> schema for the given dialect.
>
> More specifically, by relying on the `meta` dynamic anchor, a vocabulary
> meta-schema can validate the presence of a new keyword and have those
> constraints be automatically discovered and applied by any applicator of any
> other vocabulary (even future ones).

> **Common Pitfall:**
> As a fallback, the specification allows the use of this keyword to reference
> static resources and non-dynamic anchors. However, to avoid confusion and keep
> your schemas easy to understand, don't rely on this fallback behaviour. Only
> make use of this keyword to reference dynamic anchors set by the
> [`$dynamicAnchor`](dynamicanchor.md) keyword, without
> making use of any URI component (other than the fragment) as part of the
> reference.

To debug which dynamic anchor the evaluation process is jumping to, try the
[`jsonschema
validate`](https://github.com/sourcemeta/jsonschema/blob/main/docs/validate.markdown)
command with the `--trace` option. This option prints a trace of every step in
the evaluation process alongside the corresponding keywords and their
respective locations, letting you know which destination was preferred when
encountering a dynamic reference. For example:

```sh
$ jsonschema validate string-list.json instance.json --resolve generic-list.json --trace
...

-> (push) "/$ref/items/$dynamicRef" (ControlDynamicAnchorJump)
   at "/0"
   at keyword location "https://example.com/generic-list#/items/$dynamicRef"
   at vocabulary "https://json-schema.org/draft/2020-12/vocab/core"

-> (push) "/$ref/items/$dynamicRef/type" (AssertionTypeStrict)
   at "/0"
   at keyword location "https://example.com/string-list#/$defs/generic-list-item/type"
   at vocabulary "https://json-schema.org/draft/2020-12/vocab/validation"

...
```

## Examples

### Schema: A generic schema that describes an array where the items definition (by default anything) can be overridden through a dynamic anchor

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://example.com/generic-list",
  "type": "array",
  "items": {
    "$dynamicRef": "#generic-list-item"
  },
  "$defs": {
    "default": {
      "$comment": "This is a default declaration to satisfy the bookending requirement",
      "$dynamicAnchor": "generic-list-item"
    }
  }
}
```

### Valid instance: An empty array value is valid

```json
[]
```

### Valid instance: An array value with arbitrary items is valid

```json
[ 1, "foo", false ]
```

### Annotation

```json
{ "keyword": "/items", "instance": "", "value": true }
```

### Invalid instance: A non-array value is invalid

```json
"Hello World"
```

### Schema: A schema that specialises the previous generic schema to declare that array items must be strings

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://example.com/string-list",
  "$ref": "https://example.com/generic-list",
  "$defs": {
    "generic-list-item": {
      "$dynamicAnchor": "generic-list-item",
      "type": "string"
    }
  }
}
```

### Valid instance: An empty array value is valid

```json
[]
```

### Invalid instance: An array value with arbitrary items is invalid

```json
[ 1, "foo", false ]
```

### Valid instance: An array value with string items is valid

```json
[ "foo", "bar", "baz" ]
```

### Annotation

```json
{ "keyword": "/$ref/items", "instance": "", "value": true }
```

### Invalid instance: A non-array value is invalid

```json
"Hello World"
```
