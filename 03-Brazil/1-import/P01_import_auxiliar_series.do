* Made by 	Leandro Veloso 	 - leandrojpveloso@gmail.com  
* Objective: PIA clean process, select variables, rename it, label it and create vars
/*============================================================================*/ 

* 01: Deflator
{
    global path_project 	"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\06-Covid_Brazil"
	global path_ipca  "C:\Users\leand\Dropbox\3-Profissional\17-Github\03-projetos\Adm_data_project-02-classifications\05-deflatores"
	global base_deflator = 2019
	
	* IPCA monthly
	{ 
		import excel "${path_ipca}/ipca_202402SerieHist.xls",clear

		gen year = real(A)
		order year
		replace year =cond(year ==.,year[_n-1],year)
		keep if year!=. 
		rename B month

		gen index = real(C)
		drop if index==.
		keep year  month index
		
		* adj month
		replace month = "1" if month=="JAN"
		replace month = "2" if month=="FEV"
		replace month = "3" if month=="MAR"
		replace month = "4" if month=="ABR"
		replace month = "5" if month=="MAI"
		replace month = "6" if month=="JUN"
		replace month = "7" if month=="JUL"
		replace month = "8" if month=="AGO"
		replace month = "9" if month=="SET"
		replace month = "10" if month=="OUT"
		replace month = "11" if month=="NOV"
		replace month = "12" if month=="DEZ"
		destring month, replace

		gen D_base = year==${base_deflator} & month==12
		gsort -D_base
		gen base_year =index[1] 
		gen deflator_ipca = base_year /index
		 
		* 
		keep if year >=1996
		keep year month deflator_ipca
		sort year month
		gen year_month = ym(year, month)
			format %tm year_month
		
		order year_month  year month deflator_ipca
		* Saving label data 
		label data "IPCA monthly deflator base dez/${base_deflator}"
		save "${path_project}/1_data/01-import-data/ipca_deflator_month",replace
	}
	.
	
	* Year
	{
	    use "${path_project}/1_data/01-import-data/ipca_deflator_month",clear
		
		* Using december as reference
		keep if month ==12
		keep year deflator_ipca
		
 		* Saving label data 
		label data "IPCA year deflator base dez/${base_deflator}"
		
		compress
		save "${path_project}/1_data/01-import-data/ipca_deflator_year",replace
	}
}
.