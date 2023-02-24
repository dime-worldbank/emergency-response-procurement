* Program made by Leandro Veloso
* Main: Generate data to study SME set aside benefit 

* 1: Participants data
{
	use  "${path_project}/4_outputs/1-data_temp/03-participants_data",clear
	
	* Restricting to period
	* keep if year_month >=ym(2015,1)
	
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


* 1: Participation data: Measure firms participates
{
	use "${path_project}/1_data/01-sample_run_fast/04-participants_data",clear
	keep id_item id_bidder D_winner type_item item_2d_code item_5d_code D_covid Covid_group_level Covid_item_level   methods id_ug value_item
	 
	* Getting extra information
	gen 	 year 		= real(substr(id_item,14,4))
	gen id_tender 		= substr(id_item,1,17)

	* Converting to numeric
	gegen id_ug_num 	= group(id_ug)
	gegen id_tender_num = group(id_tender)
	gegen id_item_num   = group(id_item)
	
	* N participants by item
	bys id_item_num: gen N_participants_item             =      _N
	
	gegen item_5d_code_unique = group(type_item item_5d_code )
	gegen item_2d_code_unique = group(type_item item_2d_code )
	destring item_5d_code item_2d_code, replace force 
	
	rename type_item type_item_aux
	gen     type_item=1 if type_item_aux== "Product"
	replace type_item=2 if type_item_aux== "Service"
	
	
	bys id_bidder year type_item item_5d_code: gen Main_try = _N
	
	gen byte D_auction =  methods ==1
	tab methods  D_auction
	
	* Keep using
	keep D_covid Covid_group_level Covid_item_level D_winner  ///
		id_bidder year	D_auction Main_try	///
 		N_participants_item  value_item		///
		item_5d_code item_2d_code type_item	///	 	     	
		id_tender_num id_ug_num item_5d_code_unique item_2d_code_unique  
		
	compress
	save "${path_project}/4_outputs/1-data_temp/P07-participants_measures",replace
}
.

* 2: New winner
{ 
	use id_bidder year_month D_winner using "${path_project}/1_data/01-sample_run_fast/04-participants_data" if D_winner==1 ,clear
	keep id_bidder year_month 
	duplicates drop id_bidder year_month , force

	bys id_bidder (year_month): gen months_since_last_win = year_month - year_month[_n-1]
	bys id_bidder (year_month): replace months_since_last_win = year_month - ym(2013,1) if months_since_last_win==.
	gen D_new_winner =  months_since_last_win>=24

	* Keeping data
	keep id_bidder year_month D_new_winner months_since_last_win

	save "${path_project}/4_outputs/1-data_temp/P07-New_winner",replace
}
.

* 02: Aggregating procurement information to parcipant level
foreach sample of numlist 1 {		
	* triers
	use "${path_project}/4_outputs/1-data_temp/P07-participants_measures", clear
	
	* Collapsing
	gsort id_bidder year -Main_try		
	gcollapse   (sum) 	    N_item_auction_try	 = D_auction		    ///
				(mean)      avg_competition_try  = N_participants_item  ///
							avg_volume_try       = value_item 			///											
				(nunique) 	N_unique_item5d_try  = item_5d_code_unique	///	
							N_unique_item2d_try  = item_2d_code_unique	///	
							N_unique_tender_try  = id_tender_num		///	
							N_unique_ug_try      = id_ug_num			///	
				(first) 	main_item_5d_try 	 = item_5d_code			///
							main_item_2d_try 	 = item_2d_code	 		///
							main_type_item_try   = type_item 	     	///
						,by(id_bidder year) freq(N_item_try)

	tempfile try_data_`sample'
	save `try_data_`sample''
	
	* winners
	use "${path_project}/4_outputs/1-data_temp/P07-participants_measures" if D_winner==1, clear
	
	* Collapsing
	gsort id_bidder year -Main_try		
	gcollapse   (sum) 	    N_item_auction_win	 = D_auction		    ///
				(mean)      avg_competition_win  = N_participants_item  ///
							avg_volume_win       = value_item 			///											
				(nunique) 	N_unique_item5d_win  = item_5d_code_unique	///	
							N_unique_item2d_win  = item_2d_code_unique	///	
							N_unique_tender_win  = id_tender_num		///	
							N_unique_ug_win      = id_ug_num			///	
				(first) 	main_item_5d_win 	 = item_5d_code			///
							main_item_2d_win 	 = item_2d_code	 		///
							main_type_item_win   = type_item 	     	///
						,by(id_bidder year) freq(N_item_win)					
	
	merge 1:1 id_bidder year using `try_data_`sample'', nogen keep(3)
	
	gen sample=1
	
	compress
	save "${path_project}/4_outputs/1-data_temp/P07_bidder_year_sample-`sample'",replace
}
.

* 03: New winners
foreach sample of numlist 1 {		
	* triers
	use "${path_project}/4_outputs/1-data_temp/P07-participants_measures" if D_winner==1, clear
	
	* Collapsing
	gsort id_bidder year -Main_try		
	gcollapse   (sum) 	    N_item_auction_try	 = D_auction		    ///
				(mean)      avg_competition_try  = N_participants_item  ///
							avg_volume_try       = value_item 			///											
				(nunique) 	N_unique_item5d_try  = item_5d_code_unique	///	
							N_unique_item2d_try  = item_2d_code_unique	///	
							N_unique_tender_try  = id_tender_num		///	
							N_unique_ug_try      = id_ug_num			///	
				(first) 	main_item_5d_try 	 = item_5d_code			///
							main_item_2d_try 	 = item_2d_code	 		///
							main_type_item_try   = type_item 	     	///
						,by(id_bidder year) freq(N_item_try)

	tempfile try_data_`sample'
	save `try_data_`sample''
	
* winners
	use "${path_project}/4_outputs/1-data_temp/P07-participants_measures" if D_winner==1, clear

	* Collapsing
	gsort id_bidder year -Main_try		
	gcollapse   (sum) 	    N_item_auction_win	 = D_auction		    ///
				(mean)      avg_competition_win  = N_participants_item  ///
							avg_volume_win       = value_item 			///											
				(nunique) 	N_unique_item5d_win  = item_5d_code_unique	///	
							N_unique_item2d_win  = item_2d_code_unique	///	
							N_unique_tender_win  = id_tender_num		///	
							N_unique_ug_win      = id_ug_num			///	
				(first) 	main_item_5d_win 	 = item_5d_code			///
							main_item_2d_win 	 = item_2d_code	 		///
							main_type_item_win   = type_item 	     	///
						,by(id_bidder year) freq(N_item_win)
	
	merge 1:1 id_bidder year using `try_data_`sample'', nogen keep(3)
	
	gen sample=1
	
	compress
	save "${path_project}/4_outputs/1-data_temp/P07_bidder_year_sample-`sample'",replace
}
.
	
	
	
	
		compress
		gen D_winner 
							
		
		
		* Filtering
 		keep if inlist(length(id_bidder), 14,12,11)	
 
		* Destring
		destring item_5d_code, replace force
		
		* Gettinng max
		bys id_bidder year item_5d_code: gen item_aux 		 = _N
		bys id_bidder year (item_aux): gen main_item_5d 	 =      item_5d_code[_N]
		bys id_bidder year (item_aux): gen main_item_2d 	 = real(item_2d_code[_N])
		bys id_bidder year (item_aux): gen main_type_item 	 =      type_item[_N]
		
		* Getting estimated volume of item 
		merge  m:1 id_item using  "${path_import}/Portal-02-item-panel", keepusing(id_item value_item)		
		
		* Keeping relevant vars
		keep id_bidder year benefity id_ug_num id_tender_num id_item_num item_5d_code ///
			 main_item_5d  main_item_2d main_type_item N_participants_item value_item

		* Collapsing
 		gcollapse   (mean)      avg_competition      = N_participants_item  ///
								avg_colume_try       = value_item 			///
					(sum) 	    N_item_aside_try     = benefity   			///
								N_item_auction_try	 = D_auction		    ///
					(nunique) 	N_unique_ug_try 	 = id_ug_num 			///
								N_unique_tender_try  = id_tender_num 		///
								N_unique_item5d_try  = item_5d_code   		///	
								N_unique_item2d_try  = item_2d_code   		///	
					(first) 	main_item_5d_try 	 = main_item_5d			///
								main_item_2d_try 	 = main_item_2d			///
								main_type_item_try   = main_type_item 		///
							,by(id_bidder year) freq(N_item_part)
	}
	.
	
	* 2: Participation data labels and formats
	{		
		*Adding label value
			label val main_type_item lab_type
		
		* Converting back to string
			tostring main_item_2d, format(%02.0f) replace
			tostring main_item_5d, format(%05.0f) replace
		
		* labeling
			label var N_item_part 			"N items participation"
			label var N_item_aside_part 	"N set aside items participation"
			label var N_unique_ug_part 		"N distinct UG participation"
			label var N_unique_tender_part 	"N distinct tender participation"
			label var N_unique_item5d_part 	"N distinct item 5d participation"
			label var main_item_5d		 	"Most frequent item 5d participation"
			label var main_item_2d		 	"Most frequent item 2d participation"
			label var main_type_item	 	"Most frequent type item participation"
			label var avg_competition		"avg N participants in bidders participations  by year"
			
			label var id_bidder			 "id bidder"
			label var year			 	"year tender"
		
		* Formating
			format %3.2fc avg_competition
			format %12.0fc N_*	
		
		* Sort and saving
			sort year main_type_item  main_item_2d main_item_5d id_bidder
			order  id_bidder year main_type_item main_item_2d main_item_5d N_item_part N_item_aside_part  ///
				N_unique_tender_part N_unique_ug_part N_unique_item5d_part	avg_competition	
		
		* Labeling data
			label data "Bidders participation summary"
		
		* Compress and saving
			compress
			save "${path_datatemp}/P2_N_participant_bidder", replace
	}
	. 
	
	* 3: Counting the number of participation each year by bidder
	{
		use "${path_import}/Portal-02-item-panel", clear
		gduplicates drop id_item, force
		
		* Getting item code
		merge  m:1 id_item using "${path_import}/PORTAL-02-item-code", ///
			keepusing(id_item ) keep(3) nogen			

		* Getting benefity tag
		merge  1:1 id_item using "${path_final}/P1-SME-data_study-all_methods", ///
			keepusing(id_item  benefity) keep(3) nogen
				
		* First year participate
		cap drop year
		gen 	 year 		= real(substr(id_item,14,4))
		gen id_tender 		= substr(id_item,1,17)
		gen 	id_ug 		= substr(id_item,1,6)
 			
		* Filtering
		keep if inrange(year,2013,2022)
		keep if inlist(length(id_bidder), 14,12)
		keep if substr(id_item,7,2) == "05"
	
		* Converting to numeric
		gegen id_ug_num 	= group(id_ug)
		gegen id_tender_num = group(id_tender)		
		 
		* Collapsing 
		gcollapse (sum) N_set_aside_wins    = benefity   	///
						value_win_year   	= value_item 	///
			(nunique) 	N_unique_ug_win 	= id_ug_num 	///
						N_unique_tender_win = id_tender_num ///
 						,by(id_bidder year) freq(N_item_wins)
						 				
		* Merging data
		merge 1:1  id_bidder year  using "${path_datatemp}/P2_N_participant_bidder", keep(2 3 ) nogen
				
		* labeling
			label var id_bidder			 "id bidder"
			label var year				 "year tender"
			
			label var N_item_wins 			"N items participation"
			label var N_set_aside_win 		"N set aside items won"
			label var N_unique_ug_win 		"N distinct UG won"
			label var N_unique_tender_win 	"N distinct tender won"
			label var value_win_year		"total value won"
				
		
		* Filling the panel
			tab year
			fillin id_bidder year
			rename _fillin D_participant_year
				label var D_participant_year "Dummy if the bidder participated in a year tender process" 
			
		* Replacing by zerp
			foreach var of varlist N* value_* {
				replace `var' = 0 if `var' == .
			}
			.
		
		* Dummy if win in the year
			gen byte D_win_year = N_item_wins>=1
			replace D_participant_year = D_participant_year==0
		
		* 
			gen rate_win = N_item_wins/N_item_part
			label var rate_win "Probability of win"
		
		
		* Formating
			format %3.2fc avg_competition
			format %12.0fc N_*	
			format %15.0fc value_win_year*			
		
		* Sort and saving
			sort year main_type_item  main_item_2d main_item_5d id_bidder
			order  	id_bidder year	/// 
					D_participant_year 	  D_win_year			///
					main_type_item main_item_2d main_item_5d 	///						
					N_item_part			  N_item_wins 			///
					value_win_year		  avg_competition		///
					N_item_aside_part 	  N_set_aside_win  		///
					N_unique_tender_part  N_unique_tender_win 	///
					N_unique_ug_part  	  N_unique_ug_win   	///
					N_unique_item5d_part 	
					
		* Labeling data
			label data "Bidders participation summary"
		
		* prefix
			rename * bid_*
			rename bid_id_bidder id_bidder
			rename bid_year 	  year
			
		* Compress and saving
			compress
			save "${path_datatemp}/P2_procurement_bidders", replace
	}
	.
	
	* 4: Classification firm
	{
		use "${path_datatemp}/P2_procurement_bidders",clear
		
		gcollapse (sum) bid_N_wins= bid_N_item_wins, by(id_bidder)
		
		* labeling
		label var bid_N_wins "total tenders won"
		
		* sample
		gen byte bid_sample = 1 if bid_N_wins>=1 // ever win
		replace  bid_sample = 2 if bid_N_wins==0 // never win
		label var bid_sample "1-ever tender winner; 2-try and never won; 3-never try"
		
		* saving
		compress
		save "${path_datatemp}/P2_list_treats", replace
	}
	.
	
	* 5: Set of firms that participate in others procurement process
	{
		use "${path_import}/Portal-03-participants_level-panel" if D_winner ==1 ,clear
		 
		* Keeping only Reverse Auction and FA
		keep if substr(id_item,7,2) != "05"
		 
		* Selecting sample
		keep id_bidder
		gduplicates drop id_bidder, force
		
		* Participants of others methods
		compress
		save "${path_datatemp}/P3_non_auction_list", replace
	}
	.
}
.

