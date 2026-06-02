%%% January 2026
%%% G. Benmir, A. Mori, J. Roman, R. Tarsia
%%% Only Energy SCC 
%----------------------------------------------------------------
% 0. Housekeeping and Options Declaration
%----------------------------------------------------------------
close all;
// Longrun transitions are over 82 years from 2018 to 2100!
// Select whether we want habits or not (Habits are important to generate volatility in the CO2 price (cf. Green Asset Pricing))
// 0 = no habits
// 1 = habits
// 0 = Matthews
// 1 = Joos
    // Here I define all types of structures I use in the macro-processor
%----------------------------------------------------------------
% 1. Var, Varexo, and Params Declaration
%----------------------------------------------------------------
var
e_a           $A$        (long_name='TFP Trend Law of Motion')
g_a           $\gamma_A$ (long_name='TFP Growth Law of Motion')
beta          $\beta$    (long_name='Discount Factor')
c_t           $C$        (long_name='Aggregate Consumption')
y_t           $Y$        (long_name='Aggregate Output')
y_AL          $Y_{AL}$   (long_name='AL Output')
y_K           $Y_{K}$    (long_name='K Output')
y_Energy      $Y_E$      (long_name='Energy Output')
d_Energy      $D_F$      (long_name='Energy Output')
d_K           $D_K$      (long_name='K Output')
s_Energy      $S_F$      (long_name='Energy Stock')
s_K           $S_F$      (long_name='K Stock')
h             $H$        (long_name='Consumption Habits')
x_tot         $X$        (long_name='Cumulative emissions')
t             $T$        (long_name='Temperature')
e             $E$        (long_name='Emissions')
e_a_shock     $e_A$      (long_name='TFP Innovation')
e_t_shock     $e_T$      (long_name='Temperature Innovation')
welfare       $Welfare$  (long_name='Welfare')
d_t_K         $D_T_K$      (long_name='Damage Function K')
d_t_AL        $D_T_AL$     (long_name='Damage Function AL')
d_t_Energy    $D_T_Energy$ (long_name='Damage Function Energy')
v_AL          $V_AL$     (long_name='AL Lagrangian')
v_K           $V_K$      (long_name='K Lagrangian')
v_Energy      $V_F$      (long_name='Energy Lagrangian')
r_Energy      $R_F$      (long_name='Energy Stock Lagrangian')
r_K           $R_F$      (long_name='K Stock Lagrangian')
lambda_h      $Habits Shadow Price$        (long_name='Lagrangian Habits')
lambda        $Consumption Shadow Price$   (long_name='Lagrangian Consumption')
v_y_t         $Shadow Price of Total Output$            (long_name='Lagrangian Y_T')
v_x_tot       $Shadow Price of Total Cumulative Emissions$ (long_name='Lagrangian X')
v_t           $Shadow Price of Total Temperature$       (long_name='Lagrangian T')
v_emission    $Shadow Price of Emission$                (long_name='SCC')
discount_factor_1 $Discount Factor_1$ (long_name='Discount Factor_1')
discount_factor_2 $Discount Factor_2$ (long_name='Discount Factor_2')
discount_factor_3 $Discount Factor_3$ (long_name='Discount Factor_3')
discount_factor_4 $Discount Factor_4$ (long_name='Discount Factor_4')
discount_factor_5 $Discount Factor_5$ (long_name='Discount Factor_5')
;
varexo
eta_a $ eta^{a}$ (long_name='Innovation to TFP')
eta_t $ eta^{a}$ (long_name='Innovation to Temperature')
;
parameters
phi_emission $\Phi_E$ (long_name='Emission intensity')
L                  $L$               (long_name='Labour')
ALPHA_Energy       $\delta_s_Energy$ (long_name='Energy depreciation rate')
ALPHA_K            $\delta_s_K$      (long_name='K depreciation rate')
DELTA_S_Energy     $\delta_Energy$   (long_name='Energy depreciation rate')
DELTA_S_K          $\delta_K$        (long_name='K depreciation rate')
KAPPA_Energy       $\kappa_Energy$   (long_name='Weight or TFP of Energy production')
KAPPA_K            $\kappa_Energy$   (long_name='Weight or TFP of Energy production')
G_Y                $\g_Y$            (long_name='Total CES weight')
GAMMA_AL           $\gamma_AL$       (long_name='AL CES weight')
GAMMA_K            $\gamma_K$        (long_name='K CES weight')
GAMMA_Energy       $\gamma_F$        (long_name='Energy CES weight')
     D1_K_1 $d1_K_1$ (long_name='K_1 damage param 1')
     D1_K_2 $d1_K_2$ (long_name='K_2 damage param 1')
     D1_K_3 $d1_K_3$ (long_name='K_3 damage param 1')
     D1_K_4 $d1_K_4$ (long_name='K_4 damage param 1')
     D1_K_5 $d1_K_5$ (long_name='K_5 damage param 1')
     D1_AL_1 $d1_AL_1$ (long_name='AL_1 damage param 1')
     D1_AL_2 $d1_AL_2$ (long_name='AL_2 damage param 1')
     D1_AL_3 $d1_AL_3$ (long_name='AL_3 damage param 1')
     D1_AL_4 $d1_AL_4$ (long_name='AL_4 damage param 1')
     D1_AL_5 $d1_AL_5$ (long_name='AL_5 damage param 1')
     D1_Energy_1 $d1_Energy_1$ (long_name='Energy_1 damage param 1')
     D1_Energy_2 $d1_Energy_2$ (long_name='Energy_2 damage param 1')
     D1_Energy_3 $d1_Energy_3$ (long_name='Energy_3 damage param 1')
     D1_Energy_4 $d1_Energy_4$ (long_name='Energy_4 damage param 1')
     D1_Energy_5 $d1_Energy_5$ (long_name='Energy_5 damage param 1')
