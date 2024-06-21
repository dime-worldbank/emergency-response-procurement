
			  
			  
	global High_covid_scatter_opt	connect(l) sort mcolor("98 190 121")   lcolor("98 190 121") 
	global No_covid_scatter_opt 	connect(l) sort mcolor("233 149 144")  lcolor("233 149 144") 
 
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

	

{ 
	use "${path_project}/1_data/03-final/05-Regession_data-sample",clear

	bys bidder year_month Covid_item_level: keep if _n==1
	gcollapse (sum)  N_winners_24    = D_new_winner  N_winners_12    =D_new_winner_12 ///
			  (mean) rate_winners_12 = D_new_winner  rate_winners_24= D_new_winner_12, by(Covid_item_level year_semester) freq(all_bidders)


	tw 	   (scatter rate_winners_12  year_semester if Covid_item_level == 3 , ${High_covid_scatter_opt} lp(solid)  ) ///
		|| (scatter rate_winners_24  year_semester if Covid_item_level == 3 , ${High_covid_scatter_opt}  	lp(dash) ) ///
		|| (scatter rate_winners_12  year_semester if Covid_item_level == 0 , ${No_covid_scatter_opt}	lp(solid) ) ///
		   (scatter rate_winners_24  year_semester if Covid_item_level == 0 , ${No_covid_scatter_opt}   lp(dash)) ///
	, ${opt_semester} $covid_shadow_semmester   legend(order(   1 "Covid-related products 12 months" 2 "Covid-related products 24 months" ///
										3 "Non-Covid products 12 months" 	 4 "Non-Covid products 24 months" )  col(2) margin(small) ) 		 
										
	// title("Rate increase - same semester of the previous year")	
	
	graph export "${path_project}/4_outputs/3-Figures/P5-avg_graph_new_winner-bidderlevel.png", replace as(png)

}
.

{ 
	use "${path_project}/1_data/03-final/05-Regession_data-sample",clear

	* bys bidder year_month Covid_item_level: keep if _n==1
	gcollapse (sum)  N_winners_24    = D_new_winner  N_winners_12    =D_new_winner_12 ///
			  (mean) rate_winners_12 = D_new_winner  rate_winners_24= D_new_winner_12, by(Covid_item_level year_semester) freq(all_bidders)

 
	tw 	   (scatter rate_winners_12  year_semester if Covid_item_level == 3 , ${High_covid_scatter_opt} lp(solid)  ) ///
		|| (scatter rate_winners_24  year_semester if Covid_item_level == 3 , ${High_covid_scatter_opt}  	lp(dash) ) ///
		|| (scatter rate_winners_12  year_semester if Covid_item_level == 0 , ${No_covid_scatter_opt}	lp(solid) ) ///
		   (scatter rate_winners_24  year_semester if Covid_item_level == 0 , ${No_covid_scatter_opt}   lp(dash)) ///
	, ${opt_semester} $covid_shadow_semmester   legend(order(   1 "Covid-related products 12 months" 2 "Covid-related products 24 months" ///
										3 "Non-Covid products 12 months" 	 4 "Non-Covid products 24 months" )  col(2) margin(small) ) 		 
											 
	graph export "${path_project}/4_outputs/3-Figures/P5-avg_graph_new_winner-lotlevel.png", replace as(png)
}
. 