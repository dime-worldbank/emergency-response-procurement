* Made by Leandro Veloso
* Main: Winners level: item level restrict to items

* 1: Preparing service list to merge
{
	use "${path_KCP_BR}/1-data/2-imported/COMPRAS-list-02-catalog_service",clear

	keep  code_item service_group service_class   
	order code_item service_group service_class   
	
	format %30.0g service_*
	
	save "${path_project}/4_outputs/1-data_temp/service_to_merge",replace
}
.
	
* 2: Preparing product list to merge
{
	use  "${path_KCP_BR}/1-data/2-imported/COMPRAS-list-01-catalog_product",clear
	 
	keep  code_item product_group product_pdm product_class 
	order code_item product_group product_pdm product_class 
	
	format %30.0g product_*
	
	save "${path_project}/4_outputs/1-data_temp/product_to_merge",replace
}
. 

* 3: Data winner:
{
	use "${path_project}/1_data/03-participants_data" if D_winner==1,clear
	
	gduplicates drop id_item, force 
	 
	tempfile winners
	save "${path_project}/4_outputs/1-data_temp/winners",replace
}
.

* 4: Joing data
{ 
	* Reading
	local short_list_var id_item code_item type_product qtd_item item_measure value_item_estimated
	use `short_list_var' using "${path_KCP_BR}/1-data\2-imported\02-item_data/itens_bidding.dta",clear

	* Appending 
	foreach year of numlist 2014/2022 {
		append using "${path_KCP_BR}/1-data\2-imported\02-item_data/COMPRAS-02-itens-`year'.dta" , keep(id_item code_item type_product qtd_item item_measure value_item_estimated)
	}
	.

	* Duplicates drop
	gduplicates drop 

	* Duplicates drop 
	gduplicates tag id_item, gen(tag)	

	* Sorting
	gsort id_item -value_item_estimated
	by id_item: keep if _n==1	

	tempfile data_to_merge
	save `data_to_merge'

	* 
	use id_item qtd_item	value_item	unit_price  ///
		using "${path_KCP_BR}/1-data\2-imported\Portal-02-item-panel",clear

	rename qtd_item qtd_item_est

	gduplicates drop id_item, force

	merge 1:1 id_item using `data_to_merge'

	replace value_item_estimated = 	value_item if value_item_estimated==.
	drop value_item

	replace qtd_item 	         = 	qtd_item_est if qtd_item==.
	drop qtd_item_est
	
	* checking		
	replace code_item= ustrregexra(code_item,"[^0-9]","")
	
	* Preparing to merge
	replace code_item = "p" +(6-length(code_item))*"0" + code_item if type_product == "material":lab_type_product 
	replace code_item = "s" +(6-length(code_item))*"0" + code_item if type_product == "service":lab_type_product  
	
	* includin item code
	merge m:1 code_item using "${path_project}/4_outputs/1-data_temp/product_to_merge", keep(1 3) gen(merge_prod)
	
	merge m:1 code_item using "${path_project}/4_outputs/1-data_temp/service_to_merge", keep(1 3) gen(merge_serv)

	gen byte D_prod_serv = merge_prod ==3 | merge_serv ==3
	
	gen year = real(substr(id_item, 14,4))
	
	keep if inrange(year, 2013,2022)
	
	tab year D_prod_serv
	
	* keeping interesting sample
	keep if D_prod_serv==1
	drop D_prod_serv merge_prod merge_serv _merge tag
	
	* modality 
	gen modality = substr(id_item,7,2)
	
	sort year id_item
	order id_item year code_item modality type_product value_item_estimated qtd_item item_measure  product_group service_group  
	
	merge 1:1 id_item using "${path_project}/4_outputs/1-data_temp/winners"
	rename D_winner D_winner_exist
	replace D_winner_exist= 0 if D_winner_exist==.
	tab year _merge
	drop _merge
	
	label data "Data to calculate competition"		
	save "${path_project}/1_data/04-winners_data",replace
}
. 



 
