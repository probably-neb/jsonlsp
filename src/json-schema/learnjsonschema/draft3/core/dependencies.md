# dependencies

- Original: [https://www.learnjsonschema.com/draft3/core/dependencies/](https://www.learnjsonschema.com/draft3/core/dependencies/)
- Upstream source: [https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft3/core/dependencies.markdown](https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content/draft3/core/dependencies.markdown)
- Specification: [https://json-schema.org/draft-03/draft-zyp-json-schema-03.pdf#5.8](https://json-schema.org/draft-03/draft-zyp-json-schema-03.pdf#5.8)
- Metaschema: `http://json-schema.org/draft-03/schema#`
- Introduced in: `draft3`

Validation succeeds if, for each name that appears in both the instance and as a name within this keyword's value, either every item in the corresponding array is also the name of a property in the instance or the corresponding subschema successfully evaluates against the instance.

We are looking for contributors to help us fully expand the documentation to
cover this dialect. If that sounds like you, [send a pull
request on GitHub](https://github.com/sourcemeta/learnjsonschema.com/pulls)!
