close all; clear; clc;

% ===============================
% Reproducibility setup
% ===============================

num_bootstrap = 1000;

% Master seed
master_seed = 0;

% Set global seed for reproducibility
rng(master_seed, 'twister');

% Pre-generate one deterministic seed per bootstrap replication
seeds = randi(1e9, num_bootstrap, 1);

% ===============================
% Symbolic setup
% ===============================

syms gamma_f beta_oilgas beta_coal rho_f y_oil y_gas y_coal

ces = log(gamma_f) ...
    - (0.4149 / rho_f) * log( ...
        beta_oilgas * (y_gas + y_oil)^(-rho_f) ...
        + beta_coal * y_coal^(-rho_f) ...
    );

parameters = [beta_oilgas, beta_coal, rho_f, gamma_f];
data_variables = [y_oil, y_gas, y_coal];

ces_func = matlabFunction(ces, 'Vars', [parameters, data_variables]);

% ===============================
% Load data
% ===============================

data = readtable("C:\Users\adity\Dropbox\Adi-Simone-Ghassane\Natural Capital\Cleaned Files\matlab_data_fossil.xlsx");

y_oil = data.oil_production_n;
y_gas = data.gas_production_n;
y_coal = data.coal_production_n;
Y_d = data.log_fossil_cons;

% ===============================
% Objective function
% ===============================

objective = @(params) 0.5 * sqrt(sum( ...
    (Y_d - ces_func( ...
        params(1), params(2), params(3), params(4), ...
        y_oil, y_gas, y_coal ...
    )).^2 ...
));

initial_guess = [1/2, 1/2, -0.5, 2];

% Lower and upper bounds
lb = [0, 0, -1, 0];
ub = [1, 1, Inf, Inf];

% Equality constraint: beta_oilgas + beta_coal = 1
Aeq = [1, 1, 0, 0];
beq = 1;

options = optimoptions( ...
    'fmincon', ...
    'Algorithm', 'sqp', ...
    'Display', 'iter', ...
    'MaxFunctionEvaluations', 2000 ...
);

% ===============================
% Baseline estimation
% ===============================

[estimated_params, fval] = fmincon( ...
    objective, initial_guess, ...
    [], [], Aeq, beq, lb, ub, [], options ...
);

disp('Estimated parameters: beta_oilgas beta_coal rho_f gamma_f');
disp(estimated_params);

% ===============================
% Bootstrap estimation
% ===============================

bootstrap_params = zeros(num_bootstrap, length(initial_guess));

% Quieter options for parfor
options_boot = optimoptions( ...
    'fmincon', ...
    'Algorithm', 'sqp', ...
    'Display', 'off', ...
    'MaxFunctionEvaluations', 2000 ...
);

parfor i = 1:num_bootstrap

    % Worker-specific deterministic seed
    rng(seeds(i), 'twister');

    % Resample data with replacement
    idx = randsample(length(Y_d), length(Y_d), true);

    Y_d_boot = Y_d(idx);
    y_oil_boot = y_oil(idx);
    y_gas_boot = y_gas(idx);
    y_coal_boot = y_coal(idx);

    % Define objective function for bootstrapped data
    objective_boot = @(params) 0.5 * sqrt(sum( ...
        (Y_d_boot - ces_func( ...
            params(1), params(2), params(3), params(4), ...
            y_oil_boot, y_gas_boot, y_coal_boot ...
        )).^2 ...
    ));

    % Optimize for bootstrapped data
    [bootstrap_params(i, :), ~] = fmincon( ...
        objective_boot, initial_guess, ...
        [], [], Aeq, beq, lb, ub, [], options_boot ...
    );
end

third_layer_bootstrap_table = array2table( ...
    bootstrap_params, ...
    'VariableNames', {'beta_oilgas', 'beta_coal', 'rho_f', 'gamma_f'} ...
);

% ===============================
% Bootstrap summary statistics
% ===============================

means = mean(bootstrap_params);

disp('Mean Values');
disp(means);

std_error = std(bootstrap_params);

lower_bound = prctile(bootstrap_params, 2.5);
upper_bound = prctile(bootstrap_params, 97.5);

disp('Standard Errors:');
disp(std_error);

disp('Confidence Intervals:');
for i = 1:length(estimated_params)
    fprintf('Parameter %d: [%f, %f]\n', i, lower_bound(i), upper_bound(i));
end

% ===============================
% Model fit
% ===============================

predicted_Y = ces_func( ...
    estimated_params(1), estimated_params(2), estimated_params(3), estimated_params(4), ...
    y_oil, y_gas, y_coal ...
);

residuals = Y_d - predicted_Y;

MSE = mean(residuals.^2);

disp('Mean Squared Error:');
disp(MSE);

% ===============================
% Elasticity calculation
% ===============================

elasticity = 1 / (1 + means(3));

disp('Elasticity');
disp(elasticity);

means = [means, MSE];

std_error = [std_error, NaN];

var_names = {'beta_oilgas', 'beta_coal', 'rho_f', 'gamma_f', 'MSE'};

bootstrap_summary = table( ...
    means', ...
    std_error', ...
    'VariableNames', {'Mean', 'StandardDeviation'}, ...
    'RowNames', var_names);

output_file = fullfile(cd, "third_layer_sqp.xlsx");

writetable(bootstrap_summary, output_file, ...
    'Sheet', 'Bootstrap Summary', ...
    'WriteRowNames', true);