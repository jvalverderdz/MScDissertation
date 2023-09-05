********************
version 15
clear all
set more off
cls
********************
 
/*********************************************************************************************
* Nombre archivo: 		AM202102_B4ML_3.BasesGlobales.do
* Autor:          		Azael Mateo		
* Archivos usados:     
	- Todas las bases de datos ENOE (SDEMT y COE1T/2T) para todos los años disponibles.
* Archivos creados:  
	- ENOE_Base Global_Estatica.dta
	- ENOE_Base Global_Dinamica.dta
* Propósito:
	- Éste archivo genera dos bases de datos que son utilizadas para todos los cálculos 
	  posteriores: una base de datos "estática" que se limita a unir todas las bases de datos
	  disponibles, y una base de datos "dinámica" que compara los resultados de ciertas
	  variables para personas con entrevistas disponibles a lo largo de un año.
	- Importante: la base estática tiene a la población completa, pues borrar la PEA 
	  eliminaría la posibilidad de hacer un análisis de la transición del empleo a la PNEA.
*********************************************************************************************/


gl root = "D:\Javier\OneDrive - University of Sussex\Sussex\_Dissertation\Data"


******************************
* (1): Definimos directorios *
******************************
/* (1.1): Definimos el directorio en donde se encuentran las bases de datos que utilizaremos
		  y a donde exportaremos la base de datos procesada. */
gl bases = "$root/raw/Bases ENOE"
gl docs  = "$root/clean"
gl do = "$root/scripts"



************************************************************************************************************
* (2): Creamos una base unificada (para todo trimestre disponible), haciendo un merge de SDEM, COE1 y COE2 *
************************************************************************************************************
/* (2.1): Primero juntamos las bases del 2005 para tener una base "base". */
forvalues i = 1/4 {
	use "$bases/2005trim`i'_dta/SDEMT`i'05.dta", clear
	qui merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$bases/2005trim`i'_dta/COE1T`i'05.dta", force
	keep if _merge==3
	drop _merge
	keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog h_mud n_ent per n_ren c_res par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c salario zona hrsocup scian p4a p3*
	qui merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$bases/2005trim`i'_dta/COE2T`i'05.dta", force
	keep if _merge==3
	drop _merge
	keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog h_mud n_ent per n_ren c_res par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c p11_1 salario p6c p6b2 p6_9 p6a3 zona hrsocup scian p4a p3*
	tempfile base`i'
	save "`base`i''"
}

use "`base1'"
append using "`base2'"
append using "`base3'"
append using "`base4'"

save "$docs/ENOE_Base Global_Estatica.dta", replace

/* (2.2): Definimos año actual (para bajar la información hasta donde esté disponible. */
local anio : display %tdY date(c(current_date), "DMY")

/* (2.3): Generamos bases temporales para que al hacer append no ocupen mucho espacio. */
forvalues i = 6/`anio' {
	* Agregamos un 0 a inicio del local i para años anteriores a 2010:
	if strlen(string(`i'))==1 {
		local i = "0" + string(`i')
	}	
	* Corremos loop para cada trimestre
	forvalues j = 1/4 {
		capture confirm file "$bases/20`i'trim`j'_dta/SDEMT`j'`i'.dta"
		if _rc==0 {
			disp "trabajando para año `i' trim `j'"
			use "$bases/20`i'trim`j'_dta/SDEMT`j'`i'.dta", clear
			
			* Verificamos si estamos trabajando para la ENOE_N. En caso de ser así renombramos variables trimestrales.
			capture confirm variable mes_cal
			if !_rc {	
			
			    * Renombramos variables trimestrales
			    rename est_d_tri est_d
			    rename t_loc_tri t_loc
			    rename fac_tri fac
				
				destring tipo mes_cal, replace
				cap destring ca, replace
			
			    * Corremos loop especial
				qui merge 1:1 cd_a ent con v_sel tipo mes_cal n_hog h_mud n_ren using "$bases/20`i'trim`j'_dta/COE1T`j'`i'.dta"
				keep if _merge==3
				drop _merge
				keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel tipo mes_cal n_hog h_mud n_ent per n_ren c_res par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c salario zona hrsocup scian p4a p3*
				qui merge 1:1 cd_a ent con v_sel tipo mes_cal n_hog h_mud n_ren using "$bases/20`i'trim`j'_dta/COE2T`j'`i'.dta"
				keep if _merge==3
			
				* Como la variable que buscamos alterna entre p9_1 y p11_1, tenemos que revisar primero si existe. 
				capture confirm variable p9_1
				if !_rc {
						drop _merge
						keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel tipo n_hog h_mud n_ent per n_ren c_res par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c p9_1 salario p6c p6b2 p6_9 p6a3 zona hrsocup scian p4a p3*
						tempfile shortSDEMT`j'`i'
						save "`shortSDEMT`j'`i''"
				}
				else {
						drop _merge
						keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog h_mud n_ent per n_ren c_res par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c p11_1 salario p6c p6b2 p6_9 p6a3 zona hrsocup scian p4a p3*
						tempfile shortSDEMT`j'`i'
						save "`shortSDEMT`j'`i''"
				}	
			}				
			else {
			use "$bases/20`i'trim`j'_dta/SDEMT`j'`i'.dta", clear
			qui merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$bases/20`i'trim`j'_dta/COE1T`j'`i'.dta"
			keep if _merge==3
			drop _merge
			keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog h_mud n_ent per n_ren c_res par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c salario zona hrsocup scian p4a p3*
			qui merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$bases/20`i'trim`j'_dta/COE2T`j'`i'.dta"
			keep if _merge==3
			
			* Como la variable que buscamos alterna entre p9_1 y p11_1, tenemos que revisar primero si existe. 
			capture confirm variable p9_1
			if !_rc {
					drop _merge
					keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog h_mud n_ent per n_ren c_res par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c p9_1 salario p6c p6b2 p6_9 p6a3 zona hrsocup scian p4a p3*
					tempfile shortSDEMT`j'`i'
					save "`shortSDEMT`j'`i''"
			}
			else {
					drop _merge
					keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog h_mud n_ent per n_ren c_res par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c p11_1 salario p6c p6b2 p6_9 p6a3 zona hrsocup scian p4a p3*
					tempfile shortSDEMT`j'`i'
					save "`shortSDEMT`j'`i''"
			}		
		}
	}
  }
}


