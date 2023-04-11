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
		global procurement_data	"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\01-dados\01-Brasil"
 		global path_project 	"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\06-Covid_Brazil"
		global path_code 		"C:\Users\leand\Dropbox\3-Profissional\08-Projetos-pessoais\10-GitHub\03-Projects\5-DIME-procurement-team\3-emergency-response-procurement\03-Brazil\01-stata"
		global kcp_data			"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\04-KCP\01-KCP-Brazil/1-data/2-imported"
		global overleaf			"C:\Users\leand\Dropbox\5-Aplicativos\01-Overleaf\03-COVID-Brazil"
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
	
	* packages
	ssc install catplot
	ssc install gtools

	* graphs configuration
	global graph_option graphregion(color(white)) xsize(10) ysize(5)
}
.

* 01: Covid products ( jsut once)
* do "${path_code}/3-analysis/01-Covid_products_criteria_study.do"

* 02: Indicators table
do "${path_code}/3-analysis/02-Indicators_overview_table.do"

* 03: Tender graph
do "${path_code}/3-analysis/03-tender_graphs.do"

* 04: Indexes graphs
do "${path_code}/3-analysis/04-Indexes_graphs.do"

* 05: Product visualization
do "${path_code}/3-analysis/05-stat_product_visualization.do"
