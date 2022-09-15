* Made by Leandro Veloso
* Main: Time series model - Using average as example

* 0: Scatter options
{
	* graphs configuration (whhte) wider and year month
	global graph_opt_ym graphregion(color(white)) xsize(10) ysize(5) ///
		xlabel(`=ym(2015,3)'(3)`=ym(2022,6)', angle(90))

	* Predifined styles
 	global style_1_nocovid 		"connect(1)  lc(emerald) 	mcolor(emerald) ms(dh)  lp(dash)"
	global style_2_covid  		"connect(1)  lc(brown) 		mcolor(brown )  ms(th)  lp(dash)"
 
	* legend
	global order_legend  legend(order( 1 "Auction-NoCovid" 2 "Auction-Covid")  col(3))   
	
	* Covid shadow
	global covid_shadow  /*
	 */	xline(`=ym(2020,7)' , lwidth(4.5) lc(gs14)) /* 
	 */	xline(`=ym(2021,5)' , lwidth(9) lc(gs14)) /*
	 */	xline(`=ym(2022,2)' , lwidth(2.25) lc(gs14)) /*
	 */	xline(`=ym(2022,7)' , lwidth(4.5) lc(gs14)) 		 
}
.

* 1: Importing data ready to plot
{ 
	clear
	input year	month	D_covid	avg_winner
			2015	1	0	.26937014
			2015	2	0	.27044055
			2015	3	0	.25957263
			2015	4	0	.26349255
			2015	5	0	.25385186
			2015	6	0	.25410286
			2015	7	0	.24972692
			2015	8	0	.25551271
			2015	9	0	.24563207
			2015	10	0	.25354686
			2015	11	0	.27594739
			2015	12	0	.27517623
			2016	1	0	.27668792
			2016	2	0	.28865039
			2016	3	0	.24584444
			2016	4	0	.28119799
			2016	5	0	.28128728
			2016	6	0	.27782306
			2016	7	0	.26632109
			2016	8	0	.29477096
			2016	9	0	.27662343
			2016	10	0	.28963816
			2016	11	0	.2834039
			2016	12	0	.26676106
			2017	1	0	.30001017
			2017	2	0	.30418915
			2017	3	0	.28731668
			2017	4	0	.25768289
			2017	5	0	.26805875
			2017	6	0	.27144137
			2017	7	0	.26116839
			2017	8	0	.24905051
			2017	9	0	.26679653
			2017	10	0	.26209944
			2017	11	0	.28077665
			2017	12	0	.28499171
			2018	1	0	.30010471
			2018	2	0	.28450564
			2018	3	0	.26518467
			2018	4	0	.25979328
			2018	5	0	.25871494
			2018	6	0	.26323676
			2018	7	0	.28154796
			2018	8	0	.29115215
			2018	9	0	.27239409
			2018	10	0	.28445059
			2018	11	0	.29007787
			2018	12	0	.2736325
			2019	1	0	.27538276
			2019	2	0	.29350954
			2019	3	0	.26101521
			2019	4	0	.26985794
			2019	5	0	.29230917
			2019	6	0	.25746721
			2019	7	0	.27230784
			2019	8	0	.25873679
			2019	9	0	.24848111
			2019	10	0	.27118409
			2019	11	0	.29046932
			2019	12	0	.28425217
			2020	1	0	.3004497
			2020	2	0	.2895146
			2020	3	0	.27858436
			2020	4	0	.27600035
			2020	4	1	.27666596
			2020	5	0	.28377789
			2020	5	1	.30815917
			2020	6	0	.28429064
			2020	6	1	.37047192
			2020	7	0	.28303567
			2020	7	1	.36626348
			2020	8	0	.28454503
			2020	8	1	.32852232
			2020	9	0	.2926476
			2020	9	1	.23049314
			2020	10	0	.29657632
			2020	10	1	.29388371
			2020	11	0	.33527797
			2020	11	1	.21911608
			2020	12	0	.33790085
			2020	12	1	.27673757
			2021	1	0	.35565552
			2021	1	1	.25906479
			2021	2	0	.31579113
			2021	2	1	.27087575
			2021	3	0	.31059745
			2021	3	1	.18352863
			2021	4	0	.32658038
			2021	4	1	.15050781
			2021	5	0	.32756612
			2021	5	1	.21939713
			2021	6	0	.34252602
			2021	6	1	.3378703
			2021	7	0	.32386476
			2021	7	1	.30812997
			2021	8	0	.32703823
			2021	8	1	.4271341
			2021	9	0	.33845094
			2021	9	1	.36798894
			2021	10	0	.33762431
			2021	10	1	.48232314
			2021	11	0	.34381753
			2021	11	1	.22811398
			2021	12	0	.36887798
			2021	12	1	.2471434
			2022	1	0	.3685582
			2022	1	1	.22960013
			2022	2	0	.34847134
			2022	2	1	.36545041
			2022	3	0	.35875389
			2022	3	1	.18299334
			2022	4	0	.36731744
			2022	4	1	.31916416
			2022	5	0	.3599422
			2022	5	1	.13105923
			2022	6	0	.38368538
			2022	6	1	.37560567
	end
}
.

* 2: Ploting 
{
	* Year month variable
	cap drop year_month
	gen  year_month = ym(year,month)
	order year_month
	
	* Formating ( tips: changing format is a easy way to change exibition on graph)
	format %tm year_month
	format %3.2fc avg_winner // 2 decimals
	
	* Graph 1: Avg winner
	tw (scatter avg_winner  year_month if D_covid == 0 , ${style_1_nocovid}   ) ///
	|| (scatter avg_winner  year_month if D_covid == 1 , ${style_2_covid}) 		///
 	, ${graph_opt_ym} ${order_legend}  ${covid_shadow}   						/// Pre-defined options
		ytitle("winner proportion") ylabel(0(0.05)0.50,angle(0)) 				/// y axis options
		title("Competition measure on item level data")   						/// Title
		note("Auction open method most popular (>99% of open methods) ")  		/// Note
	
	* Exporting as png
	graph export "competition-avg_winner.png", replace as(png)		
}
.

* Notes
{
 * 1- I use xline to create the covid shadow. I selected the point then I changed the width.
 * lwidth is according to the graph dimensions. If you change the size of the plot, you have to adjust.
}
.
