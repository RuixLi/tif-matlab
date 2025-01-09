function writeTif(fname, im)
% write single-page 8-bit grayscale or 24-bit RGB TIF image
% automatically cast data into uint8
% also see saveTiff to save multi-page dataset

% INPUT
% fname, file name
% im, a XY matrix for grayscale or a 3d array for RGB

% written by Ruix.Li in Sep, 2020

if ~strcmpi(class(im),'uint8')
    disp('writeTif: cast image into uint8')
    im = uint8(imrscale(im,[0,255]));
end

if ~extwith(fname,'tif')
    [fa,fb] = fileparts(fname);
    fname = [fa,filesep,fb,'.tif'];
end

imwrite(im,fname)
end

%%
function a = extwith(fname,b)
if b(1) == '.'; b = b(2:end); end
[~,~,c] = fileparts(fname);
a = strcmpi(c(2:end),b);

end

function dataOUT = imrscale(dataIN,outRange)
if nargin == 1
    outRange = [0, 255];
end
nel = min(1e12,numel(dataIN));
inMin=quantile(dataIN(1:nel),0.01);
inMax=quantile(dataIN(1:nel),0.99);

if inMin == inMax
    dataOUT = zeros(size(dataIN));
else
    scaleFactor = (outRange(2)-outRange(1)) / (inMax-inMin);
    dataOUT=(dataIN - inMin).* scaleFactor + outRange(1);
end

dataOUT(dataOUT > outRange(2)) = outRange(2);
dataOUT(dataOUT < outRange(1)) = outRange(1);
dataOUT = uint8(dataOUT);
end