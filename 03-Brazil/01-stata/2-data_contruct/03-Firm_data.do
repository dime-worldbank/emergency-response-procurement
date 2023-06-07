* Program made by Leandro Veloso
* Main: Generate data to study SME set aside benefit 

* 01: Select if run the sample or the full data
{
	* Uses 1 if you want to run in the sample
	global sample_fast 0

	if $sample_fast ==1 {			
		* Uses 1 if you want to create the sample data again. Normally it is not necessary
		global generate_sample 0
		
		* sample run fast 
		global path_sample	 "${path_project}/1_data/02-sample_run_fast"
		global path_final	 "${path_sample}"
		global path_import	 "${path_sample}"
		global path_datatemp "${path_sample}"
		global path_rais     "${path_sample}"
	}
	else {
		* Original
		global path_datatemp "${path_project}/4_outputs/1-data_temp/"
		global path_import	 "${path_project}/1_data/01-import-data/"	
		global path_final	 "${path_project}/1_data/03-final"
		global path_rais   		"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\01-dados\02-rais-procurement"	
	}
	.
}
.

* 02: sampling to run quick
if $generate_sample ==1 {
	* 01: Sampling cnpjs
	{
		* Rais  10000 CNPJs
			use cnpj_cei using "${path_rais}/02-Panel_rais_to_merge",clear
			gduplicates drop cnpj_cei, force
			rename  cnpj_cei bidder_id 
			
			keep if length(bidder_id)== 14
			
			gen random_aux = runiform()
			sort random_aux
			keep if _n<=20000
			
			tempfile rais_sample
			save `rais_sample'
		
		* Bidders 1000 CNPJs
			use bidder_id using "${path_project}/1_data/01-import-data/Portal-03-participants_level-panel" ,clear
			gduplicates drop bidder_id, force
			
			keep if length(bidder_id)== 14
			gen random_aux = runiform()
			sort random_aux
			keep if _n<=2000
			
		* Appending lists
			append using `rais_sample'
			gduplicates drop bidder_id, force
			
			save "${path_sample}/01-list_bidder.dta",replace
	}
	.
		
	* 02: sampling according to bidder_id
	{
		use "${path_sample}/01-list_bidder.dta",clear
		
		merge 1:m bidder_id using "${path_project}/1_data/01-import-data/Portal-03-participants_level-panel" ,nogen keep(3)
		keep item_id
		duplicates drop item_id,force
		
		save "${path_sample}/02-list_id_tem.dta",replace
	}
	.
	
	* 03: Getting sample of all data used
	{
		* Participants
		{
			use  "${path_sample}/02-list_id_tem.dta",clear
			merge 1:m item_id using  "${path_project}/1_data/01-import-data/Portal-03-participants_level-panel", nogen keep(3)
			save "${path_sample}/Portal-03-participants_level-panel",replace
		}
		.
		
		* Items
		{
			use  "${path_sample}/02-list_id_tem.dta",clear
			merge 1:m item_id using  "${path_project}/1_data/01-import-data/Portal-02-item-panel", nogen keep(3)
			save "${path_sample}/Portal-02-item-panel",replace
		}
		.
		
		* Tender data
		{
			use  "${path_sample}/02-list_id_tem.dta",clear
			gen tender_id = substr(item_id,1,17)
			drop item_id
			duplicates drop tender_id, force
			
			merge 1:m tender_id using  "${path_project}/1_data/01-import-data/Portal-01-tender-panel.dta", nogen keep(3)
			save "${path_sample}/Portal-01-tender-panel.dta",replace
		}
		.		 
		
		* Rais 
		{			
			use  "${path_sample}/01-list_bidder.dta",clear
			rename bidder_id cnpj_cei
 			merge 1:m cnpj_cei using  "${path_rais}/02-Panel_rais_to_merge", nogen keep(3)
			save "${path_sample}/02-Panel_rais_to_merge.dta",replace 
		}
		.
	}
	.	
}
.
	
