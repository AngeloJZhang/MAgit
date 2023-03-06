function new_import_obj = combine(base_magit, new_magit)
% ==============================================================================
%  This function handles the operator for recursive imports
%  from the MAgit class. This allows for users that want to chain MAgit to
%  concat different instances of MAgit together.
% ==============================================================================
arguments

    % This is the base ImportLib Library.
    base_magit (1, 1) ImportLib

    % This is the new ImportLib Library.
    new_magit (1, 1) ImportLib

end % arguments

% All the processing has already been done. This is just to create the new
% map for imports.

base_keys = base_magit.ref_map.keys;
base_values = base_magit.ref_map.values;
new_keys = new_magit.ref_map.keys;
new_values = new_magit.ref_map.values;

% Set the new map
new_map = containers.Map([base_keys new_keys], [base_values new_values]);
base_magit.ref_map = new_map;

% Keep using the base instance as the main instance.
new_import_obj = base_magit;

end % function