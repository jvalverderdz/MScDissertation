/*******************************************************************************
1_1_CE_explore.do
Author: Javier Valverde
Version: 1.0

This Dofile uses Economic Census microdata to generate labour market concentration indices
by 4 and 3-digit SCIAN categories and representative cities from ENOE

*******************************************************************************/
*******************************************************************************

***************************1. Import and keep relevant variables****************
cap use "CE2019.dta", clear

rename *, lower

*rename (entidad municipio clase) (e03 e04 e17)
*gen h001d = runiform(160, 1600)
*gen a231a = runiform(0, 50)

*Keep relevant variables
keep e03 e04 e17 h001a h001d j000a a111a a131a a211a a221a a231a

*Rename variables
rename (e03 e04 e17 h001a h001d j000a a111a a131a a211a a221a a231a) ///
	(cve_ent cve_mun scian personal_ocupado horas_trabajadas total_remuneraciones produccion_bruta_total valor_agregado_censal_bruto inversion_total fbkf margen_operativo)

destring *, replace

***************************2. Keep relevant observations************************
*Representative cities
gen cd_a = 0

replace cd_a = 1 if cve_ent == 9 & cve_mun == 2
replace cd_a = 1 if cve_ent == 9 & cve_mun == 3
replace cd_a = 1 if cve_ent == 9 & cve_mun == 4
replace cd_a = 1 if cve_ent == 9 & cve_mun == 5
replace cd_a = 1 if cve_ent == 9 & cve_mun == 6
replace cd_a = 1 if cve_ent == 9 & cve_mun == 7
replace cd_a = 1 if cve_ent == 9 & cve_mun == 8
replace cd_a = 1 if cve_ent == 9 & cve_mun == 9
replace cd_a = 1 if cve_ent == 9 & cve_mun == 10
replace cd_a = 1 if cve_ent == 9 & cve_mun == 11
replace cd_a = 1 if cve_ent == 9 & cve_mun == 12
replace cd_a = 1 if cve_ent == 9 & cve_mun == 13
replace cd_a = 1 if cve_ent == 9 & cve_mun == 14
replace cd_a = 1 if cve_ent == 9 & cve_mun == 15
replace cd_a = 1 if cve_ent == 9 & cve_mun == 16
replace cd_a = 1 if cve_ent == 9 & cve_mun == 17
replace cd_a = 1 if cve_ent == 15 & cve_mun == 2
replace cd_a = 1 if cve_ent == 15 & cve_mun == 11
replace cd_a = 1 if cve_ent == 15 & cve_mun == 13
replace cd_a = 1 if cve_ent == 15 & cve_mun == 20
replace cd_a = 1 if cve_ent == 15 & cve_mun == 23
replace cd_a = 1 if cve_ent == 15 & cve_mun == 24
replace cd_a = 1 if cve_ent == 15 & cve_mun == 25
replace cd_a = 1 if cve_ent == 15 & cve_mun == 28
replace cd_a = 1 if cve_ent == 15 & cve_mun == 29
replace cd_a = 1 if cve_ent == 15 & cve_mun == 30
replace cd_a = 1 if cve_ent == 15 & cve_mun == 31
replace cd_a = 1 if cve_ent == 15 & cve_mun == 33
replace cd_a = 1 if cve_ent == 15 & cve_mun == 37
replace cd_a = 1 if cve_ent == 15 & cve_mun == 39
replace cd_a = 1 if cve_ent == 15 & cve_mun == 44
replace cd_a = 1 if cve_ent == 15 & cve_mun == 53
replace cd_a = 1 if cve_ent == 15 & cve_mun == 57
replace cd_a = 1 if cve_ent == 15 & cve_mun == 58
replace cd_a = 1 if cve_ent == 15 & cve_mun == 59
replace cd_a = 1 if cve_ent == 15 & cve_mun == 60
replace cd_a = 1 if cve_ent == 15 & cve_mun == 70
replace cd_a = 1 if cve_ent == 15 & cve_mun == 81
replace cd_a = 1 if cve_ent == 15 & cve_mun == 91
replace cd_a = 1 if cve_ent == 15 & cve_mun == 92
replace cd_a = 1 if cve_ent == 15 & cve_mun == 93
replace cd_a = 1 if cve_ent == 15 & cve_mun == 95
replace cd_a = 1 if cve_ent == 15 & cve_mun == 99
replace cd_a = 1 if cve_ent == 15 & cve_mun == 100
replace cd_a = 1 if cve_ent == 15 & cve_mun == 104
replace cd_a = 1 if cve_ent == 15 & cve_mun == 108
replace cd_a = 1 if cve_ent == 15 & cve_mun == 109
replace cd_a = 1 if cve_ent == 15 & cve_mun == 120
replace cd_a = 1 if cve_ent == 15 & cve_mun == 121
replace cd_a = 1 if cve_ent == 15 & cve_mun == 122
replace cd_a = 2 if cve_ent == 14 & cve_mun == 39
replace cd_a = 2 if cve_ent == 14 & cve_mun == 70
replace cd_a = 2 if cve_ent == 14 & cve_mun == 97
replace cd_a = 2 if cve_ent == 14 & cve_mun == 98
replace cd_a = 2 if cve_ent == 14 & cve_mun == 101
replace cd_a = 2 if cve_ent == 14 & cve_mun == 120
replace cd_a = 3 if cve_ent == 19 & cve_mun == 6
replace cd_a = 3 if cve_ent == 19 & cve_mun == 10
replace cd_a = 3 if cve_ent == 19 & cve_mun == 18
replace cd_a = 3 if cve_ent == 19 & cve_mun == 19
replace cd_a = 3 if cve_ent == 19 & cve_mun == 21
replace cd_a = 3 if cve_ent == 19 & cve_mun == 26
replace cd_a = 3 if cve_ent == 19 & cve_mun == 31
replace cd_a = 3 if cve_ent == 19 & cve_mun == 39
replace cd_a = 3 if cve_ent == 19 & cve_mun == 45
replace cd_a = 3 if cve_ent == 19 & cve_mun == 46
replace cd_a = 3 if cve_ent == 19 & cve_mun == 48
replace cd_a = 3 if cve_ent == 19 & cve_mun == 49
replace cd_a = 4 if cve_ent == 21 & cve_mun == 15
replace cd_a = 4 if cve_ent == 21 & cve_mun == 34
replace cd_a = 4 if cve_ent == 21 & cve_mun == 41
replace cd_a = 4 if cve_ent == 21 & cve_mun == 90
replace cd_a = 4 if cve_ent == 21 & cve_mun == 106
replace cd_a = 4 if cve_ent == 21 & cve_mun == 114
replace cd_a = 4 if cve_ent == 21 & cve_mun == 119
replace cd_a = 4 if cve_ent == 21 & cve_mun == 125
replace cd_a = 4 if cve_ent == 21 & cve_mun == 136
replace cd_a = 4 if cve_ent == 21 & cve_mun == 140
replace cd_a = 4 if cve_ent == 21 & cve_mun == 181
replace cd_a = 5 if cve_ent == 11 & cve_mun == 20
replace cd_a = 5 if cve_ent == 11 & cve_mun == 25
replace cd_a = 5 if cve_ent == 11 & cve_mun == 31
replace cd_a = 6 if cve_ent == 5 & cve_mun == 17
replace cd_a = 6 if cve_ent == 5 & cve_mun == 35
replace cd_a = 6 if cve_ent == 10 & cve_mun == 7
replace cd_a = 6 if cve_ent == 10 & cve_mun == 12
replace cd_a = 7 if cve_ent == 24 & cve_mun == 28
replace cd_a = 7 if cve_ent == 24 & cve_mun == 35
replace cd_a = 8 if cve_ent == 31 & cve_mun == 41
replace cd_a = 8 if cve_ent == 31 & cve_mun == 50
replace cd_a = 8 if cve_ent == 31 & cve_mun == 59
replace cd_a = 8 if cve_ent == 31 & cve_mun == 101
replace cd_a = 9 if cve_ent == 8 & cve_mun == 19
replace cd_a = 10 if cve_ent == 28 & cve_mun == 3
replace cd_a = 10 if cve_ent == 28 & cve_mun == 9
replace cd_a = 10 if cve_ent == 28 & cve_mun == 38
replace cd_a = 10 if cve_ent == 30 & cve_mun == 123
replace cd_a = 10 if cve_ent == 30 & cve_mun == 133
replace cd_a = 12 if cve_ent == 30 & cve_mun == 28
replace cd_a = 12 if cve_ent == 30 & cve_mun == 193
replace cd_a = 13 if cve_ent == 12 & cve_mun == 1
replace cd_a = 14 if cve_ent == 1 & cve_mun == 1
replace cd_a = 14 if cve_ent == 1 & cve_mun == 5
replace cd_a = 15 if cve_ent == 16 & cve_mun == 53
replace cd_a = 15 if cve_ent == 16 & cve_mun == 88
replace cd_a = 16 if cve_ent == 15 & cve_mun == 5
replace cd_a = 16 if cve_ent == 15 & cve_mun == 18
replace cd_a = 16 if cve_ent == 15 & cve_mun == 51
replace cd_a = 16 if cve_ent == 15 & cve_mun == 54
replace cd_a = 16 if cve_ent == 15 & cve_mun == 55
replace cd_a = 16 if cve_ent == 15 & cve_mun == 67
replace cd_a = 16 if cve_ent == 15 & cve_mun == 76
replace cd_a = 16 if cve_ent == 15 & cve_mun == 106
replace cd_a = 16 if cve_ent == 15 & cve_mun == 118
replace cd_a = 17 if cve_ent == 5 & cve_mun == 27
replace cd_a = 17 if cve_ent == 5 & cve_mun == 30
replace cd_a = 18 if cve_ent == 27 & cve_mun == 4
replace cd_a = 18 if cve_ent == 27 & cve_mun == 13
replace cd_a = 19 if cve_ent == 7 & cve_mun == 27
replace cd_a = 19 if cve_ent == 7 & cve_mun == 101
replace cd_a = 20 if cve_ent == 8 & cve_mun == 37
replace cd_a = 21 if cve_ent == 2 & cve_mun == 4
replace cd_a = 24 if cve_ent == 25 & cve_mun == 6
replace cd_a = 25 if cve_ent == 26 & cve_mun == 30
replace cd_a = 26 if cve_ent == 10 & cve_mun == 5
replace cd_a = 27 if cve_ent == 18 & cve_mun == 8
replace cd_a = 27 if cve_ent == 18 & cve_mun == 17
replace cd_a = 28 if cve_ent == 4 & cve_mun == 2
replace cd_a = 29 if cve_ent == 17 & cve_mun == 7
replace cd_a = 29 if cve_ent == 17 & cve_mun == 8
replace cd_a = 29 if cve_ent == 17 & cve_mun == 11
replace cd_a = 29 if cve_ent == 17 & cve_mun == 18
replace cd_a = 29 if cve_ent == 17 & cve_mun == 20
replace cd_a = 29 if cve_ent == 17 & cve_mun == 28
replace cd_a = 29 if cve_ent == 17 & cve_mun == 29
replace cd_a = 30 if cve_ent == 30 & cve_mun == 39
replace cd_a = 30 if cve_ent == 30 & cve_mun == 48
replace cd_a = 31 if cve_ent == 20 & cve_mun == 67
replace cd_a = 31 if cve_ent == 20 & cve_mun == 83
replace cd_a = 31 if cve_ent == 20 & cve_mun == 87
replace cd_a = 31 if cve_ent == 20 & cve_mun == 91
replace cd_a = 31 if cve_ent == 20 & cve_mun == 107
replace cd_a = 31 if cve_ent == 20 & cve_mun == 115
replace cd_a = 31 if cve_ent == 20 & cve_mun == 157
replace cd_a = 31 if cve_ent == 20 & cve_mun == 174
replace cd_a = 31 if cve_ent == 20 & cve_mun == 227
replace cd_a = 31 if cve_ent == 20 & cve_mun == 293
replace cd_a = 31 if cve_ent == 20 & cve_mun == 350
replace cd_a = 31 if cve_ent == 20 & cve_mun == 375
replace cd_a = 31 if cve_ent == 20 & cve_mun == 385
replace cd_a = 31 if cve_ent == 20 & cve_mun == 390
replace cd_a = 31 if cve_ent == 20 & cve_mun == 399
replace cd_a = 31 if cve_ent == 20 & cve_mun == 403
replace cd_a = 31 if cve_ent == 20 & cve_mun == 409
replace cd_a = 31 if cve_ent == 20 & cve_mun == 519
replace cd_a = 31 if cve_ent == 20 & cve_mun == 553
replace cd_a = 32 if cve_ent == 32 & cve_mun == 17
replace cd_a = 32 if cve_ent == 32 & cve_mun == 56
replace cd_a = 33 if cve_ent == 6 & cve_mun == 2
replace cd_a = 33 if cve_ent == 6 & cve_mun == 10
replace cd_a = 36 if cve_ent == 22 & cve_mun == 6
replace cd_a = 36 if cve_ent == 22 & cve_mun == 11
replace cd_a = 36 if cve_ent == 22 & cve_mun == 14
replace cd_a = 39 if cve_ent == 29 & cve_mun == 1
replace cd_a = 39 if cve_ent == 29 & cve_mun == 2
replace cd_a = 39 if cve_ent == 29 & cve_mun == 5
replace cd_a = 39 if cve_ent == 29 & cve_mun == 9
replace cd_a = 39 if cve_ent == 29 & cve_mun == 10
replace cd_a = 39 if cve_ent == 29 & cve_mun == 17
replace cd_a = 39 if cve_ent == 29 & cve_mun == 18
replace cd_a = 39 if cve_ent == 29 & cve_mun == 22
replace cd_a = 39 if cve_ent == 29 & cve_mun == 23
replace cd_a = 39 if cve_ent == 29 & cve_mun == 24
replace cd_a = 39 if cve_ent == 29 & cve_mun == 25
replace cd_a = 39 if cve_ent == 29 & cve_mun == 26
replace cd_a = 39 if cve_ent == 29 & cve_mun == 27
replace cd_a = 39 if cve_ent == 29 & cve_mun == 28
replace cd_a = 39 if cve_ent == 29 & cve_mun == 29
replace cd_a = 39 if cve_ent == 29 & cve_mun == 31
replace cd_a = 39 if cve_ent == 29 & cve_mun == 32
replace cd_a = 39 if cve_ent == 29 & cve_mun == 33
replace cd_a = 39 if cve_ent == 29 & cve_mun == 35
replace cd_a = 39 if cve_ent == 29 & cve_mun == 36
replace cd_a = 39 if cve_ent == 29 & cve_mun == 38
replace cd_a = 39 if cve_ent == 29 & cve_mun == 39
replace cd_a = 39 if cve_ent == 29 & cve_mun == 40
replace cd_a = 39 if cve_ent == 29 & cve_mun == 41
replace cd_a = 39 if cve_ent == 29 & cve_mun == 42
replace cd_a = 39 if cve_ent == 29 & cve_mun == 43
replace cd_a = 39 if cve_ent == 29 & cve_mun == 44
replace cd_a = 39 if cve_ent == 29 & cve_mun == 48
replace cd_a = 39 if cve_ent == 29 & cve_mun == 49
replace cd_a = 39 if cve_ent == 29 & cve_mun == 50
replace cd_a = 39 if cve_ent == 29 & cve_mun == 51
replace cd_a = 39 if cve_ent == 29 & cve_mun == 53
replace cd_a = 39 if cve_ent == 29 & cve_mun == 54
replace cd_a = 39 if cve_ent == 29 & cve_mun == 57
replace cd_a = 39 if cve_ent == 29 & cve_mun == 58
replace cd_a = 39 if cve_ent == 29 & cve_mun == 59
replace cd_a = 39 if cve_ent == 29 & cve_mun == 60
replace cd_a = 40 if cve_ent == 3 & cve_mun == 3
replace cd_a = 41 if cve_ent == 23 & cve_mun == 3
replace cd_a = 41 if cve_ent == 23 & cve_mun == 5
replace cd_a = 42 if cve_ent == 4 & cve_mun == 3
replace cd_a = 43 if cve_ent == 13 & cve_mun == 48
replace cd_a = 43 if cve_ent == 13 & cve_mun == 51
replace cd_a = 44 if cve_ent == 2 & cve_mun == 2
replace cd_a = 46 if cve_ent == 28 & cve_mun == 32
replace cd_a = 52 if cve_ent == 7 & cve_mun == 89

