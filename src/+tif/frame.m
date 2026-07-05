function n = frame(tifFile, seekInterval)
% FRAME Count frames in a TIFF file.
%
% This function reports number of frames in a tiff file.
%
%  USAGE
%   n = tif.frame(tiff, seekInterval)
%   tiff            Path to tiff file or a tiff object.
%   seekInterval    Optional number of frames to jump over.
%                   Kept for compatibility; currently unused.
%   n               Number of frames

if isa(tifFile, 'Tiff')
    info = imfinfo(tifFile.FileName);
else
    info = imfinfo(tifFile);
end
n = numel(info);

% NOTICE: the following code in window 11 and MATLAB 2023b may return wrong number


% warning('off', 'imageio:tiffmexutils:libtiffWarning')
% warning('off', 'imageio:tiffutils:libtiffWarning')
%
%     if nargin < 2
%         seekInterval = 1000;
%     end
%     % keep guessing until we seek too far
%     guess = seekInterval;
%     overSeeked = false;
%
%     if ischar(tifFile) || isstring(tifFile)
%         tifFile = Tiff(tifFile, 'r');
%         closeTiff = onCleanup(@() close(tifFile));
%     end
%
%     while ~overSeeked
%       try
%         tifFile.setDirectory(guess);
%         guess = 2*guess; %double the guess
%       catch ex
%         overSeeked = true; %we tried to seek past the last directory
%       end
%     end
%     %when overseeking occurs, the current directory/frame will be the last one
%     n = tifFile.currentDirectory;
%
%     if n == 0
%         n = 1;
%     end
%
% warning('on', 'imageio:tiffmexutils:libtiffWarning')
% warning('on', 'imageio:tiffutils:libtiffWarning')
end
