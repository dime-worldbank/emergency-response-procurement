* Made by Leandro Veloso
* Main: Competitions - based on partipants data


* 1: sample 1 
{
	* Period 1
		use "${path_project}/1_data/01-index_data/P07_index_win" if inrange(year,2015,2019) ,clear
		gen period = 1
		tempfile period_1
		save	`period_1'
		 
	* Period 2
		use "${path_project}/1_data/01-index_data/P07_index_win" if inrange(year,2018,2019) ,clear
		gen period = 2
		tempfile period_2
		save	`period_2'
		
	* Period 3
		use "${path_project}/1_data/01-index_data/P07_index_win" if inrange(year,2020,2021) ,clear
		gen period = 3
		tempfile period_3
		save	`period_3'
		
	* Period 4
		use "${path_project}/1_data/01-index_data/P07_index_win" if inrange(year,2022,2022) ,clear
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
	gcollapse (mean) *S1_* *S2_* *S3_* *S4_* N_lots N_batches N_ug, by(period)  labelformat(#sourcelabel#)
	
	
	des *S1_* 
	
	
	
	
	global desc_sample_1  *S1_*
	global desc_sample_2  *S2_*
	global desc_sample_3  *S3_*
	global desc_sample_4  *S4_*
	global general_N	  N_lots N_batches N_ug
	
	eststo drop *
	eststo stats_11: quietly estpost summarize $desc_sample_1  if period == 1 ,d  
	eststo stats_12: quietly estpost summarize $desc_sample_1  if period == 2 ,d  
	eststo stats_13: quietly estpost summarize $desc_sample_1  if period == 3 ,d
	eststo stats_14: quietly estpost summarize $desc_sample_1  if period == 4 ,d	
	
	
	
	
	esttab stats_12 stats_13 stats_14    using 	///
		"${overleaf}/01_tables/P1-All_indicators.tex",	/// 
		cells("mean(fmt(%12.4gc))") mtitles("[2015-2019]" "2018-2019" "[2020-2021]" "[2022]") nonum ///
		label replace f booktabs brackets noobs gap ///
		starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
	
	
	
	esttab stats_12 stats_13 stats_14    using 	///
	"${overleaf}/01_tables/P1-All_indicators.tex", ///
	cells("mean(fmt(%12.0fc))") nomtitles nonum ///
	label append f booktabs brackets noobs gap ///
	starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none) 
	
	
	eststo drop *
	eststo stats_12: quietly estpost summarize $descript_n  if sample == 3 ,d
	eststo stats_13: quietly estpost summarize $descript_n  if sample == 1 ,d
	eststo stats_14: quietly estpost summarize $descript_n  if sample == 2 ,d 


	 
	esttab stats_12 stats_13 stats_14    using 	///
		"${overleaf}/01_tables/P1-All_indicators.tex",	/// 
		cells("mean(fmt(%12.4gc))") mtitles("sample" "Pre period [2018,2019]"  "Post period [2020,2021]") nonum ///
		label replace f booktabs brackets noobs gap ///
		starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
}


* 1: table pre post indicators
{
	use "${path_project}/4_outputs/1-data_temp/Analysis_03-winner_data.dta",clear
	keep if inrange(year_quarter,yq(2018,1),yq(2021,4))
	
	* replace
	gen D_product 		= type_item			== "Product"
	gen D_auction		= methods  			==1
	gen value_covid		= value_item  if methods  ==1
 	
 	gen id_bidding = substr(id_item,1,17)
	
	keep    id_bidding id_item D_product D_auction  value_covid value_item N_participants SME D_covid D_post
	 
	tempfile data_to_collapse
	save `data_to_collapse' 
	
	* Reading bidding data using all methods
	clear		 
	{
		gen sample = .
		
		* sample 1
		append using `data_to_collapse'
		replace sample=1 if sample ==. & D_post ==0 &  D_product==1 & D_auction==1
		drop if sample==.
		
		* sample 2
		append using `data_to_collapse'
		replace sample=2 if sample ==. & D_post ==1 &  D_product==1 & D_auction==1
		drop if sample==.
	}	
	.
		
	* [Selected to report] Table:1
	{ 		
		* List of measures - Fase processo
		gen byte block_11_rate_prod 		= D_product
		gen byte block_12_rate_auction  	= D_auction
		gen block_13_est_value 				= value_item
		gen block_14_est_value_covid		= value_covid

		* List of measures - Fase processo
		gen block_21_participantes 			= N_participants
		gen block_22_proportion_sme_win 	= SME
 		
		* List of measures - Fase processo
		gen byte block_31_items 	= 1
		bys id_bidding sample: gen byte block_32_batches = _n==1
		
		gen id_ug = substr(id_bidding,1,6)
		bys id_ug sample: gen byte block_34_batches_ug = _n==1
		
		* 
		gen block_33_batches_covid = block_32_batches * D_covid
		
		* Collapsing
		gcollapse (sum) block_3* (mean) block_1* block_2*, by(sample)
		
		* percentage
		foreach var in block_11_rate_prod block_12_rate_auction block_22_proportion_sme_win {
			replace `var'= `var'*100
		}
		.
	
		set obs `=1+_N'
		replace sample = 3 if _n==_N
		
		foreach var of varlist block* {
			replace `var' = 1 if `var'==.			
		}
		.
		
		gen     block_15 =.
		
		label var block_11_rate_prod 			"Share products"
		label var block_12_rate_auction 		"Share SME set-aside"
		label var block_13_est_value	 		"Avg estimated value"
		label var block_14_est_value_covid 		"Avg covid value"
		label var block_15						"Location"
		label var block_21_participantes 		"Avg \# participants"
		label var block_22_proportion_sme_win	"Share SME win"
		label var block_31_items 				"N lots"
		label var block_32_batches		 		"N batches"
		label var block_33_batches_covid 		"N covid batches"
		label var block_34_batches_ug			"N buyer entities"
		
		global descript block_11_rate_prod block_12_rate_auction block_13_est_value block_14_est_value_covid block_15 ///
						block_21_participantes block_22_proportion_sme_win  
						
		global descript_n block_3* 
		
		eststo drop *
		eststo stats_12: quietly estpost summarize $descript  if sample == 3 ,d  
		eststo stats_13: quietly estpost summarize $descript  if sample == 1 ,d
		eststo stats_14: quietly estpost summarize $descript  if sample == 2 ,d
		 
		esttab stats_12 stats_13 stats_14    using 	///
			"${overleaf}/01_tables/P1-All_indicators.tex",	/// 
			cells("mean(fmt(%12.4gc))") mtitles("sample" "Pre period [2018,2019]"  "Post period [2020,2021]") nonum ///
			label replace f booktabs brackets noobs gap ///
			starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
		
		eststo drop *
		eststo stats_12: quietly estpost summarize $descript_n  if sample == 3 ,d
		eststo stats_13: quietly estpost summarize $descript_n  if sample == 1 ,d
		eststo stats_14: quietly estpost summarize $descript_n  if sample == 2 ,d 
 
		esttab stats_12 stats_13 stats_14    using 	///
			"${overleaf}/01_tables/P1-All_indicators.tex", ///
			cells("mean(fmt(%12.0fc))") nomtitles nonum ///
			label append f booktabs brackets noobs gap ///
			starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none) 
	}
	. 
}
.
