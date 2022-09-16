* Made by Leandro Veloso
* Main: Participants data

* reading participants data
use "${path_KCP_BR}/1-data\2-imported/Portal-03-participants_level-panel",clear

gen id_bidding = substr(id_item ,1,17)

merge m:1 id_bidding using "${path_project}/1_data/01-tender_data", ///
 keepusing(methods D_covid D_law_926_2020 id_ug id_top_organ id_organ uf)

keep if _merge==3
drop _merge id_bidding
  
* Quarter
gen year_quarter = yq(year(dofm(year_month)),quarter(dofm(year_month)))
format %tq year_quarter

* Including firm information
merge m:1 id_bidder	 using "${path_project}/1_data/02-firm_caracteristcs", keep(1 3) ///
	keepusing(id_bidder cnae20 great_sectors SME porte_empresa  uf_estab date_simples_end)
drop _merge

* Saving
compress
save "${path_project}/1_data/03-participants_data",replace		
