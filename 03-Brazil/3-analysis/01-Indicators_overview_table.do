* Made by Leandro Veloso
* Main: Competitions - based on partipants data

* 1: sample 1 
{
	* Period 1
		use  "${path_project}/1_data/04-index_data/P07-semester-index.dta",clear
		append using   "${path_project}/1_data/04-index_data/P07_HHI_index.dta"
		keep if inrange(year,2015,2019) 
		gen period = 1
		tempfile period_1
		save	`period_1'
		 
	* Period 2
		use  "${path_project}/1_data/04-index_data/P07-semester-index.dta",clear
		append using  "${path_project}/1_data/04-index_data/P07_HHI_index.dta"
		keep  if inrange(year,2018,2019) 
		gen period = 2
		tempfile period_2
		save	`period_2'
		
	* Period 3
		use  "${path_project}/1_data/04-index_data/P07-semester-index.dta",clear
		append using  "${path_project}/1_data/04-index_data/P07_HHI_index.dta"
		keep  if inrange(year,2020,2021) 
		gen period = 3
		tempfile period_3
		save	`period_3'
		
	* Period 4
		use  "${path_project}/1_data/04-index_data/P07-semester-index.dta",clear
		append using  "${path_project}/1_data/04-index_data/P07_HHI_index.dta"
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
 	
	* Full table
	{ 
		eststo drop *
		eststo stats_10: quietly estpost summarize $desc_sample_1  if period == 0 ,d 
		eststo stats_11: quietly estpost summarize $desc_sample_1  if period == 1 ,d  
		eststo stats_12: quietly estpost summarize $desc_sample_1  if period == 2 ,d  
		eststo stats_13: quietly estpost summarize $desc_sample_1  if period == 3 ,d
		eststo stats_14: quietly estpost summarize $desc_sample_1  if period == 4 ,d	
		
		esttab stats_10 stats_11 stats_12 stats_13 stats_14    using 	///
			"${path_project}/4_outputs/2-Tables/P1-All_indicators.tex",	/// 
			cells("mean(fmt(%12.2fc))") mtitles("sample" "[2015-2019]" "2018-2019" "[2020-2021]" "[2022]") nonum ///
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
			"${path_project}/4_outputs/2-Tables/P1-All_indicators.tex", ///
			cells("mean(fmt(%12.0fc))") nomtitles nonum ///
			label append f booktabs brackets noobs gap ///
			starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none) 
		}
		.
	}
	.
 
	
	* Select outputs
	{ 
		global desc_sample_1  	avg_S1_participants						///
								share_S1_sme_participants               ///
								share_S1_sme_win                        ///
								avg_S1_win_gap                          ///
								avg_S1_new_winner                       ///
								share_S1_material                       ///
								share_S1_auction                        ///
								share_S1_location_state                 ///
								share_S1_location_munic                 ///
								HHI_S1_5d	                            ///
								HHI_S1_2d								///
								avg_S1_decision_time_trim   
		
		
		global desc_sample_2  	avg_S2_participants  		///
								share_S2_sme_participants 	///
								avg_S2_new_winner 			///
								avg_S2_value_item 			///
								share_S2_sme_participants 
		
		global desc_sample_3 	avg_S3_unit_price_filter				///
								avg_S3_log_unit_price_filter			///
								avg_S3_value_item						///
								avg_S3_value_covid_high					///
								avg_S3_value_covid_med					///
								avg_S3_value_covid_low 					///
								avg_S3_value_covid_none 
		
		*global desc_sample_3 	avg_S3_unit_price_filter				///
		*						avg_S3_log_unit_price_filter			///
		*						avg_S3_value_item		
		
		global general_N	  N_lots N_batches N_ug	    
		
		eststo drop *
		eststo stats_10: quietly estpost summarize $desc_sample_1  if period == 0 ,d 
		eststo stats_11: quietly estpost summarize $desc_sample_1  if period == 1 ,d  
		eststo stats_12: quietly estpost summarize $desc_sample_1  if period == 2 ,d  
		eststo stats_13: quietly estpost summarize $desc_sample_1  if period == 3 ,d
		eststo stats_14: quietly estpost summarize $desc_sample_1  if period == 4 ,d	
		
		esttab stats_10 stats_11 stats_12 stats_13 stats_14    using 	///
			"${path_project}/4_outputs/2-Tables/P1-All_indicators-selected.tex",	/// 
			cells("mean(fmt(%12.2gc))") mtitles("sample" "[2015-2019]" "2018-2019" "[2020-2021]" "[2022]") nonum ///
			label replace f booktabs brackets noobs gap ///
			starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
			
		foreach set_var in desc_sample_2 desc_sample_3   general_N {
			eststo drop *
			eststo stats_10: quietly estpost summarize ${`set_var'} if period == 0 ,d 
			eststo stats_11: quietly estpost summarize ${`set_var'} if period == 1 ,d  
			eststo stats_12: quietly estpost summarize ${`set_var'} if period == 2 ,d  
			eststo stats_13: quietly estpost summarize ${`set_var'} if period == 3 ,d
			eststo stats_14: quietly estpost summarize ${`set_var'} if period == 4 ,d	
		
			esttab stats_10 stats_11 stats_12 stats_13 stats_14    using 	///
			"${path_project}/4_outputs/2-Tables/P1-All_indicators-selected.tex", ///
			cells("mean(fmt(%12.1fc))") nomtitles nonum ///
			label append f booktabs brackets noobs gap ///
			starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none) 
		}
		.
	}
	.	
	
}
.

