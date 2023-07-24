* Made by Leandro Veloso
* Goal: Creating a latex slide selecting the outputs

* Setting path
cd "C:/Users/wb543303/Documents/01-out_one_drive/03-temporary_files/01-slides_procurement/05-set_frames"

* Reading a sample
use "05-Regession_data-sample" if runiform()<=0.01 ,clear

* Outcome list	
global outcome N_participants  N_SME_participants ///
		SME log_unit_price_filter  unit_price_filter  ///
		 share_SME decision_time decision_time_trim ///
unit_price log_volume_item D_same_munic_win D_same_state_win ///
	months_since_last_win D_new_winner

local k = 0
foreach outcome in $outcome  {
* 0: Opening log to save tex out
cap log close

local k = `k'+1
log using "`k'-`outcome'.tex", replace text

if "`outcome'"=="D_new_winner" 			local var_stat_name N_S2_new_winnes
if "`outcome'"=="SME" 		   			local var_stat_name share_S1_sme_participants
if "`outcome'"=="share_SME"    			local var_stat_name share_S1_sme_win
if "`outcome'"=="decision_time" 		local var_stat_name avg_S3_decision_time
if "`outcome'"=="decision_time_trim" 	local var_stat_name S1_decision_time_trim
if "`outcome'"=="unit_price" 			local var_stat_name avg_S1_decision_time_trim
if "`outcome'"=="log_volume_item" 		local var_stat_name avg_S1_value_item
if "`outcome'"=="D_same_munic_win" 		local var_stat_name share_S1_location_munic
if "`outcome'"=="D_same_state_win" 		local var_stat_name share_S1_location_state
if "`outcome'"=="log_unit_price_filter" local var_stat_name avg_S3_unit_price_filter
if "`outcome'"=="unit_price_filter" 	local var_stat_name avg_S3_log_unit_price_filter
if "`outcome'"=="N_participants" 		local var_stat_name avg_S1_participants
if "`outcome'"=="N_SME_participants"	local var_stat_name share_S3_sme_participants
if "`outcome'"=="months_since_last_win" local var_stat_name avg_S1_win_gap

local loc_label: var label `outcome'

di as white "\begin{frame}[t]	"		
di as white "\vspace{-60} "
di as white "\centering{\textbf{\LARGE{`outcome' $:$ `loc_label'}}}"
di as white " "
di as white "\begin{columns}[t] "
di as white " "
di as white " % Coluna 1  "
di as white "\separatorcolumn"
di as white " \begin{column}{\colwidth}  "
di as white " "
di as white "\begin{block}{Average By Covid level}"
di as white "\begin{figure}[t]  "
di as white " \caption{Example caption.} "
di as white " \includegraphics[width=30cm]{01-figures/03-graph_avg/P3-Covid-`var_stat_name'.pdf} "
di as white " \centering  "
di as white "\end{figure} "
di as white "\end{block}  "
di as white " "
di as white " "
di as white "  \begin{block}{Heteregeous TWFE - High Covid product} "
di as white "\begin{figure}[t]  "
di as white " \caption{Example caption.} "
di as white " \includegraphics[width=30cm]{01-figures/02-TWFE-figure/P5-TWFE-`outcome'.png}  "
di as white " \centering  "
di as white "\end{figure} "
di as white " "
di as white "Simple regression made"
di as white "  \end{block}"
di as white " "
di as white " \end{column}"
di as white " "
di as white "% Coluna 2"
di as white "\separatorcolumn"
di as white " \begin{column}{\colwidth}  "
di as white "\begin{block}{TWFE - Pre - Post}  "
di as white "% Code:"
di as white " \begin{table}[H]  "
di as white " \caption{TWFE - many levels}  "
di as white "  \begin{tabular}{lrrrrrr}  "
di as white " \input{02-table/02-twfe-model/P5-TWFE-`outcome'} "
di as white "  \end{tabular} "
di as white " \label{tab:regs}  "
di as white " \begin{tablenotes}"
di as white " \scriptsize "
di as white " \item "
di as white " \end{tablenotes}  "
di as white "\end{table}  "
di as white "\end{block}  "
di as white " \end{column}"
di as white "\separatorcolumn"
di as white " "
di as white "% Coluna 3"
di as white "\begin{column}{\colwidth}"
di as white "  \begin{block}{TWFE - Time interaction - base 2015h1} "
di as white " "
di as white " \begin{figure}[t] "
di as white "  \caption{$FE_{item} + FE_{YearSemester}$}"
di as white "  \includegraphics[width=22cm]{01-figures/01-event_study/P05-TWFE-time-`outcome'-FE1.png}"
di as white "  \centering "
di as white " \end{figure}"
di as white " "
di as white " \begin{figure}[t] "
di as white "  \caption{$FE_{item} + FE_{YearSemester} + FE_{Month}$}  "
di as white "  \includegraphics[width=22cm]{01-figures/01-event_study/P05-TWFE-time-`outcome'-FE2.png}"
di as white "  \centering "
di as white " \end{figure}"
di as white " "
di as white " \begin{figure}[t] "
di as white "  \caption{$FE_{item} + FE_{YearSemester} + FE_{Month} + FE_{Buyer}$} "
di as white "  \includegraphics[width=22cm]{01-figures/01-event_study/P05-TWFE-time-`outcome'-FE3.png}"
di as white "  \centering "
di as white " \end{figure}"
di as white " "
di as white " \begin{figure}[t] "
di as white "  \caption{$FE_{item} + FE_{YearSemester} + FE_{Month} + FE_{Seller}$}"
di as white "  \includegraphics[width=22cm]{01-figures/01-event_study/P05-TWFE-time-`outcome'-FE4.png}"
di as white "  \centering "
di as white " \end{figure}"
di as white " "
di as white " \begin{figure}[t] "
di as white "  \caption{$FE_{item} + FE_{YearSemester} + FE_{Month} + FE_{Buyer}+ FE_{Seller}$}"
di as white "  \includegraphics[width=22cm]{01-figures/01-event_study/P05-TWFE-time-`outcome'-FE5.png}"
di as white "  \centering "
di as white " \end{figure}"
di as white " \end{block} "
di as white "\end{column} "
di as white " "
di as white " "
di as white "\separatorcolumn"
di as white "\end{columns}"
di as white "\end{frame}  "

cap log close
}
.
.


local k = 0
foreach outcome in $outcome  {
	* 0: Opening log to save tex out
	cap log close

	local k = `k'+1
	di as white "\input{03-sections/`k'-`outcome'.tex}"

}