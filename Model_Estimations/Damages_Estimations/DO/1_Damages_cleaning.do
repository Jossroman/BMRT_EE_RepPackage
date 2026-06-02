
******************************
*		Cleaning Procedure  *
******************************

*1) Clean the climate data (WB code in parenthesys)
	*1.1) Tempp (ts)
	*1.2) Precip (pr)
*2) Clean the GDP data
*3) Clean Natural capital 
*4) Clean Arable Land 
*5) Clean Energy data 
*6) Merge datasets 
	*6.1) Merge when all variables avialable
	*6.2) Merge when all variables available for GDP & Temp & at least 1 other dta



*######################## 1) CLIMATE CLEANING ######################################
*1.1) Temp 
import excel "${path_main}/Data/Raw_xlsx/Temperature.xlsx", sheet("Sheet1") firstrow clear

*Renaming for reshaping
local year 1950
foreach var of varlist C-BW{
	rename `var' temp`year'
	local year = `year'+1
}

rename name country

rename code countrycode

reshape long temp, i(country countrycode) j(year)

* This is to make stubs and codes into two different variables. 
gen code = regexs(1) if regexm(countrycode, "(^[^.]+)\.(\d+)$")
gen stub = regexs(2) if regexm(countrycode, "(^[^.]+)\.(\d+)$")

* Aggregated country does not have a stub or a code
keep if missing(code)

drop code stub

sort country year

* Convert year to a string with an appropriate format
gen str_year = string(year, "%12.0f")

* Concatenate country_code with year, using a period as a separator. This is to create a unique identifier as used in the natural capital dataset. 
gen id = countrycode + "." + str_year

*drop if year < 1995 
drop if year > 2018

*China and finland are repeated country-year, drop taiwan and another 
drop if countrycode == "TWN" | countrycode == "ALA"
drop if country == "France" & countrycode != "FRA"


save "${path_main}/Data/dta_clean/temp_clean.dta", replace


*1.2) Precip 
import excel "${path_main}/Data/Raw_xlsx/Precipitation.xlsx", sheet("all") firstrow clear

*Renaming for reshaping
local year 1950
foreach var of varlist C-BW{
	rename `var' precip`year'
	local year = `year'+1
}

rename name country

rename code countrycode

reshape long precip, i(country countrycode) j(year)

* This is to make stubs and codes into two different variables. 
gen code = regexs(1) if regexm(countrycode, "(^[^.]+)\.(\d+)$")
gen stub = regexs(2) if regexm(countrycode, "(^[^.]+)\.(\d+)$")

* Aggregated country does not have a stub or a code
keep if missing(code)

drop code stub

sort country year

* Convert year to a string with an appropriate format
gen str_year = string(year, "%12.0f")

* Concatenate country_code with year, using a period as a separator. This is to create a unique identifier as used in the natural capital dataset. 
gen id = countrycode + "." + str_year

*drop if year < 1995 
drop if year > 2018

*China and finland are repeated country-year, drop taiwan and another 
drop if countrycode == "TWN" | countrycode == "ALA"
drop if country == "France" & countrycode != "FRA"

save "${path_main}/Data/dta_clean/precip_clean.dta", replace



*##################### 2) GDP DATASET CLEANING ########################################
clear all
import excel "${path_main}/Data/Raw_xlsx/gdp 2015.xlsx", sheet("Sheet1") firstrow

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

save "${path_main}/Data/dta_clean/gdp.dta", replace


*#################### 3) NATURAL CAPITAL DATASET CLEANING ###########################

import excel "${path_main}/Data/Raw_xlsx/Natural Capital.xlsx", sheet("Sheet1") firstrow clear

drop if year == 0

drop if year < 1995
drop if year > 2018

foreach var in for_tim for_notim mangroves fisheries pa land cropland pasture subsoil ene oil gas coal min nk pk totwealth hc hc_m hc_emp_m hc_self_m hc_f hc_emp_f hc_self_f renew {
    destring `var', replace force
}

