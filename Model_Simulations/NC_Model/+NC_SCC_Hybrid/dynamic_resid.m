function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
% function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double   vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double   vector of endogenous variables in the order stored
%                                                     in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double   matrix of exogenous variables (in declaration order)
%                                                     for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double   vector of steady state values
%   params        [M_.param_nbr by 1]        double   vector of parameter values in declaration order
%   it_           scalar                     double   time period for exogenous variables for which
%                                                     to evaluate the model
%   T_flag        boolean                    boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   residual
%

if T_flag
    T = NC_SCC_Hybrid.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(168, 1);
    residual(1) = (y(31)) - (params(106)*(1+y(26))^(1-params(89)));
    residual(2) = (y(69)) - (y(31)*y(203)+y(32)^(1-params(89))/(1-params(89)));
residual(3) = y(61);
    residual(4) = (y(97)) - (y(32)^(-params(89)));
residual(5) = y(96);
    residual(6) = (y(70)) - (T(37));
    residual(7) = (y(72)) - (T(38));
    residual(8) = (y(74)) - (T(39));
    residual(9) = (y(76)) - (T(40));
    residual(10) = (y(78)) - (T(41));
    residual(11) = (y(80)) - (T(42));
    residual(12) = (y(82)) - (T(43));
    residual(13) = (y(84)) - (T(44));
    residual(14) = (y(86)) - (T(45));
    residual(15) = (y(68)) - (y(25)*params(1)*y(37));
    residual(16) = (y(67)) - (y(20)+y(28)*params(98)*(params(99)*y(15)-y(20))+log(y(29)));
    residual(17) = (y(62)) - (params(100)+y(63)+y(64)+y(65)+y(66));
    residual(18) = (y(63)) - ((1-params(90))*y(16)+y(68)*params(94));
    residual(19) = (y(64)) - ((1-params(91))*y(17)+y(68)*params(95));
    residual(20) = (y(65)) - ((1-params(92))*y(18)+y(68)*params(96));
    residual(21) = (y(66)) - ((1-params(93))*y(19)+y(68)*params(97));
    residual(22) = (y(99)) - (y(28)*params(98)*params(99)*y(104));
    residual(23) = (y(100)) - (T(1)*T(2));
    residual(24) = (y(101)) - (T(1)*T(3));
    residual(25) = (y(102)) - (T(1)*T(4));
    residual(26) = (y(103)) - (T(1)*T(5));
    residual(27) = (y(104)) - (y(234)*y(108)*(1-params(98)*y(193))-(y(108)*params(78)*params(101)*y(220)*y(202)+y(108)*params(73)*params(101)*y(218)*y(201)+y(108)*params(68)*params(101)*y(216)*y(200)+y(108)*params(63)*params(101)*y(214)*y(199)+y(108)*params(58)*params(101)*y(212)*y(198)+y(108)*params(53)*params(101)*y(210)*y(197)+y(108)*params(48)*params(101)*y(208)*y(196)+y(108)*params(38)*params(101)*y(205)*y(194)+y(109)*params(39)*params(101)*y(235)*y(236)+y(110)*params(40)*params(101)*y(237)*y(238)+y(111)*params(41)*params(101)*y(239)*y(240)+y(112)*params(42)*params(101)*y(241)*y(242)+y(109)*params(49)*params(101)*y(243)*y(244)+y(110)*params(50)*params(101)*y(245)*y(246)+y(111)*params(51)*params(101)*y(247)*y(248)+y(112)*params(52)*params(101)*y(249)*y(250)+y(109)*params(54)*params(101)*y(251)*y(252)+y(110)*params(55)*params(101)*y(253)*y(254)+y(111)*params(56)*params(101)*y(255)*y(256)+y(112)*params(57)*params(101)*y(257)*y(258)+y(109)*params(59)*params(101)*y(259)*y(260)+y(110)*params(60)*params(101)*y(261)*y(262)+y(111)*params(61)*params(101)*y(263)*y(264)+y(112)*params(62)*params(101)*y(265)*y(266)+y(109)*params(64)*params(101)*y(267)*y(268)+y(110)*params(65)*params(101)*y(269)*y(270)+y(111)*params(66)*params(101)*y(271)*y(272)+y(112)*params(67)*params(101)*y(273)*y(274)+y(109)*params(69)*params(101)*y(275)*y(276)+y(110)*params(70)*params(101)*y(277)*y(278)+y(111)*params(71)*params(101)*y(279)*y(280)+y(112)*params(72)*params(101)*y(281)*y(282)+y(109)*params(74)*params(101)*y(283)*y(284)+y(110)*params(75)*params(101)*y(285)*y(286)+y(111)*params(76)*params(101)*y(287)*y(288)+y(112)*params(77)*params(101)*y(289)*y(290)+y(109)*params(79)*params(101)*y(291)*y(292)+y(110)*params(80)*params(101)*y(293)*y(294)+y(111)*params(81)*params(101)*y(295)*y(296)+y(112)*params(82)*params(101)*y(297)*y(298))-(y(108)*params(43)*params(101)*y(206)*y(195)+y(109)*params(44)*params(101)*y(299)*y(300)+y(110)*params(45)*params(101)*y(301)*y(302)+y(111)*params(46)*params(101)*y(303)*y(304)+y(112)*params(47)*params(101)*y(305)*y(306)));
    residual(28) = (y(108)) - (T(1));
    residual(29) = (y(109)) - (y(108)*y(31)*y(307)/y(229));
    residual(30) = (y(110)) - (y(109)*y(31)*y(308)/y(307));
    residual(31) = (y(111)) - (y(110)*y(31)*y(309)/y(308));
    residual(32) = (y(112)) - (y(111)*y(31)*y(310)/y(309));
    residual(33) = (y(105)) - (y(25)*(params(94)*y(100)+params(95)*y(101)+params(96)*y(102)+params(97)*y(103)));
    residual(34) = ((1+y(26))*y(46)) - (params(107)+(1-params(5))*y(7)+params(3)*y(45));
    residual(35) = (y(34)) - (y(7)*y(70)*params(4));
    residual(36) = ((1+y(26))*y(88)) - (T(1)*((1-params(5))*y(221)+y(205)*params(4)*y(204)));
    residual(37) = ((1+y(26))*y(48)) - (params(107)+(1-params(8))*y(8)+params(6)*y(47));
    residual(38) = (y(38)) - (y(8)*y(74)*params(7));
    residual(39) = ((1+y(26))*y(89)) - (T(1)*((1-params(8))*y(222)+y(208)*params(7)*y(207)));
    residual(40) = ((1+y(26))*y(50)) - (params(107)+(1-params(11))*y(9)+params(9)*y(49));
    residual(41) = (y(39)) - (y(9)*y(76)*params(10));
    residual(42) = ((1+y(26))*y(90)) - (T(1)*((1-params(11))*y(223)+y(210)*params(10)*y(209)));
    residual(43) = ((1+y(26))*y(52)) - (params(107)+(1-params(14))*y(10)+params(12)*y(51)*y(30));
    residual(44) = (y(40)) - (y(10)*y(78)*params(13));
    residual(45) = ((1+y(26))*y(91)) - (T(1)*((1-params(14))*y(224)+y(212)*params(13)*y(211)));
    residual(46) = ((1+y(26))*y(54)) - (params(107)+(1-params(17))*y(11)+params(15)*y(53));
    residual(47) = (y(41)) - (y(11)*y(80)*params(16));
    residual(48) = ((1+y(26))*y(92)) - (T(1)*((1-params(17))*y(225)+y(214)*params(16)*y(213)));
    residual(49) = ((1+y(26))*y(56)) - (params(107)+(1-params(20))*y(12)+params(18)*y(55));
    residual(50) = (y(42)) - (y(12)*y(82)*params(19));
    residual(51) = ((1+y(26))*y(93)) - (T(1)*((1-params(20))*y(226)+y(216)*params(19)*y(215)));
    residual(52) = ((1+y(26))*y(58)) - (params(107)+(1-params(23))*y(13)+params(21)*y(57));
    residual(53) = (y(43)) - (y(13)*y(84)*params(22));
    residual(54) = ((1+y(26))*y(94)) - (T(1)*((1-params(23))*y(227)+y(218)*params(22)*y(217)));
    residual(55) = ((1+y(26))*y(60)) - (params(107)+(1-params(26))*y(14)+params(24)*y(59));
    residual(56) = (y(44)) - (y(14)*y(86)*params(25));
    residual(57) = ((1+y(26))*y(95)) - (T(1)*((1-params(26))*y(228)+y(220)*params(25)*y(219)));
    residual(58) = (y(35)) - (y(72)*y(27)*params(102)*params(2));
    residual(59) = (y(88)) - (1/params(3));
    residual(60) = (y(92)) - (1/params(15));
    residual(61) = (y(93)) - (1/params(18));
    residual(62) = (y(94)) - (1/params(21));
    residual(63) = (y(95)) - (1/params(24));
    residual(64) = (y(89)) - (1/params(6));
    residual(65) = (y(90)) - (1/params(9));
    residual(66) = (y(91)) - (1/(params(12)*y(30)));
    residual(67) = (y(73)) - (T(9)*T(7)*T(31));
    residual(68) = (y(71)) - (T(9)*T(7)*T(32));
    residual(69) = (y(83)) - (T(9)*T(7)*T(33));
    residual(70) = (y(85)) - (T(9)*T(7)*T(34));
    residual(71) = (y(87)) - (T(9)*T(7)*T(35));
    residual(72) = (y(106)) - (T(9)*T(7)*T(36));
    residual(73) = (y(107)) - (T(12)*T(13)*T(15)-params(1)*y(105));
    residual(74) = (y(81)) - (T(15)*T(13)*T(17));
    residual(75) = (y(75)) - (T(20)*T(21)*T(23));
    residual(76) = (y(77)) - (T(23)*T(21)*T(25));
    residual(77) = (y(79)) - (T(23)*T(21)*T(27));
    residual(78) = (y(98)) - (1);
    residual(79) = (y(33)) - (params(83)*T(28)^(params(86)/(params(86)-1)));
    residual(80) = (y(36)) - (params(84)*T(29)^(params(87)/(params(87)-1)));
    residual(81) = (y(37)) - (params(85)*T(30)^(params(88)/(params(88)-1)));
    residual(82) = (y(33)) - (y(59)+y(57)+y(55)+y(53)+y(51)+y(49)+y(47)+y(32)+y(45));
    residual(83) = (y(25)) - (y(1)*(1+y(2)));
    residual(84) = (y(26)) - (y(2)*(1-params(105)));
    residual(85) = (log(y(27))) - (params(109)*log(y(3))+x(it_, 1));
    residual(86) = (log(y(28))) - (params(110)*log(y(4))+x(it_, 2));
    residual(87) = (log(y(29))) - (params(110)*log(y(5))+x(it_, 3));
    residual(88) = (log(y(30))) - (params(111)*log(y(6))+x(it_, 4));
    residual(89) = (y(113)) - (y(205));
    residual(90) = (y(114)) - (y(194));
    residual(91) = (y(115)) - (y(235));
    residual(92) = (y(116)) - (y(236));
    residual(93) = (y(117)) - (y(237));
    residual(94) = (y(118)) - (y(238));
    residual(95) = (y(119)) - (y(239));
    residual(96) = (y(120)) - (y(240));
    residual(97) = (y(121)) - (y(208));
    residual(98) = (y(122)) - (y(196));
    residual(99) = (y(123)) - (y(243));
    residual(100) = (y(124)) - (y(244));
    residual(101) = (y(125)) - (y(245));
    residual(102) = (y(126)) - (y(246));
    residual(103) = (y(127)) - (y(247));
    residual(104) = (y(128)) - (y(248));
    residual(105) = (y(129)) - (y(210));
    residual(106) = (y(130)) - (y(197));
    residual(107) = (y(131)) - (y(251));
    residual(108) = (y(132)) - (y(252));
    residual(109) = (y(133)) - (y(253));
    residual(110) = (y(134)) - (y(254));
    residual(111) = (y(135)) - (y(255));
    residual(112) = (y(136)) - (y(256));
    residual(113) = (y(137)) - (y(212));
    residual(114) = (y(138)) - (y(198));
    residual(115) = (y(139)) - (y(259));
    residual(116) = (y(140)) - (y(260));
    residual(117) = (y(141)) - (y(261));
    residual(118) = (y(142)) - (y(262));
    residual(119) = (y(143)) - (y(263));
    residual(120) = (y(144)) - (y(264));
    residual(121) = (y(145)) - (y(214));
    residual(122) = (y(146)) - (y(199));
    residual(123) = (y(147)) - (y(267));
    residual(124) = (y(148)) - (y(268));
    residual(125) = (y(149)) - (y(269));
    residual(126) = (y(150)) - (y(270));
    residual(127) = (y(151)) - (y(271));
    residual(128) = (y(152)) - (y(272));
    residual(129) = (y(153)) - (y(216));
    residual(130) = (y(154)) - (y(200));
    residual(131) = (y(155)) - (y(275));
    residual(132) = (y(156)) - (y(276));
    residual(133) = (y(157)) - (y(277));
    residual(134) = (y(158)) - (y(278));
    residual(135) = (y(159)) - (y(279));
    residual(136) = (y(160)) - (y(280));
    residual(137) = (y(161)) - (y(218));
    residual(138) = (y(162)) - (y(201));
    residual(139) = (y(163)) - (y(283));
    residual(140) = (y(164)) - (y(284));
    residual(141) = (y(165)) - (y(285));
    residual(142) = (y(166)) - (y(286));
    residual(143) = (y(167)) - (y(287));
    residual(144) = (y(168)) - (y(288));
    residual(145) = (y(169)) - (y(220));
    residual(146) = (y(170)) - (y(202));
    residual(147) = (y(171)) - (y(291));
    residual(148) = (y(172)) - (y(292));
    residual(149) = (y(173)) - (y(293));
    residual(150) = (y(174)) - (y(294));
    residual(151) = (y(175)) - (y(295));
    residual(152) = (y(176)) - (y(296));
    residual(153) = (y(177)) - (y(206));
    residual(154) = (y(178)) - (y(195));
    residual(155) = (y(179)) - (y(299));
    residual(156) = (y(180)) - (y(300));
    residual(157) = (y(181)) - (y(301));
    residual(158) = (y(182)) - (y(302));
    residual(159) = (y(183)) - (y(303));
    residual(160) = (y(184)) - (y(304));
    residual(161) = (y(185)) - (y(229));
    residual(162) = (y(186)) - (y(307));
    residual(163) = (y(187)) - (y(308));
    residual(164) = (y(188)) - (y(309));
    residual(165) = (y(189)) - (y(20));
    residual(166) = (y(190)) - (y(21));
    residual(167) = (y(191)) - (y(22));
    residual(168) = (y(192)) - (y(23));

end
