# tif-matlab

`tif-matlab` is a small MATLAB package for reading and writing microscopy TIFF image stacks.

## Features

- Load a multipage TIFF file or a folder of TIFF images as a `Y-by-X-by-T` stack.
- Save a `Y-by-X-by-T` stack as a multipage TIFF file.
- Write a single grayscale or RGB TIFF image.
- Count frames in a TIFF file.

## Setup

Add the package source folder to the MATLAB path:

```matlab
addpath('src')
```

## Quick Start

```matlab
stack = uint16(reshape(1:24, [3 4 2]));

tif.save('example.tif', stack);
loaded = tif.load('example.tif');

assert(isequal(loaded, stack))
```

## API

```matlab
stack = tif.load(path);
[stack, tags] = tif.load(path, index, stride);

tif.save(path, stack);
tif.save(path, stack, bitsPerSample, imageDescription);

tif.write(path, image);

n = tif.frame(path);
```

The full public surface is listed in [src/+tif/Contents.m](src/+tif/Contents.m).

## Tests

From the repository root:

```powershell
matlab -batch "results = runtests('tests'); assertSuccess(results);"
```

## Agentic Development

Agents should start at [AGENTS.md](AGENTS.md). Current work and conventions live under [context/](context/).

## License

MIT - see [LICENSE](LICENSE).
