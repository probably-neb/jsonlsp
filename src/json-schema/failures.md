# JSON Schema test suite failures

This file tracks **what is failing**, **why it is failing**, and **what to implement**.
It is meant to be an engineering plan, not just a keyword checklist.

## Current snapshot (post recent parser/refactor work)

From a full `zig build test:suite` run captured recently:

- Total failures: **715 / 6530**
- Per draft:
  - `draft3`: 32
  - `draft4`: 30
  - `draft6`: 52
  - `draft7`: 57
  - `draft2019-09`: 158
  - `draft2020-12`: 190
  - `draft-next`: 196

Important: previously blocking hangs around:

- `allOf-with-two-empty-schemas.any-data-is-valid`
- `root-pointer-ref`

were addressed and no longer appear as suite blockers in the latest categorization.

---

## Priorities

## P0 — Highest leverage and blockers

### 1) `$ref` / URI scope / anchor / remote resolution model

**Failure clusters**

- `ref`
- `refRemote`
- `anchor`
- (prereq for `dynamicRef`/`recursiveRef` correctness)

**Representative failures**

- `draft4.test.refRemote.remote-ref.remote-ref-invalid`
- `draft4.test.refRemote.base-URI-change.base-URI-change-ref-invalid`
- `draft7.test.ref.Reference-an-anchor-with-a-non-relative-URI.mismatch`
- `draft2020-12.test.anchor.Location-independent-identifier.mismatch`
- `draft2020-12.test.ref.order-of-evaluation:-$id-and-$anchor-and-$ref.data-is-invalid-against-first-definition`

**Concrete bug / missing behavior**

Current reference handling is not fully spec-compliant for URI scoping and remote/id/anchor resolution:
- base URI changes from nested `$id` are not fully modeled as schema-resource boundaries,
- anchor lookup does not consistently follow draft rules,
- remote refs are not resolved through a robust resource registry + loader abstraction,
- order/scope interactions between `$id`, `$anchor`, and `$ref` are incomplete.

**Fix plan**

1. Build a canonical **resource registry** keyed by normalized absolute URI.
2. During parse, track current base URI per subschema and resolve `$id`/`$ref` relative to it.
3. Resolve fragment targets by:
   - JSON Pointer (`#/...`), and
   - anchor lookup (`#name`) against the right resource.
4. Introduce loader boundary for remote retrieval (map-backed first, HTTP-backed if available in harness).
5. Keep draft-specific behavior gates explicit (draft4/6/7 vs 2019-09/2020-12/next).

---

### 2) 2020-12 array applicator semantics (`prefixItems` + `items` interaction)

**Failure clusters**

- `prefixItems`
- part of `items`/`uniqueItems`/`unevaluatedItems` downstream behavior

**Representative failures**

- `draft2020-12.test.prefixItems.a-schema-given-for-prefixItems.wrong-types`
- `draft2020-12.test.prefixItems.prefixItems-with-boolean-schemas.array-with-two-items-is-invalid`

**Concrete bug / missing behavior**

`prefixItems` semantics are missing/incomplete. 2020-12 requires tuple-prefix validation via `prefixItems`, and `items` applies only to positions after the prefix.

**Fix plan**

1. Parse `prefixItems` into an ordered schema list.
2. Validate array indices `< prefixItems.len` against corresponding tuple schemas.
3. Validate remaining indices against `items` (if present).
4. Ensure this integrates with evaluated-index tracking later (for `unevaluatedItems`).

---

### 3) [FIXED] `oneOf` exact-one semantics

**Failure clusters**

- `oneOf` (small count, high confidence bug)

**Representative failures**

- `draft6.test.oneOf.oneOf-with-boolean-schemas,-all-true.any-value-is-invalid`
- similar failures in draft7/2019-09/2020-12/next

**Concrete bug**

Current `oneOf` logic behaves like parity/XOR accumulation; it should enforce **exactly one** subschema matches.

**Fix plan**

1. Evaluate all branches.
2. Count successful branches.
3. Return `count == 1`.
4. Keep short-circuiting only where semantics remain equivalent (usually not for exact-one).

---

## P1 — Medium systems with large payoff

### 4) Dependency family (`dependencies`, `dependentSchemas`, `propertyDependencies`)

