% Convert a folder of TIFF images to one multipage TIFF file.

folderPath = 'test';
outputPath = '';
outputName = 'tt';
bitsPerSample = 8;
imageDescription = '';

stack = tif.load(folderPath);
tif.save(fullfile(outputPath, outputName), stack, bitsPerSample, imageDescription);
