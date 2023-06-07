* Made by Leandro Veloso
* Main: Create data in the index level.
  
* 1: Lot data:
{
	* 01: Reading data_temp/P07_hhi_2d
	{
		* Reading data
		use "${path_project}/1_data/03-final/05-Lot_item_data",clear
		* keep if runiform()<=0.01
		* Keeping only relevant varibles
		keep ///
			year_month 				/// year month
			methods 				/// methods
			N_participants 			/// share participants
			N_SME_participants		/// Share of SME participants
			D_winner				/// dummy year
			SME						/// dummy if the winner is SME
			D_new_winner			/// dummy new winner
			months_since			/// gap age
			share_SME				/// share sme participants
			D_product				/// Dummy material
			D_auction				/// Dummy auction
			decision_time 			/// Decision time
			decision_time_trim		/// Decision time proxy
			unit_price				/// unit price
			item_value				/// item item_value
			Covid_item_level		///  Covid item
			tender_id ug_id			///
			D_same_munic_win D_same_state_win ///
			log_unit_price_filter  unit_price_filter
			 
		* Sample 1: ALL
			gen share_S1_sme_win 				= SME 
			gen share_S1_material				= D_product
			gen share_S1_auction				= D_auction
			gen N_S1_new_winnes 				= D_new_winner
			gen avg_S1_win_gap 					= months_since
			gen avg_S1_decision_time_trim 		= decision_time_trim
			gen avg_S1_unit_price_non_restrict	= unit_price
			gen avg_S1_value_item				= item_value
			gen avg_S1_participants				= N_participants
			gen share_S1_location_munic			= D_same_munic_win
			gen share_S1_location_state			= D_same_state_win
			gen share_S1_sme_participants 		= share_SME  
		
		* Sample 2: Only Auction 
			gen N_S2_new_winnes 				= D_new_winner	 if D_auction == 1
			gen avg_S2_participants				= N_participants if D_auction == 1
			gen share_S2_sme_participants 		= share_SME 	 if D_auction == 1
			gen avg_S2_decision_time 			= decision_time  if D_auction == 1
			gen avg_S2_value_item				= item_value 	 if D_auction == 1

		* Sample 3: ALL & Only material
			gen avg_S3_participants				= N_participants if D_product == 1
			gen share_S3_sme_participants 		= share_SME 	 if D_product == 1
			gen share_S3_sme_win 				= SME 			 if D_product == 1
			gen avg_S3_decision_time 			= decision_time  if D_product == 1
			gen avg_S3_value_item				= item_value 	 if D_product == 1
			gen avg_S3_unit_price_filter		= unit_price_filter	 if D_product == 1
			gen avg_S3_log_unit_price_filter	= log_unit_price_filter	 if D_product == 1
			gen avg_S3_value_covid_high			= item_value 	 if D_product == 1 & Covid_item_level==3
			gen avg_S3_value_covid_med			= item_value 	 if D_product == 1 & Covid_item_level==2
			gen avg_S3_value_covid_low			= item_value 	 if D_product == 1 & Covid_item_level==1
			gen avg_S3_value_covid_none			= item_value 	 if D_product == 1 & Covid_item_level==0

		* Sample 4: Auction & Only material	
			gen avg_S4_participants				= N_participants if D_auction == 1 & D_product == 1
			gen share_S4_sme_participants 		= share_SME 	 if D_auction == 1 & D_product == 1
			gen share_S4_sme_win 				= SME 			 if D_auction == 1 & D_product == 1
			gen avg_S4_decision_time 			= decision_time  if D_auction == 1 & D_product == 1
			gen avg_S4_value_item				= item_value 	 if D_auction == 1 & D_product == 1
			gen avg_S4_value_covid_high			= item_value 	 if D_auction == 1 & D_product == 1 & Covid_item_level==3
			gen avg_S4_value_covid_med			= item_value 	 if D_auction == 1 & D_product == 1 & Covid_item_level==2
			gen avg_S4_value_covid_low			= item_value 	 if D_auction == 1 & D_product == 1 & Covid_item_level==1
			gen avg_S4_value_covid_none			= item_value 	 if D_auction == 1 & D_product == 1 & Covid_item_level==0

		* List of measures - Fase processo
			bys tender_id: gen byte N_batches  = _n==1
			bys ug_id    : gen byte N_ug      = _n==1 
						   gen byte N_lots	   =  1
						
		* year month
			gen year  = year(dofm(year_month))
			gen month = month(dofm(year_month))
			gen year_semester = yh(year ,ceil(month/6)) 
				format %th year_semester	
	}
	.
 
	* 02: Labeling it
	{
	    * Labeling data
		{
			* Geral variables ALL
			label var year_semester 		"Year/semester of opeing tender process"
			label var N_lots 				"N items"
			label var N_ug 					"N lots"
			label var N_batches		 		"N batches" 
			
			foreach var of varlist avg_S*_participants {
				label var `var' "E[N SME participants by item/tender]"
			}
			.
			
			foreach var of varlist avg_S*_win_gap {
				label var `var' "E[Number of months between last win of winner firm]"
			}
			.
			
			foreach var of varlist avg_S*_decision_time*  {
				label var `var' "E[Decision time]"
			}
			.
			
			foreach var of varlist avg_S*_unit_price*  {
				label var `var' "E[unit price]"
			}
			.
			
			foreach var of varlist avg_S*_value_item*  {
				label var `var' "E[volume item]"
			}
			.
			
			foreach var of varlist share_S*_sme_win  {
				label var `var' "Share SME winning"
			}
			.		

			foreach var of varlist share_S*_material  {
				label var `var' "Share materials"
			}
			.				
			

			foreach var of varlist share_S*_auction  {
				label var `var' "Share auction method"
			}
			.	
			
			foreach var of varlist N_S*_new_winnes  {
				label var `var' "N New winners"
			}
			.
			
			foreach var of varlist avg_S*value_covid_high  {
				label var `var' "E[volume items High Covid items]"
			}
			.
			
			foreach var of varlist avg_S*_value_covid_med { 
				label var `var' "E[volume items Medium Covid items]"
			}
			.
			
			foreach var of varlist avg_S*_value_covid_low  {
				label var `var' "E[volume items Low Covid items]"
			}
			.
			
			foreach var of varlist avg_S*_value_covid_none  {
				label var `var' "E[volume items no Covid items]"
			}
			. 
			
			foreach var of varlist share_S*_sme_participants  {
				label var `var' "Share SME participants"
			}
			.
 
			foreach var of varlist share_S*_location_munic {
				label var `var' "Share same municipality"
			}
			.
			
			foreach var of varlist share_S*_location_state {
				label var `var' "Share same state"
			}
			.
			
			foreach var of varlist avg_S*_unit_price_filter  {
				label var `var' "E[unit price selected products|selected products]"
			}
			.
			
			foreach var of varlist avg_S*_log_unit_price_filter  {
				label var `var' "E[log(unit price)|selected products]"
			}
			.	

		}
		.
	}
	.
	
	* 03: Labeling ordering ans saving data
	{	 
		* Label data
		label data "Indexes calculated by year/semester using lot/item data"
		
		* Saving
		compress
		save "${path_project}/1_data/04-index_data/P07_data_to_create_indexes", replace
	}
	.
	
	* 04: Collapsing measures by semesters
	{ 
		* Reading data
		use "${path_project}/1_data/04-index_data/P07_data_to_create_indexes",clear
			
		* Collapsing by time measure (month)
		gcollapse 	(sum)  N_S?_*  N_batches N_ug N_lots ///
					(mean) avg_S?_* share_S?_*, by(year year_semester ) labelformat(#sourcelabel#) fast
					
		* saving
		compress
		save "${path_project}/1_data/04-index_data/P07-semester-index.dta",replace
	}
	.	
	
	* 05: Collapsing measures by semesters
	{ 
		* Reading data
		use "${path_project}/1_data/04-index_data/P07_data_to_create_indexes",clear
 		
		* Collapsing by time measure (month)
		gcollapse 	(sum) N_S?_*  N_batches N_ug N_lots ///
					(mean) avg_S?_* share_S?_*, by(year year_semester Covid_item_level) labelformat(#sourcelabel#) fast
					
		* saving
		compress
		save "${path_project}/1_data/04-index_data/P07-semester-covid-level-index.dta",replace
	}
	.	
}
.

* 2: Competition indexes
{ 
	* 01: Index 5 digits
	{ 
		* reading
		use year_month Covid_item_level type_item item_5d_code item_2d_code item_value ///
			using "${path_project}/1_data/03-final/05-Lot_item_data",clear

		* year data
		gen year = year(dofm(year_month))

		* Total
		gegen total_volume_5d = sum(item_value)  , by(year  type_item item_5d_code)
		
		* 5 digits
		gen share_5d 			=  item_value/total_volume_5d
		gen shannon_entropy_5d  = -share_5d*ln(share_5d)	
		gen HHI_5d 				=  share_5d*share_5d	
		
		* Collapsing 
		gcollapse (sum) shannon_entropy_5d  HHI_5d,	///
				  freq(N_lots ) 				///
				  by(year Covid_item_level type_item item_5d_code) 
				  
		* Saving 
		compress
		save "${path_project}/4_outputs/1-data_temp/P07_hhi_5d.dta", replace
	}
	.
	
	* 02: Index 2 digits
	{ 
		* reading
		use year_month Covid_group_level type_item item_5d_code item_2d_code item_value ///
			using "${path_project}/1_data/03-final/05-Lot_item_data",clear

		* year data
		gen year = year(dofm(year_month))

		* 2 digits
		gegen total_volume_2d = sum(item_value)  , by(year type_item item_2d_code)
		gen share_2d 			=  item_value/total_volume_2d
		gen shannon_entropy_2d  = -share_2d*ln(share_2d)	
		gen HHI_2d 				=  share_2d*share_2d	
		
		* Collapsing 
		gcollapse (sum) shannon_entropy_2d  HHI_2d,	///
				  freq(N_lots ) 				///
				  by(year Covid_group_level type_item item_2d_code) 	 labelformat(#sourcelabel#)
				  
		* Saving 
		compress
		save "${path_project}/4_outputs/1-data_temp/P07_hhi_2d.dta", replace
	}
	.
	
	* 03: Agregating to year level
	{
		* Reading data hhi 5 digits
		{
			* Using
			use "${path_project}/4_outputs/1-data_temp/P07_hhi_5d.dta",clear
			
			* Collapsing 
			gcollapse (mean) shannon_entropy_5d  HHI_5d, by(year)
			
			* Temping file
			tempfile hhi_5d
			save `hhi_5d'
		}
		.
		
		* Reading data hhi 5 digits
		{
			* Using
			use "${path_project}/4_outputs/1-data_temp/P07_hhi_2d.dta",clear
			
			* Collapsing 
			gcollapse (mean) shannon_entropy_2d  HHI_2d, by(year) labelformat(#sourcelabel#)
			
 			append using `hhi_5d'
		}
		.
		
		* labeling data
		label var HHI_2d "E[HHI: 2 digits item yearly]"
		label var HHI_5d "E[HHI: 5 digits item yearly]"
		label var shannon_entropy_2d "E[Shannon entropy: 5 digits item yearly]"
		label var shannon_entropy_5d "E[Shannon entropy: 5 digits item yearly]"
		
		* saving data
		save "${path_project}/1_data/P07_HHI_index.dta", replace
	}
	.
	
	* 04: Covid level-index
	{
		* Using
		use "${path_project}/4_outputs/1-data_temp/P07_hhi_5d.dta",clear

		* Collapsing 
		gcollapse (mean) shannon_entropy_5d  HHI_5d, by(year Covid_item_level ) labelformat(#sourcelabel#)
		
		* labeling data
 		label var HHI_5d "E[HHI: 5 digits item yearly]"
 		label var shannon_entropy_5d "E[Shannon entropy: 5 digits item yearly]"
		
		* saving
		compress
		save "${path_project}/1_data/04-index_data/P07-year-covid-level-index.dta",replace
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
		
 		
		cap drop start_covid*
		gen covid_product = (win1+win2+win3) >=1
		gen start_covid_product_1     = (covid_product>0) &  L1.covid_product == 0 
		gen start_covid_product_2     = (covid_product>0) &  L1.covid_product == . 
		gen start_covid_product_3     = (covid_product>0) & (L1.covid_product != . & L1.covid_product > 0)
		
		gcollapse (sum) covid_product (mean) start_covid_product_*, by(year) freq(N)
		order year N covid_product start_covid_product_*
		
		label var year					"year tender"
		label var covid_product  		"Number of covid item sellers"
		label var N						"Number of unique sellers"
		label var start_covid_product_1 "Firm didn't sell covid item"
		label var start_covid_product_2 "Firm didn't win tender"
		label var start_covid_product_3 "Firm sold covid item"
		
		keep if inrange(year,2019,2020)
		
		format %10.3fc start_covid_*
		
		
		global vars 	N	covid_product	start_covid_product_1	start_covid_product_2	start_covid_product_3
		
 		foreach  var of varlist start* {
			replace `var' = `var'*100
		}
		.
		 	
		eststo drop *
		eststo stats_2019: quietly estpost summarize $vars  if year == 2019 ,d 
		eststo stats_2020: quietly estpost summarize $vars  if year == 2020 ,d  

		esttab stats_2019 stats_2020  using 	///
			"${overleaf}/01_tables/P2-Firms_starts_covid.tex",	/// 
			cells("mean(fmt(%12.4gc))") mtitles("2019" "2020") nonum ///
			label replace f booktabs brackets noobs gap ///
			starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
 
}
 
 
* 4: Firms that starts to sell covid items
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
	gen covid_product = ( win3) >=1
	gen start_covid_product_1     = (covid_product>0) &  L1.covid_product == 0 
	gen start_covid_product_2     = (covid_product>0) &  L1.covid_product == . 
	gen start_covid_product_3     = (covid_product>0) & (L1.covid_product != . & L1.covid_product > 0)

	gcollapse (sum) covid_product (mean) start_covid_product_*, by(year) freq(N)
	order year N covid_product start_covid_product_*

	label var year					"year tender"
	label var covid_product  		"Number of High covid item sellers"
	label var N						"Number of unique sellers"
	label var start_covid_product_1 "Firm didn't sell covid item"
	label var start_covid_product_2 "Firm didn't win tender"
	label var start_covid_product_3 "Firm sold covid item"

	keep if inrange(year,2019,2020)

	format %10.3fc start_covid_*


	global vars 	N	covid_product	start_covid_product_1	start_covid_product_2	start_covid_product_3

	foreach  var of varlist start* {
		replace `var' = `var'*100
	}
	.
		
	eststo drop *
	eststo stats_2019: quietly estpost summarize $vars  if year == 2019 ,d 
	eststo stats_2020: quietly estpost summarize $vars  if year == 2020 ,d  


	esttab stats_2019 stats_2020  using 	///
		"${overleaf}/01_tables/P2-Firms_starts_Highcovid.tex",	/// 
		cells("mean(fmt(%12.2gc))") mtitles("2019" "2020" "2021" "2022") nonum ///
		label replace f booktabs brackets noobs gap ///
		starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
 
}