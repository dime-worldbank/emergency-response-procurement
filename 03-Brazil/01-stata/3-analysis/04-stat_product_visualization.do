* Made by Leandro Veloso
* Main: Competitions - based on partipants data

* 01: Graph bar top products
{
	use "${path_project}/1_data/05-Lot_item_data",clear
	keep if inrange(year_quarter,yq(2018,1),yq(2021,4))
	
	* Covid items
	keep if type_item	== 1
	keep if D_item_unit_price_sample	== 1
		
	* Creating variables to  graph bar
	gen volume_post = value_item if D_post ==1
	gen volume_pre = value_item  if D_post ==0
	
	* Summing up
	gcollapse (sum)  volume_pre volume_post , ///
			  by(  item_5d_code item_5d_name_eng Covid_item_level)    labelformat(#sourcelabel#) 
  
	* Millions
	replace volume_pre = volume_pre/1e6
	replace volume_post = volume_post/1e6
	
	* goptions 
	global graph_opts ///
		graphregion(color(white) ) /// <- remove la(center) for Stata < 15
		ylab(,angle(0) nogrid)   ///
		legend(region(lc(none) fc(none))) xsize(10) ysize(5)
	
	foreach k in 0 1 2 3 { 
		preserve
			
			keep if Covid_item_level== `k'
			
			gsort -volume_post 
			keep if _n<=10
			
			* Graph bar
			graph hbar (sum)  volume_post volume_pre , blabel(bar , format(%15.0fc))    ///
				 over(item_5d_name_eng, sort(1) descending ) $graph_opts ytitle("Millions reais") plotregion(margin(medlarge)) ///
				 legend(order(1 "[2020-2021]" 2 "[2018-2019]" )) ///
				 bar(1, color(dkorange) )  bar(2, color(navy) ) 
				 
			graph export  "${overleaf}/02_figures/P4-graph_bar-level_covid-`k'.pdf", as(pdf) replace

		restore 
	}
}
.

* 02: Summarize by period
{
	use "${path_project}/1_data/05-Lot_item_data",clear
	keep if inrange(year_quarter,yq(2018,1),yq(2021,4))
	
	* replace
	replace N_participants = . if methods!=1
	replace SME			   = . if methods!=1

	* Extra
	gegen total_volume = sum(value_item)  , by(D_post type_item item_5d_code    )
	gen share = value_item/total_volume
	gen shannon_entropy  = -share*ln(share)	
	gen HHI = share*share	
	
	* Covid items
	keep if type_item	== 1
	keep if D_item_unit_price_sample	== 1
	
	* Collapse
	rename item_5d_name_eng item_5d_name_eng_aux
	gen str100 item_5d_name_eng = item_5d_name_eng_aux
	drop item_5d_name_eng_aux
	compress
	
	gcollapse (sum)  volume = value_item  	HHI				///
			  (mean) avg_n_participants = N_participants 	///
					 avg_n_win_SME = SME unit_price_filter log_unit_price_filter , 					///
			  freq(N_lots ) 								///
			  by(D_post type_item item_5d_code item_5d_name_eng Covid_item_level)    labelformat(#sourcelabel#) 
	
	* Auxiliar id
 	bys item_5d_code : keep if _N ==2		 
 
	* lag vars
	gen log_volume = log(volume)
	foreach vars of varlist volume avg_n_participants avg_n_win_SME N_lots log_volume   HHI unit_price_filter log_unit_price_filter  {
		bys item_5d_code (D_post): gen L_`vars' = `vars'[1] 		 if _n==2
		gen delta_`vars' = `vars' - L_`vars'
	}	
	.
 	
	* Restricting
	bys item_5d_code: keep if _n ==2
	
	* Formating
	format %15.0fc L_*
}
.

* 03: Graph pre post pandemic
foreach words in "avg_n_participants volume" "log_volume avg_n_participants" "log_volume avg_n_win_SME"   "avg_n_win_SME volume" "HHI volume" " log_unit_price_filter volume"  "unit_price_filter volume"  {
	preserve	
		di as white "`words'"
		* LAbeling variables to aux plot title
		label var avg_n_participants "E[Number of participants by lot]"
		label var volume			 "Total item volume"
		label var log_volume		 "Log(Total item volume)"
		label var avg_n_win_SME		 "Proportion of SME winner by lot" 
		
		* Formating to plot
		format %15.0fc *volume *avg_n_participants *log_volume
 
		
		* Separating word pair
		local var_eval: word 1  of `words' 
		local var_size: word 2  of `words' 
		
		* Title
		local title_aux: var label `var_eval'
		local size_aux : var label `var_size'

		* Checking locals
		di as white "var_eval: `var_eval' | var_size: `var_size'"
		di as white "title_aux: `title_aux' | size_aux: `size_aux'"
		 
		
		count if  `var_eval'>=L_`var_eval'
			local upper_line = r(N)
			
		count if  `var_eval'< L_`var_eval'
			local lower_line = r(N)
			
		* top volume
		cap drop top_values_post
		bys D_post type_item Covid_item_level (delta_`var_eval'): gen top_values_post	 	= _N-_n+1
		
		cap drop  top_var_size
		bys D_post type_item Covid_item_level (		        `var_size'): gen top_var_size			 	= _N-_n+1
		
		cap drop botton_values_post
		bys D_post type_item Covid_item_level (delta_`var_eval'): gen botton_values_post	= _n
				
		* Top volumes
		cap drop top_labels_dot
		gen    top_labels_dot	 = item_5d_name_eng if   top_values_post<=3
		
		cap drop botton_labels_dot
		gen botton_labels_dot	 = item_5d_name_eng if botton_values_post<=3
		
		cap drop top_size_dot
		gen top_size_dot	 	= item_5d_name_eng if top_var_size<=5 & (botton_labels_dot=="" & top_labels_dot=="")
		  
		* var_size
		twoway 	(scatter `var_eval' L_`var_eval' [w = `var_size'] if Covid_item_level == 3 , ms(Oh)  msize(small)  mlwidth(thin)	 mcolor("98 190 121") )  /// 
			(scatter `var_eval' L_`var_eval' 	 [w = `var_size'] if Covid_item_level == 2 , ms(Oh)  msize(small)  mlwidth(thin)	 mcolor("104 172 32") )  /// 
			(scatter `var_eval' L_`var_eval' 	 [w = `var_size'] if Covid_item_level == 1 , ms(Oh)  msize(small)  mlwidth(thin)	 mcolor("180 182 26") )  /// 
			(scatter `var_eval' L_`var_eval' 	 [w = `var_size'] if Covid_item_level == 0 , ms(Oh)  msize(small)  mlwidth(thin)	 mcolor("233 149 144"))  /// 
			(scatter `var_eval' L_`var_eval'    		   , ms(none)   mlab(   top_labels_dot) mlabsize(vsmall) mlabcolor(black) )  ///
			(scatter `var_eval' L_`var_eval'    		   , ms(none)   mlab(botton_labels_dot) mlabsize(vsmall) mlabcolor(black))  ///
 			(lfit 	 `var_eval' L_`var_eval'	           , lc(gs8) lp(dash))  ///
			,graphregion(color(white))  title("`title_aux'", size(medsmall)) ///		
			ylab(, nogrid)   ytitle("[2020-2021]") xtitle("[2018-2019]") ///
			legend(order( 1 "High Covid" 2 "Medium Covid" 3 "low Covid" 4 "No Covid")  col(4))   xsize(10) ysize(5)  /// title("`title'")  caption("Restricted to Reverse Auction and FA")   note("Restricted to Reverse Auction and FA") 
			caption("Number of items upper line = `upper_line'; Number of items lower line = `lower_line'") /// ; limited to x {&isin} (0.01,0.99) {&intersect} y {&isin} (0.01,0.99) } ") 
			note("Size Marker: `size_aux'")
	
		graph export "${overleaf}/02_figures/P4-scatter_pre_post-`words'.pdf", replace as(pdf)		
	restore
}
.

