* Made by Leandro Veloso
* Main: Creating data to understand covid indicators

* 0: Setting stata
{
	* Clean stata console
	clear all
	cls

	* Set options
	set varabbrev on, perm
	set more off, perm
	set matsize 11000, perm

	* defying path
	* 1: Leandro Justino
	if "`c(username)'" == "leand" {	
		global path_KCP_BR    	"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\04-KCP\01-KCP-Brazil"
		global path_firm   		"C:\Users\leand\Dropbox\3-Profissional\00-Base de dados\06-socios\6_clean"	
 		global path_project 	"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\06-Covid_Brazil"
		global path_rais   		"C:\Users\leand\Dropbox\3-Profissional\00-Base de dados\02-Rais-estabelecimento\5-clean_data\1-rais-estabelecimento\1-stata"	
 	}
	.
	
	* 2:XXXX
	if "`c(username)'" == "XXXX" {
		global path_project 	""
 	}
	.
	
	* 3:ZZZZ
	if "`c(username)'" == "ZZZZ" {
		global path_project 	""
 	}	
	.
	
	* creating folder
	cap mkdir "${path_project}/1_data"
	cap mkdir "${path_project}/2_material"
	cap mkdir "${path_project}/3_writting"
	cap mkdir "${path_project}/4_outputs"
	cap mkdir "${path_project}/4_outputs/1-data_temp"
	cap mkdir "${path_project}/4_outputs/2-Tables"
	cap mkdir "${path_project}/4_outputs/3-Figures"
	cap mkdir "${path_project}/4_outputs/4-TexCompile"
	cap mkdir "${path_project}/4_outputs/1_datatemp"
	
	* graphs configuration
	global graph_option graphregion(color(white)) xsize(10) ysize(5)
}
.

