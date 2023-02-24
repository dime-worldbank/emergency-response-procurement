* Made by Leandro Veloso
* Main: Indexes study

* 0: Opening log to save tex out
cap log close
log using "${path_project}\4_outputs\5-log files\P06-latex-graphs.txt", replace text

* 01: tender Graph
di as white "Tender graphs"
{
	local chart_list: dir "${overleaf}/02_figures/" files "P3*.*"

	foreach chart of local chart_list {
		local file = subinstr(subinstr("`chart'",".pdf","",.), "_"," ",.)
		di as white "%--------------------------------------------------------------%"
		di as white "% Code: 03-tender_graphs.do"
		di as white "\begin{frame}{`file'}" 
		di as white "\begin{figure}[H]"
		di as white "	\centering"
		di as white "	\resizebox{12cm}{!}{"
		di as white "	\includegraphics{02_figures/`chart'}"
		di as white "	}"    
		di as white "\end{figure}"
		di as white "\end{frame}"
		di as white ""
		di as white ""
	}
	.
}
.

di _newline(5)
* 02: Indexes graphs
di as white "Indexes graphs"
{
	local chart_list: dir "${overleaf}/02_figures/" files "P4*.*"

	foreach chart of local chart_list {
		local file = subinstr(subinstr("`chart'",".pdf","",.), "_"," ",.)
		di as white "%--------------------------------------------------------------%"
		di as white "% Code: 04-Indexes_graphs.do"
		di as white "\begin{frame}{`file'}" 
		di as white "\begin{figure}[H]"
		di as white "	\centering"
		di as white "	\resizebox{12cm}{!}{"
		di as white "	\includegraphics{02_figures/`chart'}"
		di as white "	}"    
		di as white "\end{figure}"
		di as white "\end{frame}"
		di as white ""
		di as white ""
	}
	.
}
.

di _newline(5)
* 03: Indexes graphs
di as white "Product graphs"
{
	local chart_list: dir "${overleaf}/02_figures/" files "P5*.*"

	foreach chart of local chart_list {
		local file = subinstr(subinstr("`chart'",".pdf","",.), "_"," ",.)
		di as white "%--------------------------------------------------------------%"
		di as white "% Code: 05-stat_product_visualization.do"
		di as white "\begin{frame}{`file'}"
		di as white "\begin{figure}[H]"
		di as white "	\centering"
		di as white "	\resizebox{12cm}{!}{"
		di as white "	\includegraphics{02_figures/`chart'}"
		di as white "	}"    
		di as white "\end{figure}"
		di as white "\end{frame}"
		di as white ""
		di as white ""
	}
	.
}
.

* Log close
cap log close
	