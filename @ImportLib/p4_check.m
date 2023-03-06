function dir_path = p4_check(base_dir, remote_paths)
% ==============================================================================
%  This function logs into Perforce and auto gets the required files
%  before, allowing the user to continue. This script is created in MATLAB
%  as opposed to a bash shell script to allow for ease of use between
%  system OS. Windows CMD does not naturally support shell script and
%  Powershell is underused/requires permissions.
%
%  USAGE : p4_check("C:\Users\azhang\p4rep\azhang_PC-AZHANG_367", "//sff_fcr/dev/ANALYSIS_DEV/tools/ThirdParty/yaml4mat")
%
%    - This checks the azhang_PC-AZHANG_367 workspace for "yaml4mat" if it
%      cannot be found, the user is directed through a simple p4 UI.
% ==============================================================================
arguments

    % This holds the base path to the directory
    base_dir (1, 1) string;

    % This holds the filepaths to auto get.
    remote_paths (1, :) string = "";

end % arguments

% If no arguments are provided then do nothing.
if strcmp(remote_paths, "")
    dir_path = base_dir;
    return

end % if

fprintf("[INFO] P4 Check Starting...\n");

% Because the file paths are all depot level paths, remove first '/' and
% get the full paths
remote_paths = regexprep(remote_paths, "(^\/|\/$)", "");
file_paths = fullfile(base_dir, remote_paths);

% Check each path exist and break out of function if they are invalid.
are_all_paths_valid = true;
for filepath = file_paths
    if ~exist(filepath, 'file')
        are_all_paths_valid = false;
        break;

    end % if

end % for

% Exit out, this is not required if all paths exist.
if are_all_paths_valid

    % Perform a "//" flip
    if ispc
        remote_paths = strrep(remote_paths, "/", "\");

    end % if

    dir_path = fullfile(base_dir, remote_paths);
    fprintf("[INFO] All Files Present...\n");
    return

end % if

% Log into the P4v
fprintf("\n\nThe following script requires Perforce and an existing Workspace.\n");
fprintf("Log into Perforce:\n");

username = input("Enter p4v username(Ctrl+C to exit): ", "s");

if system(sprintf("p4 -u %s login", username))
    error('Invalid Login Credentials');

end % if

% Grab the Workspace Information
[~, client_txt] = system(sprintf("p4 clients -u %s", username));
list_of_clients = string(regexp(client_txt, "(?<=Client )\S[A-Za-z0-9_.\-]+\S", "match"));
list_of_dirs = string(regexp(client_txt, "(?<=root )\S[A-Za-z0-9_.\-\\:]+\S", "match"));

% Let's figure this out later
fprintf("Select Workspace: (1 - %d)\n", length(list_of_clients));
for client_iter = 1 : length(list_of_clients)
    fprintf("%d : %s, %s\n", client_iter, list_of_clients(client_iter), list_of_dirs(client_iter));

end % for

% Get the client number
client_ndx = str2double(input("Workspace # : ", "s"));

% Client index check
if client_ndx < 1 || client_ndx > length(list_of_clients)
    error("Invalid index : %d", client_ndx);

end % if

fprintf("[INFO] Processing, Please Wait ... \n");

% Select Workspace
if system(sprintf("p4 set P4CLIENT=%s", list_of_clients(client_ndx)))
    error("Workspace Failure. Cannot find workspace.")

end % if

% Check and Validate
if ~exist(list_of_dirs(client_ndx), "dir")
    error("Cannot find workspace root %s. Invalid Workspace Selected." ...
        + " If you wish to continue anyway create an empty folder and restart.", ...
        list_of_dirs(client_ndx));

end % if

% Grab Client Info
[~, client_info_txt] = system('p4 client -o');

% Assign root
dir_path = list_of_dirs(client_ndx);

% Loop through and ensure that the directories required are synced.
file_paths = fullfile(dir_path, remote_paths);
for file_iter = 1 : length(file_paths)
    file_path = file_paths(file_iter);
    remote_path = remote_paths(file_iter);
    [~, ~, ext] = fileparts(file_path);

    fprintf("[INFO] Checking : %s\n", remote_path);

    % Map to workspace view
    if ~contains(client_info_txt, file_path) && strcmp(ext, "")

        fprintf("[INFO] Mapping to Workspace : %s\n", file_path);

        map_path = list_of_clients(client_ndx) + remote_path;

        % This line of code is the million dollar line.
        if system(sprintf('p4 --field View+="/%s/... //%s/..." client -o | p4 client -i', remote_path,  map_path))
            error("Invalid Paths: %s, %s", remote_path, map_path);

        end % if

    end % if

    % If your local path cannot be found then get latest.
    if ~exist(file_path, "dir") && strcmp(ext, "")

         % If folder doesn't exist add it.
        if system(sprintf("p4 sync -f /%s", remote_path + "/..."))
            error("File not found: /%s", remote_path);

        end % if

        % If it is a file doesn't exist add it.
        if ~exist(file_path, 'file') && ~strcmp(ext, "")
            if system(sprintf("p4 sync -f /%s", remote_path))
                error("File not found: /%s", remote_path);

            end % if

        end % if

    end % if

end % for

fprintf("[INFO] P4 Check Done...\n");

% Return proper path
dir_path = fullfile(base_dir, remote_paths);

end % function