* 04: Creating firm data
{			
	* 01: Joing establishment + Procurement data
	{
		use "${path_datatemp}/02-Panel_rais_to_merge",clear		
		
		* Change to name used in bidder data
		rename cnpj_cei id_bidder
		
		* 02: Minor variable ajusts 
		{
			keep if length(id_bidder)==14	

			* Years 
			gen year_simples_start = year(date_simples_start)
			gen year_simples_end   = year(date_simples_end  ) 
			
			* Date 
			cap drop D_simples
			gen byte D_simples  = inrange(year, year_simples_start, year_simples_end) & inrange(year_simples_start,2005,2022) 
			drop year_simples_start year_simples_end
			
			* Dummy small medium firm
			gen byte D_SME = inlist(porte_empresa,1,2)
		 
			tostring natureza_juridica, replace
		}
		.	
	}
	.

	* 02: Adjusting formats
	{
		sort  cnpj8 id_bidder year

		order cnpj8 id_bidder year great_sectors uf_estab natureza_juridica D_mei D_SME D_simples porte_empresa  ///
			  N_workers	N_male_workers	N_female_workers	N_hire	N_fire N_dec_3112 avg_wage sum_wage	

		* Formating data
		format %12.0fc sum_wage	avg_wage N_*
		format %12.0fc sum_wage	avg_wage
		format %9.0fc N_*
		format %1.0fc D_*
		format %9s natureza_juridica

		* labeling variables 
		{
			label var cnpj8               "Firm id" 
			label var id_bidder           "bidder id"
			label var year                "year data"
			label var great_sectors       "0-agro; 1-manufactoring; 2-construction; 3-commerce; 4-service; 5-others"
			label var uf_estab            "state of stablishment"
			label var natureza_juridica   "type establishment entity"
			label var D_mei               "Dummy-Mmicro individual estab"
			label var D_SME               "Dummy-SME"
			label var D_simples           "Dummy-simples"
			label var porte_empresa       "1-ME; 3-EPP; 5-Others"
			label var N_workers           "Total workers in the year"
			label var N_male_workers      "Total male workers in the year"
			label var N_female_workers    "Total female workers in the year"
			label var N_hire              "Total hires in the year"
			label var N_fire              "Total fires in the year"
			label var N_dec_3112          "Total workers in 31/12"
			label var avg_wage            "Average establishment wage"
			label var sum_wage            "Estimated total month wage"
			label var munic_estab         "municipality of establishment"
			label var cnae20              "industry classification 2 digits"
			label var date_simples_start  "date that simples benefit started"
			label var date_simples_end	  "date that simples benefit ended"
		}
		.
	}
	.
	
	* 03: Joing establishment + Procurement data
	{
		* Renaming
		rename * rais_*
		rename rais_id_bidder 	id_bidder
		rename rais_year 	  	year
		rename rais_cnpj8		cnpj8	
		
		* Getting groups
		merge m:1 id_bidder using "${path_datatemp}/P2_list_treats", keep(1 3) nogen
		replace bid_sample = 3 if bid_sample==. 
		order cnpj8 id_bidder year bid_sample
		
		* Joing using bidder level procument data.
		merge 1:1 id_bidder  year using "${path_datatemp}/P2_procurement_bidders", keep(1 3) nogen
	}
	.
	
	* 04: Removing others methods
	{
		merge m:1 id_bidder using "${path_datatemp}/P3_non_auction_list", gen(merge_non_auc)
		
		gen byte D_filter_non_auction = merge_non_auc==3
			label var D_filter_non_auction "Non Auction methods"
		drop merge_non_auc
		
		tab   bid_sample D_filter_non_auction	
		drop if D_filter_non_auction==1
	}
	.	
	
	* 05: Creating new variables
	{
		bys id_bidder (year): gen cummulated_win 	 = sum(bid_N_item_wins)
			label var cummulated_win "cummulated number of winners by year"
		
		cap drop D_firm_destruction
 		bys id_bidder (year): gen byte D_firm_destruction = year[_n+1]==. if year< 2019
			label var D_firm_destruction "dummy if it last year of firm"
		tab year D_firm_destruction 		
		
		cap drop D_firm_destruction_2019
		bys id_bidder (year): gen byte D_firm_destruction_2019 = year[_N]!=2019
			label var D_firm_destruction_2019 "dummy if it does not in 2019"
		tab year D_firm_destruction_2019 		
	}
	.

	* 05: Ordering relevant variables
	{	
		* Keeping only the three groups
		keep if inlist(bid_sample,1,2,3)
			
		* Labeling data 
		label data "Rais panel restrict to ever bidded firms - 2013-2019"
	
		* Saving
		compress
		save "${path_final}/02-Firms_procurement_panel",replace
	}
	.
}
.
