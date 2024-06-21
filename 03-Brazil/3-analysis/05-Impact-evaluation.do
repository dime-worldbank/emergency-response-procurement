* Made by Leandro Veloso
* Main: Competitions - based on partipants data
 
* 0 Setting
{
	global outcome_selected N_participants SME share_SME     ///
							D_auction decision_time_auction  ///
							D_new_winner_12 D_new_winner  /// 
							unit_price_filter_def log_unit_price_filter_def ///
							unit_price_filter log_unit_price_filter
		 		     				 
	* Outcome list	
	* global outcome N_participants  D_new_winner SME share_SME decision_time decision_time_trim 	///
	*	   unit_price log_volume_item D_same_munic_win D_same_state_win 						///
	*	   log_unit_price_filter  unit_price_filter  											///
	*	   N_SME_participants months_since_last_win D_auction HHI_5d sd_log_unit_price
		  		 
}
.

* 01: Data Sample regression
{
	use "${path_project}/1_data/03-final/05-Lot_item_data",clear
	keep if inrange(year_quarter,yq(2015,1),yq(2022,4))
	
	* year month
	gen year  = year(dofm(year_month))
	gen month = month(dofm(year_month))
	gen year_semester = yh(year ,ceil(month/6)) 
		format %th year_semester	
	
	* year
	gen byte items_treat = inlist(Covid_item_level ,3 )
		
	drop if inlist(Covid_item_level ,1,2)	
	
	* At least 50 purchases year
	keep if D_sample_item_balance==1

	* Covid
	gen 	medical_product = 1 if item_2d_code == 65 & type_item==1
	replace medical_product = 3 if item_2d_code != 65 & type_item==1
	replace medical_product = 4 if item_2d_code != 65 & type_item==2	
	
	gen byte D_tread_post = D_post * items_treat
				
	* panel
	gegen id_item_aux = group(item_5d_code type_item)
	
	* Sampling
	* keep if runiform()<=0.25
	gen log_volume_item = log(item_value)
	
	* Extra variables to regressions
	{ 
		* Total
		gegen total_volume_5d = sum(item_value)   , by(year_semester  type_item item_5d_code)
		gegen n_5d 			  = count(item_value) , by(year_semester  type_item item_5d_code)
		
		* 5 digits
		gen share_5d 			=  item_value/total_volume_5d
		
		gen HHI_5d 				=  n_5d*share_5d*share_5d	
		*replace HHI_5d = 1 	if HHI_5d>=1
		
		
		gegen X_barr = mean(log_unit_price_filter)  , by(year_semester  type_item item_5d_code)

		gen sd_log_unit_price = (log_unit_price_filter -X_barr)^2		
	}
	.

	
	* Adjusting labels
	label var N_participants		"Number of Participants"
	label var N_SME_participants	"Number of Participants SME" 
	label var SME					"Proportion of SME Winners"
	label var log_volume_item		"log(volume item)"
	label var unit_price		 	"Unit Price - filter"
	label var unit_price_filter 	"Unit Price - filter"
	label var log_unit_price_filter "log(Unit Price - filter)"
	
	label var HHI_5d				"HHI item index by year semester"
	label var D_auction				"Proportion of reverse auction method"
	label var sd_log_unit_price			"var(log(Unit Price - filter))"
	label_function
	
	compress
	save "${path_project}/1_data/03-final/05-Regession_data-sample", replace
}
.

