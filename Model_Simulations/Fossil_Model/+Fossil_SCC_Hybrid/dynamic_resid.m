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
    T = Fossil_SCC_Hybrid.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(79, 1);
    residual(1) = (y(20)) - (params(29)*(1+y(19))^(1-params(30)));
    residual(2) = (y(41)) - (y(20)*y(101)+y(21)^(1-params(30))/(1-params(30)));
residual(3) = y(30);
    residual(4) = (y(51)) - (y(21)^(-params(30)));
residual(5) = y(50);
    residual(6) = (y(42)) - (T(14));
    residual(7) = (y(43)) - (T(15));
    residual(8) = (y(44)) - (T(16));
    residual(9) = (y(37)) - (y(18)*params(1)*y(25));
    residual(10) = (y(36)) - (y(10)+y(39)*params(40)*(params(41)*y(5)-y(10))+log(y(40)));
    residual(11) = (y(31)) - (params(39)+y(32)+y(33)+y(34)+y(35));
    residual(12) = (y(32)) - ((1-params(31))*y(6)+y(37)*params(35));
    residual(13) = (y(33)) - ((1-params(32))*y(7)+y(37)*params(36));
    residual(14) = (y(34)) - ((1-params(33))*y(8)+y(37)*params(37));
    residual(15) = (y(35)) - ((1-params(34))*y(9)+y(37)*params(38));
    residual(16) = (y(53)) - (y(39)*params(40)*params(41)*y(58));
    residual(17) = (y(54)) - (T(1)*T(2));
    residual(18) = (y(55)) - (T(1)*T(3));
    residual(19) = (y(56)) - (T(1)*T(4));
    residual(20) = (y(57)) - (T(1)*T(5));
    residual(21) = (y(58)) - (y(114)*y(60)*(1-params(40)*y(100))-(y(60)*params(23)*params(42)*y(106)*y(99)+y(61)*params(24)*params(42)*y(115)*y(116)+y(62)*params(25)*params(42)*y(117)*y(118)+y(63)*params(26)*params(42)*y(119)*y(120)+y(64)*params(27)*params(42)*y(121)*y(122))-(y(60)*params(13)*params(42)*y(105)*y(98)+y(61)*params(14)*params(42)*y(123)*y(124)+y(62)*params(15)*params(42)*y(125)*y(126)+y(63)*params(16)*params(42)*y(127)*y(128)+y(64)*params(17)*params(42)*y(129)*y(130))-(y(60)*params(18)*params(42)*y(104)*y(97)+y(61)*params(19)*params(42)*y(131)*y(132)+y(62)*params(20)*params(42)*y(133)*y(134)+y(63)*params(21)*params(42)*y(135)*y(136)+y(64)*params(22)*params(42)*y(137)*y(138)));
    residual(22) = (y(60)) - (params(29)*y(109)/y(51));
    residual(23) = (y(61)) - (y(60)*params(29)*y(139)/y(109));
    residual(24) = (y(62)) - (y(61)*params(29)*y(140)/y(139));
    residual(25) = (y(63)) - (y(62)*params(29)*y(141)/y(140));
    residual(26) = (y(64)) - (y(63)*params(29)*y(142)/y(141));
    residual(27) = (y(59)) - (y(18)*(params(35)*y(54)+params(36)*y(55)+params(37)*y(56)+params(38)*y(57)));
    residual(28) = ((1+y(19))*y(28)) - (params(50)+(1-params(5))*y(3)+params(3)*y(26));
    residual(29) = (y(25)) - (y(44)*y(3)*params(7));
    residual(30) = ((1+y(19))*y(48)) - (T(1)*((1-params(5))*y(107)+y(106)*params(7)*y(103)));
    residual(31) = ((1+y(19))*y(29)) - (params(50)+(1-params(6))*y(4)+params(4)*y(27));
    residual(32) = (y(24)) - (y(42)*y(4)*params(8));
    residual(33) = ((1+y(19))*y(49)) - (T(1)*((1-params(6))*y(108)+y(105)*params(8)*y(102)));
    residual(34) = (y(23)) - (y(43)*y(38)*params(43)*params(2));
    residual(35) = (y(48)) - (1/params(3));
    residual(36) = (y(49)) - (1/params(4));
    residual(37) = (y(45)) - (T(9)*T(7)*T(11));
    residual(38) = (y(46)) - (T(9)*T(7)*T(12));
    residual(39) = (y(47)) - (T(9)*T(7)*T(13)-params(1)*y(59));
    residual(40) = (y(22)) - (params(9)*T(10)^(params(28)/(params(28)-1)));
    residual(41) = (y(52)) - (1);
    residual(42) = (y(22)) - (y(27)+y(21)+y(26));
    residual(43) = (y(18)) - (y(1)*(1+y(2)));
    residual(44) = (y(19)) - (y(2)*(1-params(48)));
    residual(45) = (log(y(38))) - (params(46)*log(y(11))+x(it_, 1));
    residual(46) = (log(y(39))) - (params(47)*log(y(12))+x(it_, 2));
    residual(47) = (log(y(40))) - (params(47)*log(y(13))+x(it_, 3));
    residual(48) = (y(65)) - (y(106));
    residual(49) = (y(66)) - (y(99));
    residual(50) = (y(67)) - (y(115));
    residual(51) = (y(68)) - (y(116));
    residual(52) = (y(69)) - (y(117));
    residual(53) = (y(70)) - (y(118));
    residual(54) = (y(71)) - (y(119));
    residual(55) = (y(72)) - (y(120));
    residual(56) = (y(73)) - (y(105));
    residual(57) = (y(74)) - (y(98));
    residual(58) = (y(75)) - (y(123));
    residual(59) = (y(76)) - (y(124));
    residual(60) = (y(77)) - (y(125));
    residual(61) = (y(78)) - (y(126));
    residual(62) = (y(79)) - (y(127));
    residual(63) = (y(80)) - (y(128));
    residual(64) = (y(81)) - (y(104));
    residual(65) = (y(82)) - (y(97));
    residual(66) = (y(83)) - (y(131));
    residual(67) = (y(84)) - (y(132));
    residual(68) = (y(85)) - (y(133));
    residual(69) = (y(86)) - (y(134));
    residual(70) = (y(87)) - (y(135));
    residual(71) = (y(88)) - (y(136));
    residual(72) = (y(89)) - (y(109));
    residual(73) = (y(90)) - (y(139));
    residual(74) = (y(91)) - (y(140));
    residual(75) = (y(92)) - (y(141));
    residual(76) = (y(93)) - (y(10));
    residual(77) = (y(94)) - (y(14));
    residual(78) = (y(95)) - (y(15));
    residual(79) = (y(96)) - (y(16));

end
