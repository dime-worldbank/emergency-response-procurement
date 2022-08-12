* Made by Leandro Veloso
* Main: Estimating indicators

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
		global path_data    	"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\01-KCP-Brazil"
 		global path_project 	"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\04-procurement\06-Covid_Brazil"
  	}
	.
 
	* graphs configuration
	global graph_option graphregion(color(white)) xsize(10) ysize(5)
}
.

* 1: Competition - Restricting to autions
{
	* reading
	use id_item year_quarter D_winner using "${path_project}/1_data/1_participants_data",clear
	
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

* 2: New winners
{
	* 1: New winner (auction) defined by month
	{
		* reading acution data
		use id_bidder year_month D_winner using "${path_project}/1_data/1_participants_data" if D_winner==1,clear
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
				xlabel(`=yq(2016,1)'(1)`=yq(2021,1)', angle(90)) ///
				ylabel( ,angle(0)) legend( order(1 "new winners" 2 "new winners no seasonality"))
			
		graph export "${path_project}/4_outputs/3-Figures/P1_indicator_2-new_winners.pdf", replace as(pdf)

	}
	.
	
	* 3: Average new winners by item
	{
		* reading
		use "${path_project}/1_data/1_participants_data" if D_winner==1 ,clear
		
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

* 3: Market concentration
{
	* By all
	{
		global sector_measure " "
		use "${path_project}/1_data/1_participants_data" if D_winner==1 ,clear
		*drop if ${sector_measure}==.
		
		gen year  = year(dofq(year_quarter))
		bys id_bidder  ${sector_measure} year: gen byte N_winner_unique = _n==1
		
		gcollapse (sum) N_winner_unique   , by( ${sector_measure} year) freq(N_winners)
		
		gen rate = N_winner_unique/N_winners
		
		* Graph 01: 1/N_bidders
		keep if year<= 2020
		
		format %4.3fc rate
		tw 	(scatter  rate year) , ${graph_option} ///
			ytitle("Unique winners proportion") xtitle("quater/year") ///
			xlabel(2013(1)2020 , angle(90)) ///
			ylabel(0.017(0.001)0.025,angle(0))
	}
	.
	
	* By sector
	{
		
		global sector_measure "great_sectors"
		use "${path_project}/1_data/1_participants_data" if D_winner==1 ,clear
		drop if ${sector_measure}==.		
		
		gen year  = year(dofq(year_quarter))
		bys id_bidder  ${sector_measure} year: gen byte N_winner_unique = _n==1
		
		gcollapse (sum) N_winner_unique   , by( ${sector_measure} year) freq(N_winners)
		
		gen rate = N_winner_unique/N_winners
		gcollapse (mean) rate   , by( year)

		* Graph 01: 1/N_bidders
		keep if year<= 2020
		
		format %4.3fc rate
		tw 	(scatter  rate year) , ${graph_option} ///
			ytitle("Unique winners proportion") xtitle("quater/year") ///
			xlabel(2013(1)2020 , angle(90)) ///
			ylabel(,angle(0))
	}
	.
	
	* By sector
	{
		global sector_measure "great_sectors"
		use "${path_project}/1_data/1_participants_data" if D_winner==1 ,clear
		drop if ${sector_measure}==.		
		
		gen year  = year(dofq(year_quarter))
		bys id_bidder  ${sector_measure} year: gen byte N_winner_unique = _n==1
		
		gcollapse (sum) N_winner_unique   , by( ${sector_measure} year) freq(N_winners)
		
		gen rate = N_winner_unique/N_winners
		gcollapse (mean) avg=rate   , by( ${sector_measure} year) freq(N_winners)

		* Graph 01: 1/N_bidders
		keep if year<= 2020
		
		format %3.2fc rate
		tw 	(scatter  rate year if  ${sector_measure}==1) || ///
			(scatter  rate year if  ${sector_measure}==2) || 	///
			(scatter  rate year if  ${sector_measure}==3) || ///
			(scatter  rate year if  ${sector_measure}==4) || ///
			(scatter  rate year if  ${sector_measure}==5) , ${graph_option} ///
			ytitle("Unique winners proportion") xtitle("quater/year") ///
			xlabel(2013(1)2020 , angle(90)) ///
			ylabel(0(0.01)0.08,angle(0)) ///
			legend(order( 1 "manufactor" 2 "construction" 3 "commerce" 4 "service" 5 "others"))
	}
}
