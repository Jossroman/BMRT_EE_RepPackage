/*
Purpose of this do-file:

This do-file cleans and prepares the natural capital, GDP, and energy datasets used for the
natural-capital CES estimation exercise.

The file has two main functions:

1. Data cleaning and harmonisation:
   - Imports raw Excel datasets.
   - Constructs country-year identifiers.
   - Merges natural capital and GDP datasets.
   - Handles missing values using interpolation and carry-forward/backward filling.
   - Creates logged, normalised, and transformed variables used in later estimation.

2. CES/Kmenta preparation and estimation:
   - Prepares datasets for MATLAB-based CES estimation.
   - Creates second-layer CES variables for fossil versus renewable energy.
   - Creates third-layer CES variables for coal versus oil/gas.
   - Runs Kmenta-approximation OLS regressions for the second and third CES layers.

Path structure:
Only edit the globals below if the project folder moves. All imports, intermediate outputs,
cleaned outputs, and MATLAB-export files should reuse these globals rather than hard-coded paths.
*/

* ============================== PATH SETUP ==============================
* Run this do-file from Model_Estimations/CES_Estimations.
global project_root "."
* Main project folders.
global raw_nc       "../Damages_Estimations/Data/Raw_xlsx"
global clean_nc     "Cleaned_Files"
capture mkdir "$clean_nc"

* Raw input files.
global gdp_file             "$raw_nc/gdp 2015.xlsx"
global natural_capital_file "$raw_nc/Natural Capital.xlsx"
global energy_file          "$raw_nc/Energy.xlsx"

* Cleaned/intermediate Stata datasets.
global gdp_dta                  "$clean_nc/gdp.dta"
global natural_cap_country_dta  "$clean_nc/natural_cap_country.dta"
global nk_country_final_dta     "$clean_nc/nk_country_final.dta"
global nk_country_final_raw_dta "$clean_nc/nk_country_final.dta"
global nk_world_dta             "$clean_nc/nk_world.dta"

* Cleaned/intermediate Excel outputs.
global gdp_xlsx                  "$clean_nc/gdp.xlsx"
global natural_cap_country_xlsx  "$clean_nc/natural_cap_country.xlsx"
global nk_country_final_xlsx     "$clean_nc/nk_country_final.xlsx"
global nk_world_xlsx             "$clean_nc/nk_world.xlsx"

* Estimation Excel outputs for MATLAB and Python estimation
global clean_nomin_noene_xlsx    "$clean_nc/matlab_data_nomin_noene.xlsx"
global clean_allnormal_xlsx      "$clean_nc/matlab_data_allnormal.xlsx"
global clean_fossil_renew_xlsx   "$clean_nc/matlab_data_fossil_renew.xlsx"
global clean_fossil_xlsx         "$clean_nc/matlab_data_fossil.xlsx"
* =======================================================================

*THE STEPS: 

*1) Clean the GDP data
*2) Clean the natural capital data
*3) Merge natural capital with GDP data
*4) Prepare datasets for NLS CES estimation
*5) Run Kmenta-approximation OLS regressions for the second and third layer

*PREP FOR CES ESTIMATION
*1) Specification where we drop missing energy and minerals (Baseline)
*2) Specification where we do not drop anything


*################################################################## GDP DATASET CLEANING #################################################
clear all

import excel "$gdp_file", sheet("Sheet1") firstrow

* NOTE THAT THE GDP IS IN CONSTANT 2015 USD AND TO CONVERT IT TO 2018 CONSTANT USD
* WE WILL SIMPLY FIND THE DEFLATOR VALUE IN 2015 AND DEFLATOR VALUE IN 2018 AND MULTIPLY EACH 
* COUNTRIES' GDP WITH THE RATIO OF 2018:2015 DEFLATOR VALUE. 

*RATIO = 105/100 = 1.05

local year 1960
foreach var of varlist E-BP {
    rename `var' gdp`year'
    local year = `year' + 1
}

drop IndicatorName IndicatorCode

rename CountryName country

rename CountryCode countrycode

reshape long gdp, i(country countrycode) j(year)

sort country year

* Fill missing values at the start with the next available value
bysort country: carryforward gdp, replace

* Reverse sort by year to carry the last known value forward
gsort country -year

* Fill missing values at the end (now at the start due to reverse sort)
bysort country: carryforward gdp, replace

* Re-sort by country and year to return to original order
sort country year

* Linear interpolation for missing values
bysort country: ipolate gdp year, gen(gdp_interp)

drop gdp_interp

sort country year

drop if year < 1995

drop if year > 2018

gen str_year = string(year, "%12.0f")

gen id = countrycode + "." + str_year

gen gdp_2018_rebase = gdp * 1.05

drop gdp 

rename gdp_2018_rebase gdp

drop if missing(gdp)

save "$gdp_dta", replace

export excel using "$gdp_xlsx", firstrow(variables) replace

clear all

*######################################### NATURAL CAPITAL DATASET CLEANING (MINIMAL) ############################################

import excel "$natural_capital_file", sheet("Sheet1") firstrow clear

drop if year == 0

foreach var in for_tim for_notim mangroves fisheries pa land cropland pasture subsoil ene oil gas coal min nk pk totwealth hc hc_m hc_emp_m hc_self_m hc_f hc_emp_f hc_self_f renew {
    destring `var', replace force
}

