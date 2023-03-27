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
			keepusing(methods D_covid D_law_926_2020 id_ug id_top_organ id_organ uf decision_time  decision_time_trim date_result date_open  ug_state_code ug_munic_code ) nogen keep(3)
	
	* 4: Firms caracteristics
		merge m:1 id_bidder	 using "${path_project}/1_data/02-firm_caracteristcs", keep(1 3) ///
			keepusing(id_bidder cnae20 great_sectors SME porte_empresa  uf_estab munic_estab date_simples_end)
		drop _merge
		
	* 5: Including covid item classification
		rename type_item type_item_aux

		keep if type_item_aux !=.
		generate type_item = "Product" if type_item_aux == 1
		replace  type_item = "Service" if type_item_aux == 2

		* Covid item
		merge m:1 type_item item_5d_code using "${path_project}/1_data/03-covid_item-item_level", ///
			keepusing(type_item item_5d_code  Covid_group_level Covid_item_level) nogen keep(3)
			
	* 6: Include names in the data
		drop item_*_name*
		drop item_1d_code item_3d_code item_4d_code	

		* Type item
		drop type_item
		rename type_item_aux  type_item 
		
		* Merging data
		merge m:1 type_item item_5d_code using ///
			"${procurement_data}/03-extra_sources/04-clean/01-catalog-federal-procurement.dta", ///
			keepusing(type_item item_5d_code item_2d_name_eng item_5d_name_eng ) nogen keep(3)
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
		label var share_SME "Proportion of SME participants in the lot/tender"
	
	compress
	save "${path_project}/4_outputs/1-data_temp/P05-N_participants",replace
}
.
 
* 5: Joing variables to the data
{ 
	* Reading data
	use "${path_project}/4_outputs/1-data_temp/05-Lot_item_data-auxiliary data",clear
	
	* Participants information
	merge 1:1 id_item using "${path_project}/4_outputs/1-data_temp/P05-N_participants", keep(3) nogen
	
	* New winners
	merge m:1 id_bidder year_month  using "${path_project}/4_outputs/1-data_temp/P05-New_winner", keep(3) nogen
	gen byte D_new_winner =  months_since_last_win>=24 & D_winner==1
		label var D_new_winner "Dummy if the firm didn't win a lot more than 24 months'"
	
	* Creating pre/post
	gen byte D_post = year_quarter>=yq(2020,1)

	gen D_product 		= type_item== 1
		label var D_product "Dummy if the item is a product"
		
	gen D_auction		= methods  ==1
		label var D_auction "Dummy if the purchase method is auction"
	
	* Location dummy
	gen byte D_same_munic_win = munic_estab == real(ug_munic_code)
		label var D_same_munic_win "Dummy if the winner and seller are from the same municipality"
		
	gen byte D_same_state_win = uf_estab	== real(ug_state_code)
		label var D_same_state_win "Dummy if the winner and seller are from the same state"
}
.

