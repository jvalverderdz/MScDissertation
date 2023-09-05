*******************************
*aux_import_inpc.do
*This auxiliary dofile imports national price index from Mexico for deflactation of income values
*and stores it into a dta for merge.
*******************************
/* (2.1): Creamos directorio temporal y cambiamos directorio actual. */
capture mkdir "$docs\INPC"
cd "$docs\INPC"

/* (2.2): Descargamos e importamos base de datos INPC. */
copy "https://www.inegi.org.mx/contenidos/programas/inpc/2018/datosabiertos/inpc_indicador_mensual_csv.zip" inpc_indicador_mensual_csv.zip
unzipfile inpc_indicador_mensual_csv.zip
import delimited "$docs\INPC\conjunto_de_datos\conjunto_de_datos_inpc_mensual.csv", encoding(ISO-8859-1) clear
tempfile inpc
save "`inpc'", replace

/* (2.3): Revisamos tipo de sistema operativo y borramos carpeta. */
if c(os) == "MacOSX" {
	shell rm -r "$docs/INPC/"
} 
else {
	shell rd "$docs\INPC\" /s /q
}

/* (2.4): Encontramos mes de IPC. */
rename fecha fechas
gen mes = substr(fechas,4,2)
destring mes, replace
keep if concepto=="Índice nacional de precios al consumidor (mensual), Resumen, Subíndices subyacente y complementarios, Precios al Consumidor (INPC)"
keep if mes==3 | mes==6 | mes==9 | mes==12
keep valor fechas mes

/* (2.5): Generamos variables con las que se harán merge. */
gen year = substr(fechas,9,2)
gen byte trim = mes/3
egen int yeartrim = concat(year trim)
rename valor inpc

keep yeartrim inpc
destring yeartrim, replace

save "$temp\inpc.dta", replace