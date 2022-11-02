* Made by Leandro Veloso
* Main: Winners level: item level restrict to items

* 1: Criteria for group
{
	import delim "${path_project}/1_data/06-group_covid_adjust.csv" , clear delim(",") 

	keep  type_item item_2d_code d_covid_adjust
	drop if item_2d_code==.
	duplicates drop  type_item item_2d_code, force
	 
	merge 1:1 type_item item_2d_code using "${path_project}/1_data/03-covid_items-group_level"

	keep if type_item=="Product"


	*gen rate_covid_purchase = N_covid_purchases/N_purchases 
	*rename rate_covid rate_value

	gen log_covid_purchase = log(N_covid_purchases)
	gen log_covid_value    = log(total_covid)
	
	export delim using "${path_project}/1_data/covid_test.csv", delim(",")

	cap drop probab
	logit D_covid_tag log_covid_value log_covid_purchase  
	estimate store logit_est
	predict probab,p


	cap drop D_min_covid
	gen D_min_covid = N_covid_purchases>=100

	*cap drop Covid_level
	*gen      Covid_level  = 0    
	*replace  Covid_level  =	1   if D_min_covid==1 & (rate_covid_purchase>= 0.007 | rate_value>=0.07)
	*replace  Covid_level  =	2   if D_min_covid==1 & (rate_covid_purchase>= 0.040 | rate_value>=0.04)
	*replace  Covid_level  =	3	if D_min_covid==1 & (rate_covid_purchase>= 0.030 & rate_value>=0.10)	 

	* Proportion
	cap drop Covid_level  
	gen      Covid_level  = 0    
	replace  Covid_level  =	1   if probab>=0.05 & probab!=.
	replace  Covid_level  =	2   if probab>=0.3  & probab!=.
	replace  Covid_level  = 3   if probab>=0.7  & probab!=.
	  
	* Classification
	{
		format %4.2fc probab rate_covid_purchase   probab
	
		set obs `=_N+1'  
		replace log_covid_purchase = 10 if _n==_N
		replace log_covid_value    = 25 if _n==_N

		set obs `=_N+1'  
		replace log_covid_purchase = 0  if _n==_N 
		replace log_covid_value    = 0  if _n==_N
		
		set obs `=_N+1'  
		replace probab 		       = 0 if _n==_N

		set obs `=_N+1'  
		replace probab 		       = 1 if _n==_N
	}
	. 
	 
	twoway (contour probab log_covid_purchase log_covid_value , heatmap ccuts(0.05 0.2 0.7 ) ///
		ccolors("233 149 144" "104 172 32" "180 182 26"   "98 190 121") ) || /// 
		(scatter log_covid_purchase log_covid_value  if d_covid_adjust==1, m(D)  mc( gs14) msize(large) ) ///
		(scatter log_covid_purchase log_covid_value  if Covid_level   ==3, m(c)  mc( gs7) ) ///
		(scatter log_covid_purchase log_covid_value  if Covid_level   ==2, m(X)  mc( gs4) ) ///
		(scatter log_covid_purchase log_covid_value  if Covid_level   ==1, m(x)  mc( gs2)   msize(small))  ///
		(scatter log_covid_purchase log_covid_value  if Covid_level   ==0, m(x)  mc( pink)   msize(tiny)) ///
		/// (function y=15+ -12/25*x                       ,range(5 25)  color("98 190 121")  )  || ///
 		, legend(order( 1 "Covid Taged"  2 "High Covid" 3 "Medium Covid" 4 "low Covid" 5 "No Covid")  col(3)) ///
		graphregion(color(white)) xtitle("log(total expenses on covid tender)") ///		
		 ytitle("log(total item purchases on covid tender)")  
	 
	 
	graph export "${path_project}/4_outputs/3-Figures/06-Covid_group_estimation.png", replace as(png)
	
	
	* Final Criteria;
	twoway  /// 
	(function y= 0  						,range(0              25) recast(area)  color("233 149 144")  base(10) )  ///
	(function y= 1/(x+ log( 2e6))+log( 250) ,range(`=log( 2e6)' 25) recast(area)  color("104 172 32")  base(10) )  ///
	(function y= 1/(x+ log( 6e6))+log( 400) ,range(`=log(6e6)' 25) recast(area)  color("180 182 26")  base(10) )  ///
	(function y= 1/(x+ log( 2e7))+log(1000) ,range(`=log(2e7)' 25) recast(area) color("98 190 121")  base(10) )   ///
	(scatter log_covid_purchase log_covid_value  if d_covid_adjust==1, m(D)  mc( gs14) msize(large) ) || ///
	(scatter log_covid_purchase log_covid_value  if Covid_level   ==3, m(c)  mc( gs7) ) ///
	(scatter log_covid_purchase log_covid_value  if Covid_level   ==2, m(X)  mc( gs4) ) ///
	(scatter log_covid_purchase log_covid_value  if Covid_level   ==1, m(x)  mc( gs2)   msize(small))  ///
	(scatter log_covid_purchase log_covid_value  if Covid_level   ==0, m(x)  mc( pink)   msize(tiny)) ///
	, legend(order( 1 "Covid Taged"  2 "High Covid" 3 "Medium Covid" 4 "low Covid" 5 "No Covid")  col(3)) ///
	graphregion(color(white)) xtitle("The proportion of expenses on covid tender") ///
	 ytitle("The proportion of covid lots on covid tender")   
	 
	 
	* K-means
	* Final Criteria
	twoway  /// 
	(function y= 0  						,range(0              25) recast(area)  color("233 149 144")  base(10) )  ///
	(function y= 1/(x+ log( exp(16)))  +log(exp(5.5)) ,range(`=log(exp(16))' 25) recast(area)  color("104 172 32")  base(10) )  ///
	(function y= 1/(x+ log( exp(17))) +log( exp(7)) ,range(`=log(exp(17))' 25) recast(area)  color("180 182 26")  base(10) )  ///
	(function y= 1/(x+ log( exp(22)))+log(exp(7)) ,range(`=log(exp(22))' 25) recast(area) color("98 190 121")  base(10) )   ///
	(scatter log_covid_purchase log_covid_value  if d_covid_adjust==1, m(D)  mc( gs14) msize(large) ) || ///
	(scatter log_covid_purchase log_covid_value  if Covid_level   ==3, m(c)  mc( gs7) ) ///
	(scatter log_covid_purchase log_covid_value  if Covid_level   ==2, m(X)  mc( gs4) ) ///
	(scatter log_covid_purchase log_covid_value  if Covid_level   ==1, m(x)  mc( gs2)   msize(small))  ///
	(scatter log_covid_purchase log_covid_value  if Covid_level   ==0, m(x)  mc( pink)   msize(tiny)) ///
	, legend(order( 1 "Covid Taged"  2 "High Covid" 3 "Medium Covid" 4 "low Covid" 5 "No Covid")  col(3)) ///
	graphregion(color(white)) xtitle("The proportion of expenses on covid tender") ///
	 ytitle("The proportion of covid lots on covid tender")   
	
		* K-means
	* Final Criteria
	twoway  /// 
	(function y= 0  						,range(0              25) recast(area)  color("233 149 144")  base(10) )  ///
	(function y= 1/(x+ log( 57099))  +log(  6) ,range(`=log(  57099)' 25) recast(area)  color("104 172 32")  base(10) )  ///
	(function y= 1/(x+ log( 253072)) +log( 105) ,range(`=log( 253072)' 25) recast(area)  color("180 182 26")  base(10) )  ///
	(function y= 1/(x+ log( 36373389))+log(1390) ,range(`=log(36373389)' 25) recast(area) color("98 190 121")  base(10) )   ///
	(scatter log_covid_purchase log_covid_value  if d_covid_adjust==1, m(D)  mc( gs14) msize(large) ) || ///
	(scatter log_covid_purchase log_covid_value  if Covid_level   ==3, m(c)  mc( gs7) ) ///
	(scatter log_covid_purchase log_covid_value  if Covid_level   ==2, m(X)  mc( gs4) ) ///
	(scatter log_covid_purchase log_covid_value  if Covid_level   ==1, m(x)  mc( gs2)   msize(small))  ///
	(scatter log_covid_purchase log_covid_value  if Covid_level   ==0, m(x)  mc( pink)   msize(tiny)) ///
	, legend(order( 1 "High Covid" 2 "Medium Covid" 3 "low Covid" 4 "No Covid")  col(2)) ///
	graphregion(color(white)) xtitle("The proportion of expenses on covid tender") ///
	 ytitle("The proportion of covid lots on covid tender")  name(b,replace)
		 
	 
	 
	 
	
	graph export "${path_project}/4_outputs/3-Figures/06-Covid_group_estimation-square.png", replace as(png)
	
	twoway (contour probab log_covid_purchase log_covid_value , heatmap ccuts(0.05 0.2 0.7 ) ///
			ccolors("233 149 144" "104 172 32" "180 182 26"   "98 190 121") ) || ///
			(function y= 10                       ,range(0 25) recast(area) color("98 190 121")  base(0) )  || ///
			(function y= (sqrt(525-(x-1.5)^2)/2.5),range(0 25) recast(area) color("104 172 32")  base(0) )  || ///
			(function y= (sqrt(400-(x-3)^2)/2.5),range(0 25) recast(area) color("180 182 26")  base(0) )  || ///
			(function y= (sqrt(300-(x-5)^2)/2.5),range(0 25) recast(area) color("233 149 144")  base(0) )  || ///
			(scatter log_covid_purchase log_covid_value  if d_covid_adjust==1, m(D)  mc( gs14) msize(large) ) || ///
			(scatter log_covid_purchase log_covid_value  if Covid_level   ==3, m(c)  mc( gs7) ) ///
			(scatter log_covid_purchase log_covid_value  if Covid_level   ==2, m(X)  mc( gs4) ) ///
			(scatter log_covid_purchase log_covid_value  if Covid_level   ==1, m(x)  mc( gs2)   msize(small))  ///
			(scatter log_covid_purchase log_covid_value  if Covid_level   ==0, m(x)  mc( pink)   msize(tiny)) ///
			, legend(order( 1 "Covid Taged"  2 "High Covid" 3 "Medium Covid" 4 "low Covid" 5 "No Covid")  col(3)) ///
			graphregion(color(white)) xtitle("The proportion of expenses on covid tender") ///
			 ytitle("The proportion of covid lots on covid tender")  
			
	graph export "${path_project}/4_outputs/3-Figures/06-Covid_group_estimation-circle.png", replace as(png)
	
	* Data covid
	drop D_covid_tag _*
	
	order type_item item_2d_code d_covid_adjust Covid_level
	
	* 
	drop if N_purchases==.
	compress
	save  "${path_project}/1_data/06-covid_item_group",replace
}
.

* 2: Data to estimate-covid product
{
	use "${path_project}/1_data/03-covid_item-item_level",clear
	 
	keep if type_item=="Product"

	gen rate_covid_purchase = N_covid_purchases/N_purchases 
	rename rate_covid rate_value

	gen log_covid_purchase = log(N_covid_purchases)
	gen log_covid_value    = log(total_covid)

	destring item_2d_code,replace 
	merge m:1  item_2d_code using "${path_project}/1_data/06-covid_item_group", keepusing(item_2d_code Covid_level)

	keep if Covid_level==3

	keep if inlist(item_2d_code, 72, 79, 84)

	tab item_2d_code

	count if total_covid<=1000


	hist log_covid_value, bin(100)

	keep if N_purchases>=100 
	keep if total_covid>=1000
	keep if total      >=10000


	cap drop D_min_covid
	gen D_min_covid = N_covid_purchases>=3

	cap drop Covid_item_level
	gen      Covid_item_level  =    0    
	replace  Covid_item_level  =	1   if D_min_covid==1 & (rate_covid_purchase>= 0.007 | rate_value>=0.07)
	replace  Covid_item_level  =	2   if D_min_covid==1 & (rate_covid_purchase>= 0.040 | rate_value>=0.04)
	replace  Covid_item_level  =	3	if D_min_covid==1 & (rate_covid_purchase>= 0.030 & rate_value>=0.10)	 
	tab Covid_item_level, m
} 
.

* 3: Graph estimation
{
	use "${path_project}/1_data/03-covid_item-item_level-manual_class",clear

	sort Covid_item_level
	*gen d_covid_adjust=.

	*cap drop d_covid_adjust
	*gen d_covid_adjust = Covid_item_level  >=	2 & 
	tab d_covid_adjust

	cap drop probab
	logit d_covid_adjust log_covid_value log_covid_purchase  
	estimate store logit_est
	predict probab,p

	* Adjust to graph
	{
		format %4.2fc probab rate_covid_purchase rate_value probab

		set obs `=_N+1'  
		replace log_covid_purchase = 10 if _n==_N
		replace log_covid_value    = 25 if _n==_N

		set obs `=_N+1'  
		replace log_covid_purchase = 0  if _n==_N 
		replace log_covid_value    = 0  if _n==_N

		set obs `=_N+1'  
		replace probab 		       = 0 if _n==_N

		set obs `=_N+1'  
		replace probab 		       = 1 if _n==_N
	}
	. 

	cap drop z_*
 
	* Checking
	twoway (contour probab log_covid_purchase log_covid_value , heatmap ccuts(0.5 0.85 0.97 )  ///
	ccolors("233 149 144" "104 172 32" "180 182 26"   "98 190 121") )	|| /// 
 	(scatter log_covid_purchase log_covid_value  if d_covid_adjust  ==1, mc( gs7)  m(X)   ) ///
	(scatter log_covid_purchase log_covid_value  if d_covid_adjust  ==0 ,mc( pink) m(c)  ) ///	
	/// (function y=15+ -12/25*x                       ,range(5 25)  color("98 190 121")  )  || ///
	, legend(order( 1 "Covid Taged"  2 "No Covid")  col(3)) ///
	graphregion(color(white)) xtitle("The proportion of expenses on covid tender") ///		
	 ytitle("The proportion of covid lots on covid tender")  
	 
	graph export "${path_project}/4_outputs/3-Figures/06-Covid_item_estimation.png", replace as(png)
	
	* Final Criteria
	twoway (contour probab log_covid_purchase log_covid_value , heatmap ccuts(0.5 0.85 0.97 )  ///
	ccolors("233 149 144" "104 172 32" "180 182 26"   "98 190 121") )	|| /// 
	(function y= 0  						,range(0              22) recast(area)  color("233 149 144")  base(9) )  ///
	(function y= 1/(x+ log( 10000))+log( 5) ,range(`=log( 10000)' 22) recast(area)  color("104 172 32")  base(9) )  ///
	(function y= 1/(x+ log( 50000))+log(15) ,range(`=log( 50000)' 22) recast(area)  color("180 182 26")  base(9) )  ///
	(function y= 1/(x+ log(300000))+log(50) ,range(`=log(300000)' 22) recast(area) color("98 190 121")  base(9) )   ///
	(scatter log_covid_purchase log_covid_value  if d_covid_adjust  ==1, mc( gs7)  m(X)   ) ///
	(scatter log_covid_purchase log_covid_value  if d_covid_adjust  ==0 ,mc( pink) m(c)  ) 	///		
	/// (function y=15+ -12/25*x                       ,range(5 25)  color("98 190 121")  )  || ///
	, legend(order( 1 "Covid Taged"  2 "High Covid" 3 "Medium Covid" 4 "low Covid" 5 "No Covid")  col(3)) ///
	graphregion(color(white)) xtitle("The proportion of expenses on covid tender") ///		
	 ytitle("The proportion of covid lots on covid tender")  
	 
	graph export "${path_project}/4_outputs/3-Figures/06-Covid_item_estimation-square.png", replace as(png)

}
.
