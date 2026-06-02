function ss_plot_radar_2mods_matlab(varlabels, result_table, fig_options, output_dir)
model_names = fieldnames(result_table);
colors = [0.00 0.75 0.85; 0.95 0.70 0.10; 0.85 0.00 0.75];

fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 14 7], 'Visible', 'off');
tl = tiledlayout(fig, 1, length(model_names), 'TileSpacing', 'compact', 'Padding', 'compact');

for m = 1:length(model_names)
    model_name = model_names{m};
    data = result_table.(model_name);
    labels = varlabels.(model_name);
    legends = fig_options.legends.(model_name);

    ax = nexttile(tl, m);
    hold(ax, 'on');
    axis(ax, 'equal');
    axis(ax, 'off');

    n_vars = size(data, 2);
    angles = linspace(0, 2*pi, n_vars+1);
    vmin = min(data, [], 'all');
    vmax = max(data, [], 'all');
    if vmin == vmax
        vmin = vmin - eps;
        vmax = vmax + eps;
    end

    for r = 0.25:0.25:1
        plot(ax, r*cos(angles), r*sin(angles), '-', 'Color', [0.82 0.85 0.90], 'LineWidth', 0.75);
    end
    for i = 1:n_vars
        plot(ax, [0 cos(angles(i))], [0 sin(angles(i))], '-', 'Color', [0.88 0.90 0.94], 'LineWidth', 0.75);
        text(ax, 1.13*cos(angles(i)), 1.13*sin(angles(i)), labels{i}, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 10);
    end

    h = gobjects(size(data, 1), 1);
    for i = 1:size(data, 1)
        scaled = (data(i, :) - vmin) / (vmax - vmin);
        scaled = [scaled scaled(1)];
        x = scaled .* cos(angles);
        y = scaled .* sin(angles);
        patch(ax, x, y, colors(i, :), 'FaceAlpha', 0.22, 'EdgeColor', 'none');

        x_segments = NaN(1, 3*n_vars);
        y_segments = NaN(1, 3*n_vars);
        for k = 1:n_vars
            idx = 3*k - 2;
            x_segments(idx:idx+1) = [x(k), x(k+1)];
            y_segments(idx:idx+1) = [y(k), y(k+1)];
        end
        h(i) = plot(ax, x_segments, y_segments, '-', 'Color', colors(i, :), 'LineWidth', 2);
    end

    title(ax, fig_options.titles{m}, 'FontSize', 15, 'FontWeight', 'normal');
    xlim(ax, [-1.35 1.35]);
    ylim(ax, [-1.25 1.25]);

    if m == length(model_names)
        legend(ax, h, legends, 'Location', 'eastoutside', 'Box', 'off', 'FontSize', 10, 'Interpreter', 'tex');
    end
end

drawnow;
exportgraphics(fig, fullfile(output_dir, [fig_options.name '.png']), 'Resolution', 300, 'BackgroundColor', 'white');
close(fig);
end
