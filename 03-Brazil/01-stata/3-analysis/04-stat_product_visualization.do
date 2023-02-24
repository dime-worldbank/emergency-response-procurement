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

* 01: Preparing data
{
	* Filter data
	local filter "inrange(year_quarter,yq(2018,1),yq(2022,4))" // filter 1 year
	* local filter "inrange(year_quarter,yq(2019,1),yq(2020,4))" // filter 2 year
	
	use "${path_project}/1_data/04-participants_data" if `filter',clear
	
	* Counting participants
	gen N_participants = 1
	gcollapse (sum) N_participants N_SME_participants = SME, by(id_item)
	tempfile data_participants
	save `data_participants'
	
	* Reading winner data
	use "${path_project}/1_data/05-winners_data" if `filter',clear
	 
	* list interesting vars
	local list_vars id_item year_quarter id_bidder D_covid id_ug type_bidder SME great_sectors id_organ 	///
					Covid_group_level Covid_item_level methods 							///
					value_item type_item item_5d_code  id_bidder type_bidder

	* Keeping and order variables
	keep  `list_vars'
	order `list_vars'
	sort  year_quarter id_organ type_item Covid_item_level
	
	* Creating pre/post
	gen byte D_post = year_quarter>=yq(2020,1)
	
	* Merging
	merge 1:1 id_item using `data_participants', nogen keep(3)
	
	* Compressing to save
	compress
	save "${path_project}/4_outputs/1-data_temp/Analysis_03-winner_data.dta",replace
}
. 

* 02: Based on KCP table format (Table paper - Lira)
{
	use "${path_project}/4_outputs/1-data_temp/Analysis_03-winner_data.dta",clear
	keep if inrange(year_quarter,yq(2018,1),yq(2021,4))
	
	* replace
	gen D_product 		= type_item== "Product"
	gen D_auction		= methods  ==1
	gen value_covid		= value_item  if methods  ==1
 	
 	gen id_bidding = substr(id_item,1,17)
	
	keep    id_bidding id_item D_product D_auction  value_covid value_item N_participants SME D_covid D_post
	 
	tempfile data_to_collapse
	save `data_to_collapse' 
	
	* Reading bidding data using all methods
	clear		 
	{
		* sample 1
		append using `data_to_collapse'
		gen sample = 1 
		
		* sample 2
		append using `data_to_collapse'
		replace sample=2 if sample ==. &  D_product==1 & D_auction==1
		drop if sample==.
	
		* sample 3
		append using `data_to_collapse'
		replace sample=3 if sample ==. & D_post ==0 &  D_product==1 & D_auction==1
		drop if sample==.
		
		* sample 4
		append using `data_to_collapse'
		replace sample=4 if sample ==. & D_post ==1 &  D_product==1 & D_auction==1
		drop if sample==.
	}	
	.
	 
	* [Selected to report] Table:1
	{ 		
		* List of measures - Fase processo
		gen byte block_11_rate_prod 		= D_product
		gen byte block_12_rate_auction  	= D_auction
		gen block_13_est_value 				= value_item
		gen block_14_est_value_covid		= value_covid

		* List of measures - Fase processo
		gen block_21_participantes 			= N_participants
		gen block_22_proportion_sme_win 	= SME
 		
		* List of measures - Fase processo
		gen byte block_31_items 	= 1
		bys id_bidding sample: gen byte block_32_batches = _n==1
		
		gen id_ug = substr(id_bidding,1,6)
		bys id_ug sample: gen byte block_34_batches_ug = _n==1
		
		* 
		gen block_33_batches_covid = block_32_batches * D_covid
		
		* Collapsing
		gcollapse (sum) block_3* (mean) block_1* block_2*, by(sample)
		
		* percentage
		foreach var in block_11_rate_prod block_12_rate_auction block_22_proportion_sme_win {
			replace `var'= `var'*100
		}
		.
		
		label var block_11_rate_prod 			"Share products"
		label var block_12_rate_auction 		"Share SME set-aside"
		label var block_13_est_value	 		"Avg estimated value"
		label var block_14_est_value_covid 		"Avg covid value"
		label var block_21_participantes 		"Avg \# participants"
		label var block_22_proportion_sme_win	"Share SME win"
		label var block_31_items 				"N lots"
		label var block_32_batches		 		"N batches"
		label var block_33_batches_covid 		"N covid batches"
		label var block_34_batches_ug			"N buyer entities"
		
		global descript block_11_rate_prod block_12_rate_auction block_13_est_value block_14_est_value_covid ///
						block_21_participantes block_22_proportion_sme_win  ///
						
		global descript_n block_3* 
		
		eststo drop *
		eststo stats_13: quietly estpost summarize $descript  if sample == 1 ,d
		eststo stats_14: quietly estpost summarize $descript  if sample == 2 ,d
		eststo stats_15: quietly estpost summarize $descript  if sample == 3 ,d 
		eststo stats_16: quietly estpost summarize $descript  if sample == 4 ,d 

		esttab stats_13 stats_14 stats_15 stats_16  using 	///
			"${overleaf}/01_tables/P3-overview_table.tex",	/// 
			cells("mean(fmt(2))") mtitles("All" "Only Materials and auction" "Only Materials and auction [2018,2019]"  "Only Materials and auction [2020,2021]") nonum ///
			label replace f booktabs brackets noobs gap ///
			starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
		
		eststo drop *
		eststo stats_13: quietly estpost summarize $descript_n  if sample == 1 ,d
		eststo stats_14: quietly estpost summarize $descript_n  if sample == 2 ,d
		eststo stats_15: quietly estpost summarize $descript_n  if sample == 3 ,d 
		eststo stats_16: quietly estpost summarize $descript_n  if sample == 4 ,d 

		esttab stats_13 stats_14 stats_15 stats_16 using 	///
			"${overleaf}/01_tables/P3-overview_table.tex", ///
			cells("mean(fmt(%12.0fc))") nomtitles nonum ///
			label append f booktabs brackets noobs gap ///
			starlevels(* 0.1 ** 0.05 *** 0.01) collabels(none)
			
		* xpose
		xpose, clear varname
		order _varname
		sort _varname
		rename v? sample_?
		drop if _varname=="sample"
		
		* Formating
		format %12.0fc sample_*
		
		* Exporting
		export excel "${path_project}/4_outputs/2-Tables/P3-overview_table.xlsx", replace firstrow(varlabels)  		
	}
	. 
}
.

* 03: Summarize by period
{
	use "${path_project}/4_outputs/1-data_temp/Analysis_03-winner_data.dta",clear
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

* 04: Graph pre post pandemic
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
		graph export "${overleaf}/02_figures/P3-scatter_pre_post-`words'.pdf", replace as(pdf)		
	restore
}
.

