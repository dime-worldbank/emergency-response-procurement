* Made by Leandro Veloso
* Main: Create data in the index level.
  
* 1: Lot data:
{
	* 01: Reading data_temp/P07_hhi_2d
	{
		* Reading data
		use "${path_project}/1_data/05-Lot_item_data",clear
		
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
			value_item				/// item value_item
			Covid_item_level		///  Covid item
			id_bidding id_ug
			
		* Sample 1: ALL
			gen share_S1_sme_win 				= SME 
			gen share_S1_material				= D_product
			gen share_S1_auction				= D_auction
			gen N_S1_new_winnes 				= D_new_winner
			gen avg_S1_win_gap 					= months_since
			gen avg_S1_decision_time_trim 		= decision_time_trim
			gen avg_S1_unit_price_non_restrict	= unit_price
			gen avg_S1_value_item				= value_item
			gen avg_S1_participants				= N_participants
			gen share_S1_sme_participants 		= share_SME  

		
		* Sample 2: Only Auction 
			gen N_S2_new_winnes 				= D_new_winner	 if D_auction == 1
			gen avg_S2_participants				= N_participants if D_auction == 1
			gen share_S2_sme_participants 		= share_SME 	 if D_auction == 1
			gen avg_S2_decision_time 			= decision_time  if D_auction == 1
			gen avg_S2_value_item				= value_item 	 if D_auction == 1

		* Sample 3: ALL & Only material
			gen avg_S3_participants				= N_participants if D_product == 1
			gen share_S3_sme_participants 		= share_SME 	 if D_product == 1
			gen share_S3_sme_win 				= SME 			 if D_product == 1
			gen avg_S3_decision_time 			= decision_time  if D_product == 1
			gen avg_S3_value_item				= value_item 	 if D_product == 1
			gen avg_S3_value_covid_high			= value_item 	 if D_product == 1 & Covid_item_level==3
			gen avg_S3_value_covid_med			= value_item 	 if D_product == 1 & Covid_item_level==2
			gen avg_S3_value_covid_low			= value_item 	 if D_product == 1 & Covid_item_level==1
			gen avg_S3_value_covid_none			= value_item 	 if D_product == 1 & Covid_item_level==0

		* Sample 4: Auction & Only material	
			gen avg_S4_participants				= N_participants if D_auction == 1 & D_product == 1
			gen share_S4_sme_participants 		= share_SME 	 if D_auction == 1 & D_product == 1
			gen share_S4_sme_win 				= SME 			 if D_auction == 1 & D_product == 1
			gen avg_S4_decision_time 			= decision_time  if D_auction == 1 & D_product == 1
			gen avg_S4_value_item				= value_item 	 if D_auction == 1 & D_product == 1
			gen avg_S4_value_covid_high			= value_item 	 if D_auction == 1 & D_product == 1 & Covid_item_level==3
			gen avg_S4_value_covid_med			= value_item 	 if D_auction == 1 & D_product == 1 & Covid_item_level==2
			gen avg_S4_value_covid_low			= value_item 	 if D_auction == 1 & D_product == 1 & Covid_item_level==1
			gen avg_S4_value_covid_none			= value_item 	 if D_auction == 1 & D_product == 1 & Covid_item_level==0

		* List of measures - Fase processo
 		bys id_bidding: gen byte N_batches = _n==1
		bys id_ug     : gen byte N_ug      = _n==1 
	}
	.
 
	* 02: Collapsing measures by semesters
	{ 
		* year month
		gen year = year(dofm(year_month))
		gen year_semester = yh(year ,ceil(month(dofm(7))/6)) 
			format %th year_semester	
		
		* Collapsing by time measure (month)
		gcollapse 	(sum) N_S?_*  N_batches N_ug ///
					(mean) avg_S?_* share_S?_*, by(year year_semester ) freq(N_lots)	
	}
	.	
	
	* 03: Labeling ordering ans saving data
	{
		* Labeling data
		{
			* Geral variables ALL
			label var year_semester 		"Year/semester of opeing tender process"
			label var N_lots 				"\# items"
			label var N_ug 					"N lots"
			label var N_batches		 		"N batches" 
			
			foreach var of varlist avg_S*_participants {
				label var `var' "Avg \# SME participants by item/tender"
			}
			.
			
			foreach var of varlist avg_S*_win_gap {
				label var `var' "Avg number of months between last win of winner firm"
			}
			.
			
			foreach var of varlist avg_S*_decision_time*  {
				label var `var' "Avg Decision time"
			}
			.
			
			foreach var of varlist avg_S*_unit_price*  {
				label var `var' "Avg unit price"
			}
			.
			
			foreach var of varlist avg_S*_value_item*  {
				label var `var' "Avg volume items"
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
				label var `var' "\# New winners"
			}
			.
			
			foreach var of varlist avg_S*value_covid_high  {
				label var `var' "Avg volume items High Covid items"
			}
			.
			
			foreach var of varlist avg_S*_value_covid_med { 
				label var `var' "Avg volume items Medium Covid items"
			}
			.
			
			foreach var of varlist avg_S*_value_covid_low  {
				label var `var' "Avg volume items Low Covid items"
			}
			.
			
			foreach var of varlist avg_S*_value_covid_none  {
				label var `var' "Avg volume items no Covid items"
			}
			. 
			
			foreach var of varlist share_S*_sme_participants  {
				label var `var' "Share SME participants"
			}
			.			
		}
		.
		 
		* Label data
		label data "Indexes calculated by year/semester using lot/item data"
		
		* Saving
		compress
		save "${path_project}/1_data/01-index_data/P07_index_win", replace
	}
	.
}
.

* 2: Competition indexes
{ 
	* 01: Index 5 digits
	{ 
		* reading
		use year_month Covid_item_level type_item item_5d_code item_2d_code value_item ///
			using "${path_project}/1_data/05-Lot_item_data",clear

		* year data
		gen year = year(dofm(year_month))

		* Total
		gegen total_volume_5d = sum(value_item)  , by(year type_item item_5d_code)
		
		* 5 digits
		gen share_5d 			=  value_item/total_volume_5d
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
		use year_month Covid_group_level type_item item_5d_code item_2d_code value_item ///
			using "${path_project}/1_data/05-Lot_item_data",clear

		* year data
		gen year = year(dofm(year_month))

		* 2 digits
		gegen total_volume_2d = sum(value_item)  , by(year type_item item_2d_code)
		gen share_2d 			=  value_item/total_volume_2d
		gen shannon_entropy_2d  = -share_2d*ln(share_2d)	
		gen HHI_2d 				=  share_2d*share_2d	
		
		* Collapsing 
		gcollapse (sum) shannon_entropy_2d  HHI_2d,	///
				  freq(N_lots ) 				///
				  by(year Covid_group_level type_item item_2d_code) 	
				  
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
			gcollapse (mean) shannon_entropy_2d  HHI_2d, by(year)
			
 			append using `hhi_5d'
		}
		.
		
		* labeling data
		label var HHI_2d "E[HHI: 2 digits item yearly]"
		label var HHI_5d "E[HHI: 5 digits item yearly]"
		label var shannon_entropy_2d "E[Shannon entropy: 5 digits item yearly]"
		label var shannon_entropy_5d "E[Shannon entropy: 5 5 digits item yearly]"
		
		* saving data
		save "${path_project}/1_data/P07_HHI_index.dta", replace
	}
	.
}
.


 