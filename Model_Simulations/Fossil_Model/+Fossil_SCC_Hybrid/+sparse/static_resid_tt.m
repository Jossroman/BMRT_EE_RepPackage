function [T_order, T] = static_resid_tt(y, x, params, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 11
    T = [T; NaN(11 - size(T, 1), 1)];
end
T(1) = exp(params(42)*params(13)*y(19)+params(42)*params(14)*y(76)+params(42)*params(15)*y(77)+params(42)*params(16)*y(78)+params(42)*params(17)*y(79));
T(2) = exp(y(19)*params(42)*params(18)+y(76)*params(42)*params(19)+y(77)*params(42)*params(20)+y(78)*params(42)*params(21)+y(79)*params(42)*params(22));
T(3) = exp(y(19)*params(42)*params(23)+y(76)*params(42)*params(24)+y(77)*params(42)*params(25)+y(78)*params(42)*params(26)+y(79)*params(42)*params(27));
T(4) = (params(28)-1)/params(28);
T(5) = params(9)^T(4);
T(6) = y(5)^(1/params(28));
T(7) = (-1)/params(28);
T(8) = params(10)*y(6)^T(7);
T(9) = params(11)*y(7)^T(7);
T(10) = params(12)*y(8)^T(7);
T(11) = params(12)*y(8)^T(4)+params(10)*y(6)^T(4)+params(11)*y(7)^T(4);
end