/* (2.4): Ya con serie de bases pequeñas procedemos a juntar todas en una base total. */
use "$docs/ENOE_Base Global_Estatica.dta", clear

forvalues i = 6/`anio' {
	* Agregamos un 0 a inicio del local i para años anteriores a 2010:
	if strlen(string(`i'))==1 {
		local i = "0" + string(`i')
	}	
	
	* Corremos loop para cada trimestre
	forvalues j = 1/4 {
		capture confirm file "`shortSDEMT`j'`i''"
		if _rc==0 {
			append using "`shortSDEMT`j'`i''", force
		}
	}
}

/* (2.5): Conservamos solo las ciudades autorrepresentadas  */
drop if cd_a > 80


****************************************
* (3): Generamos variables importantes *
****************************************
/* (3.1): Generamos identificador único. */
egen folio = concat(cd_a ent con v_sel n_hog h_mud n_ren sex nac_dia nac_anio nac_mes)  // folio original
egen foliop = concat(cd_a ent con v_sel n_hog h_mud n_ren)
egen folioh = concat(cd_a ent con v_sel n_hog h_mud n_ren)

/* (3.2): Generamos variable clasificador de tipo de localidad. */
gen rururb = cond(t_loc>=1 & t_loc<=3,0,1) 
label define ru 0 "Urbano" 1 "Rural" 
label values rururb ru 
		
/* (3.3): Creamos variable año-trimestre y la misma con lag de un año antes. */
gen year = substr(string(per),2,2)
gen trim = substr(string(per),1,1)
egen yeartrim = concat(year trim)
destring yeartrim, replace
gen int yeartrim_lag = .
replace yeartrim_lag = yeartrim - 9
replace yeartrim_lag = yeartrim_lag + 6 if real(substr(string(yeartrim_lag), 2,1))==5 & yeartrim_lag<102
replace yeartrim_lag = yeartrim_lag + 6 if real(substr(string(yeartrim_lag), 3,1))==5 & yeartrim_lag>100
replace yeartrim_lag = 203 if yeartrim == 211
replace yeartrim_lag = 193 if yeartrim == 201
egen base = group(yeartrim)

/* (3.4): Recuperamos ingresos por rangos de salarios mínimos */
gen ocupado = cond(clase1==1 & clase2==1,1,0)

recode p6b2 (999998=.) (999999=.)
		
gen ingreso = p6b2
replace ingreso = 0 if ocupado==0
replace ingreso = 0 if p6b2==. & (p6_9==9 | p6a3==3)
replace ingreso = 0.5*salario if p6b2==. & p6c==1
replace ingreso = 1*salario if p6b2==. & p6c==2
replace ingreso = 1.5*salario if p6b2==. & p6c==3
replace ingreso = 2.5*salario if p6b2==. & p6c==4
replace ingreso = 4*salario if p6b2==. & p6c==5
replace ingreso = 7.5*salario if p6b2==. & p6c==6
replace ingreso = 10*salario if p6b2==. & p6c==7


