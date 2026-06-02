function T = dynamic_g1_tt(T, y, x, params, steady_state, it_)
% function T = dynamic_g1_tt(T, y, x, params, steady_state, it_)
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

assert(length(T) >= 81);

T = NC_SCC_Hybrid.dynamic_resid_tt(T, y, x, params, steady_state, it_);

T(46) = y(229)/y(97);
T(47) = getPowerDeriv(y(33),1/params(86),1);
T(48) = params(27)*getPowerDeriv(y(34),T(6),1);
T(49) = params(27)*getPowerDeriv(y(34),T(8),1);
T(50) = getPowerDeriv(T(28),params(86)/(params(86)-1),1);
T(51) = params(28)*getPowerDeriv(y(35),T(6),1);
T(52) = params(28)*getPowerDeriv(y(35),T(8),1);
T(53) = params(29)*getPowerDeriv(y(36),T(6),1);
T(54) = getPowerDeriv(y(36),1/params(87),1);
T(55) = params(29)*getPowerDeriv(y(36),T(8),1);
T(56) = getPowerDeriv(y(37),T(10),1);
T(57) = y(106)*params(30)*T(56);
T(58) = getPowerDeriv(y(37),1/params(88),1);
T(59) = params(30)*getPowerDeriv(y(37),T(14),1);
T(60) = getPowerDeriv(T(29),params(87)/(params(87)-1),1);
T(61) = getPowerDeriv(y(38),T(18),1);
T(62) = y(107)*params(31)*T(61);
T(63) = params(31)*getPowerDeriv(y(38),T(22),1);
T(64) = getPowerDeriv(T(30),params(88)/(params(88)-1),1);
T(65) = getPowerDeriv(y(39),T(18),1);
T(66) = y(107)*params(32)*T(65);
T(67) = params(32)*getPowerDeriv(y(39),T(22),1);
T(68) = getPowerDeriv(y(40),T(18),1);
T(69) = y(107)*params(33)*T(68);
T(70) = params(33)*getPowerDeriv(y(40),T(22),1);
T(71) = getPowerDeriv(y(41),T(10),1);
T(72) = y(106)*params(34)*T(71);
T(73) = params(34)*getPowerDeriv(y(41),T(14),1);
T(74) = params(35)*getPowerDeriv(y(42),T(6),1);
T(75) = params(35)*getPowerDeriv(y(42),T(8),1);
T(76) = params(36)*getPowerDeriv(y(43),T(6),1);
T(77) = params(36)*getPowerDeriv(y(43),T(8),1);
T(78) = params(37)*getPowerDeriv(y(44),T(6),1);
T(79) = params(37)*getPowerDeriv(y(44),T(8),1);
T(80) = (-(y(31)*y(229)))/(y(97)*y(97));
T(81) = y(31)/y(97);

end
