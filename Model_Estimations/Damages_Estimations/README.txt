README: Damages estimation

This folder contains the Stata code used to clean the damages data and
estimate the climate-damage regressions reported in the paper. The workflow is
organized around three do-files located in the DO folder.

Before running the code, set the Stata working directory to this
Damages_Estimations folder and run DO/0_Damages_master.do. The master file sets
path_main to "." and the rest of the scripts use paths relative to this folder.

Main scripts
------------

1. DO/0_Damages_master.do

This is the master file. It defines paths, creates the required output folders,
and runs the remaining do-files in the correct order.

2. DO/1_Damages_cleaning.do

This script builds the estimation dataset. It cleans and combines:

- climate data, including temperature and precipitation;
- GDP data;
- natural-capital data;
- arable-land data;
- energy data.

The final merged estimation file is saved as:

Data/dta_clean/master_clean.dta

3. DO/2_Damages_paper.do

This script estimates the climate-damage specifications and produces the
tables used in the paper and appendix. The main sections can be switched on or
off inside the do-file using local flags:

- local u_root = 1 runs the unit-root tests and produces the tables reported
  in Appendix section A.2.
- local damages = 1 runs the natural-capital damage regressions and produces
  the main damages table.
- local coint_ecm = 1 runs the cointegration tests and error-correction-model
  robustness checks reported in Appendix section B.3.3.

Outputs
-------

The scripts write cleaned data, diagnostic statistics, and regression tables
to the corresponding subfolders:

- Data/dta_clean/
- Statistics/
- Damages_results/Tables/

The code assumes that Stata can read and write to these folders. If the package
is moved to another machine, no hard-coded local path should need to be edited
as long as the master file is run from the Damages_Estimations folder.
