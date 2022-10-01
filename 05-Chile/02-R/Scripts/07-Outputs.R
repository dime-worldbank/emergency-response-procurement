# Load data ---------------------------------------------------------------

options(digits = 2)  

    {
      
      # Cleaned DATA
      
      # List of all files from data compiled folders
      files_to_load <- list.files(paste0(dropbox_dir, "3 - data_clean/0-data"))
      
      # Load all the data
      for (file in files_to_load) {
        
        data <- readRDS(paste0(dropbox_dir, "3 - data_clean/0-data/", file))
        
        assign(substr(file, 0, nchar(file) - 4), data)
        
        rm(data)
        
      }
      
      # UNSPC DESCRIPTION
      download.file("https://transparenciachc.blob.core.windows.net/oc-da/Listado_rubros_ONU.xlsx"  , destfile = paste0(dropbox_dir, "2 - data_construct/1-data_temp/UNSPC.xlsx"))
      
      # Load data
      unspc_codes       <- read_xlsx(paste0(dropbox_dir, "2 - data_construct/1-data_temp/UNSPC.xlsx"))

      
    }


# COVID-19 item summary table (all UNSPC digits) ---------------------------------------------------------------

  {
    
    # Collapse the winning offers by ITEM
    offer_values_awarded <- data_offer_sub %>% 
      filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021") %>% # Only covid-19 period
      select(
             ID_TENDER           ,
             ID_ITEM_UNSPSC      ,
             AMT_VALUE_AWARDED_99
             ) %>% 
      dplyr::group_by(ID_TENDER, ID_ITEM_UNSPSC)                 %>% # We collapse at item-tender-level
      dplyr::summarise(
        AMT_VALUE_AWARDED_99 = sum(AMT_VALUE_AWARDED_99)
      )
    
    test <- anti_join(offer_values_awarded, data_items, by = c("ID_ITEM_UNSPSC"))
      
    # Merge the offer values from the previous data frame with the item-level data frame
    data_items <- data_lot_sub %>% 
      filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021") %>% # Only covid-19 period
      select(
        DT_TENDER_YEAR      ,
        DT_TENDER_MONTH     ,
        ID_TENDER           ,
        ID_ITEM_UNSPSC      ,
        tender_covid_19     ,
        item_covid_19       ,
        medical_equipment   
      ) %>% 
      dplyr::group_by(
        ID_TENDER      ,
        ID_ITEM_UNSPSC 
      ) %>% 
      dplyr::summarise(
        tender_covid_19      = mean(tender_covid_19      , na.rm = TRUE),
        item_covid_19        = mean(item_covid_19        , na.rm = TRUE),
        medical_equipment    = mean(medical_equipment    , na.rm = TRUE)
      )
    
    # data_lot_sub
    data_items <- data_lot_sub %>% 
      select(
        DT_TENDER_YEAR      ,
        DT_TENDER_MONTH     ,
        ID_TENDER           ,
        ID_ITEM_UNSPSC      ,
        tender_covid_19     ,
        item_covid_19       ,
        medical_equipment   
      ) %>% 
      dplyr::group_by(
        DT_TENDER_YEAR ,
        DT_TENDER_MONTH,
        ID_TENDER      ,
        ID_ITEM_UNSPSC 
      ) %>% 
      dplyr::summarise(
        tender_covid_19      = mean(tender_covid_19      , na.rm = TRUE),
        item_covid_19        = mean(item_covid_19        , na.rm = TRUE),
        medical_equipment    = mean(medical_equipment    , na.rm = TRUE)
      )
    
    # Collapse data at the item-level only for items purchased through emergency procedures 
    tab_value_purchased_covid_emergency <- data_items %>% 
      
      filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021")                          %>% 
      filter(ID_ITEM_UNSPSC %in% list_covid_items$ID_ITEM_UNSPSC)                          %>% 
      na.omit("AMT_VALUE_AWARDED_99")                                                      %>%  
      mutate(AMT_VALUE_AWARDED_99 = ifelse(tender_covid_19 == 1, AMT_VALUE_AWARDED_99, 0)) %>% 
      dplyr::group_by(ID_ITEM_UNSPSC)                                                      %>% 
      dplyr::summarise(AMT_VALUE_EMERGENCY_99 = sum(AMT_VALUE_AWARDED_99),
                       N_TENDERS_EMERGENCY    = n())                                       %>% 
      mutate(
        N_TENDERS_EMERGENCY = ifelse(AMT_VALUE_EMERGENCY_99 == 0, 0, N_TENDERS_EMERGENCY)
      )
    
    # Collapse data at the item-level for all items purchased through emergency procedures but also including the items sold through ordinary procedures
    tab_value_purchased <- data_items %>% 
      
      filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021")                          %>% 
      filter(ID_ITEM_UNSPSC %in% list_covid_items$ID_ITEM_UNSPSC)                          %>% 
      na.omit("AMT_VALUE_AWARDED_99") %>%  
      dplyr::group_by(ID_ITEM_UNSPSC)                                                      %>% 
      dplyr::summarise(AMT_VALUE_AWARDED_99   = sum(AMT_VALUE_AWARDED_99, na.rm = TRUE),
                       N_TENDERS              = n())                                         
    
    # Merge together the two above just created data frames
    tab_summary_item_covid <- merge(tab_value_purchased, tab_value_purchased_covid_emergency, by = "ID_ITEM_UNSPSC")
    
    # Adjust the final table to be ready  
    tab_summary_item_covid <- tab_summary_item_covid %>% 
      mutate(
        percentage_contracts_emergency = (number_of_tenders_emergency/number_of_tenders_ordinary * 100),
        percentage_value_emergency     = (value_purchased_emergency/value_purchased_ordinary)* 100     ,
        type_of_equipment              = ifelse(substr(STR_ITEM_NAME_GENERAL, 0, 2) == 42, "Medical", "Non-medical")
      )
    
    # Add description of good
    
  }
  