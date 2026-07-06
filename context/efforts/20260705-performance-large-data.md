---
kind: effort
name: performance and large-data support
status: active
description: Adds inspection and large-stack options after the reliability contract is stable.
created: "2026-07-05T18:38"
updated: "2026-07-06T00:00"
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

- None for this increment.

### Already Made

- **Inspection is first** - add `tif.info(source)` because it avoids pixel allocation and helps validate inputs.
- **Selected-frame loading stays positional** - current `tif.load(path, [start end], stride)` already loads selected frames without returning the full stack, so this increment documents and tests that behavior instead of adding a duplicate `Frames=` API.
- **BigTIFF is semi-automatic** - `BigTiff=true` forces BigTIFF, and default saves auto-upgrade to BigTIFF when estimated output size exceeds the classic TIFF threshold with a stdout notice.
- **Streaming is later** - callback or block-wise APIs need a clearer use case before becoming public surface.
- **Benchmarks are deferred** - this increment uses generated test data and metadata/size oracles; a benchmark harness can follow after the API settles.

## Oracle(s)

| capability / claim | oracle (independent, up-front) | check |
| --- | --- | --- |
| Metadata inspection avoids pixel allocation | Test verifies `tif.info` reports size, frame count, dtype, selected tags, and BigTIFF header status without returning image data | `tests/test_performance_large_data.m` |
| Partial loading controls memory | Test loads selected frames and verifies output shape/content using the existing `tif.load(path, [start end], stride)` API | `tests/test_performance_large_data.m` |
| BigTIFF save options are passed through correctly | Test writes with `BigTiff=true` and verifies readable output plus BigTIFF header status | `tests/test_performance_large_data.m` |
| Automatic BigTIFF upgrade is observable | Test lowers the threshold on a small generated stack, captures stdout, and verifies readable BigTIFF output | `tests/test_performance_large_data.m` |

## Scope

- In: `tif.info`, selected-frame loading coverage, semi-automatic BigTIFF save options, README/CHANGELOG updates.
- Out: GPU acceleration, parallel processing, OME-TIFF metadata authoring, compression controls, streaming callbacks, external compiled dependencies.

## Design

Build performance features as additive APIs around the reliability contract. Prefer metadata-first inspection and frame selection before introducing streaming or broader save customization.

## Public Interface

- `info = tif.info(source)` where source is a file or folder path.
- `stack = tif.load(path, [start end], stride)` remains the selected-frame API.
- `tif.save(path, stack, bitspersamp, imageDescription, BigTiff=true)` forces BigTIFF.
- `tif.save(path, stack, ..., BigTiffThresholdBytes=n)` exists as an advanced/testable threshold for automatic upgrade.

## Seal

- Sealed at: 2026-07-06 on branch `reliability-first-io` before merge to `main`.
