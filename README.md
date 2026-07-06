# tif-matlab

`tif-matlab` is a small MATLAB package for reading and writing microscopy TIFF image stacks.

## Features

- Load a multipage TIFF file or a folder of TIFF images as a `Y-by-X-by-T` stack.
- Inspect TIFF metadata without loading pixel data.
- Save a `uint8` or `uint16` `Y-by-X-by-T` stack as a multipage TIFF file.
- Save large stacks as BigTIFF when requested or when the estimated output size requires it.
- Write a single `uint8` grayscale or RGB TIFF image.
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

metadata = tif.info(path);

tif.save(path, stack);
tif.save(path, stack, bitsPerSample, imageDescription);
tif.save(path, stack, bitsPerSample, imageDescription, 'BigTiff', true);

tif.write(path, image);

n = tif.frame(path);
```

Paths may be `char` vectors or scalar `string` values. Folder loads include `.tif` and `.tiff` files in deterministic natural order, so `frame2.tif` comes before `frame10.tif`.

Frame ranges use `[start end]`; set `end` to `-1` to load through the last frame. For example:

```matlab
stack = tif.load('movie.tif', [2 -1], 2);  % frames 2, 4, 6, ... through the end
```

Use `tif.info(path)` to inspect metadata before allocating a stack. It reports source type, loadable frame count, image size, bit depth/class, selected TIFF tags, estimated stack bytes, and whether the file header is BigTIFF.

`tif.save` is strict about bit depth: `BitsPerSample=8` requires `uint8`, and `BitsPerSample=16` requires `uint16`. `tif.write` requires `uint8`. Scale or cast data explicitly before calling these functions.

`tif.save` writes classic TIFF by default. Set `'BigTiff', true` to force BigTIFF. If BigTIFF is not requested but the estimated output size exceeds the classic TIFF threshold, `tif.save` automatically writes BigTIFF and prints a stdout notice.

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
