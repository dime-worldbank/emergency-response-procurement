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
    
    # Collapse data at the item-level only for items purchased trhough emergency procedures 
    tab_value_purchased_covid_emergency <- data_lot_sub %>% 
      
      filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021")           %>% 
      filter(tender_covid_19 == 1)                      %>% 
      dplyr::group_by(STR_ITEM_NAME_GENERAL)                     %>% 
      dplyr::summarise(value_purchased_emergency   = sum(AMT_QUANTITY_AWARDED_award, na.rm = TRUE),
                       number_of_tenders_emergency = n())
    
    # Collapse data at the item-level for all items purchased through emergency procedures but also including the items sold through ordinary procedures
    tab_value_purchased_covid           <- data_lot_sub       %>% 
      
      filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021")                 %>% 
      filter(STR_ITEM_NAME_GENERAL %in% tab_value_purchased_covid_emergency$STR_ITEM_NAME_GENERAL) %>% 
      dplyr::group_by(STR_ITEM_NAME_GENERAL)                           %>% 
      dplyr::summarise(value_purchased_ordinary   = sum(AMT_QUANTITY_AWARDED_award, na.rm = TRUE),
                       number_of_tenders_ordinary = n())
    
    # Merge together the two above just created data frames
    tab_summary_item_covid <- merge(tab_value_purchased_covid, tab_value_purchased_covid_emergency, by = "STR_ITEM_NAME_GENERAL")
    
    # Adjust the final table to be ready  
    tab_summary_item_covid <- tab_summary_item_covid %>% 
      mutate(
        percentage_contracts_emergency = (number_of_tenders_emergency/number_of_tenders_ordinary * 100),
        percentage_value_emergency     = (value_purchased_emergency/value_purchased_ordinary)* 100     ,
        type_of_equipment              = ifelse(substr(STR_ITEM_NAME_GENERAL, 0, 2) == 42, "Medical", "Non-medical")
      )
    
    # Add description of good
    
  }
  
  # List of items that have been purchased through covid emergency procedures
  list_covid_items <- unique(data_lot_sub %>% filter(tender_covid_19 == 1) %>% select(STR_ITEM_NAME_GENERAL))
    
  tab_value_purchased_covid_emergency <- data_lot_sub %>% 
    filter(DT_TENDER_YEAR == "2020" | DT_TENDER_YEAR == "2021") %>% 
    filter(tender_covid_19 == 1)            %>% 
    dplyr::group_by(STR_ITEM_NAME_GENERAL)           %>% 
    dplyr::summarise(value_purchased_covid = sum(AMT_QUANTITY_AWARDED_award, na.rm = TRUE))
  
  tab_value_purchased_covid           <- data_lot_sub %>% 
    filter(item_covid_19 %in% list_covid_items)       %>% 
    filter(item_covid_19 == 1 & tender_covid_19 == 1) %>% 
    dplyr::group_by(STR_ITEM_NAME_GENERAL)                     %>% 
    dplyr::summarise(value_purchased_covid_emergency = sum(AMT_QUANTITY_AWARDED_award, na.rm = TRUE))

tab_summary_item_covid <- merge(tab_value_purchased_covid, tab_value_purchased_covid_emergency, by = "STR_ITEM_NAME_GENERAL")

# DATA CONSTRUCTING: TAB COMPOSITION VALUES ------------------------------------

{# Construct the table that is in the report to compare tenders with covid and non covid items
  
  # First, we collapse data for 2020 and 2021 by type of item (all digits)
  tender_values <- data_offer_sub %>% 
    filter(IND_OFFER_WIN == 1) %>% 
    filter(DT_TENDER_YEAR == 2020 | DT_TENDER_YEAR == 2021) %>% 
    dplyr::group_by(ID_TENDER, ID_ITEM_UNSPSC) %>% 
    dplyr::summarise(
      AMT_VALUE_AWARDED    = sum(AMT_VALUE_AWARDED)
    )
  
  # Then, we add these values to the item-level dataset
  tab_covid_items <- left_join(
    
    data_lot_sub  %>% filter(DT_TENDER_YEAR %in% c(2020, 2021)) %>% select(ID_TENDER, ID_ITEM_UNSPSC, tender_covid_19, item_covid_19, medical_equipment),
    tender_values %>% select(ID_TENDER, ID_ITEM_UNSPSC, AMT_VALUE_AWARDED), 
    by = c("ID_TENDER","ID_ITEM_UNSPSC")
    
  )
  
  v1 <- tab_covid_items %>% 
    na.omit("AMT_VALUE_AWARDED") %>% 
    group_by(ID_ITEM_UNSPSC) %>% 
    dplyr::summarise(
      AMT_VALUE_AWARDED    = sum(AMT_VALUE_AWARDED)
    )
  
  
  
}