* This is to get rid of missing values usually for countries that do not have any oil, gas or coal. This comes from the unbalanced panel being made balanced in questionable ways.
foreach var in for_tim for_notim mangroves fisheries pa land cropland pasture subsoil ene oil gas coal min {
	replace `var' = 0 if `var' == .
}

*(0 real changes made)
*(0 real changes made)
*(0 real changes made)
*(0 real changes made)
*(0 real changes made)
*(0 real changes made)
*(0 real changes made)
*(0 real changes made)
*(0 real changes made)
*(0 real changes made)
*(10 real changes made)
*(30 real changes made)
*(7 real changes made)
*(0 real changes made)

encode wb_name, gen(ncountry)

drop wb_name 

save "$natural_cap_country_dta", replace

export excel using "$natural_cap_country_xlsx", firstrow(variables) replace

use "$natural_cap_country_dta", clear

merge 1:1 id using "$gdp_dta"

drop if _merge == 1| _merge == 2

drop _merge country countrycode str_year

sort ncountry year

*THERE ARE SOME SPURIOUS ZEROES AND THIS IS TO CLEAN THEM. 

*1) This part is to convert all zeros to `.' even if all years are missing for a particular country. 

foreach var in totwealth pk nk renew for_tim for_notim mangroves fisheries pa land cropland pasture subsoil ene oil gas coal min {
    *This creates an indicator for rows where `var` equals 0
    gen miss_`var' = (`var' == 0)
    
    // Sum these indicators by ncountry
    bysort ncountry: egen total_missing_`var' = total(miss_`var')
    
    // Replace 0 with missing if the total zeros are fewer than 24 in the group
    bysort ncountry: replace `var' = . if `var' == 0 & total_missing_`var' < 24
}

*2) Now I will attempt to clean these by interpolation and carryingforward.

foreach var in totwealth pk nk renew for_tim for_notim mangroves fisheries pa land cropland pasture subsoil ene oil gas coal min {
	sort ncountry year
	bysort ncountry: carryforward `var', replace
	gsort ncountry -year
	bysort ncountry: carryforward `var', replace
	sort ncountry year
	bysort ncountry: ipolate `var' year, gen(`var'_interp)
	drop `var'
	rename `var'_interp `var'
}


save "$nk_country_final_dta", replace

export excel using "$nk_country_final_xlsx", firstrow(variables) replace

* Create a new variable that is the sum of selected variables for each observation
egen total_sum_by_country_year = rowtotal(for_tim for_notim mangroves fisheries pa land cropland pasture subsoil ene oil gas coal min gdp nk pk hc)

* Sum these variables by year to get world-level natural capital aggregates. 
collapse (sum) for_tim for_notim mangroves fisheries pa land cropland pasture subsoil ene oil gas coal min gdp pk nk hc, by(year)

save "$nk_world_dta", replace

* Export the dataset to an Excel file
export excel using "$nk_world_xlsx", firstrow(variables) replace

*####################################################### PREPARING TO BE USED FOR MATLAB - DROPPING IF MINERALS AND ENERGY = 0 ###########

use "$nk_country_final_dta", clear

rename ncountry country

sort country year

xtset country year

drop miss_totwealth total_missing_totwealth miss_pk total_missing_pk miss_nk total_missing_nk miss_renew total_missing_renew miss_for_tim total_missing_for_tim miss_for_notim total_missing_for_notim miss_mangroves total_missing_mangroves miss_fisheries total_missing_fisheries miss_pa total_missing_pa miss_land total_missing_land miss_cropland total_missing_cropland miss_pasture total_missing_pasture miss_subsoil total_missing_subsoil miss_ene total_missing_ene miss_oil total_missing_oil miss_gas total_missing_gas miss_coal total_missing_coal miss_min total_missing_min

egen regionid = group(wb_region)

egen incomeid = group(wb_income)

gen prod = (pk^(1/3))*((hc)^(2/3))

