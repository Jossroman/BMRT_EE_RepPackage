function [grouped_contrib, group_labels] = irf_aggregate_contributions_by_groups(contributions, state_names, group_definitions)
all_matched = false(1, length(state_names));

for g = 1:size(group_definitions, 1)
    matched = ismember(state_names, group_definitions{g, 2})';
    all_matched = all_matched | matched;
end

unmatched_names = state_names(~all_matched);
if ~isempty(unmatched_names)
    group_definitions(end+1, :) = {'Others', unmatched_names};
end

n_endo = size(contributions, 1);
T = size(contributions, 3);
n_groups = size(group_definitions, 1);

grouped_contrib = zeros(n_endo, n_groups, T);
group_labels = group_definitions(:, 1);

for g = 1:n_groups
    mask = ismember(state_names, group_definitions{g, 2});
    grouped_contrib(:, g, :) = sum(contributions(:, mask, :), 2);
end

grouped_contrib(:, 1, :) = grouped_contrib(:, 1, :) + sum(contributions(:, end, :), 2);
end
