* Made by Leandro Veloso
* Main: Lot tender level data: The 
 
* 1: Join data variables to the lot data
{
	* 1: Reading lot/Item data 
		use "${path_KCP_BR}/1-data\2-imported\Portal-02-item-panel",clear

		* Removing duplications
		gduplicates drop id_item, force 
	
	* 2: Getting code classification
		merge 1:1 id_item using "${path_KCP_BR}/1-data\2-imported\Portal-02-item-code", keep(3)
		gen byte D_item_code_nomiss = _merge==3
		drop _merge

	* 3: Getting infomation from tender data
		merge m:1 id_bidding using "${path_project}/1_data/01-tender_data", ///
			keepusing(methods D_covid D_law_926_2020 id_ug id_top_organ id_organ uf decision_time  decision_time_trim date_result date_open) nogen keep(3)
	
	* 4: Firms caracteristics
		merge m:1 id_bidder	 using "${path_project}/1_data/02-firm_caracteristcs", keep(1 3) ///
			keepusing(id_bidder cnae20 great_sectors SME porte_empresa  uf_estab date_simples_end)
		drop _merge
		
	* 5: Including covid item classification
		rename type_item type_item_aux

		keep if type_item_aux !=.
		generate type_item = "Product" if type_item_aux == 1
		replace  type_item = "Service" if type_item_aux == 2

		* Covid item
		merge m:1 type_item item_5d_code using "${path_project}/1_data/03-covid_item-item_level", ///
			keepusing(type_item item_5d_code  Covid_group_level Covid_item_level) nogen keep(3)
}
.

* 2: Creating extra variables
{
	* Merging
	gen year_id_tender = real(substr(id_item, 14,4))

	* Restricting to the period
	keep if inrange(year_id_tender, 2013,2022)
	tab year_id_tender D_item_code_nomiss
	drop D_item_code_nomiss year_id_tender

	* Quarter
	gen year_quarter = yq(year(dofm(year_month)),quarter(dofm(year_month)))
	format %tq year_quarter
	
	* Ordering
	order year_month year_quarter id_ug id_organ id_top_organ id_bidder  type_item purchase_method value_item qtd_item unit_price 
	sort year_month  id_ug
	
	* Creating winner variables
	gen D_winner =1

	* Ordering 
	sort  year_month id_ug id_item
	order year_month id_item id_bidder type_bidder  D_winner  ///
	  type_item item_5d_code item_5d_name item_2d_code item_2d_name ///
	  D_covid Covid_group_level Covid_item_level SME great_sectors uf_estab
	 
	cap  drop item_1d* item_3d* item_4d* 

	* Lot_item_data
	label data "Lot/item data"		
	compress
	save "${path_project}/4_outputs/1-data_temp/05-Lot_item_data-auxiliary data",replace	
}
.

* 3: Calculating New winner
{  
	use id_bidder year_month D_winner using "${path_KCP_BR}/1-data\2-imported/Portal-03-participants_level-panel" if D_winner==1 ,clear
	keep id_bidder year_month 
	duplicates drop id_bidder year_month , force

	bys id_bidder (year_month): gen months_since_last_win = year_month - year_month[_n-1]
	bys id_bidder (year_month): replace months_since_last_win = year_month - ym(2013,1) if months_since_last_win==.
 
	* Keeping data
	keep id_bidder year_month months_since_last_win
	compress
	save "${path_project}/4_outputs/1-data_temp/P05-New_winner",replace
}
.

* 4: Participants by lot/tender
{
	use id_item SME using "${path_project}/1_data/03-participants_data" ,clear
	
	* Counting participants
	gen N_participants = 1
	gcollapse (sum) N_participants N_SME_participants = SME, by(id_item)
 	gen share_SME = N_SME_participants/ N_participants
	
	compress
	save "${path_project}/4_outputs/1-data_temp/P05-N_participants",replace
}
 
* 5: Joing variables to the data
{ 
	* Reading data
	use "${path_project}/4_outputs/1-data_temp/05-Lot_item_data-auxiliary data",clear
	
	* Participants information
	merge 1:1 id_item using "${path_project}/4_outputs/1-data_temp/P05-N_participants", keep(3) nogen
	
	* New winners
	merge m:1 id_bidder year_month  using "${path_project}/4_outputs/1-data_temp/P05-New_winner", keep(3) nogen
	gen byte D_new_winner =  months_since_last_win>=24 & D_winner==1
	
	* Creating pre/post
	gen byte D_post = year_quarter>=yq(2020,1)

	gen D_product 		= type_item== "Product"
	gen D_auction		= methods  ==1
	
	*labeling 
	{
		
	}
		
	compress
	save "${path_project}/1_data/05-Lot_item_data",replace
}
.



 	
