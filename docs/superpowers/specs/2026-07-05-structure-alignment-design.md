# Structure Alignment Design

## Decision

Align this repository as an agentic MATLAB package on branch `structure-alignment`.

The public MATLAB API will be namespaced:

```matlab
stack = tif.load(path);
tif.save(path, stack);
tif.write(path, image);
n = tif.frame(path);
```

Backward compatibility with the old root-level functions is not required for this branch.

## Scope

This branch is the first structural slice. It prepares the repository for future agentic work without changing TIFF behavior intentionally.

In scope:

- Move source code under `src/+tif/`.
- Rename public functions from `loadTif`, `saveTif`, `writeTif`, and `tifFrame` to `load`, `save`, `write`, and `frame`.
- Add a `Contents.m` API gateway for the `tif` package.
- Add root agentic project files: `AGENTS.md`, `ENVIRONMENT.md`, `CHANGELOG.md`, `.gitignore` updates, and a stronger `README.md`.
- Vendor the all-you-need-is-trust conventions into `context/`.
- Add minimal work memory under `context/`, including `jobs.md` and the effort/plan/log/report surfaces for this slice.
- Add MATLAB tests that prove the package API is visible and a simple TIFF round trip works.
- Move the hardcoded conversion script into `examples/`.

Out of scope:

- Preserving old unqualified function calls.
- Fixing behavioral edge cases not exposed by structure tests.
- Redesigning TIFF metadata semantics.
- Publishing a package release.

## Architecture

MATLAB source lives in one package folder:

```text
src/
  +tif/
    Contents.m
    load.m
    save.m
    write.m
    frame.m
```

Examples live outside the package:

```text
examples/
  sequence_to_multipage.m
```

Tests live under `tests/` and add `src/` to the MATLAB path before calling package functions.

Agentic memory lives under `context/`. The vendored convention bundle is copied from `D:\code\all-you-need-is-trust` so future agents can work from this repo alone.

## Oracle

The structure alignment is accepted when all of these pass:

- `check-project . --format text` reports no failures.
- MATLAB tests pass from the repo root.
- The MATLAB package exposes non-empty H1 help lines for `tif.load`, `tif.save`, `tif.write`, and `tif.frame`.
- A generated `uint16` stack can be saved with `tif.save`, loaded with `tif.load`, and compared exactly.

## Risks

- `tif.load` and `tif.save` share names with MATLAB builtins, but they are only used through the `tif.` package qualifier.
- MATLAB `arguments` blocks may require R2019b or newer; the environment document will state that requirement.
- The current code has existing edge cases, such as folder ordering and metadata handling. This branch keeps those concerns visible but does not try to solve them.

## Expected Result

After this branch, a fresh agent should start at `AGENTS.md`, reach current work through `context/jobs.md`, understand the adopted conventions, run the project checks, and use the public package as `tif.*`.
