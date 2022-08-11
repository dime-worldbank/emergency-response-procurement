# ---------------------------------------------------------------------------- #
#
#                         Emergency Response Procurement
#
#                                  Croatia
#
#                                   Import 
#
#       Author: Hao Lyu                           Update: 08/10/2022
#
# ---------------------------------------------------------------------------- #



# LOAD DATA  ------------------------------------------------------------------

      
      # procurement process level 
        procurementprocess   <-  read_dta(paste0(raw, "procurementprocess.dta"))

        
      # lot level 
        process_item   <-  read_dta(paste0(raw, "process_item.dta"))
      
        
      # contract level 
            
          # raw data
            process_contract_item <- read_dta(paste0(raw, "process_contract_item_v2.dta"))
            
          # after generating variables     
            process_contract_item_genvar <- read_dta(paste0(raw, "process_contract_item_v3.dta"))
        
            
      # bid level 
        process_item_bid <- read_dta(paste0(raw, "process_item_bid_v2.dta"))
      
        
      # complaints 
        complaints <- read_dta(paste0(rawFolder, "complaints_v3.dta")) 


# TRANSLATE COLUMN NAMES -----------------------------------------------------
      
      # for procurement process 
        var_pp = as.data.table(colnames(procurementprocess))
        
        fwrite(var_pp, paste0(intermediate, "variables_pp.csv"), row.names = F)
        
        var_pp <- fread(paste0(intermediate, "variables_pp_translated.csv"), stringsAsFactors = FALSE)
        
        colnames(procurementprocess) <- tolower(var_pp$V2)
        
        
        
      # for process-item 
        var_pi = as.data.table(colnames(process_item))
        
        fwrite(var_pi, paste0(intermediate, "variables_pi.csv"), row.names = F)
        
        var_pi <- fread(paste0(intermediate, "variables_pi_translated.csv"), stringsAsFactors = FALSE)
        
        colnames(process_item) <- tolower(var_pi$V2)
        
        
      
      # for process-contract-item 
        var_pci = as.data.table(colnames(process_contract_item))
        
        fwrite(var_pci, paste0(intermediate, "variables_pci.csv"), row.names = F)
        
        var_pci <- fread(paste0(intermediate, "variables_pci_translated.csv"), stringsAsFactors = FALSE)
        
        colnames(process_contract_item) <- tolower(var_pci$V2)
        
        
      
      # for process-item-bid 
        var_pib = as.data.table(colnames(process_item_bid))
        
        fwrite(var_pib, paste0(intermediate, "variables_pib.csv"), row.names = F)

        var_pib <- fread(paste0(intermediate, "variables_pib_translated.csv"), stringsAsFactors = FALSE)
        
        colnames(process_item_bid) <- tolower(var_pib$V2)
        
      
      
      # for complaints
        var_complaint = as.data.table(colnames(complaints))
      
        fwrite(var_complaint, paste0(intermediate, "variables_complaint.csv"), row.names = F)
      
        var_complaint <- fread(paste0(intermediate, "variables_complaint_translated.csv"), stringsAsFactors = FALSE)
      
        colnames(complaints) <- tolower(var_complaint$V2)
      
      
      
# SAVE DATA AS CSV  -----------------------------------------------------------
      
      fwrite(procurementprocess, paste0(intermediate, "procurementprocess.csv"), row.names = F)
      
      fwrite(process_item, paste0(intermediate, "process_item.csv"), row.names = F)
      
      fwrite(process_contract_item, paste0(intermediate, "process_contract_item_v2.csv"), row.names = F)
      
      fwrite(process_item_bid, paste0(intermediate, "process_item_bid_v2.csv"), row.names = F)

      fwrite(complaints, paste0(intermediate, "complaints.csv"), row.names = F)
      

      
      
      
      
      
      


