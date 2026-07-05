---
kind: log
name: reliability-first io
status: in-execution
description: Records the reliability-first I/O branch execution.
created: "2026-07-05T18:49"
updated: "2026-07-05T18:56"
---
# Reliability-First I/O - Log

## Related Files

- [effort](../efforts/20260705-reliability-first-io.md) | [plan](../plans/20260705-reliability-first-io.md)

## Log

### 2026-07-05 - Started branch

- Created branch `reliability-first-io`.
- User approved strict errors and `arguments` blocks.
- Created this plan and log before touching behavior code.

### 2026-07-05 - Reliability oracle

- Added `tests/test_reliability_io.m`.
- Verified the new test file failed against the old behavior for string paths, strict error IDs, natural folder order, `-1` frame end sentinel, range checks, mixed image sizes, and silent dtype conversion.

### 2026-07-05 - Strict I/O implementation

- Added `arguments` blocks to `tif.load`, `tif.save`, `tif.write`, and `tif.frame`.
- Reworked `tif.load` to normalize text paths, load folders in natural order, validate frame ranges, validate shape/class consistency, restore TIFF warning state, and close internally opened `Tiff` handles.
- Changed `tif.save` to require `uint8` for 8-bit output and `uint16` for 16-bit output.
- Changed `tif.write` to require `uint8` input instead of silently rescaling.
- Verified `matlab -batch "results = runtests('tests'); assertSuccess(results);"` passed after implementation.

### 2026-07-05 - Final verification

- Verified `matlab -batch "results = runtests('tests'); assertSuccess(results);"` passed with `test_reliability_io` and `test_structure_alignment`.
- Verified `$env:PYTHONPATH='D:\code\all-you-need-is-trust\tools\src'; python -m aynit.cli check-project . --format text` reported 11 passes, 0 failures, and 0 warnings.

**Next:** Human review of branch `reliability-first-io`; merge to `main` only after approval.
