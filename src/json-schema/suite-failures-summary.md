Ran the suite and analyzed the failures end-to-end without code changes.

## 1) Test run result

I ran `zig build test:suite` in `jsonls` with timeout (`120s`, then full log via redirect with `180s`).

Final summary from the run:

- `draft3`: `423/435 passed`, `12 failed`
- `draft4`: `602/610 passed`, `8 failed`
- `draft6`: `818/829 passed`, `11 failed`
- `draft7`: `902/913 passed`, `11 failed`
- `draft2019-09`: `1192/1227 passed`, `35 failed`
- `draft2020-12`: `1219/1261 passed`, `42 failed`
- `draft-next`: `1213/1255 passed`, `42 failed`

Total: `6369/6530 passed`, `161 failed`.

---

## 2) Failure categories and likely missing functionality

I grouped concrete failing tests from the log and cross-checked parser/validator code in `src/json-schema/json-schema.zig`.

### A) Remote reference resolution (`refRemote`) is largely missing
**Evidence from failing tests:**
- `draft4.test.refRemote.remote-ref.remote-ref-invalid`
- `draft6.test.refRemote.base-URI-change.base-URI-change-ref-invalid`
- `draft7.test.refRemote.Location-independent-identifier-in-remote-ref.string-is-invalid`
- `draft2019-09.test.refRemote.anchor-within-remote-ref.remote-anchor-invalid`
- `draft2020-12.test.refRemote.remote-HTTP-ref-with-different-$id.number-is-invalid`
- `draft-next.test.refRemote.$ref-to-$ref-finds-detached-$anchor.non-number-is-invalid`

Typical message pattern: expected reject, but case was accepted.

**Code evidence:**
- `resolve_ref` only resolves:
  - local `#...` pointers in current root JSON
  - IDs present in a local `id_registry`
  - URI+fragment only if base URI already in `id_registry`
- No remote fetch/registry population for external documents.
- `$anchor`, `$dynamicAnchor`, `$recursiveAnchor`, `$dynamicRef`, `$recursiveRef` handling is absent.

**Likely root cause:**
- External URI dereference + proper base URI / scope / anchor resolution model is not implemented.

**Confidence:** **High**

---

### B) `unevaluatedItems` semantics are not implemented (2019-09+)
**Evidence from failing tests:**
- `draft2019-09.test.unevaluatedItems.unevaluatedItems-false.with-unevaluated-items`
- `draft2020-12.test.unevaluatedItems.unevaluatedItems-with-$dynamicRef.with-unevaluated-items`
- `draft-next.test.unevaluatedItems.unevaluatedItems-depends-on-adjacent-contains.contains-fails,-second-item-is-not-evaluated`

There are many variants failing across `anyOf`/`oneOf`/`if-then-else`/`$ref`/`contains` interactions.

**Code evidence:**
- No parse/check support for `unevaluatedItems`.
- No annotation/evaluation bookkeeping exists (required for these drafts).

**Likely root cause:**
- Missing post-applicator evaluation tracking and `unevaluatedItems` application logic.

**Confidence:** **High**

---

### C) Boolean subschemas inside `if`/`then`/`else` cause parser panic
**Evidence from crash:**
- Panic on tests like `...if-then-else.if-with-boolean-schema-true...`
- Stack shows `error.UnrecognizedSchemaType` from `parse_into_constraint`.

**Code evidence:**
- `parse_into_constraint` sets `.true/.false` for boolean schemas, but then still does:
  - `if (schema.kind != .object) return error.UnrecognizedSchemaType;`
- So boolean schemas are not accepted as standalone parsed constraints in nested contexts.

**Likely root cause:**
- Missing early return after handling boolean schema in parser.

**Confidence:** **High**

---

### D) Recursive/root `$ref` handling can crash (signal 11)
**Evidence from crashes:**
- `while executing test 'draft3.test.ref.root-pointer-ref.match' ... signal 11`
- Similar for draft4/draft6 `root-pointer-ref.match`.

**Code evidence:**
- `parse_constraint` inserts into `constraint_cache` **after** `parse_into_constraint`.
- Self-referential `$ref` (`"$ref":"#"`) re-enters parse before cache has placeholder => unbounded recursion / stack overflow risk.

**Likely root cause:**
- No cycle-safe placeholder caching for recursive schemas.

**Confidence:** **High**

---

### E) Draft3 legacy keywords missing: `extends`, `divisibleBy`
**Evidence from failing tests:**
- `draft3.test.extends.extends.mismatch-extended`
- `draft3.test.extends.multiple-extends.mismatch-both`
- `draft3.test.divisibleBy.by-int.int-by-int-fail`
- `draft3.test.divisibleBy.by-small-number.0.00751-is-not-divisible-by-0.0001`

**Code evidence:**
- Parser implements `multipleOf` but no `divisibleBy`.
- No `extends` parsing/validation path found.

**Likely root cause:**
- Draft3-specific keywords not implemented.

**Confidence:** **High**

---

## 3) Recommended implementation priority/order

For fastest path to reliable progress toward 100% suite pass:

1. **Stability blockers first**
   - Fix boolean schema parsing in nested contexts (`if/then/else` panic).
   - Fix recursive `$ref` cycle handling (cache placeholder before descent).
   - Why first: removes crashes and makes subsequent failure signal cleaner.

2. **Reference system overhaul**
   - Implement full `$ref` resolution pipeline with:
     - remote document loading/caching
     - base URI scope changes via `id`/`$id`
     - fragment + anchor resolution (`$anchor`, legacy behaviors)
     - 2019+/2020-12 recursive/dynamic refs (`$recursiveRef`, `$dynamicRef`)
   - Biggest single failure bucket.

3. **`unevaluatedItems` with annotation tracking**
   - Add evaluated-index tracking across applicators (`allOf/anyOf/oneOf/not/if-then-else/contains/$ref`).
   - Required for large 2019-09/2020-12/next gap.

4. **Draft3 compatibility gap**
   - Add `extends`.
   - Add `divisibleBy` (draft3 predecessor of `multipleOf`).

---

## 4) Quick confidence matrix

- Remote refs / URI scope / anchor handling: **High**
- `unevaluatedItems` evaluation bookkeeping: **High**
- Boolean schema parsing panic: **High**
- Recursive `$ref` crash handling: **High**
- Draft3 `extends` and `divisibleBy`: **High**

If you want, I can next turn this into an implementation checklist mapped to specific functions in `json-schema.zig` (parser + validator phases) so it’s directly actionable.
