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

assert(length(T) >= 27);

T = Fossil_SCC_Hybrid.dynamic_resid_tt(T, y, x, params, steady_state, it_);

T(17) = y(109)/y(51);
T(18) = getPowerDeriv(y(22),1/params(28),1);
T(19) = params(10)*getPowerDeriv(y(23),T(6),1);
T(20) = params(10)*getPowerDeriv(y(23),T(8),1);
T(21) = getPowerDeriv(T(10),params(28)/(params(28)-1),1);
T(22) = params(11)*getPowerDeriv(y(24),T(6),1);
T(23) = params(11)*getPowerDeriv(y(24),T(8),1);
T(24) = params(12)*getPowerDeriv(y(25),T(6),1);
T(25) = params(12)*getPowerDeriv(y(25),T(8),1);
T(26) = (-(y(20)*y(109)))/(y(51)*y(51));
T(27) = y(20)/y(51);

end
