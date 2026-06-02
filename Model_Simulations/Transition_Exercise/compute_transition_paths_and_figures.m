% compute_transition_paths_and_figures.m
% ------------------------------------------------------------
% Runs both perfect-foresight transitions from stored guesses and exports
% the same four figures produced by plot_transi.m.
% ------------------------------------------------------------

clearvars; close all; clc;

this_file_dir = fileparts(mfilename('fullpath'));
root_dir      = fileparts(this_file_dir);
fig_dir       = fullfile(this_file_dir, 'figures');

if ~exist(fig_dir, 'dir'); mkdir(fig_dir); end

nc_model_dir     = fullfile(root_dir, 'NC_Model');
fossil_model_dir = fullfile(root_dir, 'Fossil_Model');
addpath(nc_model_dir);
addpath(fossil_model_dir);

nc_seed_file = fullfile(this_file_dir, "guess/pf_guess_nc.mat");
fossil_seed_file = fullfile(this_file_dir, "guess/pf_guess_fossil.mat");

%% Natural capital model
cd(nc_model_dir);
dynare('NC_SCC_Hybrid.mod', 'noclearall', '-Dexercise=2', '-Dhabits=0', '-Dclimate_model=1');
cd(this_file_dir);

nc_seed = load(nc_seed_file);

nc_full_periods  = nc_seed.options_.periods;
nc_solve_periods = nc_full_periods - 1;
options_.periods = nc_solve_periods;
warning off;

oo_ = perfect_foresight_setup(M_, options_, oo_);
oo_.exo_simul  = nc_seed.oo_.exo_simul(1:end-1, :);
oo_.endo_simul = nc_seed.oo_.endo_simul(:, 1:end-1);

fprintf('\nSolving perfect-foresight transition (natural capital model)...\n')
[oo_, ~] = perfect_foresight_solver(M_, options_, oo_);
warning on;

if ~oo_.deterministic_simulation.status
    error('Perfect-foresight solver failed for the natural capital model.')
end

oo_.endo_simul = [oo_.endo_simul nc_seed.oo_.endo_simul(:, end)];
oo_.exo_simul  = [oo_.exo_simul; nc_seed.oo_.exo_simul(end, :)];
options_.periods = nc_full_periods;

M_nc       = M_;
oo_nc      = oo_;
options_nc = options_;

%% Energy-only model
cd(fossil_model_dir);
dynare('Fossil_SCC_Hybrid.mod', 'noclearall', '-Dexercise=2', '-Dhabits=0', '-Dclimate_model=1');
cd(this_file_dir);

fossil_seed = load(fossil_seed_file);

fossil_full_periods  = fossil_seed.options_.periods;
fossil_solve_periods = fossil_full_periods - 1;
options_.periods = fossil_solve_periods;
warning off;

oo_ = perfect_foresight_setup(M_, options_, oo_);
oo_.exo_simul  = fossil_seed.oo_.exo_simul(1:end-1, :);
oo_.endo_simul = fossil_seed.oo_.endo_simul(:, 1:end-1);

fprintf('\nSolving perfect-foresight transition (energy-only model)...\n')
[oo_, ~] = perfect_foresight_solver(M_, options_, oo_);
warning on;

if ~oo_.deterministic_simulation.status
    error('Perfect-foresight solver failed for the energy-only model.')
end

oo_.endo_simul = [oo_.endo_simul fossil_seed.oo_.endo_simul(:, end)];
oo_.exo_simul  = [oo_.exo_simul; fossil_seed.oo_.exo_simul(end, :)];
options_.periods = fossil_full_periods;

M_f       = M_;
oo_f      = oo_;
options_f = options_;

M_ = M_f; oo_ = oo_f; options_ = options_f;

%% Figures
T = 2018:1:2018+size(oo_nc.endo_simul, 2);
T_cut = 2200;
T_cut_ID = find(T == T_cut, 1);

y_nc = oo_nc.endo_simul;
y_f  = oo_f.endo_simul;

y0_nc = y_nc(:, 1);
y0_f  = y_f(:, 1);

