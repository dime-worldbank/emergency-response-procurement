# ---------------------------------------------------------------------------- #
#
#                         Emergency Response Procurement
#
#                                  Croatia
#
#                                   Import 
#
#       Author: Hao Lyu                           Update: 08/08/2022
#
# ---------------------------------------------------------------------------- #



# LOAD DATA  ------------------------------------------------------------------

      # the data previously got is an xlsx file which is too large to read in R and Stata 
      # manually convert file from "xlsx" to "csv" on the server 
      process_contract_item  <-  fread(paste0(intermediate, "process_contract_item_v3.csv"), stringsAsFactors = FALSE)
        
      complaints             <-  read_dta(paste0(intermediate, "complaints_v3.dta"))

      

# SAVE DATA AS CSV  -----------------------------------------------------------

      fwrite(complaints, paste0(intermediate, "complaints.csv"), row.names = F)






