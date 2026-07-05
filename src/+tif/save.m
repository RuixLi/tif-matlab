function save(fname, stack, bitspersamp, imageDescription)
% SAVE Save a Y-by-X-by-T stack as a multipage TIFF file.
arguments
    fname {mustBeTextScalar}
    stack {mustBeNumeric, mustBeNonempty}
    bitspersamp (1,1) double {mustBeMember(bitspersamp, [8 16])} = 16
    imageDescription {mustBeTextScalar} = ""
end

validateStack(stack);
validateBitDepthClass(stack, bitspersamp);

fname = ensureTiffExtension(textToChar(fname));
ensureParentFolderExists(fname);

t = Tiff(fname, 'w');
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
