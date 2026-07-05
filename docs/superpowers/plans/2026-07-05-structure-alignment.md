# Structure Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the loose MATLAB TIFF utilities into an agent-ready package with the public API `tif.load`, `tif.save`, `tif.write`, and `tif.frame`.

**Architecture:** Source code moves into `src/+tif/` with `Contents.m` as the public gateway. Agentic project memory lives under `context/`, and MATLAB tests in `tests/` prove the package surface and round-trip TIFF behavior.

**Tech Stack:** MATLAB package folders, MATLAB Unit Test, all-you-need-is-trust project checks, Markdown project/context documents.

---

### Task 1: Add The MATLAB Structure Oracle

**Files:**
- Create: `tests/test_structure_alignment.m`

- [ ] **Step 1: Write the failing package structure and round-trip test**

Create `tests/test_structure_alignment.m` with:

```matlab
classdef test_structure_alignment < matlab.unittest.TestCase
    methods (Test)
        function packageFunctionsHaveHelp(testCase)
            repoRoot = fileparts(fileparts(mfilename('fullpath')));
            packageRoot = fullfile(repoRoot, 'src', '+tif');
            publicFiles = {'load.m', 'save.m', 'write.m', 'frame.m'};

            testCase.verifyTrue(isfile(fullfile(packageRoot, 'Contents.m')));
            for i = 1:numel(publicFiles)
                filePath = fullfile(packageRoot, publicFiles{i});
                testCase.verifyTrue(isfile(filePath), filePath);
                text = fileread(filePath);
                testCase.verifyNotEmpty(regexp(text, '^\s*%\s+\S+', 'once', 'lineanchors'), filePath);
            end
        end

        function saveLoadRoundTripPreservesUint16Stack(testCase)
            repoRoot = fileparts(fileparts(mfilename('fullpath')));
            addpath(fullfile(repoRoot, 'src'));
            cleanupPath = onCleanup(@() rmpath(fullfile(repoRoot, 'src')));

            stack = uint16(reshape(1:24, [3 4 2]));
            outDir = tempname;
            mkdir(outDir);
            cleanupDir = onCleanup(@() rmdir(outDir, 's'));
            outFile = fullfile(outDir, 'roundtrip.tif');

            tif.save(outFile, stack, 16, 'structure alignment round trip');
            loaded = tif.load(outFile);

            testCase.verifyEqual(loaded, stack);
        end
    end
end
```

- [ ] **Step 2: Run the test to verify RED**

Run:

```powershell
matlab -batch "results = runtests('tests'); assertSuccess(results);"
```

Expected: FAIL because `src/+tif/` does not exist yet.

- [ ] **Step 3: Commit the failing oracle**

```powershell
git add tests/test_structure_alignment.m
git commit -m "test: add structure alignment oracle"
```

### Task 2: Move MATLAB Code Into The `tif` Package

**Files:**
- Create: `src/+tif/Contents.m`
- Create: `src/+tif/load.m`
- Create: `src/+tif/save.m`
- Create: `src/+tif/write.m`
- Create: `src/+tif/frame.m`
- Delete: `loadTif.m`
- Delete: `saveTif.m`
- Delete: `writeTif.m`
- Delete: `tifFrame.m`

- [ ] **Step 1: Create package directory**

Run:

```powershell
New-Item -ItemType Directory -Force -Path 'src\+tif'
```

- [ ] **Step 2: Add `Contents.m` gateway**

Create `src/+tif/Contents.m`:

```matlab
% tif - Read and write microscopy TIFF image stacks.
%
% Functions
%   load  - Load a TIFF file or TIFF image sequence as a Y-by-X-by-T stack.
%   save  - Save a Y-by-X-by-T stack as a multipage TIFF file.
%   write - Write a single grayscale or RGB image to a TIFF file.
%   frame - Count frames in a TIFF file.
```

- [ ] **Step 3: Add `tif.load`**

