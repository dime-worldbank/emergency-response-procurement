* Made by Leandro Veloso
* Main: A short example how to estimate COVID product
* details: 

* 0: Path files
global project "C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\06-Covid_Brazil\3_writting\02-example_estimate_covid_products"

* 1: Tender Sample: Identify all covid tenders 
{
	* Sample brazil
	use "${project}/01-tender_sample",clear

	* Brazil data has a variable that explain the reason of the tender
	* Using regular expressions I can select covid related words
	
	* This is the meaning of each expression.
	* (covid)([^8]*)(19)      =>>> "covid-19","covid19","covid_19"...
	* "(sars)([^8]*)(cov)"    =>>> "sars-cov","sars-cov2","sarscov2"...
	* "(926)([^0-9]*)(2020)") =>>> "9262020","926 2020",",p 926 de 2020"   
	* "(13)([^0-9]*)(979)")   =>>> "13979","13 979","Lei 13 de 979"
	* "coronavirus"             
	

	* Note: ([^8]*) means anything except number 8 (I din't find only any charactere)/
	* I used anything that is different of 8, almost the same.
	
	
	* Creating covid dummy tender
	gen D_covid = 	  regex(bidding_object,"(covid)([^8]*)(19)")   /// Finding covid-19
					| regex(bidding_object,"(sars)([^8]*)(cov)")   /// Finding sars-cov2
					| regex(bidding_object,"(926)([^0-9]*)(2020)") /// Law for covid procurement
					| regex(bidding_object,"(13)([^0-9]*)(979)")   /// Law for covid procurement
					| regex(bidding_object,"coronavirus")					
					
	label var D_covid "Dummy for COVID tender"

	* Table year quarter
	tab year_quarte D_covid
}
.

* 2: Covid items: Assign a "covid tag"
{
	* reading item/tender data sample
	use  "${project}/02-item_sample" ,clear
	
	* Collapsing the measures
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


* Methodology note:
{
	*Our approach to identify covid products follows the following steps:

	* First, we identify all covid tenders. 
	* The tender data contains a detailed description that justifies the purchase making it possible
	* to find the pandemic related. Covid tender always contains specific words in the objective 
	* (covid-19, sarscov2, 19.979)
	
	* Second, for 2020 and 2021, for each item, we define these measures:
	* 1-the total value purchased (v1), 
	* 2-the total value purchased through covid tenders (v2), 
	* 3-the total number of purchases,
	* 4-ratio v2/v1;
 
	* Finally, if an item (for instance, mask) is above a threshold for the measures in the 
	* second step, it is a covid item. An item is a covid item if 10% of its value comes 
	* from covid tender; the amount is over 10.000; it was purchased at least 100 times for 2020/2021. 
	* These thresholds can be changed throughout the study.
	
	
	
	*** Leandro Veloso made that method following his experience without checking the literature. 
	*** It is possible that exist other methods are much more efficient to classify covid products.
}
.
