* Made by Leandro Veloso
* Main: Competitions - based on partipants data

* 0: Scatter options
{
	global style_1_auction 		"connect(1)  lc(navy)  		mcolor(navy)    ms(oh)  lp(solid)"
	global style_2_nocovid 		"connect(1)  lc(emerald) 	mcolor(emerald) ms(dh)  lp(dash)"
	global style_3_covid  		"connect(1)  lc(brown) 		mcolor(brown )  ms(th)  lp(dash)"
 
	global order_legend_g2  1 "Auction"  2 "Auction-NoCovid" 3 "Auction-Covid"
	
	* Covid shadow
	global covid_shadow  /*
	 */	xline(`=yq(2020,2)' , lwidth(4.5) lc(gs14)) /* 
	 */	xline(`=yq(2021,2)' , lwidth(9) lc(gs14)) /*
	 */	xline(`=yq(2022,1)' , lwidth(2.25) lc(gs14)) /*
	 */	xline(`=yq(2022,2)' , lwidth(4.5) lc(gs14)) 			 
}
.

* 1: Competition - Restricting to autions
{
	* Filter data
	local filter "inrange(year_quarter,yq(2018,1),yq(2022,4))" // filter 1 year
	* local filter "inrange(year_quarter,yq(2019,1),yq(2020,4))" // filter 2 year
	
	use "${path_project}/4_outputs/1-data_temp/Analysis_03-winner_data.dta",clear
	
	* Keeping reverse auction/price registration
	keep if inlist(methods,1) & type_item== "Product" 
	
	* Collapse
	gcollapse (sum)  volume = value_item  					///
			  (mean) avg_n_participants = N_participants 	///
					 avg_n_win_SME 		= SME, 				///
			  freq(N_lots ) 								///
			  by(year_quarter D_post Covid_item_level) 
 
	* Formating
	format %tq year_quarter
	
	* Graph 01: 1/N_bidders
	format %3.1fc avg_n_participants 
  
	* Graph All class
	tw (scatter avg_n_participants  year_quarter if Covid_item_level == 3 , connect(l) sort mcolor("98 190 121")   lcolor("98 190 121")  lp(solid)  ) ///
	|| (scatter avg_n_participants  year_quarter if Covid_item_level == 2 , connect(l) sort mcolor("180 182 26")   lcolor("180 182 26")  lp(solid)  ) ///
	|| (scatter avg_n_participants  year_quarter if Covid_item_level == 1 , connect(l) sort mcolor("104 172 32")   lcolor("104 172 32")  lp(solid)  ) ///
	|| (scatter avg_n_participants  year_quarter if Covid_item_level == 0 , connect(l) sort mcolor("233 149 144")  lcolor("233 149 144") lp(dash)  ) ///
 	, ${graph_option}  legend(order( 1 "High Covid" 2 "Medium Covid" 3 "low Covid" 4 "No Covid")  col(4))   		///
		xlabel(`=yq(2018,1)'(2)`=yq(2022,2)', angle(90))  ///
		ytitle("") ylabel( , angle(0) nogrid)  ${covid_shadow} ///
		title("Competition: Average number of participants") note("Restricted only to materials items using open methods")
 
	* Graph All class
	format %3.2fc avg_n_win_SME
	tw (scatter avg_n_win_SME  year_quarter if Covid_item_level == 3 , connect(l) sort mcolor("98 190 121")   lcolor("98 190 121")  lp(solid)  ) ///
	|| (scatter avg_n_win_SME  year_quarter if Covid_item_level == 2 , connect(l) sort mcolor("180 182 26")   lcolor("180 182 26")  lp(solid)  ) ///
	|| (scatter avg_n_win_SME  year_quarter if Covid_item_level == 1 , connect(l) sort mcolor("104 172 32")   lcolor("104 172 32")  lp(solid)  ) ///
	|| (scatter avg_n_win_SME  year_quarter if Covid_item_level == 0 , connect(l) sort mcolor("233 149 144")  lcolor("233 149 144") lp(dash)  ) ///
 	, ${graph_option}  legend(order( 1 "High Covid" 2 "Medium Covid" 3 "low Covid" 4 "No Covid")  col(4))   		///
		xlabel(`=yq(2018,1)'(2)`=yq(2022,2)', angle(90))  ///
		ytitle("") ylabel( , angle(0) nogrid)  ${covid_shadow} ///
		title("Competition: Proportion of SME winners") note("Restricted only to materials items using open methods")
	
}
.


* Notes
{
 * 1- Competition is measure on item level 
}
.
