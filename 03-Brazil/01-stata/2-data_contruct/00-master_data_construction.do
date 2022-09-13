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
		global path_KCP_BR    	"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\04-KCP\01-KCP-Brazil"
		global path_firm   		"C:\Users\leand\Dropbox\3-Profissional\00-Base de dados\06-socios\6_clean"	
 		global path_project 	"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\06-Covid_Brazil"
		global path_code 		"C:\Users\leand\Dropbox\3-Profissional\08-Projetos-pessoais\10-GitHub\5-DIME-procurement-team\3-emergency-response-procurement\03-Brazil\01-stata\2-data_contruct"
		global path_rais   		"C:\Users\leand\Dropbox\3-Profissional\00-Base de dados\02-Rais-estabelecimento\5-clean_data\1-rais-estabelecimento\1-stata"	
 	}
	.
	
	* 2:XXXX
	if "`c(username)'" == "XXXX" {
		global path_project 	""
 	}
	.
	
	* 3:ZZZZ
	if "`c(username)'" == "ZZZZ" {
		global path_project 	""
 	}	
	.
	
	* creating folder
	cap mkdir "${path_project}/1_data"
	cap mkdir "${path_project}/2_material"
	cap mkdir "${path_project}/3_writting"
	cap mkdir "${path_project}/4_outputs"
	cap mkdir "${path_project}/4_outputs/1-data_temp"
	cap mkdir "${path_project}/4_outputs/2-Tables"
	cap mkdir "${path_project}/4_outputs/3-Figures"
	cap mkdir "${path_project}/4_outputs/4-TexCompile"
	cap mkdir "${path_project}/4_outputs/1_datatemp"
	
	* graphs configuration
	global graph_option graphregion(color(white)) xsize(10) ysize(5)
}
.

* 1: Firm data - select main information for study
do "${path_code}/01-firm_procurement_data.do"
 
* 2: Data participants: Data offer X item level
do "${path_code}/02-participants_data.do"
 
* 3: Winners: Item level data restricted to products that has a winner.
do "${path_code}/03-winners_data.do" 


* Notes:
{
	* 1-

}
