* Made by Leandro Veloso
* Main: Indexes study

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
		global path_code 		"C:\Users\leand\Dropbox\3-Profissional\08-Projetos-pessoais\10-GitHub\5-DIME-procurement-team\3-emergency-response-procurement\03-Brazil\01-stata\2-data_contruct"
		global kcp_data			"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\04-KCP\01-KCP-Brazil/1-data/2-imported"
		global overleaf			"C:\Users\leand\Dropbox\5-Aplicativos\Overleaf\03-COVID-Brazil"
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

	* graphs configuration
	global graph_option graphregion(color(white)) xsize(10) ysize(5)
}
.

* Task 1: 
{

}
.

* Notes:
{
	* 1-

}
