/*******************************************************************************
1_1_enoe_regressions.do
Author: Javier Valverde
Version: 1.0

This Dofile generates Regressions for the Monopsony-MW project.

*******************************************************************************/
 
clear all
set more off
set max_memory ., perm
cls
*******************************************************************************
gl path = "D:\Javier\OneDrive - University of Sussex\Sussex\_Dissertation\Data"
*******************************************************************************

gl do = "$path\scripts"
gl raw = "$path\raw"
gl clean = "$path\clean"
gl temp = "$path\temp"
gl output = "$path\output"


cd "$raw"

*ssc install grstyle, replace
grstyle init
grstyle set color economist
grstyle color background white


*******************************************************************************
cap mkdir "$output\regressions"


**************************1. REGRESSIONS: SPILLOVER EFFECT**********************************
use "$clean\ENOE_Base Global_Estatica.dta", clear

keep if clase2 == 1
keep if yeartrim>153

label variable lingocup "Log hourly wage"
label variable lmw "Log minimum wage"
label variable lHHI "Log HHI"
label variable esc "Schooling"
label variable exp "Experience"
label variable exp2 "Experience^2"
label variable sex "Female"
label variable sindicato "Union"
label variable informalidad "Informality"
label variable llabor_force "Log labor force"




*******************1.1. OLS
cls
cd "$output\regressions"

reg lingocup c.lmw c.lHHI i.yeartrim i.ent [fw=fac], cluster(cd_a) robust
estimates store raw
outreg2 using raw_v1.tex, label replace ctitle("Wages") 

reg lingocup c.lmw##c.lHHI esc exp exp2 i.sex i.yeartrim i.ent [fw=fac], cluster(cd_a) robust
estimates store baseline
outreg2 using baseline_v1.tex, label replace ctitle("Baseline")


reg lingocup c.lmw##c.lHHI c.llabor_force i.sindicato i.informalidad i.sex exp exp2 esc i.yeartrim i.ent [fw=fac], cluster(cd_a) robust
estimates store baseline_plus
outreg2 using baseline_v1.tex, label append ctitle("Baseline +")


coefplot (baseline) (baseline_plus), keep(lmw)



*****Treatment Interaction
cls
use "$clean\ENOE_Base Global_Estatica.dta", clear

keep if clase2 == 1
keep if yeartrim >=154
label variable lingocup "Log hourly wage"
label variable lmw "Log minimum wage"
label variable lHHI "Log HHI"
label variable esc "Schooling"
label variable exp "Experience"
label variable exp2 "Experience^2"
label variable sex "Female"
label variable sindicato "Union"
label variable informalidad "Informality"
label variable llabor_force "Log labor force"

*replace treatment = (yeartrim >= 154)
*replace treatment = 2 if yeartrim >= 191

tostring yeartrim, gen(p)
encode p, gen(period)
replace period = period + 1 if yeartrim > 202
*replace period = period - 37


cls
reg lingocup c.lHHI##i.treatment c.llabor_force i.sindicato i.informalidad i.sex exp exp2 esc i.ent c.period i.trim [fw=fac], cluster(cd_a) robust
estimates store treatreg
reg lingocup c.lHHI##i.treatment c.llabor_force i.sindicato i.sex exp exp2 esc i.ent c.period i.trim if informalidad == 0 [fw=fac], cluster(cd_a) robust
estimates store ftreatreg
reg lingocup c.lHHI##i.treatment c.llabor_force i.sindicato i.sex exp exp2 esc i.ent c.period i.trim if informalidad == 1 [fw=fac], cluster(cd_a) robust
estimates store itreatreg


cls
reg lingocup c.period##i.treatment i.treatment#c.lHHI lHHI c.llabor_force i.sindicato i.informalidad i.sex exp exp2 esc i.ent i.trim [fw=fac], cluster(cd_a) robust
estimates store eventreg
reg lingocup c.period##i.treatment i.treatment#c.lHHI c.llabor_force i.sindicato i.sex exp exp2 esc i.ent i.trim if informalidad == 0 [fw=fac], cluster(cd_a) robust
estimates store feventreg
reg lingocup c.period##i.treatment i.treatment#c.lHHI c.llabor_force i.sindicato i.sex exp exp2 esc i.ent i.trim if informalidad == 1 [fw=fac], cluster(cd_a) robust
estimates store ieventreg

