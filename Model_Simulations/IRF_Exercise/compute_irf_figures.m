clearvars; close all; clc;

script_dir = fileparts(mfilename('fullpath'));
model_dir = fullfile(fileparts(script_dir), 'NC_Model');
fig_dir = fullfile(script_dir, 'figures');
utilities_dir = fullfile(script_dir, 'utilities');
work_dir = tempname;

if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
addpath(utilities_dir);
addpath(model_dir);
mkdir(work_dir);
copyfile(fullfile(model_dir, 'NC_SCC_Hybrid.mod'), fullfile(work_dir, 'NC_SCC_Hybrid.mod'));

old_dir = pwd;
cleanup = onCleanup(@() cd(old_dir));

T = 100;
T_cut_stocks = 30;
order = 1;

stocks_list = {'s_Gas', 'y_AL', 'y_K', 'y_Energy', 'y_Land', 'y_Minerals', 'y_Eco_Services'};
stocks_names = {'Gas Stock', 'Human Capital Prod.', 'Produced Capital Prod.', 'Energy Prod.', 'Land Prod.', 'Minerals Prod.', 'Forest ES Prod.'};

decomp_list = {'y_t', 'welfare', 'e'};
decomp_names = {'Final Output', 'Welfare', 'Emissions'};

cd(work_dir);
dynare('NC_SCC_Hybrid.mod', 'noclearall', '-Dexercise=4', '-Dfully_detrended=1', '-Dclimate_model=0', '-Dhabits=0');

M_linear = M_;
options_linear = options_;
oo_linear = oo_;
y0 = oo_linear.dr.ys;

ex_ = zeros(T, M_linear.exo_nbr);
shock_idx = strcmp(M_linear.exo_names, 'eta_d');
gas_idx = strcmp(M_linear.endo_names, 's_Gas');

ex_(1, shock_idx) = 0.01;
y_tmp = simult_(M_linear, options_linear, y0, oo_linear.dr, ex_, order);
impact = y_tmp(gas_idx, 2) / y0(gas_idx) - 1;

ex_(1, shock_idx) = 0.1 / impact * 0.01;
y_linear = simult_(M_linear, options_linear, y0, oo_linear.dr, ex_, order);
[~, contrib] = irf_simult_with_contributions(M_linear, options_linear, y0, oo_linear.dr, ex_, order);

clear functions
dynare('NC_SCC_Hybrid.mod', 'noclearall', '-Dexercise=3', '-Dfully_detrended=1', '-Dclimate_model=0', '-Dhabits=0', '-Danticipated=0');
M_pf_surprise = M_;
y_pf_surprise = oo_.endo_simul;

clear functions
dynare('NC_SCC_Hybrid.mod', 'noclearall', '-Dexercise=3', '-Dfully_detrended=1', '-Dclimate_model=0', '-Dhabits=0', '-Danticipated=1');
M_pf_anticipated = M_;
y_pf_anticipated = oo_.endo_simul;
cd(script_dir);

figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 9 10.5]);
set(gcf, 'PaperPositionMode', 'auto');
tl = tiledlayout(3, 3, 'TileSpacing', 'loose', 'Padding', 'compact');

for iS = 1:length(stocks_list)
    v_idx = strcmp(M_linear.endo_names, stocks_list{iS});
    nexttile(tl, iS);

    to_plot = (y_linear(v_idx, 2:T_cut_stocks) / y0(v_idx) - 1) * 100;
    plot(to_plot, 'b-', 'LineWidth', 1.5);

    grid on
    ax = gca;
    ax.Box = 'off';
    ax.FontSize = 9;
    ax.XLim = [1, T_cut_stocks];
    yline(0, '--k', 'LineWidth', 0.75);

    title(stocks_names{iS}, 'Interpreter', 'latex', 'FontSize', 13);
    xlabel('Time (years)', 'FontSize', 9);
    ylabel('Deviation from steady state (\%)', 'Interpreter', 'latex', 'FontSize', 9);
end

nexttile(tl, length(stocks_list) + 1);
axis off;
drawnow;
exportgraphics(gcf, fullfile(fig_dir, 'paper_fig6.pdf'), 'ContentType', 'vector', 'BackgroundColor', 'white');

figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 9 10.5]);
set(gcf, 'PaperPositionMode', 'auto');
tl = tiledlayout(3, 3, 'TileSpacing', 'loose', 'Padding', 'compact');

