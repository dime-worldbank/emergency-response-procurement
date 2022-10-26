* Made by Leandro Veloso
* Main: Winners level: item level restrict to items
 

* 2: Data winner:
{
	use "${path_project}/1_data/03-participants_data" if D_winner==1,clear
	
	gduplicates drop id_item, force 
	 
	tempfile winners
	save "${path_project}/4_outputs/1-data_temp/winners",replace
}
.

* 4: Joing data
{ 
	* Reading Item data
	local list_var_item id_item purchase_method year_month type_bidder qtd_item	value_item	unit_price  
	use `list_var_item'  ///
		using "${path_KCP_BR}/1-data\2-imported\Portal-02-item-panel",clear
		
	* Ordering variables and sorting
	order `list_var_item'
	sort id_item  purchase_method year_month
	
	* Removing few duplicates
	gduplicates drop id_item, force 
	
	* Getting code classification
	merge 1:1 id_item using "${path_KCP_BR}/1-data\2-imported\Portal-02-item-code"
	gen byte D_item_code_nomiss = _merge==3
	drop _merge
	
	* Getting tagging winners
	merge 1:1 id_item using "${path_project}/4_outputs/1-data_temp/winners", keep(3) nogen
	 
	* Merging
	gen year_file      = year(dofm(year_month))
	gen year_id_tender = real(substr(id_item, 14,4))
	
	* Restricting to the period
	keep if inrange(year_id_tender, 2013,2022)
	tab year D_item_code_nomiss
	
	* keeping interesting sample
	tab year_file type_item,m
	* keep if D_prod_serv==1
	* drop D_prod_serv merge_prod merge_serv _merge tag
	
	* modality 
	gen modality = substr(id_item,7,2)
	
	order year_month id_ug id_organ id_top_organ id_bidder  type_item purchase_method value_item qtd_item unit_price 
	sort year_month  id_ug
 	
	* Winenr
	label data "Data to calculate Winners"		
	save "${path_project}/1_data/04-winners_data",replace
}
. 



 
