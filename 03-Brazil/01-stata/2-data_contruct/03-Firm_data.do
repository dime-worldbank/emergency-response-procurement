* Program made by Leandro Veloso
* Main: Preparing firm data for the study

* 1: Participation data: Measure firms participates
{
	* 1: Collect relant infomation
	{
		use "${path_project}/1_data/01-import-data/Portal-03-participants_level-panel"  ,clear
		
		* sample (only to code fast)
		* keep if runiform()<=0.01
		 
		* Keeping only Reverse Auction and FA
		* keep if substr(item_id,7,2) == "05"
		 
		* Getting extra information
		gen 	 year 		= real(substr(item_id,14,4))
		gen 	id_ug 		= substr(item_id,1,6)

		* Converting to numeric
		gegen id_ug_num 	= group(id_ug)
		gegen id_tender_num = group(tender_id)
		gegen item_id_num   = group(item_id)
		
		* N participants by item
		bys item_id_num: gen N_participants_item             =      _N

		* Filtering
		keep if inrange(year,2013,2022)
		keep if inlist(length(bidder_id), 14)	
		
		* Removing extra variables
		cap drop type_item
		cap drop item_2d_code
		cap drop item_5d_code

		* Getting item code
		merge  m:1 item_id using "${path_import}/Portal-02-item-panel", keep(3) nogen	keepusing(item_id type_item item_5d_code item_value)
		
		* merge covid item
		merge m:1 type_item item_5d_code using "${path_project}/1_data/03-final/03-covid_item-item_level", ///
			keepusing(type_item item_5d_code  Covid_group_level Covid_item_level) nogen keep(3)	
	}
	.
	
	* 2: Creatin variables and collapsing
	{
		* Dummy de covid product
		gen byte D_win_covid_product_high  = Covid_item_level==3 & D_winner ==1
		gen byte D_win_covid_product_med   = Covid_item_level==2 & D_winner ==1
		gen byte D_win_covid_product_low   = Covid_item_level==1 & D_winner ==1
		gen byte D_part_covid_product_high = Covid_item_level==3
		gen byte D_part_covid_product_med  = Covid_item_level==2
		gen byte D_part_covid_product_low  = Covid_item_level==1	 
		
		* Destring
		destring item_5d_code, replace force
		
		* Gettinng max
		  gen item_value_win = item_value if D_winner==1
		gegen main_volume_item = sum(item_value_win), by(bidder_id year item_5d_code type_item)
		
		bys bidder_id year item_5d_code: gen item_aux 		 = _N
		bys bidder_id year (main_volume_item):   gen main_item_5d 	 =      item_5d_code[_N]
		bys bidder_id year (main_volume_item):   gen main_type_item  =      type_item[_N]
		  
		* Keeping relevant vars
		keep bidder_id year id_ug_num id_tender_num item_id_num item_5d_code ///
			 main_item_5d  main_type_item N_participants_item item_value ///
			 D_*_covid_product* D_winner item_value_win			
		 
		* Collapsing
		gcollapse   (sum)       N_item_wins      = D_winner					///
					(mean)      avg_competition      = N_participants_item  ///
								avg_value_part_year  = item_value 			///
								avg_value_win_year   = item_value_win	    ///
					(nunique) 	N_unique_ug_part 	 = id_ug_num 			///
								N_unique_tender_part = id_tender_num 		///
								N_unique_item5d_part = item_5d_code   		///	
					(max)       D_*_covid_product*							///
					(first) main_item_5d  main_type_item 		///
							,by(bidder_id year) freq(N_item_part)
	}
	.

	* 3: Labeling and saving
	{		
		*Adding label value
			label val main_type_item type_item
		
		* Converting back to string
			tostring main_item_5d, format(%05.0f) replace
		
		* labeling
		{
			label var N_item_part 			"N items bidded in the year"
			label var N_item_wins			"N items won in the year"
			label var N_unique_ug_part 		"N distinct UG participation"
			label var N_unique_tender_part 	"N distinct tender participation"
			label var N_unique_item5d_part 	"N distinct item 5d participation"
			label var main_item_5d		 	"Most frequent item 5d participation"
			label var main_type_item	 	"Most frequent type item participation"
			label var avg_competition		"avg N participants in bidders participations in a year"
			label var avg_value_part_year	"avg item volume participated by the bidder in a year"
			label var avg_value_win_year	"avg item volume won by the bidder in a year"
			
			label var bidder_id			 		"id bidder"
			label var year			 			"year tender"
			label var D_win_covid_product_high  "dummy if it won a covid item High-covid 5 digits level"     
			label var D_win_covid_product_med   "dummy if it won a covid item Medium-covid 5 digits level"       	 
			label var D_win_covid_product_low   "dummy if it won a covid item Low-covid 5 digits level"      
			label var D_part_covid_product_high "dummy if it bidded for a covid item High-covid 5 digits level"   
			label var D_part_covid_product_med  "dummy if it bidded for a covid item Medium-covid 5 digits level" 
			label var D_part_covid_product_low  "dummy if it bidded for a covid item Low-covid 5 digits level"    
		}
		.
		
		* Formating
			format %12.2fc avg_competition avg_value_part_year	avg_value_win_year 
			format %12.0fc N_*
			format %14s    bidder_id
			format %4.0fc year 
		
		* Sort and saving
			sort year main_type_item  main_item_5d bidder_id
			order   bidder_id year main_type_item main_item_5d N_item_part N_item_wins       ///
				avg_competition avg_value_part_year avg_value_win_year N_unique_tender_part  ///
				N_unique_ug_part N_unique_item5d_part	avg_competition	
		
		* Labeling data
			label data "Bidders participation summary"
		
		* Compress and saving
			compress
			save "${path_project}/4_outputs/1-data_temp/P2_N_participant_bidder", replace
	}
	. 											
}
.

