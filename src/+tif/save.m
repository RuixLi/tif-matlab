function save(fname, stack, bitspersamp, imageDescription, options)
% SAVE Save a Y-by-X-by-T stack as a multipage TIFF file.
%
% Syntax
%   tif.save(path, stack)
%   tif.save(path, stack, bitsPerSample)
%   tif.save(path, stack, bitsPerSample, imageDescription)
%   tif.save(___, 'BigTiff', tf)
%   tif.save(___, 'BigTiffThresholdBytes', bytes)
%
% Inputs
%   path - Output path as a char vector or scalar string. If no extension is
%     supplied, .tif is appended. Existing extensions must be .tif or .tiff.
%   stack - 2-D image or Y-by-X-by-T stack. Accepted classes are uint8 and
%     uint16. The stack is written without rescaling.
%   bitsPerSample - Optional bit depth, either 8 or 16. The default is 16.
%     Use 8 only with uint8 stacks and 16 only with uint16 stacks.
%   imageDescription - Optional char vector or scalar string written to the
%     TIFF ImageDescription tag.
%   BigTiff - Optional logical. true forces BigTIFF write mode.
%   BigTiffThresholdBytes - Optional positive finite threshold for automatic
%     BigTIFF upgrade. When the estimated output exceeds this value, tif.save
%     writes BigTIFF and prints a notice. The default is near 4 GiB.
%
% Outputs
%   None.
%
% Examples
%   tif.save("movie.tif", uint16Stack);
%   tif.save("movie.tif", uint8Stack, 8, "8-bit movie");
%   tif.save("large.tif", uint16Stack, 16, "", "BigTiff", true);
arguments
    fname {mustBeTextScalar}
    stack {mustBeNumeric, mustBeNonempty}
    bitspersamp (1,1) double {mustBeMember(bitspersamp, [8 16])} = 16
    imageDescription {mustBeTextScalar} = ""
    options.BigTiff (1,1) logical = false
    options.BigTiffThresholdBytes (1,1) double {mustBePositive, mustBeFinite} = 4293918720
end

validateStack(stack);
validateBitDepthClass(stack, bitspersamp);

fname = ensureTiffExtension(textToChar(fname));
ensureParentFolderExists(fname);
[tiffMode, autoBigTiff, estimatedBytes] = chooseTiffMode(stack, bitspersamp, options.BigTiff, options.BigTiffThresholdBytes);
if autoBigTiff
    fprintf('tif.save: estimated output %.0f bytes exceeds classic TIFF limit; using BigTIFF.\n', estimatedBytes);
end

t = Tiff(fname, tiffMode);
cleanupTiff = onCleanup(@() close(t));

tagstruct.ImageLength = size(stack, 1);
tagstruct.ImageWidth = size(stack, 2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = bitspersamp;
tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
tagstruct.SamplesPerPixel = 1;
tagstruct.RowsPerStrip = 256;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software = ['MATLAB ' version];

if strlength(string(imageDescription)) > 0
    tagstruct.ImageDescription = char(imageDescription);
end

t.setTag(tagstruct);
t.write(stack(:, :, 1));
for i = 2:size(stack, 3)
    t.writeDirectory();
    t.setTag(tagstruct);
    t.write(stack(:, :, i));
end
end

function [tiffMode, autoBigTiff, estimatedBytes] = chooseTiffMode(stack, bitspersamp, bigTiffRequested, bigTiffThresholdBytes)
estimatedBytes = estimateOutputBytes(stack, bitspersamp);
if bigTiffRequested
    tiffMode = 'w8';
    autoBigTiff = false;
elseif estimatedBytes > bigTiffThresholdBytes
    tiffMode = 'w8';
    autoBigTiff = true;
else
    tiffMode = 'w';
    autoBigTiff = false;
end
end

function bytes = estimateOutputBytes(stack, bitspersamp)
bytesPerSample = bitspersamp / 8;
frameCount = size(stack, 3);
directoryOverheadBytes = 4096;
bytes = double(numel(stack)) * bytesPerSample + double(frameCount) * directoryOverheadBytes;
end

function validateStack(stack)
if ndims(stack) > 3
    error('tif:save:InvalidStackShape', 'Stack must be a 2-D image or a Y-by-X-by-T array.');
end
if ~(isa(stack, 'uint8') || isa(stack, 'uint16'))
    error('tif:save:UnsupportedClass', 'Stack must be uint8 or uint16.');
end
end

function validateBitDepthClass(stack, bitspersamp)
if bitspersamp == 8 && ~isa(stack, 'uint8')
    error('tif:save:BitDepthClassMismatch', 'BitsPerSample 8 requires a uint8 stack.');
end
if bitspersamp == 16 && ~isa(stack, 'uint16')
    error('tif:save:BitDepthClassMismatch', 'BitsPerSample 16 requires a uint16 stack.');
end
end

function fname = ensureTiffExtension(fname)
[pathstr, name, ext] = fileparts(fname);
if isempty(ext)
    fname = fullfile(pathstr, [name '.tif']);
elseif ~ismember(lower(ext), {'.tif', '.tiff'})
    error('tif:save:UnsupportedExtension', 'Output file must use .tif or .tiff extension.');
end
end

function ensureParentFolderExists(fname)
parentFolder = fileparts(fname);
if ~isempty(parentFolder) && ~isfolder(parentFolder)
    error('tif:save:FolderNotFound', 'Output folder does not exist: %s', parentFolder);
end
end

function mustBeTextScalar(value)
if isTextScalar(value)
    return
end
error('tif:save:InvalidPath', 'Path must be char or scalar string.');
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
