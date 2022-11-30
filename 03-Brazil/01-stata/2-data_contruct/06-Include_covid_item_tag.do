* Made by Leandro Veloso
* Main: Winners level: item level restrict to items

* 1: Participants data
{
	use  "${path_project}/1_data/03-participants_data",clear

	* Keeping
	keep if type_item !=""
	replace type_item = "Product" if type_item == "prod"
	replace type_item = "Service" if type_item == "serv"

	* Including 
	merge m:1 type_item item_5d_code using "${path_project}/1_data/03-covid_item-item_level", ///
		keepusing(type_item item_5d_code)
		
	* Ordering 
	sort  year_month id_ug id_item
	order year_month id_item id_bidder type_bidder D_winner  ///
		  type_item item_5d_code item_2d_code D_covid Covid_group_level Covid_item_level 
		
	* Saving
	compress
	save  "${path_project}/1_data/03-participants_data",replace
}


{
	use "${path_project}/1_data/04-winners_data",clear
 
	merge m:1 type_item item_5d_code using  "${path_project}/1_data/03-covid_item-item_level", ///
		keepusing(type_item item_2d_code Covid_item_level item_5d_name)
	
	
	*  
	save "${path_project}/1_data/04-winners_data-v2",clear	
}
.


