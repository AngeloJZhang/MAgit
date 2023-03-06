classdef test_app < matlab.unittest.TestCase
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

        function ImportGit(testCase)
            % ==================================================================
            %  This function tests loading bitbucket config.
            % ==================================================================

            % This is really gross. The objective here is go to get to your
            % C:/<user_name> directory. That is because this should be
            % where your .ssh folder should be with the key that a lets you
            % access bitbucket.
            fileparts(fileparts(userpath))

            ImportLib("test_cfg/import_git.json");
            global magit
            import(magit.MatlabPluginPattern)
            testCase.assertNotEmpty(which("Application"));

            % Make sure that the library was pulled in.
            % Exist doesn't give back a logical for whatever reason.
            testCase.assertTrue(exist(fullfile(tempdir, 'MatlabPluginPattern'), "dir") == 7);

            % Clear PathGuard
            clear MatlabPluginPattern_path_guard

            % Clear ImportLib
            clear ans
            clearvars -global magit

            % Make sure that the library was cleared out.
            testCase.assertTrue(exist(fullfile(tempdir, 'MatlabPluginPattern'), "dir") == 0);

        end % function

    end % methods

end % classdef