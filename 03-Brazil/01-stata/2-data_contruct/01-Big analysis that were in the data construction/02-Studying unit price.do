
	global path_KCP_BR    	"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\04-KCP\01-KCP-Brazil"
		global path_firm   		"C:\Users\leand\Dropbox\3-Profissional\00-Base de dados\06-socios\6_clean"	
 		global path_project 	"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\06-Covid_Brazil"
		global path_code 		"C:\Users\leand\Dropbox\3-Profissional\08-Projetos-pessoais\10-GitHub\03-Projects\5-DIME-procurement-team\3-emergency-response-procurement\03-Brazil\01-stata"
		global path_rais   		"C:\Users\leand\Dropbox\3-Profissional\00-Base de dados\02-Rais-estabelecimento\5-clean_data\1-rais-estabelecimento\1-stata"	


global path_procurement  "C:\Users\leand\Dropbox\3-Profissional\00-Base de dados\07-Contas Publicas"
global path_item_compras "C:\Users\leand\Dropbox\3-Profissional\00-Base de dados\07-Contas Publicas\02-raw\03-updating-data\02-item_data"
 
 * 1: Data from item compras- details
{
	foreach year of numlist 2015/2022 { 
		use  "${path_item_compras}/COMPRAS-02-itens-detail-`year'",clear

		gen int  N_string_details_extra = length(description_item)
		gen byte D_no_extra_description = N_string_details_extra==2

		keep id_item code_item type_product N_string_details_extra D_no_extra_description
		
		tempfile item_`year'
		save	`item_`year''
	}
	.

	clear
	foreach year of numlist 2015/2022 {
		append using `item_`year''
	}
	.
	
	gduplicates drop id_item, force
	
	tempfile item
	save	`item'
}
.

* 2: Data from item compras 
{
	foreach year of numlist 2015/2022 { 
		use  "${path_item_compras}/COMPRAS-02-itens-`year'",clear
		
		keep id_item item_measure item_measure_agr qtd_item value_item_estimated D_item_sustentable D_law_7174 benefity judgment_criterion

		rename value_item_estimated value_compras
		rename qtd_item			    qtd_item_compras

		tempfile item_compras_`year'
		save	`item_compras_`year''
	}
	.

	clear
	foreach year of numlist 2015/2022 {
		append using `item_compras_`year''
	}
	.
	
gduplicates drop id_item, force
	tempfile item_compras 
	save	`item_compras'
}
.
 
* 3: join all
{
	use "${path_procurement}/03-clean/PORTAL-02-item-panel",clear
		
	gduplicates drop id_item, force
	
	* Merge play
	merge 1:m id_item using  ///
		"${path_procurement}/03-clean/PORTAL-02-item-code",  keepusing( id_item type_item item_?d_code item_5d_name   item_2d_name  item_5d_name_eng) keep(3) nogen

	
	merge 1:1 id_item  using `item',nogen keep(3) 
	
	
	merge 1:1 id_item  using `item_compras', nogen keep(3) 
		
}
.

rename code_item item_6d_code
replace item_6d_code = (6-length(item_6d_code))*"0" +item_6d_code if length(item_6d_code)<=6

order item_6d_code item_5d_code   type_product id_item year_month qtd_item value_item

drop type_item
gen     type_item = "Product"  if type_product == 1
replace type_item = "Service"  if type_product == 2
    
* Including 
merge m:1 type_item item_5d_code using "${path_project}/1_data/03-covid_item-item_level", ///
	keepusing(type_item item_5d_code  Covid_group_level Covid_item_level) nogen keep(3)		
compress
save "${path_procurement}/05-output/1-data_temp/item_data_temp",replace


* 6: getting number of features
{

	use "${path_procurement}/02-raw/03-others_sources/1-catmat_catser/catmat-features.dta",clear

	keep item_6d_code N_features_item

	gen  type_item =   "Product"
 	gduplicates drop item_6d_code, force

	merge 1:m item_6d_code type_item using   "${path_procurement}/05-output/1-data_temp/item_data_temp", keep(3 2) nogen 
}


compress
save "${path_procurement}/05-output/1-data_temp/Item_complete_auction",replace


* Check value 
{ 
	use "${path_procurement}/05-output/1-data_temp/Item_complete_auction",clear
	drop value_compras qtd_item_compras

	keep if type_item == "Product" & type_product ==1
	drop type_item type_product description item_1d_code item_3d_code
	keep if N_features_item!=.


	drop D_item_sustentable	D_law_7174	 	benefity	judgment_criterion purchase_method

	sort year_month id_bidding id_item
	 
	tab Covid_item_level

	order Covid_item_level item_6d_code item_5d_code N_features_item year_month qtd_item	value_item	unit_price item_measure	item_measure_agr N_string_details_extra	D_no_extra_description

	order year_month Covid_item_level item_6d_code item_5d_code

	gegen item_6d_code_num = group(item_6d_code)
	gen year = year(dofm(year_month))

		
	bys item_5d_code   item_measure:  gen N_measures_purchase_year = _N
	bys item_5d_code  : gen N_purchase_year = _N
	
	gen rate_measure = N_measures_purchase_year/N_purchase_year
	format %4.2fc rate_measure


	gegen max_rate = max(rate_measure), by(item_5d_code)

	gegen measures = group(item_measure)
	gcollapse (mean) max_rate avg_price = unit_price N_string_details_extra N_features_item (sd) sd_price = unit_price  ///
			 (nunique) N_6d = item_6d_code_num N_measures = measures , by(year Covid_item_level item_5d_code item_5d_name) freq(N_purchases)

	keep if inrange(year,2015,2021)
			 
	bys item_5d_code: keep if _N==7		 

	tab year Covid_item_level

	* High frequence
	cap drop restriction N_prod*
	gen restriction = .
	gen N_prod_0   = .
	gen N_prod_1   = .
	gen N_prod_2   = .
	gen N_prod_3   = .



	 local k = 0
	forvalues restriction = 0(25)500 {
		di as white "`restriction'"
		local k = `k'+1
		
		cap drop D_freq_upper
		gen D_freq_upper = N_purchases >=`restriction' & N_purchases!=.
		
		cap drop tag_aux
		bys item_5d_code D_freq_upper: gen tag_aux = _N==7 & D_freq_upper==1

	 sort restriction
		replace restriction = `restriction' if _n==`k'
		
		count if tag_aux==1 & year==2015 & Covid_item_level==0
			replace N_prod_0 =  r(N)         if _n==`k'
		count if tag_aux==1 & year==2015 & Covid_item_level==1
			replace N_prod_1 =  r(N)         if _n==`k'
		count if tag_aux==1 & year==2015 & Covid_item_level==2
			replace N_prod_2 =  r(N)         if _n==`k'
		count if tag_aux==1 & year==2015 & Covid_item_level==3
			replace N_prod_3 =  r(N)         if _n==`k'
	}

	sort restriction



		global High_covid_scatter_opt	connect(l) sort mcolor("98 190 121")   lcolor("98 190 121")  lp(solid)
		global Medium_covid_scatter_opt connect(l) sort mcolor("104 172 32")   lcolor("104 172 32")  lp(dot)  
		global Low_covid_scatter_opt 	connect(l) sort mcolor("180 182 26")   lcolor("180 182 26")  lp(dot) 
		global No_covid_scatter_opt 	connect(l) sort mcolor("233 149 144")  lcolor("233 149 144") lp(dash)
		

	* graphs configuration
	global opt_year xlabel(0(25)500 , angle(90))  /*
		*/ graphregion(color(white)) xsize(10) ysize(5)  /*
		*/ title("")  xline( 2020 ,  lc(gs8) lp(dash))

	global group_covid "Covid_item_level" 
	  
	* Plotting
	tw 		(scatter N_prod_3 restriction  if restriction>=50, ${High_covid_scatter_opt}		) ///
		|| 	(scatter N_prod_2 restriction  if restriction>=50, ${Medium_covid_scatter_opt} 	) ///
		||	(scatter N_prod_1 restriction  if restriction>=50, ${Low_covid_scatter_opt} 		) ///
		|| 	(scatter N_prod_0 restriction  if restriction>=50, ${No_covid_scatter_opt} 		) ///
		,  legend(order( 1 "High Covid" 2 "Medium Covid" 3 "low Covid" 4 "No Covid")  col(4))   	  ///
		note("`note_scatter'") ///
		 ${opt_year}  
}
.
 
* Let's take 200
{ 
	local restriction 50
	cap drop D_freq_upper
	gen D_freq_upper = N_purchases >=`restriction' & N_purchases!=.

	cap drop tag_aux
	bys item_5d_code D_freq_upper: gen tag_aux = _N==7 & D_freq_upper==1
	tab tag_aux
	keep if tag_aux==1

	 format  %60.0g item_5d_name

	tab year Covid_item_level

	*keep if Covid_item_level==3
	sort item_5d_code year

	local y  sd_price
	local x  N_measures

	 
	gcollapse (mean)  max_rate avg_price	sd_price	N_6d	N_measures	N_purchases N_string_details_extra N_features_item, by(Covid_item_level	item_5d_code	item_5d_name)
}


{ 
	gen coef_var = sd_price/avg_price	

	format %10.2fc max_rate avg_price	sd_price	N_6d	N_measures	N_purchases coef_var N_features_item N_string_details_extra

		global High_covid_scatter_opt	 mcolor("98 190 121")  
		global Medium_covid_scatter_opt  mcolor("104 172 32")  
		global Low_covid_scatter_opt 	 mcolor("180 182 26")  
		global No_covid_scatter_opt 	 mcolor("233 149 144") 
		
	local y "coef_var"	
	local x "N_6d"


	tab Covid_item_level

	tab Covid_item_level if coef_var<=15
	tab Covid_item_level if coef_var<=10
	tab Covid_item_level if coef_var<=9
	gsort -coef_var
	tab Covid_item_level if coef_var<=5
	tab Covid_item_level if coef_var<=2

	gsort -Covid_item_level -max_rate   
	bro  
	
	tab Covid_item_level if max_rate  >=0.7
	keep if max_rate  >=0.7
	
	* Getting products that is not necessary more specification
	gsort -N_6d
	bro if Covid_item_level==3
	
	tab Covid_item_level if N_string_details_extra==2
	keep if N_string_details_extra==2
	drop N_string_details_extra

	tab Covid_item_level
	tab Covid_item_level if coef_var    <=  6
	keep if coef_var    <=  6 

	tab Covid_item_level if N_6d        <= 150
	keep if N_6d        <= 150

	save  "${path_procurement}/05-output/1-data_temp/Select_products-item-5d",replace

}
.


use "${path_procurement}/05-output/1-data_temp/Item_complete_auction",clear

keep 	if ///
	inlist(item_5d_code,"01306", "01316", "01377" ,"00433", "13793", "18189", "13831") | ///
	inlist(item_5d_code,"01203","13590", "00373", "12848", "13793")

merge m:1 item_5d_code using   "${path_procurement}/05-output/1-data_temp/Select_products-item-5d"

keep if _merge==3
 
keep item_5d_code item_6d_code year_month	qtd_item	value_item  unit_price N_features_item item_measure item_measure_agr Covid_item_level ///
	avg_price	sd_price	N_6d	N_measures	N_purchases	coef_var item_5d_name	item_5d_name_eng
 format %30.0g  item_5d_name	item_5d_name_eng

order item_5d_code item_6d_code year_month	qtd_item	value_item unit_price  N_features_item item_measure item_measure_agr Covid_item_level ///
	avg_price	sd_price	N_6d	N_measures	N_purchases	coef_var item_5d_name	item_5d_name_eng

sort item_5d_code	item_6d_code year_month
 
gen log_unit_price = log(unit_price)
gen log_qtd_item   = log(qtd_item)
gen log_value	   = log(value_item)

* bys item_5d_code (log_unit_price): drop if (_n/_N)<=0.02 |  (_n/_N)>=0.98

* Main medida
{ 
	gen year = year(dofm(year_month))

	bys item_5d_code   item_measure:  gen N_measures_purchase_year = _N
	bys item_5d_code  : gen N_purchase_year = _N

	gen rate_measure = ceil(100*N_measures_purchase_year/N_purchase_year)
	format %4.0fc rate_measure
	
	gegen max_rate = max(rate_measure), by(item_5d_code)
	gen main_unidade = max_rate == rate_measure
}
.

* Compras dados -> Portal da transparencia.
* Unit of measure -> reverse auction

gen beta_log_value		= .
gen beta_log_qtd_item	= .
gen beta_const 			= .

levelsof  item_5d_code, local(values)
foreach val of local values {	
	cap {
		logit main_unidade log_value log_qtd_item if item_5d_code == "`val'" 

		replace beta_log_value		= _b[log_value]		if item_5d_code =="`val'" 
		replace beta_log_qtd_item	= _b[log_qtd_item]	if item_5d_code =="`val'" 
		replace beta_const 			= _b[_cons]			if item_5d_code =="`val'" 
	}
}

* estimating probab
gen xb = beta_log_value * log_value + beta_log_qtd_item *log_qtd_item + beta_const
gen probab_main_class = 1/(1+exp(-xb))
 
gen probab_round = ceil(probab_main_class*10)
tab probab_round main_unidade    if Covid_item_level==3

decode item_5d_name_eng, gen(item_name_string)

cap mkdir "${path_procurement}/05-output/1-data_temp/graphs2"


*drop if        item_5d_code == 12092 & log_unit_price>=2
*drop if        item_5d_code == 13114 & log_unit_price>=2
*drop if        item_5d_code == 17880 & log_unit_price>=5

levelsof  item_5d_code, local(values)
foreach val of local values { 
    di as white  "`val'" 
 	preserve
		keep if item_5d_code ==  "`val'" 
		tw (histogram log_unit_price if main_unidade==1, color(green%30)) || ///
		   (histogram log_unit_price if main_unidade!=1, color(red%30)) , ///
					graphregion(color(white)) xsize(10) ysize(5) ///
					title("Covid level=`=Covid_item_level[1]'-`val': `=item_name_string[1]'", size(vsmall)) ///
					xtitle("log unit price") note("`=max_rate[1]'% share of main unit of measure")
					 
		graph export  "${path_procurement}/05-output/1-data_temp/graphs2/graph-`=Covid_item_level[1]'-`val'-`=item_name_string[1]'.png", replace as(png)
	
	restore
}
.

local val= "18087"
preserve
 	keep if item_5d_code ==  "`val'"  
	sum log_unit_price if probab_main_class>=0.5
	tw (histogram log_unit_price if main_unidade==1, color(green%30)) || ///
	   (histogram log_unit_price if main_unidade!=1, color(red%30)) , ///
				xline(`=r(min)' `=r(max)' , lp(dash) lc(gray)) xlabel(-5(1)10)  graphregion(color(white)) xsize(10) ysize(5) ///
				title("Covid level=`=Covid_item_level[1]'-`val': `=item_name_string[1]'", size(vsmall)) ///
				xtitle("log unit price") note("`=max_rate[1]'% share of main unit of measure [`=r(min)' , `=r(max)']")
				 
 restore

 
tab Covid_item_level

* drop list
drop if inlist(item_5d_code,"11016","08874","06250","13426","09749")
drop if inlist(item_5d_code,"00056", "01287", "02690", "03888", "04736", "05007", "05363")
drop if inlist(item_5d_code,"08833", "18358", "09749", "13426", "06250", "06991","17880")
drop if inlist(item_5d_code,"10422", "11016", "11903")


gen D_item_unit_price_sample = ///
	inlist(item_5d_code,"00012", "00024", "00046", "00074", "00108", "00176", "00200", "00205", "00421", "00431" ) ///
	inlist(item_5d_code,"00517", "00867", "01415", "02085", "02173", "02671", "05728", "07533", "08061", "09665" ) ///
	inlist(item_5d_code,"09748", "12240", "12254", "12820", "13092", "13114", "13768", "13824", "13828", "14017" ) ///
	inlist(item_5d_code,"14216", "17357", "17593", "18035", "18065", "18066", "18075", "18078", "18087")

* Creating upper_level
{
	gen upper_level = .
	replace upper_level =1.2 if item_5d_code =="00012"
	replace upper_level =5.0 if item_5d_code =="00024"
	replace upper_level =2.0 if item_5d_code =="00046"
	replace upper_level =5.0 if item_5d_code =="00074"
	replace upper_level =2.0 if item_5d_code =="00108"
	replace upper_level =2.5 if item_5d_code =="00176"
	replace upper_level =4.0 if item_5d_code =="00200"
	replace upper_level =3.0 if item_5d_code =="00205"
	replace upper_level =5.0 if item_5d_code =="00421"
	replace upper_level =2.5 if item_5d_code =="00431"
	replace upper_level =6.0 if item_5d_code =="00517"
	replace upper_level =4.5 if item_5d_code =="00867"
	replace upper_level =7.0 if item_5d_code =="01415"
	replace upper_level =7.0 if item_5d_code =="02085"
	replace upper_level =9.0 if item_5d_code =="02173"
	replace upper_level =6.0 if item_5d_code =="02671"
	replace upper_level =7.0 if item_5d_code =="05728"
	replace upper_level =7.5 if item_5d_code =="07533"
	replace upper_level =4.0 if item_5d_code =="08061"
	replace upper_level =7.0 if item_5d_code =="09665"
	replace upper_level =9.0 if item_5d_code =="09748"
	replace upper_level =8.0 if item_5d_code =="12240"
	replace upper_level =9.0 if item_5d_code =="12254"
	replace upper_level =9.0 if item_5d_code =="12820"
	replace upper_level =2.0 if item_5d_code =="13092"
	replace upper_level =6.0 if item_5d_code =="13114"
	replace upper_level =10  if item_5d_code =="13768"
	replace upper_level =6.0 if item_5d_code =="13824"
	replace upper_level =8.0 if item_5d_code =="13828"
	replace upper_level =5.5 if item_5d_code =="14017"
	replace upper_level =5.0 if item_5d_code =="14216"
	replace upper_level =5.0 if item_5d_code =="17357"
	replace upper_level =7.0 if item_5d_code =="17593"
	replace upper_level =3.0 if item_5d_code =="18035"
	replace upper_level =3.0 if item_5d_code =="18065"
	replace upper_level =2.0 if item_5d_code =="18066"
	replace upper_level =1.5 if item_5d_code =="18075"
	replace upper_level =2.0 if item_5d_code =="18078"
	replace upper_level =4.0 if item_5d_code =="18087"
}
.

* Creating lower_level
{
	gen lower_level = .
	replace lower_level =-2.0 if item_5d_code =="00012"
	replace lower_level =-1.0 if item_5d_code =="00024"
	replace lower_level =-3.0 if item_5d_code =="00046"
	replace lower_level = 1.0 if item_5d_code =="00074"
	replace lower_level =-1.0 if item_5d_code =="00108"
	replace lower_level =-1.0 if item_5d_code =="00176"
	replace lower_level = 1.0 if item_5d_code =="00200"
	replace lower_level =-3.0 if item_5d_code =="00205"
	replace lower_level = 2.0 if item_5d_code =="00421"
	replace lower_level =-1.0 if item_5d_code =="00431"
	replace lower_level =-1.0 if item_5d_code =="00517"
	replace lower_level = 2.0 if item_5d_code =="00867"
	replace lower_level = 2.0 if item_5d_code =="01415"
	replace lower_level =-3.0 if item_5d_code =="02085"
	replace lower_level =-1.0 if item_5d_code =="02173"
	replace lower_level = 1.0 if item_5d_code =="02671"
	replace lower_level = 2.5 if item_5d_code =="05728"
	replace lower_level = 3.0 if item_5d_code =="07533"
	replace lower_level = 1.5 if item_5d_code =="08061"
	replace lower_level = 3.0 if item_5d_code =="09665"
	replace lower_level = 3.0 if item_5d_code =="09748"
	replace lower_level = 3.0 if item_5d_code =="12240"
	replace lower_level = 2.0 if item_5d_code =="12254"
	replace lower_level = 0.0 if item_5d_code =="12820"
	replace lower_level =-2.0 if item_5d_code =="13092"
	replace lower_level =-4.0 if item_5d_code =="13114"
	replace lower_level = 6.5 if item_5d_code =="13768"
	replace lower_level = 0.0 if item_5d_code =="13824"
	replace lower_level = 3.0 if item_5d_code =="13828"
	replace lower_level = 0.0 if item_5d_code =="14017"
	replace lower_level = 0.0 if item_5d_code =="14216"
	replace lower_level = 0.0 if item_5d_code =="17357"
	replace lower_level = 0.5 if item_5d_code =="17593"
	replace lower_level = 0.0 if item_5d_code =="18035"
	replace lower_level = 0.0 if item_5d_code =="18065"
	replace lower_level =-1.0 if item_5d_code =="18066"
	replace lower_level =-1.0 if item_5d_code =="18075"
	replace lower_level =-1.0 if item_5d_code =="18078"
	replace lower_level = 0.0 if item_5d_code =="18087"
}
.


keep if inrange(log_unit_price,lower_level,upper_level )

levelsof  item_5d_code, local(values)
foreach val of local values { 
 	preserve
		
		keep if item_5d_code ==  "`val'" 
		sum log_unit_price if probab_main_class>=0.5
		tw (histogram log_unit_price , color(green%30)) || ///
		   (histogram log_unit_price if main_unidade==1, color(blue%30)) || ///
		   (histogram log_unit_price if main_unidade!=1, color(red%30)) , ///
					xline(`=r(min)' `=r(max)' , lp(dash) lc(gray))  graphregion(color(white)) xsize(10) ysize(5) ///
					title("Covid level=`=Covid_item_level[1]'-`val': `=item_name_string[1]'", size(vsmall)) ///
					xtitle("log unit price") note("`=max_rate[1]'% share of main unit of measure") ///
					legend(order(1 "all" 2 "main unit of measurement"  3 "others unit of measurement" ) col(3))
					  
		graph export  "${path_procurement}/05-output/1-data_temp/graphs/graph-`=Covid_item_level[1]'-`val'.png", replace as(png)
	restore
}
.

duplicates drop item_5d_code ,force
keep Covid_item_level   item_5d_code item_5d_name upper_level lower_level

save  "${path_procurement}/05-output/1-data_temp/list_products",replace







use "${path_procurement}/05-output/1-data_temp/Item_complete_auction",clear

merge   m:1 item_5d_code using "${path_procurement}/05-output/1-data_temp/list_products", keep(3)

duplicates drop item_5d_code, force 

tab Covid_item_level
gsort -Covid_item_level item_5d_code
bro Covid_item_level item_5d_code item_5d_name_eng item_5d_name    









 