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

* 1: label function for report
{
	cap program drop label_function
	program define label_function
		di as white "Inluding english labels"
		* Loop over variables all variables, if exist it receives the label
		qui foreach y_dep of varlist * {
	 
			* Adjusting labels
			if "`y_dep'" =="N_participants"				label var `y_dep' "number of bidders"
			if "`y_dep'" =="N_SME_participants"			label var `y_dep' "E[Number of Participants SME]" 
			if "`y_dep'" =="SME"						label var `y_dep' "share of winners that are small/micro firms"
			if "`y_dep'" =="share_SME"					label var `y_dep' "share of bidders that are small/micro firms"
			if "`y_dep'" =="D_new_winner"				label var `y_dep' "share of firms that are new winners"
			if "`y_dep'" =="D_new_winner_12"			label var `y_dep' "share of firms that are new winners"
			if "`y_dep'" =="log_volume_item"			label var `y_dep' "E[log(volume item)]"
			if "`y_dep'" =="unit_price"		 			label var `y_dep' "E[Unit Price]"
			if "`y_dep'" =="log_unit_price_filter" 		label var `y_dep' "E[Unit Price (log) - filter]"		
			if "`y_dep'" =="unit_price_def"		 		label var `y_dep' "E[Unit Price in 2019 BRL]"
			if "`y_dep'" =="unit_price_filter" 			label var `y_dep' "E[Unit Price - filter]"
			if "`y_dep'" =="unit_price_filter_def" 		label var `y_dep' "E[Unit Price in 2019 BRL - filter]"		
			if "`y_dep'" =="log_unit_price_filter_def" 	label var `y_dep' "E[Unit Price (log) in 2019 BRL - filter]"
			if "`y_dep'" =="HHI_5d"						label var `y_dep' "E[HHI item index by year semester]"
			if "`y_dep'" =="D_auction"					label var `y_dep' "Share of tenders using the reverse auction method"
			if "`y_dep'" =="sd_log_unit_price"			label var `y_dep' "E[var(log(Unit Price - filter))]"	
			if "`y_dep'" =="decision_time_auction"		label var `y_dep' "time between starts of the process and contract award"	
			if "`y_dep'" =="decision_time_trim"			label var `y_dep' "time between starts of the process and contract award"	
		}                                                
	end program
	
}


* 2: Final report set do-files: Only the code for the final output
{
	* 8:  It creates latex code for panel dashboard overleaf
	timer on    08
		do "${path_code_analysis}/08-Outputs_review-20240620.do" 
	timer off   08

	* 8:  It creates latex code for panel dashboard overleaf
	timer on    09
		do "${path_code_analysis}/09-Report_output_copy_and_paste.do" 
	timer off   09
	
	timer list
}
.

* 3: Full outputs: This set of outputs run all results generated in the study.
{
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

	* 7: Copy and paste to overleaf sync folder
	timer on    07
		do "${path_code_analysis}/07-Overleaf-results_selection.do" 
	timer off   07
	
	* 8:  It creates latex code for panel dashboard overleaf
	timer on    08
		do "${path_code_analysis}/08-Outputs_review-20240516.do" 
	timer off   08

	* 8:  It creates latex code for panel dashboard overleaf
	timer on    09
		do "${path_code_analysis}/09-Report_output_copy_and_paste.do" 
	timer off   09
	
	timer list
}
}
.

* Notes:
{
    * 1- I removed duplicates from item data base to have it in item id level. 
	* It is possible to have multiples items for registro de precos, but it is very rare. 
	* For this study it is only make harder merge operation

}