README: Long-run transition exercise
May 2026
G. Benmir, A. Mori, J. Roman, R. Tarsia

This folder reproduces the long-run transition figures for the natural-capital
model and the energy-only benchmark model. These are the transition figures
reported in the paper:

- paper_fig2.pdf: aggregate GDP, temperature, and the social cost of carbon.
- paper_fig3.pdf: sectoral output components, indexed to 2018.
- paper_fig14.pdf: fossil-fuel components.
- paper_fig13.pdf: long-run convergence of the main input and climate variables.

A single script solves both perfect-foresight transitions and exports all
four figures in one run.


1. Requirements
---------------

Use MATLAB with Dynare available on the MATLAB path. The generated Dynare
driver files in the model folders were produced with Dynare 6.4, so Dynare 6.4
or a close compatible version is recommended.

The transition scripts call the Dynare model files located in the sibling model
folders:

- ../NC_Model/NC_SCC_Hybrid.mod
- ../Fossil_Model/Fossil_SCC_Hybrid.mod

Before running the scripts, open MATLAB from this folder or change the working
directory to:

    Model_Simulations/Transition_Exercise

The plotting script assumes that the saved transition-result folders are inside
this directory.


2. Files in this folder
-----------------------

- compute_transition_paths_and_figures.m
  Single script that solves both perfect-foresight transitions and exports
  all four paper figures. It runs the NC model first, then the energy-only
  model, both with:

      exercise = 2
      habits = 0
      climate_model = 1

  For each model the script loads the stored initial-condition path from
  guess/, sets up the perfect-foresight problem at the same horizon, and
  calls the solver once. Both solved transition paths are held in memory
  and used directly for plotting.

- guess/
  Contains the initial-condition files required by the script:

      guess/pf_guess_nc.mat
      guess/pf_guess_fossil.mat

  These files provide the starting path supplied to the perfect-foresight
  solver. Do not delete or overwrite them.

- figures/
  Output folder for the final PDF figures used in the paper.


3. Replication steps
--------------------

Run the following command in MATLAB from Model_Simulations/Transition_Exercise:

    compute_transition_paths_and_figures

The script runs Dynare for each model, loads the corresponding file from
guess/, solves the full perfect-foresight transition, and exports the four
figures to the figures/ folder. On completion it prints:

    Transition paths and figures completed.

The four output PDFs are written to figures/ as described in section 4.


4. Expected outputs
-------------------

The final replication outputs are the four PDFs written to figures/:

- figures/paper_fig2.pdf
  Compares the natural-capital model and the energy-only model for aggregate
  GDP, temperature, and the social cost of carbon.

- figures/paper_fig3.pdf
  Shows natural-capital sectoral outputs indexed to their 2018 value.

- figures/paper_fig14.pdf
  Shows the transition paths for coal, oil, and gas.

- figures/paper_fig13.pdf
  Shows the long-run convergence paths for aggregate output, temperature, the
  social cost of carbon, and the main model inputs.

These figures correspond to the long-run transition exercise discussed in the
paper section on the social cost of carbon under natural capital.


5. Notes on rerunning
---------------------

- The script overwrites the PDF files in figures/ on each run.
  Back up the folder first if you want to preserve a previous set of figures.

- Both model transitions run inside the same script. If only one model is
  needed, comment out the other block and the corresponding figure calls.

- Some MATLAB versions display small axes toolbar overlays in exported figures.
  The script includes a local helper function, hide_axes_ui, to suppress these
  overlays before exporting the PDFs.

- The files in guess/ are the reference initial conditions. They should not be
  modified or deleted.


6. Troubleshooting checklist
----------------------------

If Dynare cannot be found:

    add the Dynare matlab folder to the MATLAB path, then rerun the script.
