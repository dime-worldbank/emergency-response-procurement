* Made by Leandro Veloso
* Main: Competitions - based on partipants data

* 0: Scatter options
{
	* Quarter
	{
	global xlabel "xlabel(`=yq(2015,1)'(2)`=yq(2022,2)', angle(90) nogrid)"
		
		global style_1_auction 		"connect(1)  lc(navy)  		mcolor(navy)    ms(oh)  lp(dash)"
		global style_2_waiver 		"connect(1)  lc(emerald) 	mcolor(emerald) ms(dh)  lp(dash)"
		global style_3_unenforce  	"connect(1)  lc(brown) 		mcolor(brown )  ms(th)  lp(dash)"
	 
		global order_legend_g1  1 "Reverse Auction"  2 "Direct purchase" 3 "Unenforceable Bidding"
 
		* Covid shadow
		global covid_shadow  /*
		 */	xline(`=yq(2020,2)' , lwidth(4.5) lc(gs14)) /* 
		 */	xline(`=yq(2021,2)' , lwidth(9) lc(gs14)) /*
		 */	xline(`=yq(2022,1)' , lwidth(2.25) lc(gs14)) /*
		 */	xline(`=yq(2022,2)' , lwidth(4.5) lc(gs14)) 		 
		 
		 * graphs configuration
		global graph_option graphregion(color(white)) xsize(10) ysize(5)  ///
			xlabel(`=yq(2018,1)'(1)`=yq(2022,4)', angle(90))  ///
			ylabel( , angle(0))  ${covid_shadow}  
	}
	
	* Semestre
	{
		* Covid shadow
		global covid_shadow_semmester /*
		 */	xline(`=yh(2020,2)' , lwidth(4.5)  lc(gs14))  /* 
		 */	xline(`=yh(2021,2)' , lwidth(9)    lc(gs14))    /*
		 */	xline(`=yh(2022,1)' , lwidth(2.25) lc(gs14)) /*
		 */	xline(`=yh(2022,2)' , lwidth(4.5)  lc(gs14)) 	
		 		 	 
		 * graphs configuration
		global graph_option_semester 							///
			graphregion(color(white)) xsize(10) ysize(5)  		///
			xlabel(`=yh(2015,1)'(1)`=yh(2022,2)', angle(90))  	///
			ylabel( , angle(0))  ${covid_shadow_semmester}  
			
	}
	 
}
.

* 1: Tenders  quarter
{
	* reading
	use   "${path_project}/1_data/03-final/01-tender_data" if year_quarter >=`=yq(2018,1)',clear
 
	* Dropping
	drop if methods == 4
		
	* Collapsing by item
	gen N_tenders =1
	replace volume_tender =. if volume_tender>=1e+11
	gen volume_covid = volume_tender*D_covid	

	gcollapse (sum) N_tenders N_covid=D_covid volume_tender volume_covid, by(year_quarter methods )
	
	tabstat N_covid, by(year_quarter) stat(sum)
	 
	* Formating
	format %tq year_quarter
	
	* Graph 01: 1/N_bidders
	format %15.0fc N_tenders
 	 
	* Graph All class
	tw (scatter N_tenders  year_quarter if methods == 1 , ${style_1_auction}  ) ///
	|| (scatter N_tenders  year_quarter if methods == 2 , ${style_2_waiver}   ) ///
	|| (scatter N_tenders  year_quarter if methods == 3 , ${style_3_unenforce}) ///
 	, ${graph_option}   legend(order(${order_legend_g1})  col(3) margin(small) )		///
	 note("Other methods has less than 1% of tenders") ytitle("Number of tenders process") ///
	  title("")
		
	* Graphing export
	graph export "${path_project}/4_outputs/3-Figures/P2-quarter-N_tenders-method.png", replace as(png)
 	
	* Graph All class
	tw (scatter N_covid  year_quarter if methods == 1 , ${style_1_auction}  ) ///
	|| (scatter N_covid  year_quarter if methods == 2 , ${style_2_waiver}   ) ///
	|| (scatter N_covid  year_quarter if methods == 3 , ${style_3_unenforce}) ///
 	, ${graph_option}  legend(order(${order_legend_g1})  col(3) margin(small)   ) ///
		note("Other methods has less than 1% of tenders") title("")		  ///
		ytitle("Number of Covid tenders")
		
	graph export "${path_project}/4_outputs/3-Figures/P2-quarter-Covid_tender_n_tenders-method.png", replace as(png)
	
	* Graph All class
	replace volume_tender =volume_tender / 1e6
	tw (scatter volume_tender  year_quarter if methods == 1	, ${style_1_auction}  ) ///
	|| (scatter volume_tender  year_quarter if methods == 2 , ${style_2_waiver}   ) ///
	|| (scatter volume_tender  year_quarter if methods == 3 , ${style_3_unenforce}) ///
 	, ${graph_option} ytitle("Millions reais (BRL)")  legend(order(${order_legend_g1})  col(3) margin(small) ) ///
		note("Other methods has less than 1% of tenders") title("Total estimated volume by tenders")		
		
	* Graphing export
	graph export "${path_project}/4_outputs/3-Figures/P2-quarter-Covid_tender_Volume-method.png", replace as(png)

}
.

* 2: Tenders - semester
{
	* reading
	use year_month volume_tender  D_covid methods using ///
		"${path_project}/1_data/03-final/01-tender_data" ,clear
	
	* year month
	gen year  = year(dofm(year_month))
	gen month = month(dofm(year_month))
	gen year_semester = yh(year ,ceil(month/6)) 
		format %th year_semester		
	
	keep if year_semester >= `=yh(2015,1)'
		
	* Dropping
	drop if methods == 4
		
	* Collapsing by item
	gen N_tenders =1
	replace volume_tender =. if volume_tender>=1e+11
	gen volume_covid = volume_tender*D_covid	

	gcollapse (sum) N_tenders N_covid=D_covid volume_tender volume_covid, ///
		by(year_semester methods )
	 
	* Graph 01: 1/N_bidders
	format %15.0fc N_tenders
 	 
	* Graph All class
	tw (scatter N_tenders  year_semester if methods == 1 , ${style_1_auction}  ) ///
	|| (scatter N_tenders  year_semester if methods == 2 , ${style_2_waiver}   ) ///
	|| (scatter N_tenders  year_semester if methods == 3 , ${style_3_unenforce}) ///
 	, ${graph_option_semester}   legend(order(${order_legend_g1})  col(3))		///
	 note("Other methods has less than 1% of tenders") title("Number of tenders process")
		
	* Graphing export
	graph export "${path_project}/4_outputs/3-Figures/P2-semester-N_tenders-method.pdf", replace as(pdf)
 	
	* Graph All class
	tw (scatter N_covid  year_semester if methods == 1 , ${style_1_auction}  ) ///
	|| (scatter N_covid  year_semester if methods == 2 , ${style_2_waiver}   ) ///
	|| (scatter N_covid  year_semester if methods == 3 , ${style_3_unenforce}) ///
 	, ${graph_option_semester}  legend(order(${order_legend_g1})  col(3)) ///
		note("Other methods has less than 1% of tenders") title("Number Covid tenders tenders")		 
		
	graph export "${path_project}/4_outputs/3-Figures/P2-semester-Covid_tender_n_tenders-method.pdf", replace as(pdf)
	
	* Graph All class
	replace volume_tender =volume_tender / 1e6
	format %12.0fc volume_tender
	tw (scatter volume_tender  year_semester if methods == 1 , ${style_1_auction}  ) ///
	|| (scatter volume_tender  year_semester if methods == 2 , ${style_2_waiver}   ) ///
	|| (scatter volume_tender  year_semester if methods == 3 , ${style_3_unenforce}) ///
 	, ${graph_option_semester} ytitle("Millions reais (BRL)")  legend(order(${order_legend_g1})  col(3)) ///
		note("Other methods has less than 1% of tenders") title("Total estimated volume by tenders")		
		
	* Graphing export
	graph export "${path_project}/4_outputs/3-Figures/P2-semester-Covid_tender_Volume-method.pdf", replace as(pdf)

}
.

* 3: lot/Tenders by covid product - quarter
{
	use  year_quarter Covid_item_level SME type_item item_value  ///
		using "${path_project}/1_data/03-final/05-Lot_item_data" ///
		if year_quarter >=`=yq(2015,1)',clear
		
	keep if type_item==1
		
	gen covid_product = inlist(Covid_item_level,1,2,3)
 	
	* replace item_value =. if item_value>=1e+7
	gcollapse (sum) volume_lot=item_value , by(year_quarter covid_product ) freq(N_lots)
		
	* scatter
		replace volume_lot =volume_lot / 1e6
		format %12.0fc volume_lot
		local col_int 0.5
		tw (scatter volume_lot  year_quarter if covid_product == 1 , sort mcolor(navy *`col_int'    ) c(l) lcolor(navy*`col_int'    )  lp(dash))  ///
		|| (scatter volume_lot  year_quarter if covid_product == 0 , sort mcolor(dkorange *`col_int') c(l) lcolor(dkorange*`col_int')  lp(dash))  ///
		, ${graph_option} ytitle("Millions reais (BRL)") legend(order(1 "covid product"  2 "no covid product" ) ) ///
		title("Estimated volume by lot/tender")	
		graph export "${path_project}/4_outputs/3-Figures/P2-quarter-Covid_item-Volume.pdf", replace as(pdf)
	
	* Graph All class
		local col_int 0.5
		tw (scatter N_lots  year_quarter if covid_product == 1 , sort mcolor(navy *`col_int'    ) c(l) lcolor(navy*`col_int'    )  lp(dash))  ///
		|| (scatter N_lots  year_quarter if covid_product == 0 , sort mcolor(dkorange *`col_int') c(l) lcolor(dkorange*`col_int')  lp(dash))  ///
		, ${graph_option} legend(order(1 "covid product"  2 "no covid product" ) ) ///
		title("Number of lot/tender")
	graph export "${path_project}/4_outputs/3-Figures/P2-quarter-Covid_item-freq.pdf", replace as(pdf)

	
}
.

* 4: lot/Tenders by covid product - semester
{
	use  year_month year_quarter Covid_item_level SME type_item item_value  ///
		using "${path_project}/1_data/03-final/05-Lot_item_data" ///
		if year_quarter >=`=yq(2015,1)',clear
	
	* year month
	gen year  = year(dofm(year_month))
	gen month = month(dofm(year_month))
	gen year_semester = yh(year ,ceil(month/6)) 
		format %th year_semester		
	
	keep if year_semester >= `=yh(2015,1)'
			
	keep if type_item==1
		
	gen covid_product = inlist(Covid_item_level,1,2,3)
 	
	* replace item_value =. if item_value>=1e+7
	gcollapse (sum) volume_lot=item_value , by(year_semester covid_product ) freq(N_lots)
		 
	* scatter
		replace volume_lot =volume_lot / 1e6
		format %12.0fc  volume_lot
		local col_int 0.5
		tw (scatter volume_lot  year_semester if covid_product == 1 , sort mcolor(navy *`col_int'    ) c(l) lcolor(navy*`col_int'    )  lp(dash))  ///
		|| (scatter volume_lot  year_semester if covid_product == 0 , sort mcolor(dkorange *`col_int') c(l) lcolor(dkorange*`col_int')  lp(dash))  ///
		, ${graph_option_semester}  legend(order(1 "covid product"  2 "no covid product" ) ) ///
		ytitle("Millions reais (BRL)") ///
		title("Estimated volume by lot/tender")	
		graph export "${path_project}/4_outputs/3-Figures/P2-semester-Covid_item-Volume.pdf", replace as(pdf)
	
	* Graph All class
		local col_int 0.5
		tw (scatter N_lots  year_semester if covid_product == 1 , sort mcolor(navy *`col_int'    ) c(l) lcolor(navy*`col_int'    )  lp(dash))  ///
		|| (scatter N_lots  year_semester if covid_product == 0 , sort mcolor(dkorange *`col_int') c(l) lcolor(dkorange*`col_int')  lp(dash))  ///
 	, ${graph_option_semester} legend(order(1 "covid product"  2 "no covid product" ) ) ///
		title("Number of lot/tender")
	graph export "${path_project}/4_outputs/3-Figures/P2-semester-Covid_item-freq.pdf", replace as(pdf)
}
.
