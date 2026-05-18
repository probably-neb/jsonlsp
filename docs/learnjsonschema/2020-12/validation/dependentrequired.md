# dependentRequired

- Original: [https://www.learnjsonschema.com/2020-12/validation/dependentrequired/](https://www.learnjsonschema.com/2020-12/validation/dependentrequired/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/validation/dependentRequired.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/validation/dependentRequired.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-6.5.4](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-6.5.4)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/validation`
- Introduced in: `2019-09`

Validation succeeds if, for each name that appears in both the instance and as a name within this keyword's value, every item in the corresponding array is also the name of a property in the instance.
The [`dependentRequired`](dependentRequired.md) keyword restricts object instances to define certain
properties if other properties are also defined.

> **Common Pitfall:**
>  Note that multiple potentially interrelated dependencies
> can be declared at once, in which case every dependency must be transitively
> fulfilled for the object instance to be valid. For example, if a schema marks
> the property `B` as required if the property `A` is present and also marks the
> property `C` as required if the property `B` is present, defining the property
> `A` transitively requires _both_ the `B` and `C` properties to be present in
> the object instance.  

> **Digging Deeper:**
> The [`dependentSchemas`](../applicator/dependentschemas.md) keyword is a generalisation of this
> keyword to describe object dependencies beyond property
> requirement.

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains object instances with a single property dependency

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "dependentRequired": {
    "foo": [ "bar", "baz" ]
  }
}
```

### Valid instance: An object value that defines the dependency and all of the dependents is valid

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Invalid instance: An object value that defines the dependency and some of the dependents is invalid

```json
{ "foo": 1, "bar": 2 }
```

### Invalid instance: An object value that defines the dependency and none of the dependents is invalid

```json
{ "foo": 1 }
```

### Valid instance: An object value that does not define the dependency is valid

```json
{ "qux": 4 }
```

### Valid instance: An empty object value is valid as no dependencies apply

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constrains object instances with a transitive property dependencies

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "dependentRequired": {
    "foo": [ "bar" ],
    "bar": [ "baz" ]
  }
}
```

### Valid instance: An object value that satisfies the transitive dependency is valid

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Invalid instance: An object value that only satisfies the first part of the transitive dependency is invalid

```json
{ "foo": 1, "bar": 2 }
```

### Valid instance: An object value that only satisfies the second part of the transitive dependency is valid

```json
{ "bar": 2, "baz": 3 }
```

### Valid instance: An empty object value is valid as no dependencies apply

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```