* 02: Creating study groups
{
	* 1: Reading data step 1 and fill up the panel to balance it
	{
		use bidder_id year N_item_part N_item_wins using  "${path_project}/4_outputs/1-data_temp/P2_N_participant_bidder",clear
		
		* Keep
		keep if inrange(year, 1993, 2021)		
		
		* Creating  panel variables 
		gegen id_aux = group(bidder_id)
		
		* Panel definition
		tsset id_aux year
		tsfill, full
		
		* Filling up the bidder id
		gsort id_aux -bidder_id		
		by id_aux: replace bidder_id = bidder_id[1]
		
		* Missing by zero
		replace N_item_part = 0 if N_item_part==.
		replace N_item_wins = 0 if N_item_wins==.
		
	}
	.
	
	* 2: Variable creation
	{ 
		* Lag operation
		sort id_aux year

		gen D_win_group      = (N_item_wins +L1.N_item_wins + L2.N_item_wins) >=1 & year>=2015
		gen D_part_group     = (N_item_part +L1.N_item_part + L2.N_item_part) >=1 & year>=2015
		gen D_never_try_group= (N_item_part +L1.N_item_part + L2.N_item_part) ==0 & year>=2015

		* Cummulated variables
		by id_aux: gen cum_participation   = sum(N_item_part )
		by id_aux: gen cum_wins            = sum(N_item_wins )
		by id_aux: gen cum_year_part_group = sum(D_part_group)
		by id_aux: gen cum_year_win_group  = sum(D_win_group )
		
		* Rate win | to try
		gen rate_success     	=  N_item_wins/N_item_part
		
		* Creating groups
		gegen total_win = sum(N_item_wins), by(bidder_id)
		gen byte  bid_sample_static = 1 if total_win>= 1 // ever win
		replace   bid_sample_static = 2 if total_win== 0 // try win
		label var bid_sample_static  "1-ever tender winner; 2-try and never won; 3-never try"
		
		* Dinamic criteria
		gen byte  bid_sample_dinamic = 1 if D_win_group==1 // ever win
		replace   bid_sample_dinamic = 2 if D_win_group==0 & D_part_group==1 // never win
		replace   bid_sample_dinamic = 3 if D_win_group==0 & D_part_group==0 & D_never_try_group==1 // never win
		label var bid_sample_dinamic "Based in T, T-1, and T-2. 1-ever tender winner; 2-try and never won; 3-never try"
	}
	.
	
	* 3: Labeling and saving the data
	{
		* list relevant order
		local set_main_vars bidder_id year bid_sample_dinamic bid_sample_static ///
							 rate_success total_win ///
							 cum_participation cum_wins cum_year_part_group cum_year_win_group
							 
		* keep, order and sort data
		keep   `set_main_vars'
		order  `set_main_vars'
		sort bidder_id year
		
		* Formating
		format %8.0fc cum* total*
		format %3.2fc rate_success
		
		* Labeling
		label var rate_success			"proportion of win | N tries"
		label var total_win             "Total wins from 2013-2021"
		label var cum_participation     "Cummulated number of participations"
		label var cum_wins              "Cummulated number of winners"
		label var cum_year_part_group   "Cummulated number of years in that the bidded"
		label var cum_year_win_group    "Cummulated number of years in that the won a lot"
		
		* saving
		compress
		save "${path_project}/4_outputs/1-data_temp/P2_list_treats", replace
	}
	.
}
.

