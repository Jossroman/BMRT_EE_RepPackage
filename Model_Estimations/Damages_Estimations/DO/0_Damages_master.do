/********************************************************************
 Master do-file
 Runs the cleaning and paper do-files in sequence
********************************************************************/

clear all
set more off
set rmsg on

*--------------------------------------------------*
* Set main project path. Run this file from Model_Estimations/Damages_Estimations.
*--------------------------------------------------*
global path_main "."

cd "${path_main}"

*define Damages locals to run specific parts of the code (Set = 1 to run and to 0 otherwise): 
global u_root			= 1	
global damages 			= 1
global coint_ecm 		= 1 	

*Create folders 
cap mkdir "${path_main}/Data/dta_clean"

cap mkdir "${path_main}/Damages_results"
cap mkdir "${path_main}/Damages_results/Tables"

cap mkdir "${path_main}/Statistics"


*--------------------------------------------------*
* Run do-files
*--------------------------------------------------*

*1) run cleaning procedure 
noi di as result "Running Damages_cleaning.do"
do "${path_main}/DO/1_Damages_cleaning.do"
noi di as result "Finished Damages_cleaning.do"

*2) Estimate climate damages 
noi di as result "Running Damages_paper.do"
do "${path_main}/DO/2_Damages_paper.do"
noi di as result "Finished Damages_paper.do"


set rmsg off 





