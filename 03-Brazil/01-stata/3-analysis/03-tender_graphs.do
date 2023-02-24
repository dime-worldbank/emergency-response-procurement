* Made by Leandro Veloso
* Main: Competitions - based on partipants data

* 0: Scatter options
{
	* graphs configuration
	global graph_option graphregion(color(white)) xsize(10) ysize(5)
	
	global xlabel "xlabel(`=yq(2018,1)'(2)`=yq(2022,2)', angle(90) nogrid)"
	
	global style_1_auction 		"connect(1)  lc(navy)  		mcolor(navy)    ms(oh)  lp(dash)"
	global style_2_waiver 		"connect(1)  lc(emerald) 	mcolor(emerald) ms(dh)  lp(dash)"
	global style_3_unenforce  	"connect(1)  lc(brown) 		mcolor(brown )  ms(th)  lp(dash)"
 
	global order_legend_g1  1 "Reverse Auction"  2 "Tender Waiver" 3 "Tender Unenforce"
	
	* Covid shadow
	global covid_shadow  /*
	 */	xline(`=yq(2020,2)' , lwidth(4.5) lc(gs14)) /* 
	 */	xline(`=yq(2021,2)' , lwidth(9) lc(gs14)) /*
	 */	xline(`=yq(2022,1)' , lwidth(2.25) lc(gs14)) /*
	 */	xline(`=yq(2022,2)' , lwidth(4.5) lc(gs14)) 		 
}
.

* 1: Tenders  month
{
	* reading
	use   "${path_project}/1_data/01-tender_data" if year_quarter >=`=yq(2018,1)',clear
 
	* Dropping
	drop if methods == 4
		
	* Collapsing by item
	gen N_tenders =1
	gen volume_covid = volume_tender*D_covid
	gcollapse (sum) N_tenders N_covid=D_covid volume_tender volume_covid, by(year_quarter methods )
	
	* Formating
	format %tq year_quarter
	
	* Graph 01: 1/N_bidders
	format %15.0fc N_tenders
 	 
	* Graph All class
	tw (scatter N_tenders  year_quarter if methods == 1 , ${style_1_auction}  ) ///
	|| (scatter N_tenders  year_quarter if methods == 2 , ${style_2_waiver}   ) ///
	|| (scatter N_tenders  year_quarter if methods == 3 , ${style_3_unenforce}) ///
 	, ${graph_option} legend(order(${order_legend_g1})  col(3))  		///
	xlabel(`=yq(2018,1)'(2)`=yq(2022,2)', angle(90))  ///
		ytitle("") ylabel( , angle(0))  ${covid_shadow} ///
		note("Other methods has less than 1% of tenders") title("Number of tenders process")
		
	* Graphing export
	graph export "${path_project}/4_outputs/3-Figures/01-overview-N_tender.png", replace as(png)
	graph export "${overleaf}/02_figures/P3-N_tenders-method.pdf", replace as(pdf)		
	
	* Graph All class
	tw (scatter N_covid  year_quarter if methods == 1	, ${style_1_auction}  ) ///
	|| (scatter N_covid  year_quarter if methods == 2 , ${style_2_waiver}   ) ///
	|| (scatter N_covid  year_quarter if methods == 3 , ${style_3_unenforce}) ///
 	, ${graph_option} ${xlabel} legend(order(${order_legend_g1})  col(3))  			///
		ytitle("") ylabel( , angle(0) nogrid)  ${covid_shadow} ///
		note("Other methods has less than 1% of tenders") title("Number Covid tenders tenders")		 
	graph export "${overleaf}/02_figures/P3-Covid_tender_n_tenders-method.pdf", replace as(pdf)		
	
	* Graph All class
	tw (scatter volume_tender  year_quarter if methods == 1	, ${style_1_auction}  ) ///
	|| (scatter volume_tender  year_quarter if methods == 2 , ${style_2_waiver}   ) ///
	|| (scatter volume_tender  year_quarter if methods == 3 , ${style_3_unenforce}) ///
 	, ${graph_option} ${xlabel} legend(order(${order_legend_g1})  col(3))  			///
		ytitle("") ylabel( , angle(0) nogrid)  ${covid_shadow} ///
		note("Other methods has less than 1% of tenders") title("Total estimated volume by tenders")		
		
	* Graphing export
	graph export "${path_project}/4_outputs/3-Figures/01-overview-N_tender-covid.png", replace as(png)
	graph export "${overleaf}/02_figures/P3-Covid_tender_Volume-method.pdf", replace as(pdf)		

}
.
 