function T = dynamic_resid_tt(T, y, x, params, steady_state, it_)
% function T = dynamic_resid_tt(T, y, x, params, steady_state, it_)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double  vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double  vector of endogenous variables in the order stored
%                                                    in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double  matrix of exogenous variables (in declaration order)
%                                                    for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double  vector of steady state values
%   params        [M_.param_nbr by 1]        double  vector of parameter values in declaration order
%   it_           scalar                     double  time period for exogenous variables for which
%                                                    to evaluate the model
%
% Output:
%   T           [#temp variables by 1]       double  vector of temporary terms
%

assert(length(T) >= 45);

T(1) = y(31)*y(229)/y(97);
T(2) = (1-params(90))*y(230)+params(99)*params(98)*y(193)*y(234);
T(3) = params(99)*params(98)*y(193)*y(234)+(1-params(91))*y(231);
T(4) = params(99)*params(98)*y(193)*y(234)+(1-params(92))*y(232);
T(5) = params(99)*params(98)*y(193)*y(234)+(1-params(93))*y(233);
T(6) = (-1)/params(86);
T(7) = y(33)^(1/params(86));
T(8) = (params(86)-1)/params(86);
T(9) = params(83)^T(8);
T(10) = (-1)/params(87);
T(11) = y(37)^T(10);
T(12) = y(106)*params(30)*T(11);
T(13) = y(36)^(1/params(87));
T(14) = (params(87)-1)/params(87);
T(15) = params(84)^T(14);
T(16) = y(41)^T(10);
T(17) = y(106)*params(34)*T(16);
T(18) = (-1)/params(88);
T(19) = y(38)^T(18);
T(20) = y(107)*params(31)*T(19);
T(21) = y(37)^(1/params(88));
T(22) = (params(88)-1)/params(88);
T(23) = params(85)^T(22);
T(24) = y(39)^T(18);
T(25) = y(107)*params(32)*T(24);
T(26) = y(40)^T(18);
T(27) = y(107)*params(33)*T(26);
T(28) = params(27)*y(34)^T(8)+params(28)*y(35)^T(8)+params(29)*y(36)^T(8)+params(35)*y(42)^T(8)+params(36)*y(43)^T(8)+params(37)*y(44)^T(8);
T(29) = params(30)*y(37)^T(14)+params(34)*y(41)^T(14);
T(30) = params(31)*y(38)^T(22)+params(32)*y(39)^T(22)+params(33)*y(40)^T(22);
T(31) = params(28)*y(35)^T(6);
T(32) = params(27)*y(34)^T(6);
T(33) = params(35)*y(42)^T(6);
T(34) = params(36)*y(43)^T(6);
T(35) = params(37)*y(44)^T(6);
T(36) = params(29)*y(36)^T(6);
T(37) = exp(params(101)*params(38)*y(20)+params(101)*params(39)*y(21)+params(101)*params(40)*y(22)+params(101)*params(41)*y(23)+params(101)*params(42)*y(24));
T(38) = exp(y(20)*params(101)*params(43)+params(101)*params(44)*y(21)+params(101)*params(45)*y(22)+params(101)*params(46)*y(23)+params(101)*params(47)*y(24));
T(39) = exp(y(20)*params(101)*params(48)+params(101)*params(49)*y(21)+params(101)*params(50)*y(22)+params(101)*params(51)*y(23)+params(101)*params(52)*y(24));
T(40) = exp(y(20)*params(101)*params(53)+params(101)*params(54)*y(21)+params(101)*params(55)*y(22)+params(101)*params(56)*y(23)+params(101)*params(57)*y(24));
T(41) = exp(y(20)*params(101)*params(58)+params(101)*params(59)*y(21)+params(101)*params(60)*y(22)+params(101)*params(61)*y(23)+params(101)*params(62)*y(24));
T(42) = exp(y(20)*params(101)*params(63)+params(101)*params(64)*y(21)+params(101)*params(65)*y(22)+params(101)*params(66)*y(23)+params(101)*params(67)*y(24));
T(43) = exp(y(20)*params(101)*params(68)+params(101)*params(69)*y(21)+params(101)*params(70)*y(22)+params(101)*params(71)*y(23)+params(101)*params(72)*y(24));
T(44) = exp(y(20)*params(101)*params(73)+params(101)*params(74)*y(21)+params(101)*params(75)*y(22)+params(101)*params(76)*y(23)+params(101)*params(77)*y(24));
T(45) = exp(y(20)*params(101)*params(78)+params(101)*params(79)*y(21)+params(101)*params(80)*y(22)+params(101)*params(81)*y(23)+params(101)*params(82)*y(24));

end
