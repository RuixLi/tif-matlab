classdef test_performance_large_data < matlab.unittest.TestCase
    properties
        RepoRoot
        SrcPath
    end

    methods (TestMethodSetup)
        function addPackagePath(testCase)
            testCase.RepoRoot = fileparts(fileparts(mfilename('fullpath')));
            testCase.SrcPath = fullfile(testCase.RepoRoot, 'src');
            addpath(testCase.SrcPath);
            testCase.addTeardown(@() rmpath(testCase.SrcPath));
        end
    end

    methods (Test)
        function infoReportsMultipageFileMetadata(testCase)
            outDir = testCase.makeTempDir();
            outFile = fullfile(outDir, 'stack.tif');
            stack = uint16(reshape(1:60, [3 4 5]));
            tif.save(outFile, stack, 16, "metadata stack");

            metadata = tif.info(outFile);

            testCase.verifyEqual(metadata.SourceType, 'file');
            testCase.verifyEqual(metadata.Path, outFile);
            testCase.verifyEqual(metadata.Files, {outFile});
            testCase.verifyEqual(metadata.FrameCount, 5);
            testCase.verifyEqual(metadata.PagesPerFile, 5);
            testCase.verifyEqual(metadata.ImageSize, [3 4]);
            testCase.verifyEqual(metadata.ImageLength, 3);
            testCase.verifyEqual(metadata.ImageWidth, 4);
            testCase.verifyEqual(metadata.BitsPerSample, 16);
            testCase.verifyEqual(metadata.SamplesPerPixel, 1);
            testCase.verifyEqual(metadata.Class, 'uint16');
            testCase.verifyGreaterThanOrEqual(metadata.EstimatedStackBytes, double(numel(stack)) * 2);
            testCase.verifyFalse(metadata.IsBigTiff);
            testCase.verifyEqual(metadata.ImageDescription, 'metadata stack');
        end

        function infoReportsFolderMetadataInLoadOrder(testCase)
            outDir = testCase.makeTempDir();
            imwrite(uint8(10 * ones(2, 3)), fullfile(outDir, 'frame10.tif'));
            imwrite(uint8(2 * ones(2, 3)), fullfile(outDir, 'frame2.tif'));
            imwrite(uint8(1 * ones(2, 3)), fullfile(outDir, 'frame1.tiff'));
            fid = fopen(fullfile(outDir, 'notes.txt'), 'w');
            fprintf(fid, 'not a tiff');
            fclose(fid);

            metadata = tif.info(outDir);
            [~, names, extensions] = cellfun(@fileparts, metadata.Files, 'UniformOutput', false);

            testCase.verifyEqual(metadata.SourceType, 'folder');
            testCase.verifyEqual(metadata.Path, outDir);
            testCase.verifyEqual(strcat(names, extensions), {'frame1.tiff', 'frame2.tif', 'frame10.tif'});
            testCase.verifyEqual(metadata.FrameCount, 3);
            testCase.verifyEqual(metadata.PagesPerFile, [1 1 1]);
            testCase.verifyEqual(metadata.ImageSize, [2 3]);
            testCase.verifyEqual(metadata.BitsPerSample, 8);
            testCase.verifyEqual(metadata.Class, 'uint8');
            testCase.verifyFalse(metadata.IsBigTiff);
        end

        function loadSelectedFramesUsesExistingRangeAndStride(testCase)
            outDir = testCase.makeTempDir();
            outFile = fullfile(outDir, 'selected.tif');
            stack = uint16(reshape(1:120, [3 4 10]));
            tif.save(outFile, stack);

            loaded = tif.load(outFile, [3 9], 3);

            testCase.verifyEqual(loaded, stack(:, :, 3:3:9));
        end

        function saveCanForceBigTiff(testCase)
            outDir = testCase.makeTempDir();
            outFile = fullfile(outDir, 'forced-bigtiff.tif');
            stack = uint16(reshape(1:24, [3 4 2]));

            tif.save(outFile, stack, 16, "", 'BigTiff', true);

            metadata = tif.info(outFile);
            loaded = tif.load(outFile);
            testCase.verifyTrue(metadata.IsBigTiff);
            testCase.verifyEqual(loaded, stack);
        end

        function saveAutoUpgradesToBigTiffWhenEstimateExceedsThreshold(testCase)
            outDir = testCase.makeTempDir();
            outFile = fullfile(outDir, 'auto-bigtiff.tif');
            stack = uint16(reshape(1:24, [3 4 2]));

            message = evalc('tif.save(outFile, stack, 16, "", "BigTiffThresholdBytes", 1);');

            metadata = tif.info(outFile);
            loaded = tif.load(outFile);
            testCase.verifyNotEmpty(regexp(message, 'using BigTIFF', 'once'));
            testCase.verifyTrue(metadata.IsBigTiff);
            testCase.verifyEqual(loaded, stack);
        end
    end

    methods
        function outDir = makeTempDir(testCase)
            outDir = tempname;
            mkdir(outDir);
            testCase.addTeardown(@() rmdir(outDir, 's'));
        end
    end
end
