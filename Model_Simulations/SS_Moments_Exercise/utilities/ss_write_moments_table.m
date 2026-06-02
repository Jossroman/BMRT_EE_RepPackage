function ss_write_moments_table(output_dir, table_name, caption_text, param_values, result_table_mean, result_table_std, real_names, latex_names)
fid = fopen(fullfile(output_dir, [table_name '.tex']), 'w');

fprintf(fid, '\\begin{table}[h!]\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\begin{tabular}{l l');
for i = 1:2*length(param_values)
    fprintf(fid, ' c');
end
fprintf(fid, '}\n');
fprintf(fid, '\\hline\n');
fprintf(fid, 'Name & Variable & \\multicolumn{%d}{c}{All Natural Capital} & \\multicolumn{%d}{c}{Only Fossil} \\\\\n', length(param_values), length(param_values));
fprintf(fid, '\\hline\n');
fprintf(fid, ' & & ');

for i = 1:length(param_values)
    fprintf(fid, '$\\theta = %.2f$ & ', param_values(i));
end
for i = 1:length(param_values)
    fprintf(fid, '$\\theta = %.2f$', param_values(i));
    if i < length(param_values)
        fprintf(fid, ' & ');
    end
end
fprintf(fid, '\\\\\n');
fprintf(fid, '\\hline\n');

for i = 1:length(real_names)
    fprintf(fid, '%s & %s ', real_names{i}, latex_names{i});
    for j = 1:size(result_table_mean, 2)
        if isnan(result_table_mean(i, j))
            fprintf(fid, '& - ');
        else
            fprintf(fid, '& %.2f ', result_table_mean(i, j));
        end
    end
    fprintf(fid, '\\\\\n');

    fprintf(fid, ' & ');
    for j = 1:size(result_table_std, 2)
        if isnan(result_table_std(i, j))
            fprintf(fid, '& - ');
        else
            fprintf(fid, '& (%.2f) ', result_table_std(i, j));
        end
    end
    fprintf(fid, '\\\\\n');
end

fprintf(fid, '\\hline\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\caption{%s}\n', caption_text);
fprintf(fid, '\\label{tab:%s}\n', table_name);
fprintf(fid, '\\end{table}\n');
fclose(fid);
end
