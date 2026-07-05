# AGENTS.md

You are reading `AGENTS.md`, the entry point for agents working on this repository. Read it fully at the start of each session.

## Project

- **What:** `tif-matlab` is a MATLAB package for reading and writing microscopy TIFF image stacks.
- **Purpose:** Provide a small, namespaced TIFF I/O API for MATLAB research code.
- **Primary language:** MATLAB.
- **Archetype:** `package`; status: development.
- **Public API:** `tif.load`, `tif.save`, `tif.write`, and `tif.frame` in [src/+tif/](src/+tif/).

## How To Work Here

- **Conventions:** Follow the vendored all-you-need-is-trust conventions at [context/conventions.md](context/conventions.md), pinned by [context/conventions-bundle.json](context/conventions-bundle.json).
- **Source:** MATLAB package code lives under `src/+tif/`; do not add new root-level MATLAB functions.
- **Tests:** Add MATLAB tests under `tests/` before changing behavior.
- **Verification:** Run `matlab -batch "results = runtests('tests'); assertSuccess(results);"` after code changes. Run the project readiness check before closing an agentic structure change.

### Deviations From The Conventions

- The first alignment branch intentionally removes backward compatibility for old root functions because the new package API is the desired public surface.

## Current Work

- See [context/jobs.md](context/jobs.md).

## Where To Look

| need | file |
| --- | --- |
| overview and usage | [README.md](README.md) |
| environment and setup | [ENVIRONMENT.md](ENVIRONMENT.md) |
| source package | [src/+tif/](src/+tif/) |
| tests | [tests/](tests/) |
| changelog | [CHANGELOG.md](CHANGELOG.md) |
| current work | [context/jobs.md](context/jobs.md) |
| efforts | [context/efforts/](context/efforts/) |
| plans | [context/plans/](context/plans/) |
| logs | [context/logs/](context/logs/) |
| reports | [context/reports/](context/reports/) |
| adopted conventions | [context/conventions.md](context/conventions.md) |
