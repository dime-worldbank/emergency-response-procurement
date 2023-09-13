* Made by Leandro
* Main: Establishment study

* 1- Table- data - preparation
{
	* 1: Reshaping the measures
	foreach year of numlist 2019/2021 {
	    global list_vars bidder_id year rais_N_workers rais_D_simples rais_N_hire  rais_N_fire   rais_avg_wage 
		
	    use $list_vars using "${path_project}/4_outputs/1-data_temp/Data_pre_collapse" if year== `year' , clear
		drop year
		
		gen byte D_exist_`year'= 1
		
		foreach var of varlist rais_N_workers rais_D_simples rais_N_hire  rais_N_fire   rais_avg_wage {
		    rename `var'  `var'_`year'
		}
		.
		
		save "${path_project}/4_outputs/1-data_temp/Data_temp_`year'",replace
	}
	.
	
	* 2: Calculating bid 
	{ 
		use  bidder_id   year N_item_part N_item_wins  using "${path_project}/1_data/03-final/03-Firm_procurement_panel" if inlist(year,2018,2019,2020), clear
		gcollapse (sum)  N_item_part N_item_wins , by(bidder_id)
		replace N_item_wins =0 if N_item_wins==.
		replace N_item_part =0 if N_item_part==.
		
		gen 	bid_sample_table = 1 if N_item_wins>=1
		replace bid_sample_table = 2 if N_item_wins==0 & N_item_part>=1 
		replace bid_sample_table = 3 if N_item_wins==0 & N_item_part==0 
		
		tab bid_sample_table, m
		keep bidder_id bid_sample_table
		
		save  "${path_project}/4_outputs/1-data_temp/P06-temp_sample_table", replace
	}
	
		
	* 4: Variables
	{
		use  "${path_project}/4_outputs/1-data_temp/P06-temp_sample_table", clear
		 
		merge 1:1 bidder_id using "${path_project}/4_outputs/1-data_temp/Data_temp_2020", keep(1 3) nogen
		merge 1:1 bidder_id using "${path_project}/4_outputs/1-data_temp/Data_temp_2021", keep(1 3) nogen
		
		gcollapse (mean) *2020 *2021, by(bid_sample_table) freq(N_bidders)
		
		drop D_exist*
		
		save "${path_project}/4_outputs/1-data_temp/P06-stat_rais",replace
	}
	.
}
.