for iS = 1:length(stocks_list)
    linear_idx = strcmp(M_linear.endo_names, stocks_list{iS});
    surprise_idx = strcmp(M_pf_surprise.endo_names, stocks_list{iS});
    anticipated_idx = strcmp(M_pf_anticipated.endo_names, stocks_list{iS});
    nexttile(tl, iS);

    to_plot = [(y_linear(linear_idx, 2:T_cut_stocks) / y0(linear_idx) - 1)' * 100, ...
               (y_pf_surprise(surprise_idx, 2:T_cut_stocks) / y_pf_surprise(surprise_idx, 1) - 1)' * 100, ...
               (y_pf_anticipated(anticipated_idx, 2:T_cut_stocks) / y_pf_anticipated(anticipated_idx, 1) - 1)' * 100];

    plot(to_plot(:, 1), 'b-', 'LineWidth', 1.5); hold on
    plot(to_plot(:, 2), '--r', 'LineWidth', 1.5);
    plot(to_plot(:, 3), ':k', 'LineWidth', 1.5);

    grid on
    ax = gca;
    ax.Box = 'off';
    ax.FontSize = 9;
    ax.XLim = [1, T_cut_stocks];
    yline(0, '--k', 'LineWidth', 0.75);

    title(stocks_names{iS}, 'Interpreter', 'latex', 'FontSize', 13);
    xlabel('Time (years)', 'FontSize', 9);
    ylabel('Deviation from steady state (\%)', 'Interpreter', 'latex', 'FontSize', 9);
end

nexttile(tl, length(stocks_list) + 1);
axis off;
hold on;
h_linear = plot(NaN, NaN, 'b-', 'LineWidth', 1.5);
h_surprise = plot(NaN, NaN, '--r', 'LineWidth', 1.5);
h_anticipated = plot(NaN, NaN, ':k', 'LineWidth', 1.5);
legend([h_linear, h_surprise, h_anticipated], {'1st order', 'Non linear', 'Non linear anticipated'}, ...
    'Box', 'off', 'FontSize', 12);

drawnow;
exportgraphics(gcf, fullfile(fig_dir, 'paper_fig15.pdf'), 'ContentType', 'vector', 'BackgroundColor', 'white');

state_ids = oo_linear.dr.state_var;
state_names = M_linear.endo_names(state_ids);

group_definitions = {
    'Stoch. Innovations', {'e_shock_a', 'e_shock_d', 'e_shock_t'};
    'Stocks', {'s_K', 's_Coal', 's_Oil', 's_Gas', 's_Renewable', 's_Land', 's_Minerals', 'y_Eco_Services'};
    'Preferences', {'Beta', 'H', 'AUX_ENDO_LAG_0_1', 'AUX_ENDO_LAG_0_2', 'AUX_ENDO_LAG_0_3'};
    'Climate Dynamics', {'x_tot', 't', 'AUX_ENDO_LAG_33_1', 'AUX_ENDO_LAG_33_2', 'AUX_ENDO_LAG_33_3', 'AUX_ENDO_LAG_33_4'};
};

[grouped_contrib_direct, group_labels] = irf_aggregate_contributions_by_groups(contrib.direct, state_names, group_definitions);

figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 9 10.5]);
set(gcf, 'PaperPositionMode', 'auto');
tl = tiledlayout(4, 2, 'TileSpacing', 'loose', 'Padding', 'compact');

h_decomp = gobjects(length(group_labels), 1);

for iS = 1:length(decomp_list) * 2
    v_idx = strcmp(M_linear.endo_names, decomp_list{ceil(iS / 2)});
    nexttile(tl, iS);

    if mod(iS, 2) == 1
        if y0(v_idx) >= 0
            to_plot = (y_linear(v_idx, 2:end) / y0(v_idx) - 1) * 100;
        else
            to_plot = -(y_linear(v_idx, 2:end) / y0(v_idx) - 1) * 100;
        end
        h_baseline = plot(to_plot, 'b-', 'LineWidth', 1.5);
    else
        if y0(v_idx) >= 0
            to_plot = (squeeze(grouped_contrib_direct(v_idx, :, M_linear.maximum_lag+1:end) + y0(v_idx)) / y0(v_idx) - 1) * 100;
        else
            to_plot = -(squeeze(grouped_contrib_direct(v_idx, :, M_linear.maximum_lag+1:end) + y0(v_idx)) / y0(v_idx) - 1) * 100;
        end
        cmap = lines(length(group_labels));
        hold on
        for g = 1:length(group_labels)
            h_decomp(g) = plot(1:T, to_plot(g, :), '--', 'Color', cmap(g, :), 'LineWidth', 2);
        end
    end

    grid on
    ax = gca;
    ax.Box = 'off';
    ax.FontSize = 9;
    ax.XLim = [1, T];
    yline(0, '--k', 'LineWidth', 0.75);

    title(decomp_names{ceil(iS / 2)}, 'Interpreter', 'latex', 'FontSize', 14);
    xlabel('Time (years)', 'FontSize', 9);
    ylabel('Deviation from s.s. (\%)', 'Interpreter', 'latex', 'FontSize', 9);
end

ha_left = nexttile(tl, 7);
axis(ha_left, 'off');
ha_right = nexttile(tl, 8);
axis(ha_right, 'off');

legend(ha_left, h_baseline, {'Baseline IRF'}, ...
    'Location', 'northwest', 'Box', 'off', 'FontSize', 12);
legend(ha_right, h_decomp, group_labels, ...
    'Location', 'northwest', 'NumColumns', 2, 'Box', 'off', 'FontSize', 12);

drawnow;
exportgraphics(gcf, fullfile(fig_dir, 'paper_fig7.pdf'), 'ContentType', 'vector', 'BackgroundColor', 'white');

clear functions
try
    rmdir(work_dir, 's');
catch
end
