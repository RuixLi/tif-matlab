---
kind: plan
name: performance and large-data support
status: in-execution
description: Adds metadata inspection, selected-frame coverage, and semi-automatic BigTIFF save behavior.
created: "2026-07-06T00:00"
updated: "2026-07-06T00:00"
---
# Performance And Large-Data Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the first conservative large-data features: metadata inspection without pixel loading, documented selected-frame loading, and BigTIFF write support when requested or required by estimated output size.

**Architecture:** Keep all public MATLAB APIs in `src/+tif/`. Add `tif.info` as a metadata-only inspector built on `imfinfo` plus a TIFF header check for BigTIFF, extend `tif.save` with name-value BigTIFF options, and cover the behavior in `tests/test_performance_large_data.m`.

**Tech Stack:** MATLAB package functions, MATLAB Unit Test, `Tiff`, `imfinfo`, TIFF header bytes.

---

## Work Documents

- Effort: [performance and large-data support](../efforts/20260705-performance-large-data.md)
- Log: [performance and large-data support](../logs/20260705-performance-large-data.md)

## Decisions

### Needs Your Response

- None. The user approved the narrowed scope on 2026-07-06.

### Already Made

- Implement `tif.info(source)` for file and folder sources; do not add a second selected-frame API yet.
- Treat selected-frame loading as already supported by `tif.load(path, [start end], stride)` and add performance-contract coverage for that behavior.
- Add `BigTiff=true` to force BigTIFF save mode.
- Auto-upgrade to BigTIFF when the estimated output size crosses the classic TIFF threshold and print a stdout notice.
- Leave compression controls, streaming callbacks, and OME-TIFF metadata authoring for later efforts.

## Tasks

### Task 1: Start Effort Documents

**Files:**
- Modify: `context/efforts/20260705-performance-large-data.md`
- Modify: `context/jobs.md`
- Create: `context/plans/20260705-performance-large-data.md`
- Create: `context/logs/20260705-performance-large-data.md`

- [x] Move the performance effort from `proposed` to `active`.
- [x] Record the approved narrow scope in this plan.
- [x] Create the execution log before touching behavior code.
- [x] Commit the planning checkpoint.

### Task 2: Performance Oracle

**Files:**
- Create: `tests/test_performance_large_data.m`

- [x] Write tests for `tif.info` on a multipage file, `tif.info` on a naturally sorted folder, selected-frame loading, explicit BigTIFF save mode, and automatic BigTIFF upgrade using a tiny test threshold.
- [x] Run `matlab -batch "results = runtests('tests/test_performance_large_data.m'); assertSuccess(results);"` and verify the new tests fail because `tif.info` and BigTIFF options are not implemented yet.
- [x] Commit the failing oracle.

### Task 3: Metadata Inspection

**Files:**
- Create: `src/+tif/info.m`
- Modify: `src/+tif/Contents.m`

- [x] Implement `tif.info(source)` with an `arguments` block accepting `char` and scalar `string` paths.
- [x] For files, report `SourceType`, `Path`, `Files`, `FrameCount`, `PagesPerFile`, `ImageSize`, `ImageLength`, `ImageWidth`, `BitsPerSample`, `SamplesPerPixel`, `Class`, `Compression`, `ImageDescription`, `EstimatedStackBytes`, and `IsBigTiff`.
- [x] For folders, list `.tif` and `.tiff` files in natural order, report one loadable frame per file, and validate metadata consistency without reading pixel data.
- [x] Run the performance test file and verify the `tif.info` tests pass while BigTIFF tests still fail.

### Task 4: BigTIFF Save Mode

**Files:**
- Modify: `src/+tif/save.m`

- [ ] Add `BigTiff` and `BigTiffThresholdBytes` name-value options after the existing positional arguments.
- [ ] Use MATLAB `Tiff` mode `'w8'` when `BigTiff=true`.
- [ ] Estimate output size from stack element count, bytes per sample, and a small per-directory overhead; use `'w8'` automatically when the estimate exceeds the threshold.
- [ ] Print a stdout notice only for automatic BigTIFF upgrade.
- [ ] Run the performance test file and verify all new tests pass.

### Task 5: Docs, Report, And Verification

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Modify: `context/efforts/20260705-performance-large-data.md`
- Modify: `context/jobs.md`
- Modify: `context/logs/20260705-performance-large-data.md`
- Create: `context/reports/20260705-performance-large-data.md`
- Regenerate: `context/efforts.md`, `context/plans.md`, `context/logs.md`, `context/reports.md`

- [ ] Document `tif.info`, selected-frame loading, and BigTIFF save behavior.
- [ ] Record the final oracle results in a report.
- [ ] Run `matlab -batch "results = runtests('tests'); assertSuccess(results);"`.
- [ ] Run `$env:PYTHONPATH='D:\code\all-you-need-is-trust\tools\src'; python -m aynit.cli check-project . --format text`.
- [ ] Commit the completed performance patch.

## Untouchables

- Do not commit generated TIFF files.
- Do not implement streaming callbacks, compression options, or OME-TIFF metadata authoring in this effort.
- Do not merge back to `main` until the user confirms the final branch result.
