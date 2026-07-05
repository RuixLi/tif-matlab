---
kind: scheme
name: behavior roadmap
status: active
description: Coordinates reliability and performance patches for the TIFF package after structure alignment.
created: "2026-07-05T18:38"
updated: "2026-07-05T18:38"
---
# Behavior Roadmap - Scheme

Coordinate the next behavior work for `tif-matlab` without losing the ideas discussed after the structure alignment merge.

## Outcome

- Reliability risks are handled before widening the API.
- Performance and large-data features build on the reliable behavior contract.
- Each patch has its own effort, branch, oracle, plan, and report before implementation.

## Milestones

1. **Reliability-first I/O** - make the existing `tif.*` API safer, deterministic, and test-covered.
2. **Performance and large-data support** - add inspection and loading/saving options that help with large microscopy stacks.

## Modules

- [Reliability-first I/O](20260705-reliability-first-io.md)
- [Performance and large-data support](20260705-performance-large-data.md)

## Decisions

### Needs Your Response

- **Implementation order after reliability** - decide whether performance should prioritize load-time memory control, save-time BigTIFF/compression, or metadata inspection.

### Already Made

- **Reliability first** - silent data corruption and nondeterministic file loading are higher risk than missing convenience features.
- **Separate efforts** - reliability and performance should be separate branches because they have different oracles and review surfaces.

## Shared Constraints

- Keep the public namespace `tif.*`.
- Preserve MATLAB-only implementation unless a later effort justifies another dependency.
- Add tests before behavior changes.
- Avoid adding generated TIFF artifacts to git.

## Success Signal

This scheme is complete when both linked efforts have reports, and the follow-up API is stable enough to update `README.md` and `CHANGELOG.md`.