FS_AX   = 9;
FS_XLAB = 9;
FS_YLAB = 11;
FS_TIT1 = 14;
FS_TIT4 = 12;
LW      = 1.5;
LEG_FS  = 10;

grid_on = true;
hide_ui = @(ax) hide_axes_ui(ax);

%% Fig 1: GDP, temperature, and SCC
var_list       = {'y_t' , 't', 'v_emission'};
var_list_title = {'Aggregate GDP', 'Temperature', 'Social Cost of Carbon'};
var_list_label = {'Trillions \$', 'Celsius ($^\circ$C)', '\$ / ton of Co2'};

tfp_idx_nc = strcmp(M_nc.endo_names, 'e_a');
tfp_idx_f  = strcmp(M_f.endo_names,  'e_a');
tfp_bool   = [true, false, false];

figure('Position',[100, 100, 650, 950]);
tl = tiledlayout(3, 1, 'Padding', 'compact', 'TileSpacing', 'compact');
tl.OuterPosition = [0.10 0.06 0.88 0.92];

h_nc_leg = gobjects(1,1);
h_f_leg  = gobjects(1,1);

for iV = 1:length(var_list)
    v_idx_nc = strcmp(M_nc.endo_names, var_list{iV});
    v_idx_f  = strcmp(M_f.endo_names,  var_list{iV});

    ax = nexttile(tl);

    to_plot_nc = y_nc(v_idx_nc, 2:T_cut_ID+1);
    if tfp_bool(iV) && any(tfp_idx_nc)
        to_plot_nc = to_plot_nc .* y_nc(tfp_idx_nc, 2:T_cut_ID+1) / y0_nc(tfp_idx_nc);
    end
    h1 = plot(ax, T(1:T_cut_ID), to_plot_nc, 'b-', 'LineWidth', LW);
    hold(ax, 'on');
    if ~isgraphics(h_nc_leg), h_nc_leg = h1; end

    if any(v_idx_f)
        to_plot_f = y_f(v_idx_f, 2:T_cut_ID+1);
        if tfp_bool(iV) && any(tfp_idx_f)
            to_plot_f = to_plot_f .* y_f(tfp_idx_f, 2:T_cut_ID+1) / y0_f(tfp_idx_f);
        end
        h2 = plot(ax, T(1:T_cut_ID), to_plot_f, 'r--', 'LineWidth', LW);
        if ~isgraphics(h_f_leg), h_f_leg = h2; end
    end
    hold(ax, 'off');

    if grid_on, grid(ax, 'on'); end
    ax.Box = 'off';
    ax.FontSize = FS_AX;
    ax.XLim = [T(1), T(T_cut_ID)];
    hide_ui(ax);

    title(ax, var_list_title{iV}, 'Interpreter', 'latex', 'FontSize', FS_TIT1);
    xlabel(ax, 'Years', 'FontSize', FS_XLAB);
    ylabel(ax, var_list_label{iV}, 'Interpreter', 'latex', 'FontSize', FS_YLAB);
end

lg1 = legend([h_nc_leg, h_f_leg], {'Model with Natural Capital','Model with Energy Only'}, ...
    'Orientation', 'horizontal', 'FontSize', LEG_FS, 'Box', 'off');
lg1.Layout.Tile = 'south';

exportgraphics(gcf, fullfile(fig_dir, 'paper_fig2.pdf'), ...
    'ContentType', 'vector', 'BackgroundColor', 'white');

%% Fig 2: sectoral outputs
var_list       = {'y_AL', 'y_K', 'y_Land', 'y_Minerals', 'y_Eco_Services', 'y_Renewable', 'y_Fossil'};
var_list_title = {'Human Capital', 'Produced Capital', 'Land', 'Minerals', 'Forest', 'Renewable', 'Fossil'};

figure('Position', [100, 100, 1200, 600]);
ax = gca; hold(ax, 'on');

colors = lines(length(var_list));

