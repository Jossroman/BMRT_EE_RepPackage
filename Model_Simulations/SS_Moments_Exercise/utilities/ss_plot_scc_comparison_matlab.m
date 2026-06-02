function ss_plot_scc_comparison_matlab(field_names, sensi_values, result_table, fig_options, output_dir)
model_names = fieldnames(result_table);
num_models = length(model_names);

xmin = inf;
xmax = -inf;
for i = 1:num_models
    model_data = result_table.(model_names{i});
    xmin = min(xmin, min(model_data, [], 'all'));
    xmax = max(xmax, max(model_data, [], 'all'));
end
xmargin = 0.08 * (xmax - xmin);

fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 14 6.5], 'Visible', 'off');
tl = tiledlayout(fig, 1, num_models, 'TileSpacing', 'compact', 'Padding', 'compact');
cmap = [linspace(0, 1, 256)', linspace(1, 0, 256)', ones(256, 1)];
colormap(fig, cmap);
row_positions = (0:length(field_names)-1) * 2;
bar_half_height = 0.08;

for m = 1:num_models
    ax = nexttile(tl, m);
    hold(ax, 'on');
    model_data = result_table.(model_names{m});

    for i = 1:length(field_names)
        x_values = model_data(i, :);
        c_values = sensi_values(i, :);
        c_range = max(c_values) - min(c_values);
        if c_range == 0
            c_values = zeros(size(c_values));
        else
            c_values = (c_values - min(c_values)) / c_range;
        end

        valid = isfinite(x_values) & isfinite(c_values);
        x_values = x_values(valid);
        c_values = c_values(valid);

        if isempty(x_values)
            continue
        end

        [x_values, sort_idx] = sort(x_values);
        c_values = c_values(sort_idx);
        [x_values, unique_idx] = unique(x_values, 'stable');
        c_values = c_values(unique_idx);

        if length(x_values) == 1
            x_values = x_values + [-eps eps];
            c_values = c_values([1 1]);
        end

        surface(ax, [x_values; x_values], ...
            repmat([row_positions(i)-bar_half_height; row_positions(i)+bar_half_height], 1, length(x_values)), ...
            zeros(2, length(x_values)), ...
            [c_values; c_values], ...
            'FaceColor', 'interp', 'EdgeColor', 'none');
    end

    xline(ax, fig_options.base_value(m), '--k', 'LineWidth', 1);
    clim(ax, [0 1]);
    grid(ax, 'on');
    ax.Box = 'on';
    ax.FontSize = 11;
    ax.YDir = 'reverse';
    ax.YLim = [row_positions(1)-0.8 row_positions(end)+0.8];
    ax.XLim = [xmin - xmargin, xmax + xmargin];
    ax.YTick = row_positions;
    if m == 1
        ax.YTickLabel = field_names;
    else
        ax.YTickLabel = [];
    end
    title(ax, fig_options.modlabels{m}, 'FontSize', 15);
    xlabel(ax, fig_options.xlabel, 'FontSize', 11);
end

cb = colorbar;
cb.Layout.Tile = 'south';
cb.Ticks = [0 1];
cb.TickLabels = {'Low', 'High'};
cb.Label.String = 'Parameter Relative Value';
cb.Label.FontSize = 13;

drawnow;
exportgraphics(fig, fullfile(output_dir, [fig_options.name '.png']), 'Resolution', 300, 'BackgroundColor', 'white');
close(fig);
end
