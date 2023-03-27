* Made by Leandro Veloso
* Main: Competitions - based on partipants data

* 01: TWFE item level (DiD)
{
	use "${path_project}/1_data/05-Lot_item_data",clear
	keep if inrange(year_quarter,yq(2018,1),yq(2021,4))
 	
	* year
	gen byte items_treat = inlist(Covid_item_level ,3 )
		
	drop if inlist(Covid_item_level ,1,2)	
	
	keep if D_sample_item_balance==1
		
	global outcome D_new_winner SME share_SME decision_time decision_time_trim ///
				   unit_price value_item D_same_munic_win D_same_state_win ///
				   log_unit_price_filter  unit_price_filter N_participants ///
				   N_SME_participants months_since
	
	* Covid
	gen 	medical_product = 1 if item_2d_code == "65" & type_item==1
	replace medical_product = 3 if item_2d_code != "65" & type_item==1
	replace medical_product = 4 if item_2d_code != "65" & type_item==2
	
	* gcollapsing
	gcollapse (mean) $outcome (first)   medical_product type_item items_treat D_post , by(item_5d_code year_quarter)  labelformat(#sourcelabel#) 
	
	gen byte D_tread_post = D_post * items_treat
	
	* Cheking unique
	gunique  item_5d_code year_quarter
	
	* generate
	cap drop axis coef se all
	gen axis =.
	gen coef =.
	gen se   =.
	cap	gen byte all = 1
	
	* Overall
	foreach outcome of varlist $outcome  {
		
		* local outcome N_participants
		di as white "outcome=`outcome'"
 
		local k =0
		foreach var of varlist all type_item medical_product {
			levelsof `var', local(values_level)
			foreach values of local values_level {
				
				sum `outcome' if `var'==`values'
				loc outcome_avg: di %10.3fc r(mean)
				di as white "`var' = `values' ; AVG = `outcome_avg'"			
				
				local k = `k'+1
				
				count if `var'==`values' &  `outcome'!=.
				if r(N) >=100 { 
					reghdfe `outcome' D_tread_post  if `var'==`values', absorb(item_5d_code year_quarter)  	vce(robust)	
					 
					* txt option
					*global adds_txt  "addtext(E[dep var|sample],`outcome_avg',error,robust error)"
					*outreg2 using "${path}/7_output/1-estab/3-models/02-partners/01-sample_1-TWFE-`leader'.xls", `replace' ctitle(sample= `var'==`values' , Y=`outcome') ${adds_txt}
					*local replace "append"
				
					* Getting N of regression
					if "`var'" == "all" local N_obs: di %14.0fc e(N) 

					* Getting N of regression
					if "`var'" == "all" local geral_avg: di %14.2fc `outcome_avg'
					
					* Getting Coef				
					replace axis =`k' 				 if _n==`k'
					replace coef = _b[D_tread_post]  if _n==`k'
					replace se   = _se[D_tread_post] if _n==`k'
				}
			
			}
			.
		}
		.

		* Labeling axis
		{ 
			* Labeling Axis (inverted
			label define names  	///
			6  "All"	///
			5  "Goods"	///
			4  "Services"	///
			3  "Medical Goods"	///
			2  "Non-Medical Goods" 	///
			1  "Non-Medical Services"	/// 
			, replace	

			cap drop axis_2
			gen axis_2 = 7- axis
			label val axis_2 names	
		}
		.
			
		* Creating IC upper and lower
		cap drop IC_upper
		gen IC_upper =  coef+  1.96*se
		cap drop IC_lower
		gen IC_lower =  coef-  1.96*se
		
		* Title extracted from outcome label
		local title: var label   `outcome'
		
		* GAmbiarra ( faz o zero sempre aparecer)
		replace coef = 0 if _n==100
		 
		format %3.2fc coef
		* Graph of efects
		twoway 	(rcap 	IC_upper 	IC_lower	axis_2,lcolor(navy) lpattern(solid) horizontal ) || ///
				(scatter 					axis_2 coef,mcolor(cranberry) msymbol(circle ) ) ,legend(off)		///
		  note("IC = 95%, E[dep var] = `geral_avg', N obs =`N_obs'") graphregion(color(white))  ylabel(1/6, valuelabel angle(0) nogrid)  xtitle("TWFE-coeficient", size(small)) ///
		xline(0 , lcolor("red") ) xline( `=coef[1]' , lcolor("gs8") lp("dot")) yline(5.5 3.5 , lcolor("black") lp("dash"))	title("`title'", size(small)) ytitle("", size(small)) ///
		caption("TWFE heterogeneous effect}", size(small))
		
		graph export   "${overleaf}/02_figures/P5-TWFE-`outcome'.png", replace as(png)
	}
	.	
}
.
 
* 02: Multiple fixed effect
{
	* 1: reading data
	{
		use "${path_project}/1_data/05-Lot_item_data",clear
 		
		keep if D_sample_item_balance==1
		
		* year
		gen byte items_treat = inlist(Covid_item_level ,3 )
		gen byte D_tread_post = D_post * items_treat
	
						
		global outcome D_new_winner SME share_SME decision_time decision_time_trim ///
					   unit_price value_item D_same_munic_win D_same_state_win ///
					   log_unit_price_filter  unit_price_filter N_participants ///
					   N_SME_participants months_since
	}
	.
	
	* 2: Filtering
	{
		keep if inrange(year_quarter,yq(2018,1),yq(2021,4))
 
		drop if inlist(Covid_item_level ,1,2)		
		
		* panel
		gegen id_item_aux = group(item_5d_code type_item)
	}
	.
	
	keep if runiform()<=0.1
	
	* 3: Regressions on wage 
	foreach dep_var in share_SME decision_time D_new_winner D_same_state_win  log_unit_price_filter N_SME_participants {   		
		* Set of variables left hand side of regression
		global FE1 "D_tread_post items_treat	,  vce(robust) absorb(id_item_aux year_month)"
		global FE2 "D_tread_post items_treat    ,  vce(robust) absorb(id_item_aux year_month id_ug)" 
		global FE3 "D_tread_post items_treat    ,  vce(robust) absorb(id_item_aux year_month id_bidder)"
		global FE4 "D_tread_post items_treat    ,  vce(robust) absorb(id_item_aux year_month id_bidder id_ug)"		
		
		* Running regressions in a loop
		eststo drop *
		foreach k in 1 2 3 {
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
			
			* Maker if it has Buyer
			if regex("${FE`k'}","id_ug") 			estadd loc buyer_fe "\cmark"
			else						  			estadd loc buyer_fe "\xmark"
			
			* Maker if it has Seller
			if regex("${FE`k'}","id_bidder") 		estadd loc seller_fe "\cmark"
			else						  			estadd loc seller_fe "\xmark"
			
		}
		.

		* exporting
		esttab using "${overleaf}/01_tables/P5-TWFE-`dep_var'.tex", replace f booktabs se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) nomtitles ///
			   coeflabels(D_tread_post "`dep_var'")   keep(D_tread_post) ///
				   sfmt(%12.0fc %9.3fc %9.3fc ) ///
			   scalars("N Observations" "r2 R-Squared" "mean Dep. Var. mean "  "item_fe Item FE?" "ym_fe ym FE?"  "buyer_fe Buyer FE?" "seller_fe Seller FE?") ///
			   mgroups("TWFE levels" , ///
			   span prefix(\multicolumn{@span}{c}{) suffix(}) pattern(1 0 0 0) erepeat(\cmidrule(lr){@span})) 
	}
	.
}
.





* 02: Graph bar top products
{
	use "${path_project}/1_data/05-Lot_item_data",clear
	keep if inrange(year_quarter,yq(2018,1),yq(2021,4))
 	
	* year
	gen byte items_treat = inlist(Covid_item_level ,3 )
		
	drop if inlist(Covid_item_level ,1,2)	
		
	global outcome D_new_winner SME share_SME decision_time decision_time_trim ///
				   unit_price value_item D_same_munic_win D_same_state_win ///
				   log_unit_price_filter  unit_price_filter N_participants ///
				   N_SME_participants months_since
	
	* Covid
	gen 	medical_product = 1 if item_2d_code == "65" & type_item==1
	replace medical_product = 3 if item_2d_code != "65" & type_item==1
	replace medical_product = 4 if item_2d_code != "65" & type_item==2
	
	* gcollapsing
	gcollapse (mean) $outcome (first)   medical_product type_item items_treat D_post , by(item_5d_code year_quarter)  labelformat(#sourcelabel#) 
	
	gen byte D_tread_post = D_post * items_treat
	
	* Cheking unique
	gunique  item_5d_code year_quarter
	
	* generate
	cap drop axis coef se all
	gen axis =.
	gen coef =.
	gen se   =.
	cap	gen byte all = 1
	
	* Overall
	foreach outcome of varlist $outcome  {
		
		* local outcome N_participants
		di as white "outcome=`outcome'"
 
		local k =0
		foreach var of varlist all type_item medical_product {
			levelsof `var', local(values_level)
			foreach values of local values_level {
				
				sum `outcome' if `var'==`values'
				loc outcome_avg: di %10.3fc r(mean)
				di as white "`var' = `values' ; AVG = `outcome_avg'"			
				
				local k = `k'+1
				
				count if `var'==`values' &  `outcome'!=.
				if r(N) >=100 { 
					reghdfe `outcome' D_tread_post  if `var'==`values', absorb(item_5d_code year_quarter)  	vce(robust)	
					 
					* txt option
					*global adds_txt  "addtext(E[dep var|sample],`outcome_avg',error,robust error)"
					*outreg2 using "${path}/7_output/1-estab/3-models/02-partners/01-sample_1-TWFE-`leader'.xls", `replace' ctitle(sample= `var'==`values' , Y=`outcome') ${adds_txt}
					*local replace "append"
				
					* Getting N of regression
					if "`var'" == "all" local N_obs: di %14.0fc e(N) 

					* Getting N of regression
					if "`var'" == "all" local geral_avg: di %14.2fc `outcome_avg'
					
					* Getting Coef				
					replace axis =`k' 				 if _n==`k'
					replace coef = _b[D_tread_post]  if _n==`k'
					replace se   = _se[D_tread_post] if _n==`k'
				}
			
			}
			.
		}
		.

		* Labeling axis
		{ 
			* Labeling Axis (inverted
			label define names  	///
			6  "All"	///
			5  "Goods"	///
			4  "Services"	///
			3  "Medical Goods"	///
			2  "Non-Medical Goods" 	///
			1  "Non-Medical Services"	/// 
			, replace	

			cap drop axis_2
			gen axis_2 = 7- axis
			label val axis_2 names	
		}
		.
			
		* Creating IC upper and lower
		cap drop IC_upper
		gen IC_upper =  coef+  1.96*se
		cap drop IC_lower
		gen IC_lower =  coef-  1.96*se
		
		* Title extracted from outcome label
		local title: var label   `outcome'
		
		* GAmbiarra ( faz o zero sempre aparecer)
		replace coef = 0 if _n==100
		 
		format %3.2fc coef
		* Graph of efects
		twoway 	(rcap 	IC_upper 	IC_lower	axis_2,lcolor(navy) lpattern(solid) horizontal ) || ///
				(scatter 					axis_2 coef,mcolor(cranberry) msymbol(circle ) ) ,legend(off)		///
		  note("IC = 95%, E[dep var] = `geral_avg', N obs =`N_obs'") graphregion(color(white))  ylabel(1/6, valuelabel angle(0) nogrid)  xtitle("TWFE-coeficient", size(small)) ///
		xline(0 , lcolor("red") ) xline( `=coef[1]' , lcolor("gs8") lp("dot")) yline(5.5 3.5 , lcolor("black") lp("dash"))	title("`title'", size(small)) ytitle("", size(small)) ///
		caption("TWFE heterogeneous effect}", size(small))
		
		graph export   "${overleaf}/02_figures/P5-TWFE-`outcome'.png", replace as(png)
	}
	.	
}
.