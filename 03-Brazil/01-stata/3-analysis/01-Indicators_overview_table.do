* Made by Leandro Veloso
* Main: Competitions - based on partipants data

* 1: sample 1 
{
	* Period 1
		use  "${path_project}/1_data/01-index_data/P07-semester-index.dta",clear
		append using  "${path_project}/1_data/P07_HHI_index.dta"
		keep if inrange(year,2015,2019) 
		gen period = 1
		tempfile period_1
		save	`period_1'
		 
	* Period 2
		use  "${path_project}/1_data/01-index_data/P07-semester-index.dta",clear
		append using  "${path_project}/1_data/P07_HHI_index.dta"
		keep  if inrange(year,2018,2019) 
		gen period = 2
		tempfile period_2
		save	`period_2'
		
	* Period 3
		use  "${path_project}/1_data/01-index_data/P07-semester-index.dta",clear
		append using  "${path_project}/1_data/P07_HHI_index.dta"
		keep  if inrange(year,2020,2021) 
		gen period = 3
		tempfile period_3
		save	`period_3'
		
	* Period 4
		use  "${path_project}/1_data/01-index_data/P07-semester-index.dta",clear
		append using  "${path_project}/1_data/P07_HHI_index.dta"
		keep  if inrange(year,2022,2022) 
		gen period = 4
		tempfile period_4
		save	`period_4'
	
	* Joing Periods
	clear
	foreach i of numlist 1/4 {
		di as white "period_`i'"
		append using `period_`i''
	}
	.
	
	* gcollapse
	gcollapse (mean) HHI_2d HHI_5d *S1_* *S2_* *S3_* *S4_* N_lots N_batches N_ug, by(period)  labelformat(#sourcelabel#)
	
	des *S1_* 	
	
	rename  HHI_*d HHI_S1_*d
	
	global desc_sample_1  *S1_* 
	global desc_sample_2  *S2_*
	global desc_sample_3  *S3_*
	global desc_sample_4  *S4_*
	global general_N	  N_lots N_batches N_ug
	
	set obs `=_N+1'
	replace  period = 0 if  period == .
	
	foreach i in 1 2 3 4 {
		foreach var of varlist *S`i'_* {
			replace `var' = `i' if period==0
		}
	}
	.
	
	foreach var of varlist $general_N {
		replace `var' = 1 if period==0
	}
	.
 	
	eststo drop *
	eststo stats_10: quietly estpost summarize $desc_sample_1  if period == 0 ,d 
	eststo stats_11: quietly estpost summarize $desc_sample_1  if period == 1 ,d  
	eststo stats_12: quietly estpost summarize $desc_sample_1  if period == 2 ,d  
	eststo stats_13: quietly estpost summarize $desc_sample_1  if period == 3 ,d
	eststo stats_14: quietly estpost summarize $desc_sample_1  if period == 4 ,d	
	
	esttab stats_10 stats_11 stats_12 stats_13 stats_14    using 	///
		"${overleaf}/01_tables/P1-All_indicators.tex",	/// 
		cells("mean(fmt(%12.4gc))") mtitles("sample" "[2015-2019]" "2018-2019" "[2020-2021]" "[2022]") nonum ///
		label replace f booktabs brackets noobs gap ///
		starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
		
	foreach set_var in desc_sample_2 desc_sample_3 desc_sample_4  general_N {
		eststo drop *
		eststo stats_10: quietly estpost summarize ${`set_var'} if period == 0 ,d 
		eststo stats_11: quietly estpost summarize ${`set_var'} if period == 1 ,d  
		eststo stats_12: quietly estpost summarize ${`set_var'} if period == 2 ,d  
		eststo stats_13: quietly estpost summarize ${`set_var'} if period == 3 ,d
		eststo stats_14: quietly estpost summarize ${`set_var'} if period == 4 ,d	
	
		esttab stats_10 stats_11 stats_12 stats_13 stats_14    using 	///
		"${overleaf}/01_tables/P1-All_indicators.tex", ///
		cells("mean(fmt(%12.0fc))") nomtitles nonum ///
		label append f booktabs brackets noobs gap ///
		starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none) 
	}
	.
}
.

* 2: Table of products
{
	* 1: Getting all variables
	{ 
		* Reading Covid table
		use "${path_project}/1_data/03-covid_item-item_level",clear
		keep type_item item_5d_code  Covid_group_level Covid_item_level total total_covid rate_covid_purchase rate_covid
		format %5.4fc rate*
		
		* Type item
		rename type_item type_item_aux
		gen 	type_item =1  if type_item_aux == "Product"
		replace type_item =2  if type_item_aux == "Service"	
		drop type_item_aux
		
		* Merging data
		merge m:1 type_item item_5d_code using ///
			"${procurement_data}/03-extra_sources/04-clean/01-catalog-federal-procurement.dta", ///
			keepusing(type_item item_5d_code item_2d_code  item_2d_name   item_2d_name_eng item_5d_name item_5d_name_eng ) nogen keep(3)
		
		label val type_item lab_type
	}
	
	* 2: Preparing to export
	{
	    gsort type_item -Covid_group_level -Covid_item_level   item_2d_code -total_covid 
		order Covid_group_level Covid_item_level type_item item_2d_code item_5d_code  item_2d_name_eng item_2d_name  item_5d_name_eng item_5d_name
		
		format  %45s item_*d_name*
		
		label define lab_covid_level  3 "3-High Covid" 2 "2-Medium Covid" 1 "-low Covid" 4 "0-No Covid", replace
		label val Covid_group_level lab_covid_level
		label val Covid_item_level  lab_covid_level
		
		* Labeling variables to export to excel
		label var Covid_item_level  "Covid level item - 5 digits"
		label var Covid_group_level "Covid level item - 2 digits"
		label var type_item			 "Type item - Good or service"
		label var item_2d_code		 "item code - 2 digits"
		label var item_5d_code 		 "item code - 5 digits"
		label var item_2d_name_eng	 "item english name - 2 digits"
		label var item_5d_name_eng 	 "item english name - 5 digits"
		label var item_2d_name		 "item original name - 2 digits"
		label var item_5d_name 		 "item original name - 5 digits"
		
		* Exporting
		export excel using "${path_project}/4_outputs/2-Tables/01-table_products_covid_level.xlsx", replace firstrow(varlabels)
				
	}
}
