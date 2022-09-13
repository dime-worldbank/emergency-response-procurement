* Made by Leandro Veloso
* Main: Competitions - based on partipants data

* 1: Competition - Restricting to autions
{
	* reading
	use id_item year_quarter D_winner using "${path_project}/1_data/02-participants_data",clear
	
	* Collapsing by item
	gcollapse (mean) avg_winner= D_winner, by(id_item year_quarter) freq(N_participants)
	
	* Collapsing by year quarter
	gcollapse (mean) avg_winner=avg_winner avg_bidders =N_participants, by(year_quarter)
	
	* Graph 01: 1/N_bidders
	format %3.2fc avg_winner
	scatter  avg_winner year_quarter, ${graph_option} ///
		ytitle("winner proportion") xtitle("quater/year") ///
		xlabel(`=yq(2013,1)'(1)`=yq(2021,1)', angle(90)) ///
		ylabel(0.2(0.01)0.35,angle(0))
	graph export "${path_project}/4_outputs/3-Figures/P1_indicator_1-avg_bidders.pdf", replace as(pdf)
	
	* Graph 02: E[N_bidders]
	format %5.2fc avg_bidders
	scatter  avg_bidders year_quarter, ${graph_option} ///
		ytitle("Average number of bidders by quarter") xtitle("quater/year") ///
		xlabel(`=yq(2013,1)'(1)`=yq(2021,1)', angle(90)) ///
		ylabel(4(0.5)10,angle(0))		
	graph export "${path_project}/4_outputs/3-Figures/P1_indicator_1-avg_bidders.pdf", replace as(pdf)
}
.
