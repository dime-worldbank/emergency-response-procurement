* Made by Leandro Veloso
* Main: Preparing tender level data

* 1: Reading tender panel 
{
    * 1: Reading and creating relevant variables
	{
		* reading tender data
		use "${path_project}/1_data/01-import-data/Portal-01-tender-panel.dta",clear

		*Keeping only used variables
		keep  tender_id  year_month ug_id  tender_status  tender_objective tender_date_result tender_date_open
		order tender_id  year_month ug_id  tender_status  tender_objective   
		 
		* modality according to the code
		gen modality = substr(tender_id,7,2)
		tab modality

		* * Year month variable
		rename year_month aux
		gen year_month = ym(real(substr(aux,1,4)), real(substr(aux,5,2)))
			format %tm year_month
		drop aux
		
		* Checking 
		tab year_month

		* Quarter
		gen year         = year(dofm(year_month))
		gen year_quarter = yq(year,quarter(dofm(year_month)))
		format %tq year_quarter

		* Methods
		gen 	methods  = 1	if modality== "05" 
		replace methods  = 2	if modality== "06" 
		replace methods  = 3	if modality== "07" 
		replace methods  = 4	if methods	==.

		label define lab_method ///
			1 "01-auction" 	  ///
			2 "02-waiver" 	  ///
			3 "03-unenforce"  ///
			4 "04-others" ,replace

		label val methods lab_method
		
		* Tabulating 
		tab  year methods
	}
	.
	
	* 2: Covid tender variables
	{
		* Creating covid dummy tender
		gen D_covid = 	  regex(tender_objective,"(covid)([^8]*)(19)") ///
						| regex(tender_objective,"(sars)([^8]*)(cov)") ///
						| regex(tender_objective,"(926)([^0-9]*)(2020)") ///
						| regex(tender_objective,"(13)([^0-9]*)(979)") ///
						| regex(tender_objective,"coronavirus") 
						
		label var D_covid "Dummy for COVID tender"

		* Table year quarter
		tab year_quarter D_covid

		* Creating covid dummy tender
		gen D_law_926_2020 = regex(tender_objective,"(926)([^0-9]*)(2020)") ///
							| regex(tender_objective,"(13)([^0-9]*)(979)")  

		label var D_law_926_2020 "Dummy COVID emergence law 13.979"

		* Table year quarter
		tab year_quarter D_covid	
	}
	.
	
	* 3: Time variables
	{	    
		* Decisition time variable
		gen decision_time = tender_date_result - tender_date_open
			label var decision_time "time between open process and having a winner"
		gen decision_time_trim = tender_date_result - mdy(month(dofm(year_month)),1,year(dofm(year_month)))
			label var decision_time_trim "time between trim open process and having a winner"
	}
	.
	
	* 4: Ordering and saving tempdata
	{
		* tempfile to merge
 		compress
		save "${path_project}/4_outputs/1-data_temp/P01-tempdata-tender" ,replace
	}
	.
}
.

* 2: Getting extra information
{
	* Getting total volume in the item data
		use    "${path_project}/1_data/01-import-data/Portal-02-item-panel.dta",clear
		gcollapse (sum) volume_tender = item_value, by(tender_id)
			
		* Merging with tender temporary data of first step
		merge 1:1 tender_id  using "${path_project}/4_outputs/1-data_temp/P01-tempdata-tender", keep(3) nogen

	* Including location information 
		merge m:1 ug_id using  "${path_project}/1_data/01-import-data/Portal-04-buyer_data.dta", ///
			keep(3) nogen keepusing(ug_id ug_state ug_state_code ug_municipality_code )
}
.

* 3: Ordering, labeling and saving data
{
	* Labeling data
	label data  "Brazil tender data - 01/2013-12/2022"

	* Ordering
 	order year year_quarter year_month tender_id methods modality ug_id D_covid D_law_926_2020 ///
		  ug_state ug_state_code ug_municipality_code 	volume_tender 				 ///
		  tender_date_open tender_date_result decision_time decision_time_trim ///
		  tender_status	tender_objective 
	
	* Sorting
	sort  year year_quarter year_month ug_id
	
	* Formating
	format %16.0fc volume_tender 
	format tender_id  			 %17s 
	format ug_municipality_code  %-8s 
	
	* Including labels
	label var ug_state_code 		"manage unit state code"
	label var ug_municipality_code  "manage unit municipality code"

	* Saving
	compress
	save "${path_project}/1_data/03-final/01-tender_data",replace		
}
.
