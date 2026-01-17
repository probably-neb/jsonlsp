# JSON Schema test suite failures

Checklist of features/bug fixes derived from test suite failures.

## Missing features

- [ ] `ref` (212) — example: `draft3.test.ref.root-pointer-ref.recursive-mismatch` — Expected rejection, but it was accepted.
- [ ] `refRemote` (79) — example: `draft3.test.refRemote.remote-ref.remote-ref-invalid` — Expected rejection, but it was accepted.
- [ ] `recursiveRef` (13) — example: `draft2019-09.test.recursiveRef.$recursiveRef-without-$recursiveAnchor-works-like-$ref.recursive-mismatch` — Expected rejection, but it was accepted.
- [ ] `dynamicRef` (42) — example: `draft2020-12.test.dynamicRef.A-$dynamicRef-to-a-$dynamicAnchor-in-the-same-schema-resource-behaves-like-a-normal-$ref-to-an-$anchor.An-array-containing-non-strings-is-invalid` — Expected rejection, but it was accepted.
- [ ] `anchor` (12) — example: `draft2019-09.test.anchor.Location-independent-identifier.mismatch` — Expected rejection, but it was accepted.
- [ ] `defs` (3) — example: `draft2019-09.test.defs.validate-definition-against-metaschema.invalid-definition-schema` — Expected rejection, but it was accepted.
- [ ] `definitions` (3) — example: `draft4.test.definitions.validate-definition-against-metaschema.invalid-definition-schema` — Expected rejection, but it was accepted.
- [ ] `vocabulary` (3) — example: `draft2019-09.test.vocabulary.schema-that-uses-custom-metaschema-with-with-no-validation-vocabulary.no-validation:-invalid-number,-but-it-still-validates` — Expected acceptance, but it was rejected.
- [ ] `unevaluatedProperties` (173) — example: `draft2019-09.test.unevaluatedProperties.unevaluatedProperties-schema.with-invalid-unevaluated-properties` — Expected rejection, but it was accepted.
- [ ] `unevaluatedItems` (74) — example: `draft2019-09.test.unevaluatedItems.unevaluatedItems-false.with-unevaluated-items` — Expected rejection, but it was accepted.
- [ ] `dependentSchemas` (30) — example: `draft2019-09.test.dependentSchemas.single-dependency.wrong-type` — Expected rejection, but it was accepted.
- [ ] `dependentRequired` (18) — example: `draft2019-09.test.dependentRequired.single-dependency.missing-dependency` — Expected rejection, but it was accepted.
- [ ] `dependencies` (50) — example: `draft3.test.dependencies.dependencies.missing-dependency` — Expected rejection, but it was accepted.
- [ ] `propertyDependencies` (4) — example: `draft-next.test.propertyDependencies.multiple-options-selects-the-right-one.bar-with-more-than-2-properties-is-invalid` — Expected rejection, but it was accepted.
- [ ] `if-then-else` (32) — example: `draft7.test.if-then-else.if-and-then-without-else.invalid-through-then` — Expected rejection, but it was accepted.
- [ ] `contains` (39) — example: `draft6.test.contains.contains-keyword-validation.array-without-items-matching-schema-is-invalid` — Expected rejection, but it was accepted.
- [ ] `minContains` (42) — example: `draft2019-09.test.minContains.minContains=1-with-contains.empty-data` — Expected rejection, but it was accepted.
- [ ] `maxContains` (18) — example: `draft2019-09.test.maxContains.maxContains-with-contains.empty-data` — Expected rejection, but it was accepted.
- [ ] `prefixItems` (4) — example: `draft2020-12.test.prefixItems.a-schema-given-for-prefixItems.wrong-types` — Expected rejection, but it was accepted.
- [ ] `additionalItems` (23) — example: `draft3.test.additionalItems.additionalItems-as-schema.additional-items-do-not-match-schema` — Expected rejection, but it was accepted.
- [ ] `patternProperties` (64) — example: `draft3.test.patternProperties.patternProperties-validates-properties-matching-a-regex.a-single-invalid-match-is-invalid` — Expected rejection, but it was accepted.
- [ ] `propertyNames` (22) — example: `draft6.test.propertyNames.propertyNames-validation.some-property-names-invalid` — Expected rejection, but it was accepted.
- [ ] `extends` (6) — example: `draft3.test.extends.extends.mismatch-extends` — Expected rejection, but it was accepted.
- [ ] `disallow` (5) — example: `draft3.test.disallow.disallow.disallowed` — Expected rejection, but it was accepted.

## Bugs (implemented but incorrect behavior)

- [x] `additionalProperties` (31) — example: `draft3.test.additionalProperties.additionalProperties-being-false-does-not-allow-other-properties.patternProperties-are-not-additional-properties` — Expected acceptance, but it was rejected.
- [x] `items` (38) — example: `draft3.test.items.an-array-of-schemas-for-items.wrong-types` — Expected rejection, but it was accepted.
- [x] `properties` (14) — example: `draft3.test.properties.properties,-patternProperties,-additionalProperties-interaction.patternProperty-invalidates-property` — Expected rejection, but it was accepted.
- [x] `uniqueItems` (22) — example: `draft3.test.uniqueItems.uniqueItems-with-an-array-of-items-and-additionalItems=false.extra-items-are-invalid-even-if-unique` — Expected rejection, but it was accepted.
- [x] `enum` (44) — example: `draft3.test.enum.enums-in-properties.missing-required-property-is-invalid` — Expected rejection, but it was accepted.
- [ ] `const` (20) — example: `draft6.test.const.const-with-[false]-does-not-match-[0].[false]-is-valid` — Expected acceptance, but it was rejected.
- [x] `required` (1) — example: `draft3.test.required.required-validation.non-present-required-property-is-invalid` — Expected rejection, but it was accepted.
- [ ] `maximum` (2) — example: `draft3.test.maximum.exclusiveMaximum-validation.boundary-point-is-invalid` — Expected rejection, but it was accepted.
- [ ] `minimum` (2) — example: `draft3.test.minimum.exclusiveMinimum-validation.boundary-point-is-invalid` — Expected rejection, but it was accepted.
- [x] `multipleOf` (12) — example: `draft4.test.multipleOf.by-small-number.0.0075-is-multiple-of-0.0001` — Expected acceptance, but it was rejected.
- [ ] `type` (4) — example: `draft3.test.type.types-can-include-schemas.an-object-is-valid` — Expected acceptance, but it was rejected.
- [ ] `oneOf` (5) — example: `draft6.test.oneOf.oneOf-with-boolean-schemas,-all-true.any-value-is-invalid` — Expected rejection, but it was accepted.
- [ ] `not` (3) — example: `draft2019-09.test.not.collect-annotations-inside-a-'not',-even-if-collection-is-disabled.unevaluated-property` — Expected acceptance, but it was rejected.
- [ ] `infinite-loop-detection` (7) — example: `draft3.test.infinite-loop-detection.evaluating-the-same-schema-location-against-the-same-data-location-twice-is-not-a-sign-of-an-infinite-loop.failing-case` — Expected rejection, but it was accepted.
- [x] `maxProperties` (17) — example: `draft4.test.maxProperties.maxProperties-validation.too-long-is-invalid` — Expected rejection, but it was accepted.
- [x] `minProperties` (11) — example: `draft4.test.minProperties.minProperties-validation.too-short-is-invalid` — Expected rejection, but it was accepted.
