* Made by Leandro Veloso
* Main: Winners level: item level restrict to items

* 1: data preparation
{
	* reading data
	use   "${path_project}/1_data/04-winners_data.dta"  if year_month >=`=ym(2020,1)',clear
	
	* Keeping
	keep if type_item !=""
	replace type_item = "Product" if type_item == "prod"
	replace type_item = "Service" if type_item == "serv"
	
	* Products
	* keep if type_item=="prod"		
	destring item_2d_code ,replace	
	destring item_4d_code ,replace	
		
	* Covid items
	gegen covid_item = max(D_covid) , by(item_5d_code type_item)
  
    * Keeping relevant variables 
	keep D_covid type_item item_5d_* D_covid item_4d_* item_2d_* value_item
	
	compress
	save  "${path_project}/4_outputs/1-data_temp/covid_product_temp",replace
}
.

* 2: Covid items: Assign a "covid tag"
{
	* reading item/tender data sample
	use  "${path_project}/4_outputs/1-data_temp/covid_product_temp", clear
	
	* Collapsing the measures
	cap drop total_covid
	
	gen total_covid = value_item if D_covid==1
	gen N_covid_purchases = D_covid==1
	gcollapse (sum) total = value_item total_covid  N_covid_purchases ///
	(first) item_5d_name item_4d_code item_2d_code, by(type_item item_5d_code) freq(N_purchases)
	
	tostring item_2d_code, replace format(%02.0f)
	tostring item_4d_code, replace format(%04.0f)
	
	* Ordering
	compress
	order item_5d_code item_5d_name
	format %50.0g item_5d_name

	* Keeping:
	gen rate_covid = total_covid/ total

	* Graph All class:
	format %3.2fc rate_covid
	
	* Chiles:
	gsort  type_item item_2d_code -total_covid -rate_covid
	
	* covid tag: For items that respect those criteria 
	gen D_covid_tag =         /// // Data restrict to purchases in [2020,2021,2022]
		  rate_covid  >= 0.1  /// // 10% volume of this product was covid tenders
		& total_covid >=10000 /// // It was spent at least 10,000 reais in this product
		& N_purchases >=100       // It was purchase at least 100 times in
	
	* Labeling
	label var D_covid_tag "dummy if it is a covid item" 
	
	* Labeling
	label var type_item          "Product/Service"
	label var item_2d_code       "item group - 2 digits"
	label var item_4d_code       "item class - 4 digits"
	label var item_5d_code       "item code - 5 digits"
	label var item_5d_name       "item name"
	label var total_covid        "Total value in covid tenders"
	label var total              "Total value"
	label var N_purchases 		 "N item/lot"
	label var N_covid_purchases  "N item/lot covid"
	label var rate_covid         "Proportion of expenses on covid tender"
	
	* formating 
	format %18.0fc total total_covid N_covid_purchases  N_purchases
 	order type_item item_2d_code item_4d_code item_5d_code item_5d_name D_covid_tag N_purchases  ///
		N_covid_purchases  total total_covid rate_covid 

	* saving table
	save "${path_project}/1_data/03-covid_item-item_level",replace
}
.	
	 
* 3: Class products:	
{
	* reading item/tender data sample
	use  "${path_project}/4_outputs/1-data_temp/covid_product_temp", clear
	
	* Collapsing the measures
	cap drop total_covid	
	
	gen total_covid = value_item if D_covid==1
	gen N_covid_purchases = D_covid==1
	gcollapse (sum) total = value_item total_covid  N_covid_purchases ///
	(first) item_4d_name item_2d_code, by(type_item item_4d_code ) freq(N_purchases)
	
	tostring item_2d_code, replace format(%02.0f)
	
	* Ordering
	compress
	order item_4d_code item_4d_name
	format %50.0g item_4d_name

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
	save "${path_project}/1_data/03-covid_item-class_level",replace
}
.	
	
* 4: Group products:	
{
	* reading item/tender data sample
	use  "${path_project}/4_outputs/1-data_temp/covid_product_temp", clear
	
	* Collapsing the measures
	cap drop total_covid
	
	gen total_covid = value_item if D_covid==1
	gen N_covid_purchases = D_covid==1
	gcollapse (sum) total = value_item total_covid  N_covid_purchases ///
	(first) item_2d_name, by(type_item item_2d_code) freq(N_purchases)
	
  	* Ordering
	compress
	order item_2d_code item_2d_name
	format %50.0g item_2d_name

	* Keeping:
	gen rate_covid = total_covid/ total

	* Graph All class:
	format %3.2fc rate_covid
	
	* Chiles:
	gsort item_2d_code -total_covid -rate_covid 
	
	* covid tag: For items that respect those criteria 
	gen D_covid_tag =         /// // Data restrict to purchases in [2020,2021,2022]
		  rate_covid  >= 0.05 

	* Labeling
	label var D_covid_tag "dummy if it is a covid item" 
	
	* Labeling
	label var type_item          "Product/Service"
	label var item_2d_code       "item group - 2 digits"
	label var item_2d_name       "group name"
	label var total_covid        "Total value in covid tenders"
	label var total              "Total value"
	label var N_purchases 		 "N item/lot"
	label var N_covid_purchases  "N item/lot covid"
	label var rate_covid         "Proportion of expenses on covid tender"
	
	* formating 
	format %18.0fc total total_covid N_covid_purchases  N_purchases 
 	order type_item item_2d_code item_2d_name D_covid_tag N_purchases  ///
		N_covid_purchases  total total_covid rate_covid 

	* saving table
	save "${path_project}/1_data/03-covid_items-group_level",replace
}
.	
			
* 5: Exporting to excel:
{
	
	use "${path_project}/1_data/03-covid_items-group_level",clear
	export excel "${path_project}/4_outputs/2-Tables/01_covid_items.xlsx", sheet("01-group_level-2 digits") ///
		replace firstrow(varlabels) 
	
	* 1: Item export
	use "${path_project}/1_data/03-covid_item-item_level",clear
	export excel "${path_project}/4_outputs/2-Tables/01_covid_items.xlsx", sheet("03-item_level-5 digits"  ) ///
		sheetreplace firstrow(varlabels) 

	use "${path_project}/1_data/03-covid_item-class_level",clear
	export excel "${path_project}/4_outputs/2-Tables/01_covid_items.xlsx", sheet("02-class_level-4 digits" ) ///
		sheetreplace firstrow(varlabels) 


}
.





 