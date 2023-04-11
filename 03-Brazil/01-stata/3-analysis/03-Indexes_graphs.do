* Made by Leandro Veloso
* Main: Competitions - based on partipants data

* 0: Scatter options
{
	global High_covid_scatter_opt	connect(l) sort mcolor("98 190 121")   lcolor("98 190 121")  lp(solid)
	global Medium_covid_scatter_opt connect(l) sort mcolor("104 172 32")   lcolor("104 172 32")  lp(dot)  
	global Low_covid_scatter_opt 	connect(l) sort mcolor("180 182 26")   lcolor("180 182 26")  lp(dot) 
	global No_covid_scatter_opt 	connect(l) sort mcolor("233 149 144")  lcolor("233 149 144") lp(dash)
	
	global order_legend_g2  1 "Auction"  2 "Auction-NoCovid" 3 "Auction-Covid"
	
	* Covid shadow
	global covid_shadow  /*
	 */	xline(`=yq(2020,2)' , lwidth(4.5) 	lc(gs14)) /* 
	 */	xline(`=yq(2021,2)' , lwidth(9) 	lc(gs14)) /*
	 */	xline(`=yq(2022,1)' , lwidth(2.25) 	lc(gs14)) /*
	 */	xline(`=yq(2022,2)' , lwidth(4.5) 	lc(gs14)) /*
	 */ xline(`=yq(2020,1) - 0.5' , lc(gs9) 		lp(dash))  
}
.

* 1: Competition Covid tenders - Restricting to autions
{
	* 1: Semester covid level
	{
		use "${path_project}/1_data/01-index_data/P07-semester-covid-level-index.dta",clear	
		
		keep if year_semester >= `=yh(2015,1)'
		
		* drop
		cap drop *covid*
		
		* graphs configuration
		global opt_semester xlabel(`=yh(2015,1)'(1)`=yh(2022,2)', angle(90))  /*
				*/ graphregion(color(white)) xsize(10) ysize(5) ylabel(, angle(0) nogrid) /*
				*/ title("")  xline(`=yh(2019,2)+0.5' ,  lc(gs8) lp(dash))
				
		* Covid shadow
		global covid_shadow_semmester /*
		 */	xline(`=yh(2020,2)' , lwidth(4.5)  lc(gs14))  /* 
		 */	xline(`=yh(2021,2)' , lwidth(9)    lc(gs14))    /*
		 */	xline(`=yh(2022,1)' , lwidth(2.25) lc(gs14)) /*
		 */	xline(`=yh(2022,2)' , lwidth(4.5)  lc(gs14)) 	
		
		global group_covid "Covid_item_level" 
		
		* Graph 01: 1/N_bidders
		format %15.2gc *S1_* *S2_* *S3_* *S4_* N_lots N_batches N_ug
		
		* Graph All class 
		foreach y_dep of varlist *S1_* *S2_* *S3_* *S4_* N_lots N_batches N_ug {
			* local y_dep avg_S3_decision_time
			* Preparing data
			if regex("`var'","S1_") | inlist("`var'", "N_lots", "N_batches", "N_ug") {
				label note_scatter "Sample 1: unrestricted sample"
			}
			if regex("`var'","S2_") label note_scatter "Sample 2: limited to purchases through reverse auction"
			if regex("`var'","S3_") label note_scatter "Sample 3: limited to materials"
			if regex("`var'","S4_") label note_scatter "Sample 4: limited to materials purchased solely through auction."

			* Plotting
			tw 		(scatter `y_dep'  year_semester if ${group_covid} == 3 , ${High_covid_scatter_opt}		) ///
				|| 	(scatter `y_dep'  year_semester if ${group_covid} == 2 , ${Medium_covid_scatter_opt} 	) ///
				||	(scatter `y_dep'  year_semester if ${group_covid} == 1 , ${Low_covid_scatter_opt} 		) ///
				|| 	(scatter `y_dep'  year_semester if ${group_covid} == 0 , ${No_covid_scatter_opt} 		) ///
				,  legend(order( 1 "High Covid" 2 "Medium Covid" 3 "low Covid" 4 "No Covid")  col(4))   	  ///
				note("`note_scatter'") ///
				${covid_shadow_semmester} ${opt_semester} 
		
			* exporing
			compress
			graph export "${overleaf}/02_figures/P3-Covid-`y_dep'.pdf", replace as(pdf)
		}
	}
	.
	
	* 2: Year covid level
	{
		use "${path_project}/1_data/01-index_data/P07-year-covid-level-index.dta",clear	
		
		keep if year >= 2015
		
		* Graph 01: 1/N_bidders
		format %15.2gc HHI_5d

		*  ${covid_shadow} 
		 
		* graphs configuration
		global opt_year xlabel(2015(1)2022 , angle(90))  /*
				*/ graphregion(color(white)) xsize(10) ysize(5) /*
				*/ title("")  xline( 2019.5 ,  lc(gs8) lp(dash))
		
		global group_covid "Covid_item_level" 
		
		foreach y_dep of varlist HHI_5d shannon_entropy_5d {
			* Preparing data
			if regex("`var'","S1_") | inlist("`var'", "N_lots", "N_batches", "N_ug", "HHI_5d", "shannon_entropy_5d") {
				label note_scatter "Sample 1: unrestricted sample"
			}
			if regex("`var'","S2_") label note_scatter "Sample 2: limited to purchases through reverse auction"
			if regex("`var'","S3_") label note_scatter "Sample 3: limited to materials"
			if regex("`var'","S4_") label note_scatter "Sample 4: limited to materials purchased solely through auction."

			* Plotting
			tw 		(scatter `y_dep'  year if ${group_covid} == 3 , ${High_covid_scatter_opt}		) ///
				|| 	(scatter `y_dep'  year if ${group_covid} == 2 , ${Medium_covid_scatter_opt} 	) ///
				||	(scatter `y_dep'  year if ${group_covid} == 1 , ${Low_covid_scatter_opt} 		) ///
				|| 	(scatter `y_dep'  year if ${group_covid} == 0 , ${No_covid_scatter_opt} 		) ///
				,  legend(order( 1 "High Covid" 2 "Medium Covid" 3 "low Covid" 4 "No Covid")  col(4))   	  ///
				note("`note_scatter'") ///
				 ${opt_year} 
			 	
			* exporing
			compress
			graph export "${overleaf}/02_figures/P3-Covid-`y_dep'.pdf", replace as(pdf)
		}
	}
	.
}
.

* 02: Graph trend stand
{
	use "${path_project}/1_data/05-Lot_item_data",clear
	keep if inrange(year_quarter,yq(2015,1),yq(2021,4))
	
	* Covid items
	keep if type_item	== 1
	keep if D_item_unit_price_sample	== 1

	* year month
	gen year  = year(dofm(year_month))
	gen month = month(dofm(year_month))
	gen year_semester = yh(year ,ceil(month/6)) 
		format %th year_semester	
 		
	gcollapse (mean) avg_price = unit_price_filter avg_log_price = log_unit_price_filter  ///
			   (sd)  sd_price  = unit_price_filter sd_log_price  = log_unit_price_filter  ///
			   , by(item_5d_code Covid_item_level year_semester)
	
	* Using price standardize by 2015
	bys item_5d_code (year_semester): gen std_price = (avg_price-avg_price[1])/sd_price[1]
	
	* Using price standardize by 2015
	bys item_5d_code (year_semester): gen std_log_price = (avg_log_price-avg_log_price[1])/sd_log_price[1]
	
	gcollapse (mean) std_price std_log_price , by(Covid_item_level year_semester)
	
	label var std_price "E[unit price standardize by 2015]"
	label var std_log_price "E[log(unit price standardize by 2015)]" 
 	
	* Graph 01: 1/N_bidders
	format %15.2gc std_price std_log_price
	
	* Graph All class 
	foreach y_dep of varlist  std_price std_log_price {
		
 		* Plotting
		tw 		(scatter `y_dep'  year_semester if ${group_covid} == 3 , ${High_covid_scatter_opt}		) ///
			|| 	(scatter `y_dep'  year_semester if ${group_covid} == 2 , ${Medium_covid_scatter_opt} 	) ///
			||	(scatter `y_dep'  year_semester if ${group_covid} == 1 , ${Low_covid_scatter_opt} 		) ///
			|| 	(scatter `y_dep'  year_semester if ${group_covid} == 0 , ${No_covid_scatter_opt} 		) ///
			,  legend(order( 1 "High Covid" 2 "Medium Covid" 3 "low Covid" 4 "No Covid")  col(4))   	  ///
			note("Sample of selected products") ///
			${covid_shadow_semmester} ${opt_semester} 
			
		* exporing
		compress
		graph export "${overleaf}/02_figures/P3-Covid-`y_dep'.pdf", replace as(pdf)
	}
	.
}
.
