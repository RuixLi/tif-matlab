---
kind: effort
name: reliability-first io
status: done
description: Hardens the existing TIFF load/save/write/frame behavior against silent errors and nondeterministic inputs.
created: "2026-07-05T18:38"
updated: "2026-07-05T18:56"
---
# Reliability-First I/O - Effort

Make the current `tif.*` API safer before adding larger features.

## Outcome

- `tif.load`, `tif.save`, `tif.write`, and `tif.frame` validate their inputs and fail with useful errors.
- Loading a folder of TIFF files is deterministic.
- Frame ranges, stride, path types, warnings, and file handles behave predictably.
- Tests cover the failure modes most likely to cause silent data corruption.

## Assumptions

- **Backward compatibility with old root functions is not required** - only the `tif.*` API is supported.
- **MATLAB R2019b+ is acceptable** - `arguments` blocks may be used.
- **Reliability changes may adjust error behavior** - unclear input should error rather than guess.

## Decisions

### Needs Your Response

- None. The user approved strict errors on 2026-07-05.

### Already Made

- **Natural/deterministic folder ordering** - folder loads should not depend on filesystem enumeration order.
- **Resource cleanup is part of correctness** - `Tiff` handles and warning state should be restored via cleanup guards.
- **Strict errors** - missing paths, empty folders, out-of-range frames, mixed image sizes, and unsupported dtypes should error rather than guess.

## Oracle(s)

| capability / claim | oracle (independent, up-front) | check |
| --- | --- | --- |
| Path handling is robust | Tests cover `char` and `string` paths, missing path errors, `.tif`, and `.tiff` | `matlab -batch "results = runtests('tests'); assertSuccess(results);"` |
| Folder loading is deterministic | Test creates unsorted filenames and verifies natural sorted stack order | `tests/test_reliability_io.m` |
| Frame selection is correct | Tests cover `Frames`/index ranges, `-1` end sentinel, stride, and out-of-range errors | `tests/test_reliability_io.m` |
| Save/load preserves intended dtype | Tests cover exact `uint8` and `uint16` round trips, plus explicit cast behavior for floats | `tests/test_reliability_io.m` |
| Cleanup works on errors | Tests force a read/write error and verify warning state / file handle behavior does not leak | `tests/test_reliability_io.m` |

## Scope

- In: input validation, deterministic file ordering, frame-range semantics, cleanup guards, focused tests, README/CHANGELOG updates.
- Out: BigTIFF, compression tuning, streaming APIs, metadata redesign, OME-TIFF support.

## Design

Keep the public API small while making behavior explicit. Use input validation at the function boundary, private helpers for path/file discovery and frame-range normalization, and test fixtures that generate small temporary TIFF stacks.

## Public Interface

- Existing API remains: `tif.load`, `tif.save`, `tif.write`, `tif.frame`.
- Optional argument style should move toward name-value options where behavior would otherwise require more positional parameters.

## Seal

- Sealed at: branch `reliability-first-io`; ground: MATLAB Unit Test and all-you-need-is-trust `check-project`; by: Codex, on 2026-07-05.
