# Load data ---------------------------------------------------------------

options(digits = 2)  

    {
      
      # Cleaned DATA
      
      # List of all files from data compiled folders
      files_to_load <- list.files(paste0(dropbox_dir, "3 - data_clean/1-data_cleaned"))
      
      # Load all the data
      for (file in files_to_load) {
        
        data <- readRDS(paste0(dropbox_dir, "3 - data_clean/1-data_cleaned/", file))
        
        assign(substr(file, 0, nchar(file) - 4), data)
        
        rm(data)
        
      }
      
      # Load data
      unspc_codes         <- read_xlsx(paste0(github_dir, "/auxilary_files/unspsc.xlsx"),
                                     col_types = "text", sheet = "8_digits")
      
      unspc_codes_6       <- read_xlsx(paste0(github_dir, "/auxilary_files/unspsc.xlsx"),
                                       col_types = "text", sheet = "6_digits")
      
      unspc_codes_4       <- read_xlsx(paste0(github_dir, "/auxilary_files/unspsc.xlsx"),
                                       col_types = "text", sheet = "4_digits")
      
      unspc_codes_2       <- read_xlsx(paste0(github_dir, "/auxilary_files/unspsc.xlsx"),
                                       col_types = "text", shee = "2_digits")
      
      

      
    }


