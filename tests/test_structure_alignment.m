classdef test_structure_alignment < matlab.unittest.TestCase
    methods (Test)
        function packageFunctionsHaveHelp(testCase)
            repoRoot = fileparts(fileparts(mfilename('fullpath')));
            packageRoot = fullfile(repoRoot, 'src', '+tif');
            publicFiles = {'load.m', 'info.m', 'save.m', 'write.m', 'frame.m'};

            testCase.verifyTrue(isfile(fullfile(packageRoot, 'Contents.m')));
            for i = 1:numel(publicFiles)
                filePath = fullfile(packageRoot, publicFiles{i});
                testCase.verifyTrue(isfile(filePath), filePath);
                if ~isfile(filePath)
                    continue
                end
                text = fileread(filePath);
                testCase.verifyNotEmpty(regexp(text, '^\s*%\s+\S+', 'once', 'lineanchors'), filePath);
                requiredSections = {'Syntax', 'Inputs', 'Outputs', 'Examples'};
                for j = 1:numel(requiredSections)
                    pattern = ['^\s*%\s+' requiredSections{j} '\s*$'];
                    testCase.verifyNotEmpty(regexp(text, pattern, 'once', 'lineanchors'), ...
                        sprintf('%s is missing help section: %s', filePath, requiredSections{j}));
                end
            end
        end

        function saveLoadRoundTripPreservesUint16Stack(testCase)
            repoRoot = fileparts(fileparts(mfilename('fullpath')));
            srcPath = fullfile(repoRoot, 'src');
            testCase.verifyTrue(isfolder(srcPath), srcPath);
            if ~isfolder(srcPath)
                return
            end
            addpath(srcPath);
            cleanupPath = onCleanup(@() rmpath(srcPath));

            stack = uint16(reshape(1:24, [3 4 2]));
            outDir = tempname;
            mkdir(outDir);
            cleanupDir = onCleanup(@() rmdir(outDir, 's'));
            outFile = fullfile(outDir, 'roundtrip.tif');

            tif.save(outFile, stack, 16, 'structure alignment round trip');
            loaded = tif.load(outFile);

            testCase.verifyEqual(loaded, stack);
        end
    end
end
