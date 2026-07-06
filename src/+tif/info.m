function metadata = info(tiffSource)
% INFO Inspect TIFF file or image-sequence metadata without loading pixels.
arguments
    tiffSource {mustBeTextScalar}
end

[sourceType, sourcePath] = resolveSource(textToChar(tiffSource));
if strcmp(sourceType, 'folder')
    metadata = folderInfo(sourcePath);
else
    metadata = fileInfo(sourcePath);
end
end

function metadata = fileInfo(filePath)
frames = imfinfo(filePath);
metadata = buildMetadata('file', filePath, {filePath}, frames(1), numel(frames), numel(frames), isBigTiffFile(filePath));
end

function metadata = folderInfo(folderPath)
files = listTiffFiles(folderPath);
firstInfo = imfinfo(files{1});
firstFrame = firstInfo(1);
pagesPerFile = zeros(1, numel(files));
isBigTiff = false(1, numel(files));

for i = 1:numel(files)
    frames = imfinfo(files{i});
    pagesPerFile(i) = numel(frames);
    isBigTiff(i) = isBigTiffFile(files{i});
    validateMatchingMetadata(frames(1), firstFrame);
end

metadata = buildMetadata('folder', folderPath, files, firstFrame, numel(files), pagesPerFile, any(isBigTiff));
end

function metadata = buildMetadata(sourceType, sourcePath, files, firstFrame, frameCount, pagesPerFile, isBigTiff)
imageLength = firstFrame.Height;
imageWidth = firstFrame.Width;
bitsPerSample = metadataField(firstFrame, 'BitsPerSample', metadataField(firstFrame, 'BitDepth', []));
samplesPerPixel = metadataField(firstFrame, 'SamplesPerPixel', 1);

metadata = struct();
metadata.SourceType = sourceType;
metadata.Path = sourcePath;
metadata.Files = files;
metadata.FrameCount = frameCount;
metadata.PagesPerFile = pagesPerFile;
metadata.ImageSize = [imageLength imageWidth];
metadata.ImageLength = imageLength;
metadata.ImageWidth = imageWidth;
metadata.BitsPerSample = bitsPerSample;
metadata.SamplesPerPixel = samplesPerPixel;
metadata.Class = classFromBits(bitsPerSample);
metadata.Compression = metadataField(firstFrame, 'Compression', '');
metadata.ImageDescription = metadataField(firstFrame, 'ImageDescription', '');
metadata.EstimatedStackBytes = estimateStackBytes(imageLength, imageWidth, frameCount, bitsPerSample, samplesPerPixel);
metadata.IsBigTiff = isBigTiff;
end

function [sourceType, sourcePath] = resolveSource(pathValue)
if isfolder(pathValue)
    sourceType = 'folder';
    sourcePath = pathValue;
elseif isfile(pathValue)
    sourceType = 'file';
    sourcePath = pathValue;
else
    error('tif:info:FileNotFound', 'TIFF source does not exist: %s', pathValue);
end
end

function files = listTiffFiles(folderPath)
listing = dir(folderPath);
isFile = ~[listing.isdir];
names = {listing(isFile).name};
isTiff = ~cellfun(@isempty, regexpi(names, '\.(tif|tiff)$', 'once'));
names = names(isTiff);
if isempty(names)
    error('tif:info:NoTiffFiles', 'Folder contains no .tif or .tiff files: %s', folderPath);
end

names = naturalSort(names);
files = cellfun(@(name) fullfile(folderPath, name), names, 'UniformOutput', false);
end

function names = naturalSort(names)
keys = cellfun(@naturalKey, names, 'UniformOutput', false);
[~, order] = sort(keys);
names = names(order);
end

function key = naturalKey(name)
tokens = regexp(name, '\d+|\D+', 'match');
parts = cell(size(tokens));
for i = 1:numel(tokens)
    token = tokens{i};
    if all(isstrprop(token, 'digit'))
        parts{i} = sprintf('%020.0f', str2double(token));
    else
        parts{i} = lower(token);
    end
end
key = strjoin(parts, char(0));
end

function validateMatchingMetadata(frame, firstFrame)
if frame.Height ~= firstFrame.Height || frame.Width ~= firstFrame.Width
    error('tif:info:InconsistentImageSize', 'All TIFF frames must share size metadata.');
end

if ~isequal(metadataField(frame, 'BitsPerSample', []), metadataField(firstFrame, 'BitsPerSample', [])) || ...
        ~isequal(metadataField(frame, 'SamplesPerPixel', 1), metadataField(firstFrame, 'SamplesPerPixel', 1))
    error('tif:info:InconsistentImageClass', 'All TIFF frames must share bit-depth and sample metadata.');
end
end

function value = metadataField(metadata, fieldName, defaultValue)
if isfield(metadata, fieldName)
    value = metadata.(fieldName);
else
    value = defaultValue;
end
end

function className = classFromBits(bitsPerSample)
if isempty(bitsPerSample)
    className = 'unknown';
    return
end

bits = bitsPerSample(1);
if bits == 8
    className = 'uint8';
elseif bits == 16
    className = 'uint16';
else
    className = sprintf('uint%d', bits);
end
end

function bytes = estimateStackBytes(imageLength, imageWidth, frameCount, bitsPerSample, samplesPerPixel)
if isempty(bitsPerSample)
    bytes = NaN;
    return
end

bits = double(bitsPerSample(1));
bytesPerSample = bits / 8;
bytes = double(imageLength) * double(imageWidth) * double(frameCount) * double(samplesPerPixel) * bytesPerSample;
end

function tf = isBigTiffFile(filePath)
fid = fopen(filePath, 'r');
if fid < 0
    tf = false;
    return
end
cleanupFile = onCleanup(@() fclose(fid));
header = fread(fid, 4, 'uint8=>uint8')';
if numel(header) < 4
    tf = false;
    return
end

if header(1) == uint8('I') && header(2) == uint8('I')
    magic = double(header(3)) + 256 * double(header(4));
elseif header(1) == uint8('M') && header(2) == uint8('M')
    magic = 256 * double(header(3)) + double(header(4));
else
    magic = NaN;
end
tf = magic == 43;
end

function mustBeTextScalar(value)
if isTextScalar(value)
    return
end
error('tif:info:InvalidSource', 'Source must be char or scalar string path.');
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
