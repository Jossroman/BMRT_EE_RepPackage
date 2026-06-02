***Beneath the Trees: The Influence of Natural Capital on 
*Shadow Price Dynamics in a Macroeconomic Model with Uncertainty
*Author: Romano Tarsia
*Date written: March 2026

*This code carries out the analysis reportes in the climate damages section of the paper and creates the relevant tables:
*Unit-root tests (creates tables in section A.2 of the Online Appendix)
*Natural Capital-specific climate damages (creates Table 3) 
*Cointegration tests and ECM (creates tables 28 and 29 in section B.3.3 of the Appendix)


	 
*Dependent variables (we use pk in the paper not pk_cd and we do not use y_cd)
global dep_var  pk tot_crop for_notim min energy 	///
				fossil_elec ren_electr				///
				coal_elec gas_elec 	oil_elec  		
				
global test_var temp precip gdp tot_crop for_notim min coal_elec gas_elec 		///
				oil_elec fossil_elec energy ren_electr	
				
	

				
				  
				
*Open dta 
use "${path_main}/Data/dta_clean/master_clean.dta", clear 

rename *electricity *elec				

*Create T-squared first OTW stata will automatically estimate the square of the diff and not the diff of the square (see my post on statalist)
gen temp_sq = temp^2
label var temp_sq "Temp_sq"
gen precip_sq = precip^2
label var precip_sq "Precip_sq"

*generate country id for FE
egen co_id = group(country)
*tsset data 
tsset co_id year

*manually gen logs
foreach var of global dep_var {
	gen l_`var' = log(`var')
}



*========================================*
* Unit-root tests
*========================================*


if ${u_root} == 1 {

foreach var of global test_var {

	*Create an empty matrix to store values. REMEMBER: modify X in the rows J(X, 2, .) when changin N(models)
	matrix dir 
	matrix drop _all 
	matrix ADF_test_t = J(6, 2, .)

	quietly {
		*Define columns 
		local columns "Statistic" "p-value"
		*Define rows: first 2 from IPS and others from Fisher (Choi)											
		local rows "Z-ttilde-bar" "W-t-bar" "Inverse chi-squared" ///
				   "Inverse normal" "Inverse logit" "Modified inv. chi-squared"   					

		display "`columns'"
		display "`rows'"

		*define matrices for GO and T
		matrix colnames ADF_test_t = "`columns'"
		matrix rownames ADF_test_t = "`rows'"



		*seems I should use the Im–Pesaran–Shin test because:
		* i)   can be used when N-> infinity and T is fixed (my case)
		* ii)  tests for autocorrelation and applies test on #lasg minimising AIC or BIC
		* iii) can be used for balanced panels 
		noi dis "Augmented Dicky-Fuller (Im–Pesaran–Shin) test - no lags:"
		noi dis "Z-ttilde-bar statistics"
		xtunitroot ips `var' //, lags(aic 3)

		matrix ADF_test_t[1,1] = r(zttildebar) 
		matrix ADF_test_t[1,2] = r(p_zttildebar) 

		matrix list ADF_test_t

		noi dis "Augmented Dicky-Fuller (Im–Pesaran–Shin) test - lags (AIC)"
		noi dis "W-t-bar statistic"
		xtunitroot ips `var', lags(aic 3)

		matrix ADF_test_t[2,1] = r(wtbar) 
		matrix ADF_test_t[2,2] = r(p_wtbar) 

		matrix list ADF_test_t

		*Also use the Fisher - see Choi (2002) introduction
		noi dis "Augmented Dicky-Fuller (Fisher, Chois 2002) test for `var'"
		
		if inlist(`var', temp, precip, min, tot_crop) == 1  {

			xtunitroot fisher `var', dfuller lags(1) //trend		
		}
		else {
			
			xtunitroot fisher `var', dfuller lags(1) trend		
			
		}
		

		matrix ADF_test_t[3,1] = r(P) 
		matrix ADF_test_t[4,1] = r(L)
		matrix ADF_test_t[5,1] = r(Z) 
		matrix ADF_test_t[6,1] = r(Pm) 

		matrix ADF_test_t[3,2] = r(p_P) 
		matrix ADF_test_t[4,2] = r(p_L)
		matrix ADF_test_t[5,2] = r(p_Z) 
		matrix ADF_test_t[6,2] = r(p_Pm) 

		matrix list ADF_test_t

	}
	// end of quietly 
	
	noi dis "Tests for `var'"
	matrix list ADF_test_t


	*export table in tex, option fmt(x) where x is the number of decimal digits 
	esttab matrix(ADF_test_t, fmt(3)) using "${path_main}/Statistics/ADF_uroot_`var'.tex", tex replace 



}
//end of foreach var of global 


}
// end of local u_root 



