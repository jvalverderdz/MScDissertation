/*******************************************************************************
1_aux_bootrstrapped_ci.do
Author: Javier Valverde
Version: 1.0

This Auxiliary Dofile generates Standard Errors and Confidence Intervals from the
Bootstrapped distribution of the Quantile Regression estimates.
*/

*******************************************************************************
gl path = "D:\Javier\OneDrive - University of Sussex\Sussex\_Dissertation\Data"
*******************************************************************************

gl do = "$path\scripts"
gl raw = "$path\raw"
gl clean = "$path\clean"
gl temp = "$path\temp"
gl output = "$path\output"

gl bootstrap = "$output\regressions\bootstrap"


*ssc install grstyle, replace
grstyle init
grstyle set color economist
grstyle color background white

global quantiles 5 6 7 8 9 10 15 20 30 40 50 60 70 80 90

********Clean Point Estimates******
import excel "$output\regressions\qregressions_v5.xls", clear 


drop in 1
drop in 2

gen q = "q"
foreach var of varlist B-P {
	ereplace `var' = concat(q `var') in 1
	rename `var' `=`var'[1]'
}

rename A parameter

drop in 1
drop if q5th == ""
drop if parameter == "Observations"
replace parameter = subinstr(parameter, ".", "",.)
replace parameter = "Interaction" if parameter == "clmw#clHHI"

drop if parameter == ""

drop q

foreach var of varlist q* {
	replace `var' = subinstr(`var', "*","",.)
}

tostring *, replace

reshape long q, i(parameter) j(quantile) string
rename q v
reshape wide v, i(quantile) j(parameter) string

replace quantile = subinstr(quantile, "th", "",.)
destring *, replace
*keep if inlist(quantile, 5, 6, 8, 10, 15, 20, 30, 40, 50, 60, 70, 80, 90)
sort quantile

foreach var of varlist v* {
	gen `var'_se = .
	gen `var'_ci_l = .
	gen `var'_ci_u = .
	gen `var'_pvalue = .
}

save "$temp\quantile_results_temp.dta", replace




********Obtain SE, CI, p-values and add to point estimates******


***Clean bootstrapped estimations
foreach i of numlist $quantiles {
*foreach i in 5 6 8 10 15 20 30 40 50 60 70 80 {
	di "Cleaning boostrapped estimations for quantile `i'"
	import delimited "$bootstrap\qboot`i'.txt", clear
	drop in 1/3
	*keep v1-v51
	drop if v1 == "" | v2 == "" | v1 == "Observations"
	rename v1 parameter
	reshape long v, i(parameter) j(iteration) string
	replace parameter = subinstr(parameter, ".", "",.)
	replace parameter = "Interaction" if parameter == "clmw#clHHI"
	reshape wide v, i(iteration) j(parameter) string

	destring *, replace
	sort iteration

 	gen quantile =  `i'
	if quantile != 5 {
		append using "$temp\bootstrapped_estimations.dta"
	}
	save "$temp\bootstrapped_estimations.dta", replace
}

***Iterate for all quantiles
foreach i of numlist $quantiles {
*foreach i in 5 6 8 10 15 20 30 40 50 60 70 80 {
	di "*****Obtaining SE Estimates for Quantile `i'*****"
	use "$temp\bootstrapped_estimations.dta", clear
	keep if quantile == `i'
	
	foreach var of varlist v* {
		di "`var'"
		preserve
			use "$temp\quantile_results_temp.dta", clear
			sum `var' if quantile == `i'
			local beta = r(mean)
		restore
		
		sum `var'
		local `var'_se = r(sd)
		egen `var'_p025 = pctile(`var'), p(5)
		local `var'_ci_l = `var'_p025[1]
		egen `var'_p975 = pctile(`var'), p(95)
		local `var'_ci_u = `var'_p975[1]
		
		replace `var' = `var' - `beta'
		count if `var' > abs(`beta')
		local fail = r(N)
		count if `var' < -abs(`beta')
		local fail = `fail' + r(N)
		local `var'_pvalue = `fail' / _N
		
		preserve
			use "$temp\quantile_results_temp.dta", clear
			replace `var'_se = ``var'_se' if quantile == `i'
			replace `var'_ci_l = ``var'_ci_l' if quantile == `i'
			replace `var'_ci_u = ``var'_ci_u' if quantile == `i'
			replace `var'_pvalue = ``var'_pvalue' if quantile == `i'
			save "$temp\quantile_results_temp.dta", replace
		restore
		
	}
}

