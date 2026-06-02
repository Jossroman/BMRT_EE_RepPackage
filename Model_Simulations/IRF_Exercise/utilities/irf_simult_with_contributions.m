function [y_, contributions] = irf_simult_with_contributions(M_, options_, y0, dr, ex_, iorder)
iter = size(ex_, 1);
endo_nbr = M_.endo_nbr;
T_full = iter + M_.maximum_lag;

y_ = zeros(size(y0, 1), T_full);
y_(:, 1) = y0;

if options_.loglinear && ~options_.logged_steady_state
    k = get_all_variables_but_lagged_leaded_exogenous(M_);
    dr.ys(k) = log(dr.ys(k));
end

if ~options_.k_order_solver || (options_.k_order_solver && options_.pruning)
    if iorder == 1
        y_(:, 1) = y_(:, 1) - dr.ys;
    end
end

if iorder ~= 1
    error('Only first-order simulations are supported.');
end

k2 = dr.kstate(dr.kstate(:, 2) <= M_.maximum_lag+1, [1 2]);
k2 = k2(:, 1) + (M_.maximum_lag + 1 - k2(:, 2)) * endo_nbr;

order_var = dr.order_var;
inv_order(order_var) = 1:length(order_var);

n_endo = length(order_var);
n_state = length(k2);

direct_contrib = zeros(n_endo, n_state + 1, T_full);
initial_contrib = zeros(endo_nbr, n_state, T_full);

if isempty(dr.ghx)
    y_(order_var, :) = dr.ghu * transpose(ex_);
    contributions.direct = [];
    contributions.initial_state = [];
    y_ = bsxfun(@plus, y_, dr.ys);
    return
end

epsilon = dr.ghu * transpose(ex_);

for t = 2:T_full
    yhat = y_(order_var(k2), t-1);
    y_(order_var, t) = dr.ghx * yhat + epsilon(:, t-1);

    for k = 1:n_state
        direct_contrib(:, k, t) = yhat(k) * dr.ghx(:, k);
    end
end

direct_contrib(:, end, 2:end) = squeeze(direct_contrib(:, end, 2:end)) + epsilon;
y_ = bsxfun(@plus, y_, dr.ys);
direct_contrib = direct_contrib(inv_order, :, :);

x0 = dr.ghu * transpose(ex_(1, :));
s0 = x0(k2);
Tmat = dr.ghx(k2, :);

for k = 1:n_state
    s_k = zeros(n_state, 1);
    s_k(k) = s0(k);
    for t = 3:T_full
        initial_contrib(:, k, t) = dr.ghx * s_k;
        s_k = Tmat * s_k;
    end
end

initial_contrib = initial_contrib(inv_order, :, :);

contributions.direct = direct_contrib;
contributions.initial_state = initial_contrib;
end
