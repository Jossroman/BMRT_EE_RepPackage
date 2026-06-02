function [T_order, T] = dynamic_resid_tt(y, x, params, steady_state, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 16
    T = [T; NaN(16 - size(T, 1), 1)];
end
T(1) = y(82)*y(192)/y(113);
T(2) = (1-params(31))*y(195)+params(41)*params(40)*y(180)*y(199);
T(3) = params(41)*params(40)*y(180)*y(199)+(1-params(32))*y(196);
T(4) = params(41)*params(40)*y(180)*y(199)+(1-params(33))*y(197);
T(5) = params(41)*params(40)*y(180)*y(199)+(1-params(34))*y(198);
T(6) = (-1)/params(28);
T(7) = y(84)^(1/params(28));
T(8) = (params(28)-1)/params(28);
T(9) = params(9)^T(8);
T(10) = params(12)*y(87)^T(8)+params(10)*y(85)^T(8)+params(11)*y(86)^T(8);
T(11) = params(10)*y(85)^T(6);
T(12) = params(11)*y(86)^T(6);
T(13) = params(12)*y(87)^T(6);
T(14) = exp(params(42)*params(13)*y(19)+params(42)*params(14)*y(76)+params(42)*params(15)*y(77)+params(42)*params(16)*y(78)+params(42)*params(17)*y(79));
T(15) = exp(y(19)*params(42)*params(18)+params(42)*params(19)*y(76)+params(42)*params(20)*y(77)+params(42)*params(21)*y(78)+params(42)*params(22)*y(79));
T(16) = exp(y(19)*params(42)*params(23)+params(42)*params(24)*y(76)+params(42)*params(25)*y(77)+params(42)*params(26)*y(78)+params(42)*params(27)*y(79));
end
