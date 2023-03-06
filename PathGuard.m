% ==============================================================================
%  The Pathguard can operate as a standable class or with the importer
%  class to fix the paths for the operation of Matlab.
% ==============================================================================
classdef PathGuard < handle
    % ==========================================================================
    %  The PathGuard class is a simple guard class that
    %  on construction then adds a paths that is requested.
    %  On cleanup, the guard removes its path.
    % ==========================================================================

    properties(GetAccess = public, SetAccess = private)

        % This indicates the path to the directory being added
        path (1, 1) string

    end % properties

    methods(Access = public)
        function obj = PathGuard(dir_path)
            % ==================================================================
            %  Constructor
            % ==================================================================

            arguments
                % This indicates the path to the directory being added
                dir_path (1, 1) string
            end

            % Perform a quick check to see if the path already exists. If
            % it does throw a warning, and do not create a PathGuard.
            env_paths = split(path, ";");
            if contains(env_paths, dir_path)
                warning("Path :%s already exists in searchpath.", dir_path);
                obj.path = "";
                return
            end

            obj.path = dir_path;
            addpath(obj.path);

            % This event is triggered when the PathGuard is about to be deleted
            % due to the ending of a function. Cleanup performed upon the call
            % of this event so that PathGuards are always destroyed before
            % the Importer Class in the unlikely event the two are instanced within
            % the same function call.

            % The listener object pushes in two variables for the feval of
            % the function handle.
            % 1 ) The handle of the object itself
            % 2 ) The event data object
            addlistener(obj, 'ObjectBeingDestroyed', @(obj, ~) cleanup(obj));

        end % function

    end % methods

    methods (Access = private)
        % The following function is seal because it does not act like a
        % normal delete function. It deletes when called by the listener.
        % Nothing else should call this function.
        function cleanup(obj)
            % =============================================================
            %  Destructor
            % =============================================================
            
            % Remove the path if there is something to remove, there should
            % always be something to remove but this is a just in case.
            if ~strcmp(obj.path, "")
                rmpath(obj.path)

            end % if

        end % function

    end % methods

    methods(Static)
        function path = ReturnParentDirectory()
            % =============================================================
            %  Description: Returns the directory that contains PathGuard
            % =============================================================
            path = fileparts((which('PathGuard')));

        end % function

    end % methods

end % classdef