*============================================================*
* Regressions and Table 3 
*============================================================*

* Estimate model depending on variable

if ${damages} == 1 {
	
	foreach var of global dep_var {
		
		noi dis as result "Estimate climate damages for `var'"

		* First-difference on first-difference only for coal_elec and energy
		if inlist("`var'", "coal_elec", "energy") {
			
			reghdfe d.l_`var' d.c.temp        ///
					l1.d.c.temp               ///
					l2.d.c.temp               ///
					d.c.precip,               ///
					absorb(co_id year) vce(cluster regionid)
			
			* store estimates to export table
			estadd local mod "Diff-Diff"
			estadd local ife "Yes"
			estadd local ntfe "Yes"
			eststo `var'_lin_difdif_2lag
		}
		
		* Levels on levels for all other variables
		else {
			
			reghdfe l_`var' c.temp            ///
					l1.c.temp                 ///
					l2.c.temp                 ///
					c.precip,                 ///
					absorb(co_id year) vce(cluster regionid)
			
			* store estimates to export table
			estadd local mod "Lev-Lev"
			estadd local ife "Yes"
			estadd local ntfe "Yes"
			eststo `var'_lin_levlev_2lag
		}

	}
	// end of foreach var of global dep_var



	*------------------------------------------------------------*
	* Export LaTeX table with custom layout
	*------------------------------------------------------------*
	esttab ///
		pk_lin_levlev_2lag ///
		tot_crop_lin_levlev_2lag ///
		for_notim_lin_levlev_2lag ///
		min_lin_levlev_2lag ///
		energy_lin_difdif_2lag ///
		fossil_elec_lin_levlev_2lag ///
		ren_electr_lin_levlev_2lag ///
		coal_elec_lin_difdif_2lag ///
		gas_elec_lin_levlev_2lag ///
		oil_elec_lin_levlev_2lag ///
	using "${path_main}/Damages_results/Tables/damages_energyecon.tex", replace ///
		fragment ///
		booktabs ///
		nomtitles ///
		nonumbers ///
		se ///
		b(%9.4f) se(%9.4f) ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		keep(temp L.temp L2.temp D.temp LD.temp L2D.temp precip D.precip) ///
		order(temp L.temp L2.temp D.temp LD.temp L2D.temp precip D.precip) ///
		coeflabels( ///
			temp      "$T$" ///
			L.temp    "$(\ell1)\,T$" ///
			L2.temp   "$(\ell2)\,T$" ///
			D.temp    "$\Delta T$" ///
			LD.temp  "$(\ell1)\,\Delta T$" ///
			L2D.temp "$(\ell2)\,\Delta T$" ///
			precip    "$P$" ///
			D.precip  "$\Delta P$" ///
		) ///
		stats(ife ntfe r2 N, ///
			labels("Country FE" "Year FE" "$R^{2}$" "$N$") ///
			fmt(%9s %9s %9.2f %9.0f)) ///
		prehead("\scriptsize" ///
				"\setlength{\tabcolsep}{3pt}% narrower cols" ///
				"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" ///
				"" ///
				"\begin{adjustbox}{max width=\textwidth}" ///
				"\begin{tabular}{l*{10}{c}}" ///
				"\toprule" ///
				"        & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10)\\[-0.25em]" ///
				"        & \makecell{Produced\\Capital}" ///
				"        & Cropland" ///
				"        & \makecell{Forest\\Ecosystem}" ///
				"        & Minerals" ///
				"        & \makecell{$\Delta$\;Agg.\\Energy}" ///
				"        & \makecell{Fossil\\Fuel}" ///
				"        & \makecell{Renewable\\Energy}" ///
				"        & \makecell{$\Delta$ Coal}" ///
				"        & Gas" ///
				"        & Oil\\" ///
				"\midrule") ///
		postfoot("\bottomrule" ///
				 "\multicolumn{11}{l}{\footnotesize Standard errors in parentheses}\\" ///
				 "\multicolumn{11}{l}{\footnotesize \sym{*}\,$p<0.10$,\; \sym{**}\,$p<0.05$,\; \sym{***}\,$p<0.01$}\\" ///
				 "\end{tabular}%" ///
				 "\end{adjustbox}")		 
			
}
// end of if damages 

		
		
