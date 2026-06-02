function [T_order, T] = static_g1_tt(y, x, params, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = Fossil_SCC_Hybrid.sparse.static_resid_tt(y, x, params, T_order, T);
T_order = 1;
if size(T, 1) < 13
    T = [T; NaN(13 - size(T, 1), 1)];
end
T(12) = getPowerDeriv(y(5),1/params(28),1);
T(13) = getPowerDeriv(T(11),params(28)/(params(28)-1),1);
end