* 03: Aggregating procurement information to parcipant level
{
	* 1: Participation data: Measure firms participates
	{
		use "${path_import}/Portal-03-participants_level-panel"  ,clear
		 
		* Keeping only Reverse Auction and FA
		* keep if substr(item_id,7,2) == "05"
		 
		* Getting extra information
		gen 	 year 		= real(substr(item_id,14,4))
		gen id_tender 		= substr(item_id,1,17)
		gen 	id_ug 		= substr(item_id,1,6)
 
		* Converting to numeric
		gegen id_ug_num 	= group(id_ug)
		gegen id_tender_num = group(id_tender)
		gegen item_id_num   = group(item_id)
		
		* N participants by item
		bys item_id_num: gen N_participants_item             =      _N

		* Filtering
		keep if inrange(year,2013,2022)
		keep if inlist(length(bidder_id), 14,12)	
		
		* Removing extra variables
		cap drop type_item
		cap drop item_2d_code
		cap drop item_5d_code
	
		tempfile to_merge
		save `to_merge'
		
		use item_id  type_item item_5d_code item_value using "${path_import}/Portal-02-item-panel",clear
			gduplicates drop item_id, force
	
		* Getting item code
		merge  1:m item_id using `to_merge', keep(3) nogen	
		
		* merge covid item
		merge m:1 type_item item_5d_code using "${path_project}/1_data/03-final/03-covid_item-item_level", ///
			keepusing(type_item item_5d_code  Covid_group_level Covid_item_level) nogen keep(3)	
		
		gen byte D_win_covid_product_high  = Covid_item_level==3 & D_winner ==1
		gen byte D_win_covid_product_med   = Covid_item_level==2 & D_winner ==1
		gen byte D_win_covid_product_low   = Covid_item_level==1 & D_winner ==1
		gen byte D_part_covid_product_high = Covid_item_level==3
		gen byte D_part_covid_product_med  = Covid_item_level==2
		gen byte D_part_covid_product_low  = Covid_item_level==1	 
		
		* Destring
		destring item_5d_code, replace force
		
		* Gettinng max
		bys bidder_id year item_5d_code: gen item_aux 		 = _N
		bys bidder_id year (item_aux):   gen main_item_5d 	 =      item_5d_code[_N]
		bys bidder_id year (item_aux):   gen main_type_item  =      type_item[_N]
		 
		* Keeping relevant vars
		keep bidder_id year id_ug_num id_tender_num item_id_num item_5d_code ///
			 main_item_5d  main_type_item N_participants_item item_value ///
			 D_*_covid_product* D_winner

		* Collapsing
 		gcollapse   (mean)      avg_competition      = N_participants_item  ///
								value_part_year   	 = item_value 			///
					(sum) 		bid_N_item_wins      = D_winner             ///
					(nunique) 	N_unique_ug_part 	 = id_ug_num 			///
								N_unique_tender_part = id_tender_num 		///
								N_unique_item5d_part = item_5d_code   		///	
					(max)       D_*_covid_product*							///
					(first) main_item_5d  main_type_item 		///
							,by(bidder_id year) freq(N_item_part)
	}
	.
	
	* 2: Participation data labels and formats
	{		
		*Adding label value
			label val main_type_item lab_type
		
		* Converting back to string
			tostring main_item_5d, format(%05.0f) replace
		
		* labeling
			label var N_item_part 			"N items participation"
 			label var N_unique_ug_part 		"N distinct UG participation"
			label var N_unique_tender_part 	"N distinct tender participation"
			label var N_unique_item5d_part 	"N distinct item 5d participation"
			label var main_item_5d		 	"Most frequent item 5d participation"
			label var main_type_item	 	"Most frequent type item participation"
			label var avg_competition		"avg N participants in bidders participations  by year"
			
			label var bidder_id			 	"id bidder"
			label var year			 		"year tender"
		
		* Formating
			format %3.2fc avg_competition
			format %12.0fc N_*	
		
		* Sort and saving
			sort year main_type_item  main_item_5d bidder_id
			order  bidder_id year main_type_item main_item_5d N_item_part    ///
				N_unique_tender_part N_unique_ug_part N_unique_item5d_part	avg_competition	
		
		* Labeling data
			label data "Bidders participation summary"
		
		* Compress and saving
			compress
			save "${path_datatemp}/P2_N_participant_bidder", replace
	}
	. 
	
	* 3 Classification firm
	{
		use "${path_import}/Portal-03-participants_level-panel",clear
		
		gcollapse (sum) bid_N_wins= D_winner, by(bidder_id)
		
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
	
	* 4: Set of firms that participate in others procurement process
	{
		use "${path_import}/Portal-03-participants_level-panel" if D_winner ==1 ,clear
		 
		* Keeping only Reverse Auction and FA
		keep if substr(item_id,7,2) != "05"
		 
		* Selecting sample
		keep bidder_id
		gduplicates drop bidder_id, force
		
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
		use "${path_rais}/02-Panel_rais_to_merge",clear		
		
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
		merge m:1 bidder_id using "${path_datatemp}/P2_list_treats", keep(1 3) nogen
		replace bid_sample = 3 if bid_sample==. 
		order cnpj8 bidder_id year bid_sample
		
		* Joing using bidder level procument data.
		merge 1:1 bidder_id  year using "${path_datatemp}/P2_N_participant_bidder", keep(1 3) nogen
	}
	.
	
	* 04: Removing others methods
	{
		merge m:1 bidder_id using "${path_datatemp}/P3_non_auction_list", gen(merge_non_auc) keep(1 3)
		
		gen byte D_filter_non_auction = merge_non_auc==3
			label var D_filter_non_auction "Non Auction methods"
		drop merge_non_auc
		
		tab   bid_sample D_filter_non_auction	
 	}
	.	
	
	* 05: Creating new variables
	{
		bys bidder_id (year): gen cummulated_win 	 = sum(bid_N_item_wins)
			label var cummulated_win "cummulated number of winners"
		
		cap drop D_firm_destruction
 		bys bidder_id (year): gen byte D_firm_destruction = year[_n+1]==. if year< 2021
			label var D_firm_destruction "dummy if it last year of firm"
		tab year D_firm_destruction 		
		
		cap drop D_firm_destruction_2021
		bys bidder_id (year): gen byte D_firm_destruction_2021 = year[_N]!=2021
			label var D_firm_destruction_2021 "dummy if it does not in 2021"
		tab year D_firm_destruction_2021 		
	}
	.	

	* 05: Ordering relevant variables
	{	
		* Keeping only the three groups
		keep if inlist(bid_sample,1,2,3)
			
		* Labeling data 
		label data "Rais panel restrict to ever bidded firms - 2013-2021"
	
		* Saving
		compress
		save "${path_final}/03-Firm_procurement_panel",replace
	}
	.
	
	* 06: Constant by last year obs)
	{
		use "${path_final}/03-Firm_procurement_panel",clear
		
		* Keeping
		keep bidder_id year bid_sample rais_great_sectors rais_uf_estab ///
			 rais_natureza_juridica rais_munic_estab rais_cnae20 rais_date_open_estab ///
			 D_firm_destruction_2021 rais_date_simples_start  rais_date_simples_end 
		
		* Keeping last obs
		bys bidder_id (year): keep if _n==_N
		drop year
		
		* Only relevant characteristics
		compress
		save "${path_final}/03-Firm_procurement_constant_characteristics", replace
	}
	.
}
.
