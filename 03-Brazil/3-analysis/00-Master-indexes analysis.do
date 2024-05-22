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
 		global path_project 		"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\06-Covid_Brazil"
		global path_code_analysis	"C:\Users\leand\Dropbox\3-Profissional\17-Github\04-WGB\01-procurement\3-emergency-response-procurement\03-Brazil\01-stata\3-analysis"
		global path_firm_data		"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\01-dados\03-Covid-br\01-data"
		
 	}
	.
	
	* 2:XXXX
	if "`c(username)'" == "XXXX" {
 	}
	.
	
	* packages
	cap ssc install ftools
	cap ssc install catplot
	cap ssc install gtools
	cap ssc install reghdfe
	cap ssc install coefplot
			
	* Timer reboot
	timer clear
}
.

* 1: [015 minutes] 
di as white "Running 01-Indicators_overview_table"
timer on    01
	do "${path_code_analysis}/01-Indicators_overview_table.do"
timer off   01

* 2: [001 minutes] 
di as white "Running 02-tender_graphs"
timer on    02
	do "${path_code_analysis}/02-tender_graphs.do"
timer off   02
 
* 3: [002 minutes]
di as white "Running 03-Indexes_graphs"
timer on    03
	do "${path_code_analysis}/03-Indexes_graphs.do"
timer off   03
 
* 4: [002 minutes] 
di as white "Running 04-stat_product_visualization"
timer on    04
	do "${path_code_analysis}/04-stat_product_visualization.do" 
timer off   04

* 5: [800 minutes] Running the impact evaluation of covid product
di as white "Running 05-Impact-evaluation"
timer on    05
	do "${path_code_analysis}/05-Impact-evaluation.do" 
timer off   05

* 6: [410 minutes] Firms analysis
timer on    06
	do "${path_code_analysis}/06-Employer_employee_study.do" 
timer off   06

* 7: It creates latex code for graphs
timer on    07
	do "${path_code_analysis}/07-Create temporaty tex file-for graphs.do" 
timer off   07

* 8:  It creates latex code for panel dashboard overleaf
timer on    08
	do "${path_code_analysis}/08-Tex-creator.do" 
timer off   08

timer list

* Notes:
{
    * 1- I removed duplicates from item data base to have it in item id level. 
	* It is possible to have multiples items for registro de precos, but it is very rare. 
	* For this study it is only make harder merge operation
	
	* Read before come back to project
	Index =>> sample

"Decision time"

INclude N participants

Table 2 
Table 3 

Keep the bad results

Meeting with Chile goverment

To include
Dummy - "Open method"

I can include my opnion*

Check if I have more. 


Put in the dashboard a board introduction with the big picture.

Dashboard with all

01-Dashboards - all we tried 
02-Report Firms ( review the graphs label) - Review
03-Big excel table

	
	
}