# COVID-19 item summary table  ---------------------------------------------------------------

  {
    
    { #(all UNSPC digits)
      
      # Collapse the winning offers by ITEM
      offer_values_emergency <- data_offer_sub %>% 
        
        filter(tender_covid_19 == 1) %>% 
        filter(IND_OFFER_WIN == 1)   %>% 
        na.omit("AMT_VALUE_AWARDED_99") %>% 
        filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021") %>% # Only covid-19 period
        select(
          ID_ITEM_UNSPSC      ,
          AMT_VALUE_AWARDED_99
        ) %>% 
        dplyr::group_by(ID_ITEM_UNSPSC) %>% # We collapse at item-tender-level
        dplyr::summarise(
          AMT_VALUE_AWARDED_99_EMERGENCY = sum(AMT_VALUE_AWARDED_99),
          N_TENDERS_EMERGENCY            = n()
        )
      
      # Collapse data at the item-level only for items purchased through emergency procedures 
      offer_values_all <- data_offer_sub %>% 
        
        filter(ID_ITEM_UNSPSC %in% offer_values_emergency$ID_ITEM_UNSPSC) %>% 
        filter(IND_OFFER_WIN == 1)   %>% 
        na.omit("AMT_VALUE_AWARDED_99") %>% 
        filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021") %>% # Only covid-19 period
        select(
          ID_ITEM_UNSPSC      ,
          AMT_VALUE_AWARDED_99
        ) %>% 
        dplyr::group_by(ID_ITEM_UNSPSC) %>% # We collapse at item-tender-level
        dplyr::summarise(
          AMT_VALUE_AWARDED_99_ALL = sum(AMT_VALUE_AWARDED_99),
          N_TENDERS_ALL      = n()
        )                                      
      
      # Merge together the two above just created data frames
      tab_summary_item_covid <- merge(offer_values_emergency, offer_values_all, by = "ID_ITEM_UNSPSC")
      
      # Adjust the final table to be ready  
      tab_summary_item_covid <- tab_summary_item_covid %>% 
        mutate(
          PCT_VALUE_EMERGENCY = (AMT_VALUE_AWARDED_99_EMERGENCY/AMT_VALUE_AWARDED_99_ALL * 100),
          PCT_CONTRACT_EMERGENCY    = (N_TENDERS_EMERGENCY/N_TENDERS_ALL)* 100     ,
          type_of_equipment      = ifelse(substr(ID_ITEM_UNSPSC, 0, 2) == 42, "Medical", "Non-medical")
        )
      
      # Adjust the final table to be ready  
      tab_summary_item_covid <- left_join(tab_summary_item_covid, unspc_codes, by = "ID_ITEM_UNSPSC")
      
    }

    {# (6 UNSPC digits)
      
      # Collapse the winning offers by ITEM
      offer_values_emergency_6 <- data_offer_sub %>% 
        
        filter(tender_covid_19 == 1) %>% 
        filter(IND_OFFER_WIN == 1)   %>% 
        na.omit("AMT_VALUE_AWARDED_99") %>% 
        filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021") %>% # Only covid-19 period
        select(
          ID_ITEM_UNSPSC      ,
          AMT_VALUE_AWARDED_99
        ) %>% 
        mutate(
          ID_ITEM_UNSPSC = substr(ID_ITEM_UNSPSC, 0, 6)
        ) %>% 
        dplyr::group_by(ID_ITEM_UNSPSC) %>% # We collapse at item-tender-level
        dplyr::summarise(
          AMT_VALUE_AWARDED_99_EMERGENCY = sum(AMT_VALUE_AWARDED_99),
          N_TENDERS_EMERGENCY            = n()
        )
      
      # Collapse data at the item-level only for items purchased through emergency procedures 
      offer_values_all_6 <- data_offer_sub %>% 
        
        mutate(
          ID_ITEM_UNSPSC = substr(ID_ITEM_UNSPSC, 0, 6)
        ) %>% 
        filter(ID_ITEM_UNSPSC %in% offer_values_emergency_6$ID_ITEM_UNSPSC) %>% 
        filter(IND_OFFER_WIN == 1)   %>% 
        na.omit("AMT_VALUE_AWARDED_99") %>% 
        filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021") %>% # Only covid-19 period
        select(
          ID_ITEM_UNSPSC      ,
          AMT_VALUE_AWARDED_99
        ) %>% 
        dplyr::group_by(ID_ITEM_UNSPSC) %>% # We collapse at item-tender-level
        dplyr::summarise(
          AMT_VALUE_AWARDED_99_ALL = sum(AMT_VALUE_AWARDED_99),
          N_TENDERS_ALL      = n()
        )                                      
      
      # Merge together the two above just created data frames
      tab_summary_item_covid_6 <- merge(offer_values_emergency_6, offer_values_all_6, by = "ID_ITEM_UNSPSC")
      
      # Adjust the final table to be ready  
      tab_summary_item_covid_6 <- tab_summary_item_covid_6 %>% 
        mutate(
          PCT_VALUE_EMERGENCY = (AMT_VALUE_AWARDED_99_EMERGENCY/AMT_VALUE_AWARDED_99_ALL * 100),
          PCT_CONTRACT_EMERGENCY    = (N_TENDERS_EMERGENCY/N_TENDERS_ALL)* 100     ,
          type_of_equipment      = ifelse(substr(ID_ITEM_UNSPSC, 0, 2) == 42, "Medical", "Non-medical")
        )
      
      unspc_codes_6 <- unspc_codes_6 %>% 
        mutate(
          ID_ITEM_UNSPSC = substr(ID_ITEM_UNSPSC, 0, 6)
        ) %>% 
        distinct(ID_ITEM_UNSPSC, ID_ITEM_DESCRIPTION)
      
      # Adjust the final table to be ready  
      tab_summary_item_covid_6 <- left_join(tab_summary_item_covid_6, unspc_codes_6, by = "ID_ITEM_UNSPSC")
      
    }
    
    {# (4 UNSPC digits)
      
      # Collapse the winning offers by ITEM
      offer_values_emergency_4 <- data_offer_sub %>% 
        
        filter(tender_covid_19 == 1) %>% 
        filter(IND_OFFER_WIN == 1)   %>% 
        na.omit("AMT_VALUE_AWARDED_99") %>% 
        filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021") %>% # Only covid-19 period
        select(
          ID_ITEM_UNSPSC      ,
          AMT_VALUE_AWARDED_99
        ) %>% 
        mutate(
          ID_ITEM_UNSPSC = substr(ID_ITEM_UNSPSC, 0, 4)
        ) %>% 
        dplyr::group_by(ID_ITEM_UNSPSC) %>% # We collapse at item-tender-level
        dplyr::summarise(
          AMT_VALUE_AWARDED_99_EMERGENCY = sum(AMT_VALUE_AWARDED_99),
          N_TENDERS_EMERGENCY            = n()
        )
      
      # Collapse data at the item-level only for items purchased through emergency procedures 
      offer_values_all_4 <- data_offer_sub %>% 
        
        mutate(
          ID_ITEM_UNSPSC = substr(ID_ITEM_UNSPSC, 0, 4)
        ) %>% 
        filter(ID_ITEM_UNSPSC %in% offer_values_emergency_4$ID_ITEM_UNSPSC) %>% 
        filter(IND_OFFER_WIN == 1)   %>% 
        na.omit("AMT_VALUE_AWARDED_99") %>% 
        filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021") %>% # Only covid-19 period
        select(
          ID_ITEM_UNSPSC      ,
          AMT_VALUE_AWARDED_99
        ) %>% 
        dplyr::group_by(ID_ITEM_UNSPSC) %>% # We collapse at item-tender-level
        dplyr::summarise(
          AMT_VALUE_AWARDED_99_ALL = sum(AMT_VALUE_AWARDED_99),
          N_TENDERS_ALL      = n()
        )                                      
      
      # Merge together the two above just created data frames
      tab_summary_item_covid_4 <- merge(offer_values_emergency_4, offer_values_all_4, by = "ID_ITEM_UNSPSC")
      
      # Adjust the final table to be ready  
      tab_summary_item_covid_4 <- tab_summary_item_covid_4 %>% 
        mutate(
          PCT_VALUE_EMERGENCY = (AMT_VALUE_AWARDED_99_EMERGENCY/AMT_VALUE_AWARDED_99_ALL * 100),
          PCT_CONTRACT_EMERGENCY    = (N_TENDERS_EMERGENCY/N_TENDERS_ALL)* 100     ,
          type_of_equipment      = ifelse(substr(ID_ITEM_UNSPSC, 0, 2) == 42, "Medical", "Non-medical")
        )
      
      unspc_codes_4 <- unspc_codes_4 %>% 
        mutate(
          ID_ITEM_UNSPSC = substr(ID_ITEM_UNSPSC, 0, 4)
        ) %>% 
        distinct(ID_ITEM_UNSPSC, ID_ITEM_DESCRIPTION)
      
      # Adjust the final table to be ready  
      tab_summary_item_covid_4 <- left_join(tab_summary_item_covid_4, unspc_codes_4, by = "ID_ITEM_UNSPSC")
      
    }
    
    {# (2 UNSPC digits)
      
      # Collapse the winning offers by ITEM
      offer_values_emergency_2 <- data_offer_sub %>% 
        
        filter(tender_covid_19 == 1) %>% 
        filter(IND_OFFER_WIN == 1)   %>% 
        na.omit("AMT_VALUE_AWARDED_99") %>% 
        filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021") %>% # Only covid-19 period
        select(
          ID_ITEM_UNSPSC      ,
          AMT_VALUE_AWARDED_99
        ) %>% 
        mutate(
          ID_ITEM_UNSPSC = substr(ID_ITEM_UNSPSC, 0, 2)
        ) %>% 
        dplyr::group_by(ID_ITEM_UNSPSC) %>% # We collapse at item-tender-level
        dplyr::summarise(
          AMT_VALUE_AWARDED_99_EMERGENCY = sum(AMT_VALUE_AWARDED_99),
          N_TENDERS_EMERGENCY            = n()
        )
      
      # Collapse data at the item-level only for items purchased through emergency procedures 
      offer_values_all_2 <- data_offer_sub %>% 
        
        mutate(
          ID_ITEM_UNSPSC = substr(ID_ITEM_UNSPSC, 0, 2)
        ) %>% 
        filter(ID_ITEM_UNSPSC %in% offer_values_emergency_2$ID_ITEM_UNSPSC) %>% 
        filter(IND_OFFER_WIN == 1)   %>% 
        na.omit("AMT_VALUE_AWARDED_99") %>% 
        filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021") %>% # Only covid-19 period
        select(
          ID_ITEM_UNSPSC      ,
          AMT_VALUE_AWARDED_99
        ) %>% 
        dplyr::group_by(ID_ITEM_UNSPSC) %>% # We collapse at item-tender-level
        dplyr::summarise(
          AMT_VALUE_AWARDED_99_ALL = sum(AMT_VALUE_AWARDED_99),
          N_TENDERS_ALL      = n()
        )                                      
      
      # Merge together the two above just created data frames
      tab_summary_item_covid_2 <- merge(offer_values_emergency_2, offer_values_all_2, by = "ID_ITEM_UNSPSC")
      
      # Adjust the final table to be ready  
      tab_summary_item_covid_2 <- tab_summary_item_covid_2 %>% 
        mutate(
          PCT_VALUE_EMERGENCY = (AMT_VALUE_AWARDED_99_EMERGENCY/AMT_VALUE_AWARDED_99_ALL * 100),
          PCT_CONTRACT_EMERGENCY    = (N_TENDERS_EMERGENCY/N_TENDERS_ALL)* 100     ,
          type_of_equipment      = ifelse(substr(ID_ITEM_UNSPSC, 0, 2) == 42, "Medical", "Non-medical")
        )
      
      unspc_codes_2 <- unspc_codes_2 %>% 
        mutate(
          ID_ITEM_UNSPSC = substr(ID_ITEM_UNSPSC, 0, 2)
        ) %>% 
        distinct(ID_ITEM_UNSPSC, ID_ITEM_DESCRIPTION)
      
      # Adjust the final table to be ready  
      tab_summary_item_covid_2 <- left_join(tab_summary_item_covid_2, unspc_codes_2, by = "ID_ITEM_UNSPSC")
      
    }
    
    saveRDS(tab_summary_item_covid  , file.path(dropbox_dir, "3 - data_clean", "1-outputs","tab_summary_item_covid.rds"))
    saveRDS(tab_summary_item_covid_6, file.path(dropbox_dir, "3 - data_clean", "1-outputs","tab_summary_item_covid_6.rds"))
    saveRDS(tab_summary_item_covid_4, file.path(dropbox_dir, "3 - data_clean", "1-outputs","tab_summary_item_covid_4.rds"))
    saveRDS(tab_summary_item_covid_2, file.path(dropbox_dir, "3 - data_clean", "1-outputs","tab_summary_item_covid_2.rds"))
    
    write.xlsx(tab_summary_item_covid  , "tab_items_covid.xlsx", sheetName = "8_digits", col.names = TRUE, row.names = TRUE)
    write.xlsx(tab_summary_item_covid_6, "tab_items_covid.xlsx", sheetName = "6_digits", col.names = TRUE, row.names = TRUE, append=TRUE)
    write.xlsx(tab_summary_item_covid_4, "tab_items_covid.xlsx", sheetName = "4_digits", col.names = TRUE, row.names = TRUE, append=TRUE)
    write.xlsx(tab_summary_item_covid_2, "tab_items_covid.xlsx", sheetName = "2_digits", col.names = TRUE, row.names = TRUE, append=TRUE)
  
    }
  