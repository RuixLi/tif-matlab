---
kind: report
name: reliability-first io
status: passed
description: Strict validation, deterministic folder loading, and dtype-safe TIFF I/O passed the reliability oracle.
created: "2026-07-05T18:56"
updated: "2026-07-05T18:56"
---
# Reliability-First I/O - Report

## Status

- **passed** - The reliability-first I/O oracle passed on branch `reliability-first-io`.

## Evidence

- `matlab -batch "results = runtests('tests'); assertSuccess(results);"` passed with `test_reliability_io` and `test_structure_alignment`.
- `$env:PYTHONPATH='D:\code\all-you-need-is-trust\tools\src'; python -m aynit.cli check-project . --format text` reported 11 passes, 0 failures, 0 warnings, and 0 not-applicable checks.

## Related Files

- [effort](../efforts/20260705-reliability-first-io.md)
- [plan](../plans/20260705-reliability-first-io.md)
- [log](../logs/20260705-reliability-first-io.md)
- [source](../../src/+tif/)
- [tests](../../tests/test_reliability_io.m)

## Next Action(s)

- Review the branch result -> [jobs](../jobs.md)
- Merge `reliability-first-io` into `main` after human approval.