*Keep only relevant cities
keep if cd_a != 0


***************************3. Generate relevant variables***********************

*4 and 3-digit Industry clasification
tostring scian, replace
gen scian_4 = substr(scian, 1, 4)
gen scian_3 = substr(scian, 1, 3)

*Total employment
egen total_personal_ocupado = sum(personal_ocupado), by(scian_4 cd_a)
egen total_personal_ocupado_3 = sum(personal_ocupado), by(scian_3 cd_a)

*Share of employment
gen share_empleo = (personal_ocupado / total_personal_ocupado)*100
gen share_empleo_3 = (personal_ocupado / total_personal_ocupado_3)*100

*Share of employment squared
gen share_empleo_sqrt = share_empleo^2
gen share_empleo_3_sqrt = share_empleo_3^2

*Herfindahl-Hirschman Index
egen HHI = sum(share_empleo_sqrt), by(scian_4 cd_a)
egen HHI_3 = sum(share_empleo_3_sqrt), by(scian_3 cd_a)

*Average number of employees
egen personal_ocupado_promedio = mean(personal_ocupado), by(scian_4 cd_a)
egen personal_ocupado_promedio_3 = mean(personal_ocupado), by(scian_3 cd_a)

*Percentiles of number of employees
egen personal_ocupado_p25 = pctile(personal_ocupado), by(scian_4 cd_a) p(25)
egen personal_ocupado_p50 = pctile(personal_ocupado), by(scian_4 cd_a) p(50)
egen personal_ocupado_p75 = pctile(personal_ocupado), by(scian_4 cd_a) p(75)
egen personal_ocupado_max = max(personal_ocupado), by(scian_4 cd_a)

