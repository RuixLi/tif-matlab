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

**Next:** Add the performance oracle tests.
