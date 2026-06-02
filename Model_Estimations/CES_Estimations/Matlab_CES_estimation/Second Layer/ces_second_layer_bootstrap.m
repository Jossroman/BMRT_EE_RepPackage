close all; clear; clc; 
num_bootstrap = 1000; 
% Ensure reproducibility for parfor
rng(0, 'combRecursive');  % Sets global seed

% Pre-generate random seeds for each bootstrap
seeds = randi(1e9, num_bootstrap, 1);

syms gamma_e beta_fe beta_re rho_e y_fe y_re

ces = log(gamma_e) - (0.8126/rho_e)*log(beta_fe*y_fe^(-rho_e) + (1 - beta_fe)*y_re^(-rho_e)); 


parameters = [beta_fe, beta_re, rho_e, gamma_e];
data_variables = [y_fe, y_re];
ces_func = matlabFunction(ces, 'Vars', [parameters, data_variables]);

data = readtable("C:\Users\adity\Dropbox\Adi-Simone-Ghassane\Natural Capital\Cleaned Files\matlab_data_fossil_renew.xlsx");

y_fe_d = data.fossil_energy;
y_re_d = data.renew_energy;

Y_d = data.ln_energy_prod;

objective = @(params) .5*sqrt((sum((Y_d - ces_func(params(1), params(2), params(3), params(4), ...
    y_fe_d, y_re_d)).^2)));

initial_guess = [0.5, 0.5, -.4, 4];

%upper and lower bounds
lb = [0, 0, -1, -Inf];
ub = [1, 1, Inf, Inf];

% Equality constraints: sum of beta parameters should equal 1
Aeq = [1, 1, 0, 0];
beq = 1;

options = optimoptions('fmincon', 'Algorithm', 'sqp', 'Display', 'iter','MaxFunctionEvaluations', 2000);

[estimated_params, fval] = fmincon(objective, initial_guess, [], [], Aeq, beq, lb, ub, [], options);

disp('Estimated parameters: beta_fe beta_re rho_e gamma_e');
disp(estimated_params);

% Bootstrapping for confidence intervals
bootstrap_params = zeros(num_bootstrap, length(initial_guess));

parfor i = 1:num_bootstrap
    % Resample data with replacement
    stream = RandStream('CombRecursive', 'Seed', seeds(i));
    RandStream.setGlobalStream(stream);
    % Resample data with replacement
    idx = randsample(length(Y_d), length(Y_d), true);
    Y_d_boot = Y_d(idx);
    y_fe_d_boot = y_fe_d(idx);
    y_re_d_boot = y_re_d(idx);
    
    % Define objective function for bootstrapped data
    objective_boot = @(params) .5*sqrt((sum((Y_d_boot - ces_func(params(1), params(2), params(3), params(4), ...
        y_fe_d_boot, y_re_d_boot)).^2)));
    
    % Optimize for bootstrapped data
    [bootstrap_params(i, :), ~] = fmincon(objective_boot, initial_guess, [], [], Aeq, beq, lb, ub, [], options);
end

second_layer_bootstrap_table = array2table(bootstrap_params, 'VariableNames', {'beta_fe', 'beta_re', 'rho_e', 'gamma_e'});

means = mean(bootstrap_params); 

% Display standard errors and confidence intervals
disp('Mean Values');
disp(means);

% Calculate standard errors
std_error = std(bootstrap_params);

% Calculate confidence intervals
lower_bound = prctile(bootstrap_params, 2.5);
upper_bound = prctile(bootstrap_params, 97.5);

% Display standard errors and confidence intervals
disp('Standard Errors:');
disp(std_error);

% Display confidence intervals
disp('Confidence Intervals:');
for i = 1:length(estimated_params)
    fprintf('Parameter %d: [%f, %f]\n', i, lower_bound(i), upper_bound(i));
end

% Compute predicted values using estimated parameters
predicted_Y = ces_func(estimated_params(1), estimated_params(2),estimated_params(3), estimated_params(4),...
    y_fe_d, y_re_d);

% Calculate residuals
residuals = Y_d - predicted_Y;

% Calculate Mean Squared Error (MSE)
MSE = mean(residuals.^2);

% Display MSE
disp('Mean Squared Error:');
disp(MSE);

elasticity = 1/(1+means(1,3));

disp('Elasticity'); 
disp(elasticity);

means = [means, MSE];

std_error = [std_error, NaN];

var_names = {'fossil_energy', 'renew_energy', 'rho_e', 'gamma_e', 'MSE'};

bootstrap_summary = table( ...
    means', ...
    std_error', ...
    'VariableNames', {'Mean', 'StandardDeviation'}, ...
    'RowNames', var_names);

output_file = fullfile(cd, "second_layer_sqp.xlsx");

writetable(bootstrap_summary, output_file, ...
    'Sheet', 'Bootstrap Summary', ...
    'WriteRowNames', true);