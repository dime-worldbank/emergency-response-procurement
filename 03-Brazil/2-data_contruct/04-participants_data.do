* Made by Leandro Veloso
* Main: Participants data
* time to run: About 20 minutes

* 01: Reading participants data
{
	* reading participants data
	use "${path_project}/1_data/01-import-data/Portal-03-participants_level-panel",clear
	
	* keep if runiform()<=0.01
	
	* Getting information from tender data
	merge m:1 tender_id using "${path_project}/1_data/03-final/01-tender_data", ///
	 keepusing(methods D_covid ug_id year )  keep(3) nogen
 		
	* Getting code classification
	merge m:1 item_id using "${path_project}/1_data/01-import-data/Portal-02-item-panel", ///
		keepusing(item_id	type_item	item_5d_code item_value ) keep(3) nogen

	* Firms caracteristics
	{
		merge m:1 bidder_id	 using "${path_project}/1_data/03-final/03-Firm_procurement_constant_characteristics", keep(1 3) ///
			keepusing(bidder_id rais_great_sectors rais_date_simples_start rais_date_simples_end )
		drop _merge	
		
		rename rais_* *
		
		* Years 
		gen year_simples_start = year(date_simples_start)
		gen year_simples_end   = year(date_simples_end  ) 

		* Date 
		cap drop date_simples_start date_simples_end
		gen byte SME  = inrange(year, year_simples_start, year_simples_end) & inrange(year_simples_start,2005,2022)  
		cap drop year_simples_start year_simples_end 
	}
	.		
	 
	* merge covid item
	merge m:1 type_item item_5d_code using "${path_project}/1_data/03-final/02-covid_item-item_level", ///
		keepusing(type_item item_2d_code item_5d_code  Covid_group_level Covid_item_level) nogen keep(3)		

	* Ordering
	keep  year_month item_id   methods  ug_id item_value  bidder_id great_sectors SME D_winner type_item item_2d_code item_5d_code D_covid Covid_group_level Covid_item_level 	
	order year_month item_id   methods  ug_id item_value  bidder_id great_sectors SME D_winner type_item item_2d_code item_5d_code D_covid Covid_group_level Covid_item_level
	sort year_month  ug_id  bidder_id

	* Saving participants data
	compress
	save "${path_project}/1_data/03-final/04-participants_data", replace
	
	* Creating 5% sample to run fast
	gen random = runiform() 
	bys  bidder_id: keep if random[1]<=0.05
	drop random
	save  "${path_project}/1_data/02-sample_run_fast/04-participants_data",replace
}
.
