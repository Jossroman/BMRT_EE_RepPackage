README: Model simulations
January 2026
G. Benmir, A. Mori, J. Roman, R. Tarsia

This folder contains the model code and the simulation exercises used for the
quantitative model results in the paper. The simulations are organized around
three exercises. The scripts use paths relative to this repository, so no local
or machine-specific repository path should be hard-coded. Before running the
MATLAB scripts, add Dynare to the MATLAB path.

1. Long-run transitions
   Folder: Transition_Exercise

   This exercise solves deterministic perfect-foresight transition paths. It
   shows how the economy, temperature, the social cost of carbon, and the main
   natural-capital inputs evolve from 2018 toward the long-run steady state
   under exogenous growth that gradually declines. See:

       Transition_Exercise/README.txt

2. Long-run steady state and moments
   Folder: SS_Moments_Exercise

   This exercise computes deterministic steady-state objects, sensitivity
   figures for the social cost of carbon and shadow prices, and stochastic
   moments from second-order perturbation solutions around the deterministic
   stationary equilibrium or balanced-growth-path equilibrium. It is used for
   the SCC and shadow-price sensitivity results, as well as the uncertainty
   tables for TFP and temperature shocks. See:

       SS_Moments_Exercise/README.txt

3. Short-run impulse responses
   Folder: IRF_Exercise

   This exercise studies a short-run fossil-fuel discovery shock. In the paper,
   the shock is calibrated as a gas discovery that increases the gas stock by
   10 percent on impact. The scripts report impulse responses and decompositions
   for output, welfare, emissions, and natural-capital production. See:

       IRF_Exercise/README.txt


Model-code folders
------------------

- NC_Model/
  Contains the Dynare/MATLAB model code for the full model with natural capital.
  This is the model with produced capital, human capital, energy, fossil fuels,
  renewables, land, minerals, and forest ecosystem services.

- Fossil_Model/
  Contains the Dynare/MATLAB model code for the fossil-energy-only benchmark.
  This is the comparison model used to evaluate how omitting the richer
  natural-capital structure changes the social cost of carbon and shadow prices.

The exercise folders call these model-code folders. In normal replication use,
start from the README in the relevant exercise folder rather than running files
inside NC_Model or Fossil_Model directly.

