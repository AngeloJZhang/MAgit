function import_name = subsref(obj, ref_struct)
% ==================================================================
%  This function sets the paths of the library that
%  that user wants with the ImportLib object. It assigns a guard
%  within the scope of the function so that it automatically
%  clears when the function ends.
%
%  Unfortunately, dynamic imports are not possible due to the
%  following bug so the import_name is passed out to serve as
%  an import point. When, this bug has been fixed, a dynamic
%  import point should be placed.
%
%  While this class can use the mix in for dot indexing it does
%  not because there is no assignment of values.
%
%  https://www.mathworks.com/matlabcentral/answers/1877397-dynamic-import-with-evalin-not-possible
%
%  Usage : import(<ImportLib Obj>.<Library Name>)
%
%  Example : import(lib.testclass) -> this sets the path and
%                                     imports testclass and
%                                     gets cleared at funct end
% ==================================================================
arguments

    % The Import Object itself
    obj (1, 1) ImportLib

    % The Reference Key that the user imports
    ref_struct (1, 1) struct

end % arguments

ref_key = string(ref_struct.subs);

% Perform Validation on the Subscript
if length(ref_key) > 1
    error("This class does not support multiple subscripts.")
end

% Validate the key
if ~any(contains(obj.ref_map.keys, ref_key))
    error("ref_key does not exist in object map: %s", ref_key);
end

import_path = obj.ref_map(ref_key);
pathguard_obj = PathGuard(import_path);

% This evaluates in the caller the PathGuard and the Import
% step so that the user can immediately being using their lib
assignin("caller", ref_key + "_path_guard", pathguard_obj);
import_name = ref_key + ".*";

end % function