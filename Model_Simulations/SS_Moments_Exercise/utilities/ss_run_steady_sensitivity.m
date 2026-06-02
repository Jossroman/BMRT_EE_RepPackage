old_dir_sensitivity = pwd;
work_dir_sensitivity = tempname;
mkdir(work_dir_sensitivity);

copyfile( ...
    fullfile(sensitivity_model_spec.dir, [sensitivity_model_spec.name '.mod']), ...
    fullfile(work_dir_sensitivity, [sensitivity_model_spec.name '.mod']));

addpath(sensitivity_model_spec.dir, '-begin');
cd(work_dir_sensitivity);
clear functions
dynare([sensitivity_model_spec.name '.mod'], sensitivity_dynare_opts{:});

sensitivity_endo_names = cellstr(M_.endo_names);
sensitivity_result = struct();
sensitivity_result.endo_names = sensitivity_endo_names;
sensitivity_result.orig_param = M_.params;
sensitivity_result.orig_ss = oo_.steady_state;
sensitivity_result.values = struct();

for sensitivity_ivar = 1:length(sensitivity_display_variables)
    sensitivity_result.values.(sensitivity_display_variables{sensitivity_ivar}) = NaN(size(sensitivity_param_values));
end

for sensitivity_ipar = 1:size(sensitivity_param_values, 1)
    for sensitivity_iparv = 1:size(sensitivity_param_values, 2)
        M_.params = sensitivity_result.orig_param;
        set_param_value(sensitivity_param_names{sensitivity_ipar}, sensitivity_param_values(sensitivity_ipar, sensitivity_iparv));
        options_.noprint = true;
        evalc('steady;');

        for sensitivity_ivar = 1:length(sensitivity_display_variables)
            sensitivity_var_name = sensitivity_display_variables{sensitivity_ivar};
            sensitivity_idx_var = strcmp(sensitivity_endo_names, sensitivity_var_name);
            if any(sensitivity_idx_var)
                sensitivity_result.values.(sensitivity_var_name)(sensitivity_ipar, sensitivity_iparv) = oo_.steady_state(sensitivity_idx_var);
            end
        end
    end
end

cd(old_dir_sensitivity);
rmpath(sensitivity_model_spec.dir);
clear functions
if exist(work_dir_sensitivity, 'dir')
    try
        rmdir(work_dir_sensitivity, 's');
    catch
    end
end
