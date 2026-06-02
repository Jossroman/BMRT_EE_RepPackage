close all; clear; clc; 
num_bootstrap = 1000; 
% Ensure reproducibility for parfor
rng(0, 'combRecursive');  % Sets global seed

% Pre-generate random seeds for each bootstrap
seeds = randi(1e9, num_bootstrap, 1);

syms pk ecosystem cropland min energy rho beta_1 beta_2 beta_3 beta_4 beta_5 gamma beta_6 labour upsilon

ces = log(gamma) - (upsilon/rho)*log(beta_1*(pk)^(-rho) + beta_2*ecosystem^(-rho) + beta_3*cropland^(-rho) + beta_4*min^(-rho) + (beta_5)*energy^(-rho) + (1-beta_1 - beta_2 - beta_3 - beta_4 - beta_5)*labour^(-rho)); 

parameters = [beta_1, beta_2, beta_3, beta_4, beta_5, beta_6, rho, gamma, upsilon];
data_variables = [pk, ecosystem, cropland, min, energy, labour];
ces_func = matlabFunction(ces, 'Vars', [parameters, data_variables]);

data = readtable("C:\Users\adity\Dropbox\Adi-Simone-Ghassane\Natural Capital\Cleaned Files\matlab_data_nomin_noene.xlsx");

pk_d = data.pk_n;
ecosystem_d = data.for_notim_n;
cropland_d = data.cropland_n;
min_d = data.min_n;
energy_d = data.ene_n;
labour_d = data.hc_n;
Y_d = data.ln_gdp;

objective = @(params) 0.5*sqrt(sum((Y_d - ces_func(params(1), params(2), params(3), params(4), params(5), params(6), params(7), params(8), params(9),...
    pk_d, ecosystem_d, cropland_d, min_d, energy_d, labour_d)).^2));

initial_guess = [.4, .05, .1, .05, .2, .1, -0.3, 0.333, 1];

%upper and lower bounds
lb = [0, 0, 0, 0, 0, 0,-1, -Inf, 0];
ub = [1, 1, 1, 1, 1, 1, Inf, Inf, Inf];

% Equality constraints: sum of beta parameters should equal 1
Aeq = [1, 1, 1, 1, 1, 1, 0, 0, 0];
beq = 1;

options = optimoptions('fmincon', 'Algorithm', 'sqp', 'Display', 'iter');

[estimated_params, fval] = fmincon(objective, initial_guess, [], [], Aeq, beq, lb, ub, [], options);

disp('Estimated parameters:');
disp(estimated_params);

% Bootstrapping for confidence intervals
bootstrap_params = zeros(num_bootstrap, length(initial_guess));

parfor i = 1:num_bootstrap
    % Resample data with replacement
    stream = RandStream('CombRecursive', 'Seed', seeds(i));
    RandStream.setGlobalStream(stream);
    idx = randsample(length(Y_d), length(Y_d), true);
    Y_d_boot = Y_d(idx);
    pk_d_boot = pk_d(idx);
    ecosystem_d_boot = ecosystem_d(idx);
    cropland_d_boot = cropland_d(idx);
    min_d_boot = min_d(idx);
    energy_d_boot = energy_d(idx);
    labour_d_boot = labour_d(idx);
    
    % Define objective function for bootstrapped data
    objective_boot = @(params) 0.5*sqrt(sum((Y_d_boot - ces_func(params(1), params(2), params(3), params(4), params(5), params(6), params(7), params(8), params(9),...
        pk_d_boot, ecosystem_d_boot, cropland_d_boot, min_d_boot, energy_d_boot, labour_d_boot)).^2));
    
    % Optimize for bootstrapped data
    [bootstrap_params(i, :), ~] = fmincon(objective_boot, initial_guess, [], [], Aeq, beq, lb, ub, [], options);
end

first_layer_bootstrap_table = array2table(bootstrap_params, 'VariableNames', {'beta_1', 'beta_2', 'beta_3', 'beta_4', 'beta_5', 'beta_6', 'rho', 'gamma', 'upsilon'});

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
predicted_Y = ces_func(estimated_params(1), estimated_params(2), estimated_params(3), estimated_params(4), estimated_params(5), estimated_params(6), estimated_params(7), estimated_params(8), estimated_params(9),...
    pk_d, ecosystem_d, cropland_d, min_d, energy_d, labour_d);

% Calculate residuals
residuals = Y_d - predicted_Y;

% Calculate Mean Squared Error (MSE)
MSE = mean(residuals.^2);

% Display MSE
disp('Mean Squared Error:');
disp(MSE);

elasticity = 1/(1+means(1,7));

disp('Elasticity'); 
disp(elasticity);

means = [means, MSE];

std_error = [std_error, NaN];

var_names = {'pk', 'ecosystem', 'cropland', 'min', 'energy', ...
             'labour', 'rho', 'gamma', 'upsilon', 'MSE'};

bootstrap_summary = table( ...
    means', ...
    std_error', ...
    'VariableNames', {'Mean', 'StandardDeviation'}, ...
    'RowNames', var_names);

cd = cd;

output_file = fullfile(cd, "first_layer_upsilon_sqp.xlsx");

writetable(bootstrap_summary, output_file, ...
    'Sheet', 'Bootstrap Summary', ...
    'WriteRowNames', true);