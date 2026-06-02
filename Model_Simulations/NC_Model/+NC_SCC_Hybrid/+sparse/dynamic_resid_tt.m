function [T_order, T] = dynamic_resid_tt(y, x, params, steady_state, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 45
    T = [T; NaN(45 - size(T, 1), 1)];
end
T(1) = y(175)*y(409)/y(241);
T(2) = (1-params(90))*y(412)+params(99)*params(98)*y(340)*y(416);
T(3) = params(99)*params(98)*y(340)*y(416)+(1-params(91))*y(413);
T(4) = params(99)*params(98)*y(340)*y(416)+(1-params(92))*y(414);
T(5) = params(99)*params(98)*y(340)*y(416)+(1-params(93))*y(415);
T(6) = (-1)/params(86);
T(7) = y(177)^(1/params(86));
T(8) = (params(86)-1)/params(86);
T(9) = params(83)^T(8);
T(10) = (-1)/params(87);
T(11) = y(181)^T(10);
T(12) = y(250)*params(30)*T(11);
T(13) = y(180)^(1/params(87));
T(14) = (params(87)-1)/params(87);
T(15) = params(84)^T(14);
T(16) = y(185)^T(10);
T(17) = y(250)*params(34)*T(16);
T(18) = (-1)/params(88);
T(19) = y(182)^T(18);
T(20) = y(251)*params(31)*T(19);
T(21) = y(181)^(1/params(88));
T(22) = (params(88)-1)/params(88);
T(23) = params(85)^T(22);
T(24) = y(183)^T(18);
T(25) = y(251)*params(32)*T(24);
T(26) = y(184)^T(18);
T(27) = y(251)*params(33)*T(26);
T(28) = params(27)*y(178)^T(8)+params(28)*y(179)^T(8)+params(29)*y(180)^T(8)+params(35)*y(186)^T(8)+params(36)*y(187)^T(8)+params(37)*y(188)^T(8);
T(29) = params(30)*y(181)^T(14)+params(34)*y(185)^T(14);
T(30) = params(31)*y(182)^T(22)+params(32)*y(183)^T(22)+params(33)*y(184)^T(22);
T(31) = params(28)*y(179)^T(6);
T(32) = params(27)*y(178)^T(6);
T(33) = params(35)*y(186)^T(6);
T(34) = params(36)*y(187)^T(6);
T(35) = params(37)*y(188)^T(6);
T(36) = params(29)*y(180)^T(6);
T(37) = exp(params(101)*params(38)*y(43)+params(101)*params(39)*y(165)+params(101)*params(40)*y(166)+params(101)*params(41)*y(167)+params(101)*params(42)*y(168));
T(38) = exp(y(43)*params(101)*params(43)+params(101)*params(44)*y(165)+params(101)*params(45)*y(166)+params(101)*params(46)*y(167)+params(101)*params(47)*y(168));
T(39) = exp(y(43)*params(101)*params(48)+params(101)*params(49)*y(165)+params(101)*params(50)*y(166)+params(101)*params(51)*y(167)+params(101)*params(52)*y(168));
T(40) = exp(y(43)*params(101)*params(53)+params(101)*params(54)*y(165)+params(101)*params(55)*y(166)+params(101)*params(56)*y(167)+params(101)*params(57)*y(168));
T(41) = exp(y(43)*params(101)*params(58)+params(101)*params(59)*y(165)+params(101)*params(60)*y(166)+params(101)*params(61)*y(167)+params(101)*params(62)*y(168));
T(42) = exp(y(43)*params(101)*params(63)+params(101)*params(64)*y(165)+params(101)*params(65)*y(166)+params(101)*params(66)*y(167)+params(101)*params(67)*y(168));
T(43) = exp(y(43)*params(101)*params(68)+params(101)*params(69)*y(165)+params(101)*params(70)*y(166)+params(101)*params(71)*y(167)+params(101)*params(72)*y(168));
T(44) = exp(y(43)*params(101)*params(73)+params(101)*params(74)*y(165)+params(101)*params(75)*y(166)+params(101)*params(76)*y(167)+params(101)*params(77)*y(168));
T(45) = exp(y(43)*params(101)*params(78)+params(101)*params(79)*y(165)+params(101)*params(80)*y(166)+params(101)*params(81)*y(167)+params(101)*params(82)*y(168));
end