/* (3.6): Generamos variable caracter de año, mes y fecha.*/
gen anio = "20" + year
destring trim, replace
gen mes = string(trim*3)
replace mes = "0" + mes if strlen(mes)==1
generate str fecha = anio + "-" + mes + "-01"

gen t = date(fecha, "YMD")
replace t = qofd(t)
format t %tq

/* (3.7): Editamos labels.*/
label define cd_a 1 "México City" 6 "Torreón" 20 "Ciudad Juárez" 30 "Coatzacoalcos" 40 "La Paz" 42 "Ciudad del Carmen" 44 "Mexicali" 46 "Reynosa" 52 "Tapachula", modify

label define zona 1 "Zone A" 2 "Zone B" 3 "Zone C", modify


/* (3.8): Merge con datos de concentración de mercados */
preserve
	use "$docs\HHI_ciudades_autorrepresentadas_CE.dta", clear
	gen inv_firmas = 1/numero_firmas
	collapse (mean) mean_HHI = HHI mean_HHI_3 = HHI_3 personal_ocupado_promedio personal_ocupado_promedio_3 ///
	personal_ocupado_p25 personal_ocupado_p50 personal_ocupado_p75 personal_ocupado_max personal_ocupado_3_p25 personal_ocupado_3_p50 personal_ocupado_3_p75 personal_ocupado_3_max ///
	personal_ocupado_sd personal_ocupado_3_sd share_empleo share_empleo_3 horas_trabajadas_promedio remuneraciones_promedio ///
	productividad_ptrabajdor productividad_phora fbkf fbkf_ptrabajador margen_operativo mean_inv_firmas = inv_firmas ///
	(sum) total_personal_ocupado total_personal_ocupado_3 produccion_bruta_total valor_agregado_censal_bruto inversion_total fbkf_total horas_trabajadas, by(cd_a)
	
	save "$docs\IHH_cities.dta", replace
restore

preserve
	use "$docs\HHI_ciudades_autorrepresentadas_CE.dta", clear
	keep cd_a scian_4 HHI HHI_3 total_personal_ocupado
	gen scian_2 = substr(scian, 1, 2)
	destring scian_2, replace
	gen scian = .
	replace scian = 1 if scian_2 == 11
	replace scian = 2 if scian_2 == 21
	replace scian = 3 if scian_2 == 22
	replace scian = 4 if scian_2 == 23
	replace scian = 5 if inrange(scian_2, 31, 33)
	replace scian = 6 if scian_2 == 43
	replace scian = 7 if scian_2 == 46
	replace scian = 8 if inrange(scian_2, 48, 49)
	replace scian = 9 if scian_2 == 51
	replace scian = 10 if scian_2 == 52
	replace scian = 11 if scian_2 == 53
	replace scian = 12 if scian_2 == 54
	replace scian = 13 if scian_2 == 55
	replace scian = 14 if scian_2 == 56
	replace scian = 15 if scian_2 == 61
	replace scian = 16 if scian_2 == 62
	replace scian = 17 if scian_2 == 71
	replace scian = 18 if scian_2 == 72
	replace scian = 19 if scian_2 == 81
	
	collapse (mean) HHI (count) total_personal_ocupado [fw=total_personal_ocupado], by(cd_a scian)
	
	compress
	save "$docs\IHH_sectors.dta", replace
restore

merge m:1 cd_a using "$docs\IHH_cities.dta"
keep if inlist(_merge, 1, 3)
drop _merge

merge m:1 cd_a scian using "$docs\IHH_sectors.dta"
keep if inlist(_merge, 1, 3)
drop _merge


/* (3.9): Deflactar */
preserve
	do "$do/aux_import_inpc.do"
restore

merge m:1 yeartrim using "$temp/inpc.dta", gen(merge_inpc)
keep if inlist(merge_inpc, 1, 3)
drop merge_inpc

gen ingocup_real = (ingocup / inpc)*100
gen salario_real = (salario / inpc)*100

/* (3.10): Generar variables relevantes */
replace zona = 3 if zona == 2 & yeartrim >=191
replace zona = 4 if zona == 1 & yeartrim >=191

gen inghora = ingocup_real / hrsocup

gen lingocup = ln(inghora)
gen lmw = ln(salario_real)
gen lHHI = ln(mean_HHI)
gen treatment = 0
replace treatment = 1 if yeartrim >=191
gen is_pea = fac if clase1 == 1
egen pea = sum(is_pea), by(yeartrim cd_a)