* This is to get rid of missing values usually for countries that do not have any oil, gas or coal. This comes from the unbalanced panel being made balanced in questionable ways.
foreach var in for_tim for_notim mangroves fisheries pa land cropland pasture subsoil ene oil gas coal min {
	replace `var' = 0 if `var' == .
}

encode wb_name, gen(ncountry)
drop wb_name 

save "${path_main}/Data/dta_clean/natural_cap_country.dta", replace



*1) This part is to convert all zeros to `.' even if all years are missing for a particular country. 
foreach var in totwealth pk nk renew for_tim for_notim mangroves fisheries pa land cropland pasture subsoil ene oil gas coal min {
    *This creates an indicator for rows where `var` equals 0
    gen miss_`var' = (`var' == 0)
    
    // Sum these indicators by ncountry
    bysort ncountry: egen total_missing_`var' = total(miss_`var')
    
    // Replace 0 with missing if the total zeros are fewer than 24 in the group
    bysort ncountry: replace `var' = . if `var' == 0 & total_missing_`var' < 24
}

drop *miss*

*2) Now clean these by interpolation and carryingforward.
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


save "${path_main}/Data/dta_clean/nk_country_clean.dta", replace




*######################## 4) ARABLE LAND DATA. ##############################
*NOTE: THIS IS IN HECTARES PER CAPITA 

clear all

import excel "${path_main}/Data/Raw_xlsx/Arable Land.xlsx", sheet("Sheet1") firstrow

local year 1960
foreach var of varlist E-BP{
	rename `var' cropland`year'
	local year = `year'+1
}

drop IndicatorName IndicatorCode

rename CountryName country
rename CountryCode countrycode

reshape long cropland, i(country countrycode) j(year)

sort country year

drop if year < 1995
drop if year > 2018

sort country year

gen str_year = string(year, "%12.0f")

gen id = countrycode + "." + str_year

save "${path_main}/Data/dta_clean/cropland_clean.dta", replace





*##################### 5) ENERGY DATASET ###############################################

import excel "${path_main}/Data/Raw_xlsx/Energy.xlsx", sheet("Sheet1") firstrow clear

sort country year
rename iso_code countrycode

*drop gdp as alreay in gdp file 
drop gdp 


*Gets rid of entries like ASEAN
drop if missing(countrycode)

gen str_year = string(year, "%12.0f")

gen id = countrycode + "." + str_year

****NOTE: previous DO was merging with other dta so these values dropped
*if you don't drop these then missing values and most countries will be drop below (drop more than 10 missing values)
drop if year < 1995
drop if year > 2018


foreach var in coal_production coal_consumption gas_production gas_consumption oil_production oil_consumption fossil_fuel_consumption energy_per_capita population {
    destring `var', replace force
}

foreach var in coal_production coal_consumption gas_production gas_consumption oil_production oil_consumption fossil_fuel_consumption energy_per_capita population{
	sort country year
	* Linear interpolation for missing values
	bysort country: ipolate `var' year, gen(`var'_interp)
	
	drop `var'	
	rename `var'_interp `var'
	bysort country: carryforward `var', replace
	gsort country -year
	bysort country: carryforward `var', replace
	sort country year
} 

*create enery here because pop (in main file) and population here slightly different
gen energy = energy_per_capita*population

sort country year

foreach var in energy{
    gen m1_`var' = (`var' == 0)    
    bysort country: egen tm1_`var' = total(m1_`var')
    bysort country: replace `var' = . if `var' == 0 & tm1_`var' < 24
}

drop tm1_energy m1_energy


foreach var in energy{
	bysort country: carryforward `var', replace
	gsort country -year
	bysort country: carryforward `var', replace
	sort country year
	bysort country: ipolate `var' year, gen(`var'_interp)
	drop `var'
	rename `var'_interp `var'
}