**Failure clusters**

- `dependencies`
- `dependentSchemas`
- `propertyDependencies`

**Representative failures**

- `draft3.test.dependencies.dependencies.missing-dependency`
- `draft7.test.dependencies.multiple-dependencies.missing-both-dependencies`
- `draft-next.test.dependentSchemas.single-dependency.wrong-type`
- `draft-next.test.propertyDependencies.multiple-options-selects-the-right-one.bar-with-more-than-2-properties-is-invalid`

**Concrete bug / missing behavior**

`dependentRequired` support exists, but dependency-family behavior is still incomplete/inconsistent by draft:
- legacy `dependencies` dual-form handling (array vs schema) is incomplete,
- `dependentSchemas` is missing/incomplete,
- draft-next `propertyDependencies` behavior is missing/incomplete.

**Fix plan**

1. Implement draft-gated parser support:
   - draft3–7: `dependencies` (array = required-properties, schema = whole-instance validation)
   - 2019-09+: `dependentRequired` + `dependentSchemas` (+ compatibility where suite expects)
   - next: `propertyDependencies` per suite expectations.
2. Validate on object instances only.
3. Reuse current object-key existence checks and cached constraint parsing for schema deps.

---

### 5) `contains` / `minContains` / `maxContains`

**Failure clusters**

- `contains`
- `minContains`
- `maxContains`

**Representative failures**

- `draft6.test.contains.contains-keyword-validation.array-without-items-matching-schema-is-invalid`
- `draft2019-09.test.minContains.minContains=1-with-contains.empty-data`
- `draft2019-09.test.maxContains.maxContains-with-contains.empty-data`

**Concrete bug / missing behavior**

`contains` family is absent or partial. Correct behavior requires counting elements that satisfy the `contains` subschema and enforcing min/max constraints.

**Fix plan**

1. Parse `contains` constraint and optional `minContains`/`maxContains`.
2. On arrays:
   - count matching items,
   - default minimum to 1 when `contains` exists and `minContains` absent,
   - enforce lower/upper bounds.
3. On non-arrays: keyword is not applicable (passes).

---

### 6) `propertyNames`

**Failure clusters**

- `propertyNames`

**Representative failures**

- `draft6.test.propertyNames.propertyNames-validation.some-property-names-invalid`
- `draft7.test.propertyNames.propertyNames-with-pattern.non-matching-property-name-is-invalid`
- `draft2020-12.test.propertyNames.propertyNames-with-boolean-schema-false.object-with-any-properties-is-invalid`

**Concrete bug / missing behavior**

Keyword is missing/incomplete. Property keys must be validated as JSON string instances against the `propertyNames` subschema.

**Fix plan**

1. Parse `propertyNames` as schema constraint.
2. In object validation, run each key through that schema.
3. Keep semantics separate from `properties`/`patternProperties` and from evaluated-property bookkeeping.

---

## P2 — Large semantic subsystem

### 7) `unevaluatedProperties` / `unevaluatedItems`

**Failure clusters**

- `unevaluatedProperties` (largest)
- `unevaluatedItems`

**Representative failures**

- `draft2019-09.test.unevaluatedProperties.unevaluatedProperties-false.with-unevaluated-properties`
- `draft2019-09.test.unevaluatedItems.unevaluatedItems-false.with-unevaluated-items`
- `draft-next.test.unevaluatedProperties.unevaluatedProperties-with-dependentSchemas.with-unevaluated-properties`
- `draft2020-12.test.unevaluatedItems.unevaluatedItems-with-$dynamicRef.with-unevaluated-items`

**Concrete bug / missing behavior**

Current evaluator primarily returns boolean validity and does not fully carry annotation/evaluated-location state through applicators and refs, which is required for unevaluated-* semantics.

**Fix plan**

1. Introduce evaluation result structure:
   - validity +
   - evaluated property set +
   - evaluated item index/range set.
2. Merge/propagate sets correctly through applicators:
   - `allOf`: merge from all successful branches,
   - `anyOf`/`oneOf`: merge only successful branch(es),
   - `if/then/else`, `not`, `$ref` semantics per draft rules.
3. Apply unevaluated-* constraints to leftovers after in-scope applicators.

---

## P3 — Advanced refs + legacy draft3