* 03: Creating firm data
{			
	* 01: Joing establishment + Procurement data
	{
		use "${path_rais}/02-Panel_rais_to_merge",clear		
*keep if runiform()<=0.01
		* Filtering
		keep if D_atividade ==1
		drop D_rais_neg D_atividade
		
		* Change to name used in bidder data
		rename cnpj_cei bidder_id
		
		* 02: Minor variable ajusts 
		{
			keep if length(bidder_id)==14	

			* Years 
			gen year_simples_start = year(date_simples_start)
			gen year_simples_end   = year(date_simples_end  ) 
 			
			* Date 
			*cap drop date_simples_start date_simples_end
			*gen byte D_simples  = inrange(year, year_simples_start, year_simples_end) & inrange(year_simples_start,2005,2022)  
			
			* Dummy small medium firm
			gen byte D_SME = inlist(porte_empresa,1,2)
		 
			tostring natureza_juridica, replace
		}
		.	
	}
	.

	* 02: Adjusting formats
	{
		sort  cnpj8 bidder_id year

		order cnpj8 bidder_id year great_sectors uf_estab natureza_juridica D_mei D_SME D_simples porte_empresa  ///
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
			label var bidder_id           "bidder id"
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
			label var year_simples_start  "year that simples benefit started"
			label var year_simples_end	  "year that simples benefit ended"
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
		rename rais_bidder_id 	bidder_id
		rename rais_year 	  	year
		rename rais_cnpj8		cnpj8	
		
		* Getting groups
		merge m:1 bidder_id year using "${path_project}/4_outputs/1-data_temp/P2_list_treats", keep(1 3) nogen
		replace bid_sample_dinamic = 3 if bid_sample_dinamic==.
		replace bid_sample_static  = 3 if bid_sample_static ==.
				
		* Joing using bidder level procument data.
		merge 1:1 bidder_id  year using "${path_project}/4_outputs/1-data_temp/P2_N_participant_bidder", keep(1 3)  nogen
	}
	.
	  
	* 05: Creating new variables
	{ 
		cap drop D_firm_exist
 		bys bidder_id (year): gen byte D_firm_exist = (year[_n+1]-year)==1 if year<=2020
			label var D_firm_exist "dummy if it exist next year"
		tab year D_firm_exist 		
		
		cap drop D_firm_exist_2021
		foreach year in 2021 2020 2019 2018 { 
			cap drop aux_year 
			gen byte aux_year = year ==`year'
			bys bidder_id (aux_year): gen byte D_firm_exist_`year' = year[_N]==`year'
				label var D_firm_exist_`year' "dummy if it exist in `year'"
		}
		.
		cap drop aux_year 
		
		tab year D_firm_destruction_2021 		
		
	}
	.	
	
	* Replacing missing to zero
	foreach var of varlist D_win_covid*  N_item_part N_item_wins cum_* N_unique* {
		replace `var' = 0  if `var'==.
	}
	
	* 06: catchment variables
	{
		gen rais_cnae20_2d  =substr(rais_cnae20,1,2)
		
		cap drop level_catch_*
		tempfile data_to_merge
		save 	 `data_to_merge'
		
		global level_catch_01 "year rais_munic_estab rais_cnae20 rais_natureza_juridica"
		global level_catch_02 "year rais_munic_estab rais_cnae20"
 		
		foreach level in 01 02 {
			* 1: Getting municipality list from NaN
			{			
 				* Using
				use  `data_to_merge' if inlist(bid_sample_dinamic,1,2) ,clear
				 
				* Municipality list
				keep ${level_catch_`level'}  
				duplicates drop	${level_catch_`level'}, force
				
				* saving
				save "${path_project}/4_outputs/1-data_temp/level_catch_`level'", replace 
			}
			.
		}
		.
		
		* Merging catchment variables
		use `data_to_merge',clear
		foreach level in 01 02 {	
			* 2: Merging			
			cap drop _merge
			merge m:1  ${level_catch_`level'} using "${path_project}/4_outputs/1-data_temp/level_catch_`level'", keep(1 3) 
			gen level_catch_`level' =_merge==3
			label var level_catch_`level' "Catchment variables - ${level_catch_`level'}"
			drop _merge		
			
			di as white "Tabulating: Catchment variables - ${level_catch_`level'}"
			tab bid_sample_dinamic  level_catch_`level' 
		}
		.
	}
	.
	
	* 07: Ordering relevant variables
	{	 
		* Labeling data 
		label data "Rais panel restrict to ever bidded firms - 2013-2021"
	
		* Saving
		compress
		save "${path_project}/1_data/03-final/03-Firm_procurement_panel",replace
		
		gen random = runiform()<=0.05
		bys bidder_id: gen D_selected = random[1]
		drop if D_selected==0 & bid_sample_static==3
		
		save "${path_project}/1_data/03-final/03-Firm_procurement_panel_sample",replace		
	}
	.
	
	* 08: Constant by last year obs)
	{
		use "${path_project}/1_data/03-final/03-Firm_procurement_panel",clear
		
		* Keeping
		keep bidder_id year bid_sample* rais_great_sectors rais_uf_estab ///
			 rais_natureza_juridica rais_munic_estab rais_cnae20 rais_date_open_estab ///
			 D_firm_destruction_2021 rais_date_simples_start  rais_date_simples_end 
		
		* Keeping last obs
		bys bidder_id (year): keep if _n==_N
		drop year
		
		* Only relevant characteristics
		compress
		save "${path_project}/1_data/03-final/03-Firm_procurement_constant_characteristics", replace
	}
	.
}
.
