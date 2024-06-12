function saveTif(fname,stack,bitspersamp,ImageDescription)
% saveTiff save XYT numeric array as a muti-page tif file

% INPUT
% stack, a numeric stack of uint8 or uint16
% if stack is float, cast it as uint8/uint16
% fname, filename of the tiff
% bitspersamp, 8 or 16(default) for uint8 or uint16
% ImageDescription, a string vector

% wirtten by Ruix.Li in Oct, 2020

if ~exist('bitspersamp','var'); bitspersamp = 16; end

if exist('ImageDescription','var')
    writeImDesc = 1; 
else
    writeImDesc = 0; 
end

[pathstr, name, ~] = fileparts(fname);
fname = fullfile(pathstr,[name,'.tif']); % ensure file has an .tiff extension

t = Tiff(fname,'w');

tagstruct.ImageLength = size(stack,1);
tagstruct.ImageWidth = size(stack,2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;

if bitspersamp == 8
    tagstruct.BitsPerSample = 8;
    if ~strcmpi(class(stack),'uint8')
        warning('cast data into uint8')
        stack =rescale(stack,0,255);
        stack = cast(stack,'uint8');
    end
end

if bitspersamp == 16
    tagstruct.BitsPerSample = 16;
    if ~strcmpi(class(stack),'uint16')
        warning('cast data into uint16')
        stack =rescale(stack,0,65535);
        stack = cast(stack,'uint16');
    end
end

tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
tagstruct.SamplesPerPixel = 1;
tagstruct.RowsPerStrip = 256;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software = ['MATLAB ' version];

if writeImDesc
    tagstruct.ImageDescription = ImageDescription;
end

tic
t.setTag(tagstruct);
t.write(stack(:,:,1));
for i = 2:size(stack,3)
    t.writeDirectory();
    t.setTag(tagstruct);
    t.write(stack(:,:,i));
end
t.close()
toc
end