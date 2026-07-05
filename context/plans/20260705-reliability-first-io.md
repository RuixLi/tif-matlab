---
kind: plan
name: reliability-first io
status: completed
description: Adds strict validation and deterministic TIFF I/O behavior under the existing tif namespace.
created: "2026-07-05T18:49"
updated: "2026-07-05T18:56"
---
# Reliability-First I/O Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Harden `tif.load`, `tif.save`, `tif.write`, and `tif.frame` so invalid inputs fail strictly and ordinary TIFF stack operations are deterministic.

**Architecture:** Keep the public API in `src/+tif/`. Add `arguments` blocks to all public functions, rewrite `tif.load` around small local helper functions for path discovery, frame range normalization, and tag collection, and keep tests in `tests/test_reliability_io.m`.

**Tech Stack:** MATLAB package functions, MATLAB Unit Test, `Tiff`, `imfinfo`, `imwrite`.

---

## Work Documents

- Effort: [reliability-first io](../efforts/20260705-reliability-first-io.md)
- Log: [reliability-first io](../logs/20260705-reliability-first-io.md)

## Decisions

### Needs Your Response

- None. Strict errors and `arguments` blocks were approved by the user on 2026-07-05.

### Already Made

- Use strict errors for missing paths, empty folders, frame ranges, mixed folder image sizes, and dtype/bit-depth mismatches.
- Keep name-value expansion minimal; this branch preserves positional `index` and `stride` while making their semantics reliable.
- Keep exact `uint8`/`uint16` preservation; do not silently rescale in `tif.save`.

## Tasks

### Task 1: Reliability Oracle

**Files:**
- Create: `tests/test_reliability_io.m`

- [x] Write tests for string/char paths, `.tif`/`.tiff`, deterministic folder loading, `[start -1]` frame ranges, stride, out-of-range errors, empty folders, mixed image sizes, dtype mismatch, and `tif.write` uint8 strictness.
- [x] Run `matlab -batch "results = runtests('tests'); assertSuccess(results);"` and verify the new tests fail for the current behavior.
- [x] Commit the failing oracle.

### Task 2: Strict Load And Frame Behavior

**Files:**
- Modify: `src/+tif/load.m`
- Modify: `src/+tif/frame.m`

- [x] Add `arguments` blocks to `tif.load` and `tif.frame`.
- [x] Normalize text paths from `char` or scalar `string`.
- [x] Strictly error for missing paths, empty folders, unsupported source types, invalid frame ranges, and out-of-range frame requests.
- [x] Load folder TIFFs in deterministic natural order and verify every image has the same size/class before writing into the output stack.
- [x] Restore warning state and close internally opened `Tiff` handles with cleanup guards.
- [x] Run MATLAB tests and commit when green.

### Task 3: Strict Save And Write Behavior

**Files:**
- Modify: `src/+tif/save.m`
- Modify: `src/+tif/write.m`

- [x] Add `arguments` blocks to `tif.save` and `tif.write`.
- [x] Accept `char` and scalar `string` paths.
- [x] Require `BitsPerSample` to match stack class: `uint8` with 8 and `uint16` with 16.
- [x] Require `tif.write` image input to be `uint8` so a single-image write does not silently rescale data.
- [x] Ensure output folders exist before writing and close `Tiff` handles with cleanup guards.
- [x] Run MATLAB tests and commit when green.

### Task 4: Docs And Report

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Modify: `context/jobs.md`
- Modify: `context/efforts/20260705-reliability-first-io.md`
- Modify: `context/logs/20260705-reliability-first-io.md`
- Create: `context/reports/20260705-reliability-first-io.md`
- Regenerate: `context/efforts.md`, `context/plans.md`, `context/logs.md`, `context/reports.md`

- [x] Document strict dtype behavior and frame range semantics.
- [x] Record final oracle results in the report.
- [x] Run `matlab -batch "results = runtests('tests'); assertSuccess(results);"` and `python -m aynit.cli check-project . --format text`.
- [x] Commit the final report.

## Untouchables

- Do not implement BigTIFF, compression options, streaming APIs, or metadata redesign in this branch.
- Do not commit generated TIFF files.
