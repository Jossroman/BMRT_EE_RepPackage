% Run the different files for each of the layers. Note that the results
% will be saved in their relevant folders. 

master_dir = cd;

files_to_run = [
    fullfile(master_dir, "First Layer", "ces_complete_case_bootstrap.m")
    fullfile(master_dir, "First Layer", "ces_complete_case_bootstrap_upsilon.m")
    fullfile(master_dir, "First Layer", "ces_energy_prod_complete_bootstrap.m")
    fullfile(master_dir, "First Layer", "ces_energy_prod_complete_bootstrap_upsilon.m")

    fullfile(master_dir, "Second Layer", "ces_second_layer_bootstrap.m")
    fullfile(master_dir, "Second Layer", "ces_second_layer_bootstrap_upsilon.m")

    fullfile(master_dir, "Third Layer", "ces_third_layer_bootstrap.m")
    fullfile(master_dir, "Third Layer", "ces_third_layer_bootstrap_upsilon.m")
];

% this is to ensure that the clear all coded in each file does not
% delete the directories by creating a different session for each file. 
% Launching parpool might take some time. 
for i = 1:numel(files_to_run)
    script_file = files_to_run(i);

    cmd = sprintf('matlab -batch "run(''%s'')"', script_file);

    status = system(cmd);

    if status ~= 0
        error("Script failed: %s", script_file);
    end
end