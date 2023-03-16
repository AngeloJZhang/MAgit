function [repo_name, loc_dest] = git_fetch(git_url, opts)
% ==============================================================================
%  This function fetches the git library and stores it on the desktop. This
%  is a read-only fetcher, no git information is stored. This should not be
%  used for modifying git files. At the moment, this only works for github.com,
%  however, variables can be changed such that it works for different API systems
%  via the temporary files.
% ==============================================================================

arguments

    % The url for the main repository.
    git_url (1, 1) string

    % The commit value to specify a particular version of the repository
    opts.commit (1, 1) string = ""

    % The temp dir to store files
    opts.tempdir (1, 1) string = tempdir()

    % This variables adjusts the commit access. "<commit>" is the
    % placeholder token for the commit number located in "opts.commit"
    % https://github.com/ckan/ckanext-xloader/archive/c9615d86c2ac2ca4617481d33e57db5b4732931e.zip
    opts.commit_url_exp (1, 2) string = ["(.)$", "$1/archive/<commit>.zip"]

    % This variable adjusts main branch access
    % https://github.com/AngeloJZhang/MatlabPluginPattern/archive/refs/heads/main.zip
    opts.main_url_exp (1, 2) string = ["(.)$", "$1/archive/refs/heads/main.zip"]

    % This variable holds your token for auth.
    opts.token (1, 1) string = ""

    % Rename the repo directory if desired.
    opts.repo_name (1, 1) string = ""

end % arguments

webopt_obj = weboptions;

% Add authentication token to the URLread.
if ~strcmp(opts.token, "")
    webopt_obj.HeaderFields = ["Authorization", "Bearer " + opts.token];

end % if

% Attempt to access the webserver.
try
    webread(git_url, webopt_obj);

    % Re-throw the error on the git fetch level
catch MatlabException
    rethrow(MatlabException);

end % try

fprintf("[INFO] Validated (http or https) path.\n");

% Build the zip destination path.
zip_path = string(tempname) + ".zip";

% Build the url to the zip file
if ~strcmp(opts.commit, "")

    % The following is for customizing the URL for different GIT servers.
    fprintf("[INFO] Using GIT commit # : %s.\n", opts.commit);
    url_path = regexprep(git_url, opts.commit_url_exp(1), opts.commit_url_exp(2));
    full_url = strrep(url_path, "<commit>", opts.commit);

else

    % The following is for customizing the URL for different GIT servers.
    fprintf("[INFO] Using GIT main ...\n");
    full_url = regexprep(git_url, opts.main_url_exp(1), opts.main_url_exp(2));

    % There is a chance if a git branch is long standing, they haven't
    % switch from then outdated "master" branch to "main".
    % Here we perform a check.

    try
        webread(full_url, webopt_obj);

    catch
        fprintf("[WARNING] Could not find main branch : %s\n", full_url)
        full_url = strrep(full_url, "main", "master");

    end % try

    % Attempt the 'master' path.
    try
        fprintf("[INFO] Attempting 'master' branch : %s\n", full_url);
        webread(full_url, webopt_obj);

    catch MatlabException
        rethrow(MatlabException);
        
    end % try

end % if

% Attempt to pull data
try
    fprintf('[INFO] Download started ...\n');
    websave(zip_path, full_url, webopt_obj);

catch MatlabException
    rethrow(MatlabException);

end % try

if ~exist(zip_path, "file")
    error("Empty GIT repository : %s", full_url);

end % if

fprintf("[INFO] Unzipping : %s\n", git_url);

% Attempt to unzip the repository
dirname = unzip(zip_path, opts.tempdir);

% The first entry in the dirname is the pointer to the.
dirname = dirname{1};

% Check what OS you are using.
if ispc

    % This expression is for windows due to the "\" filesep
    dirname = string(regexp(dirname, "(?!\\)[-\w]+-\w+(?=\\)", "match"));

else

    % This expression is for mac $ unix due to the "/" filesep
    dirname = string(regexp(dirname, "(?!\/)[-\w+]+-\w+(?=\/$)", "match"));

end % if

fprintf("[INFO] Done unzipping...\n");

delete(zip_path);

fprintf("[INFO] Deleted zip file...\n");

dir_path = fullfile(opts.tempdir, dirname);

% Create the new directory name. This is based on whether or not a repo
% name is provided. If used in the MAgit library, a repo name is always
% provided.
if ~strcmp(opts.repo_name, "")
    new_filepath = fullfile(opts.tempdir, opts.repo_name);

    % Set the repo_name if manually created
    repo_name = opts.repo_name;

else

    new_dirname = string(regexp(dirname, "[-\w]+(?=-)", "match"));
    new_filepath = fullfile(opts.tempdir, new_dirname);

    % Set the repo_name if automatically created
    repo_name = new_dirname;
	
end % if

fprintf("[INFO] Changing name to match HEAD...\n");

% Change to the new directory name.
movefile(dir_path, new_filepath)

fprintf("[INFO] Successful Fetch : %s\n", git_url);

% Set path to directory
loc_dest = new_filepath;

end % function