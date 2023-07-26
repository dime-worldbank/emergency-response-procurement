* Made by Leandro Veloso
* Main: Historic to copy and paste the relevant outputs
 
 global overleaf	 "C:\Users\leand\Dropbox\5-Aplicativos\01-Overleaf\03-COVID-Brazil"
 global overleafdash "C:\Users\leand\Dropbox\5-Aplicativos\01-Overleaf\03-COVID-dashboard"
 
* From: 01-Indicators_overview_table.do
{
	* Line 96
	copy 	"${path_project}/4_outputs/2-Tables/P1-All_indicators.tex" ///
			"${overleaf}/01_tables/P1-All_indicators.tex",replace
			
			
	copy "${path_project}/4_outputs/2-Tables/P1-All_indicators-selected.tex"	///
		 "${overleaf}/01_tables/P1-All_indicators-selected.tex",replace
			
	
}
.

* From: 02-tender_graphs
{
	
	* Line 57
	copy 	"${path_project}/4_outputs/3-Figures/P2-N_tenders-method.png" ///
			"${overleaf}/02_figures/P2-N_tenders-method.pdf",replace

	* Line 66
	copy 	"${path_project}/4_outputs/3-Figures/P2-Covid_tender_n_tenders-method.pdf" ///
			"${overleaf}/02_figures/P2-Covid_tender_n_tenders-method.pdf",replace

	* Line 76
	copy "${path_project}/4_outputs/3-Figures/P2-Covid_tender_Volume-method.pdf"	 ///
		 "${overleaf}/02_figures/P2-Covid_tender_Volume-method.pdf"	 ,replace
}
.

* From: 03-Indexes_graphs
{
	* Line 73: Average by semester
	{ 
		use "${path_project}/1_data/04-index_data/P07-semester-covid-level-index.dta" if _n<=10,clear	
		* drop
		cap drop *covid*
		* Graph All class 
		foreach y_dep of varlist *S1_* *S2_* *S3_* *S4_* N_lots N_batches N_ug {
	 
			copy "${path_project}/4_outputs/3-Figures/P3-Covid-`y_dep'.pdf"	 ///
				 "${overleaf}/02_figures/P3-Covid-`y_dep'.pdf"	 ,replace 

			copy "${path_project}/4_outputs/3-Figures/P3-Covid-`y_dep'.pdf"	 ///
				 "${overleafdash}/01-figures/03-graph_avg/P3-Covid-`y_dep'.pdf"	 ,replace 
				 
		}
		.
	}
	.
	
	* Line 116: Average by year (HHI)
	{ 
		foreach y_dep in HHI_5d shannon_entropy_5d  {
	 
			copy "${path_project}/4_outputs/3-Figures/P3-Covid-`y_dep'.pdf"	 ///
				 "${overleaf}/02_figures/P3-Covid-`y_dep'.pdf"	 ,replace 
		}
		.
	}
	.	
	 
	* Line 170: Graph trend stand
	{ 
		foreach y_dep in  std_price std_log_price {	 
			copy "${path_project}/4_outputs/3-Figures/P3-Covid-`y_dep'.pdf"	 ///
				 "${overleaf}/02_figures/P3-Covid-`y_dep'.pdf"	 ,replace 
		}
		.
	}
	.		 
}
.

* From: 04-stat_product_visualization
{
	* Line 45 - Top volume by covid level ( only the selection from unit price study)
	foreach k in 0 1 2 3 { 
		copy 	"${path_project}/4_outputs/3-Figures/P4-graph_bar-level_covid-`k'.pdf" ///
				"${overleaf}/02_figures/P4-graph_bar-level_covid-`k'.pdf",replace
	}
	.
	
	* Line 170 - Pre-post varible by item.
	foreach words in "avg_n_participants volume" "log_volume avg_n_participants" "log_volume avg_n_win_SME"   "avg_n_win_SME volume" "HHI volume" " log_unit_price_filter volume"  "unit_price_filter volume"  {
		copy 	"${path_project}/4_outputs/3-Figures/P4-scatter_pre_post-`words'.pdf" ///
				"${overleaf}/02_figures/P4-scatter_pre_post-`words'.pdf",replace
				
 	}
	. 
}
.

* From: 05-impact evaluation
{
	* Copy first 
	foreach outcome in $outcome  {
		copy "${path_project}/4_outputs/3-Figures/P5-TWFE-`outcome'.pdf" ///
			 "${overleaf}/02_figures/P5-TWFE-`outcome'.pdf", replace
			 
		copy "${path_project}/4_outputs/3-Figures/P5-TWFE-`outcome'.pdf" ///
			 "${overleafdash}/01-figures/02-TWFE-figure/P5-TWFE-`outcome'.pdf", replace
	}
	.
	
	foreach outcome in $outcome  {
		copy "${path_project}/4_outputs/2-Tables/P5-TWFE-`outcome'.tex"	///
			 "${overleaf}/01_tables/P5-TWFE-`outcome'.tex", replace	
			 
		copy "${path_project}/4_outputs/2-Tables/P5-TWFE-`outcome'.tex"	///
			 "${overleafdash}/02-table/02-twfe-model/P5-TWFE-`outcome'.tex", replace	
	}
	.
	
	* Line 45 - Top volume by covid level ( only the selection from unit price study)
	foreach dep_var in $outcome  {   	
		foreach k in 1 2 3 4 5 {
			copy  "${path_project}/4_outputs/3-Figures/P05-TWFE-time-`dep_var'-FE`k'.png" ///
				  "${overleaf}/02_figures/P05-TWFE-time-`dep_var'-FE`k'.png", replace
				  
			copy  "${path_project}/4_outputs/3-Figures/P05-TWFE-time-`dep_var'-FE`k'.png" ///
				  "${overleafdash}/01-figures/01-event_study/P05-TWFE-time-`dep_var'-FE`k'.png", replace
		}
	}
	.	
}
.

* From: 06-Employer_employee_study
{
	
	* Line 96
	copy 	"${path_project}/4_outputs/2-Tables/P06-firms_procurement.tex" ///
			"${overleaf}/01_tables/P06-firms_procurement.tex",replace
	
	 
	* Variables Create D_exist 
	global main_Vars  F1_D_firm_exist rais_N_workers rais_D_simples rais_N_hire  rais_N_fire   rais_avg_wage log_N_emp log_wage
	* global main_Vars rais_N_workers 	
	
	local filter "all"
 
	foreach var_box in $main_Vars {
		di as white "P06-`filter'-Covid-avg-`var_box'.png"
		copy "${path_project}/4_outputs/3-Figures/P06-`filter'-Covid-avg-`var_box'.png" ///
			 "${overleaf}/02_figures/P06-`filter'-Covid-avg-`var_box'.png", replace
	}	
	.	
}
.

