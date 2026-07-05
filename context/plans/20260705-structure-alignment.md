---
kind: plan
name: structure alignment
status: completed
description: Executes the first structural slice that turns the loose MATLAB utilities into an agent-ready package.
created: "2026-07-05T18:11"
updated: "2026-07-05T18:25"
---
# Structure Alignment - Plan

Execute the approved structure alignment design and the detailed implementation plan.

## Work Documents

- Effort: [structure alignment](../efforts/20260705-structure-alignment.md)
- Log: [structure alignment](../logs/20260705-structure-alignment.md)
- Detailed plan: [2026-07-05-structure-alignment.md](../archive/superpowers/2026-07-05-structure-alignment.md)

## Decisions

### Needs Your Response

- None.

### Already Made

- Use inline execution on branch `structure-alignment`; subagent spawning requires explicit user authorization in this tool environment.

## Architecture

- `src/+tif/` holds package source and `Contents.m`.
- `tests/` holds MATLAB Unit Test files.
- `context/` holds conventions and work memory.
- `examples/` holds runnable usage scripts.

## Tasks

- [x] Write failing MATLAB structure oracle.
- [x] Move MATLAB API into `src/+tif`.
- [x] Add agentic project surfaces.
- [x] Move conversion script into `examples/`.
- [x] Run final verification and write report.

## Untouchables

- Do not edit `LICENSE`.
- Do not add sample microscopy data to git.