* 2- Table export
{
    use "${path_project}/4_outputs/1-data_temp/P06-stat_rais",clear
	merge 1:1 bid_sample_table using  "${path_project}/4_outputs/1-data_temp/P06-stat_survival", nogen

	* Labeling
	label var rais_N_workers_2020  "Average Number of Workers in 2020"
	label var rais_N_hire_2020     "Average Number of Hires in 2020"
	label var rais_N_fire_2020     "Average Number of Separations in 2020"
	label var rais_avg_wage_2020   "Average Wage in 2020"
	label var rais_D_simples_2020  "Percentage of SMEs in 2020"                 

	label var rais_N_workers_2021  "Average Number of Workers in 2021"
	label var rais_N_hire_2021     "Average Number of Hires in 2021"
	label var rais_N_fire_2021     "Average Number of Separations in 2021"
	label var rais_avg_wage_2021   "Average Wage in 2021"
	label var rais_D_simples_2021  "Percentage of SMEs in 2021"                 

	label var N_bidders            	 "Number of Distinct Establishments in 2018, 2019, and 2020"

		
		
	* 4: Exporting to latex
	{	
		* Block 1 2021
			rename rais_N_workers_2020 block2020_1
			rename rais_N_hire_2020    block2020_2
			rename rais_N_fire_2020    block2020_3
			rename rais_avg_wage_2020  block2020_4
			rename rais_D_simples_2020 block2020_5
		
		* Block 2 2020
			rename rais_N_workers_2021 block2021_1
			rename rais_N_hire_2021    block2021_2
			rename rais_N_fire_2021    block2021_3
			rename rais_avg_wage_2021  block2021_4
			rename rais_D_simples_2021 block2021_5
		
		* Block 3 Fims counting 
			rename N_bidders              blocksurv_1

		* Global to separate variables
		global set_1  block2020* 
		global set_2  block2021* 	
		global set_3  blocksurv*
		
		* Ordering variables in the table
		order bid_sample_table  block2020*  block2021* blocksurv*, alphabetic 
		
		* part 1 table		
		{ 
			eststo drop *
			eststo main_1: quietly estpost summarize $set_1  if bid_sample_table == 1 ,d
			eststo main_2: quietly estpost summarize $set_1  if bid_sample_table== 2 ,d
			eststo main_3: quietly estpost summarize $set_1  if bid_sample_table== 3 ,d
		
			esttab main_1 main_2  main_3   using 	///
				 "${path_project}/4_outputs/2-Tables/P06-firms_procurement.tex", ///
				cells("mean(fmt(%15.2fc))") mtitles("Winners" "Participants" "Never try") nonum ///
				label replace f booktabs brackets noobs gap ///
				starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
		}
		.
		
		* part 2 table		
		{ 
			eststo drop *
			eststo main_1: quietly estpost summarize $set_2  if bid_sample_table== 1 ,d
			eststo main_2: quietly estpost summarize $set_2  if bid_sample_table== 2 ,d
			eststo main_3: quietly estpost summarize $set_2  if bid_sample_table== 3 ,d
		
			esttab main_1 main_2  main_3   using 	///
				"${path_project}/4_outputs/2-Tables/P06-firms_procurement.tex", ///
				cells("mean(fmt(%15.2fc))") nomtitles nonum ///
				label append f booktabs brackets noobs gap ///
				starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
		}
		.		
		
		* part 3 table		
		{ 
			eststo drop *
			eststo main_1: quietly estpost summarize $set_3  if bid_sample_table== 1 ,d
			eststo main_2: quietly estpost summarize $set_3  if bid_sample_table== 2 ,d
			eststo main_3: quietly estpost summarize $set_3  if bid_sample_table== 3 ,d
		
			esttab main_1 main_2  main_3   using 	///
				"${path_project}/4_outputs/2-Tables/P06-firms_procurement.tex", ///
				cells("mean(fmt(%15.2fc))") nomtitles nonum ///
				label append f booktabs brackets noobs gap ///
				starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
		}
		. 
	}
	.
}
.

* 3- Survival table export existing
{
	use  bidder_id   year bid_sample_dinamic D_firm_exi*  using "${path_project}/1_data/03-final/03-Firm_procurement_panel" if inlist(year,2017, 2018,2019,2020), clear
	
	* Summarize death probab
	gcollapse (mean) propab_exist_2019_ = D_firm_exist_2019 ///
					 propab_exist_2020_ = D_firm_exist_2020 ///
					 propab_exist_2021_ = D_firm_exist_2021, by(bid_sample_dinamic year)  
	
	* Reshapping
	reshape wide propab_exist_2019_ propab_exist_2020_ propab_exist_2021_  , i(bid_sample_dinamic) j(year)

	* Labeling 
	label var propab_exist_2021_2020 "Survival Rate of 2020 Firms into 2021"
	label var propab_exist_2021_2019 "Survival Rate of 2019 Firms into 2021"
	label var propab_exist_2021_2018 "Survival Rate of 2018 Firms into 2021"
	label var propab_exist_2020_2019 "Survival Rate of 2019 Firms into 2020"
	label var propab_exist_2020_2018 "Survival Rate of 2018 Firms into 2020"
	label var propab_exist_2020_2017 "Survival Rate of 2017 Firms into 2020"
	label var propab_exist_2019_2017 "Survival Rate of 2017 Firms into 2019"	
	
	* Renaming
	rename propab_exist_2021_2020 blocksurv_2 
	rename propab_exist_2021_2019 blocksurv_3
	rename propab_exist_2021_2018 blocksurv_4
	rename propab_exist_2020_2019 blocksurv_5
	rename propab_exist_2020_2018 blocksurv_6
	rename propab_exist_2020_2017 blocksurv_7
	rename propab_exist_2019_2017 blocksurv_8
	
	* Global to separate variables 
	global set_3  blocksurv*
	
	* Ordering variables in the table
	order bid_sample_dinamic blocksurv*, alphabetic 
	
	* part 1 table		
	{ 
		eststo drop *
		eststo main_1: quietly estpost summarize $set_3  if bid_sample_dinamic == 1 ,d
		eststo main_2: quietly estpost summarize $set_3  if bid_sample_dinamic == 2 ,d
		eststo main_3: quietly estpost summarize $set_3  if bid_sample_dinamic == 3 ,d
	
		esttab main_1 main_2  main_3   using 	///
			 "${path_project}/4_outputs/2-Tables/P06-firms_procurement-survival.tex", ///
			cells("mean(fmt(%15.2fc))") mtitles("Winners" "Participants" "Never try") nonum ///
			label replace f booktabs brackets noobs gap ///
			starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
	}
	.
}	
.

