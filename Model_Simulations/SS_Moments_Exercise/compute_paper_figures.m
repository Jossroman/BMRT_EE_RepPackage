clearvars -except this_dir ss_ndraws; close all; clc;

if exist('ss_ndraws', 'var')
    ndraws = ss_ndraws;
else
    ndraws = 1000;
end

script_dir = fileparts(mfilename('fullpath'));
root_dir = fileparts(script_dir);
fig_dir = fullfile(script_dir, 'results', 'figures');
utilities_dir = fullfile(script_dir, 'utilities');
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
addpath(utilities_dir);

model_specs = struct( ...
    'name', {'NC_SCC_Hybrid', 'Fossil_SCC_Hybrid'}, ...
    'dir', {fullfile(root_dir, 'NC_Model'), fullfile(root_dir, 'Fossil_Model')});

scc_param_names = {'TEMP_MEAN', 'ZETTA_1', 'BETTA', 'EPS_Y'};
scc_param_labels = {'Damage Functions', 'Climate Sensitivity', 'Discount Rate', 'Elasticity of Substitution (First Layer)'};
scc_param_values = zeros(length(scc_param_names), ndraws);
scc_param_values(1, :) = linspace(14.5/15.5, 14.5/15.5*4, ndraws);
scc_param_values(2, :) = linspace(0.1, 2, ndraws);
scc_param_values(3, :) = linspace(0.94, 0.99, ndraws);
scc_param_values(4, :) = linspace(0.2, 3.5, ndraws);

scc_figures = struct( ...
    'name', {'paper_fig4', 'paper_fig9'}, ...
    'climate_model', {0, 1});

for ifig = 1:length(scc_figures)
    result_plot = struct();
    base_value = NaN(1, length(model_specs));
    dynare_opts = {'noclearall', '-Dexercise=0', ['-Dclimate_model=' num2str(scc_figures(ifig).climate_model)], '-Dhabits=0', '-Dclimate_calib=0'};

    for imod = 1:length(model_specs)
        sensitivity_model_spec = model_specs(imod);
        sensitivity_dynare_opts = dynare_opts;
        sensitivity_param_names = scc_param_names;
        sensitivity_param_values = scc_param_values;
        sensitivity_display_variables = {'v_emission'};
        run(fullfile(utilities_dir, 'ss_run_steady_sensitivity.m'));

        result_plot.(model_specs(imod).name) = sensitivity_result.values.v_emission;
        base_value(imod) = sensitivity_result.orig_ss(strcmp(sensitivity_result.endo_names, 'v_emission'));
    end

    fig_options.name = scc_figures(ifig).name;
    fig_options.xlabel = 'Social Cost of Carbon 2018 (Real US$ per tCO2)';
    fig_options.modlabels = {'Natural Capital Model', 'Energy Only Model'};
    fig_options.base_value = base_value;
    ss_plot_scc_comparison_matlab(scc_param_labels, scc_param_values, result_plot, fig_options, fig_dir);
end

shadow_param_names = {'TEMP_MEAN', 'EPS_Y', 'BETTA', 'ZETTA_1'};
shadow_param_tex = {'\beta^{h}_{m}', '\theta', '\beta', '\phi_{1}'};
shadow_fig_names = {'paper_fig10', 'paper_fig5', 'paper_fig11', 'paper_fig12'};
shadow_param_values = [
    14.5/15.5, 14.5/15.5*2, 14.5/15.5*4;
    1.70, 0.99, 0.85;
    0.968, 0.95, 0.99;
    0.50, 0.25, 0.75
];
shadow_variables = {'v_K', 'v_AL', 'v_Energy', 'v_Fossil', 'v_Oil', 'v_Gas', 'v_Coal', 'v_Renewable', 'v_Minerals', 'v_Eco_Services', 'v_Land'};
shadow_labels.NC_SCC_Hybrid = {'Produced', 'Human', 'Energy', 'Fossil', 'Oil', 'Gas', 'Coal', 'Renewable', 'Minerals', 'Forest', 'Land'};
shadow_labels.Fossil_SCC_Hybrid = {'Produced', 'Human', 'Energy'};

dynare_opts = {'noclearall', '-Dexercise=0', '-Dclimate_model=0', '-Dhabits=0', '-Dclimate_calib=0'};
shadow_results = struct();
shadow_endo_names = struct();

for imod = 1:length(model_specs)
    sensitivity_model_spec = model_specs(imod);
    sensitivity_dynare_opts = dynare_opts;
    sensitivity_param_names = shadow_param_names;
    sensitivity_param_values = shadow_param_values;
    sensitivity_display_variables = shadow_variables;
    run(fullfile(utilities_dir, 'ss_run_steady_sensitivity.m'));

    shadow_results.(model_specs(imod).name) = sensitivity_result.values;
    shadow_endo_names.(model_specs(imod).name) = sensitivity_result.endo_names;
end

fig_options.titles = {'Natural Capital Model', 'Energy Only Model'};
fig_options.varlabels = shadow_labels;

for ipar = 1:length(shadow_param_names)
    result_plot = struct();
    fig_options.name = shadow_fig_names{ipar};

    if ipar == 1
        legend_labels = {['Baseline - Estimated ' shadow_param_tex{ipar}], ['Estimated ' shadow_param_tex{ipar} ' x2'], ['Estimated ' shadow_param_tex{ipar} ' x4']};
    else
        legend_labels = {['Baseline - ' shadow_param_tex{ipar} ' = ' num2str(shadow_param_values(ipar, 1), 2)], ...
                         [shadow_param_tex{ipar} ' = ' num2str(shadow_param_values(ipar, 2), 2)], ...
                         [shadow_param_tex{ipar} ' = ' num2str(shadow_param_values(ipar, 3), 2)]};
    end

    for imod = 1:length(model_specs)
        model_name = model_specs(imod).name;
        model_values = [];

        for ivar = 1:length(shadow_variables)
            var_name = shadow_variables{ivar};
            if any(strcmp(shadow_endo_names.(model_name), var_name))
                raw_values = shadow_results.(model_name).(var_name)(ipar, :);
                model_values(:, end+1) = (raw_values ./ raw_values(1))';
            end
        end

        result_plot.(model_name) = model_values;
        fig_options.legends.(model_name) = legend_labels;
    end

    ss_plot_radar_2mods_matlab(fig_options.varlabels, result_plot, fig_options, fig_dir);
end
