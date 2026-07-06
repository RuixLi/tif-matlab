# Changelog

All notable changes to this package are recorded here.

## [Unreleased]

- No unreleased changes.

## [2.0.0] - 2026-07-06

### Changed

- Move the public MATLAB API to the `tif` package namespace: `tif.load`, `tif.info`, `tif.save`, `tif.write`, and `tif.frame`.
- Add agentic project entry and context surfaces for all-you-need-is-trust alignment.
- Harden TIFF I/O behavior with strict input validation, deterministic folder loading, string path support, and explicit bit-depth/class checks.
- Add `tif.info` metadata inspection without pixel loading.
- Add explicit and automatic BigTIFF support to `tif.save`.
- Expand public function help and README API documentation with syntax, input contracts, outputs, and examples.

## [1.0.2] - 2025-07-04

### Added

- Historical repository state before agentic structure alignment.