* 02: Plotting average graph trend
{
 	use "${path_project}/1_data/03-final/05-Regession_data-sample", clear
	
	gcollapse (mean) ${outcome_selected}, by(year_semester Covid_item_level) labelformat(#sourcelabel#) fast freq(n)
	
	label_function
	
	global High_covid_scatter_opt	connect(l) sort mcolor("98 190 121")   lcolor("98 190 121")  lp(solid)
	global No_covid_scatter_opt 	connect(l) sort mcolor("233 149 144")  lcolor("233 149 144") lp(dash)

	* graphs configuration
	global opt_semester xlabel(`=yh(2015,1)'(1)`=yh(2022,2)', angle(90))  /*
		*/ graphregion(color(white)) xsize(10) ysize(5) ylabel(, angle(0) nogrid) /*
		*/  title("")  xline(`=yh(2019,2)+0.5' ,  lc(gs8) lp(dash))
		
	* Covid shadow
	global covid_shadow_semmester /*
	*/	xline(`=yh(2020,2)' , lwidth(4.5)  lc(gs14))  /* 
	*/	xline(`=yh(2021,2)' , lwidth(9)    lc(gs14))    /*
	*/	xline(`=yh(2022,1)' , lwidth(2.25) lc(gs14)) /*
	*/	xline(`=yh(2022,2)' , lwidth(4.5)  lc(gs14)) 	

 
	* Title
	*foreach y_dep of varlist $outcome { 
		foreach y_dep of varlist $outcome_selected { 
		
		* local y_dep decision_time_trim
		* Adjusting labels
		local title_graph: var label `y_dep'
  
		tw 		(scatter `y_dep'  year_semester if Covid_item_level == 3 , ${High_covid_scatter_opt}		) /// 
			|| 	(scatter `y_dep'  year_semester if Covid_item_level == 0 , ${No_covid_scatter_opt} 		) ///
			,  legend(order( 1 "Covid-related products" 2 "Non-Covid products")  col(2) margin(small) )   	  ///
			ytitle("`title_graph'", size(small)) ///
			${covid_shadow_semmester} ${opt_semester} 
		* sleep 2000
		
		graph export "${path_project}/4_outputs/3-Figures/P5-avg_graph_`y_dep'.png", replace as(png)
	}
	.
 }
.

* 03: TWFE item level (DiD)
{
	* Sampling data
	use "${path_project}/1_data/03-final/05-Regession_data-sample",clear

	* gcollapsing
	gcollapse (mean) $outcome (first)   medical_product type_item items_treat D_post D_tread_post Covid_group_level, ///
			by(id_item_aux year_semester)  labelformat(#sourcelabel#) 

	* Cheking unique
	gunique  id_item_aux year_semester
	
	* generate
	cap drop axis coef se all
	gen outcome   = ""
	gen label_out = ""
	gen N_obs = .
	gen avg  =.
	gen axis =.
	gen coef =.
	gen se   =.
	cap	gen byte all = 1
	
	* 
	local line = 0
	foreach outcome of varlist $outcome  {
		foreach k of numlist 1/10 {
			* Title extracted from outcome label
			local title: var label   `outcome'
			local line = `line' +1
			replace outcome   = "`outcome'"	    if _n==`line'
			replace label_out = "`title'"		if _n==`line'
			replace axis    = `k' 				if _n==`line'	
		}
	}
	.
	
	* Labeling axis
	{ 
		* Labeling Axis (inverted
		label define names  	///
	   10  "All"	///
		9  "Goods"	///
		8  "Services"	///
		7  "Medical Goods"	///
		6  "Non-Medical Goods" 	///
		5  "Non-Medical Services"	/// 
		4  "High-Covid-Group Goods"	///
		3  "Medium-Covid-Group Goods"	///
		2  "Low-Covid-Group Goods" 	///
		1  "No-Covid-Group Goods" 	/// 
		, replace	

		cap drop axis_2
		gen axis_2 = 11- axis
		label val axis_2 names	
	}
	.
 	 
 	* Overall
	foreach outcome of varlist $outcome  {
		* local outcome "D_new_winner"
		* local outcome N_participants
		di as white "outcome=`outcome'"
		
		local k =0
		foreach var of varlist all type_item medical_product Covid_group_level {		
			
			levelsof `var', local(values_level)
			foreach values of local values_level {
				
				sum `outcome' if `var'==`values'
				replace avg     = r(mean)  if outcome == "`outcome'" & axis==`k'
 
				di as white "`var' = `values' ; AVG = `outcome_avg'"			
				
				local k = `k'+1
				
				count if `var'==`values' &  `outcome'!=.
				if r(N) >=100 { 
					
					if "`var'" =="Covid_group_level" {
						reghdfe `outcome' D_tread_post if `var'==`values' &  `outcome'!=. & type_item==1, absorb(id_item_aux year_semester)  	vce(robust)	
					}
					
					if "`var'" !="Covid_group_level" {
						reghdfe `outcome' D_tread_post if  `var'==`values' &  `outcome'!=., absorb(id_item_aux year_semester)  	vce(robust)	
					}
					 
					* txt option
					*global adds_txt  "addtext(E[dep var|sample],`outcome_avg',error,robust error)"
					*outreg2 using "${path}/7_output/1-estab/3-models/02-partners/01-sample_1-TWFE-`leader'.xls", `replace' ctitle(sample= `var'==`values' , Y=`outcome') ${adds_txt}
					*local replace "append"
				  
					* Getting Coef
					replace N_obs   = `e(N)'  			if outcome == "`outcome'" & axis==`k'
					replace coef    = _b[D_tread_post]  if outcome == "`outcome'" & axis==`k'
					replace se      = _se[D_tread_post] if outcome == "`outcome'" & axis==`k'
				}
			
			} // foreach values
			.
 		} // foreach var
		.

	} // foreach outcome
	.
	
	
	keep outcome label_out axis axis_2 avg N_obs coef se 
		
	* Creating IC upper and lower
	cap drop IC_upper
	gen IC_upper =  coef+  1.96*se
	cap drop IC_lower
	gen IC_lower =  coef-  1.96*se
	keep if outcome !=""
	
	format %12.2fc  avg N_obs coef
	
	order outcome label_out axis axis_2 avg N_obs coef se  IC_upper IC_lower
	
	save "${path_project}/4_outputs/2-Tables/P5-TWFE-model.dta",replace
	
	* Graphing 
	foreach outcome in $outcome  {
 		use "${path_project}/4_outputs/2-Tables/P5-TWFE-model.dta",clear
		
		keep if outcome == "`outcome'"
		
		* Gambiarra ( faz o zero sempre aparecer)
		replace coef = 0 if _n==100
		 
		format %3.2fc coef
		* Graph of efects
		twoway 	(rcap 	IC_upper 	IC_lower	axis_2,lcolor(navy) lpattern(solid) horizontal ) || ///
				(scatter 						axis_2 coef,mcolor(cranberry) msymbol(circle ) ) ,legend(off)		///
			note("IC = 95%, E[dep var] = `=round(avg[1],0.01)', N obs =`=N_obs[1]'")  ///
			graphregion(color(white))  ylabel(1/10, valuelabel angle(0) nogrid)  xtitle("TWFE-coeficient", size(small)) ///
			xline(0 , lcolor("red") ) xline( `=coef[1]' , lcolor("gs8") lp("dot")) yline(9.5 7.5 4.5 , lcolor("black") lp("dash")) ///
			title("`=label_out[1]'", size(small)) ytitle("", size(small)) ///
			caption("TWFE heterogeneous effect}", size(small))
		
		graph export   "${path_project}/4_outputs/3-Figures/P5-TWFE-`outcome'.pdf", replace as(pdf)
	}
}
.
 
* 04: TWFE
{
	* Sampling data
	use "${path_project}/1_data/03-final/05-Regession_data-sample",clear
 
	* 3: Regressions on wage 
	foreach dep_var in  $outcome  	{ 
		* Set of variables left hand side of regression
 		global FE1 "D_tread_post  items_treat   ,  vce(robust) absorb(id_item_aux year_semester)"
		global FE2 "D_tread_post  items_treat   ,  vce(robust) absorb(id_item_aux year_semester month)"
		global FE3 "D_tread_post  items_treat   ,  vce(robust) absorb(id_item_aux year_semester month ug_id)" 
		global FE4 "D_tread_post  items_treat   ,  vce(robust) absorb(id_item_aux year_semester month bidder_id)"
		global FE5 "D_tread_post  items_treat   ,  vce(robust) absorb(id_item_aux year_semester month bidder_id ug_id)"		
 
		* Running regressions in a loop
		eststo drop *
		foreach k in 1 2 3 4 5 {
			* regression according X1, X2,... global
 			eststo: reghdfe `dep_var' ${FE`k'}
			
			* Average Y
			qui sum  `dep_var'
			estadd  scalar  r(mean)
			
			* Maker if it has item 5 d
			if regex("${FE`k'}","id_item_aux") 		estadd loc item_fe "\cmark"
			else						  	  		estadd loc item_fe "\xmark"

			* Maker if it has year_month
			if regex("${FE`k'}","year_month") 		estadd loc ym_fe 	"\cmark"
			else						  	 		estadd loc ym_fe 	"\xmark"
	
			* Maker if it has Month
			if regex("${FE`k'}","month") 			estadd loc month_fe "\cmark"
			else						  			estadd loc month_fe "\xmark"
			
			* Maker if it has Buyer
			if regex("${FE`k'}","ug_id") 			estadd loc buyer_fe "\cmark"
			else						  			estadd loc buyer_fe "\xmark"
			
			* Maker if it has Seller
			if regex("${FE`k'}","bidder_id") 		estadd loc seller_fe "\cmark"
			else						  			estadd loc seller_fe "\xmark"

			
		}
		.

		* exporting
		esttab using "${path_project}/4_outputs/2-Tables/P5-TWFE-`dep_var'.tex", replace f booktabs se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) nomtitles ///
			   coeflabels(D_tread_post "`dep_var'")   keep(D_tread_post) ///
				   sfmt(%12.0fc %9.3fc %9.3fc ) ///
			   scalars("N Observations" "r2 R-Squared" "mean Dep. Var. mean "  "item_fe Item FE?" "ym_fe ym FE?" "month_fe month FE?"  "buyer_fe Buyer FE?" "seller_fe Seller FE?") ///
			   mgroups("TWFE levels" , ///
			   span prefix(\multicolumn{@span}{c}{) suffix(}) pattern(1 0 0 0) erepeat(\cmidrule(lr){@span})) 
	}
	.
}
.

* 05: TWFE + time interaction
{
	* Sampling data
	use "${path_project}/1_data/03-final/05-Regession_data-sample",clear
  
	global list_iter  ""
	foreach year of numlist 2015/2022 { 
		foreach semester in 1 2 {
			gen byte Y`year's0`semester' = year_semester == yh(`year', `semester') *  (items_treat ==1)
			global list_iter  "${list_iter} Y`year's0`semester'"
		}
	}
	.
	 
	* Dropping
	local reference_value Y2015s01
	foreach reference_year in  `reference_value' { 
		global list_iter = subinstr("${list_iter}", "`reference_year'", "",1)
	}
	.
	
	* reghdfe N_SME_participants ${list_iter}  items_treat ,  vce(robust) absorb(id_item_aux year_semester)
	* coefplot, levels(95) keep( ${list_iter}) vertical  xlabel(,angle(90)) yline(0)  ///
	*  	graphregion(color(white)) xsize(10) ysize(5)  xline(9.5 ,  lc(gs8) lp(dash)) note("Reference-Y2015s01")
		
	* 3: Regressions on wage 
	foreach dep_var in $outcome_selected  {   	
				
		* Set of variables left hand side of regression
		global FE1 "${list_iter}  items_treat   ,  vce(robust) absorb(id_item_aux year_semester)"
		global FE2 "${list_iter}  items_treat   ,  vce(robust) absorb(id_item_aux year_semester month)" 
		global FE3 "${list_iter}  items_treat   ,  vce(robust) absorb(id_item_aux year_semester month ug_id)" 
		global FE4 "${list_iter}  items_treat   ,  vce(robust) absorb(id_item_aux year_semester month bidder_id)"
		global FE5 "${list_iter}  items_treat   ,  vce(robust) absorb(id_item_aux year_semester month bidder_id ug_id)"		
		
		* Running regressions in a loop
		eststo drop *
		foreach k in  3 { // 1 2 3 4 5 {
			
			* regression according X1, X2,... global
 			reghdfe `dep_var' ${FE`k'}			
			
			* Title 
 			local title_graph: var label `dep_var'					
			
			* Coeficient graph					
			coefplot, levels(95) keep( ${list_iter}) vertical  xlabel(,angle(90)) yline(0)  ///
			graphregion(color(white)) xsize(10) ysize(5)  xline(9.5 ,  lc(gs8) lp(dash)) note("Reference-Y2015s01") ///
			/*ytitle("`title_graph'", size(small))*/ ytitle("", size(small)) title("")
			 
			graph export "${path_project}/4_outputs/2-Tables/P05-TWFE-time-`dep_var'-FE`k'.png",replace as(png)
 		}
		. 
 	}
	.
}
.