### 8) `$dynamicRef` / `$dynamicAnchor` and `$recursiveRef` / `$recursiveAnchor`

**Failure clusters**

- `dynamicRef`
- `recursiveRef`

**Representative failures**

- `draft2019-09.test.recursiveRef.$recursiveRef-without-$recursiveAnchor-works-like-$ref.recursive-mismatch`
- `draft2020-12.test.dynamicRef.A-$dynamicRef-to-a-$dynamicAnchor-in-the-same-schema-resource-behaves-like-a-normal-$ref-to-an-$anchor.An-array-containing-non-strings-is-invalid`

**Concrete bug / missing behavior**

Dynamic and recursive reference resolution rules are not implemented or incomplete:
- no proper dynamic scope chain for anchor rebinding during evaluation.

**Fix plan**

1. Add parsed forms for dynamic/recursive reference keywords.
2. Maintain dynamic anchor scope stack at evaluation time.
3. Resolve dynamic refs by static target + dynamic rebinding rules.

---

### 9) Draft3 legacy keywords/semantics

**Failure clusters**

- `extends`
- `disallow`
- `divisibleBy`
- schema-in-`type` behavior
- draft3 exclusive min/max edge semantics

**Representative failures**

- `draft3.test.extends.extends.mismatch-extended`
- `draft3.test.disallow.disallow.disallowed`
- `draft3.test.divisibleBy.by-number.35-is-not-divisible-by-1.5`
- `draft3.test.type.types-can-include-schemas.an-object-is-valid`
- `draft3.test.maximum.exclusiveMaximum-validation.boundary-point-is-invalid`
- `draft3.test.minimum.exclusiveMinimum-validation.boundary-point-is-invalid`

**Concrete bug / missing behavior**

Legacy draft3 semantics differ materially from later drafts and are not fully modeled.

**Fix plan**

1. Add explicit draft3-only parse + check paths for legacy keywords.
2. Avoid leaking legacy semantics into newer draft code paths.
3. Gate behavior tightly by revision.

---

## Smaller correctness buckets (still real bugs)

These are lower-volume but need specific fixes:

- `const`: equality/normalization edge cases in value comparison.
- `not`: annotation/interaction semantics (especially with unevaluated collection).
- `type` (draft3 schema-in-type arrays): missing legacy handling.
- `infinite-loop-detection`: evaluator recursion tracking needs location-pair awareness (schema-location + instance-location), not just naive recursion checks.

---

## Recommended execution order

1. **Quick wins first**:
   - fix `oneOf` exact-one counting,
   - implement `propertyNames`.
2. **Core arrays**:
   - implement `prefixItems` + correct 2020-12 `items` tail behavior.
3. **Dependency + contains families**.
4. **Ref model v1** (`$id`/anchors/remote).
5. **Dynamic/recursive refs**.
6. **Unevaluated subsystem** once applicators/refs are stable.
7. **Draft3 legacy cleanup**.

This order reduces rework and unlocks high-failure buckets with maximal impact.

---

## Acceptance-gate test shortlist

Use these as a compact progress board after each milestone:

- `draft6.test.oneOf.oneOf-with-boolean-schemas,-all-true.any-value-is-invalid`
- `draft6.test.propertyNames.propertyNames-validation.some-property-names-invalid`
- `draft2020-12.test.prefixItems.a-schema-given-for-prefixItems.wrong-types`
- `draft7.test.dependencies.multiple-dependencies.missing-both-dependencies`
- `draft2019-09.test.minContains.minContains=2-with-contains.some-elements-match,-invalid-minContains`
- `draft4.test.refRemote.remote-ref.remote-ref-invalid`
- `draft2020-12.test.anchor.Location-independent-identifier.mismatch`
- `draft2019-09.test.unevaluatedProperties.unevaluatedProperties-false.with-unevaluated-properties`
- `draft2020-12.test.dynamicRef.multiple-dynamic-paths-to-the-$dynamicRef-keyword.number-list-with-string-values`
- `draft3.test.extends.extends.mismatch-extended`

---

## Notes

- This document intentionally avoids “targeted bug fix” as a vague label; each section states the concrete behavioral bug and expected implementation direction.
- Counts are from a recent full-suite snapshot and should be refreshed after each major milestone.
