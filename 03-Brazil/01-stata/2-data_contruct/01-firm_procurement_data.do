* Made by Leandro Veloso
* Main: Creating firm data
 
* 1: Set of firms
{
	use id_bidder using "${path_KCP_BR}/1-data\2-imported/Portal-03-participants_level-panel",clear
		
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
	save "${path_project}/1_data/01-firm_caracteristcs",replace
}
.

