* Made by Leandro Veloso
* Main: Competitions - based on partipants data
 
* 01: Summarize by period
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
	
	* Collapse
	gcollapse (sum)  volume = value_item  	HHI				///
			  (mean) avg_n_participants = N_participants 	///
					 avg_n_win_SME = SME, 					///
			  freq(N_lots ) 								///
			  by(D_post type_item item_5d_code Covid_item_level Covid_group_level) 
	
	* Auxiliar id
	gegen aux_id = group(type_item item_5d_code)
	gunique aux_id
	bys aux_id: keep if _N ==2		 

	* Getting item name 
	{
		rename type_item aux_type
		gen 	type_item = 1 if  aux_type == "Product"
		replace type_item = 2 if  aux_type == "Service"
		
		* Getting product names
		merge m:1 type_item item_5d_code using   "${kcp_data}/AUXILIAR-01-catalog_items", ///
			keepusing(type_item type_item item_5d_code item_5d_name*)  keep(3) nogen
	}
	.
	
	* lag vars
	gen log_volume = log(volume)
	foreach vars of varlist volume avg_n_participants avg_n_win_SME N_lots log_volume   HHI {
		bys aux_id (D_post): gen L_`vars' = `vars'[1] 		 if _n==2
		gen delta_`vars' = `vars' - L_`vars'
	}	
	.
 	
	* Restricting
	bys aux_id: keep if _n ==2
	
	* Formating
	format %15.0fc L_*
}
.

* 02: Graph pre post pandemic
foreach words in "avg_n_participants volume" "log_volume avg_n_participants" "log_volume avg_n_win_SME"   "avg_n_win_SME volume" "HHI volume" {
	preserve	 
   		* Materials and High covid products
		keep if Covid_item_level==3
		keep if type_item	== 1	

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
		gen    top_labels_dot	 = item_5d_name_eng if   top_values_post<=10
		
		cap drop botton_labels_dot
		gen botton_labels_dot	 = item_5d_name_eng if botton_values_post<=10
		
		cap drop top_size_dot
		gen top_size_dot	 	= item_5d_name_eng if top_var_size<=10 & (botton_labels_dot=="" & top_labels_dot=="")
		 
		* var_size
		twoway 	(scatter `var_eval' L_`var_eval' [w = `var_size'] , ms(Oh)  msize(small)  mlwidth(thin)	mc(dknavy)  mc(dknavy*0.8) )  /// 
				(scatter `var_eval' L_`var_eval'    		   , ms(none)   mlab(   top_labels_dot) mlabsize(small) mlabcolor(blue) )  ///
				(scatter `var_eval' L_`var_eval'    		   , ms(none)   mlab(botton_labels_dot) mlabsize(small) mlabcolor(dkorange))  ///
				(scatter `var_eval' L_`var_eval'    		   , ms(none) /*jitter(10)*/   mlab(top_size_dot) 		 mlabsize(vsmall) mlabcolor(gs5 ))  ///
				(lfit 	 `var_eval' L_`var_eval'	           , lc(gs8) lp(dash))  ///
				,graphregion(color(white))  title("High Covid Materials (item 5d) - Measure: `title_aux' ; Size Marker: `size_aux'", size(medsmall)) ///		
				ylab(, nogrid)   ytitle("[2020-2021]") xtitle("[2018-2019]") ///
				legend(off) xsize(10) ysize(5)  /// title("`title'")  caption("Restricted to Reverse Auction and FA")   note("Restricted to Reverse Auction and FA") 
				caption("Number of items upper line = `upper_line'; Number of items lower line = `lower_line'") // ; limited to x {&isin} (0.01,0.99) {&intersect} y {&isin} (0.01,0.99) } ") 
		graph export "${overleaf}/02_figures/P5-scatter_pre_post-`words'.pdf", replace as(pdf)		
	restore
}
.