*foreach var in for_tim for_notim land ene min cropland fisheries{
*	bysort country: gen `var'_n = `var'/25
*	gen `var'_rn = `var'_n/(10^10)
*}

*gen gdp_n = gdp/(10^10)

*gen prod_n = prod/(10^10)

foreach var in gdp pk hc for_tim for_notim land ene min cropland prod fisheries{
	bysort country: gen `var'_n = `var'/(10^10)
}

gen for_n = for_notim_n + for_tim_n

gen ln_gdp = log(gdp_n)

drop if min_n == 0

drop if ene_n == 0

*drop if incomeid == 3| incomeid == 5

*drop if fisheries_n == 0
*this is how you get to 1632 observations.

export excel using "$clean_nomin_noene_xlsx", firstrow(variables) replace

*####################################################### PREPARING TO BE USED FOR MATLAB NO CHANGES ######################################
use "$nk_country_final_raw_dta", clear

rename ncountry country

sort country year

xtset country year

sort country year

egen regionid = group(wb_region)

egen incomeid = group(wb_income)

gen prod = (pk^(1/3))*((hc)^(2/3))


foreach var in gdp pk hc labour_force for_tim for_notim land ene min cropland prod{
	bysort country: gen `var'_n = `var'/(10^10)
}

gen ln_gdp = log(gdp_n)

export excel using "$clean_allnormal_xlsx", firstrow(variables) replace

*################################################# CLEANING FOR SECOND LAYER CES ESTIMATION ###############################################

import excel "$energy_file", sheet("Sheet1") firstrow clear

sort country year

rename iso_code countrycode

*Gets rid of entries like ASEAN
drop if missing(countrycode)

gen str_year = string(year, "%12.0f")

gen id = countrycode + "." + str_year

merge 1:1 id using "$nk_country_final_dta", force

drop if _merge == 1| _merge == 2

drop _merge

drop miss_totwealth total_missing_totwealth miss_pk total_missing_pk miss_nk total_missing_nk miss_renew total_missing_renew miss_for_tim total_missing_for_tim miss_for_notim total_missing_for_notim miss_mangroves total_missing_mangroves miss_fisheries total_missing_fisheries miss_pa total_missing_pa miss_land total_missing_land miss_cropland total_missing_cropland miss_pasture total_missing_pasture miss_subsoil total_missing_subsoil miss_ene total_missing_ene miss_oil total_missing_oil miss_gas total_missing_gas miss_coal total_missing_coal miss_min total_missing_min

drop country 

rename ncountry country

*gen energy_prod = (fossil_electricity + renewables_electricity + nuclear_electricity)*(10^9)

*gen fossil_energy = fossil_energy_per_capita*population

*gen renew_energy = renewables_energy_per_capita*population

*gen nuc_energy = nuclear_energy_per_capita*population

*gen energy_cons = fossil_energy + renew_energy + nuc_energy 

sort country year

*FEEL FREE TO ADD MORE. 
*foreach var in oil_production gas_production coal_production low_carbon_electricity fossil_electricity renewables_electricity{
*    gen m1_`var' = (`var' == 0)
    
*    bysort country: egen tm1_`var' = total(m1_`var')
    
*    bysort country: replace `var' = . if `var' == 0 & tm1_`var' < 24
*}

*drop m1_oil_production tm1_oil_production m1_gas_production tm1_gas_production m1_coal_production tm1_coal_production m1_low_carbon_electricity tm1_low_carbon_electricity m1_fossil_electricity tm1_fossil_electricity m1_renewables_electricity tm1_renewables_electricity

foreach var in electricity_demand fossil_electricity renewables_electricity{
	sort country year
	bysort country: ipolate `var' year, gen(`var'_in)
	drop `var'
	rename `var'_in `var'
	bysort country: carryforward `var', replace
	gsort country -year
	bysort country: carryforward `var', replace
	sort country year
} 

*gen energy_prod = (fossil_electricity + renewables_electricity + nuclear_electricity)

gen energy_prod = electricity_demand

*gen fossil_cons = (oil_consumption + gas_consumption + coal_consumption)

*gen renew_cons = (nuclear_consumption + biofuel_consumption + hydro_consumption + solar_consumption + wind_consumption)

gen fossil_energy = fossil_electricity

gen renew_energy = renewables_electricity

* This variable is to check for the feasibility of energy ces estimation. This must sum to be higher than the output. 
gen energy_cons = fossil_energy + renew_energy

*This is to group energies into fossil and non-fossil fuel. 
*gen non_fossil_energy = renew_energy + nuc_energy

drop if missing(fossil_energy)| missing(energy_prod)| missing(renew_energy)


