---
kind: effort
name: structure alignment
status: done
description: Realigns the old loose MATLAB TIFF utilities as an agent-ready namespaced package.
created: "2026-07-05T18:11"
updated: "2026-07-05T18:15"
---
# Structure Alignment - Effort

Realign the repository as a MATLAB package that future agents can enter, test, and continue without relying on chat history.

## Outcome

- The repository exposes the package API `tif.load`, `tif.save`, `tif.write`, and `tif.frame` under `src/+tif/`.
- The root contains the entry, environment, README, changelog, and context surfaces expected by the adopted conventions.
- The old root-level MATLAB functions are removed.

## Assumptions

- **Backward compatibility is not required** - old calls such as `loadTif(...)` may stop working.
- **MATLAB is available locally** - the test oracle uses MATLAB Unit Test.
- **The framework checkout is available at `D:\code\all-you-need-is-trust`** - project checks use its local `aynit` tools.

## Decisions

### Needs Your Response

- None for this slice.

### Already Made

- **Namespace:** use `+tif` with public calls like `tif.load(...)`, because this matches MATLAB package conventions and the desired compact API.
- **Branch:** work on `structure-alignment`, then merge after review.

## Oracle(s)

| capability / claim | oracle (independent, up-front) | check |
| --- | --- | --- |
| MATLAB package structure and round trip work | MATLAB Unit Test exercises package files and a `uint16` save/load round trip | `matlab -batch "results = runtests('tests'); assertSuccess(results);"` |
| Agent entry and project signals are present | all-you-need-is-trust readiness checker | `$env:PYTHONPATH='D:\code\all-you-need-is-trust\tools\src'; python -m aynit.cli check-project . --format text` |

## Scope

- In: package layout, agent entry/context files, environment docs, README, tests, example location.
- Out: behavioral edge-case fixes, old root API wrappers, publishing a release.

## Public Interface

- `tif.load` - load a TIFF file or image sequence as a stack.
- `tif.save` - save a stack as a multipage TIFF.
- `tif.write` - write one TIFF image.
- `tif.frame` - count frames in a TIFF file.

## Seal

- Sealed at: branch `structure-alignment`; ground: MATLAB Unit Test and all-you-need-is-trust `check-project`; by: Codex, on 2026-07-05.