*****




*******************1.2. OLS BY INFORMALITY
cls
cd "$output\regressions"

reg lingocup c.lmw##c.lHHI esc exp exp2 i.sex i.yeartrim i.ent if informalidad == 0  [fw=fac], cluster(cd_a) robust
estimates store fbasline
outreg2 using infbaseline_v1.tex, replace ctitle("Formal Baseline") label

reg lingocup c.lmw##c.lHHI c.llabor_force i.sindicato i.sex exp exp2 esc i.yeartrim i.ent if informalidad == 0  [fw=fac], cluster(cd_a) robust
estimates store fbasline_plus
outreg2 using infbaseline_v1.tex, append ctitle("Formal Baseline +") label

***
reg lingocup c.lmw##c.lHHI esc exp exp2 i.sex i.yeartrim i.ent if informalidad == 1  [fw=fac], cluster(cd_a) robust
estimates store ibaseline
outreg2 using infbaseline_v1.tex, append ctitle("Informal Baseline +") label

reg lingocup c.lmw##c.lHHI c.llabor_force i.sindicato i.sex exp exp2 esc i.yeartrim i.ent if informalidad == 1  [fw=fac], cluster(cd_a) robust
estimates store ibaseline_plus
outreg2 using infbaseline_v1.tex, append ctitle("Informal Baseline +") label


*******************1.3. WALD TESTS
global y = 1
do "$do\1_aux_wald_baseline.do"
	

	
*******************1.4. QUANTILE REGRESSIONS
use "$clean\ENOE_Base Global_Estatica.dta", clear
	keep if clase2 == 1
	keep if yeartrim>153
save "$temp\ENOE_bootstraping.dta", replace	

cls
cd"$output\regressions"
qreg lingocup c.lmw##c.lHHI c.llabor_force i.sindicato i.informalidad i.sex exp exp2 esc c.t i.trim [fw=fac], q(5) vce(iid, res)
outreg2 using qregressions_v5.xls, replace ctitle("5th") excel noaster

