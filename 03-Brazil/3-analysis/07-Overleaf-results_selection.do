* Made by Leandro Veloso
* Main: Historic to copy and paste the relevant outputs
 
global overleaf	 "C:\Users\leand\Dropbox\5-Aplicativos\01-Overleaf\03-COVID-Brazil"
global overleafdash "C:\Users\leand\Dropbox\5-Aplicativos\01-Overleaf\03-COVID-dashboard"
 
* From: 01-Indicators_overview_table.do
{
	* Line 96
	{
		copy 	"${path_project}/4_outputs/2-Tables/P1-All_indicators.tex" ///
				"${overleaf}/01_tables/P1-All_indicators.tex",replace
				
		copy 	"${path_project}/4_outputs/2-Tables/P1-All_indicators.tex" ///
				"${overleafdash}/02-table/01-table/P1-All_indicators.tex",replace	
	}
	
	copy "${path_project}/4_outputs/2-Tables/P1-All_indicators-selected.tex"	///
		 "${overleaf}/01_tables/P1-All_indicators-selected.tex",replace
		 
	
	* Line 96
	{
		copy 	"${path_project}/4_outputs/2-Tables/P1-Firms_starts_covid.tex" ///
				"${overleaf}/01_tables/P1-Firms_starts_covid.tex" ,replace
				
		copy 	"${path_project}/4_outputs/2-Tables/P1-Firms_starts_covid.tex" ///
				"${overleafdash}/02-table/01-table/P1-Firms_starts_covid.tex" ,replace	
	}
		 
		 
			
	
}
.

* From: 02-tender_graphs: 
{
	foreach graphs in 	"P2-quarter-N_tenders-method.pdf"				///
						"P2-quarter-Covid_tender_n_tenders-method.pdf"  ///
						"P2-quarter-Covid_tender_Volume-method.pdf"     ///
						"P2-semester-N_tenders-method.pdf"              ///
						"P2-semester-Covid_tender_n_tenders-method.pdf" ///
						"P2-semester-Covid_tender_Volume-method.pdf"    ///
						"P2-quarter-Covid_item-Volume.pdf"              ///
						"P2-quarter-Covid_item-freq.pdf"                ///
						"P2-semester-Covid_item-Volume.pdf"             ///
						"P2-semester-Covid_item-freq.pdf" { 
							
	 
			copy "${path_project}/4_outputs/3-Figures/`graphs'"	 ///
				 "${overleaf}/02_figures/`graphs'"	 ,replace 

			copy "${path_project}/4_outputs/3-Figures/`graphs'"	 ///
				 "${overleafdash}/01-figures/03-graph_avg/`graphs'"	 ,replace 			 
	}
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
				
		copy 	"${path_project}/4_outputs/3-Figures/P4-graph_bar-level_covid-`k'.pdf" ///
				"${overleafdash}/01-figures/03-graph_avg/P4-graph_bar-level_covid-`k'.pdf",replace
				
	}
	.
	
	* Line 170 - Pre-post varible by item.
	foreach words in "avg_n_participants volume" "log_volume avg_n_participants" "log_volume avg_n_win_SME"   "avg_n_win_SME volume" "HHI volume" " log_unit_price_filter volume"  "unit_price_filter volume"  {
		copy 	"${path_project}/4_outputs/3-Figures/P4-scatter_pre_post-`words'.pdf" ///
				"${overleaf}/02_figures/P4-scatter_pre_post-`words'.pdf",replace
				
				
		copy 	"${path_project}/4_outputs/3-Figures/P4-scatter_pre_post-`words'.pdf" ///
				"${overleafdash}/01-figures/03-graph_avg/P4-scatter_pre_post-`words'.pdf" ,replace
	
				
 	}
	. 	
	
	copy 	"${path_project}/4_outputs/3-Figures/P4-Covid_product-criteria.pdf" ///
			"${overleaf}/02_figures/P4-Covid_product-criteria.pdf",replace
			
			
	copy 	"${path_project}/4_outputs/3-Figures/P4-Covid_product-criteria.pdf" ///
			"${overleafdash}/01-figures/03-graph_avg/P4-Covid_product-criteria.pdf" ,replace
	 
	
}
.

* From: 05-impact evaluation
{
	global outcome N_participants  D_new_winner SME share_SME decision_time decision_time_trim 	///
		   unit_price log_volume_item D_same_munic_win D_same_state_win 						///
		   log_unit_price_filter  unit_price_filter  											///
		   N_SME_participants months_since_last_win D_auction HHI_5d sd_log_unit_price
		   
	* Copy first 
	foreach outcome in $outcome  {
		copy "${path_project}/4_outputs/3-Figures/P5-avg_graph_`outcome'.pdf" ///
			 "${overleaf}/02_figures/P5-avg_graph_`outcome'.pdf", replace
			 
		copy "${path_project}/4_outputs/3-Figures/P5-avg_graph_`outcome'.pdf" ///
			 "${overleafdash}/01-figures/03-graph_avg/P5-avg_graph_`outcome'.pdf", replace
	}
	.		    
	
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
			
	copy 	"${path_project}/4_outputs/2-Tables/P06-firms_procurement-survival.tex" ///
			"${overleaf}/01_tables/P06-firms_procurement-survival.tex",replace
	
	* Variables Create D_exist 
	global main_Vars D_firm_exist_2021 F1_D_firm_exist rais_N_workers rais_D_simples rais_N_hire  rais_N_fire   rais_avg_wage log_N_emp log_wage
	* global main_Vars rais_N_workers 	
	
	local filter "all"
 
	foreach var_box in $main_Vars {
		di as white "P06-`filter'-Covid-avg-`var_box'.png"
		copy "${path_project}/4_outputs/3-Figures/P06-`filter'-Covid-avg-`var_box'.png" ///
			 "${overleaf}/02_figures/P06-`filter'-Covid-avg-`var_box'.png", replace
			 
		copy "${path_project}/4_outputs/3-Figures/P06-`filter'-Covid-avg-`var_box'-no_ci.png" ///
			 "${overleaf}/02_figures/P06-`filter'-Covid-avg-`var_box'-no_ci.png", replace
			 
		
	}	
	.	
	
	* Model selections
	import delim "${path_project}/4_outputs/2-Tables/P06-firm_models.txt",clear
	
	global keep_list "v1"
	
	
	
	foreach var of varlist * {
		if (regex(`var'[2],"year:2018") & regex(`var'[4],"F1")) | (regex(`var'[2],"year:2020") & regex(`var'[4],"F1")) {
			global keep_list "${keep_list} `var'"			
		}		
	}
	
	keep ${keep_list}
	
	global keep_list "v1"
	 
	foreach var of varlist * {
		if regex(`var'[15],"1") {
			global keep_list "${keep_list} `var'"			
		}		
	}
	
	
	di as white "${keep_list}"
	
	keep ${keep_list}
}
.

* 

	copy 	"${path_project}/4_outputs/3-Figures/05-Covid_group_estimation-item.png" ///
			"${overleafdash}/01-figures/03-graph_avg/05-Covid_group_estimation-item.png",replace
	
