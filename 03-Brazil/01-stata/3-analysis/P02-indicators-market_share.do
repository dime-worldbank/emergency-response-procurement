* Made by Leandro Veloso
* Main: Competitions - based on partipants data
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
.