EPS_Y              $\sigma_Y$        (long_name='Output Elasticity')
BETTA              $\beta$           (long_name='Discount Factor')
SIGMA              $\{\sigm_y}_2$    (long_name='Risk Aversion')
DELTA_X_TOT $\delta_x_tot$ (long_name='Decay Rate of emissions')
X_BAR              $\bar{X}$         (long_name='Cumulative Emissions at the start')
ZETTA_1            $\zetta_1$        (long_name='Climate Sensitivity Parameter 1')
ZETTA_2            $\zetta_2$        (long_name='Climate Sensitivity Parameter 2')
TEMP_MEAN          $Temp_SS$         (long_name='Temperature Mean for the world')
A                  $A$               (long_name='Labour Productivity')
M                  $m$               (long_name='Habits level')
GAMMA_H            $\gamma$          (long_name='Habits level adjustment in the utility')
RHO_A            $\rho_A$          (long_name='TFP Persistence')
RHO_T            $\rho_T$          (long_name='Temperature Persistence')
DELTA_A $\delta_A$ (long_name='Decay rate of TFP Growth')
DELTA_VARPHI       $\delta_A$        (long_name='Decay rate of Decoupling Growth')
g_a_0              $\gamma_{A_0}$    (long_name='The initial growth rate')
S_BAR              $\bar{S}$         (long_name='Numerical accuracy adjustment constant to all stocks')
;
%----------------------------------------------------------------
% 2. Params Calibration
%----------------------------------------------------------------
%% Env Params
TEMP_MEAN = 14.5/15.5;
D1_AL_1 = -.02;
D1_AL_2 = 0.0;
D1_AL_3 = 0.0;
D1_AL_4 = 0.0;//
D1_AL_5 = 0.0;
D1_K_1 = -.029;
D1_K_2 = -0.039;
D1_K_3 = -0.035;
D1_K_4 = 0.0;//
D1_K_5 = 0.0;
D1_Energy_1 = -0.027;
D1_Energy_2 = -0.027;
D1_Energy_3 =  -0.0067;
D1_Energy_4 = .0 ; // Climate Damages param
D1_Energy_5 = .0 ; // Climate Damages param
%% CES Weights
GAMMA_K= 0.2531;     // share in the CES
GAMMA_Energy= 0.2043;// share in the CES
GAMMA_AL= 0.5426;
%% CES Elasticity
EPS_Y = 1/(1-0.4211);  // Output CES elasticity
%% Climate Params
ZETTA_1 = .5;    // Climate sensitivity
DELTA_X_TOT = 0.007;//0.00001;
%% Macro params
SIGMA = 2;         // CRRA utility
BETTA =.968;// 0.966183574879227;//.95;  //Time pref assuming a 3.5% world gdp-weighted interest rate
L = 1/3;
M = 1;        // Habits level
GAMMA_H = .9; // Habits utility
    ALPHA_K = 1;
    DELTA_S_K = .05;
    ALPHA_Energy = 1;
    DELTA_S_Energy = .05;
