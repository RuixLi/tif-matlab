% convert a sequence of images in a given folder to a multipage tiff file
folder_path = 'test';
output_path = '';
output_name = 'tt';
bitspersamp = 8;
ImageDescription = '';

% read the files in the folder
x = loadTif(folder_path);

% save the images to a multipage tiff file
saveTif(fullfile(output_path,output_name),x,bitspersamp,ImageDescription);