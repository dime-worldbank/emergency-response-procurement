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
	 */	xline(`=ym(2020,7)' , lwidth(4.5) lc(gs14)) /* 
	 */	xline(`=ym(2021,5)' , lwidth(9) lc(gs14)) /*
	 */	xline(`=ym(2022,2)' , lwidth(2.25) lc(gs14)) /*
	 */	xline(`=ym(2022,7)' , lwidth(4.5) lc(gs14)) 		 
}
.

* 1: Competition - Restricting to autions
{
	* reading
	use id_item year_quarter year_month D_winner methods SME D_covid  using "${path_project}/1_data/03-participants_data" if year_month >=`=ym(2015,1)',clear
	
	* Keeping reverse auction/price registration
	keep if inlist(methods,1)
	
	
	preserve
		* Collapsing by item
		gcollapse (mean) avg_winner= D_winner , by(id_item D_covid year_month) freq(N_participants )
		
		* Collapsing by year quarter
		gcollapse (mean) avg_winner=avg_winner avg_bidders =N_participants, by(year_month D_covid)
		
		tempfile covid_data
		save `covid_data'
	restore
	
	* Collapsing by item
	gcollapse (mean) avg_winner= D_winner , by(id_item year_month) freq(N_participants )
	
	* Collapsing by year quarter
	gcollapse (mean) avg_winner=avg_winner avg_bidders =N_participants, by(year_month)

	gen byte D_covid = 10
	
	append using `covid_data'	
	
	* Formating
	format %tm year_month
	
	* Graph 1: Avg winner
	format %3.2fc avg_winner
	tw (scatter avg_winner  year_month if D_covid == 10	, ${style_1_auction}  ) ///
	|| (scatter avg_winner  year_month if D_covid == 0 , ${style_2_nocovid}   ) ///
	|| (scatter avg_winner  year_month if D_covid == 1 , ${style_3_covid}) ///
 	, ${graph_option} legend(order(${order_legend_g2})  col(3))  		///
	xlabel(`=ym(2015,2)'(2)`=ym(2022,6)', angle(90))  ///
		ytitle("winner proportion") ${covid_shadow} ///
		ylabel(0(0.05)0.50,angle(0)) ${covid_shadow}  ///
		note("Competition measure on item level data") title("Competition on action process")
			
	graph export "${path_project}/4_outputs/3-Figures/02-competition-avg_winner.png", replace as(png)

	
	* Graph 2: avg bidders
	format %4.0fc avg_bidders
	tw (scatter avg_bidders  year_month if D_covid == 10 , ${style_1_auction}  ) ///
	|| (scatter avg_bidders  year_month if D_covid == 0  , ${style_2_nocovid}   ) ///
	|| (scatter avg_bidders  year_month if D_covid == 1  , ${style_3_covid}) ///
 	, ${graph_option} legend(order(${order_legend_g2})  col(3))  		///
	xlabel(`=ym(2015,2)'(2)`=ym(2022,6)', angle(90))  ///
		ytitle("avg participants by item") ${covid_shadow} ///
		ylabel(5(2)17,angle(0)) ${covid_shadow}  ///
		note("Competition measure on item level data") title("Competition on action process")
			
	graph export "${path_project}/4_outputs/3-Figures/02-competition-avg_bidders.png", replace as(png)		
		
}
.


* Notes
{
 * 1- Competition is measure on item level 
}
.
