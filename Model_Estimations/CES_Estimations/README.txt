README: CES estimations
=======================

This folder contains the empirical workflow used to prepare the data and
estimate the CES production-function parameters used in the quantitative
model. The workflow covers the three production nests:

1. First nest: aggregate output produced from produced capital, human capital,
   energy, land, minerals, and forest ecosystem services.
2. Second nest: energy produced from fossil energy and renewable energy.
3. Third nest: fossil energy produced from coal, oil, and gas.

The folder combines three types of code:

- a Stata cleaning and Kmenta-approximation file;
- Python scripts using TensorFlow/Adam and neural-network estimation;
- MATLAB scripts using nonlinear least squares and bootstrap inference.

The recommended replication order is:

1. Run the Stata cleaning/Kmenta file to create the cleaned Excel inputs.
2. Run the Python ADAM/NNE scripts to reproduce the machine-learning CES
   estimates.
3. Run the MATLAB scripts to reproduce the bootstrap estimates, standard
   errors, confidence intervals, and MSE comparisons.


Folder structure
----------------

Main files and folders:

- data_cleaning_kmenta_ces_nc.do
- Adam_CES_estimation/
- Matlab_CES_estimation/

The Stata file prepares the cleaned datasets used by both the Python and
MATLAB estimation routines. The Python and MATLAB folders then estimate the
CES parameters for the first, second, and third nests.


Important path note
-------------------

The CES scripts now use paths relative to this replication package.

The Stata cleaning script should be run from:

Model_Estimations/CES_Estimations/

It reads raw Excel files from:

Model_Estimations/Damages_Estimations/Data/Raw_xlsx/

and writes cleaned CES estimation files to:

Model_Estimations/CES_Estimations/Cleaned_Files/

The Python and MATLAB estimation scripts read the cleaned Excel files from
that same Cleaned_Files folder. The Python master file also calls the layer
scripts using paths relative to Adam_CES_estimation/ADAM_CES_estimation_master_file.py.


Step 1: Data cleaning and Kmenta estimation
-------------------------------------------

Script:

- data_cleaning_kmenta_ces_nc.do

Purpose:

This Stata do-file cleans and prepares the natural-capital, GDP, and energy
datasets used in the natural-capital CES estimation. It also runs the
Kmenta-approximation OLS regressions for the second and third CES layers.

Main workflow:

1. Define reusable project paths.
2. Clean the GDP dataset.
3. Clean the natural-capital dataset.
4. Merge natural capital with GDP data.
5. Clean and transform natural-capital variables.
6. Create country-year panel identifiers.
7. Create logged, normalized, and transformed variables needed for CES/Kmenta
   estimation.
8. Prepare second-layer CES variables for fossil versus renewable energy.
9. Prepare third-layer CES variables for coal versus oil/gas.
10. Run Kmenta-approximation OLS regressions for the second and third CES
    layers.
11. Export cleaned datasets and CES/Kmenta-ready datasets.

Path setup:

The file uses global macros at the top so that file paths do not need to be
hard-coded throughout the script. If the project folder moves, edit only the
project-root path in the PATH SETUP section at the top of the do-file.

The key folder globals are:

- project_root: the main project directory.
- raw_nc: folder containing raw natural-capital, GDP, and energy input files.
- clean_nc: folder where cleaned and intermediate outputs are saved.

Raw input files are defined once using globals:

- gdp_file
- natural_capital_file
- energy_file

Required raw input files:

1. gdp 2015.xlsx
   - Used to construct country-year GDP data.
   - GDP is rebased from constant 2015 USD to constant 2018 USD using a 1.05
     multiplier.

2. Natural Capital.xlsx
   - Contains country-year natural-capital variables.
   - Used to construct and clean inputs such as timber, fisheries, protected
     areas, cropland, pasture, subsoil assets, energy, oil, gas, coal,
     minerals, produced capital, human capital, and renewable assets.

3. Energy.xlsx
   - Used for the energy and fossil-fuel components of the CES/Kmenta
     workflow.

Main outputs:

