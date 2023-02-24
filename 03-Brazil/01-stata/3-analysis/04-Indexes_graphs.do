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
				*/ title("")  xline(`=yh(2020,1)' ,  lc(gs8) lp(dash))
				
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
		format %10.2fc HHI_5d
			*  ${covid_shadow} 
		 
		* graphs configuration
		global opt_year xlabel(2015(1)2022 , angle(90))  /*
				*/ graphregion(color(white)) xsize(10) ysize(5) ylabel(0(0.1)0.6, angle(0) nogrid) /*
				*/ title("")  xline( 2020 ,  lc(gs8) lp(dash))
		
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