********Marginal Effect Wald Test**************


foreach q of numlist $quantiles {
*foreach q in 5 6 8 10 15 20 30 40 50 60 70 80 {
	use "$temp\bootstrapped_estimations.dta", clear
	keep if quantile == `q'
	corr vlmw vInteraction, cov
	mat V = r(C)
	mat V[1, 2] = V[2,1]
	mat VInv`q' = inv(V)
}


use "$temp\quantile_results_temp.dta", clear
gen ME_pvalue = .

foreach q of numlist $quantiles {
*foreach q in 5 6 8 10 15 20 30 40 50 60 70 80 {
	qui sum vlmw if quantile == `q'
	scalar beta_1 = r(mean)
	qui sum vInteraction if quantile == `q'
	scalar phi = r(mean)
	mat B = (beta_1, phi)
	mat Bt = (beta_1 \ phi)
	
	mat W = B*VInv`q'
	mat W = W*Bt
	scalar Wald = W[1,1]
	
	scalar chi2pvalue = chi2tail(2, Wald)
	replace ME_pvalue = chi2pvalue if quantile == `q'
	
}
save "$temp\quantile_results_temp.dta", replace


********Graphs of Individual Effects**************

use "$temp\quantile_results_temp.dta", clear

twoway rarea vlmw_ci_l vlmw_ci_u quantile, astyle(ci) fcolor(gs50%20) || ///
    line vlmw quantile, lcolor(navy) ///
    legend(order(2 "MW Estimate" )) xtitle("Percentile") ///
    note("With 90% confidence interval") ///
    name(rarea, replace)	///
	title("Minimum Wage coefficient estimates" "by percentile", size(medium))
graph export "$output\regressions\Q_1_MWCoefs.png", replace width(1020)
	   
twoway rarea vInteraction_ci_l vInteraction_ci_u quantile, astyle(ci) fcolor(gs50%20) || ///
       line vInteraction quantile, lcolor(edkblue) ///
       legend(order(2 "Interaction Estimate" )) xtitle("Percentile") ///
       note("With 90% confidence interval.") ///
       name(rarea, replace) ///
	   title("Interaction coefficient estimates" "by percentile", size(medium))
graph export "$output\regressions\Q_2_InteractionCoefs.png", replace width(1020)

gen p5 = 0.05
gen p10 = 0.10
twoway connected ME_pvalue quantile, ///
	lcolor(navy) mcolor(navy) || ///
	line p5 quantile, lcolor("175 175 175") || ///
	line p10 quantile, lcolor("200 200 200") ///
	xtitle("Percentile") legend(off) ///
	title("Wald test of joint signifficance" "p-values by percentile", size(medium))
graph export "$output\regressions\Q_3_WaldPValues.png", replace width(1020)
	   
	   
order quantile vlmw* vlHHI* vInteraction* vllabor_force* v1sindicato* v1informalidad* v2sex* vesc* vexp* vexp2* vt* v2trim* v3trim* v4trim* vConstant* 
tostring *, replace
destring *_pvalue, replace
gen aster = "*"
foreach var in vlmw vlHHI vInteraction vllabor_force v1sindicato v1informalidad v2sex vesc vexp vexp2 vt v2trim v3trim v4trim vConstant {
	ereplace `var' = concat(`var' aster) if `var'_pvalue < 0.1
	ereplace `var' = concat(`var' aster) if `var'_pvalue < 0.05
	ereplace `var' = concat(`var' aster) if `var'_pvalue < 0.01
}

drop p5 p10 aster

export excel "$output\quantile_results.xlsx", firstrow(var) replace


