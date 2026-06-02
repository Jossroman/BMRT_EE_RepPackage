function T = dynamic_g2_tt(T, y, x, params, steady_state, it_)
% function T = dynamic_g2_tt(T, y, x, params, steady_state, it_)
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

assert(length(T) >= 91);

T = NC_SCC_Hybrid.dynamic_g1_tt(T, y, x, params, steady_state, it_);

T(82) = (-y(229))/(y(97)*y(97));
T(83) = 1/y(97);
T(84) = (-((-(y(31)*y(229)))*(y(97)+y(97))))/(y(97)*y(97)*y(97)*y(97));
T(85) = (-y(31))/(y(97)*y(97));
T(86) = getPowerDeriv(y(33),1/params(86),2);
T(87) = getPowerDeriv(y(36),1/params(87),2);
T(88) = getPowerDeriv(y(37),1/params(88),2);
T(89) = getPowerDeriv(T(28),params(86)/(params(86)-1),2);
T(90) = getPowerDeriv(T(29),params(87)/(params(87)-1),2);
T(91) = getPowerDeriv(T(30),params(88)/(params(88)-1),2);

end
