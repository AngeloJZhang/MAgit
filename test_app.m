classdef test_app < matlab.unittest.TestCase
    % ==========================================================================
    %  This is the test file for MAgit.
    %  This test class should be run from the top-level folder.
    % ==========================================================================
    methods(TestMethodSetup)
        function restore_paths(testCase)

            % Make sure all pathing is empty on each test run.
            restoredefaultpath

        end % function

    end % methods

    methods(Test)
        % Test methods

        function ImportLocal(testCase)
            % ==================================================================
            %  This function tests loading local config.
            % ==================================================================

            ImportLib("test_cfg/import_local.json");
            global magit
            import(magit.test)
            testCase.assertEqual(returnA, "A");
            clearvars -global magit

        end % function

        function ImportP4(testCase)
            % ==================================================================
            %  This function tests loading p4 config.
            % ==================================================================

            % The following uses a random p4 directory, to test this
            % script. If in the future, the directory is changed. Please
            % remove this and map to a different directory. We should no
            % longer be using p4 anyway.
            ImportLib("test_cfg/import_p4.json");
            global magit
            import(magit.tracker_test)
            testCase.assertNotEmpty(which("form_all_hypothesis_score"));
            clearvars -global magit

        end % function

        function ImportGit(testCase)
            % ==================================================================
            %  This function tests loading git config.
            % ==================================================================
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

        function ImportGitWithCommit(testCase)
            % ==================================================================
            %  This function tests loading git_w_commit config.
            % ==================================================================
            ImportLib("test_cfg/import_git_w_commit.json");
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

        function ImportMulti(testCase)
            % ==================================================================
            %  This function tests loading multiple different config.
            % ==================================================================

            % The following uses a random p4 directory, to test this
            % script. If in the future, the directory is changed. Please
            % remove this and map to a different directory. We should no
            % longer be using p4 anyway.
            ImportLib("test_cfg/import_multiple.json");
            global magit

            %% Test Local
            import(magit.test)
            testCase.assertEqual(returnA, "A");

            %% Test P4
            import(magit.tracker_test)
            testCase.assertNotEmpty(which("form_all_hypothesis_score"));

            %% Test Git

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

        function ImportConcat(testCase)
            % ==================================================================
            %  This function tests loading multiple different config.
            % ==================================================================

            % The following uses a random p4 directory, to test this
            % script. If in the future, the directory is changed. Please
            % remove this and map to a different directory. We should no
            % longer be using p4 anyway.
            ImportLib("test_cfg/import_local.json");
            ImportLib("test_cfg/import_p4.json");
            global magit

            %% Test Local
            import(magit.test)
            testCase.assertEqual(returnA, "A");

            %% Test P4
            import(magit.tracker_test)
            testCase.assertNotEmpty(which("form_all_hypothesis_score"));

            %% Clean up
            clearvars -global magit

        end % function

    end % method

end % classdef