* 1: Firm data
{
	* 1: Set of firms
	{
		use id_bidder using "${path_KCP_BR}/1-data\2-imported/Bid_item_participant_level-panel",clear
			
		* removing duplications
		gduplicates drop id_bidder, force
		gen cnpj8 = substr(id_bidder,1,8) if length(id_bidder)==14
		
		* tempfile
		save "${path_project}/4_outputs/1_datatemp/P01-01_set_firms",replace
	}
	.

	* 2: Getting sectors
	{
		foreach year of numlist 2013/2020 {
 			use cnpj_cei cnae20 great_sectors natureza_juridica uf_estab munic_estab ///
				using "${path_rais}/rais_estab-`year'",clear
			
			* Duplications
			gduplicates drop cnpj_cei, force
			rename cnpj_cei id_bidder
			merge 1:1 id_bidder using "${path_project}/4_outputs/1_datatemp/P01-01_set_firms", keep(2 3)
			drop _merge
			
			tempfile rais_`year'
			save `rais_`year''
		}
		.
		
		clear
		foreach year of numlist 2013/2020 {
			append using `rais_`year''
		}
		.
		
		* Dropping
		gduplicates drop id_bidder, force
		
		save "${path_project}/4_outputs/1_datatemp/P01-02_set_firms",replace
	}
	.
	
	* 3: Getting sectors
	{
		* Reading data
		use "${path_project}/4_outputs/1_datatemp/P01-02_set_firms",clear
		
		* Merging to get extra information
		merge m:1 cnpj8 using  "${path_firm}/empresa_social_contract", nogen keep(1 3) ///
			keepusing(cnpj8	D_simples	D_mei	D_cpf	porte_empresa date_simples_start	date_simples_end)
		
		
		* gen SME: MEI, ME, EPP or cpf
		gen byte SME = inlist(porte_empresa,1,2) | D_mei==1 | length(id_bidder)==11
		
		* Tabulating
		tab SME
		order id_bidder cnpj8	D_simples	D_mei porte_empresa SME
		sort  id_bidder cnpj8	D_simples	D_mei porte_empresa SME
			
		* Saving
		compress
		save "${path_project}/1_data/1_firms_caracteristics",replace
	}
	.
}
.

* 2: Data participants:
{	
	* reading participants data
	use "${path_KCP_BR}/1-data\2-imported/Bid_item_participant_level-panel",clear
	
	* modality
	gen modality = substr(id_item,7,2)
	tab modality
	
	* Keeping auction + FA
	keep if modality=="05"
	drop modality 
	
	* Quarter
	gen year_quarter = yq(year(dofm(year_month)),quarter(dofm(year_month)))
	format %tq year_quarter
	
	* Including firm information
	merge m:1 id_bidder	 using  "${path_project}/1_data/1_firms_caracteristics", keep(1 3) ///
		keepusing(id_bidder cnae20 great_sectors SME porte_empresa  uf_estab date_simples_end)
	drop _merge
 
	* Saving
	compress
	save "${path_project}/1_data/1_participants_data",replace		
}
.

* 3: Winners: I can include more variables
{
	* 1: Preparing service list to merge
	{
		use "${path_KCP_BR}/1-data/2-imported/catser-service_list",clear

		replace code_item ="s" + (6-length(code_item))*"0" + code_item
 
		destring code_item_group code_item_class, replace
		
		* labmask in the hwhole data take a long
		foreach var in group class {
			preserve
 				keep code_item_`var'_name code_item_`var'
				gduplicates drop code_item_`var', force
				
				* creating the label variable
				labmask code_item_`var'	, val(code_item_`var'_name) lblname(label_`var')
				
				* I need to a data set to append
				clonevar unusuless_variable = code_item_`var'

				keep unusuless_variable
				drop if _n>=1
				tempfile data_auxiliary_`var'
				save `data_auxiliary_`var''
			restore
		}
		.
	
		* Including extra variables using append to get the label
		foreach var in group class {
			append using  `data_auxiliary_`var''

			label val code_item_`var' label_`var'
			drop code_item_`var'_name
			drop unusuless_variable	
		}
		.
		
		keep code_item code_item_class code_item_group 
		order code_item code_item_class code_item_group 
		
		format %30.0g *item_*
		
		rename code_item_class code_serv_class
		rename code_item_group code_serv_group
		
		tempfile service
		save "${path_project}/4_outputs/1-data_temp/service_to_merge",replace
	}
	
	* 2: Preparing product list to merge
	(
		use  "${path_KCP_BR}/1-data/2-imported/catmat-material_list",clear
		replace code_item = "p" +(6-length(code_item))*"0" + code_item

		order code_item code_item_group	code_item_group_name	code_item_class	code_item_class_name			
		keep  code_item code_item_group	code_item_group_name	code_item_class	code_item_class_name			
		
		destring code_item_group code_item_class, replace
		
		* labmask in the hwhole data take a long
		foreach var in group class {
			preserve
				keep code_item_`var'_name code_item_`var'
				gduplicates drop
				
				* creating the label variable
				labmask code_item_`var'	, val(code_item_`var'_name) lblname(label_`var')
				
				* I need to a data set to append
				clonevar unusuless_variable = code_item_`var'

				keep unusuless_variable
				drop if _n>=1
				tempfile data_auxiliary_`var'
				save `data_auxiliary_`var''
			restore
		}
		.
		
		* Including extra variables using append to get the label
		foreach var in group class {
			append using  `data_auxiliary_`var''

			label val code_item_`var' label_`var'
			drop code_item_`var'_name
			drop unusuless_variable	
		}
		.
		format %30.0g *item_*	
		
		
		rename code_item_class code_prod_class
		rename code_item_group code_prod_group
		
		tempfile service
		save "${path_project}/4_outputs/1-data_temp/product_to_merge",replace
	}
	.
		

 
	* Reading
	
	local short_list_var id_item code_item type_product qtd_item item_measure value_item_estimated
	use `short_list_var' using "${path_KCP_BR}/1-data/2-imported/itens_bidding.dta",clear

	* Preparing to merge
	replace code_item = "p" +(6-length(code_item))*"0" + code_item if type_product == "material":lab_type_product 
	replace code_item = "s" +(6-length(code_item))*"0" + code_item if type_product == "service":lab_type_product  
	
	* includin item code
	merge m:1 code_item using "${path_project}/4_outputs/1-data_temp/product_to_merge", keep(1 3) nogen
	
	merge m:1 code_item using "${path_project}/4_outputs/1-data_temp/service_to_merge", keep(1 3) nogen


}
.


 