gen sindicato = p3i == 1
gen lproductividad_ptrabajador = ln(productividad_ptrabajdor)
gen lfbkf_ptrabajador = ln(fbkf_ptrabajador)
gen lmargen_operativo = ln(margen_operativo)
gen informalidad = imssissste == 4
gen llabor_force = ln(pea)
gen lhoras = ln(hrsocup) if clase2 == 1

rename (cs_p13_1 cs_p13_2) (nivel grado)
gen esc = .
replace esc = 0 if inlist(nivel, 0, 1, 2, 99)
replace esc = 6 if nivel == 3
replace esc = 9 if inlist(nivel, 4, 5, 6)
replace esc = 12 if nivel == 7
replace esc = 16 if nivel == 8
replace esc = 18 if nivel == 9

replace esc = esc + grado

replace esc = 19 if esc > 19 & esc != .

gen exp = eda - esc - 6
gen exp2 = exp^2

xtile ing_pctile = ingocup_real [fw=fac], nq(100)


/* (3.98): Guardar base completa.*/
sort cd_a yeartrim
compress
save "$docs/ENOE_Base Global_Estatica.dta", replace


/* (3.99): Guardar mini-base para facilitar cálculos.*/
use "$docs/ENOE_Base Global_Estatica.dta", clear
sample 5, by(yeartrim cd_a)

save "$docs/ENOE_Base Global_Estatica_mini.dta", replace






*******************************************
* (4): Generamos base de datos "dinámica" *
*******************************************
use "$docs/ENOE_Base Global_Estatica.dta", clear

*keep if yeartrim >= 201

/* (4.1): Tiramos las entrevistas intermedias. */
drop if n_ent!=1 & n_ent!= 4							

/* (4.2): Generamos variables de tiempo necesarias. */
gen temp = yeartrim
replace temp = . if yeartrim<61
save "$docs/ENOE_Base Global_Dinamica.dta", replace

/* (4.3): Generamos bases de datos temporales para después unirlas. */
* Seleccionamos solo los años-meses que dejamos en temp.
levelsof temp, local(levels) 

* Por cada año de los permitidos por temp, nos quedamos con aquellas variables que corresponden al año y cuatro trimestres antes
local b = 1
foreach i of local levels {
	use "$docs/ENOE_Base Global_Dinamica.dta", clear
	disp "trabajando para yeartrim `i'"
	tempfile `b'
	qui sum yeartrim_lag if yeartrim==`i'
	scalar M = r(mean)
	keep if yeartrim==`i' | yeartrim==r(mean)
	
	* Mantenemos solo a aquellos que tienen entrevista en primer y en cuarto trimestre.
	qui duplicates tag foliop, gen(dup)				
	qui keep if dup==1									
	save "``b''"

	tempfile tempa
	
	* Nos quedamos solo con las observaciones de cuatro trimestres antes.
	qui keep if yeartrim==M
	rename ingreso ingreso1
	cap rename poblab poblab1
	rename ingocup ingocup1
	rename imssissste imssissste1
	rename clase1 clase1ini
	rename clase2 clase2ini
	rename clase3 clase3ini
	save "`tempa'"
	use "``b''", clear
	
	* Nos quedamos solo con las observaciones del trimestre actual.
	qui keep if yeartrim==`i'
	capture drop _merge
	
	* Juntamos las dos bases.
	qui merge m:m foliop using "`tempa'" 
	qui keep if _merge==3
	qui drop dup											
	gen basenum = `b'
	save "``b''", replace
	local b = `b' + 1
}

/* (4.4): Juntamos bases. */
use "$docs/ENOE_Base Global_Dinamica.dta", clear
quietly tab temp
scalar an = r(r)

use "`1'", clear
forvalues i = 2/`=scalar(an)' {
	disp "Trabajando para base `i'"
	capture append using "``i''"
	}
	
/* (4.5): Renombramos variables. */
rename ingreso ingreso2
cap rename poblab poblab2
rename ingocup ingocup2
rename imssissste imssissste2
rename clase1 clase1fin
rename clase2 clase2fin
rename clase3 clase3fin
rename fac factor

/* (4.6): Tiramos a ausentes definitivos, nos quedamos con rango de edad de PEA, entrevistas completas y PEA */
drop if r_def!=0
drop if c_res==2
drop if eda<12 | eda==99
keep if clase1ini==1
compress





save "$docs/ENOE_Base Global_Dinamica.dta", replace



*******************************************
* (5): Generar catálogo de ciudades autorrepresentadas *
*******************************************

*Define catalogue of ciudades autorrepresentadas
use "$docs/ENOE_Base Global_Estatica.dta", clear
collapse (first) cd_a, by(ent mun)
label values cd_a cd_a
sort cd_a ent mun
rename (ent mun) (CVE_ENT CVE_MUN)

save "$docs\cd_a_catalogue.dta", replace


