classdef test_app_tokens < matlab.unittest.TestCase
    % ==========================================================================
    %  This is the test file for MAgit. This particular file handles token
    %  authentication for GIT and Bitbucket. This is seperated out so that
    %  basic functionality can be tested.
    %  This test class should be run from the top-level folder.
    %
    %  IF BITBUCKET IS USED A PERSONAL TOKEN IS REQUIRED.
    %
    % ==========================================================================
    methods(TestMethodSetup)
        function restore_paths(testCase)

            % Make sure all pathing is empty on each test run.
            restoredefaultpath

        end % function

    end % methods

    methods(Test)

        % Test Methods

        function ImportBitBucket(testCase)
            % ==================================================================
            %  This function tests loading bitbucket config.
            % ==================================================================

            ImportLib("test_cfg/import_bitbucket.json");
            global magit
            import(magit.matlabsdms)
            testCase.assertNotEmpty(which("RemoteCKAN"));

            % Make sure that the library was pulled in.
            % Exist doesn't give back a logical for whatever reason.
            testCase.assertTrue(exist(fullfile(tempdir, 'matlabsdms'), "dir") == 7);

            % Clear PathGuard
            clear matlabsdms_path_guard

            % Clear ImportLib
            clear ans
            clearvars -global magit

            % Make sure that the library was cleared out.
            testCase.assertTrue(exist(fullfile(tempdir, 'matlabsdms'), "dir") == 0);

        end % function

        function ImportBitBucketWithCommit(testCase)
            % ==================================================================
            %  This function tests loading bitbucket config.
            % ==================================================================

            ImportLib("test_cfg/import_bitbucket.json");
            global magit
            import(magit.matlabsdms)
            testCase.assertNotEmpty(which("RemoteCKAN"));

            % Make sure that the library was pulled in.
            % Exist doesn't give back a logical for whatever reason.
            testCase.assertTrue(exist(fullfile(tempdir, 'matlabsdms'), "dir") == 7);

            % Clear PathGuard
            clear matlabsdms_path_guard

            % Clear ImportLib
            clear ans
            clearvars -global magit

            % Make sure that the library was cleared out.
            testCase.assertTrue(exist(fullfile(tempdir, 'matlabsdms'), "dir") == 0);

        end % function

    end % methods

end % classdef