gen ln_energy_prod = log(energy_prod)

egen incomeid = group(wb_income)

egen regionid = group(wb_region)

*drop if incomeid == 3| incomeid == 4

gen log_foss = log(fossil_energy)

gen log_renew = log(renew_energy)

gen sq_term = (log_foss - log_renew)^2

*IMPORTANT: The line below generates the Kmenta approximation OLS results for the second layer
reghdfe ln_energy_prod log_foss log_renew sq_term, absorb(country) vce(robust)

export excel using "$clean_fossil_renew_xlsx", firstrow(variables) replace

levelsof incomeid, local(incomeids)

foreach income in `incomeids'{
	di "Processing region ID: `income'"
	preserve
	keep if incomeid == `income'
	reghdfe ln_energy_prod log_foss log_renew sq_term, absorb(country) vce(robust)
	estimates store est_`income'
	restore
}
*############################################### CLEANING FOR THIRD LAYER CES ESTIMATION ##################################################

import excel "$energy_file", sheet("Sheet1") firstrow clear

sort country year

rename iso_code countrycode

*Gets rid of entries like ASEAN
drop if missing(countrycode)

gen str_year = string(year, "%12.0f")

gen id = countrycode + "." + str_year

merge 1:1 id using "$nk_country_final_dta", force

drop if _merge == 1| _merge == 2

drop _merge

drop miss_totwealth total_missing_totwealth miss_pk total_missing_pk miss_nk total_missing_nk miss_renew total_missing_renew miss_for_tim total_missing_for_tim miss_for_notim total_missing_for_notim miss_mangroves total_missing_mangroves miss_fisheries total_missing_fisheries miss_pa total_missing_pa miss_land total_missing_land miss_cropland total_missing_cropland miss_pasture total_missing_pasture miss_subsoil total_missing_subsoil miss_ene total_missing_ene miss_oil total_missing_oil miss_gas total_missing_gas miss_coal total_missing_coal miss_min total_missing_min

drop country 

rename ncountry country

sort country year

foreach var in fossil_electricity coal_production oil_production gas_production{
    gen m1_`var' = (`var' == 0)
    
    bysort country: egen tm1_`var' = total(m1_`var')
    
    bysort country: replace `var' = . if `var' == 0 & tm1_`var' < 24
}

drop m1_fossil_electricity tm1_fossil_electricity m1_coal_production tm1_coal_production m1_oil_production tm1_oil_production m1_gas_production tm1_gas_production

foreach var in fossil_electricity coal_production oil_production gas_production{
	sort country year
	bysort country: ipolate `var' year, gen(`var'_interp)
	drop `var'
	rename `var'_interp `var'
	bysort country: carryforward `var', replace
	gsort country -year
	bysort country: carryforward `var', replace
	sort country year
} 

drop if missing(coal_production) | missing(oil_production) | missing(gas_production)| missing(fossil_electricity)

foreach var in coal_production oil_production gas_production fossil_electricity{
	gen `var'_n = `var'/(100)
}

egen incomeid = group(wb_income)

egen regionid = group(wb_region)

gen log_fossil_cons = log(fossil_electricity)

gen oil_gas = oil_production_n + gas_production_n

gen log_og = log(oil_gas)

gen log_oil = log(oil_production_n)

gen log_gas = log(gas_production_n)

gen log_coal = log(coal_production_n)

gen log_oc = log(oil_production_n/coal_production_n)

gen log_gc = log(gas_production_n/coal_production_n)

gen log_ocgc = log_gc*log_oc 

gen log_oc_sq = (log_oc)^2

gen log_gc_sq = (log_gc)^2

reghdfe log_fossil_cons log_coal log_gc log_oc log_gc_sq log_oc_sq log_ocgc, absorb(country) vce(robust) 

gen sq_term = (log_og - log_coal)^2

*IMPORTANT: The line below generates the Kmenta approximation OLS results for the third layer
reghdfe log_fossil_cons log_coal log_og sq_term, absorb(country) vce(robust)

gen total_energy = coal_production + oil_production + gas_production

gen check_net_importer = (fossil_electricity - total_energy)

*bysort country: egen net_importer_flag = max(check_net_importer > 0)

* Drop all observations for countries that are net importers in any year
*drop if net_importer_flag == 1

export excel using "$clean_fossil_xlsx", firstrow(variables) replace

levelsof incomeid, local(incomeids)

foreach income in `incomeids'{
	di "Processing region ID: `income'"
	preserve
	keep if incomeid == `income'
	reghdfe log_fossil_cons log_coal log_og sq_term, absorb(country) vce(robust)
	estimates store est_`income'
	restore
}
