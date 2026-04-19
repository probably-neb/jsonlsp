- [ ] remaining json-schema compat issues
  - [ ] remote ref
  - [ ] remaining unhandled keys
  - [ ] error generation
- [ ] Integrate Json schema validation
  - [ ] create "snapshot" structure
    - syntax errors
    - hashed json
    - schema validation errors
    - created from document state + previous snapshot
  - [ ] integrate hashes into resilient parsing, for re-using of hashed json strucutres, errors, etc
- [ ] fuzz incremental edits
- [ ] Fuzz json schema parsing/checking (can integrate with incremental edit fuzzing for full integration fuzzing)
- [ ] Improve document memory usage
  - [ ] create segmented arena, that subdivides allocated address space into regions
  - [ ] use segmented arena for document storage, where each piece of document has enough space for the absolute max, but memory is only committed as needed based on bucket sizes
  - [ ] devise way to store/parse tree + tokens in constant space (using scratch arena as necessary of course)


## DONE
- [x] Handle incremental edits
  - [x] Make gap buffer data structure
  - [x] Make json parsing have a "feed" construct that feeds ranges of bytes into the parser
  - [x] handle incremental edit messages and just reparse the entire document
- [x] Track key hashes in HashableJsonValue (and rename it). Fix places in check where hashes must be computed or strings used instead
- [x] Flatten json schema constraint type
