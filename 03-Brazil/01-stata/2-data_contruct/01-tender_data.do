* Made by Leandro Veloso
* Main: Participants data

* reading participants data
use "${path_KCP_BR}/1-data\2-imported/Portal-01-tender-panel.dta",clear

*Keeping
keep  id_bidding year_month purchase_method id_ug id_top_organ id_organ  bidding_status uf municipality bidding_object 
order id_bidding year_month purchase_method id_ug id_top_organ id_organ  bidding_status uf municipality bidding_object 

* modality
gen modality = substr(id_bidding,7,2)
tab modality

* Keeping auction + FA
*keep if modality=="05"
*drop modality 

* Quarter
gen year_quarter = yq(year(dofm(year_month)),quarter(dofm(year_month)))
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
	
* Creating covid dummy tender
gen D_covid = 	  regex(bidding_object,"(covid)([^8]*)(19)") ///
				| regex(bidding_object,"(sars)([^8]*)(cov)") ///
				| regex(bidding_object,"(926)([^0-9]*)(2020)") ///
				| regex(bidding_object,"(13)([^0-9]*)(979)") ///
				| regex(bidding_object,"coronavirus") 
				
				
label var D_covid "Dummy for COVID tender"

* Table year quarter
tab year_quarter D_covid

* Creating covid dummy tender
gen D_law_926_2020 = regex(bidding_object,"(926)([^0-9]*)(2020)") ///
					| regex(bidding_object,"(13)([^0-9]*)(979)")  

label var D_law_926_2020 "Dummy COVID emergence law 13.979"

* tempfile to merge
tempfile merge_data
save `merge_data'

* Including value estimated
use  id_bidding  value_item using "${path_KCP_BR}/1-data\2-imported\Portal-02-item-panel",clear
gcollapse (sum) volume_tender = value_item, by(id_bidding)
	
merge 1:1 id_bidding  using `merge_data', keep(3) nogen
		
* Labeling data
label data  "Brazil tender data - 01/2013-06/2022"

* Ordering
order year_month id_bidding methods purchase_method volume_tender D_covid D_law_926_2020
sort  year_month id_bidding

* Saving
compress
save "${path_project}/1_data/01-tender_data",replace		

