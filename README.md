# NC Replication Package

Replication package for:

**Beneath the Trees: The Influence of Natural Capital on Shadow Price Dynamics in a Macroeconomic Model with Uncertainty**  
Benmir, Mori, Roman, and Tarsia

This repository contains the empirical estimation files, quantitative model
simulation files, and manuscript files used for the paper. Each main component
has its own README with the detailed replication instructions.

## Repository Structure

### `Model_Estimations/`

This folder contains the empirical estimation exercises used to calibrate the
model.

- `CES_Estimations/` contains the data-cleaning, Kmenta, MATLAB bootstrap, and
  ADAM/NNE estimation files for the nested CES production structure. See
  [`Model_Estimations/CES_Estimations/README.txt`](Model_Estimations/CES_Estimations/README.txt).

- `Damages_Estimations/` contains the Stata files used to estimate the
  temperature-damage equations for the natural-capital and fossil-fuel inputs.
  See
  [`Model_Estimations/Damages_Estimations/README.txt`](Model_Estimations/Damages_Estimations/README.txt).

### `Model_Simulations/`

This folder contains the Dynare/MATLAB model code and the simulation exercises
used for the quantitative results.

- `NC_Model/` contains the model code for the full natural-capital model.
- `Fossil_Model/` contains the fossil-energy-only benchmark model.
- `Transition_Exercise/` reproduces the long-run transition paths. See
  [`Model_Simulations/Transition_Exercise/README.txt`](Model_Simulations/Transition_Exercise/README.txt).
- `SS_Moments_Exercise/` reproduces the steady-state sensitivity figures and
  stochastic moments tables. See
  [`Model_Simulations/SS_Moments_Exercise/README.txt`](Model_Simulations/SS_Moments_Exercise/README.txt).
- `IRF_Exercise/` reproduces the short-run impulse-response and decomposition
  exercises. See
  [`Model_Simulations/IRF_Exercise/README.txt`](Model_Simulations/IRF_Exercise/README.txt).

For an overview of the simulation folder, see
[`Model_Simulations/README.txt`](Model_Simulations/README.txt).

### `Paper/`

This folder contains the manuscript source and bibliography files, along with a
compiled PDF version of the paper.

## Suggested Replication Order

1. Start with the estimation folders if you want to reproduce the calibration
   inputs:
   - `Model_Estimations/CES_Estimations/`
   - `Model_Estimations/Damages_Estimations/`

2. Then run the simulation exercises in the order used in the paper:
   - long-run transitions;
   - steady-state and moments exercises;
   - short-run impulse-response exercises.

3. Consult the `Paper/` folder to match the generated tables and figures to the
   manuscript.

Software requirements and folder-specific instructions are documented in the
README files inside each replication folder.
