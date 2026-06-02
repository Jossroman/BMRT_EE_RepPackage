moments_results = struct();
moments_endo_names = struct();
moments_old_dir = pwd;

for moments_imod = 1:length(model_specs)
    moments_model = model_specs(moments_imod);
    moments_work_dir = tempname;
    mkdir(moments_work_dir);
    copyfile(fullfile(moments_model.dir, [moments_model.name '.mod']), fullfile(moments_work_dir, [moments_model.name '.mod']));
    addpath(moments_model.dir, '-begin');

    try
        cd(moments_work_dir);
        clear functions
        dynare([moments_model.name '.mod'], 'noclearall', '-Dexercise=1', '-Dclimate_model=0', ['-Dhabits=' num2str(moments_spec.habits)]);
        moments_endo_names.(moments_model.name) = cellstr(M_.endo_names);

        for moments_ipar = 1:length(moments_param_values)
            moments_field = [moments_model.name '_' strrep(num2str(moments_param_values(moments_ipar)), '.', '')];
            set_param_value(moments_param_name, moments_param_values(moments_ipar));
            steady;
            moments_results.SS.(moments_field) = oo_.steady_state;
            options_.order = 2;
            options_.nograph = 1;
            M_.Sigma_e(:, :) = 0;
            M_.Sigma_e(moments_spec.shock_index, moments_spec.shock_index) = moments_spec.shock_variance;
            [~, oo_, options_, M_] = stoch_simul(M_, options_, oo_, M_.endo_names);
            moments_results.mean.(moments_field) = oo_.mean;
            moments_results.std.(moments_field) = sqrt(diag(oo_.var));
        end
    catch moments_error
        cd(moments_old_dir);
        rmpath(moments_model.dir);
        if exist(moments_work_dir, 'dir')
            rmdir(moments_work_dir, 's');
        end
        rethrow(moments_error);
    end

    cd(moments_old_dir);
    rmpath(moments_model.dir);
    clear functions
    if exist(moments_work_dir, 'dir')
        rmdir(moments_work_dir, 's');
    end
end

moments_table_mean = NaN(length(moments_display_variables), length(model_specs)*length(moments_param_values));
moments_table_std = NaN(size(moments_table_mean));

for moments_ivar = 1:length(moments_display_variables)
    moments_col = 0;
    for moments_imod = 1:length(model_specs)
        moments_model_name = model_specs(moments_imod).name;
        moments_idx_var = strcmp(moments_endo_names.(moments_model_name), moments_display_variables{moments_ivar});

        for moments_ipar = 1:length(moments_param_values)
            moments_col = moments_col + 1;
            if ~any(moments_idx_var)
                continue
            end

            moments_field = [moments_model_name '_' strrep(num2str(moments_param_values(moments_ipar)), '.', '')];
            moments_mean = moments_results.mean.(moments_field)(moments_idx_var);
            moments_ss = moments_results.SS.(moments_field)(moments_idx_var);
            moments_std = moments_results.std.(moments_field)(moments_idx_var);
            moments_table_mean(moments_ivar, moments_col) = (moments_mean / moments_ss - 1) * 100;
            moments_table_std(moments_ivar, moments_col) = 100 * moments_std / abs(moments_mean);
        end
    end
end
