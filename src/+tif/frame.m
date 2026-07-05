function n = frame(tifFile, seekInterval)
% FRAME Count frames in a TIFF file.
arguments
    tifFile {mustBeFrameSource}
    seekInterval (1,1) double {mustBeInteger, mustBePositive} = 1000 %#ok<INUSA>
end

if isa(tifFile, 'Tiff')
    pathValue = tifFile.FileName;
else
    pathValue = textToChar(tifFile);
    if ~isfile(pathValue)
        error('tif:frame:FileNotFound', 'TIFF file does not exist: %s', pathValue);
    end
end

info = imfinfo(pathValue);
n = numel(info);
end

function mustBeFrameSource(value)
if isa(value, 'Tiff') || isTextScalar(value)
    return
end
error('tif:frame:InvalidSource', 'Source must be a Tiff object, char path, or scalar string path.');
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
