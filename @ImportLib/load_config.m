function [ref_struct, workspace_struct] = load_config(path_to_config)
% ==============================================================================
%  This function takes the path_to_config and attempts to load the json
%  file in while removing any comments.
% ==============================================================================
arguments

    % This path_to_config contains the path to the json config that holds
    % the linking configuration of your data.
    path_to_config (1, 1) string {mustBeFile}

end % arguments

%% Load in Configuration
txt_data = readlines(path_to_config);

% The following is just a simple negative look ahead with regexp
% Potentially a multi-line comment removal can be done,
% however, that gets very complicated very quickly.
config_data = regexp(txt_data, "^(?!(\s*)\#).*", "match", "noemptymatch");

% Reformat the config data from cell array to string array
config_data = [config_data{:}];

% JSONs read '\' as an escape character and requires '\\' instead.
config_data = strrep(config_data, "\", "\\");

% Combine everything into a single string and decode
config = jsondecode(config_data.join(newline));

% Gets the imports structure
ref_struct = struct();
if isfield(config, "imports")
    ref_struct = config.imports;
    
end % if

% Gets the workspace structure
workspace_struct = struct();
if isfield(config, "workspace")
    workspace_struct = config.workspace;

end % if

end % function
