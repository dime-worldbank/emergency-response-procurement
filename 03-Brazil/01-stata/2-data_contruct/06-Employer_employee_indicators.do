* Made by Leandro Veloso
* Main: Create data in the index level.

* 1: Reading and selecting variables
{
	 * use "${path_project}/1_data/03-final/03-Firm_procurement_panel",clear
	 use "${path_project}/1_data/03-final/03-Firm_procurement_panel_sample", clear
	 drop if year<=2014
	 
	* Extra historgram 
	gen log_N_emp = log(rais_N_workers)
		label var log_N_emp "log[Total workers]"
	gen log_wage  = log(rais_avg_wage)	
		label var log_wage "log[Average establishment salary]"
	 
	* Global main vars
	global main_Vars D_firm_exist   rais_N_workers rais_D_simples rais_N_hire  rais_N_fire   rais_avg_wage ///
					    log_N_emp log_wage  		

	keep bidder_id year rais_D_simples level_catch_01 level_catch_02 D_win_covid_product* bid_sample* ///
		 ${main_Vars} ///
		 rais_great_sectors rais_natureza_juridica rais_uf_estab rais_cnae20 rais_munic_estab 
		 
	* Creating panel
	gegen id_panel = group(bidder_id)
	tsset id_panel year
	 
	* Time variables
	foreach var in  $main_Vars {
		local label_aux:  var label `var'
		di as white "Time operation: `var'"
		* gen L1_`var' = L1.`var'
		*	label var L1_`var' "L1[`label_aux']"
		* gen L2_`var' = L2.`var'
		*	label var L2_`var' "L2[`label_aux']"
		gen F1_`var' = F1.`var'
			label var F1_`var' "F1[`label_aux']"
		*gen F2_`var' = F2.`var'		
		*	label var F2_`var' "L2[`label_aux']"
	}
	. 
	
	drop F1_D_firm_exist
	clonevar   F1_D_firm_exist = D_firm_exist
	replace D_firm_exist = L1.D_firm_exist
	foreach var in $main_Vars { 
		local label_aux:  var label `var'
  		bys bidder_id (year): gen `var'_2021 = `var'[_N] if year[_N]==2021
			label var `var'_2021 "[2021] `label_aux'"
	}
	.
	
	drop D_firm_exist_2021
	bys bidder_id (year): gen D_firm_exist_2021 =  year[_N]==2021
	
	global set_vars_to_measure ""
	foreach var in  $main_Vars { 
		* global set_vars_to_measure "${set_vars_to_measure} L2_`var' L1_`var' `var'  F1_`var' F2_`var'"
		 global set_vars_to_measure "${set_vars_to_measure} `var'  F1_`var' `var'_2021 "
	}
	.
	
	compress
}
.
 
* 2: Defyining main groups
{
	global sample bid_sample_dinamic 

	gen byte D_sample_win_01 =  ${sample} ==1 
	gen byte D_sample_win_02 =  ${sample} ==1 & D_win_covid_product_high==1
	gen byte D_sample_win_03 =  ${sample} ==1 & D_win_covid_product_high==0 & D_win_covid_product_med==1
	gen byte D_sample_win_04 =  ${sample} ==1 & D_win_covid_product_high==0 & D_win_covid_product_med==0 & D_win_covid_product_low ==1
	gen byte D_sample_win_05 =  ${sample} ==1 & D_win_covid_product_high==0 & D_win_covid_product_med==0 & D_win_covid_product_low ==0
	gen byte D_sample_win_covid =  ${sample} ==1 & D_win_covid_product_high==1 | D_win_covid_product_med==1  | D_win_covid_product_low ==1


	gen byte D_sample_try_01 =  ${sample} ==2
	gen byte D_sample_never_try_01 =  ${sample} ==3
	gen byte D_sample_never_try_02 =  ${sample} ==3 & level_catch_01==1
	gen byte D_sample_never_try_03 =  ${sample} ==3 & level_catch_02==1
	
	gen D_sample_win_01_post = D_sample_win_01 * (year==2020)
	gen D_sample_try_01_post = D_sample_try_01 * (year==2020)
	
	compress
	save "${path_project}/4_outputs/1-data_temp/Data_pre_collapse",replace
}
.

