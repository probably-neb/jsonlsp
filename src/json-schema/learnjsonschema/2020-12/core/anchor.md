# $anchor

- Original: [https://www.learnjsonschema.com/2020-12/core/anchor/](https://www.learnjsonschema.com/2020-12/core/anchor/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/core/anchor.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/core/anchor.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-core.html#section-8.2.2](https://json-schema.org/draft/2020-12/json-schema-core.html#section-8.2.2)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/core`
- Introduced in: `2019-09`

This keyword is used to create plain name fragments that are not tied to any particular structural location for referencing purposes, which are taken into consideration for static referencing.
The [`$anchor`](anchor.md) keyword associates a subschema with the
given URI fragment identifier, which can be referenced using the [`$ref`](ref.md) keyword. The fragment identifier is resolved
against the URI of the schema resource. Therefore, using this keyword to
declare the same anchor more than once within the same schema resource results
in an invalid schema.

> **Digging Deeper:**
> JSON Schema anchors were inspired by how web browsers [automatically
> scroll](https://html.spec.whatwg.org/multipage/browsing-the-web.html#scroll-to-the-fragment-identifier)
> to HTML elements given a matching URL fragment identifier.
>
> For example, a company website at `https://example.com` may define a contact
> form enclosed in an HTML element such as `<section id="contact">`.  When the
> user visits the `https://example.com#contact` URL, the web browser will
> automatically scroll to the location of such element. Furthermore, the website
> can move the contact form to a different location within the same page and the
> `https://example.com#contact` URL will continue directing the web browser to
> scroll to the correct location.

> **Best Practice:**
> This keyword rarely comes up in practice. The only common use in the wild we
> are aware of is to mark helpers in a location-independent manner, so the helper
> itself can be moved to a different location within the schema without breaking
> existing references to it.

> **Common Pitfall:**
> This keyword declares fragment identifiers (a.k.a. anchors) for use _within_
> the same schema file or resource.  Defining schema files or resources that
> reference anchors of _other_ schema files or resources is considered to be an
> anti-pattern. If you want to share a subschema across multiple schema files or
> resources, that common schema should be a standalone schema file or resource
> itself.

To debug anchors and how JSON Schema is interpreting your relative URIs, try
the [`jsonschema
inspect`](https://github.com/sourcemeta/jsonschema/blob/main/docs/inspect.markdown)
command. This command prints detailed information about each schema reference
and of each anchor in the schema. For example:

```sh
$ jsonschema inspect schema.json

...

(ANCHOR) URI: https://example.com/person#internal-string
    Type              : Static
    Root              : https://example.com/person
    Pointer           : /$defs/nonEmptyString
    Base              : https://example.com/person
    Relative Pointer  : /$defs/nonEmptyString
    Dialect           : https://json-schema.org/draft/2020-12/schema
    Base Dialect      : https://json-schema.org/draft/2020-12/schema
    Parent            :
    Instance Location : /firstName
    Instance Location : /lastName

...

(REFERENCE) ORIGIN: /properties/firstName/$ref
    Type              : Static
    Destination       : https://example.com/person#internal-string
    - (w/o fragment)  : https://example.com/person
    - (fragment)      : internal-string

...
```

## Examples

### Schema: A schema that declares a helper schema associated with a location-independent identifier

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://example.com/person",
  "properties": {
    "firstName": {
      "$comment": "As a relative reference",
      "$ref": "#internal-string"
    },
    "lastName": {
      "$comment": "As an absolute reference",
      "$ref": "https://example.com/person#internal-string"
    }
  },
  "$defs": {
    "nonEmptyString": {
      "$anchor": "internal-string",
      "type": "string",
      "minLength": 1
    }
  }
}
```

### Valid instance: An object value with non-empty first and last names is valid

```json
{ "firstName": "John", "lastName": "Doe" }
```

### Invalid instance: An object value with empty first and last names is invalid

```json
{ "firstName": "", "lastName": "" }
```