for iV = 1:length(var_list)
    v_idx_nc = strcmp(M_nc.endo_names, var_list{iV});
    if any(v_idx_nc)
        to_plot_nc = y_nc(v_idx_nc, 2:T_cut_ID+1);
        to_plot_nc = to_plot_nc / to_plot_nc(1);
        plot(ax, T(1:T_cut_ID), to_plot_nc, 'LineWidth', LW, 'Color', colors(iV,:), ...
            'DisplayName', var_list_title{iV});
    end

    v_idx_f = strcmp(M_f.endo_names, var_list{iV});
    if any(v_idx_f)
        to_plot_f = y_f(v_idx_f, 2:T_cut_ID+1);
        to_plot_f = to_plot_f / to_plot_f(1);
        plot(ax, T(1:T_cut_ID), to_plot_f, '--', 'LineWidth', LW, 'Color', colors(iV,:), ...
            'HandleVisibility', 'off', 'Visible', 'off');
    end
end

hold(ax, 'off');

if grid_on, grid(ax, 'on'); end
ax.Box = 'off';
ax.FontSize = FS_AX;
ax.XLim = [T(1), T(T_cut_ID)];
hide_ui(ax);

title(ax, 'Sectoral Outputs', 'Interpreter', 'latex', 'FontSize', FS_TIT1);
xlabel(ax, 'Years', 'FontSize', FS_XLAB);
ylabel(ax, 'Index (2018 = 1)', 'Interpreter', 'latex', 'FontSize', FS_YLAB);

legend(ax, 'Location', 'southwest', 'FontSize', LEG_FS, 'Box', 'off');

exportgraphics(gcf, fullfile(fig_dir, 'paper_fig3.pdf'), ...
    'ContentType', 'vector', 'BackgroundColor', 'white');

%% Fig 3: fossil fuels
var_list       = {'y_Coal', 'y_Oil', 'y_Gas'};
var_list_title = {'Coal', 'Oil', 'Gas'};

figure('Position', [100, 100, 1200, 600]);
ax = gca; hold(ax, 'on');

colors = lines(length(var_list));

for iV = 1:length(var_list)
    v_idx_nc = strcmp(M_nc.endo_names, var_list{iV});
    if any(v_idx_nc)
        to_plot_nc = y_nc(v_idx_nc, 2:T_cut_ID+1);
        plot(ax, T(1:T_cut_ID), to_plot_nc, 'LineWidth', LW, 'Color', colors(iV,:), ...
            'DisplayName', var_list_title{iV});
    end

    v_idx_f = strcmp(M_f.endo_names, var_list{iV});
    if any(v_idx_f)
        to_plot_f = y_f(v_idx_f, 2:T_cut_ID+1);
        plot(ax, T(1:T_cut_ID), to_plot_f, '--', 'LineWidth', LW, 'Color', colors(iV,:), ...
            'HandleVisibility', 'off');
    end
end

hold(ax, 'off');

if grid_on, grid(ax, 'on'); end
ax.Box = 'off';
ax.FontSize = FS_AX;
ax.XLim = [T(1), T(T_cut_ID)];
hide_ui(ax);

title(ax, 'Sectoral Outputs (Fossil Fuels)', 'Interpreter', 'latex', 'FontSize', FS_TIT1);
xlabel(ax, 'Years', 'FontSize', FS_XLAB);
ylabel(ax, 'Trillions \$', 'Interpreter', 'latex', 'FontSize', FS_YLAB);

legend(ax, 'Location', 'southwest', 'FontSize', LEG_FS, 'Box', 'off');

exportgraphics(gcf, fullfile(fig_dir, 'paper_fig14.pdf'), ...
    'ContentType', 'vector', 'BackgroundColor', 'white');

