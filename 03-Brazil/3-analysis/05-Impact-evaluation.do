* Made by Leandro Veloso
* Main: Competitions - based on partipants data
 
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
	
	* Adjusting labels
	label var SME					"Proportion of SME Winners"
	label var log_volume_item		"log(volume item)"
	label var unit_price		 	"Unit Price - filter"
	label var unit_price_filter 	"Unit Price - filter"
	label var log_unit_price_filter "log(Unit Price - filter)"
	
	* Outcome list	
	global outcome N_participants  D_new_winner SME share_SME decision_time decision_time_trim ///
		   unit_price log_volume_item D_same_munic_win D_same_state_win ///
		   log_unit_price_filter  unit_price_filter  ///
		   N_SME_participants months_since_last_win

	compress
	save "${path_project}/1_data/03-final/05-Regession_data-sample", replace
}
.

* 02: TWFE item level (DiD)
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
	gen axis =.
	gen coef =.
	gen se   =.
	cap	gen byte all = 1
	 
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
				loc outcome_avg: di %10.3fc r(mean)
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
				(scatter 						axis_2 coef,mcolor(cranberry) msymbol(circle ) ) ,legend(off)		///
		  note("IC = 95%, E[dep var] = `geral_avg', N obs =`N_obs'") graphregion(color(white))  ylabel(1/10, valuelabel angle(0) nogrid)  xtitle("TWFE-coeficient", size(small)) ///
		xline(0 , lcolor("red") ) xline( `=coef[1]' , lcolor("gs8") lp("dot")) yline(9.5 7.5 4.5 , lcolor("black") lp("dash"))	title("`title'", size(small)) ytitle("", size(small)) ///
		caption("TWFE heterogeneous effect}", size(small))
		
		graph export   "${overleaf}/02_figures/P5-TWFE-`outcome'.png", replace as(png)
	}
	.	
}
.
 
* 03: TWFE
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
		esttab using "${overleaf}/01_tables/P5-TWFE-`dep_var'.tex", replace f booktabs se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) nomtitles ///
			   coeflabels(D_tread_post "`dep_var'")   keep(D_tread_post) ///
				   sfmt(%12.0fc %9.3fc %9.3fc ) ///
			   scalars("N Observations" "r2 R-Squared" "mean Dep. Var. mean "  "item_fe Item FE?" "ym_fe ym FE?" "month_fe month FE?"  "buyer_fe Buyer FE?" "seller_fe Seller FE?") ///
			   mgroups("TWFE levels" , ///
			   span prefix(\multicolumn{@span}{c}{) suffix(}) pattern(1 0 0 0) erepeat(\cmidrule(lr){@span})) 
	}
	.
}
.

* 04: TWFE + time interaction
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
	foreach dep_var in $outcome  {   	
				
		* Set of variables left hand side of regression
		global FE1 "${list_iter}  items_treat   ,  vce(robust) absorb(id_item_aux year_semester)"
		global FE2 "${list_iter}  items_treat   ,  vce(robust) absorb(id_item_aux year_semester month)" 
		global FE3 "${list_iter}  items_treat   ,  vce(robust) absorb(id_item_aux year_semester month ug_id)" 
		global FE4 "${list_iter}  items_treat   ,  vce(robust) absorb(id_item_aux year_semester month bidder_id)"
		global FE5 "${list_iter}  items_treat   ,  vce(robust) absorb(id_item_aux year_semester month bidder_id ug_id)"		
		
		* Running regressions in a loop
		eststo drop *
		foreach k in 1 2 3 4 5 {
			
			* regression according X1, X2,... global
 			reghdfe `dep_var' ${FE`k'}			
			 
			* Title
			local title_coef: var label `dep_var'
			
			* Coeficient graph					
			coefplot, levels(95) keep( ${list_iter}) vertical  xlabel(,angle(90)) yline(0)  ///
			graphregion(color(white)) xsize(10) ysize(5)  xline(9.5 ,  lc(gs8) lp(dash)) note("Reference-Y2015s01") ///
			title("`title_coef'")
			
			graph export "${overleaf}/02_figures/P05-TWFE-time-`dep_var'-FE`k'.png",replace as(png)
 		}
		. 
 	}
	.
}
.
