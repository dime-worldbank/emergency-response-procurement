* Made by Leandro Veloso
* Main: Winners level: item level restrict to items


* 0: data preparation
	use   "${path_project}/1_data/04-winners_data.dta"  if year_month >=`=ym(2020,1)',clear
	keep if type_product==1

	gegen covid_item = max(D_covid) , by(code_item)
 
	gen total_covid = value_item_estimated if D_covid==1
	replace D_covid =0 if D_covid==.

	keep code_item covid_item product_pdm  product_class product_group value_item_estimated total_covid
	
	save  "${path_project}/4_outputs/1-data_temp/covid_product_temp",replace

* 1: COVID products:
	use  "${path_project}/4_outputs/1-data_temp/covid_product_temp" ,clear
	
	gcollapse (sum) total = value_item_estimated total_covid , by(product_pdm  covid_item  ) freq(N_top)

	* Keeping:
	gen rate_covid = total_covid/ total

	* Graph All class:
	format %3.2fc rate_covid
	
	* Chiles:
	gsort -total_covid -rate_covid 

	drop if rate_covid<=0.1 | total_covid <=10000 | N_top <=100
	keep if covid_item==1
	drop covid_item
	
	save "${path_project}/1_data/05-covid_item",replace

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

 
