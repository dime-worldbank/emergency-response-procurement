* Made by Leandro Veloso
* Main: Winners level: item level restrict to items

* 1: Participants data
{
	use  "${path_project}/4_outputs/1-data_temp/03-participants_data",clear
	
	* Restricting to period
	keep if year_month >=ym(2015,1)
	
	* Keeping
	rename type_item type_item_aux
	
	keep if type_item_aux !=.
	generate type_item = "Product" if type_item_aux == 1
	replace  type_item = "Service" if type_item_aux == 2

	* Including 
	merge m:1 type_item item_5d_code using "${path_project}/1_data/03-covid_item-item_level", ///
		keepusing(type_item item_5d_code  Covid_group_level Covid_item_level) nogen keep(3)
		
	* Ordering 
	sort  year_month id_ug id_item
	order year_month id_item id_bidder type_bidder D_winner  ///
		  type_item item_5d_code item_2d_code D_covid Covid_group_level Covid_item_level 
	
	* Saving
	compress
	save  "${path_project}/1_data/04-participants_data",replace
	
	* Creating 5% sample to run fast
	gen random = runiform() 
	bys id_bidder: keep if random[1]<=0.05
	
	save  "${path_project}/1_data/01-sample_run_fast/04-participants_data",replace
}
.

* 2: Participants data
{
	use "${path_project}/4_outputs/1-data_temp/04-winners_data",clear
	
	* Restricting to period
	keep if year_month >=ym(2016,1)
	
	drop item_3* item_4* item_1* 
 	cap drop  year_file year_id_tender modality  
	
	* Keeping
	keep if type_item !=""
	replace type_item = "Product" if type_item == "prod"
	replace type_item = "Service" if type_item == "serv"

	* Including 
	merge m:1 type_item item_5d_code using "${path_project}/1_data/03-covid_item-item_level", ///
		keepusing(type_item item_5d_code  Covid_group_level Covid_item_level) nogen
		
	* Ordering 
	sort  year_month id_ug id_item
	order year_month id_item id_bidder type_bidder  D_winner  ///
		  type_item item_5d_code item_5d_name item_2d_code item_2d_name ///
		  D_covid Covid_group_level Covid_item_level SME great_sectors uf_estab
		
	* saving
	compress
	save "${path_project}/1_data/05-winners_data",replace	
}
.
