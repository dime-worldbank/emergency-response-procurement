* Made by Leandro Veloso
* Main: Master dofile to create the data for COVID study

* 0: Setting stata
{
	* Clean stata console
	clear all
	cls

	* Set options
	set varabbrev on, perm
	set more off, perm
	set matsize 11000, perm

	* defying path
	* 1: Leandro Justino
	if "`c(username)'" == "leand" {	
 		global path_project 	"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\06-Covid_Brazil"
		global path_code_data	"C:\Users\leand\Dropbox\3-Profissional\17-Github\04-WGB\01-procurement\3-emergency-response-procurement\03-Brazil\01-stata\2-data_contruct"
		global path_rais 		"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\01-dados\02-rais-procurement"
 		global overleaf			"C:\Users\leand\Dropbox\5-Aplicativos\01-Overleaf\03-COVID-Brazil"
		
 	}
	.
	
	* 2: XXXX
	if "`c(username)'" == "XXXX" {
		global path_project 	""
 	}
	.
	
	* 3: ZZZZ
	if "`c(username)'" == "ZZZZ" {
		global path_project 	""
 	}	
	.
	
	* creating folder
	cap mkdir "${path_project}/1_data"
	cap mkdir "${path_project}/1_data/01-index_data"
	cap mkdir "${path_project}/2_material"
	cap mkdir "${path_project}/3_writting"
	cap mkdir "${path_project}/4_outputs"
	cap mkdir "${path_project}/4_outputs/1-data_temp"
	cap mkdir "${path_project}/4_outputs/2-Tables"
	cap mkdir "${path_project}/4_outputs/3-Figures"
	cap mkdir "${path_project}/4_outputs/4-TexCompile"
	cap mkdir "${path_project}/4_outputs/1_datatemp"
	
	* graphs configuration
	global graph_option graphregion(color(white)) xsize(10) ysize(5) /*
		*/ xtitle("quater/year") xlabel(`=ym(2015,2)'(2)`=ym(2022,6)', angle(90))
		
		
	* Timer reboot
	timer clear
}
.

* 1: [003 minutes] Prepating tender data
timer on  01
	do "${path_code_data}/01-tender_data.do"
timer off 01

* 2: [004 minutes]  Estimating covid products
timer on   02
	do "${path_code_data}/02-Covid_products.do"
timer off  02
 
* 3: [059 minutes] Preparing firm data
timer on    03
	do "${path_code_data}/03-Firm_data.do"
timer off   03
 
* 4: [025 minutes] Preparing participants item level data firm data
timer on    04
	do "${path_code_data}/04-participants_data.do" 
timer off    04

* 5: [018 minutes] Create the main data  (lot/tender) with all necessary variables
timer on    05
	do "${path_code_data}/05-lot_tender_data.do" 
timer off   05

* 6: Preparing establishment panel to evaluation
timer on    06
	do "${path_code_data}/06-Employer_employee_indicators.do" 
timer off    06

* 7: Calculating indexes
timer on    07
	do "${path_code_data}/07-Calculating_indicators.do" 
timer off   07

timer list

* Notes:
{
    * 1- I removed duplicates from item data base to have it in item id level. 
	* It is possible to have multiples items for registro de precos, but it is very rare. 
	* For this study it is only make harder merge operation
	
	
}


 