# Environment

## Toolchain

- MATLAB R2019b or newer - runs package-folder code and MATLAB Unit Test.
- Python 3.11 or compatible - runs the optional `aynit` project checks from the local all-you-need-is-trust checkout.
- Git - tracks branch work and release history.

## Dependencies

- MATLAB Image Processing Toolbox - required for `Tiff`, `imwrite`, `imfinfo`, and `rescale`.
- all-you-need-is-trust tools - used from `D:\code\all-you-need-is-trust\tools\src` for project conformance checks.

## Setup

1. Open MATLAB at the repository root.
2. Add the package source folder:

   ```matlab
   addpath('src')
   ```

3. Run tests:

   ```matlab
   results = runtests('tests');
   assertSuccess(results);
   ```

## Project Checks

From PowerShell at the repository root:

```powershell
$env:PYTHONPATH='D:\code\all-you-need-is-trust\tools\src'; python -m aynit.cli check-project . --format text
```

## Notes

- Generated TIFF files are local artifacts and ignored by git.
- Keep large microscopy data outside git; add provenance sidecars for load-bearing artifacts when future work produces them.
