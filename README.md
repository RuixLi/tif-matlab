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

### `tif.load`

```matlab
stack = tif.load(path);
[stack, tags] = tif.load(path);
stack = tif.load(path, index);
[stack, tags] = tif.load(path, index, stride);
```

`path` may be a `.tif`/`.tiff` file, a folder of `.tif`/`.tiff` files, or an open `Tiff` object. File and folder paths may be `char` vectors or scalar `string` values. Folder loads use deterministic natural order, so `frame2.tif` comes before `frame10.tif`.

`index` controls the loaded frames:

- Omit `index` or pass `[]` to load all frames.
- Pass scalar `N` to load frames `N` through the last frame.
- Pass `[start end]` to load an inclusive range.
- Use `-1` as `end` to mean the last frame.

`stride` is a positive integer frame step. The default is `1`.

```matlab
stack = tif.load('movie.tif', [2 -1], 2);  % frames 2, 4, 6, ... through the end
```

The output stack is `Y-by-X-by-T`. Optional `tags` contains `frameN`, `ImageWidth`, `ImageLength`, `BitsPerSample`, `Compression`, and `ImageDescription`.

### `tif.info`

```matlab
metadata = tif.info(path);
```

`path` may be a `.tif`/`.tiff` file or a folder of `.tif`/`.tiff` files. `tif.info` does not load pixel data. It reports source type, files, loadable frame count, pages per file, image size, bit depth/class, compression, image description, estimated stack bytes, and BigTIFF header status.

### `tif.save`

```matlab
tif.save(path, stack)
tif.save(path, stack, bitsPerSample)
tif.save(path, stack, bitsPerSample, imageDescription)
tif.save(___, 'BigTiff', true)
tif.save(___, 'BigTiffThresholdBytes', bytes)
```

`path` may be a `char` vector or scalar `string`. If no extension is supplied, `.tif` is appended. Existing extensions must be `.tif` or `.tiff`.

`stack` must be a 2-D image or `Y-by-X-by-T` stack with class `uint8` or `uint16`. `bitsPerSample` accepts only `8` or `16`, and it must match the stack class: `8` for `uint8`, `16` for `uint16`. Data is written without rescaling.

`'BigTiff', true` forces BigTIFF output. Otherwise, `tif.save` writes classic TIFF unless the estimated output size exceeds the BigTIFF threshold; in that case it writes BigTIFF and prints a stdout notice.

### `tif.write`

```matlab
tif.write(path, image)
```

Writes one `uint8` image. Accepted shapes are `Y-by-X` grayscale or `Y-by-X-by-3` RGB. Data is written without rescaling.

### `tif.frame`

```matlab
n = tif.frame(path);
```

Returns the number of image directories/pages in a TIFF file. `path` may also be an open `Tiff` object.

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
