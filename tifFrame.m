function n = tifFrame(tifFile, seekInterval)
% Find the number of frames in a tiff file
%
% This function reports number of frames in a tiff file by
% jumping over seekInterval frames until the end of the file.
% This is in general faster than Matlab's imfinfo function.
%
%  USAGE
%   n = tifFrame(tiff, seekInterval)
%   tiff            Path to tiff file or a tiff object.
%   seekInterval    Optional number of frames to jump over.
%                   Default is 1000.
%   n               Number of frames

x = imfinfo(tifFile.FileName);
n = length(x);

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

