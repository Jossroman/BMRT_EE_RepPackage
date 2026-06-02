function [T_order, T] = static_resid_tt(y, x, params, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 40
    T = [T; NaN(40 - size(T, 1), 1)];
end
T(1) = exp(params(101)*params(38)*y(43)+params(101)*params(39)*y(165)+params(101)*params(40)*y(166)+params(101)*params(41)*y(167)+params(101)*params(42)*y(168));
T(2) = exp(y(43)*params(101)*params(43)+y(165)*params(101)*params(44)+y(166)*params(101)*params(45)+y(167)*params(101)*params(46)+y(168)*params(101)*params(47));
T(3) = exp(y(43)*params(101)*params(48)+y(165)*params(101)*params(49)+y(166)*params(101)*params(50)+y(167)*params(101)*params(51)+y(168)*params(101)*params(52));
T(4) = exp(y(43)*params(101)*params(53)+y(165)*params(101)*params(54)+y(166)*params(101)*params(55)+y(167)*params(101)*params(56)+y(168)*params(101)*params(57));
T(5) = exp(y(43)*params(101)*params(58)+y(165)*params(101)*params(59)+y(166)*params(101)*params(60)+y(167)*params(101)*params(61)+y(168)*params(101)*params(62));
T(6) = exp(y(43)*params(101)*params(63)+y(165)*params(101)*params(64)+y(166)*params(101)*params(65)+y(167)*params(101)*params(66)+y(168)*params(101)*params(67));
T(7) = exp(y(43)*params(101)*params(68)+y(165)*params(101)*params(69)+y(166)*params(101)*params(70)+y(167)*params(101)*params(71)+y(168)*params(101)*params(72));
T(8) = exp(y(43)*params(101)*params(73)+y(165)*params(101)*params(74)+y(166)*params(101)*params(75)+y(167)*params(101)*params(76)+y(168)*params(101)*params(77));
T(9) = exp(y(43)*params(101)*params(78)+y(165)*params(101)*params(79)+y(166)*params(101)*params(80)+y(167)*params(101)*params(81)+y(168)*params(101)*params(82));
T(10) = (params(86)-1)/params(86);
T(11) = params(83)^T(10);
T(12) = y(9)^(1/params(86));
T(13) = (-1)/params(86);
T(14) = params(28)*y(11)^T(13);
T(15) = params(27)*y(10)^T(13);
T(16) = params(35)*y(18)^T(13);
T(17) = params(36)*y(19)^T(13);
T(18) = params(37)*y(20)^T(13);
T(19) = params(29)*y(12)^T(13);
T(20) = (-1)/params(87);
T(21) = y(13)^T(20);
T(22) = y(82)*params(30)*T(21);
T(23) = y(12)^(1/params(87));
T(24) = (params(87)-1)/params(87);
T(25) = params(84)^T(24);
T(26) = y(17)^T(20);
T(27) = y(82)*params(34)*T(26);
T(28) = (-1)/params(88);
T(29) = y(14)^T(28);
T(30) = y(83)*params(31)*T(29);
T(31) = y(13)^(1/params(88));
T(32) = (params(88)-1)/params(88);
T(33) = params(85)^T(32);
T(34) = y(15)^T(28);
T(35) = y(83)*params(32)*T(34);
T(36) = y(16)^T(28);
T(37) = y(83)*params(33)*T(36);
T(38) = params(27)*y(10)^T(10)+params(28)*y(11)^T(10)+params(29)*y(12)^T(10)+params(35)*y(18)^T(10)+params(36)*y(19)^T(10)+params(37)*y(20)^T(10);
T(39) = params(30)*y(13)^T(24)+params(34)*y(17)^T(24);
T(40) = params(31)*y(14)^T(32)+params(32)*y(15)^T(32)+params(33)*y(16)^T(32);
end
