* Made by Leandro Veloso
* Main: Competitions - based on partipants data
 

* 2: New winners
{
	* 1: New winner (auction) defined by month
	{
		* reading acution data
		use id_bidder year_month D_winner using "${path_project}/1_data/03-participants_data" if D_winner==1,clear
		drop D_winner
		
		* duplications
		gduplicates drop id_bidder year_month,force
		
		* New winners
		bys id_bidder (year_month): gen D_new_winner= _n==1
			label var D_new_winner "New winner is defined in a month"
		
		bys id_bidder (D_new_winner): gen year_month_first_win = year_month[_N]
			format %tm year_month_first_win
		
		* Keeping only the year_month first winners
		keep id_bidder year_month_first_win
		duplicates drop id_bidder, force
		
		* Establishment first win
		compress
		save "${path_project}/4_outputs/1-data_temp/P01-new_winners",replace
	}
	.
	
	* 2: Graph number of new winners:
	{
		* reading
		use "${path_project}/4_outputs/1-data_temp/P01-new_winners",clear
		
		* Quarter
		gen year_quarter = yq(year(dofm(year_month_first_win)),quarter(dofm(year_month_first_win)))
		format %tq year_quarter		
		
		keep if year(dofm(year_month_first_win))>=2016
		
		* Collapsing
		gen D_new_winner=1
		gcollapse (sum) N_winners = D_new_winner, by(year_quarter)
		
		* Removing seasonalty - simplest approach
		{
			gen quarter = quarter(dofq(year_quarter))
			reg N_winners i.quarter
			predict season_effect,xb
			
			
			sum N_winners
			gen N_winners_unsea = N_winners - season_effect + r(mean) 
		}
		
		* N new winners 
		format %5.0fc N_winners
		tw 	(scatter  N_winners		 year_quarter  if year_quarter>=`=yq(2016,1)') || ///
			(line     N_winners_unsea year_quarter if year_quarter>=`=yq(2016,1)'), ${graph_option} ///
				ytitle("Number of new winners agreggated by quarter") xtitle("quater/year") ///
				xlabel(`=yq(2016,1)'(1)`=yq(2022,2)', angle(90)) ///
				ylabel( ,angle(0)) legend( order(1 "new winners" 2 "new winners no seasonality"))
			
		graph export "${path_project}/4_outputs/3-Figures/3-indicator_2-new_winners.pdf", replace as(pdf)

	}
	.
	
	* 3: Average new winners by item
	{
		* reading
		use "${path_project}/1_data/03-participants_data" if D_winner==1 ,clear
		
		* reading
		merge m:1 id_bidder using  "${path_project}/4_outputs/1-data_temp/P01-new_winners"
		
		gen D_first_win = year_month ==year_month_first_win
		
		keep if year(dofq(year_quarter))>=2016
		
		* Collapsing
		{
			gen D_first_win_and_sme = SME* D_first_win
			gcollapse (mean) SME_win       = SME					///
							 First_win     = D_first_win			///
							 First_win_sme = D_first_win_and_sme	, by(id_item year_quarter)
							 
			gcollapse (mean) SME_win     			///
							 First_win     			///
							 First_win_sme  , by(year_quarter)	
		}
		.
		
		* Graph 01: 1/N_bidders
		format %3.2fc SME_win
		scatter  SME_win year_quarter, ${graph_option} ///
			ytitle("SME winner proportion") xtitle("quater/year") ///
			xlabel(`=yq(2016,1)'(1)`=yq(2021,1)', angle(90)) ///
			ylabel(0.76(0.02)0.9,angle(0))
		graph export "${path_project}/4_outputs/3-Figures/P1_indicator_2-SME_win.pdf", replace as(pdf)
		
		* Graph 02: 1/N_bidders
		format %3.2fc First_win
		scatter  First_win year_quarter, ${graph_option} ///
			ytitle("First month being winner proportion") xtitle("quater/year") ///
			xlabel(`=yq(2016,1)'(1)`=yq(2021,1)', angle(90)) ///
			ylabel(,angle(0))
		graph export "${path_project}/4_outputs/3-Figures/P1_indicator_2-first_winner.pdf", replace as(pdf)
		
		* Graph 03: 1/N_bidders
		format %3.2fc First_win_sme
		scatter  First_win_sme year_quarter, ${graph_option} ///
			ytitle("First month being a SME & winner proportion") xtitle("quater/year") ///
			xlabel(`=yq(2016,1)'(1)`=yq(2021,1)', angle(90)) ///
			ylabel( ,angle(0))
		graph export "${path_project}/4_outputs/3-Figures/P1_indicator_2-first_winner_SME.pdf", replace as(pdf)	
	}
	.
}
.
 