*Here we drop the country if more than 10 missing. Feel free to adjust. 
foreach var in coal_production gas_production oil_production fossil_fuel_consumption energy renewables_electricity{
egen m_`var' = rowmiss(`var')
bysort country: egen tm_`var' = sum(m_`var')
bysort country: drop if tm_`var' > 10
}

drop m_coal_production tm_coal_production m_gas_production tm_gas_production m_oil_production tm_oil_production m_fossil_fuel_consumption tm_fossil_fuel_consumption m_energy tm_energy m_renewables_electricity tm_renewables_electricity

foreach var in coal_production gas_production oil_production fossil_fuel_consumption energy renewables_electricity{
bysort country: carryforward `var', replace
gsort country -year
bysort country: carryforward `var', replace
sort country year
bysort country: ipolate `var' year, gen(`var'_in)
drop `var'
rename `var'_in `var'
}


save "${path_main}/Data/dta_clean/energy_clean.dta", replace




*##################### 5) TFP DATASET ####################################


import excel "${path_main}/Data/Raw_xlsx/TFP_1001.xlsx", sheet("Data") firstrow clear
keep country countrycode country year rtfpna
rename rtfpna tfp_ind

sort country year

drop if missing(countrycode)
gen str_year = string(year, "%12.0f")
gen id = countrycode + "." + str_year


drop if year < 1995
drop if year > 2018

*change index values
gen tfp_aux_1995 = tfp_ind if year == 1995

carryforward tfp_aux_1995, replace 
gen tfp_ind_95 = tfp_ind/tfp_aux_1995
replace tfp_ind = tfp_ind_95
drop tfp_aux_1995 tfp_ind_95


save "${path_main}/Data/dta_clean/tfp_clean.dta", replace




****************************************
****	6) Merge all datasets
****************************************


**********Create dataset with always merge (if country not available in one dta dropped)
*use GDP
use "${path_main}/Data/dta_clean/gdp.dta", clear
*tab country

*merge with TFP (we looses 250 obs but from marginal countries)
merge 1:1 id using "${path_main}/Data/dta_clean/tfp_clean.dta"
keep if _merge == 3 
drop _merge 

*merge with Tempo
merge 1:1 id using "${path_main}/Data/dta_clean/temp_clean.dta"

keep if _merge == 3 
drop _merge 
*tab country

*merge with Precip
merge 1:1 id using "${path_main}/Data/dta_clean/precip_clean.dta"
keep if _merge == 3 
drop _merge 

*merge with natural cap
merge 1:1 id using "${path_main}/Data/dta_clean/nk_country_clean.dta"
keep if _merge == 3 
drop _merge 
tab country

*merge with cropland
merge 1:1 id using "${path_main}/Data/dta_clean/cropland_clean.dta"
keep if _merge == 3 
drop _merge 
tab country

*merge with energy
merge 1:1 id using "${path_main}/Data/dta_clean/energy_clean.dta"
keep if _merge == 3 
drop _merge 
tab country


*gen totatl cropland from hectars per capita 
gen total_cropland = cropland*pop


*rename and check variables 
rename total_cropland tot_crop
rename *production *prod 
rename fossil_fuel_consumption fossil_cons
rename renewables_electricity ren_electr

label var tot_crop "Total Cropland"
label var fossil_cons "Fossil fuel Consumption"
label var ren_electr "Renewable Energy"
label var for_notim "Natural Capital (no timber)"
label var min "Minerals"


codebook tot_crop coal_prod gas_prod 				///
				oil_prod fossil_cons energy 		///
				ren_electr for_notim min

				
				
****for estimation part 
egen regionid = group(wb_region)
egen incomeid = group(wb_income)

drop countrycode str_year id

*this is the dataset with all countries together 
save "${path_main}/Data/dta_clean/master_clean.dta", replace 


*****Cleaning procedure complete*****


