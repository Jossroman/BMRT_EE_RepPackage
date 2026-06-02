README: Short-run IRF exercise
January 2026
G. Benmir, A. Mori, J. Roman, R. Tarsia

This folder reproduces the short-run impulse-response figures for a fossil-fuel
discovery shock. The shock is calibrated inside the script to generate a
10 percent increase in the gas stock on impact.


1. Requirements
---------------

Use MATLAB with Dynare available on the MATLAB path. The script calls the
natural-capital model in:

    ../NC_Model/NC_SCC_Hybrid.mod

Run the script from:

    Model_Simulations/IRF_Exercise


2. Main script
--------------

- compute_irf_figures.m
  Runs the first-order discovery-shock IRF, the two perfect-foresight variants
  of the same shock, and the IRF decomposition used in the paper.

  The perfect-foresight variants are:

      surprise discovery shock
      anticipated discovery shock

  The AR-parameter comparison figure is not part of this streamlined workflow.

Helper functions used by the script are stored in:

    utilities/


3. Replication step
-------------------

Run the following command in MATLAB from Model_Simulations/IRF_Exercise:

    compute_irf_figures


4. Expected outputs
-------------------

The outputs are saved in:

    figures/

Expected PDF files:

- figures/paper_fig6.pdf
  First-order impulse responses of the gas stock and selected natural-capital
  production variables to the gas discovery shock.

- figures/paper_fig15.pdf
  Comparison of first-order, non-linear surprise, and non-linear anticipated
  gas-discovery responses.

- figures/paper_fig7.pdf
  Decomposition of the responses of final output, welfare, and emissions into
  grouped channels such as stocks, preferences, and climate dynamics.


5. Notes
--------

- The shock size is chosen internally so that the gas stock rises by 10 percent
  on impact.

- The exercise uses the natural-capital model only. The fossil-energy-only model
  is not used in this folder.
