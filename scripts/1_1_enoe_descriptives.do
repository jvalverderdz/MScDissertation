/*******************************************************************************
1_3_enoe_descriptives.do
Author: Javier Valverde
Version: 1.0

This Dofile generates descriptive tables, graphs and maps

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
gl map_root = "D:\Javier\Documentos\Proyecto basico de informacion 2020\Marco Geoestadistico\cartografia"

cd "$raw"

*ssc install grstyle, replace
grstyle init
grstyle set color economist
grstyle color background white


*******************************************************************************

**************************1. MINIMUM WAGE ZONES**********************************
*Transform shps to dta
shp2dta using "$map_root\estatal.shp", database(estatalDb) coordinates(estatalCo) genid(id) gencentroids("centroid") replace
shp2dta using "$map_root\municipal.shp", database(municipalDb) coordinates(municipalCo) genid(id) gencentroids("centroid") replace
shp2dta using "$map_root\loc_urb.shp", database(citiesDb) coordinates(citiesCo) genid(id) gencentroids("centroid") replace

*Clean municipalaities dta
use municipalDb, clear
rename CVEGEO CVE_MUN
keep CVE_MUN OID id *_centroid
save "$clean\municipalDb.dta", replace

*Clean mw zones
gen ent = substr(CVE_MUN, 1, 2)
gen mun = substr(CVE_MUN, 3, 3)
destring ent mun, replace

gen zone = .
replace zone = 1 if inlist(ent, 2, 3, 9)
replace zone = 1 if ent == 8 & inlist(mun, 28, 37, 53, 31)
replace zone = 1 if ent == 12 & inlist(mun, 1)
replace zone = 1 if ent == 14 & inlist(mun, 39, 70, 97, 98, 101, 120)
replace zone = 1 if ent == 15 & inlist(mun, 12, 20, 24, 121, 33, 57, 182, 109)
replace zone = 1 if ent == 19 & inlist(mun, 6, 19, 26, 39, 46, 48)
replace zone = 1 if ent == 26 & inlist(mun, 2, 4, 7, 12, 16, 48, 21, 71, 17, 18, 19, 20, 22, 25, 26, 29, 30, 70, 33, 35, 36, 39, 42, 43, 45, 46, 47, 56, 58, 59, 72, 55, 60, 62, 64, 65)
replace zone = 2 if zone == .
label define zonel 1 "Zone A" 2 "Zone B"
label values zone zonel

gen border = .
replace border = 1 if ent == 2 & inlist(mun, 1, 2, 3, 4, 5)
replace border = 1 if ent == 26 & inlist(mun, 2, 4, 17, 19, 39, 43, 48, 55, 59, 60, 70)
replace border = 1 if ent == 8 & inlist(mun, 5, 15, 28, 35, 37, 42, 52, 53)
replace border = 1 if ent == 5 & inlist(mun, 2, 12, 13, 14, 22, 23, 25, 38)
replace border = 1 if ent == 19 & mun == 5
replace border = 1 if ent == 28 & inlist(mun, 7, 14, 15, 22, 24, 25, 27, 32, 33, 40)
replace border = 2 if border == .
label define borderl 1 "Northern border zone" 2 "Rest of the country"
label values border borderl

spmap zone using municipalCo, id(id) ///
	osize(none ..) fcolor("33 113 181" "158 202 225") ///
	title("Minimum wage zones (2012-2015)", size(medium)) clmethod(unique) ///
	polygon(data(estatalCo) ocolor("225 225 225") osize(vthin)) legend(size(medium))
graph export "$output\descriptives\1_0_MW_zones.png", replace width(1020)

spmap border using municipalCo, id(id) ///
	osize(none ..) fcolor("33 113 181" "158 202 225") ///
	title("Minimum wage zones (2019)", size(medium)) clmethod(unique) ///
	polygon(data(estatalCo) ocolor("225 225 225") osize(vthin)) legend(size(medium))
graph export "$output\descriptives\1_1_MW_border_zones.png", replace width(1020)


**************************2. MINIMUM WAGE TRENDS**********************************
use "$clean\ENOE_Base Global_Estatica.dta", clear

collapse (first) salario salario_real fecha, by(zona yeartrim)
*keep if yeartrim >= 151
gen date = date(fecha, "YMD")
format date %td

replace zona = 1 if zona == 3 & yeartrim >= 191
save "$temp\minimum_wages.dta", replace

preserve
	keep salario date zona
	reshape wide salario, i(date) j(zona)

	tsset date 

	tsline salario*, lwidth(medium) xlabel(#5, labsize(vsmall) angle(45)) ytitle("Current MXN") xtitle("") ///
		legend(order(1 "Zone A" 2 "Zone B" 3 "Zone C" 4 "Border Zone")) ///
		title("Nominal Minimum Wage trends (2005-2022)", size(medium)) xline(20423, lwidth(thin) lcolor("120 120 120") lpattern(dash))
	graph export "$output\descriptives\2_1_MW_trend.png", replace width(1020)
restore

preserve
	keep salario_real date zona
	reshape wide salario_real, i(date) j(zona)

	tsset date
	
	tsline salario_real*, lwidth(medium) xlabel(#5, labsize(vsmall) angle(45)) ytitle("MXN") xtitle("") ///
		legend(order(1 "Zone A" 2 "Zone B" 3 "Zone C" 4 "Border Zone")) ///
		title("Real Minimum Wage trends (2005-2022)", size(medium)) xline(20423, lwidth(thin) lcolor("120 120 120") lpattern(dash))
	graph export "$output\descriptives\2_2_RealMW_trend.png", replace width(1020)
restore


use "$temp\minimum_wages.dta", clear
keep salario date zona
reshape wide salario, i(date) j(zona)
tsset date 
sort date 

forval n=1/4 {
	gen dsalario`n' = ((salario`n' - salario`n'[_n-1]) / salario`n')*100
	replace dsalario`n' = 0 if dsalario`n' == .
}

gen sum_dsalario = dsalario1 + dsalario2 + dsalario3 + dsalario4
drop if sum_dsalario == 0
gen year = string(date, "%td")
replace year = substr(year, 6, 4)

graph bar dsalario*, over(year, label(labsize(vsmall) angle(45))) ytitle("%") ///
	legend(order(1 "Zone A" 2 "Zone B" 3 "Zone C" 4 "Border Zone")) ///
	title("Nominal Minimum Wage increases (2005-2022)", size(medium)) blabel(bar, format(%9.2f))
graph export "$output\descriptives\2_3_MW_increases.png", replace width(1020)



**************************3. HHI vs wage**********************************
use "$clean\ENOE_Base Global_Estatica.dta", clear
keep if yeartrim >=151

gen ocupadoW = ocupado * fac
gen peaW = (clase1 == 1)*fac

egen Nocupado = sum(ocupadoW), by(cd_a yeartrim)
egen PEA = sum(peaW), by(cd_a yeartrim)

gen tasa_ocupacion = Nocupado / (PEA)

keep if ingocup != . & ingocup > 0

gen pre = inrange(yeartrim, 151, 184)
gen post = yeartrim >= 191

collapse (mean) ingocup ingocup_real (first) mean_HHI Nocupado PEA tasa_ocupacion zona salario t yeartrim_lag, by(cd_a post) 

twoway scatter ingocup_real mean_HHI if post == 0, mcolor(eltblue)|| scatter ingocup_real mean_HHI if post == 1, mcolor(navy) ///
	|| lfit ingocup_real mean_HHI if post == 0, lcolor(eltblue%50) || lfit ingocup_real mean_HHI if post == 1, lcolor(navy%50) ///
	legend(order(1 "2015-2018" 2 "2019-2022")) ytitle("MXN") xtitle("Herfindahl-Hirschmnan Index") ///
	title("City-average concentration index vs. wages", size(medium))
graph export "$output\descriptive\3_1_HHI_wages.png", replace width(1020)


*xtset cd_a t
decode cd_a, gen(city)

save "$clean\ENOE_byCity", replace




**************************4. Table of Descriptives**********************************
*use "$clean\ENOE_Base Global_Estatica_mini.dta", clear
use "$clean\ENOE_Base Global_Estatica.dta", clear

*Descriptives of employed
keep if ocupado == 1	//Keep only active population

gen gender = (sex == 2)
replace hrsocup = . if ocupado == 0

keep if yeartrim > 151
gen yearbracket = .
replace yearbracket = 1 if yeartrim < 191
replace yearbracket = 2 if yeartrim >= 191

gen ingho

cd "$output\descriptives"
asdoc tabstat inghora lingocup salario_real lmw mean_HHI lHHI sindicato informalidad gender exp exp2 esc hrsocup [fw=fac], stat(mean sd) by(yearbracket) ///
save(descriptive_ind.doc) replace



**************************5. DESCRIPTIVES BY CITY**********************************

use "$clean\ENOE_Base Global_Estatica.dta", clear

gen ocupadoW = ocupado * fac
gen peaW = (clase1 == 1)*fac

egen Nocupado = sum(ocupadoW), by(cd_a yeartrim)
egen PEA = sum(peaW), by(cd_a yeartrim)

gen tasa_ocupacion = Nocupado / (PEA)

keep if ocupado == 1

collapse (mean) ingocup_real inghora informalidad (first) mean_HHI Nocupado PEA tasa_ocupacion zona salario t yeartrim_lag, by(cd_a yeartrim) 

*xtset cd_a t
decode cd_a, gen(city)
replace city = "Tuxtla Gutiérrez" if cd_a == 19

save "$clean\ENOE_byCity", replace






*******5.0. Table of Descriptives******
use "$clean\ENOE_Base Global_Estatica.dta", clear

*keep if clase2 == 1
keep if yeartrim>153

collapse (sum) ocupado total_horas = hrsocup (mean) mean_HHI (first) pea ent salario salario_real zona base trim (mean) sindicato informalidad [fw=fac], by(cd_a yeartrim)

gen lHHI = ln(mean_HHI)
gen treatment = 0
replace treatment = 1 if yeartrim >=191
gen desempleo = (1 - (ocupado / pea))*100
gen lmw = ln(salario_real)
gen lpea = ln(pea)
gen lu = ln(desempleo)
gen horas_ppea = total_horas / pea
gen lhoras = ln(horas_ppea)

label variable lu "Log unemployment"
label variable lhoras "Log hours"
label variable lmw "Log minimum wage"
label variable lHHI "Log HHI"
label variable lpea "Log labor force"
label variable informalidad "Informality rate"
label variable sindicato "Unionization rate"

gen yearbracket = (yeartrim >=191)

*tabstat desempleo lu total_horas lhoras mean_HHI lHHI pea lpea informalidad sindicato, stat(mean sd) by(yearbracket)
asdoc tabstat desempleo lu total_horas lhoras mean_HHI lHHI pea lpea informalidad sindicato, stat(mean sd) by(yearbracket) ///
	save(descriptive_city.doc) replace


*******5.1. Average Wage by City******
use "$clean\ENOE_byCity", clear

keep inghora t cd_a
reshape wide inghora, i(cd_a) j(t) 
sort cd_a

export excel "$output\descriptives\5_1_AverageWage_byCity.xlsx", firstrow(var) replace


*******5.2. Average IHH by City******
use "$clean\ENOE_byCity", clear

graph bar mean_HHI, over(city, sort(mean_HHI) label(labsize(vsmall) angle(45))) title("Average Herfindahl-Hirschman Index by city", size(medium)) ytitle("HHI") noout
graph export "$output\descriptives\5_2_HHI_byCity.png", replace width(1020)

*******5.3. Total Labor force by City******
use "$clean\ENOE_byCity", clear

egen total_PEA = sum(PEA)
gen perc_PEA = (PEA / total_PEA)*100
*egen perc_PEA = mean(share_PEA), by(cd_a)

replace PEA = PEA / 1000
keep if inlist(yeartrim, 151, 191, 221)
keep PEA perc_PEA yeartrim city
reshape wide PEA perc_PEA, i(city) j(yeartrim)


graph bar PEA*, over(city, sort(PEA221) desc label(labsize(vsmall) angle(45))) title("Total labor force by city", size(medium)) ytitle("Thousands of persons") ///
	legend(order(1 "2015" 2 "2019" 3 "2022")) note("The data corresponds with the first quarter of each year.")
graph export "$output\descriptives\5_3_PEA_byCity.png", replace width(1020)


use "$clean\ENOE_byCity", clear
graph pie PEA, over(city) sort desc ///
	plabel(1 perc, format(%9.1f)) plabel(2 perc, format(%9.1f)) plabel(3 perc, format(%9.1f)) plabel(4 perc, format(%9.1f)) plabel(5 perc, format(%9.1f)) ///
	plabel(6 perc, format(%9.1f)) plabel(7 perc, format(%9.1f)) plabel(8 perc, format(%9.1f)) plabel(9 perc, format(%9.1f)) plabel(10 perc, format(%9.1f)) ///
	legend(order(1 2 3 4 5 6 7 8 9 10) cols(3)) ///
	title("Share of national labor force (2022)", size(medium))
graph export "$output\descriptives\5_3a_SharePEA.png", replace width(1020)








*******5.4. HHI vs Income******
use "$clean\ENOE_byCity", clear
gen treatment = (yeartrim >=191)

collapse (mean) inghora (first) mean_HHI, by(city)

twoway scatter inghora mean_HHI || lfit inghora mean_HHI, ytitle("MXN") xtitle("HHI") ///
	legend(off) title("Average Hourly Wage by HHI", size(medium))
graph export "$output\descriptives\5_4_HHIvIncome.png", replace width(1020)

*******5.5. Informality by city******
use "$clean\ENOE_byCity", clear
keep if inlist(yeartrim, 151, 191, 221)
keep informalidad yeartrim city
replace informalidad = informalidad * 100
reshape wide informalidad, i(city) j(yeartrim)

graph bar informalidad*, over(city, sort(informalidad221) desc label(labsize(vsmall) angle(45))) title("Informality by city", size(medium)) ytitle("%") ///
	legend(order(1 "2015" 2 "2019" 3 "2022") cols(3)) note("The data corresponds with the first quarter of each year.")
graph export "$output\descriptives\5_5_Informality_ByCity.png", replace width(1020)


*******5.6. Wages v. Informality******
use "$clean\ENOE_byCity", clear

collapse (mean) inghora, by(informalidad)
replace informalidad = informalidad * 100

twoway scatter inghora informalidad || lowess inghora informalidad, ytitle("MXN") xtitle("Informality rate") ///
	legend(off) title("Average Hourly Wage by Informality rate", size(medium))
graph export "$output\descriptives\5_6_WagesvInformality.png", replace width(1020)


