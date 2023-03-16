% ==============================================================================
%  The ImportLib class manages imports to the data and handles the pathing
%  to said directories. This allows for a more proper pathing in matlab without
%  the need to add every folder in a share coding space. In addition, it allows
%  for import commands such that paths do not persist between function calls.
%  This class is a singleton class.
% ==============================================================================
classdef ImportLib < handle
    % ==========================================================================
    %  Within the Application, the import allows for a very pythonic way of
    %  linking directories. By using the ImportLib, in conjuction with the
    %  pathguard, we create something simpler to the import command such
    %  that, multiple functions with the same name should never be an
    %  issue as they are seperate by both namespace and pathing.
    % ==========================================================================

    %% Constant Variables
    properties(Constant)

        % This field points to the import config
        IMPORT_CFG = "import_cfg.json"

        % This field points to the workspace config
        WORKSPACE_CFG = "workspace.json"

    end % properties

    %% Private Variables
    properties(GetAccess = public, SetAccess = private)

        % This container holds the references between the path to the script
        % and the name of the library
        ref_map containers.Map;

        % This contains the reference structure for the import configs.
        ref_struct (1, 1) struct;

        % This contains the workspace information.
        workspace_struct (1, 1) struct;

    end % properties

    methods (Access = public)
        function obj = ImportLib(path_to_config, opts)
            % ==================================================================
            %  Constructor
            % ==================================================================
            arguments

                % This path_to_config contains the path to the json config that holds
                % the linking configuration of your data.
                path_to_config (1, 1) string {mustBeFile} = ImportLib.IMPORT_CFG

                % This path_to_workspace contains the path to the json config that holds
                % the workspace configuration of your data.
                opts.path_to_workspace (1, 1) string {mustBeFile} = ImportLib.WORKSPACE_CFG

            end % arguments

            % Set the path of ImportLib
            addpath(fileparts(fileparts(mfilename("fullpath"))));

            % Attempt to load in the configurations.
            obj.ref_struct = ImportLib.load_config(path_to_config);
            obj.workspace_struct = ImportLib.load_config(opts.path_to_workspace);

            %% Validate Reference Structure
            if isequal(obj.ref_struct, struct())
                error("Reference Structure must contain a value.");

            end % if

            % This is probably the most valid use of global in MATLAB.
            % Ignore the warning statement.
            global magit

            % Check if magit has been used already.
            if ~isempty(magit)

                % It's actually alright to have duplicates because, in the
                % case of git things will auto delete, and in the case of
                % local paths or p4 paths, they don't double load. So with
                % that in mind, this is not 100% optimized.

                base_import = magit.ref_struct;
                new_import = obj.ref_struct;
                base_names = fieldnames(base_import);
                new_names = fieldnames(new_import);
                new_import_libs = setdiff(new_names, base_names);

                % Set in the original workspace structure.
                obj.workspace_struct = magit.workspace_struct;

                % No new imports found.
                if isempty(new_import_libs)
                    return
                end % if

                % Clear all imports and reset it.
                obj.ref_struct = struct();

                % Loop through and add the valid ones.
                for lib = string(new_import_libs.')
                    obj.ref_struct.(lib) = new_import.(lib);

                end % for

            end % if

            % Create the map <key, value>
            lib_keys = [];
            lib_paths = [];

            for lib = string(fieldnames(obj.ref_struct)).'

                % Get the lib_type of the import
                lib_struct = obj.ref_struct.(lib);
                lib_type = lib_struct.lib_type;

                switch lib_type

                    % Case Bitbucket is a special case of git
                    case "bitbucket"

                        % Look for field "bb_token".
                        if ~isfield(obj.workspace_struct, "bb_token")
                            error("Require bb_token field for bitbucket.");

                        end % if

                        % Error if token does not exist.
                        if ~isfield(obj.workspace_struct, "bb_token")
                            error("The existing workspace does not contain field 'bb_token'." ...
                                + " Refresh the object if the workspace has been updated.");

                        end % if

                        [~, lib_path] = ImportLib.bb_fetch(lib_struct.url, ...
                            lib, ...
                            commit=lib_struct.commit, ...
                            token=obj.workspace_struct.bb_token);

                    % Local library typically means that the folder should
                    % not be cleaned up after the fact.
                    case "local"

                        % Do a quick check to validate the struct exists
                        if ~exist(lib_struct.url, "dir")
                            error("Cannot find path to lib : %s", lib_struct.url)

                        end % if

                        lib_path = lib_struct.url;

                        % A git library means we should download it, unzip it
                        % and then clean it up after the fact.
                    case "git"

                        % TODO : Apply GIT Token
                        [~, lib_path] = ImportLib.git_fetch(lib_struct.url, ...
                            commit=lib_struct.commit, ...
                            repo_name=lib);

                        % A p4 library entails that we should pull the latest
                        % everytime and leave it for later.
                    case "p4"

                        % Look for field "base_path".
                        if ~isfield(obj.workspace_struct, "p4_path")
                            error("The existing workspace does not contain field 'p4_path'." ...
                                + " Refresh the object if the workspace has been updated.");

                        end % if

                        lib_path = ImportLib.p4_check(obj.workspace_struct.p4_path, ...
                            lib_struct.url);

                        % Invalid Library type found. Add to this switch case
                        % if another type needs to be added.
                    otherwise
                        error("Invalid lib_type, Check configuration : %s", lib_type);

                end % switch

                lib_keys = horzcat(lib_keys, lib);
                lib_paths = horzcat(lib_paths, lib_path);

            end % for

            %% Create import map
            obj.ref_map = containers.Map(lib_keys, lib_paths);

            % Create callback for delete function call since occasionally
            % the destructor for matlab does not choose to work. This is a
            % known issue, when it comes to class instances.
            addlistener(obj, 'ObjectBeingDestroyed', @(obj, ~) cleanup(obj));

            % Set the import lib into magit.
            % magit is empty then leave once set.
            if isempty(magit)
                magit = obj;
                return
            end

            % If magit is not empty, combine the mappings.
            magit = ImportLib.combine(magit, obj);
            obj = magit;

        end % function

    end % methods

    methods (Sealed, Access = private)
        % The following function is seal because it does not act like a
        % normal delete function. It deletes when called by the listener.
        % Nothing else should call this function.
        function cleanup(obj)
            % ==================================================================
            %  Destructor
            % ==================================================================

            % Loop through all libraries
            for lib = obj.ref_map.values
                parent_dir = fileparts(string(lib));

                % Clear our everything in the temp directory
                if strcmp(tempdir(), parent_dir + "\")
                    rmdir(string(lib), "s")

                end % if

            end % for

        end % function

    end % methods

    methods (Static)

        % Defining Static Functions Here.
        % Realistically, the inputs should also be defined, however, this
        % will be a TODO item for a later update.
        [repo_name, lib_path] = bb_fetch();
        [repo_name, lib_path] = git_fetch();
        [ref_struct, workspace_struct] = load_config();
        lib_path = p4_check();
        new_import_obj = combine();

    end % methods

end % classdef