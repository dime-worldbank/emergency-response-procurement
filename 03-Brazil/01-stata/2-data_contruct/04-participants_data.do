* Made by Leandro Veloso
* Main: Participants data

* 01: Reading participants data
{
	* reading participants data
	use "${path_KCP_BR}/1-data\2-imported/Portal-03-participants_level-panel",clear

	gen id_bidding = substr(id_item ,1,17)

	merge m:1 id_bidding using "${path_project}/1_data/01-tender_data", ///
	 keepusing(methods D_covid id_ug )  keep(3) nogen
 		
	* Getting code classification
	merge m:1 id_item using "${path_KCP_BR}/1-data\2-imported\Portal-02-item-code", ///
		keepusing(id_item	type_item	item_5d_code	item_4d_code item_2d_code) keep(3) nogen

	* Getting estimated volume of item 
	merge  m:1 id_item using  "${path_KCP_BR}/1-data/2-imported/Portal-02-item-panel", ///
		keepusing(id_item value_item)  keep(3) nogen		
	
	* 4: Firms caracteristics
		merge m:1 id_bidder	 using "${path_project}/1_data/02-firm_caracteristcs", keep(1 3) ///
			keepusing(id_bidder great_sectors SME)
		drop _merge	
	
	* Keeping
	rename type_item type_item_aux
	
	keep if type_item_aux !=.
	generate type_item = "Product" if type_item_aux == 1
	replace  type_item = "Service" if type_item_aux == 2

	* Including 
	merge m:1 type_item item_5d_code using "${path_project}/1_data/03-covid_item-item_level", ///
		keepusing(type_item item_5d_code  Covid_group_level Covid_item_level) nogen keep(3)		
	
	* Ordering
	keep  year_month id_item   methods id_ug value_item id_bidder great_sectors SME D_winner type_item item_2d_code item_5d_code D_covid Covid_group_level Covid_item_level 	
	order year_month id_item   methods id_ug value_item id_bidder great_sectors SME D_winner type_item item_2d_code item_5d_code D_covid Covid_group_level Covid_item_level
	sort year_month id_ug id_bidder

	* Saving participants data
	compress
	save "${path_project}/1_data/03-participants_data", replace
	
	* Creating 5% sample to run fast
	gen random = runiform() 
	bys id_bidder: keep if random[1]<=0.05
	drop random
	save  "${path_project}/1_data/01-sample_run_fast/03-participants_data",replace
}
.
