---
kind: report
name: performance and large-data support
status: passed
description: Metadata inspection, selected-frame coverage, and semi-automatic BigTIFF save behavior passed the performance oracle.
created: "2026-07-06T00:20"
updated: "2026-07-06T00:20"
---
# Performance And Large-Data Support - Report

## Status

- **passed** - `tif.info`, selected-frame load coverage, explicit BigTIFF save, and automatic BigTIFF upgrade passed the MATLAB oracle.

## Related Files

- [effort](../efforts/20260705-performance-large-data.md) | [plan](../plans/20260705-performance-large-data.md) | [log](../logs/20260705-performance-large-data.md)
- Source: [info.m](../../src/+tif/info.m), [save.m](../../src/+tif/save.m), [Contents.m](../../src/+tif/Contents.m)
- Tests: [test_performance_large_data.m](../../tests/test_performance_large_data.m), [test_structure_alignment.m](../../tests/test_structure_alignment.m)
- Docs: [README.md](../../README.md), [CHANGELOG.md](../../CHANGELOG.md), [AGENTS.md](../../AGENTS.md)

## Oracle Results

- `matlab -batch "results = runtests('tests/test_performance_large_data.m'); assertSuccess(results);"` passed.
- `matlab -batch "results = runtests('tests'); assertSuccess(results);"` passed.
- `$env:PYTHONPATH='D:\code\all-you-need-is-trust\tools\src'; python -m aynit.cli check-project . --format text` passed with 11 passes, 0 failures, and 0 warnings.

## Next Action(s)

- Review the stacked `reliability-first-io` branch result before merge -> [jobs](../jobs.md)