egen personal_ocupado_3_p25 = pctile(personal_ocupado), by(scian_3 cd_a) p(25)
egen personal_ocupado_3_p50 = pctile(personal_ocupado), by(scian_3 cd_a) p(50)
egen personal_ocupado_3_p75 = pctile(personal_ocupado), by(scian_3 cd_a) p(75)
egen personal_ocupado_3_max = max(personal_ocupado), by(scian_3 cd_a)

*Standard deviation of number of employees
egen personal_ocupado_sd = sd(personal_ocupado), by(scian_4 cd_a)
egen personal_ocupado_3_sd = sd(personal_ocupado), by(scian_3 cd_a)

*Average wages, productivity and capital formation
gen remuneraciones_promedio = total_remuneraciones / personal_ocupado
gen productividad_ptrabajdor = produccion_bruta_total / personal_ocupado
gen productividad_phora = produccion_bruta_total / horas_trabajadas
gen fbkf_ptrabajador = fbkf / personal_ocupado

gen counter = 1

*Aggregate by industry and city
collapse (count) numero_firmas = counter ///
	(first) HHI HHI_3 total_personal_ocupado total_personal_ocupado_3 personal_ocupado_promedio personal_ocupado_promedio_3 ///
	personal_ocupado_p25 personal_ocupado_p50 personal_ocupado_p75 personal_ocupado_max personal_ocupado_3_p25 personal_ocupado_3_p50 personal_ocupado_3_p75 personal_ocupado_3_max ///
	personal_ocupado_sd personal_ocupado_3_sd ///
	(mean) share_empleo share_empleo_3 horas_trabajadas_promedio = horas_trabajadas remuneraciones_promedio productividad_ptrabajdor productividad_phora fbkf fbkf_ptrabajador margen_operativo ///
	(sum) horas_trabajadas total_remuneraciones produccion_bruta_total valor_agregado_censal_bruto inversion_total fbkf_total = fbkf, by(scian_4 cd_a)

	
	
	
***************************99. Export*******************************************
	
save "HHI_ciudades_autorrepresentadas_CE.dta", replace