* 3: Collapsing measures: Average graphs
foreach sme in "1" "0" {
	foreach sample_data in 	D_sample_win_01 D_sample_win_02 D_sample_win_03 D_sample_win_04 D_sample_win_05  D_sample_win_covid ///
							D_sample_try_01 D_sample_never_try_01 D_sample_never_try_02 D_sample_never_try_03 {
		
*local sample_data D_sample_win_02
*local var_box D_firm_destruction 	
*local sme 			1
		* Reading filter data
		if "`sme'" == "1" {
			use "${path_project}/4_outputs/1-data_temp/Data_pre_collapse" ///
			if rais_D_simples ==1 & `sample_data'==1,clear
		}
		else {
			use "${path_project}/4_outputs/1-data_temp/Data_pre_collapse" ///
			if  `sample_data'==1,clear
		}
		
		save "${path_project}/4_outputs/1-data_temp/P06_Data_pre_collapse_filter",replace 
		
		foreach var_box in $set_vars_to_measure {	
			di as white "sample = `sample_data'; var = `var_box'; sme = `sme'"
			
			use "${path_project}/4_outputs/1-data_temp/P06_Data_pre_collapse_filter" if  !inlist(`var_box',.),clear

			
			local label_aux:  var label `var_box'
			if _N>0 { 
				* Agragagating year  and sample
				gcollapse (count) N_non_miss  = `var_box'  (mean) avg= `var_box' ///
							(sd)  sd = `var_box' , by(year)	freq(N_obs)
				
				gen var_index  	= "`var_box'"
				gen bar_label  	= "`label_aux'"
				gen group  		= "`sample_data'"
				gen sme 		= "`sme'"
				
				* Upper and lower bound
				gen CI_low = avg+ 1.96*sd/sqrt(N_non_miss)
				gen CI_hig = avg- 1.96*sd/sqrt(N_non_miss)			
		
				save "${path_project}/4_outputs/1-data_temp/P06_temp_`sample_data'_`var_box'_sme_`sme'",replace
			}	
		}
	}
}
.

* 4: Collapsing measures: Average graphs
foreach sme in "1" "0" {
	clear
	foreach sample_data in 	D_sample_win_01 D_sample_win_02 D_sample_win_03 D_sample_win_04 D_sample_win_05  D_sample_win_covid///
							D_sample_try_01 D_sample_never_try_01 D_sample_never_try_02 D_sample_never_try_03 {
		foreach var_box in $set_vars_to_measure {

			cap confirm file  "${path_project}/4_outputs/1-data_temp/P06_temp_`sample_data'_`var_box'_sme_`sme'.dta"
			
			di as white "sample = `sample_data'; var = `var_box'; sme = `sme'; Exist = `=_rc'"
			
			if _rc==0 {
				append using "${path_project}/4_outputs/1-data_temp/P06_temp_`sample_data'_`var_box'_sme_`sme'.dta"
			}

		}
	}
	.
 
	* formating
	format %12.0fc N_obs N_non_miss	
	format %12.2fc avg	sd	CI_low	CI_hig
	
	* ordering data
	order   var_index	bar_label year sme group N_obs	N_non_miss avg  sd	CI_low	CI_hig
 	
	* label data
	label data  "Yearly month index variables for employers vs procurement"
	
	* Saving
	compress
		
	if `sme' ==0 save "${path_project}/1_data/04-index_data/P06_establishment_year-index-all",replace
	if `sme' ==1 save "${path_project}/1_data/04-index_data/P06_establishment_year-index-sme",replace	
}
.

* 5: removing extra files
* rm "${path_project}/4_outputs/1-data_temp/Data_pre_collapse.dta"
rm "${path_project}/4_outputs/1-data_temp/P06_Data_pre_collapse_filter.dta"
* 4: Collapsing measures: Average graphs
foreach sme in "1" "0" {
	foreach sample_data in 	D_sample_win_01 D_sample_win_02 D_sample_win_03 D_sample_win_04 D_sample_win_05  D_sample_win_covid ///
							D_sample_try_01 D_sample_never_try_01 D_sample_never_try_02 D_sample_never_try_03 {
		foreach var_box in $set_vars_to_measure {

				cap rm using "${path_project}/4_outputs/1-data_temp/P06_temp_`sample_data'_`var_box'_sme_`sme'.dta"
		}
	}
	.
}
.