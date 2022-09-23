* Made by Leandro Veloso
* Main: Winners level: item level restrict to items


* 0: data preparation
	use   "${path_project}/1_data/04-winners_data.dta"  if year_month >=`=ym(2020,1)',clear
	keep if type_product==1

	gegen covid_item = max(D_covid) , by(code_item)
  
	keep code_item D_covid covid_item product_pdm  product_class product_group value_item_estimated
	
	save  "${path_project}/4_outputs/1-data_temp/covid_product_temp",replace

* 2: Covid items: Assign a "covid tag"
{
	* reading item/tender data sample
	use  "${path_project}/4_outputs/1-data_temp/covid_product_temp", clear
	
	* Collapsing the measures
	cap drop total_covid
	
	gen total_covid = value_item_estimated if D_covid==1
	gcollapse (sum) total = value_item_estimated total_covid , by(product_pdm) freq(N_purchases)

	* Keeping:
	gen rate_covid = total_covid/ total

	* Graph All class:
	format %3.2fc rate_covid
	
	* Chiles:
	gsort -total_covid -rate_covid 
	
	* covid tag: For items that respect those criteria 
	gen D_covid_tag =         /// // Data restrict to purchases in [2020,2021,2022]
		  rate_covid  >= 0.1  /// // 10% volume of this product was covid tenders
		& total_covid >=10000 /// // It was spent at least 10,000 reais in this product
		& N_purchases >=100       // It was purchase at least 100 times in
	
	* Labeling
	label var D_covid_tag "dummy if it is a covid item" 
	
	* formating
	 format %50.0g product_pdm
	 order product_pdm D_covid_tag N_purchases rate_covid
	
	* saving table
	save "${path_project}/1_data/03-covid_items",replace
}
.	
	 
* 2: Class products:	
	
* 3: group products:
		
* 4: pdm products:







Preparing service list to merge
* reading

gcollapse (sum) total = value_item_estimated total_covid , by(code_item product_pdm  ) freq(N_top)

* Keeping 
gen rate_covid = total_covid/ total

* Graph All class
format %3.2fc rate_covid

gsort -rate_covid -total_covid

drop if rate_covid<=0.1 | rate_covid <=10000 | N_top <=10

 