S_BAR =  1e-8; // for numerical accuracy and to avoid S = a flat 0 
RHO_A = .9;
RHO_T = .9;
g_a_0 = 0.0; // for the moments exercise   
%----------------------------------------------------------------
% 3. Model
%----------------------------------------------------------------
model;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Household        %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[name='Beta'] 
beta = BETTA*(1+g_a)^(1-SIGMA);
[name='Welfare']
welfare =  (c_t-GAMMA_H*h(-1))^(1-SIGMA)/(1-SIGMA) + beta*welfare(+1);
[name='Habits']
h = 0;
[name='FOC C']
lambda  = (c_t-GAMMA_H*h(-1))^(-SIGMA) - lambda*lambda_h*(1-M);
[name='FOC H']
lambda_h  = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Climate Dynamics       %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[name='Damage Function K']
 d_t_K = exp(
           + TEMP_MEAN*D1_K_1*t(-1)
           + TEMP_MEAN*D1_K_2*t(-2)
           + TEMP_MEAN*D1_K_3*t(-3)
           + TEMP_MEAN*D1_K_4*t(-4)
           + TEMP_MEAN*D1_K_5*t(-5)
               );
[name='Damage Function AL']
 d_t_AL = exp(
           + TEMP_MEAN*D1_AL_1*t(-1)
           + TEMP_MEAN*D1_AL_2*t(-2)
           + TEMP_MEAN*D1_AL_3*t(-3)
           + TEMP_MEAN*D1_AL_4*t(-4)
           + TEMP_MEAN*D1_AL_5*t(-5)
               );
[name='Damage Function Energy']
 d_t_Energy = exp(
           + TEMP_MEAN*D1_Energy_1*t(-1)
           + TEMP_MEAN*D1_Energy_2*t(-2)
           + TEMP_MEAN*D1_Energy_3*t(-3)
           + TEMP_MEAN*D1_Energy_4*t(-4)
           + TEMP_MEAN*D1_Energy_5*t(-5)
               );
[name='Total Emissions']
e = e_a*phi_emission*y_Energy;
// [name='Emissions Intensity']
//phi_emission = phi_emission;//(1 - DELTA_VARPHI) * phi_emission(-1);
[name='Temperature']
t = e_t_shock*ZETTA_1*(ZETTA_2*x_tot(-1) - t(-1)) + t(-1) ;
[name='Cumulative Emissions']
x_tot = X_BAR + (1-DELTA_X_TOT)*x_tot(-1) + e ;
    [name='FOC X(+1)']
    v_x_tot = beta*lambda(+1)/lambda*( (1-DELTA_X_TOT)*v_x_tot(+1) + e_t_shock(+1)* ZETTA_1*ZETTA_2*v_t(+1)     );