foreach n in 6 7 8 9 10 15 20 30 40 50 60 70 80 90 {
*foreach n in 90 {
	qreg lingocup c.lmw##c.lHHI c.llabor_force i.sindicato i.informalidad i.sex exp exp2 esc c.t i.trim [fw=fac], q(`n') vce(iid, res)
	outreg2 using qregressions_v5.xls, append ctitle("`n'th") excel noaster
}


*******************1.5. BOOTSTRAPPING QUANTILE ESTIMATORS
cd "$output\regressions\bootstrap"

foreach n in 5 6 7 8 9 10 15 20 30 50 60 70 80 90 {
*foreach n in 5 10 15 {
	
	di "Bootstrapping for Quantile `n'th"
	forval i = 1/50 {
	*forval i = 51/100 {
		use "$temp\ENOE_bootstraping.dta", clear
		di "Iteration `i'"
		bsample, cluster(cd_a)
		qreg lingocup c.lmw##c.lHHI c.llabor_force i.sindicato i.informalidad i.sex exp exp2 esc c.t i.trim [fw=fac], q(`n') vce(iid, res)
		outreg2 using qboot`n'.xls, append ctitle("`n'th-`i'") excel noaster
	}
}

do "$do\1_aux_bootrstrapped_ci.do"


*******************1.6. ROBUSTNESS CHECKS
cap mkdir "$output\regressions\robustness"


use "$clean\ENOE_Base Global_Estatica.dta", clear

keep if clase2 == 1
keep if yeartrim>153

label variable lingocup "Log hourly wage"
label variable lmw "Log minimum wage"
label variable lHHI "Log HHI"
label variable esc "Schooling"
label variable exp "Experience"
label variable exp2 "Experience^2"
label variable sex "Female"
label variable sindicato "Union"
label variable informalidad "Informality"
label variable llabor_force "Log labor force"
label variable mean_invfirmas "Average Inverse of Firms"

gen lHHI3 = ln(mean_HHI_3)
label variable lHHI3 "Log HHI 3-Digits"

gen linvn = ln(mean_invfirmas)
label variable linvn "Log Inverse of Firms"


cls
cd "$output\regressions\robustness"

reg lingocup c.lmw##c.lHHI3 i.sindicato i.informalidad c.llabor_force i.sex exp exp2 esc i.yeartrim i.ent [fw=fac], cluster(cd_a)
outreg2 using wrobust.tex, replace ctitle("HHI 3-Digits") label

reg lingocup c.lmw##c.linvn i.sindicato i.informalidad c.llabor_force i.sex exp exp2 esc i.yeartrim i.ent [fw=fac], cluster(cd_a)
outreg2 using wrobust.tex, append ctitle("Inverse of Firms") label

reg lingocup c.lmw##c.lHHI i.sindicato i.informalidad c.llabor_force i.sex exp exp2 esc i.yeartrim i.ent [fw=fac] if ent != 9, cluster(cd_a)
outreg2 using wrobust.tex, append ctitle("No Mexico City") label

reg lingocup c.lmw##c.lHHI i.sindicato i.informalidad c.llabor_force i.sex exp exp2 esc i.yeartrim i.ent if ing_pctile > 75 [fw=fac], cluster(cd_a)
outreg2 using wrobust.tex, append ctitle("Placebo Test") label

reg lingocup c.lmw##c.lHHI i.sindicato i.informalidad c.llabor_force i.sex exp exp2 esc i.yeartrim i.ent if yeartrim <= 201 [fw=fac], cluster(cd_a)



**************************2. REGRESSIONS: EMPLOYMENT EFFECT**********************************


*******************2.1. OLS
use "$clean\ENOE_Base Global_Estatica.dta", clear

*keep if clase2 == 1
keep if yeartrim>153

collapse (sum) ocupado total_horas = hrsocup (mean) mean_HHI mean_HHI_3 mean_invfirmas (first) pea ent salario salario_real zona base trim (mean) sindicato informalidad [fw=fac], by(cd_a yeartrim)

gen lHHI = ln(mean_HHI)
gen lHHI3 = ln(mean_HHI)
gen treatment = 0
replace treatment = 1 if yeartrim >=191
gen desempleo = (1 - (ocupado / pea))*100
gen lmw = ln(salario_real)
gen lpea = ln(pea)
gen lu = ln(desempleo)
gen horas_ppea = total_horas / pea
gen lhoras = ln(horas_ppea)
gen linvn = ln(mean_invfirmas)

label variable lu "Log unemployment"
label variable lhoras "Log hours"
label variable lmw "Log minimum wage"
label variable lHHI "Log HHI"
label variable lpea "Log labor force"
label variable informalidad "Informality rate"
label variable sindicato "Unionization rate"


cls
cd "$output\regressions"

reg lu c.lmw c.lHHI i.yeartrim i.ent [fw=pea], cluster(cd_a) robust
estimates store uraw
*outreg2 using raw_v1.tex, label append ctitle("Unemployment")

reg lu c.lmw##c.lHHI i.yeartrim i.ent [fw=pea], cluster(cd_a) robust
estimates store ubaseline
*outreg2 using ubaseline_v1.tex, replace ctitle("Baseline") label

reg lu c.lmw##c.lHHI lpea sindicato informalidad i.yeartrim i.ent [fw=pea], cluster(cd_a) robust
estimates store ubaseline_plus
*outreg2 using ubaseline_v1.tex, append ctitle("Baseline +") label


*******************2.2. WALD TESTS

global y = 2
do "$do\1_aux_wald_baseline.do"


*******************2.3. ROBUSTNESS CHECKS
cls
cd "$output\regressions\robustness"

reg lu c.lmw##c.lHHI3 lpea sindicato informalidad i.yeartrim i.ent [fw=pea], cluster(cd_a) robust
outreg2 using urobust.tex, append ctitle("HHI 3-Digits") label

reg lu c.lmw##c.linvn lpea sindicato informalidad i.yeartrim i.ent [fw=pea], cluster(cd_a) robust
outreg2 using urobust.tex, append ctitle("Inverse of Firms") label

reg lu c.lmw##c.lHHI lpea sindicato informalidad i.yeartrim i.ent if ent != 9 [fw=pea], cluster(cd_a) robust
outreg2 using urobust.tex, append ctitle("No Mexico City") label