Create `src/+tif/load.m` by adapting `loadTif.m`:

```matlab
function [stack, tfTag] = load(tiffFile, index, stride)
% LOAD Load a TIFF file or TIFF image sequence as a Y-by-X-by-T stack.
```

The implementation body is the existing `loadTif` body with these structural edits:

- Function name becomes `load`.
- Output variable `TFtag` becomes `tfTag`.
- Calls to `tifFrame(t)` become `tif.frame(t)`.
- Keep existing behavior otherwise.

- [ ] **Step 4: Add `tif.save`**

Create `src/+tif/save.m` by adapting `saveTif.m`:

```matlab
function save(fname, stack, bitspersamp, imageDescription)
% SAVE Save a Y-by-X-by-T stack as a multipage TIFF file.
```

The implementation body is the existing `saveTif` body with these structural edits:

- Function name becomes `save`.
- Argument `ImageDescription` becomes `imageDescription`.
- Internal flag `writeImDesc` remains acceptable.
- Keep existing behavior otherwise.

- [ ] **Step 5: Add `tif.write`**

Create `src/+tif/write.m` by adapting `writeTif.m`:

```matlab
function write(fname, im)
% WRITE Write a single grayscale or RGB image to a TIFF file.
```

The implementation body is the existing `writeTif` body with these structural edits:

- Function name becomes `write`.
- Status message becomes `tif.write: cast image into uint8`.
- Helper functions remain local to `write.m`.
- Keep existing behavior otherwise.

- [ ] **Step 6: Add `tif.frame`**

Create `src/+tif/frame.m` by adapting `tifFrame.m`:

```matlab
function n = frame(tifFile, seekInterval)
% FRAME Count frames in a TIFF file.
```

The implementation body is the existing `tifFrame` body with this compatibility improvement:

```matlab
if isa(tifFile, 'Tiff')
    info = imfinfo(tifFile.FileName);
else
    info = imfinfo(tifFile);
end
n = numel(info);
```

Retain the old commented note if useful.

- [ ] **Step 7: Delete the old root-level function files**

Remove the old unnamespaced public functions:

```powershell
Remove-Item -LiteralPath 'loadTif.m','saveTif.m','writeTif.m','tifFrame.m'
```

- [ ] **Step 8: Run the MATLAB test to verify GREEN**

Run:

```powershell
matlab -batch "results = runtests('tests'); assertSuccess(results);"
```

Expected: PASS.

- [ ] **Step 9: Commit the package move**

```powershell
git add src tests loadTif.m saveTif.m writeTif.m tifFrame.m
git commit -m "refactor: move MATLAB API into tif package"
```

### Task 3: Add Agentic Project Surfaces

**Files:**
- Create: `AGENTS.md`
- Create: `ENVIRONMENT.md`
- Create: `CHANGELOG.md`
- Modify: `.gitignore`
- Modify: `README.md`
- Create: `context/` files copied from the framework bundle.
- Create: `context/jobs.md`
- Create: `context/efforts/20260705-structure-alignment.md`
- Create: `context/plans/20260705-structure-alignment.md`
- Create: `context/logs/20260705-structure-alignment.md`

- [ ] **Step 1: Vendor the framework bundle**

Run from the source framework checkout:

```powershell
$env:PYTHONPATH='D:\code\all-you-need-is-trust\tools\src'; python -m aynit.cli vendor-conventions 'D:\code\all-you-need-is-trust' 'D:\code\tif-matlab\context'
```

Expected: creates `context/conventions.md`, `context/conventions/`, `context/references.md`, `context/references/`, `context/templates.md`, `context/templates/`, and `conventions-bundle.json`.

- [ ] **Step 2: Add root `AGENTS.md`**

Create an entry point that names:

- Project: `tif-matlab`, a MATLAB package for TIFF stack I/O.
- Archetype: `package`.
- Primary language: MATLAB.
- Conventions: `context/conventions.md` and `conventions-bundle.json`.
- Current work: `context/jobs.md`.
- Navigation links for README, environment, source, tests, changelog, and work documents.

