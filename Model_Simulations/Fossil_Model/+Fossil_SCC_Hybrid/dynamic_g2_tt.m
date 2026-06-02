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

assert(length(T) >= 33);

T = Fossil_SCC_Hybrid.dynamic_g1_tt(T, y, x, params, steady_state, it_);

T(28) = (-y(109))/(y(51)*y(51));
T(29) = 1/y(51);
T(30) = (-((-(y(20)*y(109)))*(y(51)+y(51))))/(y(51)*y(51)*y(51)*y(51));
T(31) = (-y(20))/(y(51)*y(51));
T(32) = getPowerDeriv(y(22),1/params(28),2);
T(33) = getPowerDeriv(T(10),params(28)/(params(28)-1),2);

end