The do-file creates cleaned and intermediate Stata and Excel outputs in the
cleaned-files folder. Typical outputs include:

1. gdp.dta / gdp.xlsx
   - Cleaned country-year GDP data.

2. natural_cap_country.dta / natural_cap_country.xlsx
   - Cleaned natural-capital country-year dataset before final merges and
     transformations.

3. nk_country_final.dta / nk_country_final.xlsx
   - Final country-level natural-capital/GDP dataset used for later
     transformations.

4. nk_world.dta / nk_world.xlsx
   - World-level natural-capital aggregates. These aggregates may be used for
     the model calibration.

5. matlab_data_nomin_noene.xlsx
   - Baseline CES-estimation dataset excluding missing minerals and energy.
   - Used in the first-nest CES estimation routines.

6. matlab_data_allnormal.xlsx
   - CES-estimation-ready dataset with normalized natural-capital variables.
   - Included for completeness but not used as the baseline estimation file.

7. matlab_data_fossil_renew.xlsx
   - Baseline second-layer CES dataset for fossil versus renewable energy.

8. matlab_data_fossil.xlsx
   - Baseline third-layer CES dataset for coal versus oil/gas.

Kmenta/CES estimation sections:

The do-file includes Kmenta-approximation regressions for the CES structure.

Second layer:

- Fossil energy versus renewable energy.
- Main variables include ln_energy_prod, log_foss, log_renew, and sq_term.

Third layer:

- Coal versus oil/gas.
- Main variables include log_fossil_cons, log_coal, log_og, and sq_term.

Required Stata packages/commands:

The file uses Stata commands including:

- import excel
- export excel
- reshape
- merge
- encode
- egen
- ipolate
- carryforward
- reghdfe

The user should ensure that required user-written packages are installed,
especially:

- reghdfe
- carryforward

If needed, install them in Stata using:

ssc install reghdfe, replace
ssc install carryforward, replace

Depending on the Stata setup, reghdfe may also require related dependencies
such as ftools.


Step 2: Python ADAM and neural-network CES estimation
-----------------------------------------------------

Folder:

- Adam_CES_estimation/

Purpose:

This folder contains Python scripts that estimate CES parameters using
TensorFlow and the Adam optimizer for the first nest, and neural-network
estimation for the second and third nests. The scripts estimate distribution
parameters, elasticities of substitution, scale parameters, and related CES
weights for the different layers.

Master script:

- Adam_CES_estimation/ADAM_CES_estimation_master_file.py

The master file runs the underlying scripts for the different layers and
specifications. Each file will also produce .xlsx output that will contain the estimated parameters and associated standard errors. Before using the master file, update script_paths so that they point to the local script locations.

Scripts:

First layer:

- Adam_CES_estimation/First Layer/ces_first_layer_ml.py
- Adam_CES_estimation/First Layer/ces_first_layer_ene_prod.py
- Adam_CES_estimation/First Layer/ces_first_layer_rolling_est.py

The first-layer scripts estimate CES production functions using TensorFlow and
the Adam optimizer. They cover:

- the full natural-capital specification;
- the energy-only natural-capital specification;
- rolling-window estimates.

The first-layer scripts require the cleaned Excel input:

- matlab_data_nomin_noene.xlsx

Second layer:

- Adam_CES_estimation/Second Layer/nne_nat_cap_second_layer.py
- Adam_CES_estimation/Second Layer/nne_nat_cap_second_layer_upsilon.py

These scripts use neural-network estimation to estimate a two-input CES energy
production function for fossil and renewable energy. The scripts generate
simulated moment-based training data and then predict the parameters from the
observed data moments.

The second-layer scripts require:

- matlab_data_fossil_renew.xlsx

Third layer:

- Adam_CES_estimation/Third Layer/nne_nat_cap_third_layer.py
- Adam_CES_estimation/Third Layer/nne_nat_cap_third_layer_upsilon.py

These scripts use the same neural-network estimation logic for the fossil
energy nest, with coal and the oil-gas composite as inputs.

The third-layer scripts require:

