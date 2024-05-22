* Made by Leandro Veloso
* Main: Historic to copy and paste the relevant outputs to report
 
global report	 "C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\06-Covid_Brazil\4_outputs\6-report_selection_2024"

 
* Section 3: 
{
	* Line 96
	copy 	"${path_project}/4_outputs/2-Tables/P8-extra_outputs.xlsx" ///
			"${report}/section_3-Covid-items.xlsx",replace
	

	global time year_semester

	foreach graphs in ///
	"n_lots_by_covid.png"			///
	"log_n_lots_by_covid.png"        ///
	"rate_lots_by_covid.png"         ///
	"rate_2019_lots_by_covid.png"    ///
	"volume_by_covid.png"            ///
	"log_volume_by_covid.png"        ///
	"rate_2019_volume_by_covid.png"  ///
	"rate_volume_by_covid.png"       ///
	"avg_volume_by_covid.png"        ///
	"log_avg_volume_by_covid.png"	{

		copy "${path_project}/4_outputs/3-Figures/P8-${time}-`graphs'" ///
			 "${report}/section_3-`graphs'", replace	

	}
	
}
.

* Section 4: 02-tender_graphs: 
{
	* Figure X4
	copy "${path_project}/4_outputs/3-Figures/P2-quarter-Covid_tender_n_tenders-method.png"	 ///
		 "${report}/section_4-quarter-N_tenders-method.png"	 ,replace 
 
 
	global outcome_selected N_participants SME share_SME log_unit_price_filter D_auction decision_time_trim D_new_winner

	foreach y_dep of varlist decision_time_trim {
		copy "${path_project}/4_outputs/3-Figures/P5-avg_graph_`y_dep'.png"	 ///
			 "${report}/section_4-avg_trend-`y_dep'.png"	 ,replace 
			  
		copy "${path_project}/4_outputs/2-Tables/P05-TWFE-time-`y_dep'-FE3.png" ///
			 "${report}/section_4-event_study-`y_dep'-FE3.png"	 ,replace 	 
	}
	.

		
	copy "${path_project}/4_outputs/2-Tables/P5-average_numbersTable_model_day.txt" ///
		"${report}/section_4-average_numbers.txt",replace	
	
}
.

 