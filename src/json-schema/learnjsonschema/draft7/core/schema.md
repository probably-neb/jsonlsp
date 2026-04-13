# $schema

- Original: [https://www.learnjsonschema.com/draft7/core/schema/](https://www.learnjsonschema.com/draft7/core/schema/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/core/schema.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft7/core/schema.markdown)
- Specification: [https://json-schema.org/draft-07/draft-handrews-json-schema-01#rfc.section.7](https://json-schema.org/draft-07/draft-handrews-json-schema-01#rfc.section.7)
- Metaschema: `http://json-schema.org/draft-07/schema#`
- Introduced in: `draft3`

This keyword is both used as a JSON Schema dialect identifier and as a reference to a JSON Schema which describes the set of valid schemas written for this particular dialect.

The [`$schema`](schema.md) keyword serves to explicitly
associate a _schema resource_ with the JSON Schema dialect that defines it,
where the dialect is the identifier of a meta-schema that defines the keywords
in use and imposes syntactic constraints on its schema instances.  If the
[`$schema`](schema.md) keyword is not declared, the
schema inherits its context-specific or implementation-specific default
dialect.

> **Digging Deeper:**
>  It is common to avoid the [`$schema`](schema.md) keyword when working with
> [OpenAPI](https://www.openapis.org). This is possible because the OpenAPI
> specification clearly documents what the default JSON Schema dialect is for
> every version. For example, [OpenAPI
> v3.1.1](https://spec.openapis.org/oas/latest.html#json-schema-keywords) defines
> the default dialect as `https://spec.openapis.org/oas/3.1/dialect/base`.

Strictly-compliant JSON Schema implementations will refuse to process a schema
whose dialect cannot be unambiguously determined.

> **Best Practice:**
>  To avoid undefined behavior, it is generally recommended to
> always explicitly set the dialect of a schema using the [`$schema`](schema.md) keyword. This ensures that less strict
> implementations unambiguously know how to process the schema and don't attempt
> to guess.

Note that the [`$schema`](schema.md) keyword can occur
multiple times in the same schema, and not only at the top-level. This is often
the case when performing [JSON Schema
Bundling](https://github.com/sourcemeta/jsonschema/blob/main/docs/bundle.markdown)
to inline externally referenced schemas that might be based on different
dialects of JSON Schema.

> **Common Pitfall:**
> JSON Schema prohibits referencing meta-schemas using
> relative URIs. The fundamental reason for this is that resolving the
> meta-schema is necessary for correctly determining the base URI of the schema,
> from which a relative meta-schema reference would be resolved, introducing a
> circular problem.
>
> A common occurrence of this issue is setting the [`$schema`](schema.md) keyword to a relative path, which is again invalid
> according to the specification.

> **Common Pitfall:**
> JSON Schema prohibits the use of the this keyword on
> arbitrary subschemas that do not represent schema resources. It can only be
> present at the root of the schema (an implicit schema resource) or as a sibling
> of the [`$id`](id.md) keyword (an explicit schema
> resource).

A schema is considered syntactic valid if it successfully validates against its
dialect meta-schema. You can validate a schema against its meta-schema using
the [`jsonschema
metaschema`](https://github.com/sourcemeta/jsonschema/blob/main/docs/metaschema.markdown)
command.  For example:

```sh
$ jsonschema metaschema my-schema.json
```

To debug the role of the [`$schema`](schema.md)
keyword on a schema (particularly schemas with embedded resources), try the
[`jsonschema
inspect`](https://github.com/sourcemeta/jsonschema/blob/main/docs/inspect.markdown)
command. This command prints detailed information about each schema resource,
subschema, location, and reference present in the schema. For example:

```sh
$ jsonschema inspect schema.json
(RESOURCE) URI: https://example.com/schema
    Type              : Static
    Root              : https://example.com/schema
    Pointer           :
    Base              : https://example.com/schema
    Relative Pointer  :
    Dialect           : http://json-schema.org/draft-07/schema#
    Base Dialect      : http://json-schema.org/draft-07/schema#
    Parent            : <NONE>
    Instance Location :

...

(SUBSCHEMA) URI: https://example.com/schema#/properties/foo
    Type              : Static
    Root              : https://example.com/schema
    Pointer           : /properties/foo
    Base              : https://example.com/schema
    Relative Pointer  : /properties/foo
    Dialect           : http://json-schema.org/draft-07/schema#
    Base Dialect      : http://json-schema.org/draft-07/schema#
    Parent            :
    Instance Location : /foo

...

(REFERENCE) ORIGIN: /$schema
    Type              : Static
    Destination       : http://json-schema.org/draft-07/schema
    - (w/o fragment)  : http://json-schema.org/draft-07/schema
    - (fragment)      : <NONE>
```

## Examples

### Schema: A schema described by the JSON Schema Draft 7 official dialect

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "string"
}
```

### Schema: A valid schema without an explicitly declared dialect, prone to undefined behavior

```json
{
  "items": [ { "type": "number" } ]
}
```

### Schema: A valid schema that mixes the Draft 7 and 2020-12 official dialects

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "properties": {
    "price": { "type": "number" },
    "discount": {
      "$ref": "#/definitions/discount"
    }
  },
  "definitions": {
    "discount": {
      "$schema": "https://json-schema.org/draft/2020-12/schema",
      "type": "number"
    }
  }
}
```
