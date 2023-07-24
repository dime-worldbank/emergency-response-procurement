* Made by Leandro Veloso
* Main: Competitions - based on partipants data

* 0: Scatter options
{
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
	
	* Graph All class
	tw (scatter N_covid  year_quarter if methods == 1	, ${style_1_auction}  ) ///
	|| (scatter N_covid  year_quarter if methods == 2 , ${style_2_waiver}   ) ///
	|| (scatter N_covid  year_quarter if methods == 3 , ${style_3_unenforce}) ///
 	, ${graph_option} legend(order(${order_legend_g1})  col(3))  		///
	xlabel(`=yq(2018,1)'(2)`=yq(2022,2)', angle(90))  ///
		ytitle("") ylabel( , angle(0))  ${covid_shadow} ///
		note("Other methods has less than 1% of tenders") title("Number Covid tenders tenders")		 
		
	* Graph All class
	tw (scatter volume_tender  year_quarter if methods == 1	, ${style_1_auction}  ) ///
	|| (scatter volume_tender  year_quarter if methods == 2 , ${style_2_waiver}   ) ///
	|| (scatter volume_tender  year_quarter if methods == 3 , ${style_3_unenforce}) ///
 	, ${graph_option} legend(order(${order_legend_g1})  col(3))  		///
	xlabel(`=yq(2018,1)'(2)`=yq(2022,2)', angle(90))  ///
		ytitle("") ylabel( , angle(0))  ${covid_shadow} ///
		note("Other methods has less than 1% of tenders") title("Number Covid tenders tenders")		
		
	* Graphing export
	graph export "${path_project}/4_outputs/3-Figures/01-overview-N_tender-covid.png", replace as(png)
}
.

* 2: Volume month
{
	* reading
	use  "${path_project}/1_data/05-winners_data" if year_month >=`=ym(2018,1)' ,clear
 
	* Dropping
	drop if methods == 4
		
	* Collapsing by item
	gen N_tenders =1
	gen value_covid_tender = value_item if D_covid == 1
	gcollapse (sum)  total = value_item  value_covid_tender , by(year_month methods  )
	
	format %tm year_month
	
	gen log10_total = log10(total)
	gen log10_total_covid = log10(value_covid_tender)
	
	* Graph 01: 1/N_bidders
	format %15.2fc log10_total*
 	 
	* Graph All class
	tw (scatter log10_total  year_month if methods == 1 , ${style_1_auction}  ) ///
	|| (scatter log10_total  year_month if methods == 2 , ${style_2_waiver}   ) ///
	|| (scatter log10_total  year_month if methods == 3 , ${style_3_unenforce}) ///
 	, ${graph_option} legend(order(${order_legend_g1})  col(3))  		///
	xlabel(`=ym(2018,1)'(2)`=ym(2022,6)', angle(90))  ///
		ytitle("") ylabel( , angle(0))  ${covid_shadow} ///
		note("Other methods has less than 1% of tenders") title("log 10(total volume estimated) ")
		
	* Graphing export
	graph export "${path_project}/4_outputs/3-Figures/01-overview-Volume_est.png", replace as(png)
	
		* Graph All class
	tw (scatter log10_total_covid  year_month if methods == 1 , ${style_1_auction}  ) ///
	|| (scatter log10_total_covid  year_month if methods == 2 , ${style_2_waiver}   ) ///
	|| (scatter log10_total_covid  year_month if methods == 3 , ${style_3_unenforce}) ///
 	, ${graph_option} legend(order(${order_legend_g1})  col(3))  		///
	xlabel(`=ym(2015,2)'(2)`=ym(2022,6)', angle(90))  ///
		ytitle("") ylabel( , angle(0))  ${covid_shadow} ///
		note("Other methods has less than 1% of tenders") title("COVID tender log 10(total volume estimated) ")
		
	* Graphing export
	graph export "${path_project}/4_outputs/3-Figures/01-overview-Volume_est-covid_tender.png", replace as(png)
}
.
 
* 3: COVID items
{
	* reading
	use  "${path_project}/1_data/05-winners_data" if year_month >=`=ym(2018,1)' ,clear
	 
	gcollapse (sum) total = value_item tot_qtd = qtd_item  , by(year_month Covid_item_level) freq(N_top)

	drop if year_month==.
	
	* Graph All class
	tw (scatter N_top  year_month , ${style_1_auction}  ) /// 
 	,  xlabel(`=ym(2015,1)'(2)`=ym(2022,6)', angle(90)) ///
	  graphregion(color(white)) xsize(10) ysize(5) xtitle("quater/year")   ///
		ytitle("") ylabel(, angle(0)) ${covid_shadow} ///
		note("Other methods has less than 1% of tenders") title("Covid lots")
	graph export "${path_project}/4_outputs/3-Figures/01-overview-coviditem-lots.png", replace as(png)	
	
	
	* Graph All class
	gen log_total10=log10(total)
	tw (scatter log_total10  year_month , ${style_1_auction}  ) /// 
 	,  xlabel(`=ym(2015,1)'(2)`=ym(2022,6)', angle(90)) ///
	  graphregion(color(white)) xsize(10) ysize(5) xtitle("quater/year")   ///
		ytitle("") ylabel(, angle(0)) ${covid_shadow} ///
		note("Other methods has less than 1% of tenders") title("Covid log 10(total volume estimated) ")
	* Graphing export
	graph export "${path_project}/4_outputs/3-Figures/01-overview-coviditem-volume.png", replace as(png)	
		
	
	* Graph All class
	gen log_tot_qtd10=log10(tot_qtd)
	tw (scatter log_tot_qtd10  year_month , ${style_1_auction}  ) /// 
 	,  xlabel(`=ym(2015,1)'(2)`=ym(2022,6)', angle(90)) ///
	  graphregion(color(white)) xsize(10) ysize(5) xtitle("quater/year")   ///
		ytitle("") ylabel(, angle(0)) ${covid_shadow} ///
		note("Other methods has less than 1% of tenders") title("Covid qtd ")
		
	* Graphing export
	graph export "${path_project}/4_outputs/3-Figures/01-overview-coviditem-qtd.png", replace as(png)
 
	
}
.

* Notes
{
 * 1- Competition is measure on item level 
}
.

