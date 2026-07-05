---
kind: effort
name: performance and large-data support
status: proposed
description: Adds inspection and large-stack options after the reliability contract is stable.
created: "2026-07-05T18:38"
updated: "2026-07-05T18:38"
---
# Performance And Large-Data Support - Effort

Add useful performance features for microscopy stacks once the reliability-first behavior is in place.

## Outcome

- Users can inspect TIFF stack metadata without loading pixel data.
- Users can load selected frames without allocating the full stack.
- Save behavior exposes useful large-file options where MATLAB `Tiff` supports them.
- Performance changes are measured against small reproducible benchmarks.

## Assumptions

- **Reliability-first I/O lands first** - performance work depends on stable path, frame, and dtype semantics.
- **Large data should not be committed** - benchmarks use generated temporary stacks or documented local artifacts.
- **The first performance API should be conservative** - add only features with clear microscopy workflow value.

## Decisions

### Needs Your Response

- **First performance priority** - options: `tif.info`, partial frame loading, BigTIFF/compression save options, or streaming callback.
- **Benchmark scale** - choose generated stack sizes that are large enough to catch regressions but small enough for routine local tests.

### Already Made

- **Inspection is low risk** - `tif.info(path)` is likely the first useful feature because it avoids pixel allocation and helps validate inputs.
- **Streaming is powerful but later** - callback or block-wise APIs need a clearer use case before becoming public surface.

## Oracle(s)

| capability / claim | oracle (independent, up-front) | check |
| --- | --- | --- |
| Metadata inspection avoids pixel allocation | Test verifies `tif.info` reports size, frame count, dtype, and selected tags from `imfinfo`/`Tiff` without returning image data | `tests/test_performance_api.m` |
| Partial loading controls memory | Test loads selected frames and verifies output shape/content without reading every frame into the result | `tests/test_performance_api.m` |
| Save options are passed through correctly | Test writes with selected compression / BigTIFF-compatible options where supported and verifies readable output | `tests/test_performance_api.m` |
| Performance does not regress obviously | Benchmark script records timing for generated stacks and compares against a baseline documented in the effort report | `run/` job log and report evidence |

## Scope

- In: `tif.info`, partial-frame load options, optional save options, small benchmark harness, README/CHANGELOG updates.
- Out: GPU acceleration, parallel processing, OME-TIFF metadata authoring, external compiled dependencies.

## Design

Build performance features as additive APIs around the reliability contract. Prefer metadata-first inspection and frame selection before introducing streaming or broader save customization.

## Public Interface

- Candidate: `info = tif.info(path)`.
- Candidate: `stack = tif.load(path, Frames=frames, Stride=stride)`.
- Candidate: `tif.save(path, stack, BitsPerSample=16, Compression="none", BigTiff=false)`.

## Seal

- Sealed at: pending future performance branch.
