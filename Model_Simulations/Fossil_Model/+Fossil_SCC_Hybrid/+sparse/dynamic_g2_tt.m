function [T_order, T] = dynamic_g2_tt(y, x, params, steady_state, T_order, T)
if T_order >= 2
    return
end
[T_order, T] = Fossil_SCC_Hybrid.sparse.dynamic_g1_tt(y, x, params, steady_state, T_order, T);
T_order = 2;
if size(T, 1) < 33
    T = [T; NaN(33 - size(T, 1), 1)];
end
T(28) = (-y(192))/(y(113)*y(113));
T(29) = 1/y(113);
T(30) = (-((-(y(82)*y(192)))*(y(113)+y(113))))/(y(113)*y(113)*y(113)*y(113));
T(31) = (-y(82))/(y(113)*y(113));
T(32) = getPowerDeriv(y(84),1/params(28),2);
T(33) = getPowerDeriv(T(10),params(28)/(params(28)-1),2);
end
