function residual = static_resid(T, y, x, params, T_flag)
% function residual = static_resid(T, y, x, params, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T         [#temp variables by 1]  double   vector of temporary terms to be filled by function
%   y         [M_.endo_nbr by 1]      double   vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1]       double   vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1]     double   vector of parameter values in declaration order
%                                              to evaluate the model
%   T_flag    boolean                 boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   residual
%

if T_flag
    T = Fossil_SCC_Hybrid.static_resid_tt(T, y, x, params);
end
residual = zeros(79, 1);
    residual(1) = (y(3)) - (params(29)*(1+y(2))^(1-params(30)));
    residual(2) = (y(24)) - (y(3)*y(24)+y(4)^(1-params(30))/(1-params(30)));
residual(3) = y(13);
    residual(4) = (y(34)) - (y(4)^(-params(30)));
residual(5) = y(33);
    residual(6) = (y(25)) - (T(1));
    residual(7) = (y(26)) - (T(2));
    residual(8) = (y(27)) - (T(3));
    residual(9) = (y(20)) - (y(1)*params(1)*y(8));
    residual(10) = (y(19)) - (y(19)+y(22)*params(40)*(params(41)*y(14)-y(19))+log(y(23)));
    residual(11) = (y(14)) - (params(39)+y(15)+y(16)+y(17)+y(18));
    residual(12) = (y(15)) - (y(15)*(1-params(31))+y(20)*params(35));
    residual(13) = (y(16)) - (y(16)*(1-params(32))+y(20)*params(36));
    residual(14) = (y(17)) - (y(17)*(1-params(33))+y(20)*params(37));
    residual(15) = (y(18)) - (y(18)*(1-params(34))+y(20)*params(38));
    residual(16) = (y(36)) - (y(22)*params(40)*params(41)*y(41));
    residual(17) = (y(37)) - (y(3)*(y(22)*params(40)*params(41)*y(41)+(1-params(31))*y(37)));
    residual(18) = (y(38)) - (y(3)*(y(22)*params(40)*params(41)*y(41)+(1-params(32))*y(38)));
    residual(19) = (y(39)) - (y(3)*(y(22)*params(40)*params(41)*y(41)+(1-params(33))*y(39)));
    residual(20) = (y(40)) - (y(3)*(y(22)*params(40)*params(41)*y(41)+(1-params(34))*y(40)));
    residual(21) = (y(41)) - (y(41)*y(43)*(1-y(22)*params(40))-(y(43)*y(8)*params(23)*params(42)*y(30)+y(44)*params(24)*params(42)*y(48)*y(49)+y(45)*params(25)*params(42)*y(50)*y(51)+y(46)*params(26)*params(42)*y(52)*y(53)+y(47)*params(27)*params(42)*y(54)*y(55))-(y(43)*params(13)*params(42)*y(29)*y(7)+y(44)*params(14)*params(42)*y(56)*y(57)+y(45)*params(15)*params(42)*y(58)*y(59)+y(46)*params(16)*params(42)*y(60)*y(61)+y(47)*params(17)*params(42)*y(62)*y(63))-(y(43)*params(18)*params(42)*y(28)*y(6)+y(44)*params(19)*params(42)*y(64)*y(65)+y(45)*params(20)*params(42)*y(66)*y(67)+y(46)*params(21)*params(42)*y(68)*y(69)+y(47)*params(22)*params(42)*y(70)*y(71)));
    residual(22) = (y(43)) - (params(29));
    residual(23) = (y(44)) - (y(43)*params(29)*y(72)/y(34));
    residual(24) = (y(45)) - (y(44)*params(29)*y(73)/y(72));
    residual(25) = (y(46)) - (y(45)*params(29)*y(74)/y(73));
    residual(26) = (y(47)) - (y(46)*params(29)*y(75)/y(74));
    residual(27) = (y(42)) - (y(1)*(params(35)*y(37)+params(36)*y(38)+params(37)*y(39)+params(38)*y(40)));
    residual(28) = ((1+y(2))*y(11)) - (params(50)+y(11)*(1-params(5))+params(3)*y(9));
    residual(29) = (y(8)) - (y(27)*y(11)*params(7));
    residual(30) = ((1+y(2))*y(31)) - (y(3)*((1-params(5))*y(31)+y(30)*y(27)*params(7)));
    residual(31) = ((1+y(2))*y(12)) - (params(50)+y(12)*(1-params(6))+params(4)*y(10));
    residual(32) = (y(7)) - (y(25)*y(12)*params(8));
    residual(33) = ((1+y(2))*y(32)) - (y(3)*((1-params(6))*y(32)+y(29)*y(25)*params(8)));
    residual(34) = (y(6)) - (y(26)*y(21)*params(43)*params(2));
    residual(35) = (y(31)) - (1/params(3));
    residual(36) = (y(32)) - (1/params(4));
    residual(37) = (y(28)) - (T(5)*T(6)*T(8));
    residual(38) = (y(29)) - (T(5)*T(6)*T(9));
    residual(39) = (y(30)) - (T(5)*T(6)*T(10)-params(1)*y(42));
    residual(40) = (y(5)) - (params(9)*T(11)^(params(28)/(params(28)-1)));
    residual(41) = (y(35)) - (1);
    residual(42) = (y(5)) - (y(10)+y(4)+y(9));
    residual(43) = (y(1)) - ((1+y(2))*y(1));
    residual(44) = (y(2)) - (y(2)*(1-params(48)));
    residual(45) = (log(y(21))) - (log(y(21))*params(46)+x(1));
    residual(46) = (log(y(22))) - (log(y(22))*params(47)+x(2));
    residual(47) = (log(y(23))) - (log(y(23))*params(47)+x(3));
    residual(48) = (y(48)) - (y(30));
    residual(49) = (y(49)) - (y(8));
    residual(50) = (y(50)) - (y(48));
    residual(51) = (y(51)) - (y(49));
    residual(52) = (y(52)) - (y(50));
    residual(53) = (y(53)) - (y(51));
    residual(54) = (y(54)) - (y(52));
    residual(55) = (y(55)) - (y(53));
    residual(56) = (y(56)) - (y(29));
    residual(57) = (y(57)) - (y(7));
    residual(58) = (y(58)) - (y(56));
    residual(59) = (y(59)) - (y(57));
    residual(60) = (y(60)) - (y(58));
    residual(61) = (y(61)) - (y(59));
    residual(62) = (y(62)) - (y(60));
    residual(63) = (y(63)) - (y(61));
    residual(64) = (y(64)) - (y(28));
    residual(65) = (y(65)) - (y(6));
    residual(66) = (y(66)) - (y(64));
    residual(67) = (y(67)) - (y(65));
    residual(68) = (y(68)) - (y(66));
    residual(69) = (y(69)) - (y(67));
    residual(70) = (y(70)) - (y(68));
    residual(71) = (y(71)) - (y(69));
    residual(72) = (y(72)) - (y(34));
    residual(73) = (y(73)) - (y(72));
    residual(74) = (y(74)) - (y(73));
    residual(75) = (y(75)) - (y(74));
    residual(76) = (y(76)) - (y(19));
    residual(77) = (y(77)) - (y(76));
    residual(78) = (y(78)) - (y(77));
    residual(79) = (y(79)) - (y(78));

end
