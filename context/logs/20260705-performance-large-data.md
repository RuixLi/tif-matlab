---
kind: log
name: performance and large-data support
status: in-execution
description: Records the performance and large-data support branch execution.
created: "2026-07-06T00:00"
updated: "2026-07-06T00:00"
---
# Performance And Large-Data Support - Log

## Related Files

- [effort](../efforts/20260705-performance-large-data.md) | [plan](../plans/20260705-performance-large-data.md)

## Log

### 2026-07-06 - Started stacked performance patch

- Continued on branch `reliability-first-io` before the reliability branch merge.
- User approved the narrowed scope: add `tif.info`, keep selected-frame loading on the existing `tif.load(path, [start end], stride)` API, and add semi-automatic BigTIFF support to `tif.save`.
- Created this plan and log before touching behavior code.

### 2026-07-06 - Performance oracle

- Added `tests/test_performance_large_data.m`.
- Verified `matlab -batch "results = runtests('tests/test_performance_large_data.m'); assertSuccess(results);"` failed for the intended reasons: `tif.info` is undefined, and `tif.save` rejects the new BigTIFF name-value options.

### 2026-07-06 - Metadata inspection

- Added `src/+tif/info.m`.
- Added package listing for `tif.info` in `src/+tif/Contents.m`.
- Verified the focused performance test now passes the `tif.info` and selected-frame tests; only the BigTIFF `tif.save` tests remain red.

**Next:** Implement BigTIFF mode selection in `tif.save`.