* 6: Unit price (items selected by 02-Studying unit price.do )
{
	cap drop D_item_unit_price_sample
	gen D_item_unit_price_sample = ///
		inlist(item_5d_code,"00012", "00024", "00046", "00074", "00108", "00176", "00200", "00205", "00421" ) | ///
		inlist(item_5d_code,"00517", "00867", "01415", "02085", "02173", "02671", "05728", "07533", "08061" ) | ///
		inlist(item_5d_code,"09748", "12240", "12254", "12820", "13092", "13114", "13768", "13824", "13828" ) | ///
		inlist(item_5d_code,"14216", "17357", "17593", "18035", "18065", "18066", "18075", "18078", "18087" ) | ///
		inlist(item_5d_code, "00431", "09665", "14017")
		
	* Creating upper_level
	{
		gen upper_level = .
		replace upper_level =1.2 if item_5d_code =="00012"
		replace upper_level =5.0 if item_5d_code =="00024"
		replace upper_level =2.0 if item_5d_code =="00046"
		replace upper_level =5.0 if item_5d_code =="00074"
		replace upper_level =2.0 if item_5d_code =="00108"
		replace upper_level =2.5 if item_5d_code =="00176"
		replace upper_level =4.0 if item_5d_code =="00200"
		replace upper_level =3.0 if item_5d_code =="00205"
		replace upper_level =5.0 if item_5d_code =="00421"
		replace upper_level =2.5 if item_5d_code =="00431"
		replace upper_level =6.0 if item_5d_code =="00517"
		replace upper_level =4.5 if item_5d_code =="00867"
		replace upper_level =7.0 if item_5d_code =="01415"
		replace upper_level =7.0 if item_5d_code =="02085"
		replace upper_level =9.0 if item_5d_code =="02173"
		replace upper_level =6.0 if item_5d_code =="02671"
		replace upper_level =7.0 if item_5d_code =="05728"
		replace upper_level =7.5 if item_5d_code =="07533"
		replace upper_level =4.0 if item_5d_code =="08061"
		replace upper_level =7.0 if item_5d_code =="09665"
		replace upper_level =9.0 if item_5d_code =="09748"
		replace upper_level =8.0 if item_5d_code =="12240"
		replace upper_level =9.0 if item_5d_code =="12254"
		replace upper_level =9.0 if item_5d_code =="12820"
		replace upper_level =2.0 if item_5d_code =="13092"
		replace upper_level =6.0 if item_5d_code =="13114"
		replace upper_level =10  if item_5d_code =="13768"
		replace upper_level =6.0 if item_5d_code =="13824"
		replace upper_level =8.0 if item_5d_code =="13828"
		replace upper_level =5.5 if item_5d_code =="14017"
		replace upper_level =5.0 if item_5d_code =="14216"
		replace upper_level =5.0 if item_5d_code =="17357"
		replace upper_level =7.0 if item_5d_code =="17593"
		replace upper_level =3.0 if item_5d_code =="18035"
		replace upper_level =3.0 if item_5d_code =="18065"
		replace upper_level =2.0 if item_5d_code =="18066"
		replace upper_level =1.5 if item_5d_code =="18075"
		replace upper_level =2.0 if item_5d_code =="18078"
		replace upper_level =4.0 if item_5d_code =="18087"
	}
	.

	* Creating lower_level
	{
		gen lower_level = .
		replace lower_level =-2.0 if item_5d_code =="00012"
		replace lower_level =-1.0 if item_5d_code =="00024"
		replace lower_level =-3.0 if item_5d_code =="00046"
		replace lower_level = 1.0 if item_5d_code =="00074"
		replace lower_level =-1.0 if item_5d_code =="00108"
		replace lower_level =-1.0 if item_5d_code =="00176"
		replace lower_level = 1.0 if item_5d_code =="00200"
		replace lower_level =-3.0 if item_5d_code =="00205"
		replace lower_level = 2.0 if item_5d_code =="00421"
		replace lower_level =-1.0 if item_5d_code =="00431"
		replace lower_level =-1.0 if item_5d_code =="00517"
		replace lower_level = 2.0 if item_5d_code =="00867"
		replace lower_level = 2.0 if item_5d_code =="01415"
		replace lower_level =-3.0 if item_5d_code =="02085"
		replace lower_level =-1.0 if item_5d_code =="02173"
		replace lower_level = 1.0 if item_5d_code =="02671"
		replace lower_level = 2.5 if item_5d_code =="05728"
		replace lower_level = 3.0 if item_5d_code =="07533"
		replace lower_level = 1.5 if item_5d_code =="08061"
		replace lower_level = 3.0 if item_5d_code =="09665"
		replace lower_level = 3.0 if item_5d_code =="09748"
		replace lower_level = 3.0 if item_5d_code =="12240"
		replace lower_level = 2.0 if item_5d_code =="12254"
		replace lower_level = 0.0 if item_5d_code =="12820"
		replace lower_level =-2.0 if item_5d_code =="13092"
		replace lower_level =-4.0 if item_5d_code =="13114"
		replace lower_level = 6.5 if item_5d_code =="13768"
		replace lower_level = 0.0 if item_5d_code =="13824"
		replace lower_level = 3.0 if item_5d_code =="13828"
		replace lower_level = 0.0 if item_5d_code =="14017"
		replace lower_level = 0.0 if item_5d_code =="14216"
		replace lower_level = 0.0 if item_5d_code =="17357"
		replace lower_level = 0.5 if item_5d_code =="17593"
		replace lower_level = 0.0 if item_5d_code =="18035"
		replace lower_level = 0.0 if item_5d_code =="18065"
		replace lower_level =-1.0 if item_5d_code =="18066"
		replace lower_level =-1.0 if item_5d_code =="18075"
		replace lower_level =-1.0 if item_5d_code =="18078"
		replace lower_level = 0.0 if item_5d_code =="18087"
	}
	.
	
	* Generating new unit price
	{
		gen unit_price_filter = unit_price if ///
			inrange(log(unit_price),lower_level,upper_level) & ///
			D_item_unit_price_sample==1
		label var unit_price_filter "log(unit price filter)"
			
		gen log_unit_price_filter = log(unit_price_filter)
			label var log_unit_price_filter "log(unit price filter)"
	}
}
.

*
{  
	tempfile data_to_merge
	save `data_to_merge' 
	
	
	use "${path_project}/1_data/05-Lot_item_data",clear
	
	gen year = year(dofm(year_month))
	gcollapse (count) value_item  , by(year type_item item_5d_code) freq(N_purchases)
	
	* Year list
	keep if inrange(year,2015,2021)
	
	*
	bys item_5d_code: keep if _N==7			
	
	rename N_purchases N_sample_all_years_purchase 
	
	gcollapse (mean) N_item_purchases_mean = N_sample_all_years_purchase ///
			  (min)   N_item_purchases_min = N_sample_all_years_purchase , ///
			 by(item_5d_code type_item)	
	
 	merge 1:m item_5d_code type_item using  `data_to_merge' , nogen
	
	gen byte D_sample_item_balance = N_item_purchases_mean>=50 & N_item_purchases_mean!=.
	order D_sample_item_balance N_item_purchases_mean N_item_purchases_min, last
} 
.

* 7: Saving
{	
	compress
	save "${path_project}/1_data/05-Lot_item_data",replace
}
.	