* 4- Trends graph
{
	* Reading data
	use "${path_project}/1_data/04-index_data/P06_establishment_year-index-all", clear
	
	* Keeping
	keep if year>=2015
	
	* Keeping only relevant groups
	keep if inlist( group, "D_sample_win_covid", "D_sample_win_05", "D_sample_try_01", "D_sample_never_try_01" )
	
	* Renaming
	replace group = "sold covid products"    if group == "D_sample_win_covid"		
	replace group = "sold no-covid products" if group == "D_sample_win_05"			
	replace group = "try"					 if group == "D_sample_try_01" 		
	replace group = "never try-catchment"    if group == "D_sample_never_try_01" 

	* Keeping only relant variables
	keep if inlist(var_index,"D_firm_exist_2021", /// 
							 "F1_D_firm_exist"  , /// 
							 "rais_N_workers"   , /// 
							 "rais_D_simples"   , /// 
							 "rais_N_hire"      , /// 
							 "rais_N_fire"      , /// 
							 "rais_avg_wage"    , /// 
							 "log_N_emp"        , /// 
							 "log_wage" )

	* Labeling it
	{	
		replace bar_label = "Proportion of firms that exist in 2021"				if var_index == "D_firm_exist_2021"		
		
		replace bar_label = "Proportion of firms that exist in the next year"		if var_index == "F1_D_firm_exist"
		replace bar_label = "Average number of workers throughout year"             if var_index == "rais_N_workers" 
		replace bar_label = "Proportion of SME (proxy simples fiscal benefit)"		if var_index == "rais_D_simples"
		
		replace bar_label = "Average number of hires"								if var_index == "rais_N_hire"
		replace bar_label = "Average number of separations"							if var_index == "rais_N_fire"
		replace bar_label = "Average of salary"						    			if var_index == "rais_avg_wage"           
		replace bar_label = "Average of Logarithmic of number of workers"		    if var_index == "log_N_emp"  
		replace bar_label = "Average of Logarithmic of salary"	    				if var_index == "log_wage"   
	}
	
	drop sme	
	
	* Exporting to excel
	export excel "${path_project}/4_outputs/2-Tables/P06-table_trend_stats.xlsx", replace  firstrow(variables)
	
	* Temporary data
	save "${path_project}/4_outputs/1-data_temp/P06-table_trend_stats.dta" ,replace
	 	
	* Variables Create D_exist 
	global main_Vars D_firm_exist_2021 F1_D_firm_exist rais_N_workers rais_D_simples rais_N_hire  rais_N_fire   rais_avg_wage log_N_emp log_wage
	
	foreach var_box in $main_Vars {
		use "${path_project}/4_outputs/1-data_temp/P06-table_trend_stats.dta" , clear
		keep if inlist(var_index,"`var_box'")
 
 		* scatter
		local col_int 0.5
		tw	   (scatter   avg year if group=="sold covid products"   	, sort mcolor(maroon *`col_int') c(l) lcolor(maroon*`col_int')  lp(dash))   ///
			|| (scatter   avg year if group=="sold no-covid products"	, sort mcolor(orange *`col_int') c(l) lcolor(orange*`col_int')  lp(dash))   ///
			|| (scatter   avg year if group=="try"					    , sort mcolor(navy   *`col_int') c(l) lcolor(navy   *`col_int') lp(dash))   ///
			|| (scatter   avg year if group=="never try-catchment"    	, sort mcolor(emerald*`col_int') c(l) lcolor(emerald*`col_int') lp(dash))   ///
			, legend(order(1 "sold covid products" 2 "sold no-covid products" 3 "try" 4 "never try-catchment") col(4))    											///
			title("`=bar_label[1]'", size(medium)) ytitle("") xtitle("")  xlabel(2015(1)2021)															///
			 graphregion(color(white)) xsize(10) ysize(5) ylabel(,angle(0) nogrid) 
		graph export  "${path_project}/4_outputs/3-Figures/P06-all-Covid-avg-`var_box'-no_ci.png", as(png) replace	
 
		* scatter
		local col_int 0.5
		tw	   (scatter   avg year 					if group=="sold covid products"   	, sort mcolor(maroon *`col_int') c(l) lcolor(maroon*`col_int')  lp(dash))   ///
			|| (scatter   avg year 					if group=="sold no-covid products"	, sort mcolor(orange *`col_int') c(l) lcolor(orange*`col_int')  lp(dash))   ///
			|| (scatter   avg year 					if group=="try"					    , sort mcolor(navy   *`col_int') c(l) lcolor(navy   *`col_int') lp(dash))   ///
			|| (scatter   avg year 					if group=="never try-catchment"    	, sort mcolor(emerald*`col_int') c(l) lcolor(emerald*`col_int') lp(dash))   ///
			|| (rarea     CI_hig CI_low year 		if group=="sold covid products"   	, color(maroon%10))   											///
			|| (rarea     CI_hig CI_low year 		if group=="sold no-covid products"	, color(orange%10))   											///
			|| (rarea     CI_hig CI_low year 		if group=="try"					    , color(navy%10))   											///
			|| (rarea     CI_hig CI_low year 		if group=="never try-catchment"    	, color(emerald%10))   											///
			, legend(order(1 "sold covid products" 2 "sold no-covid products" 3 "Try" 4 "Never Try-catchment") col(4))    											///
			title("`=bar_label[1]'", size(medium)) ytitle("") xtitle("")  xlabel(2015(1)2021)															///
			 graphregion(color(white)) xsize(10) ysize(5) ylabel(,angle(0) nogrid) 
			 
		graph export  "${path_project}/4_outputs/3-Figures/P06-all-Covid-avg-`var_box'.png", as(png) replace
 		
	}
	.	
}
.

* 5: Naive regressions
{  	   

	*global dep_vars  D_firm_exist_next_year F1_rais_avg_wage  F1_rais_N_fire F1_rais_N_hire F1_rais_N_workers
	
	
	global dep_vars  D_firm_exist  rais_avg_wage   rais_N_fire  rais_N_hire  rais_N_workers log_N_emp log_wage
	
	* Set of variables left hand side of regression
	global X1 "D_sample_win_01 D_sample_try_01 				,  vce(robust) noabsorb"
	global X2 "D_sample_win_01 D_sample_try_01 				,  vce(robust) absorb(rais_cnae20)" 
	global X3 "D_sample_win_01 D_sample_try_01 				,  vce(robust) absorb(rais_cnae20 rais_munic_estab)"
	global X4 "D_sample_win_01 D_sample_try_01 				,  vce(robust) absorb(rais_cnae20 rais_munic_estab rais_natureza_juridica )"
	global X5 "D_sample_win_01 D_sample_try_01 	if level_catch_01==1	,  vce(robust) absorb(rais_cnae20 rais_munic_estab rais_natureza_juridica )"
	global X6 "D_sample_win_01 D_sample_try_01 	if level_catch_02==1	,  vce(robust) absorb(rais_cnae20 rais_munic_estab rais_natureza_juridica )"
	
	* 
	global adds_1 	   "addtext(Level catchment, 0, Sector controls, No , Munic controls, No ,  Nature Firm controls, No ) e(all) label(insert)"
	global adds_2 	   "addtext(Level catchment, 0, Sector controls, Yes, Munic controls, No ,  Nature Firm controls, No ) e(all) label(insert)"
	global adds_3 	   "addtext(Level catchment, 0, Sector controls, Yes, Munic controls, Yes,  Nature Firm controls, No ) e(all) label(insert)"
	global adds_4 	   "addtext(Level catchment, 0, Sector controls, Yes, Munic controls, Yes,  Nature Firm controls, Yes) e(all) label(insert)"
	global adds_5 	   "addtext(Level catchment, 1, Sector controls, Yes, Munic controls, Yes,  Nature Firm controls, Yes) e(all) label(insert)"
	global adds_6 	   "addtext(Level catchment, 2, Sector controls, Yes, Munic controls, Yes,  Nature Firm controls, Yes) e(all) label(insert)"

	* Set of variables left hand side of regression
	global Xdid1 "D_sample_win_01_post D_sample_try_01_post D_sample_win_01 D_sample_try_01 							,  vce(robust) absorb(year)"
	global Xdid2 "D_sample_win_01_post D_sample_try_01_post D_sample_win_01 D_sample_try_01 							,  vce(robust) absorb(year rais_cnae20 )" 
	global Xdid3 "D_sample_win_01_post D_sample_try_01_post D_sample_win_01 D_sample_try_01 							,  vce(robust) absorb(year rais_cnae20 rais_munic_estab)"
	global Xdid4 "D_sample_win_01_post D_sample_try_01_post D_sample_win_01 D_sample_try_01 							,  vce(robust) absorb(year rais_cnae20 rais_munic_estab rais_natureza_juridica )"
	global Xdid5 "D_sample_win_01_post D_sample_try_01_post D_sample_win_01 D_sample_try_01 	if level_catch_01==1	,  vce(robust) absorb(year rais_cnae20 rais_munic_estab rais_natureza_juridica )"
	global Xdid6 "D_sample_win_01_post D_sample_try_01_post D_sample_win_01 D_sample_try_01 	if level_catch_02==1	,  vce(robust) absorb(year rais_cnae20 rais_munic_estab rais_natureza_juridica )"
	
	* Model 2020
	local replace "replace"
	foreach Y in $dep_vars {
		foreach k in 1 2 3 4 5 6 {
			di as white "Running model 2020: Y =`Y'; `k'"
			use  "${path_project}/4_outputs/1-data_temp/Data_pre_collapse" if year ==2020,clear
			reghdfe F1_`Y' ${X`k'}
			outreg2 using "${path_project}/4_outputs/2-Tables/P06-firm_models.xls", `replace'  ctitle(year:2020,robust, F1[`Y'] ) ${adds_`k'} 
			local replace "append"

			use  "${path_project}/4_outputs/1-data_temp/Data_pre_collapse" if year ==2019,clear
			reghdfe F1_`Y'  ${X`k'}
			outreg2 using "${path_project}/4_outputs/2-Tables/P06-firm_models.xls", append    	ctitle(year:2019,robust, F1[`Y']) ${adds_`k'} 				

			use  "${path_project}/4_outputs/1-data_temp/Data_pre_collapse" if year ==2018,clear
			reghdfe F1_`Y'  ${X`k'}
			outreg2 using "${path_project}/4_outputs/2-Tables/P06-firm_models.xls", append    	ctitle(year:2018,robust, F1[`Y']) ${adds_`k'} 
			
			use  "${path_project}/4_outputs/1-data_temp/Data_pre_collapse" if inlist(year,2018, 2020),clear
			reghdfe  F1_`Y'  ${X`k'}
			outreg2 using "${path_project}/4_outputs/2-Tables/P06-firm_models.xls", append   	ctitle(DiD,robust,`Y') ${adds_`k'} 
			
			use  "${path_project}/4_outputs/1-data_temp/Data_pre_collapse" if year ==2018,clear
			reghdfe `Y'_2021  ${X`k'}
			outreg2 using "${path_project}/4_outputs/2-Tables/P06-firm_models.xls", append    	ctitle(year:2018,robust,`Y'_2021) ${adds_`k'} 
			
			use  "${path_project}/4_outputs/1-data_temp/Data_pre_collapse" if year ==2019,clear
			reghdfe `Y'_2021  ${X`k'}
			outreg2 using "${path_project}/4_outputs/2-Tables/P06-firm_models.xls", append    	ctitle(year:2019,robust,`Y'_2021) ${adds_`k'} 							

		}
	}
	.	
}
.