[name='FOC T(+1)']
v_t = discount_factor_1 * (1 - e_t_shock(+1) * ZETTA_1) * v_t(+1) - (
       + discount_factor_1* (v_Energy(1) * TEMP_MEAN*D1_Energy_1 * y_Energy(1))
       + discount_factor_2* (v_Energy(2) * TEMP_MEAN*D1_Energy_2 * y_Energy(2))
       + discount_factor_3* (v_Energy(3) * TEMP_MEAN*D1_Energy_3 * y_Energy(3))
       + discount_factor_4* (v_Energy(4) * TEMP_MEAN*D1_Energy_4 * y_Energy(4))
       + discount_factor_5* (v_Energy(5) * TEMP_MEAN*D1_Energy_5 * y_Energy(5))
) - (
       + discount_factor_1* (v_K(1) * TEMP_MEAN*D1_K_1 * y_K(1))
       + discount_factor_2* (v_K(2) * TEMP_MEAN*D1_K_2 * y_K(2))
       + discount_factor_3* (v_K(3) * TEMP_MEAN*D1_K_3 * y_K(3))
       + discount_factor_4* (v_K(4) * TEMP_MEAN*D1_K_4 * y_K(4))
       + discount_factor_5* (v_K(5) * TEMP_MEAN*D1_K_5 * y_K(5))
) - (
       + discount_factor_1*(v_AL(1) * TEMP_MEAN*D1_AL_1 * y_AL(1))
       + discount_factor_2*(v_AL(2) * TEMP_MEAN*D1_AL_2 * y_AL(2))
       + discount_factor_3*(v_AL(3) * TEMP_MEAN*D1_AL_3 * y_AL(3))
       + discount_factor_4*(v_AL(4) * TEMP_MEAN*D1_AL_4 * y_AL(4))
       + discount_factor_5*(v_AL(5) * TEMP_MEAN*D1_AL_5 * y_AL(5))
);
[name='Discount factor']
discount_factor_1 = (BETTA*lambda(1)/lambda(0));
     discount_factor_2 = discount_factor_1 * (BETTA*lambda(2)/lambda(2-1));
     discount_factor_3 = discount_factor_2 * (BETTA*lambda(3)/lambda(3-1));
     discount_factor_4 = discount_factor_3 * (BETTA*lambda(4)/lambda(4-1));
     discount_factor_5 = discount_factor_4 * (BETTA*lambda(5)/lambda(5-1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Social Cost of Carbon  %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[name='SCC']
v_emission = v_x_tot* e_a;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% NC Exhaustible Stock   %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[name='Energy Stock Law of motion']
(1+g_a)*s_Energy = S_BAR + (1- DELTA_S_Energy)*s_Energy(-1) + ALPHA_Energy*d_Energy;
[name='Energy Production in terms of stock']
y_Energy = d_t_Energy*(KAPPA_Energy*s_Energy(-1) );
[name='S_Energy(+1) stock FOC']
(1+g_a)*r_Energy =  beta*lambda(+1)/lambda*( (1-DELTA_S_Energy)*r_Energy(+1) + KAPPA_Energy*d_t_Energy(+1)*v_Energy(+1) );
[name='K Stock Law of motion']
(1+g_a)*s_K = S_BAR + (1- DELTA_S_K)*s_K(-1) + ALPHA_K*d_K;
[name='K Production in terms of stock']
y_K = d_t_K*(KAPPA_K*s_K(-1) );
[name='S_K(+1) stock FOC']
(1+g_a)*r_K =  beta*lambda(+1)/lambda*( (1-DELTA_S_K)*r_K(+1) + KAPPA_K*d_t_K(+1)*v_K(+1) );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% NC + Y_KL Laws Choices  %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[name='A and L Production']
y_AL = d_t_AL*(A*L);
[name='FOC D_Energy ']
r_Energy = 1/ALPHA_Energy ;
[name='FOC D_K ']
r_K = 1/ALPHA_K ;
[name='FOC Y_AL']
v_AL = GAMMA_AL*v_y_t*(y_AL)^(-1/EPS_Y)*(y_t)^(1/EPS_Y)*(e_a_shock*G_Y)^((EPS_Y-1)/EPS_Y);
[name='FOC K']
v_K = v_y_t*GAMMA_K*(y_K)^(-1/EPS_Y)*(y_t)^(1/EPS_Y)*(e_a_shock*G_Y)^((EPS_Y-1)/EPS_Y);
[name='FOC Energy']
v_Energy = v_y_t*GAMMA_Energy*(y_Energy)^(-1/EPS_Y)*(y_t)^(1/EPS_Y)*(e_a_shock*G_Y)^((EPS_Y-1)/EPS_Y) - phi_emission*v_emission;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Aggregate Output %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[name='Aggregate GDP']
y_t = e_a_shock*G_Y*(
GAMMA_Energy*(y_Energy)^((EPS_Y-1)/EPS_Y) + GAMMA_AL*(y_AL)^((EPS_Y-1)/EPS_Y)  + GAMMA_K*(y_K)^((EPS_Y-1)/EPS_Y)
      )^ (EPS_Y / (EPS_Y - 1));
[name='FOC Y_T']
v_y_t = 1 ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Market Clearing  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[name='Aggregate Resource Constraint']
y_t = c_t + d_Energy + d_K ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Shocks %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[name='TFP Trend Law of Motion']
e_a = 1 ;
[name='TFP Growth Law of Motion']
g_a = g_a_0;
[name='TFP Shock Process']
log(e_a_shock) = RHO_A*log(e_a_shock(-1)) + eta_a;
[name='TFP Shock Process']
log(e_t_shock) = RHO_T*log(e_t_shock(-1)) + eta_t;
end;
%----------------------------------------------------------------
% 4. Steady State Model
%----------------------------------------------------------------
steady_state_model;
e_a_shock = 1; // TFP Shock Process
e_t_shock = 1;
e_a = 1; // Initial level of TFP
g_a = g_a_0; // Initial growth rate of TFP
//Here we match all the targets (i.e. values at the start)
e = .03677; // In trillion TCO2 
t = 1.12; 
x_tot = 1.63; //3.12
ZETTA_2 = t/x_tot;
X_BAR = DELTA_X_TOT*x_tot - e;
 d_t_K = exp(
           + TEMP_MEAN*D1_K_1*t
           + TEMP_MEAN*D1_K_2*t
           + TEMP_MEAN*D1_K_3*t
           + TEMP_MEAN*D1_K_4*t
           + TEMP_MEAN*D1_K_5*t
               );
 d_t_AL = exp(
           + TEMP_MEAN*D1_AL_1*t
           + TEMP_MEAN*D1_AL_2*t
           + TEMP_MEAN*D1_AL_3*t
           + TEMP_MEAN*D1_AL_4*t
           + TEMP_MEAN*D1_AL_5*t
               );
 d_t_Energy = exp(
           + TEMP_MEAN*D1_Energy_1*t
           + TEMP_MEAN*D1_Energy_2*t
           + TEMP_MEAN*D1_Energy_3*t
           + TEMP_MEAN*D1_Energy_4*t
           + TEMP_MEAN*D1_Energy_5*t
               );
discount_factor_1 = BETTA;
     discount_factor_2 = discount_factor_1 * BETTA;
     discount_factor_3 = discount_factor_2 * BETTA;
     discount_factor_4 = discount_factor_3 * BETTA;
     discount_factor_5 = discount_factor_4 * BETTA;
y_Energy = 25.9253;// 0.5427 + 25.382520161216998 ;// Energy value from the NC_SCC case.
y_K = 358.496430394957;//34.626; //(In Tillion Dollars)
y_AL = 727.209555089740;// 85.4098; //(In Tillion Dollars)
y_t = 86.5; //(In Tillion Dollars)
phi_emission = e/y_Energy;
DELTA_VARPHI = 0;// emission intenisty decay rate
beta = BETTA*(1+g_a)^(1-SIGMA);
G_Y = y_t/((GAMMA_Energy*y_Energy^((EPS_Y-1)/EPS_Y) + GAMMA_AL*y_AL^((EPS_Y-1)/EPS_Y) + GAMMA_K*(y_K)^((EPS_Y-1)/EPS_Y))^ (EPS_Y / (EPS_Y - 1)));
v_y_t = 1;
v_AL = GAMMA_AL*v_y_t*(y_AL)^(-1/EPS_Y)*(y_t)^(1/EPS_Y)*(e_a_shock*G_Y)^((EPS_Y-1)/EPS_Y);
v_K  = v_y_t*GAMMA_K*(y_K)^(-1/EPS_Y)*(y_t)^(1/EPS_Y)*(e_a_shock*G_Y)^((EPS_Y-1)/EPS_Y);
A = y_AL/(d_t_AL*L) ;
[v_t, v_x_tot, v_emission, v_fossil] = 
                                  get_ss_v_fossil_energy_hybrid_0(TEMP_MEAN,phi_emission,v_y_t,G_Y,v_AL,v_K,y_t,EPS_Y, y_AL,y_K, 
                                                                              D1_K_1, D1_K_2, D1_K_3, D1_K_4, D1_K_5, 
                                                                              D1_AL_1, D1_AL_2, D1_AL_3, D1_AL_4, D1_AL_5, 
                                                                              D1_Energy_1,D1_Energy_2 ,D1_Energy_3,D1_Energy_4,D1_Energy_5, 
                                                                              y_Energy, GAMMA_Energy, BETTA, ZETTA_1, ZETTA_2, 
                                                                              DELTA_X_TOT);
v_Energy = v_y_t*GAMMA_Energy*(y_Energy)^(-1/EPS_Y)*(y_t)^(1/EPS_Y)*(e_a_shock*G_Y)^((EPS_Y-1)/EPS_Y) - phi_emission*v_emission;
    r_K = 1/ALPHA_K ;   
    KAPPA_K = ((1+g_a)*r_K /beta  - S_BAR -(1-DELTA_S_K)*r_K ) / (d_t_K*v_K);
    s_K  = y_K/(d_t_K*KAPPA_K);
    d_K = (g_a+DELTA_S_K)*s_K / ALPHA_K;
    r_Energy = 1/ALPHA_Energy ;   
    KAPPA_Energy = ((1+g_a)*r_Energy /beta  - S_BAR -(1-DELTA_S_Energy)*r_Energy ) / (d_t_Energy*v_Energy);
    s_Energy  = y_Energy/(d_t_Energy*KAPPA_Energy);
    d_Energy = (g_a+DELTA_S_Energy)*s_Energy / ALPHA_Energy;
c_t = y_t - d_K - d_Energy;
    h = 0;
welfare =  ((c_t-GAMMA_H*h)^(1-SIGMA)/(1-SIGMA))/(1-beta);
    lambda = c_t^(-SIGMA);
    lambda_h  = 0;
end;
%----------------------------------------------------------------
% 5. Computation
%----------------------------------------------------------------
// Note: steady state check is SKIPPED because we do not start from the SS 
// but rather an initial state and we converge toward the real SS! This clear 
// for the climate block and growth processes.
steady;
resid;
check;
%----------------------------------------------------------------
% 6. Simulations
%----------------------------------------------------------------
shocks;
 var eta_a;
 stderr 0.01;
end;
stoch_simul(nograph);
