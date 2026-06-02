function [T_order, T] = dynamic_g1_tt(y, x, params, steady_state, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = NC_SCC_Hybrid.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
T_order = 1;
if size(T, 1) < 81
    T = [T; NaN(81 - size(T, 1), 1)];
end
T(46) = y(409)/y(241);
T(47) = getPowerDeriv(y(177),1/params(86),1);
T(48) = params(27)*getPowerDeriv(y(178),T(6),1);
T(49) = params(27)*getPowerDeriv(y(178),T(8),1);
T(50) = getPowerDeriv(T(28),params(86)/(params(86)-1),1);
T(51) = params(28)*getPowerDeriv(y(179),T(6),1);
T(52) = params(28)*getPowerDeriv(y(179),T(8),1);
T(53) = params(29)*getPowerDeriv(y(180),T(6),1);
T(54) = getPowerDeriv(y(180),1/params(87),1);
T(55) = params(29)*getPowerDeriv(y(180),T(8),1);
T(56) = getPowerDeriv(y(181),T(10),1);
T(57) = y(250)*params(30)*T(56);
T(58) = getPowerDeriv(y(181),1/params(88),1);
T(59) = params(30)*getPowerDeriv(y(181),T(14),1);
T(60) = getPowerDeriv(T(29),params(87)/(params(87)-1),1);
T(61) = getPowerDeriv(y(182),T(18),1);
T(62) = y(251)*params(31)*T(61);
T(63) = params(31)*getPowerDeriv(y(182),T(22),1);
T(64) = getPowerDeriv(T(30),params(88)/(params(88)-1),1);
T(65) = getPowerDeriv(y(183),T(18),1);
T(66) = y(251)*params(32)*T(65);
T(67) = params(32)*getPowerDeriv(y(183),T(22),1);
T(68) = getPowerDeriv(y(184),T(18),1);
T(69) = y(251)*params(33)*T(68);
T(70) = params(33)*getPowerDeriv(y(184),T(22),1);
T(71) = getPowerDeriv(y(185),T(10),1);
T(72) = y(250)*params(34)*T(71);
T(73) = params(34)*getPowerDeriv(y(185),T(14),1);
T(74) = params(35)*getPowerDeriv(y(186),T(6),1);
T(75) = params(35)*getPowerDeriv(y(186),T(8),1);
T(76) = params(36)*getPowerDeriv(y(187),T(6),1);
T(77) = params(36)*getPowerDeriv(y(187),T(8),1);
T(78) = params(37)*getPowerDeriv(y(188),T(6),1);
T(79) = params(37)*getPowerDeriv(y(188),T(8),1);
T(80) = (-(y(175)*y(409)))/(y(241)*y(241));
T(81) = y(175)/y(241);
end
