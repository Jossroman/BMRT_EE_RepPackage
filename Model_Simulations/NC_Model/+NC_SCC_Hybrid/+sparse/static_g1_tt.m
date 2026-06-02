function [T_order, T] = static_g1_tt(y, x, params, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = NC_SCC_Hybrid.sparse.static_resid_tt(y, x, params, T_order, T);
T_order = 1;
if size(T, 1) < 46
    T = [T; NaN(46 - size(T, 1), 1)];
end
T(41) = getPowerDeriv(y(9),1/params(86),1);
T(42) = getPowerDeriv(T(38),params(86)/(params(86)-1),1);
T(43) = getPowerDeriv(y(12),1/params(87),1);
T(44) = getPowerDeriv(y(13),1/params(88),1);
T(45) = getPowerDeriv(T(39),params(87)/(params(87)-1),1);
T(46) = getPowerDeriv(T(40),params(88)/(params(88)-1),1);
end