- matlab_data_fossil.xlsx

Fixed versus estimated returns to scale:

Scripts with the suffix _upsilon estimate the returns-to-scale parameter
upsilon in addition to the CES weights, scale parameter, and elasticity. Scripts
without the suffix keep the corresponding specification fixed.

Main Python packages:

- tensorflow
- pandas
- numpy
- scipy
- scikit-learn
- matplotlib
- multiprocessing
- random
- pathlib

The exact imports differ across scripts.

Python outputs:

The scripts print parameter estimates, bootstrap averages, and standard errors
to the console. The rolling first-layer script also exports rolling estimates
to CSV files; update the output CSV paths in that script before running it on a
new machine.


Step 3: MATLAB CES bootstrap estimation
---------------------------------------

Folder:

- Matlab_CES_estimation/

Master script:

- Matlab_CES_estimation/master_file_sqp.m

The master file runs the underlying scripts for the different layers and
specifications. The master file runs each of the underlying scripts in separate sessions. 

Purpose:

This folder contains MATLAB scripts used to estimate CES parameters and
bootstrap their sampling uncertainty. The estimation procedure follows
Appendix B.2 and performs 1,000 bootstrap replications. In each replication,
the data are resampled with replacement and the CES model is re-estimated.
A pre-generated set of random seeds is used to make the parallel bootstrap
process reproducible.

Folder structure and scripts:

First layer:

- Matlab_CES_estimation/First Layer/ces_complete_case_bootstrap.m
- Matlab_CES_estimation/First Layer/ces_complete_case_bootstrap_upsilon.m
- Matlab_CES_estimation/First Layer/ces_energy_prod_complete_bootstrap.m
- Matlab_CES_estimation/First Layer/ces_energy_prod_complete_bootstrap_upsilon.m

The first two scripts estimate the full natural-capital first nest. The energy
production scripts estimate the first-nest case where only the energy natural
capital component is included.

Second layer:

- Matlab_CES_estimation/Second Layer/ces_second_layer_bootstrap.m
- Matlab_CES_estimation/Second Layer/ces_second_layer_bootstrap_upsilon.m

These scripts estimate the fossil-versus-renewable energy nest.

Third layer:

- Matlab_CES_estimation/Third Layer/ces_third_layer_bootstrap.m
- Matlab_CES_estimation/Third Layer/ces_third_layer_bootstrap_upsilon.m

These scripts estimate the fossil-energy nest over coal, oil, and gas.

Fixed versus estimated returns to scale:

As in the Python folder, scripts with the suffix _upsilon estimate the
returns-to-scale parameter upsilon. Scripts without _upsilon use the fixed
returns-to-scale specification.

MATLAB inputs:

The MATLAB scripts read the cleaned Excel files produced by the Stata
cleaning script:

- matlab_data_nomin_noene.xlsx
- matlab_data_fossil_renew.xlsx
- matlab_data_fossil.xlsx

Before running the scripts on a new machine, update the readtable paths in
each MATLAB file so that they point to the local cleaned-data folder.

MATLAB outputs:

The key outputs are .xlsx files for different specifications discussed earlier that contains the parameter estimates and associated standard errors. 

Each script also reports:

- estimated CES parameters from the full sample;
- mean bootstrap parameter estimates;
- bootstrap standard errors;
- 95 percent percentile confidence intervals.

The bootstrap results are then used to compare specifications and compute the
MSE measures reported in the paper and appendix.


How the estimates enter the quantitative model
----------------------------------------------

The CES estimates are used to calibrate the production weights, elasticities,
and scale parameters in the model files under:

- Model_Simulations/NC_Model/
- Model_Simulations/Fossil_Model/

In the natural-capital model, the estimated structure maps into:

- the first aggregate-output nest;
- the second energy nest;
- the third fossil-energy nest.

In the fossil-only benchmark, only the aggregate production structure relevant
to the fossil-energy-only model is used.

When updating model calibrations, check that the selected estimates correspond
to the specification used in the paper, especially whether upsilon is fixed or
estimated in the relevant CES layer.