*============================================================*
* Cointegration tests   
*============================================================*
if ${coint_ecm} == 1 {
		
	*============================================================*
	* Westerlund cointegration tests (somepanels)
	*============================================================*


	matrix W = J(2,2,.)
	matrix rownames W = "Energy" "Coal electricity"
	matrix colnames W = "Statistic" "p-value"

	quietly xtcointtest westerlund l_energy temp, somepanels
	matrix W[1,1] = round(r(stat), .001)
	matrix W[1,2] = round(r(p),    .0001)

	quietly xtcointtest westerlund l_coal_elec temp, somepanels
	matrix W[2,1] = round(r(stat), .001)
	matrix W[2,2] = round(r(p),    .0001)

	esttab matrix(W) using "${path_main}/Statistics/westerlund_somepanels.tex", ///
		replace booktabs nomtitles nonumbers
		
		
		
		

	*============================================================*
	*ECM with Engle and Granger procedure
	*============================================================*	

	foreach var in energy coal_elec {
		
		* Long-run equation in levels
		reghdfe l_`var' c.temp c.precip, ///
			absorb(co_id year) vce(cluster regionid) resid
		
		* Residual from cointegrating equation
		cap drop ec_`var'
		predict ec_`var', resid
		
		* Lagged error-correction term (same name so it shows on same row in table)
		cap drop l_ec
		gen l_ec = l.ec_`var'
		
		* Short-run ECM
		reghdfe d.l_`var'        ///
				d.c.temp         ///
				l1.d.c.temp      ///
				l2.d.c.temp      ///
				d.c.precip       ///
				l_ec,		     ///
				absorb(co_id year) vce(cluster regionid)
		
		estadd local mod "ECM-EG"
		estadd local ife "Yes"
		estadd local ntfe "Yes"
		eststo `var'_lin_ecmEG_2lag
	}

	esttab ///
		energy_lin_ecmEG_2lag ///
		coal_elec_lin_ecmEG_2lag ///
	using "${path_main}/Damages_results/Tables/ecm_engle_granger.tex", replace ///
		fragment ///
		booktabs ///
		nomtitles ///
		nonumbers ///
		se ///
		b(%9.4f) se(%9.4f) ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		keep(D.temp LD.temp L2D.temp D.precip l_ec) ///
		order(D.temp LD.temp L2D.temp D.precip l_ec) ///
		coeflabels( ///
			D.temp    "$\Delta T$" ///
			LD.temp   "$(\ell1)\,\Delta T$" ///
			L2D.temp  "$(\ell2)\,\Delta T$" ///
			D.precip  "$\Delta P$" ///
			l_ec   "EC term" ///
		) ///
		stats(ife ntfe r2 N, ///
			labels("Country FE" "Year FE" "$R^{2}$" "N") ///
			fmt(%9s %9s %9.2f %9.0f)) ///
		prehead("\scriptsize" ///
				"\setlength{\tabcolsep}{3pt}% narrower cols" ///
				"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" ///
				"" ///
				"\begin{adjustbox}{max width=\textwidth}" ///
				"\begin{tabular}{l*{2}{c}}" ///
				"\toprule" ///
				"        & (1) & (2)\\[-0.25em]" ///
				"        & \makecell{$\Delta$\;Agg.\\Energy}" ///
				"        & \makecell{$\Delta$ Coal}\\" ///
				"\midrule") ///
		postfoot("\bottomrule" ///
				 "\multicolumn{3}{l}{\footnotesize Standard errors in parentheses}\\" ///
				 "\multicolumn{3}{l}{\footnotesize \sym{*}\,$p<0.10$,\; \sym{**}\,$p<0.05$,\; \sym{***}\,$p<0.01$}\\" ///
				 "\end{tabular}%" ///
				 "\end{adjustbox}")


}
// end of if coint_ecm





