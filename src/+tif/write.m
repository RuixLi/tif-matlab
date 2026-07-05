function write(fname, im)
% WRITE Write a single uint8 grayscale or RGB image to a TIFF file.
arguments
    fname {mustBeTextScalar}
    im {mustBeNonempty}
end

if ~isa(im, 'uint8')
    error('tif:write:ImageClass', 'Image must be uint8; use explicit scaling before calling tif.write.');
end

if ~(ismatrix(im) || (ndims(im) == 3 && size(im, 3) == 3))
    error('tif:write:ImageShape', 'Image must be a 2-D grayscale image or an RGB image.');
end

fname = ensureTiffExtension(textToChar(fname));
ensureParentFolderExists(fname);
imwrite(im, fname)
end

function fname = ensureTiffExtension(fname)
[pathstr, name, ext] = fileparts(fname);
if isempty(ext)
    fname = fullfile(pathstr, [name '.tif']);
elseif ~ismember(lower(ext), {'.tif', '.tiff'})
    error('tif:write:UnsupportedExtension', 'Output file must use .tif or .tiff extension.');
end
end

function ensureParentFolderExists(fname)
parentFolder = fileparts(fname);
if ~isempty(parentFolder) && ~isfolder(parentFolder)
    error('tif:write:FolderNotFound', 'Output folder does not exist: %s', parentFolder);
end
end

function mustBeTextScalar(value)
if isTextScalar(value)
    return
end
error('tif:write:InvalidPath', 'Path must be char or scalar string.');
end

function tf = isTextScalar(value)
tf = (ischar(value) && (isrow(value) || isempty(value))) || (isstring(value) && isscalar(value));
end

function pathValue = textToChar(value)
if isstring(value)
    pathValue = char(value);
else
    pathValue = value;
end
end