%% Fig 4: long-run convergence tiles
var_list       = {'y_t' , 't', 'v_emission', 'y_AL', 'y_K','y_Energy', 'y_Land', 'y_Minerals', 'y_Eco_Services', 'y_Renewable', 'y_Coal', 'y_Oil', 'y_Gas'};
var_list_title = {'Aggregate GDP', 'Temperature', 'Social Cost of Carbon', 'Human Capital', 'Produced Capital','Energy', 'Land', 'Minerals', 'Forest', 'Renewable', 'Coal', 'Oil', 'Gas'};
var_list_label = {'Index (2018 = 1)', 'Celsius ($^\circ$C)', '\$ / ton of Co2', ...
                  'Index (2018 = 1)', 'Index (2018 = 1)','Index (2018 = 1)', ...
                  'Index (2018 = 1)', 'Index (2018 = 1)', 'Index (2018 = 1)', ...
                  'Index (2018 = 1)', 'Index (2018 = 1)', 'Index (2018 = 1)', 'Index (2018 = 1)'};
base_bool = [true, false, false, true, true, true, true, true, true, true, true, true, true];

keep_nc = false(1, length(var_list));
for iV = 1:length(var_list)
    keep_nc(iV) = any(strcmp(M_nc.endo_names, var_list{iV}));
end
var_list_use       = var_list(keep_nc);
var_list_title_use = var_list_title(keep_nc);
var_list_label_use = var_list_label(keep_nc);
base_bool_use      = base_bool(keep_nc);

n_plots = length(var_list_use);
cols = 4;
rows = ceil(n_plots / cols);

figure('Position', [100, 100, 1400, 800]);

tl = tiledlayout(rows, cols, 'Padding', 'compact', 'TileSpacing', 'compact');
tl.TileIndexing = 'rowmajor';

h_nc = gobjects(1,1);
h_f  = gobjects(1,1);

for iV = 1:n_plots
    ax = nexttile(tl);

    v_idx_nc = strcmp(M_nc.endo_names, var_list_use{iV});
    to_plot_nc = y_nc(v_idx_nc, :);
    if base_bool_use(iV)
        to_plot_nc = to_plot_nc / to_plot_nc(1);
    end
    h1 = plot(ax, T(1:end-1), to_plot_nc, 'b-', 'LineWidth', LW);
    hold(ax, 'on');
    if ~isgraphics(h_nc) || ~isgraphics(h_nc(1)), h_nc = h1; end

    v_idx_f = strcmp(M_f.endo_names, var_list_use{iV});
    if any(v_idx_f)
        to_plot_f = y_f(v_idx_f, :);
        if base_bool_use(iV)
            to_plot_f = to_plot_f / to_plot_f(1);
        end
        h2 = plot(ax, T(1:end-1), to_plot_f, 'r--', 'LineWidth', LW);
        if ~isgraphics(h_f) || ~isgraphics(h_f(1)), h_f = h2; end
    end
    hold(ax, 'off');

    if grid_on, grid(ax, 'on'); end
    ax.Box = 'off';
    ax.FontSize = FS_AX;
    ax.XLim = [T(1), T(end-1)];
    hide_ui(ax);

    title(ax, var_list_title_use{iV}, 'Interpreter', 'latex', 'FontSize', FS_TIT4);
    xlabel(ax, 'Years', 'FontSize', FS_XLAB);
    ylabel(ax, var_list_label_use{iV}, 'Interpreter', 'latex', 'FontSize', 10);
end

lg = legend([h_nc, h_f], {'Model with Natural Capital','Model with Energy Only'}, ...
    'Orientation', 'horizontal', 'FontSize', LEG_FS, 'Box', 'off');
lg.Layout.Tile = 'south';

lg.Units = 'normalized';
pos = lg.Position;
pos(2) = max(pos(2) - 0.06, 0.02);
lg.Position = pos;

exportgraphics(gcf, fullfile(fig_dir, 'paper_fig13.pdf'), ...
    'ContentType', 'vector', 'BackgroundColor', 'white');

fprintf('\nTransition paths and figures completed.\n')

function hide_axes_ui(ax)
    try
        disableDefaultInteractivity(ax);
    catch
    end

    try
        if isprop(ax, 'Toolbar') && ~isempty(ax.Toolbar)
            ax.Toolbar.Visible = 'off';
        end
    catch
    end

    try
        axtoolbar(ax, {});
    catch
    end
end
