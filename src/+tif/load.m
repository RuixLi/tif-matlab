function [stack, tfTag] = load(tiffFile, index, stride)
% LOAD Load a TIFF file or TIFF image sequence as a Y-by-X-by-T stack.
arguments
    tiffFile {mustBeTiffSource}
    index (1,:) double {mustBeInteger} = []
    stride (1,1) double {mustBeInteger, mustBePositive} = 1
end

[warnState1, warnState2] = disableTiffWarnings();
cleanupWarnings = onCleanup(@() restoreWarnings(warnState1, warnState2));

[sourceKind, sourceValue] = resolveSource(tiffFile);
if strcmp(sourceKind, 'folder')
    [stack, tfTag] = loadFolder(sourceValue, index, stride, nargout > 1);
else
    [stack, tfTag] = loadFile(sourceValue, index, stride, nargout > 1, ~isa(sourceValue, 'Tiff'));
end
end

function [stack, tfTag] = loadFile(sourceValue, index, stride, loadTag, closeWhenDone)
if isa(sourceValue, 'Tiff')
    t = sourceValue;
else
    t = Tiff(sourceValue, 'r');
end

if closeWhenDone
    cleanupTiff = onCleanup(@() close(t));
end

nFrame = tif.frame(t);
loadIdx = normalizeFrameIndex(index, stride, nFrame);

setDirectory(t, loadIdx(1));
sample = read(t);
validateImagePlane(sample, 'tif:load:UnsupportedImageShape');
stack = zeros([size(sample, 1), size(sample, 2), numel(loadIdx)], class(sample));
tfTag = initTags(numel(loadIdx));

for n = 1:numel(loadIdx)
    setDirectory(t, loadIdx(n));
    frame = read(t);
    validateMatchingFrame(frame, sample);
    stack(:, :, n) = frame;
    if loadTag
        tfTag(n) = readTag(t, currentDirectory(t));
    end
end
end

function [stack, tfTag] = loadFolder(folderPath, index, stride, loadTag)
files = listTiffFiles(folderPath);
nFrame = numel(files);
loadIdx = normalizeFrameIndex(index, stride, nFrame);

[sample, sampleTag] = readSingleFile(files{loadIdx(1)}, files{loadIdx(1)});
stack = zeros([size(sample, 1), size(sample, 2), numel(loadIdx)], class(sample));
tfTag = initTags(numel(loadIdx));

for n = 1:numel(loadIdx)
    filePath = files{loadIdx(n)};
    [frame, tag] = readSingleFile(filePath, filePath);
    validateMatchingFrame(frame, sample);
    stack(:, :, n) = frame;
    if loadTag
        tfTag(n) = tag;
    end
end

if loadTag
    tfTag(1) = sampleTag;
end
end

function [frame, tag] = readSingleFile(filePath, frameLabel)
t = Tiff(filePath, 'r');
cleanupTiff = onCleanup(@() close(t));
frame = read(t);
validateImagePlane(frame, 'tif:load:UnsupportedImageShape');
tag = readTag(t, frameLabel);
end

function [sourceKind, sourceValue] = resolveSource(tiffFile)
if isa(tiffFile, 'Tiff')
    sourceKind = 'file';
    sourceValue = tiffFile;
    return
end

pathValue = textToChar(tiffFile);
if isfolder(pathValue)
    sourceKind = 'folder';
    sourceValue = pathValue;
elseif isfile(pathValue)
    sourceKind = 'file';
    sourceValue = pathValue;
else
    error('tif:load:FileNotFound', 'TIFF source does not exist: %s', pathValue);
end
end

function files = listTiffFiles(folderPath)
listing = dir(folderPath);
isFile = ~[listing.isdir];
names = {listing(isFile).name};
isTiff = ~cellfun(@isempty, regexpi(names, '\.(tif|tiff)$', 'once'));
names = names(isTiff);
if isempty(names)
    error('tif:load:NoTiffFiles', 'Folder contains no .tif or .tiff files: %s', folderPath);
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

function loadIdx = normalizeFrameIndex(index, stride, nFrame)
if isempty(index)
    frameRange = [1 nFrame];
elseif numel(index) == 1
    frameRange = [index nFrame];
elseif numel(index) == 2
    frameRange = index;
else
    error('tif:load:InvalidFrameRange', 'Frame index must be empty, scalar, or [start end].');
end

if frameRange(2) == -1
    frameRange(2) = nFrame;
end

if any(frameRange < 1) || frameRange(1) > frameRange(2)
    error('tif:load:InvalidFrameRange', 'Invalid frame range [%d %d].', frameRange(1), frameRange(2));
end

loadIdx = frameRange(1):stride:frameRange(2);
if isempty(loadIdx) || any(loadIdx > nFrame)
    error('tif:load:FrameIndexOutOfRange', 'Requested frame range exceeds %d frames.', nFrame);
end
end

function validateMatchingFrame(frame, sample)
validateImagePlane(frame, 'tif:load:UnsupportedImageShape');
if ~isequal(size(frame), size(sample)) || ~strcmp(class(frame), class(sample))
    error('tif:load:InconsistentImageSize', 'All loaded TIFF frames must share size and class.');
end
end

function validateImagePlane(frame, errorId)
if ndims(frame) ~= 2
    error(errorId, 'Only single-channel two-dimensional TIFF frames are supported.');
end
end

function tags = initTags(nFrame)
tags = repmat(struct( ...
    'frameN', [], ...
    'ImageWidth', [], ...
    'ImageLength', [], ...
    'BitsPerSample', [], ...
    'Compression', [], ...
    'ImageDescription', 'Null'), 1, nFrame);
end

function tag = readTag(t, frameLabel)
tag = struct();
tag.frameN = frameLabel;
tag.ImageWidth = readOptionalTag(t, 256, []);
tag.ImageLength = readOptionalTag(t, 257, []);
tag.BitsPerSample = readOptionalTag(t, 258, []);
tag.Compression = readOptionalTag(t, 259, []);
tag.ImageDescription = readOptionalTag(t, 270, 'Null');
end

function value = readOptionalTag(t, tagId, defaultValue)
try
    value = getTag(t, tagId);
catch
    value = defaultValue;
end
end

function [state1, state2] = disableTiffWarnings()
state1 = warning('off', 'imageio:tiffmexutils:libtiffWarning');
state2 = warning('off', 'imageio:tiffutils:libtiffWarning');
end

function restoreWarnings(state1, state2)
warning(state1);
warning(state2);
end

function mustBeTiffSource(value)
if isa(value, 'Tiff') || isTextScalar(value)
    return
end
error('tif:load:InvalidSource', 'Source must be a Tiff object, char path, or scalar string path.');
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
