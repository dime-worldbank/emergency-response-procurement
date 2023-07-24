* Made by Leandro Veloso
* Main: Competitions - based on partipants data

Chile
1- Shape of open tenders (N and value)
2- Share of covid items in a covid tender_covid
3- Share of medical items in a covid tender.
4- Try a diff-in-diff

* 0: Scatter options
{
	global style_1_auction 		"connect(1)  lc(navy)  		mcolor(navy)    ms(oh)  lp(solid)"
	global style_2_nocovid 		"connect(1)  lc(emerald) 	mcolor(emerald) ms(dh)  lp(dash)"
	global style_3_covid  		"connect(1)  lc(brown) 		mcolor(brown )  ms(th)  lp(dash)"
 
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
	* Filter data
	local filter "inrange(year_quarter,yq(2018,1),yq(2022,4))" // filter 1 year
	* local filter "inrange(year_quarter,yq(2019,1),yq(2020,4))" // filter 2 year
	
	use "${path_project}/4_outputs/1-data_temp/Analysis_03-winner_data.dta",clear
	
	* Keeping reverse auction/price registration
	keep if inlist(methods,1) & type_item== "Product" 
 
	gen share_SME = N_SME_participants/ N_participants
 
	* Collapse
	gcollapse (sum)  volume = value_item  	 			///
			  (mean) avg_n_participants = N_participants 	///
					 avg_n_sme_part 	= N_SME_participants ///
					 share_SME_win 		= SME 				///
					 share_SME,	///
			  freq(N_lots ) 								///
			  by(year_quarter D_post D_covid) 
 
	* Formating
	format %tq year_quarter
	
	label var avg_n_participants "Avg number of participants"
	label var avg_n_sme_part	 "Avg number of participants SME"
	label var share_SME_win		 "Proportion of SME winners"
	label var share_SME			 "Proportion of participants SME"
	
	
	* Graph 01: 1/N_bidders
	format %3.2fc avg_n_participants avg_n_sme_part avg_n_sme_part share_SME_win share_SME 
  
	* Graph All class
	* local y_dep avg_n_participants
	foreach y_dep of varlist avg_n_participants avg_n_sme_part share_SME_win share_SME {
		tw (scatter `y_dep'  year_quarter if D_covid == 1 , connect(l) sort mcolor("98 190 121")   lcolor("98 190 121")  lp(solid)  ) ///
		|| (scatter `y_dep'  year_quarter if D_covid == 0 , connect(l) sort mcolor("233 149 144")  lcolor("233 149 144") lp(dash)  ) ///
		, ${graph_option}  legend(order( 1 "Covid tender" 2 "regular tender" )  col(4))   		///
			xlabel(`=yq(2018,1)'(2)`=yq(2022,2)', angle(90))  		///
			ylabel(, angle(0) nogrid)  ${covid_shadow} 	///
			title("") note("") xtitle("Year-Quarter")	
		graph export "${overleaf}/02_figures/P4-comp-tender_covid-`y_dep'.pdf", replace as(pdf)
 	}
	.
}
.

* 2: Competition Covid Items - Restricting to autions
foreach group_covid in Covid_group_level Covid_item_level {
	* Filter data
	local filter "inrange(year_quarter,yq(2018,1),yq(2022,4))" // filter 1 year
	* local filter "inrange(year_quarter,yq(2019,1),yq(2020,4))" // filter 2 year
	
	use "${path_project}/4_outputs/1-data_temp/Analysis_03-winner_data.dta",clear
	
	* Keeping reverse auction/price registration
	keep if inlist(methods,1) & type_item== "Product" 
 
	gen share_SME = N_SME_participants/ N_participants
 
	* Collapse
	gcollapse (sum)  volume = value_item  	 			///
			  (mean) avg_n_participants = N_participants 	///
					 avg_n_sme_part 	= N_SME_participants ///
					 share_SME_win 		= SME 				///
					 share_SME,	///
			  freq(N_lots ) 								///
			  by(year_quarter D_post `group_covid') 
 
	* Formating
	format %tq year_quarter
	
	label var avg_n_participants "Avg number of participants"
	label var avg_n_sme_part	 "Avg number of participants SME"
	label var share_SME_win		 "Proportion of SME winners"
	label var share_SME			 "Proportion of participants SME"
	
	
	* Graph 01: 1/N_bidders
	format %3.2fc avg_n_participants avg_n_sme_part avg_n_sme_part share_SME_win share_SME 
  
	* Graph All class
	* local y_dep avg_n_participants
	foreach y_dep of varlist avg_n_participants avg_n_sme_part share_SME_win share_SME {
		tw (scatter `y_dep'  year_quarter if `group_covid' == 3 , connect(l) sort mcolor("98 190 121")   lcolor("98 190 121")  lp(solid)  ) ///
		|| (scatter `y_dep'  year_quarter if `group_covid' == 2 , connect(l) sort mcolor("104 172 32")   lcolor("104 172 32")  lp(dot)  msize(small) ) ///
		|| (scatter `y_dep'  year_quarter if `group_covid' == 1 , connect(l) sort mcolor("180 182 26")   lcolor("180 182 26")  lp(dot)  msize(small) ) ///
		|| (scatter `y_dep'  year_quarter if `group_covid' == 0 , connect(l) sort mcolor("233 149 144")  lcolor("233 149 144") lp(dash)  ) ///
		, ${graph_option}  legend(order( 1 "High Covid" 2 "Medium Covid" 3 "low Covid" 4 "No Covid")  col(4))   		///
			xlabel(`=yq(2018,1)'(2)`=yq(2022,2)', angle(90))  		///
			ylabel(, angle(0) nogrid)  ${covid_shadow} 	///
			title("") note("") xtitle("Year-Quarter")		
		graph export "${overleaf}/02_figures/P4-comp-`group_covid'-`y_dep'.pdf", replace as(pdf)
	}
	.
}
.

* 3: New firms
{

}

* 4: market Concentration top firms
foreach group_covid in Covid_group_level Covid_item_level {
	
	local group_covid Covid_group_level
	use "${path_project}/4_outputs/1-data_temp/Analysis_03-winner_data.dta",clear
	 
	* Keeping reverse auction/price registration
	keep if inlist(methods,1) & type_item== "Product" 
	
	global agreagation_level item_5d_code
	
	global top_X 3
	
	drop if value_item==. | value_item==0
	gcollapse (sum)  value_item  , by(id_bidder  year_quarter  ///
					item_5d_code  `group_covid' ) freq(N_winners)
	
	
	gegen total_volume = sum(value_item)  , by(item_5d_code year_quarter)
	
	gen share = value_item/total_volume
	
	gsort item_5d_code year_quarter -value_item
	by item_5d_code year_quarter  : gen share_top  = share if	_n<=${top_X}
 	
	gen shannon_entropy = -share*ln(share)
	
	gen HHI = share*share
	
	gcollapse (sum) share_top  shannon_entropy HHI, by(item_5d_code year_quarter `group_covid')
	
	* 
	gcollapse (mean) share_top  shannon_entropy HHI , by(year_quarter `group_covid' )	
	
	tw (scatter   HHI   year_quarter, connect(l 1 1) sort mcolor("98 190 121")   lcolor("98 190 121")  lp(solid)  ) ///
	, ${graph_option}  legend(order( 1 "Covid tender" 2 "regular tender" )  col(4))   		///
		xlabel(`=yq(2018,1)'(2)`=yq(2022,2)', angle(90))  		///
		ylabel(, angle(0) nogrid)  ${covid_shadow} 	///
		title("Share of top ${top_X} products ") note("") xtitle("Year-Quarter")	
 	 
	* Graph All class
	* local y_dep avg_n_participants
	foreach y_dep of varlist share_top  shannon_entropy HHI  {
		tw (scatter `y_dep'  year_quarter if `group_covid' == 3 , connect(l) sort mcolor("98 190 121")   lcolor("98 190 121")  lp(solid)  ) ///
		|| (scatter `y_dep'  year_quarter if `group_covid' == 2 , connect(l) sort mcolor("104 172 32")   lcolor("104 172 32")  lp(dot)  msize(small) ) ///
		|| (scatter `y_dep'  year_quarter if `group_covid' == 1 , connect(l) sort mcolor("180 182 26")   lcolor("180 182 26")  lp(dot)  msize(small) ) ///
		|| (scatter `y_dep'  year_quarter if `group_covid' == 0 , connect(l) sort mcolor("233 149 144")  lcolor("233 149 144") lp(dash)  ) ///
		, ${graph_option}  legend(order( 1 "High Covid" 2 "Medium Covid" 3 "low Covid" 4 "No Covid")  col(4))   		///
			xlabel(`=yq(2018,1)'(2)`=yq(2022,2)', angle(90))  		///
			ylabel(, angle(0) nogrid)  ${covid_shadow} 	///
			title("") note("") xtitle("Year-Quarter")		
		graph export "${overleaf}/02_figures/P4-mkt-`group_covid'-`y_dep'.pdf", replace as(pdf)
	}
	.
}
.


		.
	
* Notes
{
 * 1- Competition is measure on item level 
}
.
