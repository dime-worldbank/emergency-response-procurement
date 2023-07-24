* Made by Leandro Veloso
* Main: Lot tender level data: The 
 
* 1: Join data variables to the lot data
{
	* 1: Reading lot/Item data 
		use "${path_project}/1_data/01-import-data/Portal-02-item-panel",clear
		cap drop year_month
		
	* 2: Getting infomation from tender data
		merge m:1 tender_id using "${path_project}/1_data/03-final/01-tender_data", ///
			keepusing( tender_id year year_month year_quarter year_month methods D_covid ///
			D_law_926_2020 ug_id ug_state ug_state_code ug_municipality_code decision_time  decision_time_trim ) nogen keep(3)
	
		rename year year_id_tender 
		
	* 3: Firms caracteristics
	{
		merge m:1 bidder_id	 using "${path_project}/1_data/03-final/03-Firm_procurement_constant_characteristics", keep(1 3) ///
			keepusing(bidder_id rais_great_sectors rais_date_simples_start rais_date_simples_end  rais_uf_estab rais_munic_estab )
		drop _merge	
		
		rename rais_* *
		
		* Years 
		gen year_simples_start = year(date_simples_start)
		gen year_simples_end   = year(date_simples_end  ) 

		* Date 
		cap drop date_simples_start date_simples_end
		gen byte SME  = inrange(year_id_tender, year_simples_start, year_simples_end) & inrange(year_simples_start,2005,2022)  
		cap drop year_simples_start year_simples_end 
	}
	.	
			 
	* 4: merge covid item
	merge m:1 type_item item_5d_code using "${path_project}/1_data/03-final/02-covid_item-item_level", ///
		keepusing(type_item item_2d_code item_5d_code  Covid_group_level Covid_item_level) nogen keep(3)		

	* 5: Merging data
	merge m:1 type_item item_5d_code  using "${path_project}/1_data/01-import-data/Extra-01-catalog-federal-procurement", ///
		keepusing(type_item item_5d_code item_2d_name_eng item_5d_name_eng ) keep(1 3) 	nogen 
}
.

* 2: Creating extra variables
{
	* Restricting to the period
	keep if inrange(year_id_tender, 2013,2022)
	
	* Checking no item code
	gen byte D_item_code_nomiss = item_5d_code==""
	tab year_id_tender D_item_code_nomiss
	drop D_item_code_nomiss 
 	
	* Ordering
	gen unit_price  = item_value/item_qtd 
	
	* Creating winner variables
	gen byte D_winner = 1

	* Ordering 
	sort  year_month ug_id item_id
	order year_id_tender year_month year_quarter  item_id bidder_id D_winner  ///
	  type_item item_5d_code item_5d_name item_2d_code item_2d_name ///
	  D_covid Covid_group_level Covid_item_level SME great_sectors uf_estab

	* Lot_item_data
	label data "Lot/item data"		
	compress
	save "${path_project}/4_outputs/1-data_temp/05-Lot_item_data-auxiliary data",replace	
}
.

* 3: Calculating New winner
{  
	use bidder_id year_month D_winner using "${path_project}/1_data/01-import-data/Portal-03-participants_level-panel" if D_winner==1 ,clear
	keep bidder_id year_month 
	duplicates drop bidder_id year_month , force
	
	* Year month
	rename year_month aux
	gen year_month = ym(real(substr(aux,1,4)), real(substr(aux,5,2)))
		format %tm year_month
	drop aux
	
	* Months since last won
	bys bidder_id (year_month): gen months_since_last_win = year_month - year_month[_n-1]
	bys bidder_id (year_month): replace months_since_last_win = year_month - ym(2013,1) if months_since_last_win==.
 
	* Keeping data
	keep bidder_id year_month months_since_last_win
	compress
	save "${path_project}/4_outputs/1-data_temp/P05-New_winner",replace
}
.

* 4: Participants by lot/tender
{
	use item_id SME using  "${path_project}/1_data/03-final/04-participants_data" ,clear
	
	* Counting participants
	gen N_participants = 1
	gcollapse (sum) N_participants N_SME_participants = SME, by(item_id)
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
	merge 1:1 item_id using "${path_project}/4_outputs/1-data_temp/P05-N_participants", keep(3) nogen
	
	* New winners
	merge m:1 bidder_id year_month  using "${path_project}/4_outputs/1-data_temp/P05-New_winner", keep(3) nogen
	gen byte D_new_winner =  months_since_last_win>=24 & D_winner==1
		label var D_new_winner "Dummy if the firm didn't win a lot more than 24 months'"
	
	* Creating pre/post
	gen byte D_post = year_quarter>=yq(2020,1)

	gen D_product 		= type_item== 1
		label var D_product "Dummy if the item is a product"
		
	gen D_auction		= methods  ==1
		label var D_auction "Dummy if the purchase method is auction"
	
	* Location dummy
	cap drop D_same_munic_win
	gen byte D_same_munic_win = munic_estab == real(substr(ug_municipality_code,1,6))
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
	.
}
.

*
{  
	tempfile data_to_merge
	save `data_to_merge' 
	
	* Collapsing 
	gen year = year(dofm(year_month))
	gcollapse (count) item_value  , by(year_id_tender type_item item_5d_code) freq(N_purchases)
	
	* Year list
	keep if inrange(year_id_tender,2015,2022)
	
	*
	bys item_5d_code: keep if _N==8			
	
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
	save "${path_project}/1_data/03-final/05-Lot_item_data",replace
}
.	
