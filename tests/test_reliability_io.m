classdef test_reliability_io < matlab.unittest.TestCase
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
        function loadAcceptsStringPathsAndTiffExtension(testCase)
            outDir = testCase.makeTempDir();
            outFile = fullfile(outDir, 'stack.tiff');
            stack = uint16(reshape(1:24, [3 4 2]));

            tif.save(string(outFile), stack, 16, "string path round trip");
            loaded = tif.load(string(outFile));

            testCase.verifyEqual(tif.frame(string(outFile)), 2);
            testCase.verifyEqual(loaded, stack);
        end

        function loadRejectsMissingPathAndEmptyFolder(testCase)
            outDir = testCase.makeTempDir();

            testCase.verifyError(@() tif.load(fullfile(outDir, 'missing.tif')), ...
                'tif:load:FileNotFound');
            testCase.verifyError(@() tif.load(outDir), ...
                'tif:load:NoTiffFiles');
        end

        function folderLoadUsesNaturalOrderAndIgnoresNonTiffs(testCase)
            outDir = testCase.makeTempDir();
            imwrite(uint8(10 * ones(2, 3)), fullfile(outDir, 'frame10.tif'));
            imwrite(uint8(2 * ones(2, 3)), fullfile(outDir, 'frame2.tif'));
            imwrite(uint8(1 * ones(2, 3)), fullfile(outDir, 'frame1.tiff'));
            fid = fopen(fullfile(outDir, 'notes.txt'), 'w');
            fprintf(fid, 'not a tiff');
            fclose(fid);

            stack = tif.load(outDir);

            testCase.verifyEqual(squeeze(stack(1, 1, :))', uint8([1 2 10]));
        end

        function frameRangeSupportsEndSentinelAndStride(testCase)
            outDir = testCase.makeTempDir();
            outFile = fullfile(outDir, 'stack.tif');
            stack = uint16(reshape(1:60, [3 4 5]));
            tif.save(outFile, stack);

            loaded = tif.load(outFile, [2 -1], 2);

            testCase.verifyEqual(loaded, stack(:, :, 2:2:5));
        end

        function loadRejectsOutOfRangeFrames(testCase)
            outDir = testCase.makeTempDir();
            outFile = fullfile(outDir, 'stack.tif');
            tif.save(outFile, uint16(reshape(1:24, [3 4 2])));

            testCase.verifyError(@() tif.load(outFile, [1 3]), ...
                'tif:load:FrameIndexOutOfRange');
        end

        function folderLoadRejectsMixedImageSizes(testCase)
            outDir = testCase.makeTempDir();
            imwrite(uint8(ones(2, 3)), fullfile(outDir, 'frame1.tif'));
            imwrite(uint8(ones(3, 3)), fullfile(outDir, 'frame2.tif'));

            testCase.verifyError(@() tif.load(outDir), ...
                'tif:load:InconsistentImageSize');
        end

        function saveRejectsBitDepthClassMismatch(testCase)
            outDir = testCase.makeTempDir();
            outFile = fullfile(outDir, 'mismatch.tif');

            testCase.verifyError(@() tif.save(outFile, uint8(ones(2, 3, 2)), 16), ...
                'tif:save:BitDepthClassMismatch');
            testCase.verifyError(@() tif.save(outFile, uint16(ones(2, 3, 2)), 8), ...
                'tif:save:BitDepthClassMismatch');
        end

        function writeRejectsNonUint8Images(testCase)
            outDir = testCase.makeTempDir();
            outFile = fullfile(outDir, 'single.tif');

            testCase.verifyError(@() tif.write(outFile, ones(2, 3)), ...
                'tif:write:ImageClass');
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
