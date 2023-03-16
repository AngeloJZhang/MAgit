function [repo_name, loc_dest] = bb_fetch(git_url, repo_name, opts)
% ==============================================================================
%  This function fetches the git library and stores it on the desktop. This
%  is a read-only fetcher, no git information is stored. This should not be
%  used for modifying git files. At the moment, this only works for github.com,
%  however, variables can be changed such that it works for different API systems
%  via the temporary files.
%
%  This function is just different enough from git, that it warrents it's
%  own file. There is alot of overlap, however, the different ends up being
%  file structures are actually stored differently in the bb zip vs the git
%  zip.
%
% ==============================================================================

arguments

    % The url for the main repository.
    git_url (1, 1) string

    % The repository name is required in bb_fetch
    repo_name

    % The commit value to specify a particular version of the repository
    opts.commit (1, 1) string = ""

    % The temp dir to store files
    opts.tempdir (1, 1) string = tempdir()

    % This variables adjusts the commit access. "<commit>" is the
    % placeholder token for the commit number located in "opts.commit"
    % https://github.com/ckan/ckanext-xloader/archive/c9615d86c2ac2ca4617481d33e57db5b4732931e.zip
    opts.commit_url_exp (1, 2) string = ["(.*)(?:projects)(.*)(?:browse)", ...
        "$1rest/api/latest/projects$2archive?at=<commit>&format=zip"]

    % This variable adjusts main branch access
    % https://github.com/AngeloJZhang/MatlabPluginPattern/archive/refs/heads/main.zip
    opts.main_url_exp (1, 2) string = ["(.*)(?:projects)(.*)(?:browse)", ...
        "$1rest/api/latest/projects$2archive?format=zip"]

    % This variable holds your token for auth.
    opts.token (1, 1) string = ""

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

end % if

% Attempt to pull data
try
    fprintf('[INFO] Download started ...\n');
    websave(zip_path, full_url, webopt_obj);

catch ME
    rethrow(ME);

end % try

if ~exist(zip_path, "file")
    error("Empty GIT repository : %s", full_url);
    
end % if

fprintf("[INFO] Unzipping : %s\n", git_url);

% Attempt to unzip the repository
dir_path = fullfile(opts.tempdir, repo_name);

% repo_name = regexp(zip_path, );
unzip(zip_path, dir_path);

fprintf("[INFO] Done unzipping...\n");

delete(zip_path);

fprintf("[INFO] Deleted zip file...\n");

% Set path to directory
loc_dest = dir_path;

fprintf("[INFO] Successful Fetch : %s\n", git_url);

end % function