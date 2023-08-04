* Made by Leandro Veloso
* Main: Using lot data level to estimate the covid product frontier
 
* 1: data preparation
{	
    * Reading data
	use    "${path_project}/1_data/01-import-data/Portal-02-item-panel.dta",clear
	
	* Restring to the pandemic period 
	rename year_month aux
	gen year_month = ym(real(substr(aux,1,4)), real(substr(aux,5,2)))
		format %tm year_month
	drop aux	
	
	* Filtering relevant information
		keep if year_month >=`=ym(2020,1)'
	
	* Getting covid tag from data from program 01
	merge m:1 tender_id using "${path_project}/1_data/03-final/01-tender_data", ///
	 keepusing(tender_id D_covid )  keep(3) nogen
	 
	* getting item information
	merge m:1 type_item item_5d_code  using "${path_project}/1_data/01-import-data/Extra-01-catalog-federal-procurement", ///
		keepusing(type_item item_5d_* item_4d_* item_2d_* ) keep(1 3) 
	
	* Dropping extra data
	cap drop item_5d_code_aux
		 
	* Products
	* keep if type_item=="prod"		
	destring item_2d_code ,replace	
	destring item_4d_code ,replace	
		
	* Covid items
	gegen covid_item = max(D_covid) , by(item_5d_code type_item)
  
    * Keeping relevant variables 
	keep D_covid covid_item type_item item_5d_* item_4d_* item_2d_* item_value
	
	* Saving auxiliar data
	compress
	save  "${path_project}/4_outputs/1-data_temp/P02-covid_product_temp",replace
}
.
	
* 2: Group products:	
{
	* reading item/tender data sample
	use  "${path_project}/4_outputs/1-data_temp/P02-covid_product_temp", clear
	
	* Collapsing the measures
	cap drop total_covid
	
	gen total_covid = item_value if D_covid==1
	gen N_covid_purchases = D_covid==1
	gcollapse (sum) total = item_value total_covid  N_covid_purchases ///
	    , by(type_item item_2d_code item_2d_name) freq(N_purchases)
	
  	* Ordering
	compress
	order item_2d_code item_2d_name

	* Keeping:
	gen rate_covid = total_covid/ total

	* Graph All class:
	format %3.2fc rate_covid
	
	* Chiles:
	gsort item_2d_code -total_covid -rate_covid 
	
	* covid tag: For items that respect those criteria 
	gen D_covid_tag =         /// // Data restrict to purchases in [2020,2021,2022]
		  rate_covid  >= 0.05 
			
	* Covid rate
	gen rate_covid_purchase = N_covid_purchases/N_purchases 
	rename rate_covid rate_value

	gen log_covid_purchase = log(N_covid_purchases)
	gen log_covid_value    = log(total_covid)
	
	* Covid levels
	cap drop Covid_group_level
	gen      Covid_group_level  = 0
	replace  Covid_group_level  = 1 if N_covid_purchases>= 250  & total_covid>= 2e6
	replace  Covid_group_level  = 2 if N_covid_purchases>= 400  & total_covid>= 6e6
	replace  Covid_group_level  = 3 if N_covid_purchases>= 1000 & total_covid>= 2e7
	tab Covid_group_level
	
	* Final Criteria
	twoway  /// 
	(function y= 0  						,range(0            25) recast(area)  color("233 149 144") base(10) )  ///
	(function y= 1/(x+ log( 2e6))+log( 250) ,range(`=log( 2e6)' 25) recast(area)  color("104 172 32")  base(10) )  ///
	(function y= 1/(x+ log( 6e6))+log( 400) ,range(`=log(6e6)'  25) recast(area)  color("180 182 26")  base(10) )  ///
	(function y= 1/(x+ log( 2e7))+log(1000) ,range(`=log(2e7)'  25) recast(area)  color("98 190 121")  base(10) )  ///
 	(scatter log_covid_purchase log_covid_value  if Covid_group_level   ==3, m(c)  mc( gs7) ) ///
	(scatter log_covid_purchase log_covid_value  if Covid_group_level   ==2, m(X)  mc( gs4) ) ///
	(scatter log_covid_purchase log_covid_value  if Covid_group_level   ==1, m(x)  mc( gs2)   msize(small))  ///
	(scatter log_covid_purchase log_covid_value  if Covid_group_level   ==0, m(x)  mc( pink)   msize(tiny)) ///
	, legend(order( 4 "High Covid" 3 "Medium Covid" 2 "low Covid" 1 "No Covid")  col(4)) ///
	graphregion(color(white)) xtitle("The proportion of expenses on covid tender") ///
	 ytitle("The proportion of covid lots on covid tender")
	 	
	graph export "${path_project}/4_outputs/3-Figures/02-Covid_group_estimation-region.png", replace as(png)
	 
	* K-means
	* Final Criteria
	twoway  /// 
	(function y= 0  						,range(0              25) recast(area)  color("233 149 144")  base(10) )  ///
	(function y= 1/(x+ log( 1400))  +log(  5) ,range(`=log(  1400)' 25) recast(area)  color("104 172 32")  base(10) )  ///
	(function y= 1/(x+ log( 49950)) +log( 60) ,range(`=log( 49950)' 25) recast(area)  color("180 182 26")  base(10) )  ///
	(function y= 1/(x+ log( 253072))+log(512) ,range(`=log(253072)' 25) recast(area) color("98 190 121")  base(10) )   ///
 	(scatter log_covid_purchase log_covid_value  if Covid_group_level   ==3, m(c)  mc( gs7) ) ///
	(scatter log_covid_purchase log_covid_value  if Covid_group_level   ==2, m(X)  mc( gs4) ) ///
	(scatter log_covid_purchase log_covid_value  if Covid_group_level   ==1, m(x)  mc( gs2)   msize(small))  ///
	(scatter log_covid_purchase log_covid_value  if Covid_group_level   ==0, m(x)  mc( pink)   msize(tiny)) ///
	, legend(order( 4 "High Covid" 3 "Medium Covid" 2 "low Covid" 1 "No Covid")  col(4)) ///
	graphregion(color(white)) xtitle("The proportion of expenses on covid tender") ///
	 ytitle("The proportion of covid lots on covid tender")
	
	* Labeling
	label var D_covid_tag 		 "Old-dummy if it is a covid item" 
	label var type_item          "Product/Service"
	label var item_2d_code       "item group - 2 digits"
	label var item_2d_name       "group name"
	label var total_covid        "Total value in covid tenders"
	label var total              "Total value"
	label var N_purchases 		 "N item/lot"
	label var N_covid_purchases  "N item/lot covid"
	label var rate_covid          "Proportion of expenses on covid tender"
	label var rate_covid_purchase "Proportion of covid lots"
	
	label var Covid_group_level  "Covid level classification group - 2 digits"
	
	* formating	
	format %18.0fc total total_covid N_covid_purchases  N_purchases 
 	order type_item item_2d_code item_2d_name Covid_group_level N_purchases  ///
		N_covid_purchases  total total_covid rate_covid_purchase rate_covid  D_covid_tag

 	keep type_item item_2d_code item_2d_name Covid_group_level N_purchases  ///
		N_covid_purchases  total total_covid rate_covid_purchase rate_covid  D_covid_tag

	* saving table
	save "${path_project}/1_data\03-final/02-covid_items-group_level",replace
}
.	
 
* 3: Class products:	
{
	* reading item/tender data sample
	use  "${path_project}/4_outputs/1-data_temp/P02-covid_product_temp", clear
	
	* Collapsing the measures
	cap drop total_covid	
	
	gen total_covid = item_value if D_covid==1
	gen N_covid_purchases = D_covid==1
	gcollapse (sum) total = item_value total_covid  N_covid_purchases ///
		, by(type_item item_4d_code item_4d_name item_2d_code ) freq(N_purchases)
	
	tostring item_2d_code, replace format(%02.0f)
	
	* Ordering
	compress
	order item_4d_code item_4d_name
 
	* Keeping:
	gen rate_covid = total_covid/ total

	* Graph All class:
	format %3.2fc rate_covid
	
	* Chiles:
	gsort type_item item_4d_code -total_covid -rate_covid 
	
	* covid tag: For items that respect those criteria 
	gen D_covid_tag =         /// // Data restrict to purchases in [2020,2021,2022]
		  rate_covid  >= 0.1  
		  
	* Labeling
	label var D_covid_tag "dummy if it is a covid item" 
	
	* Labeling
	label var type_item          "Product/Service"
	label var item_2d_code       "item group - 2 digits"
	label var item_4d_code       "item class - 4 digits"
	label var item_4d_name       "class name"
	label var total_covid        "Total value in covid tenders"
	label var total              "Total value"
	label var N_purchases 		 "N item/lot"
	label var N_covid_purchases  "N item/lot covid"
	label var rate_covid         "Proportion of expenses on covid tender"
	
	* formating 
	format %18.0fc total total_covid N_covid_purchases  N_purchases 
 	order type_item item_4d_code item_4d_name D_covid_tag N_purchases  ///
		N_covid_purchases  total total_covid rate_covid 

	* saving table
	save "${path_project}/1_data\03-final/02-covid_item-class_level",replace
}
.	

* 4: Covid items: Assign a "covid tag"
{
	* reading item/tender data sample
	use  "${path_project}/4_outputs/1-data_temp/P02-covid_product_temp", clear
	
	* Collapsing the measures
	cap drop total_covid
	
	gen total_covid = item_value if D_covid==1
	gen N_covid_purchases = D_covid==1
	gcollapse (sum) total = item_value total_covid  N_covid_purchases ///
		, by(type_item item_5d_code item_5d_name item_4d_code item_2d_code) freq(N_purchases)
	
	tostring item_2d_code, replace format(%02.0f)
	tostring item_4d_code, replace format(%04.0f)
	
	* Ordering
	compress
	order item_5d_code item_5d_name
 
	* Keeping:
	gen rate_covid = total_covid/ total
	gen rate_covid_purchase = N_covid_purchases/N_purchases 

	gen log_covid_purchase = log(N_covid_purchases)
	gen log_covid_value    = log(total_covid)
	
	* Graph All class:
	format %3.2fc rate_covid
	
	* Chiles:
	gsort  type_item item_2d_code -total_covid -rate_covid
	
	* covid tag: For items that respect those criteria 
	  gen D_covid_tag =         /// // Data restrict to purchases in [2020,2021,2022]
		  rate_covid  >= 0.1  /// // 10% volume of this product was covid tenders
		& total_covid >=10000 /// // It was spent at least 10,000 reais in this product
		& N_purchases >=100       // It was purchase at least 100 times in

	destring item_2d_code,replace 
	merge m:1 type_item item_2d_code using "${path_project}/1_data\03-final/02-covid_items-group_level", keepusing(item_2d_code Covid_group_level) nogen
	
	* Covid levels
	cap drop Covid_item_level
	gen      Covid_item_level  = 0
	replace  Covid_item_level  = 1 if N_covid_purchases>= 5  & total_covid>=  10000
	replace  Covid_item_level  = 2 if N_covid_purchases>= 15 & total_covid>=  50000
	replace  Covid_item_level  = 3 if N_covid_purchases>= 50 & total_covid>= 300000
	tab Covid_item_level	
	
	tab Covid_group_level Covid_item_level
	
	 
	* Final Criteria
	twoway  /// 
	(scatter log_covid_purchase log_covid_value  if D_covid_tag   ==1, m(x)  mc( gs2)    msize(small))  	///
	(scatter log_covid_purchase log_covid_value  if D_covid_tag   ==0,       mc( pink)   msize(tiny)) 	///	
	/// (function y=15+ -12/25*x                       ,range(5 25)  color("98 190 121")  )  || 		///
	, legend(order( 1  "D Covid =1"  2  "D Covid =0")  col(4)) ///
	graphregion(color(white)) xtitle("Log(Covid Expenses) vs Log(Covid Purchases)") ///		
	 ytitle("Log(Covid Expenses)")  xtitle("Log(Covid Purchases)")   	///
	 note("Tenders opened in [2020,2021,2022]")
	
 
	* Final Criteria
	twoway  /// 
	(function y= 0  						,range(0              25) recast(area)  color("233 149 144")  base(9) )  ///
	(function y= 1/(x+ log( 10000))+log( 5) ,range(`=log( 10000)' 25) recast(area)  color("104 172 32")  base(9) )  ///
	(function y= 1/(x+ log( 50000))+log(15) ,range(`=log( 50000)' 25) recast(area)  color("180 182 26")  base(9) )  ///
	(function y= 1/(x+ log(300000))+log(50) ,range(`=log(300000)' 25) recast(area) color("98 190 121")  base(9) )   ///
 	(scatter log_covid_purchase log_covid_value  if Covid_item_level   ==3, m(c)  mc( gs16)    msize(small)) 				///
	(scatter log_covid_purchase log_covid_value  if Covid_item_level   ==2, m(d)  mc( gs8)    msize(small)) 				///
	(scatter log_covid_purchase log_covid_value  if Covid_item_level   ==1, m(x)  mc( gs2)    msize(small))  	///
	(scatter log_covid_purchase log_covid_value  if Covid_item_level   ==0,       mc( pink)   msize(tiny)) 	///	
	/// (function y=15+ -12/25*x                       ,range(5 25)  color("98 190 121")  )  || 		///
	, legend(order( 4 "High Covid" 3 "Medium Covid" 2 "low Covid" 1 "No Covid")  col(4)) ///
	graphregion(color(white)) xtitle("The proportion of expenses on covid tender") ///		
	 ytitle("The proportion of covid lots on covid tender")   		
	
	graph export "${path_project}/4_outputs/3-Figures/02-Covid_group_estimation-item.png", replace as(png)
	
	* Labeling
	label var D_covid_tag "Old-dummy if it is a covid item"  
	label var type_item           "Product/Service"
	label var item_2d_code        "item group - 2 digits"
	label var item_4d_code        "item class - 4 digits"
	label var item_5d_code        "item code - 5 digits"
	label var item_5d_name        "item name"
	label var total_covid         "Total value in covid tenders"
	label var total               "Total value"
	label var N_purchases 		  "N item/lot"
	label var N_covid_purchases   "N item/lot covid"
	label var rate_covid          "Proportion of expenses on covid tender"
	label var rate_covid_purchase "Proportion of covid lots"
	label var Covid_item_level    "Covid level classification item - 5 digits"

	* formating 
	format %18.0fc total total_covid N_covid_purchases  N_purchases
 	order type_item item_2d_code item_4d_code item_5d_code item_5d_name Covid_group_level Covid_item_level  N_purchases  ///
		N_covid_purchases  total total_covid rate_covid_purchase rate_covid  D_covid_tag
	
	* Keeping
	keep type_item item_2d_code item_4d_code item_5d_code item_5d_name Covid_group_level Covid_item_level  N_purchases  ///
		N_covid_purchases  total total_covid rate_covid_purchase rate_covid  D_covid_tag
	
	* saving table
	save "${path_project}/1_data\03-final/02-covid_item-item_level",replace
}
.	
		
* 5: Exporting to excel:
{
	use "${path_project}/1_data\03-final/02-covid_items-group_level",clear
	export excel "${path_project}/4_outputs/2-Tables/02_covid_items.xlsx", sheet("01-group_level-2 digits") ///
		replace firstrow(varlabels) 
	
	* 1: Item export
	use "${path_project}/1_data\03-final/02-covid_item-item_level",clear
	export excel "${path_project}/4_outputs/2-Tables/02_covid_items.xlsx", sheet("03-item_level-5 digits"  ) ///
		sheetreplace firstrow(varlabels) 

	use "${path_project}/1_data\03-final/02-covid_item-class_level",clear
	export excel "${path_project}/4_outputs/2-Tables/02_covid_items.xlsx", sheet("02-class_level-4 digits" ) ///
		sheetreplace firstrow(varlabels) 
}
.