* 2: Table of products
{
	* 1: Getting all variables
	{ 
		* Reading Covid table
		use "${path_project}/1_data/03-final/02-covid_item-item_level",clear
		keep type_item item_5d_code  Covid_group_level Covid_item_level total total_covid rate_covid_purchase rate_covid
		format %5.4fc rate*
		
		* Merging data
		merge m:1 type_item item_5d_code using ///
			"${path_project}/1_data/01-import-data/Extra-01-catalog-federal-procurement.dta", ///
			keepusing(type_item item_5d_code item_2d_code  item_2d_name   item_2d_name_eng item_5d_name item_5d_name_eng ) nogen keep(3)
		
		label val type_item lab_type
	}
	.
	
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
.

* 3: Firms that starts to sell covid items
{
		* reading
		use year_month bidder_id year_month Covid_item_level SME type_item  item_5d_code  item_5d_name ///
			using "${path_project}/1_data/03-final/05-Lot_item_data",clear
			
		* year month
		gen year  = year(dofm(year_month))
			
		keep if inrange(year, 2018,2020)
		
		gen win =1
		gcollapse (sum) win, by(bidder_id year Covid_item_level) 
		reshape wide win, i(bidder_id year) j(Covid_item_level)
		
		gegen id_num = group(bidder_id)
		xtset id_num year
		
		foreach var of varlist win* {
			replace `var' = 0 if `var' ==.
		}
		.
 		
		cap drop start_covid*
		gen covid_product = (win1+win2+win3) >=1
		
		* didn't win previous year
			gen start_covid_product_1     = (covid_product>0) &  L1.covid_product == . 
		
		* didn't sell previous year
			gen start_covid_product_2     = (covid_product>0) &  L1.covid_product == 0  
		
		* didn't win previous year
			gen start_covid_product_3     = (covid_product>0) & (L1.covid_product != . & L1.covid_product > 0)
		
		gen Hcovid_product = (win3) >=1
		* didn't win previous year
			gen start_Hcovid_product_1     = (Hcovid_product>0) &  L1.Hcovid_product == . 
		
		* didn't sell previous year
			gen start_Hcovid_product_2     = (Hcovid_product>0) &  L1.Hcovid_product == 0  
		
		* didn't win previous year
			gen start_Hcovid_product_3     = (Hcovid_product>0) & (L1.Hcovid_product != . & L1.Hcovid_product > 0)
				
		gcollapse (sum) covid_product Hcovid_product (mean) start_covid_product_* start_Hcovid_product*, by(year) freq(N)
		order year N covid_product start_covid_product_*
		
		label var year					"year tender"
		label var N						"Total Number of Winner Firms"
		
		label var covid_product  		"Number of Firms Selling COVID-19-Related Items"
		label var start_covid_product_1 "Firm share: didn't win a tender"
		label var start_covid_product_2 "Firm share: Sold Only Non-COVID-19 Items"
		label var start_covid_product_3 "Firm share: Sold COVID-19-Related Items"
		
		label var Hcovid_product  		 "Number of Firms Selling High-Level COVID-19 Items"
		label var start_Hcovid_product_1 "Firm share: didn't win a tender"
		label var start_Hcovid_product_2 "Firm share: Sold Only Non-High-Level COVID-19 Items"
		label var start_Hcovid_product_3 "Firm share: Sold High-Level COVID-19 Items"
		
		keep if inrange(year,2019,2020)
		
		format %10.3fc start_covid_*		 
		 	
		eststo drop *
		eststo stats_2019: quietly estpost summarize   N   if year == 2019 ,d 
		eststo stats_2020: quietly estpost summarize   N   if year == 2020 ,d  

		esttab stats_2019 stats_2020  using 	///
			"${path_project}/4_outputs/2-Tables/P1-Firms_starts_covid.tex",	/// 
			cells("mean(fmt(%12.0fc))") mtitles("2019" "2020") nonum ///
			label replace f booktabs brackets noobs gap ///
			starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
 

		eststo drop *
		eststo stats_2019: quietly estpost summarize covid_product start_covid_product_1 start_covid_product_2 start_covid_product_3  if year == 2019 ,d 
		eststo stats_2020: quietly estpost summarize covid_product start_covid_product_1 start_covid_product_2 start_covid_product_3  if year == 2020 ,d  
		
 		esttab stats_2019 stats_2020   using 	///
			"${path_project}/4_outputs/2-Tables/P1-Firms_starts_covid.tex", ///
			cells("mean(fmt(%12.3fc))") nomtitles nonum ///
			label append f booktabs brackets noobs gap ///
			starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none) 
			
	
		eststo drop *
		eststo stats_2019: quietly estpost summarize Hcovid_product start_Hcovid_product_1 start_Hcovid_product_2 start_Hcovid_product_3  if year == 2019 ,d 
		eststo stats_2020: quietly estpost summarize Hcovid_product start_Hcovid_product_1 start_Hcovid_product_2 start_Hcovid_product_3  if year == 2020 ,d  
		
 		esttab stats_2019 stats_2020   using 	///
			"${path_project}/4_outputs/2-Tables/P1-Firms_starts_covid.tex", ///
			cells("mean(fmt(%12.3fc))") nomtitles nonum ///
			label append f booktabs brackets noobs gap ///
			starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)  
}
.