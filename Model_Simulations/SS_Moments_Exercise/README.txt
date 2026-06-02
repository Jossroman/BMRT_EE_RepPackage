README: Long-run steady state and moments exercise
January 2026
G. Benmir, A. Mori, J. Roman, R. Tarsia

This folder reproduces the steady-state sensitivity figures and stochastic
moments tables for the natural-capital and fossil-only model specifications.
All computation and plotting is done in MATLAB.


1. Requirements
---------------

Use MATLAB with Dynare available on the MATLAB path. Run the scripts from:

    Model_Simulations/SS_Moments_Exercise


2. Scripts
----------

    compute_paper_figures
    compute_paper_tables
    run_moment_exercises

`run_moment_exercises` runs the figure script first and then the table script.


3. Figures
----------

Figures are saved in:

    results/figures/

Expected files:

    paper_fig4.png              SCC comparison
    paper_fig5.png              shadow-price radar, elasticity of substitution
    paper_fig9.png              SCC comparison, climate model Joos et al.
    paper_fig10.png             shadow-price radar, climate damages
    paper_fig11.png             shadow-price radar, discount factor
    paper_fig12.png             shadow-price radar, climate sensitivity


4. Tables
---------

Tables are saved in:

    results/tex_results/

Expected files:

    paper_table4.tex    TFP shock, no habits
    paper_table5.tex    temperature shock 2, no habits
    paper_table30.tex   TFP shock, habits
    paper_table31.tex   temperature shock 2, habits
    paper_table33.tex   temperature shock 1, habits
    paper_table34.tex   temperature shock 1, no habits

The table script reports conditional means and standard deviations of shadow
prices relative to the deterministic benchmark for theta = 0.85, 0.99, 1.93.


5. Notes
--------

The current workflow runs Dynare from temporary work folders for the paper
figures and tables. The figures in the paper were generated in Python. 
For simplicity, we run everything in MATLAB here.
