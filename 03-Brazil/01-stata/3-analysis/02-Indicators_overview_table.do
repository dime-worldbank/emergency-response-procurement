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