- [ ] **Step 3: Add `ENVIRONMENT.md`**

Record:

- MATLAB R2019b or newer, because package folders and `arguments`-block-compatible style are expected.
- Image Processing Toolbox, because the code uses `Tiff`, `imwrite`, `imfinfo`, and `rescale`.
- Python 3.11 or compatible only for `aynit` project checks when run from the local framework checkout.

- [ ] **Step 4: Add `CHANGELOG.md`**

Use Keep a Changelog shape with:

- `## [Unreleased]`
- `### Changed`
- Structure alignment branch moves the API to `tif.*`.

- [ ] **Step 5: Update `.gitignore`**

Ignore local/generated files:

```gitignore
.DS_Store
run/
*.asv
*.m~
*.tif
*.tiff
```

- [ ] **Step 6: Rewrite README**

Document:

- Purpose.
- New `tif.*` API.
- Setup by adding `src/` to MATLAB path.
- Minimal save/load example.
- Test command.
- Pointer to `AGENTS.md`.

- [ ] **Step 7: Add current work documents**

Create `context/jobs.md`, effort, plan, and log files with valid YAML frontmatter. The effort oracle must point to:

- `matlab -batch "results = runtests('tests'); assertSuccess(results);"`
- `$env:PYTHONPATH='D:\code\all-you-need-is-trust\tools\src'; python -m aynit.cli check-project . --format text`

- [ ] **Step 8: Commit agentic surfaces**

```powershell
git add AGENTS.md ENVIRONMENT.md CHANGELOG.md README.md .gitignore context conventions-bundle.json
git commit -m "docs: add agentic project surfaces"
```

### Task 4: Move The Example Script

**Files:**
- Create: `examples/sequence_to_multipage.m`
- Delete: `script_sequnece_to_multipage.m`

- [ ] **Step 1: Create examples directory**

Run:

```powershell
New-Item -ItemType Directory -Force -Path 'examples'
```

- [ ] **Step 2: Add namespaced example**

Create `examples/sequence_to_multipage.m`:

```matlab
% Convert a folder of TIFF images to one multipage TIFF file.

folderPath = 'test';
outputPath = '';
outputName = 'tt';
bitsPerSample = 8;
imageDescription = '';

stack = tif.load(folderPath);
tif.save(fullfile(outputPath, outputName), stack, bitsPerSample, imageDescription);
```

- [ ] **Step 3: Delete old misspelled script**

```powershell
Remove-Item -LiteralPath 'script_sequnece_to_multipage.m'
```

- [ ] **Step 4: Commit example move**

```powershell
git add examples script_sequnece_to_multipage.m
git commit -m "docs: move conversion script to examples"
```

### Task 5: Final Verification And Report

**Files:**
- Modify: `context/logs/20260705-structure-alignment.md`
- Create: `context/reports/20260705-structure-alignment.md`

- [ ] **Step 1: Run MATLAB tests**

Run:

```powershell
matlab -batch "results = runtests('tests'); assertSuccess(results);"
```

Expected: PASS.

- [ ] **Step 2: Run project readiness check**

Run:

```powershell
$env:PYTHONPATH='D:\code\all-you-need-is-trust\tools\src'; python -m aynit.cli check-project . --format text
```

Expected: no `[fail]` findings.

- [ ] **Step 3: Add report**

Create `context/reports/20260705-structure-alignment.md` with status `passed` if both oracles pass, or `blocked` with the failing command and output summary if either oracle cannot pass.

- [ ] **Step 4: Commit final report**

```powershell
git add context/logs context/reports
git commit -m "docs: report structure alignment result"
```

- [ ] **Step 5: Summarize branch status**

Report:

- Current branch.
- Commits made.
- Verification commands and outcomes.
- Any residual risks.
