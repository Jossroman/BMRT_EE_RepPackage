function [T_order, T] = dynamic_g1_tt(y, x, params, steady_state, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = Fossil_SCC_Hybrid.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
T_order = 1;
if size(T, 1) < 27
    T = [T; NaN(27 - size(T, 1), 1)];
end
T(17) = y(192)/y(113);
T(18) = getPowerDeriv(y(84),1/params(28),1);
T(19) = params(10)*getPowerDeriv(y(85),T(6),1);
T(20) = params(10)*getPowerDeriv(y(85),T(8),1);
T(21) = getPowerDeriv(T(10),params(28)/(params(28)-1),1);
T(22) = params(11)*getPowerDeriv(y(86),T(6),1);
T(23) = params(11)*getPowerDeriv(y(86),T(8),1);
T(24) = params(12)*getPowerDeriv(y(87),T(6),1);
T(25) = params(12)*getPowerDeriv(y(87),T(8),1);
T(26) = (-(y(82)*y(192)))/(y(113)*y(113));
T(27) = y(82)/y(113);
end
