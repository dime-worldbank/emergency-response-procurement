* Made by Leandro Veloso
* Main: Competitions - based on partipants data

* 0: Scatter options
{
	global High_covid_scatter_opt	connect(l) sort mcolor("98 190 121")   lcolor("98 190 121")  lp(solid)
	global Medium_covid_scatter_opt connect(l) sort mcolor("104 172 32")   lcolor("104 172 32")  lp(dot)  
	global Low_covid_scatter_opt 	connect(l) sort mcolor("180 182 26")   lcolor("180 182 26")  lp(dot) 
	global No_covid_scatter_opt 	connect(l) sort mcolor("233 149 144")  lcolor("233 149 144") lp(dash)
	
	global order_legend_g2  1 "Auction"  2 "Auction-NoCovid" 3 "Auction-Covid"
	
	 * graphs configuration
	global graph_option graphregion(color(white)) xsize(10) ysize(5)  ///
		xlabel(`=yq(2018,1)'(1)`=yq(2022,4)', angle(90))  ///
		ytitle("") ylabel( , angle(0))  ${covid_shadow}  
 	
	* Covid shadow
	global covid_shadow  /*
	 */	xline(`=yq(2020,2)' , lwidth(4.5) 	lc(gs14)) /* 
	 */	xline(`=yq(2021,2)' , lwidth(9) 	lc(gs14)) /*
	 */	xline(`=yq(2022,1)' , lwidth(2.25) 	lc(gs14)) /*
	 */	xline(`=yq(2022,2)' , lwidth(4.5) 	lc(gs14)) /*
	 */ xline(`=yq(2020,1) - 0.5' , lc(gs9) 		lp(dash))
	 
	* Semestre
	{
		* Covid shadow
		global covid_shadow_semmester /*
		 */	xline(`=yh(2020,2)' , lwidth(4.5)  lc(gs14))  /* 
		 */	xline(`=yh(2021,2)' , lwidth(9)    lc(gs14))    /*
		 */	xline(`=yh(2022,1)' , lwidth(2.25) lc(gs14)) /*
		 */	xline(`=yh(2022,2)' , lwidth(4.5)  lc(gs14)) 	
		 		 	 
		 * graphs configuration
		global graph_option_semester 							///
			graphregion(color(white)) xsize(10) ysize(5)  		///
			xlabel(`=yh(2018,1)'(1)`=yh(2022,2)', angle(90))  	///
			ytitle("") ylabel( , angle(0))  ${covid_shadow_semmester}  
			
	} 
 
}
.

* 01: Tables products
{
	use "${path_project}/1_data/03-final/05-Lot_item_data",clear
	keep if inrange(year_quarter,yq(2019,1),yq(2020,4))
	
	* Covid items
	keep if type_item	== 1
	gen D_covid_product_selection = D_item_unit_price_sample	== 1 | ///
		inlist(item_5d_code ///
				, "00433" /// surgical mask 
				, "18189" /// ethyl alcohol 
				, "00406" /// hospital apron 
				, "13831" /// swab 
				, "14569" /// individual protection goggles
				)	
		 
	* Creating variables to  graph bar
	gen N_lots_post  = (D_post ==1)
	gen N_lots_pre   = (D_post ==0)
	
	gen volume_post = item_value if D_post ==1
	gen volume_pre  = item_value if D_post ==0
	
	* Summing up
	gcollapse (sum)  N_lots_* volume_* , ///
			  by(Covid_item_level item_2d_code item_2d_name_eng item_5d_code item_5d_name_eng D_covid_product_selection ) ///
			  labelformat(#sourcelabel#) 
  
	gsort -Covid_item_level -D_covid_product_selection -volume_post
 
	* Millions scale
	replace volume_pre  = volume_pre /1e6
	replace volume_post = volume_post/1e6
		
	label var  item_2d_code  	 "Item code 2 digits"
	label var  item_5d_code  	 "Item code 5 digits"
	label var  item_2d_name_eng  "Item name group-2 digits"
	label var  item_5d_name_eng  "Item name 5 digits"
 
	label var  N_lots_pre  "Number of lots 2019"		
	label var  volume_pre  "Contracting volume in Millions BRL - 2019"	
	label var  N_lots_post "Number of lots 2020"
	label var  volume_post "Contracting volume in Millions BRL - 2020"	
	
	* Oredering
	order Covid_item_level item_2d_code item_2d_name_eng item_5d_code item_5d_name_eng D_covid_product_selection ///
		  N_lots_pre volume_pre N_lots_post volume_post
	
	* Formating
	format %15.0fc N_lots* 
	format %15.2fc volume*
	
	* ordering
	export excel "${path_project}/4_outputs/2-Tables/P8-extra_outputs.xlsx", ///
	replace sheet("01-sample covid related") firstrow(varlabels)
}
.

* 02- Survival table export existing
{
	use  bidder_id   year bid_sample_dinamic D_firm_exi*  using "${path_firm_data}/03-Firm_procurement_panel" if inlist(year,2017, 2018,2019,2020), clear
	
	* Summarize death probab
	gcollapse (mean) propab_exist_2018_ = D_firm_exist_2018 ///
					 propab_exist_2019_ = D_firm_exist_2019 ///
					 propab_exist_2020_ = D_firm_exist_2020 ///
					 propab_exist_2021_ = D_firm_exist_2021, by(bid_sample_dinamic year)  
	
	* Reshapping
	reshape wide propab_exist_2018_ propab_exist_2019_ propab_exist_2020_ propab_exist_2021_  , i(bid_sample_dinamic) j(year)
	
	xpose, clear varname 
	
	gen variable =""
	replace variable = "2020 Firms into 2021" if _varname=="propab_exist_2021_2020"
	replace variable = "2019 Firms into 2020" if _varname=="propab_exist_2020_2019"
	replace variable = "2018 Firms into 2019" if _varname=="propab_exist_2019_2018"
	replace variable = "2017 Firms into 2018" if _varname=="propab_exist_2018_2017"
	replace variable = "2019 Firms into 2021" if _varname=="propab_exist_2021_2019"
	replace variable = "2018 Firms into 2020" if _varname=="propab_exist_2020_2018"
	replace variable = "2017 Firms into 2019" if _varname=="propab_exist_2019_2017"	
 
	gen order =.
	replace order = 1 if _varname=="propab_exist_2021_2020"
	replace order = 2 if _varname=="propab_exist_2020_2019"
	replace order = 3 if _varname=="propab_exist_2019_2018"
	replace order = 4 if _varname=="propab_exist_2018_2017"
	replace order = 5 if _varname=="propab_exist_2021_2019"
	replace order = 6 if _varname=="propab_exist_2020_2018"
	replace order = 7 if _varname=="propab_exist_2019_2017" 
	
	label var v1 "Winners"
	label var v2 "Participants"
	label var v3 "Never try"
	  
	
	sort order
	keep if variable !=""
	
	keep  variable v1 v2 v3
	order variable v1 v2 v3

 	* ordering
	export excel "${path_project}/4_outputs/2-Tables/P8-extra_outputs.xlsx", ///
	sheetmodify sheet("02-survival_probability") firstrow(varlabels)
}	
.

* 03: Tabulating average graph trend
{
	global outcome_selected N_participants SME share_SME  ///
							D_auction decision_time_auction decision_time_trim  ///
							D_new_winner_12 D_new_winner  /// 
							unit_price_filter_def log_unit_price_filter_def ///
							unit_price_filter log_unit_price_filter  
							
 	use "${path_project}/1_data/03-final/05-Regession_data-sample", clear
	
	gcollapse (mean) ${outcome_selected}, by(year_semester Covid_item_level) labelformat(#sourcelabel#) fast  
	 
	foreach y_dep of varlist $outcome_selected {
		local lab_`y_dep': var label  `y_dep'
		rename `y_dep' avg`y_dep'
	}
	
 
	reshape long avg, i(year_semester	Covid_item_level) j(variables) s
	
		
	gen label	= ""	
	foreach y_dep in $outcome_selected {
 		replace label = "`lab_`y_dep''" if variables =="`y_dep'"		
	}
	.
	
	order Covid_item_level 	variables label year_semester var
	sort variables  year_semester Covid_item_level
	
 	* ordering
	export excel "${path_project}/4_outputs/2-Tables/P8-extra_outputs.xlsx", ///
	sheetmodify sheet("03-avg_graph numbers") firstrow(varlabels)
}
.

* 04: graphs High covid vs low colid
{
	use "${path_project}/1_data/03-final/05-Lot_item_data",clear
	keep if inrange(year_quarter,yq(2017,1),yq(2022,4))
	
	* year month to semester
	gen year  = year(dofm(year_month))
	gen month = month(dofm(year_month))
	gen year_semester = yh(year ,ceil(month/6)) 
		format %th year_semester
	
	* Covid items
	keep if type_item	== 1
	 
	replace item_value =. if item_value>=1e+7
	
	global time year_semester
	
	* Summing up
	gcollapse (sum)  volume = item_value   /// 	 
			  (mean)  avg_volume = item_value,  ///
			  by(Covid_item_level year ${time}) ///  
			  labelformat(#sourcelabel#) freq(N_lots)
			  
	if "${time}" == "year_semester" { 
		gen aux_var = year_semester if year ==2019
		gen month = month(dofh(year_semester))
		gen rate_2019_lots = .
		
		bro Covid_item_level year_semester  aux_var rate_2019_lots month
		bys Covid_item_level (aux_var): replace rate_2019_lots    = ((N_lots-N_lots[1])/ N_lots[1]) if month<=6
		bys Covid_item_level (aux_var): replace rate_2019_lots    = ((N_lots-N_lots[2])/ N_lots[2]) if month>=7
		
		gen rate_2019_volume = .
		bys Covid_item_level (aux_var): replace rate_2019_volume    = ((volume-volume[1])/ volume[1]) if month<=6
		bys Covid_item_level (aux_var): replace rate_2019_volume    = ((volume-volume[2])/ volume[2]) if month>=7
 		
		bys Covid_item_level (year_semester): gen rate_lots_last_year    = ((N_lots-N_lots[_n-2])/ N_lots[_n-2])
		bys Covid_item_level (year_semester): gen rate_volume_last_year  = ((volume-volume[_n-2])/ volume[_n-2])
		
		 * graphs configuration
		global graph_option 							///
			graphregion(color(white)) xsize(10) ysize(5)  		///
			xlabel(`=yh(2018,1)'(1)`=yh(2022,2)', angle(90))  	///
			ytitle("") ylabel( , angle(0))  ${covid_shadow_semmester}  		
	} 
	if "${time}" == "year_quarter" { 
		bys Covid_item_level (year_quarter): gen rate_lots_last_year    = ((N_lots-N_lots[_n-4])/ N_lots[_n-4])
		bys Covid_item_level (year_quarter): gen rate_volume_last_year  = ((volume-volume[_n-4])/ volume[_n-4])
		
		 * graphs configuration
		global graph_option graphregion(color(white)) xsize(10) ysize(5)  ///
			xlabel(`=yq(2018,1)'(1)`=yq(2022,4)', angle(90))  ///
			ytitle("") ylabel( , angle(0))  ${covid_shadow}  
	} 
	. 
	
	* Dropping time before
	drop if year< 2018		
	
	* 01: Number of lots
	{  
		* Graph 01: 1/N_bidders
		format %15.0fc N_lots
	 
		tw (scatter N_lots  ${time} if Covid_item_level == 3 , ${High_covid_scatter_opt}  ) ///
		|| (scatter N_lots  ${time} if Covid_item_level == 0 , ${No_covid_scatter_opt}) ///
		, ${graph_option}   legend(order( 1 "Covid-related products" 2 "Non-Covid products")  col(2) margin(small) ) 		 
		// title("Rate increase - same semester of the previous year")	
		
		graph export "${path_project}/4_outputs/3-Figures/P8-${time}-n_lots_by_covid.png", replace as(png)
 
		gen log_N_lots = log(N_lots)
		tw (scatter log_N_lots  ${time} if Covid_item_level == 3 , ${High_covid_scatter_opt}  ) ///
		|| (scatter log_N_lots  ${time} if Covid_item_level == 0 , ${No_covid_scatter_opt}) ///
		, ${graph_option}   legend(order( 1 "Covid-related products" 2 "Non-Covid products")  col(2) margin(small) ) 		 
		// title("Rate increase - same semester of the previous year")	
		
		graph export "${path_project}/4_outputs/3-Figures/P8-${time}-log_n_lots_by_covid.png", replace as(png)	
		* Graph 01: 1/N_bidders
		format %15.0fc N_lots
		
		tw (scatter rate_lots_last_year  ${time} if Covid_item_level == 3 , ${High_covid_scatter_opt}  ) ///
		|| (scatter rate_lots_last_year  ${time} if Covid_item_level == 0 , ${No_covid_scatter_opt}) ///
		, ${graph_option}   legend(order( 1 "Covid-related products" 2 "Non-Covid products")  col(2) margin(small) ) 	yline(0, lp(dash) lc(gs2))	 
		// title("Rate increase - same semester of the previous year") 	w
		graph export "${path_project}/4_outputs/3-Figures/P8-${time}-rate_lots_by_covid.png", replace as(png)

	 
		tw (scatter rate_2019_lots  ${time} if Covid_item_level == 3 , ${High_covid_scatter_opt}  ) ///
		|| (scatter rate_2019_lots  ${time} if Covid_item_level == 0 , ${No_covid_scatter_opt}) ///
		, ${graph_option}   legend(order( 1 "Covid-related products" 2 "Non-Covid products")  col(2) margin(small) ) 	yline(0, lp(dash) lc(gs2))	 
		// title("Rate increase - same semester of the previous year") 	
		
		graph export "${path_project}/4_outputs/3-Figures/P8-${time}-rate_2019_lots_by_covid.png", replace as(png)

	}
	.
	
	* 02: Volume
	{ 	
		set obs `=_N+1'
		replace volume =0 if _n==_N
		
		* Log volume	
		replace volume =volume / 1e6
		tw (scatter volume  ${time} if Covid_item_level == 3 , ${High_covid_scatter_opt}  ) ///
		|| (scatter volume  ${time} if Covid_item_level == 0 , ${No_covid_scatter_opt}) ///
		, ${graph_option}   legend(order( 1 "Covid-related products" 2 "Non-Covid products")  col(2) margin(small) ) 		 ///
		 ytitle("Millions reais (BRL)")  
 
		graph export "${path_project}/4_outputs/3-Figures/P8-${time}-volume_by_covid.png", replace as(png)

		
		* Log volume
		gen log_volume = log(volume)
		tw (scatter log_volume  ${time} if Covid_item_level == 3 , ${High_covid_scatter_opt}  ) ///
		|| (scatter log_volume  ${time} if Covid_item_level == 0 , ${No_covid_scatter_opt}) ///
		, ${graph_option}   legend(order( 1 "Covid-related products" 2 "Non-Covid products")  col(2) margin(small) ) 		  	 	 
		 // title("Number of tenders process")
		* Graphing export
				graph export "${path_project}/4_outputs/3-Figures/P8-${time}-log_volume_by_covid.png", replace as(png)

	 
		* Rate volume increase
		tw (scatter rate_2019_volume  ${time} if Covid_item_level == 3 , ${High_covid_scatter_opt}  ) ///
		|| (scatter rate_2019_volume  ${time} if Covid_item_level == 0 , ${No_covid_scatter_opt}) ///
		, ${graph_option} legend(order( 1 "Covid-related products" 2 "Non-Covid products")  col(2) margin(small) ) 		  	 
		// title("Number of tenders process")
		* Graphing export
		graph export "${path_project}/4_outputs/3-Figures/P8-${time}-rate_2019_volume_by_covid.png", replace as(png)			
				
		* Rate volume increase
		tw (scatter rate_volume_last_year  ${time} if Covid_item_level == 3 , ${High_covid_scatter_opt}  ) ///
		|| (scatter rate_volume_last_year  ${time} if Covid_item_level == 0 , ${No_covid_scatter_opt}) ///
		, ${graph_option}legend(order( 1 "Covid-related products" 2 "Non-Covid products")  col(2) margin(small) ) 		  		 
		// title("Number of tenders process")
		* Graphing export
		graph export "${path_project}/4_outputs/3-Figures/P8-${time}-rate_volume_by_covid.png", replace as(png)
	}
	.
	
	* 03: Average item value
	{
		set obs `=_N+1'
		replace avg_volume =0 if _n==_N
		
		* Log volume	
 		tw (scatter avg_volume  ${time} if Covid_item_level == 3 , ${High_covid_scatter_opt}  ) ///
		|| (scatter avg_volume  ${time} if Covid_item_level == 0 , ${No_covid_scatter_opt}) ///
		, ${graph_option} legend(order( 1 "Covid-related products" 2 "Non-Covid products")  col(2) margin(small) ) 		 ///
		 ytitle("Average item volume in BRL")
			graph export "${path_project}/4_outputs/3-Figures/P8-${time}-avg_volume_by_covid.png", replace as(png)
 
		* Log volume
		gen log_avg_volume = log(avg_volume)
		tw (scatter log_avg_volume  ${time} if Covid_item_level == 3 , ${High_covid_scatter_opt}  ) ///
		|| (scatter log_avg_volume  ${time} if Covid_item_level == 0 , ${No_covid_scatter_opt}) ///
		, ${graph_option}  legend(order( 1 "Covid-related products" 2 "Non-Covid products")  col(2) margin(small) ) 		  
		 // title("Number of tenders process")
		* Graphing export
			graph export "${path_project}/4_outputs/3-Figures/P8-${time}-log_avg_volume_by_covid.png", replace as(png)
	}
	.
	
	* sending results to a table
 	export excel "${path_project}/4_outputs/2-Tables/P8-extra_outputs.xlsx", ///
	sheetmodify sheet("04-covid_volume") firstrow(variables)
	
}
.

* 05: Firm regressions
{  	   
	* 2: Defyining main groups
	{
		use  "${path_project}/4_outputs/1-data_temp/Data_pre_collapse" if year>=2017,clear
		
		keep bidder_id year rais_cnae20 rais_uf_estab F1_* *2021 log_N_emp   rais_N_workers level_catch_01 level_catch_02
		
		merge m:1 bidder_id year using "${path_project}/4_outputs/1-data_temp/P2_list_treats", ///
			keep(1 3) nogen keepusing(bidder_id year bid_sample_dinamic N_item_wins  N_item_part)
		replace bid_sample_dinamic = 3 if bid_sample_dinamic==.
		
		* Creating dummies
		gen byte D_sample_win_try 	=  inlist(bid_sample_dinamic,1,2) 
		gen byte D_sample_win 		=  bid_sample_dinamic ==1 
		gen byte D_sample_try 		=  bid_sample_dinamic ==2
		gen byte D_sample_never_try	=  bid_sample_dinamic ==3
		
		* Keeping only variables to regressions 
		order bidder_id year D_sample* rais_cnae20 rais_uf_estab  *D_firm_exist*  *rais_avg_wage*  *rais_N_workers* *log_N_emp* level_catch_01 level_catch_02
		keep bidder_id year  D_sample* rais_cnae20 rais_uf_estab  *D_firm_exist*  *rais_avg_wage*  *rais_N_workers* *log_N_emp* level_catch_01 level_catch_02
		
		compress
		save "${path_project}/4_outputs/1-data_temp/P08_data_firm_regression",replace
	}
	.
	
	* Setting parameters
	global dep_vars  D_firm_exist  rais_avg_wage  log_N_emp
    *global dep_vars  log_N_emp
	
	* Set of variables left hand side of regression
	global X1  "D_sample_win_try				 											,  vce(robust) noabsorb"
	global X2  "D_sample_win	D_sample_try 										    	,  vce(robust) noabsorb"
	global X3  "D_sample_win_try				 											,  vce(robust) absorb(rais_cnae20)"
	global X4  "D_sample_win	D_sample_try 										    	,  vce(robust) absorb(rais_cnae20)"
	global X5  "D_sample_win_try				 											,  vce(robust) absorb(rais_cnae20 rais_uf_estab)"
	global X6  "D_sample_win	D_sample_try 										    	,  vce(robust) absorb(rais_cnae20 rais_uf_estab)"
	global X7  "D_sample_win_try				log_N_emp 								,  vce(robust) absorb(rais_cnae20 rais_uf_estab)"
	global X8  "D_sample_win	D_sample_try 	log_N_emp								,  vce(robust) absorb(rais_cnae20 rais_uf_estab)"
	global X9  "D_sample_win_try				log_N_emp 		if level_catch_01==1	,  vce(robust) absorb(rais_cnae20 rais_uf_estab)"
	global X10 "D_sample_win	D_sample_try 	log_N_emp		if level_catch_01==1	,  vce(robust) absorb(rais_cnae20 rais_uf_estab)"
	global X11 "D_sample_win_try				log_N_emp 		if level_catch_02==1	,  vce(robust) absorb(rais_cnae20 rais_uf_estab)"
	global X12 "D_sample_win	D_sample_try 	log_N_emp		if level_catch_02==1	,  vce(robust) absorb(rais_cnae20 rais_uf_estab)"
 
	* 
	global adds_1 	   "addtext(Level catchment, 0, Sector controls, No , state controls, No ) e(all) label(insert)"
	global adds_2 	   "addtext(Level catchment, 0, Sector controls, No , state controls, No ) e(all) label(insert)"
	global adds_3 	   "addtext(Level catchment, 0, Sector controls, Yes, state controls, No ) e(all) label(insert)"
	global adds_4 	   "addtext(Level catchment, 0, Sector controls, Yes, state controls, No ) e(all) label(insert)"
	global adds_5 	   "addtext(Level catchment, 0, Sector controls, Yes, state controls, Yes) e(all) label(insert)"
	global adds_6 	   "addtext(Level catchment, 0, Sector controls, Yes, state controls, Yes) e(all) label(insert)"
	global adds_7	   "addtext(Level catchment, 0, Sector controls, Yes, state controls, Yes) e(all) label(insert)"
	global adds_8 	   "addtext(Level catchment, 0, Sector controls, Yes, state controls, Yes) e(all) label(insert)"
	global adds_9 	   "addtext(Level catchment, 1, Sector controls, Yes, state controls, Yes) e(all) label(insert)"
	global adds_10 	   "addtext(Level catchment, 1, Sector controls, Yes, state controls, Yes) e(all) label(insert)"
	global adds_11 	   "addtext(Level catchment, 2, Sector controls, Yes, state controls, Yes) e(all) label(insert)"
	global adds_12 	   "addtext(Level catchment, 2, Sector controls, Yes, state controls, Yes) e(all) label(insert)"

	* Model 2020
	local replace "replace"
	foreach Y in $dep_vars {
		foreach k in 1 2 3 4 5 6 7 8 9 10 11 12 {
		*foreach k in 1 2 3 4 5 6 7 8 {	
			
			* Outcomes 2021, data 2020 
			di as white "Running model 2020: Y =`Y'; `k'"
			use  "${path_project}/4_outputs/1-data_temp/P08_data_firm_regression" if year ==2020,clear
			reghdfe F1_`Y'  ${X`k'}
			outreg2 using "${path_project}/4_outputs/2-Tables/P08-firm_models.xls", `replace'  ctitle(year:2020,robust, F1[`Y'] ) ${adds_`k'} 
			local replace "append"

			* Outcomes 2020, data 2019
			use  "${path_project}/4_outputs/1-data_temp/P08_data_firm_regression" if year ==2019,clear
			reghdfe F1_`Y'  ${X`k'}
			outreg2 using "${path_project}/4_outputs/2-Tables/P08-firm_models.xls", append    	ctitle(year:2019,robust, F1[`Y']) ${adds_`k'} 				
			
			* Outcomes 2019, data 2018
			use  "${path_project}/4_outputs/1-data_temp/P08_data_firm_regression" if year ==2018,clear
			reghdfe F1_`Y'  ${X`k'}
			outreg2 using "${path_project}/4_outputs/2-Tables/P08-firm_models.xls", append    	ctitle(year:2018,robust, F1[`Y']) ${adds_`k'} 
			
			* Outcomes 2021, data 2019
			use  "${path_project}/4_outputs/1-data_temp/P08_data_firm_regression" if year ==2019,clear
			reghdfe `Y'_2021  ${X`k'}
			outreg2 using "${path_project}/4_outputs/2-Tables/P08-firm_models.xls", append    	ctitle(year:2019,robust,`Y'_2021) ${adds_`k'} 							

		}
	}
	.	
}
.
 