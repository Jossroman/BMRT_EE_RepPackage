function [decays_1,decays_2,decays_3] = calibrate_decays(T, g_a0, phi0, e_a0, tol_g, tol_phi)
% Calibrate DELTA_A and DELTA_VARPHI so that g_a(T) ~ 0 and phi(T) ~ 0,
% and return the implied terminal TFP level e_a(T).
%
% Model:
%   e_a(t) = e_a(t-1) * (1 + g_a(t-1))
%   g_a(t) = g_a(t-1) * (1 - DELTA_A)
%
%   phi(t) = (1 - DELTA_VARPHI) * phi(t-1)
%
% Inputs:
%   T       : horizon (integer > 0), period when rates are ~0
%   g_a0    : initial growth rate level (e.g., 0.02)
%   phi0    : initial phi_emission level (e.g., 1)
%   e_a0    : initial TFP level (default = 1)
%   tol_g   : target tolerance for g_a(T) (default = 1e-6)
%   tol_phi : target tolerance for phi(T) (default = 1e-6)
%
% Outputs:
%   DELTA_A       : decay rate for g_a
%   e_a_T         : terminal TFP level e_a(T)
%   DELTA_VARPHI  : decay rate for phi_emission

    if nargin < 4 || isempty(e_a0),   e_a0 = 1;     end
    if nargin < 5 || isempty(tol_g),  tol_g = 1e-6; end
    if nargin < 6 || isempty(tol_phi),tol_phi = 1e-6; end

    % -----------------------
    % Basic checks
    % -----------------------
    assert(T > 0 && mod(T,1)==0, 'T must be a positive integer.');
    assert(g_a0 > 0, 'g_a0 must be positive.');
    assert(phi0 > 0, 'phi0 must be positive.');
    assert(e_a0 > 0, 'e_a0 must be positive.');
    assert(tol_g > 0 && tol_g < g_a0,   'tol_g must be in (0, g_a0).');
    assert(tol_phi > 0 && tol_phi < phi0, 'tol_phi must be in (0, phi0).');

    % -----------------------
    % 1) Calibrate DELTA_A from g_a(T) = tol_g
    %    g_a(T) = g_a0 * (1-DELTA_A)^T
    % -----------------------
    DELTA_A = 1 - (tol_g / g_a0)^(1 / T);
    qA = 1 - DELTA_A;  % decay factor

    % -----------------------
    % 2) Compute terminal TFP level e_a(T)
    %    e_a(T) = e_a0 * prod_{t=0}^{T-1} (1 + g_a(t))
    %    where g_a(t) = g_a0 * qA^t
    % -----------------------
    log_e = log(e_a0);
    for t = 0:(T-1)
        g_t = g_a0 * (qA^t);
        log_e = log_e + log1p(g_t);  % log(1+g_t) in a stable way
    end
    e_a_T = exp(log_e);

    % -----------------------
    % 3) Calibrate DELTA_VARPHI from phi(T) = tol_phi
    %    phi(T) = phi0 * (1-DELTA_VARPHI)^T
    % -----------------------
    DELTA_VARPHI = 1 - (tol_phi / phi0)^(1 / T);

    decays = [DELTA_A, e_a_T, DELTA_VARPHI];
    decays_1 = decays(1);
    decays_2 = decays(2);
    decays_3 = decays(3);
    
end
