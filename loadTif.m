function [stack,TFtag] = loadTif(tiffFile,index,stride)
% load imaging tiff file as a XYT array

% INPUT
% tiffFile, a tiff object or a file directory
% -tiffFile can be a multi-page file or a folder of single images
% if not defined, gui select
% index, [start, end] if end = -1, load all frames
% stride, a scale number

% OUTPUT
% stack, the [Y,X,T] data array in tiff
% TFtag, a struct contains some useful fields in tag struct

% DOCUMENTATION
% for each frame in tiff, the TFtag has following fields

% TFtag.FrameN
% TFtag.ImageLength
% TFtag.ImageWidth
% TFtag.BitsPerSample
% TFtag.Compression
% TFtag.ImageDescription

% written by Ruix.Li in Sep, 2020

%% check tifFile

warning('off', 'imageio:tiffmexutils:libtiffWarning')
warning('off', 'imageio:tiffutils:libtiffWarning')

if nargin == 0; tiffFile = getfile('tif*'); end

% case 1: tifFile is a tiff object
if strcmpi(class(tiffFile),'Tiff')
  t = tiffFile;
  dirFlg = 0;
end

if ischar(tiffFile)
    if ~isfolder(tiffFile) % case 2: tifFile is the dir of a tiff file
      t = Tiff(tiffFile, 'r');
      dirFlg = 0;
    else % case 3: tifFile is a folder
        list = dir(tiffFile);
        tifNames = {list.name};
        rMatchNs = regexpi(tifNames, ['\.(', 'tif*', ')$']);
        tifNames = tifNames(~cellfun(@isempty, rMatchNs));
        nFrame = length(tifNames);
        dirFlg = 1;
    end
end

%% read File
if nargin < 2 || isempty(index)
    if dirFlg
        index = [1 nFrame];
    else
        nFrame = tifFrame(t);
        index = [1 nFrame];
    end
end

if nargin < 3     
    if length(index) == 1
        if dirFlg
            index = [index nFrame];
            
        else
            nFrame = tifFrame(t);
            index = [index nFrame];
            disp(index)
        end        
    end
    stride = 1;
end


if nargout > 1
    loadTag = 1;
else
    loadTag = 0;
end

if dirFlg == 0
    loadIdx = index(1):stride:index(2);
    w = t.getTag('ImageWidth');
    h = t.getTag('ImageLength');
    LoadFrames = length(loadIdx);
    stack = zeros(h, w, LoadFrames, class(read(t)));
    
    if loadTag
        [TFtag(1:LoadFrames).frameN] = deal(currentDirectory(t));
        [TFtag(1:LoadFrames).ImageWidth] = deal(getTag(t,256));
        [TFtag(1:LoadFrames).ImageLength] = deal(getTag(t,257));
        [TFtag(1:LoadFrames).BitsPerSample] = deal(getTag(t,258));
        [TFtag(1:LoadFrames).Compression] = deal(getTag(t,259));
        try [TFtag(1:LoadFrames).ImageDescription] = deal(getTag(t,270));
        catch ; [TFtag(1:LoadFrames).ImageDescription] = deal('Null'); end
    end
    warning('off', 'imageio:tiffutils:libtiffWarning')
    for n = 1:LoadFrames
        setDirectory(t, loadIdx(n));
        % im = read(t);
        % stack(:,:,n) = im(:,:,1);
        stack(:,:,n) = read(t);
        if loadTag
            TFtag(n).frameN = currentDirectory(t);
            TFtag(n).ImageWidth = getTag(t,256);
            TFtag(n).ImageLength = getTag(t,257);
            TFtag(n).BitsPerSample = getTag(t,258);
            TFtag(n).Compression = getTag(t,259);
            try [TFtag(1:LoadFrames).ImageDescription] = deal(getTag(t,270));
            catch ; [TFtag(1:LoadFrames).ImageDescription] = deal('Null'); end
        end           
    end
    
else % load from multiple files in the folder
    
    disp(['loading tiffs from ' tifNames{index(1)} ' to ' tifNames{index(2)}])
    ToLoadIdx = index(1):stride:index(2);
    LoadFrames = length(ToLoadIdx);
    t = Tiff([tiffFile filesep tifNames{index(1)}]);
    w = t.getTag('ImageWidth');
    h = t.getTag('ImageLength');
    
    if loadTag
        [TFtag(1:LoadFrames).frameN] = deal(ToLoadIdx(1));
        [TFtag(1:LoadFrames).ImageWidth] = deal(getTag(t,256));
        [TFtag(1:LoadFrames).ImageLength] = deal(getTag(t,257));
        [TFtag(1:LoadFrames).BitsPerSample] = deal(getTag(t,258));
        [TFtag(1:LoadFrames).Compression] = deal(getTag(t,259));
        try [TFtag(1:LoadFrames).ImageDescription] = deal(getTag(t,270));
        catch ; [TFtag(1:LoadFrames).ImageDescription] = deal('Null'); end
    end
    
    stack = zeros(h, w, LoadFrames, class(read(t)));

    for n = 1:LoadFrames
        t = Tiff([tiffFile filesep tifNames{ToLoadIdx(n)}]);
        stack(:,:,n) = read(t);
        if loadTag
            TFtag(n).frameN = tifNames{ToLoadIdx(n)};
            TFtag(n).ImageWidth = getTag(t,256);
            TFtag(n).ImageLength = getTag(t,257);
            TFtag(n).BitsPerSample = getTag(t,258);
            TFtag(n).Compression = getTag(t,259);
            try [TFtag(1:LoadFrames).ImageDescription] = deal(getTag(t,270));
            catch ; [TFtag(1:LoadFrames).ImageDescription] = deal('Null'); end
        end
    end
end

warning('on', 'imageio:tiffmexutils:libtiffWarning')
warning('on', 'imageio:tiffutils:libtiffWarning')
end
