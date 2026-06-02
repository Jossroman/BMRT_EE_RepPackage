function [T_order, T] = dynamic_g2_tt(y, x, params, steady_state, T_order, T)
if T_order >= 2
    return
end
[T_order, T] = NC_SCC_Hybrid.sparse.dynamic_g1_tt(y, x, params, steady_state, T_order, T);
T_order = 2;
if size(T, 1) < 91
    T = [T; NaN(91 - size(T, 1), 1)];
end
T(82) = (-y(409))/(y(241)*y(241));
T(83) = 1/y(241);
T(84) = (-((-(y(175)*y(409)))*(y(241)+y(241))))/(y(241)*y(241)*y(241)*y(241));
T(85) = (-y(175))/(y(241)*y(241));
T(86) = getPowerDeriv(y(177),1/params(86),2);
T(87) = getPowerDeriv(y(180),1/params(87),2);
T(88) = getPowerDeriv(y(181),1/params(88),2);
T(89) = getPowerDeriv(T(28),params(86)/(params(86)-1),2);
T(90) = getPowerDeriv(T(29),params(87)/(params(87)-1),2);
T(91) = getPowerDeriv(T(30),params(88)/(params(88)-1),2);
end
