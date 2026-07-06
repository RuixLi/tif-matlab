function n = frame(tifFile, seekInterval)
% FRAME Count frames in a TIFF file.
%
% Syntax
%   n = tif.frame(source)
%   n = tif.frame(source, seekInterval)
%
% Inputs
%   source - TIFF file source. Use a char vector or scalar string path to a
%     .tif/.tiff file, or an open Tiff object.
%   seekInterval - Optional positive integer retained for older call sites.
%     The current implementation counts frames with imfinfo.
%
% Outputs
%   n - Number of image directories/pages in the TIFF file.
%
% Examples
%   n = tif.frame("movie.tif");
%   stack = tif.load("movie.tif", [1 min(n, 100)]);
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
