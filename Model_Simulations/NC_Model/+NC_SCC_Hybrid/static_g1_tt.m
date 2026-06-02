function T = static_g1_tt(T, y, x, params)
% function T = static_g1_tt(T, y, x, params)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T         [#temp variables by 1]  double   vector of temporary terms to be filled by function
%   y         [M_.endo_nbr by 1]      double   vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1]       double   vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1]     double   vector of parameter values in declaration order
%
% Output:
%   T         [#temp variables by 1]  double   vector of temporary terms
%

assert(length(T) >= 46);

T = NC_SCC_Hybrid.static_resid_tt(T, y, x, params);

T(41) = getPowerDeriv(y(9),1/params(86),1);
T(42) = getPowerDeriv(T(38),params(86)/(params(86)-1),1);
T(43) = getPowerDeriv(y(12),1/params(87),1);
T(44) = getPowerDeriv(y(13),1/params(88),1);
T(45) = getPowerDeriv(T(39),params(87)/(params(87)-1),1);
T(46) = getPowerDeriv(T(40),params(88)/(params(88)-1),1);

end
