# patternProperties

- Original: [https://www.learnjsonschema.com/draft4/validation/patternproperties/](https://www.learnjsonschema.com/draft4/validation/patternproperties/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/patternProperties.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft4/validation/patternProperties.markdown)
- Specification: [https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.4.4](https://json-schema.org/draft-04/draft-fge-json-schema-validation-00#rfc.section.5.4.4)
- Metaschema: `http://json-schema.org/draft-04/schema#`
- Introduced in: `draft3`

Validation succeeds if, for each instance name that matches any regular expressions that appear as a property name in this keyword's value, the child instance for that name successfully validates against each schema that corresponds to a matching regular expression.

The [`patternProperties`](index.md)
keyword restricts properties of an object instance that match certain regular
expressions to match their corresponding subschemas definitions.

> **Common Pitfall:**
>  This keyword is evaluated independently of the
> [`properties`](../properties/index.md) keyword. If an
> object property is described by both keywords, then both subschemas must
> successfully validate against the given property for validation to succeed.
> Furthermore, an instance property may match more than one regular expression
> set with this keyword, in which case the property is expected to validate
> against all matching subschemas.

> **Digging Deeper:**
>  While the specification suggests the use of
> [ECMA-262](https://www.ecma-international.org/publications-and-standards/standards/ecma-262/)
> regular expressions for interoperability purposes, the use of different
> flavours like PCRE or POSIX (Basic or Extended) is permitted. Also, the
> specification does not impose the use of any particular regular expression
> flag. By convention (and somewhat enforced by the official JSON Schema test
> suite), regular expressions are not implicitly
> [anchored](https://www.regular-expressions.info/anchors.html) and are always
> treated as case-sensitive. It is also common for the
> [`DOTALL`](https://tc39.es/ecma262/multipage/text-processing.html#sec-get-regexp.prototype.dotAll)
> flag to be enabled, permitting the dot character class to match new lines.
>
> To avoid interoperability issues, stick to
> [ECMA-262](https://www.ecma-international.org/publications-and-standards/standards/ecma-262/),
> and don't assume the use of any regular expression flag.  

> **Common Pitfall:**
>  Regular expressions often make use of characters that need
> to be escaped when making use of them as part of JSON strings. For example, the
> *reverse solidus* character (more commonly known as the backslash character)
> and the *double quote* character need to be escaped. Failure to do so will
> result in an invalid JSON document. Applications to work with regular
> expressions, like [Regex Forge](https://regexforge.com), typically provide
> convenient functionality to copy a regular expression for use in JSON.

> **Type constraint:** Non-`object` instances also validate against this keyword. Use [`type`](../type/index.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains object instances to enforce that lowercase properties are integers

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "patternProperties": {
    "^[a-z]+$": { "type": "integer" }
  }
}
```

### Valid instance: An object value that defines only lowercase integer properties is valid

```json
{ "foo": 1, "bar": 2, "baz": 3 }
```

### Valid instance: An object value that defines non-lowercase properties is valid

```json
{ "CamelCase": true, "alphanumeric123": "anything is valid" }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Invalid instance: An object value that defines a lowercase non-integer properties is invalid

```json
{ "foo": "should have been an integer" }
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constrains object instances with two potentially overlapping regular expressions

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "patternProperties": {
    "^f": { "type": "string" },
    "o$": { "minLength": 3 }
  }
}
```

### Valid instance: An object value that defines a property that matches both regular expressions and schemas is valid

```json
{ "foo": "long string" }
```

### Valid instance: An object value that defines a property that matches one regular expression and its corresponding schema is valid

```json
{ "boo": 1 }
```

### Invalid instance: An object value that defines a property that matches both regular expressions but does not match one of the schemas is invalid

```json
{ "foo": "xx" }
```

### Invalid instance: An object value that defines a property that matches one regular expression but does not match its schema is invalid

```json
{ "boo": "xx" }
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```

### Schema: A schema that constrains object instances with overlapping static and regular expression definitions

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "patternProperties": {
    "^f": { "minLength": 3 }
  },
  "properties": {
    "foo": { "type": "string" }
  }
}
```

### Valid instance: An object value that defines a property that matches both definitions and schemas is valid

```json
{ "foo": "long string" }
```

### Valid instance: An object value that defines a property that matches only the regular expression definition and its schema is valid

```json
{ "football": 3 }
```

### Invalid instance: An object value that defines a property that matches both definitions but only matches one schema is invalid

```json
{ "foo": "xx" }
```

### Valid instance: An empty object value is valid

```json
{}
```

### Valid instance: A non-object value is valid

```json
"Hello World"
```
