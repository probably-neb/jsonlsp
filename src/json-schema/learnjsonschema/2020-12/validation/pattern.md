# pattern

- Original: [https://www.learnjsonschema.com/2020-12/validation/pattern/](https://www.learnjsonschema.com/2020-12/validation/pattern/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/validation/pattern.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/2020-12/validation/pattern.markdown)
- Specification: [https://json-schema.org/draft/2020-12/json-schema-validation.html#section-6.3.3](https://json-schema.org/draft/2020-12/json-schema-validation.html#section-6.3.3)
- Metaschema: `https://json-schema.org/draft/2020-12/meta/validation`
- Introduced in: `draft1`

A string instance is considered valid if the regular expression matches the instance successfully.
The [`pattern`](pattern.md) keyword restricts string instances to match the given regular
expression.

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

> **Type constraint:** Non-`string` instances also validate against this keyword. Use [`type`](type.md) if you need to restrict the accepted type.

## Examples

### Schema: A schema that constrains string instances to look like e-mail addresses

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "pattern": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
}
```

### Valid instance: A string value that matches the regular expression is valid

```json
"john.doe@example.com"
```

### Invalid instance: A string value that does not match the regular expression is invalid

```json
"foo"
```

### Valid instance: A non-string value is valid

```json
1234
```
