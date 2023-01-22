# Download and Load  supplementary data ----------------------------------------

{     
  
  {# List of covid-19 tender emergency and items 
    
    if (!file.exists(paste0(dropbox_dir, "2 - data_construct/1-data_temp/OC_COVID19.csv")) 
        | !file.exists(paste0(dropbox_dir, "2 - data_construct/1-data_temp/OCitem_COVID19.csv"))){
      
      # Create a tempfile for the zip
      temp <- tempfile()
      
      # Downlaod the file
      download.file("https://transparenciachc.blob.core.windows.net/covid/OC_COVID.zip", temp, mode="wb")
      
      # Unzip it 
      unzip(temp, exdir = paste0(dropbox_dir, "2 - data_construct/1-data_temp"))
      
      # Delete tempfile
      unlink(temp)
      
    }
    
    # Load COVID-19 data
    tender_covid <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/OC_COVID19.csv"    ), encoding = "Latin-1", colClasses = "character")
    item_covid   <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/OCitem_COVID19.csv"), encoding = "Latin-1", colClasses = "character")
    
    }

  }
  


# Pooling datasets ------------------------------------------------------

{
  
  # Create pooled data frames at tender/item/offer level from 2015 to 2021
  
  for (level in c("tender","lot","offer")) {
    
    data <- readRDS(paste0(dropbox_dir,path_imp, "/2-data_compiled/", level, "-2015.rds"))
    
    for (DT_TENDER_YEAR in seq(2016, 2022)) {
      
      # Assign each data frame to the same name
      data_to_append <- readRDS(paste0(dropbox_dir, "/",path_imp, "/2-data_compiled/", level, "-", DT_TENDER_YEAR, ".rds"))
      
      # Remove the old data frame
      rm(list = paste0("data_", level, "_", DT_TENDER_YEAR))
      
      # Append the data frame to the old one
      data <- rbind(data, data_to_append)
      
      # Remove data to append
      rm(data_to_append)
      
    }
    
    # Assign new name to the final data frame
    assign(paste0("data_", level), data)
    
    # Remove the first data frame 2015
    rm(list = paste0("data_", level, "_2015"))
    rm(data)
    
    # Save the new pooled dataset
    saveRDS(get(paste0("data_", level)) ,paste0(dropbox_dir, "/",path_imp, "/3-data_pooled/data_", level, ".rds"))
    
  }
  
  { # We check if there are issues with the merging
    
    if (
    
        data_lot %>% 
          anti_join(data_tender, by = "ID_TENDER") %>% 
          count() != 0
        |
        data_lot %>% 
          anti_join(data_offer, by = "ID_TENDER") %>% 
          count() != 0
        |
        data_lot %>% 
          anti_join(data_offer, by = "ID_ITEM") %>% 
          count() != 0
        |
        data_offer %>% 
          anti_join(data_tender, by = "ID_TENDER") %>% 
          count() != 0
  
        ) {
      
          stop("Issues with merging")
      
      }
    
    }
  
  }


# Exploring: e-procurement portal -------------------------------------

{
  
  # Number of tenders 
  n_tenders <- format(nrow(data_tender), nsmall = 0, digits = 2, big.mark = ",")
  n_tenders
  
  # Number of tenders 
  n_bids <- format(nrow(data_offer), nsmall = 0, digits = 2, big.mark = ",")
  n_bids
  
  # Percentage of tenders "Cerrada"
  p_tenders_cerrada <- format((nrow(data_tender %>% filter(CAT_TENDER_STATUS == "Cerrada"))/nrow(data_tender))*100, nsmall = 0, digits = 2, big.mark = ",")
  p_tenders_cerrada
  
  # Percentage of tenders "Desierta"
  p_tenders_desierta <- format((nrow(data_tender %>% filter(CAT_TENDER_STATUS == "Desierta (o art. 3 ó 9 Ley 19.886)"))/nrow(data_tender))*100, nsmall = 0, digits = 2, big.mark = ",")
  p_tenders_desierta
  
  # Percentage of tenders "Revocada"
  p_tenders_revocada <- format((nrow(data_tender %>% filter(CAT_TENDER_STATUS == "Revocada"))/nrow(data_tender))*100, nsmall = 0, digits = 2, big.mark = ",")
  p_tenders_revocada
  
  # Percentage of tenders "Suspendida"
  p_tenders_suspendida <- format((nrow(data_tender %>% filter(CAT_TENDER_STATUS == "Suspendida"))/nrow(data_tender))*100, nsmall = 0, digits = 2, big.mark = ",")
  p_tenders_suspendida
  
  # Percentage of tenders "Adjudicada"
  p_tenders_adjudicada <- format(nrow(data_tender %>% filter(CAT_TENDER_STATUS == "Adjudicada")), nsmall = 0, digits = 2, big.mark = ",")
  p_tenders_adjudicada
  
  # Percentage of tenders "Adjudicada" that consitute the final sample
  p_tenders_subsample <- format((nrow(data_tender %>% filter(CAT_TENDER_STATUS == "Adjudicada"))/nrow(data_tender))*100, nsmall = 0, digits = 2, big.mark = ",")
  p_tenders_subsample
  
  
}

# Treatment vs Control ---------------------------------------------------------

{
  
  # Change name of columns for ID
  colnames(item_covid)[3]   <- "ID_TENDER"
  colnames(tender_covid)[3] <- "ID_TENDER"
  
  # Number of covid tenders
  n_tender_covid <- format(nrow(item_covid %>% distinct(ID_TENDER)), nsmall = 0, digits = 2, big.mark = ",")
  n_tender_covid
  
  
  # Label the tenders that can be matched with the e-procurement data
  item_covid$tender_covid_bin   <- ifelse(item_covid$ID_TENDER %in% data_tender$ID_TENDER_EXTERNAL , "Matched", "Unmatched")
  tender_covid$tender_covid_bin <- ifelse(tender_covid$ID_TENDER %in% data_tender$ID_TENDER_EXTERNAL , "Matched", "Unmatched")
  
  # List of matched data
  list_matched <- (item_covid[item_covid$tender_covid_bin == "Matched",])
  
  # Extract the list of item purchased within COVID emergency tenders
  item_covid_list <- item_covid[!duplicated(item_covid$poiGoodAndService),c("poiGoodAndService")] %>% 
    filter(nchar(poiGoodAndService) > 2)
  
  # Add a variable to identify which tenders are COVID-emergency related
  for (level in c("tender", "lot", "offer")) {
    
    if (level == "tender" | level == "offer") {
      
      # load the data
      assign("data", get(paste0("data_", level)))
      
      # add the variable based on the ID from the COVID-19 data set
      data <- data %>%
        mutate(
          tender_covid_19 = ifelse(ID_TENDER_EXTERNAL %in% item_covid$ID_TENDER, 1, 0)
        )
      
      assign(paste0("data_", level), data)
      
      rm(data)
      
    } else {
      
      # load the data
      assign("data", data_lot)
      
      # add the variable based on the ID from the COVID-19 data set
      data <- data %>%
        mutate(
          tender_covid_19      = ifelse(ID_TENDER_EXTERNAL  %in%    item_covid$ID_TENDER     , 1, 0),
          item_covid_19        = ifelse(ID_ITEM_UNSPSC %in% item_covid_list$poiGoodAndService, 1, 0),
          medical_equipment    = ifelse(substr(ID_ITEM_UNSPSC, 0, 2) == 42                   , 1, 0)
        )
      
      assign("data_lot", data)
      
      rm(data)
      
    }
    
  }
  
  # Remove covid-related data frame
  rm( item_covid_list)
  
}   


# Subsampling ------------------------------------------------------------------

{
  
  # I need to sub-sample for getting the final sample of interest for the analysis
  list_ID_TENDER_EXTERNAL_sub <- data_tender %>% 
    filter(
      CAT_TENDER_STATUS == "Adjudicada"
    )
  
  # We sub-sample and save each data frame
  for (level in c("tender","lot","offer")) {
    
    # load the data
    assign("data", get(paste0("data_", level)))
    
    # add the variable based on the ID from the COVID-19 data set
    data <- data %>%
      filter(
        ID_TENDER %in% list_ID_TENDER_EXTERNAL_sub$ID_TENDER
      )
    
    # assign the data
    assign(paste0("data_", level, "_sub"), data)
    
    rm(data)
    
    rm(list = paste0("data_", level))
    
  }
  
  if (
    
    data_lot_sub %>% 
    anti_join(data_tender_sub, by = "ID_TENDER") %>% 
    count() != 0
    |
    data_lot_sub %>% 
    anti_join(data_offer_sub, by = "ID_TENDER") %>% 
    count() != 0
    |
    data_lot_sub %>% 
    anti_join(data_offer_sub, by = "ID_ITEM") %>% 
    count() != 0
    |
    data_offer_sub %>% 
    anti_join(data_tender_sub, by = "ID_TENDER") %>% 
    count() != 0
    
  ) {
    
    stop("Issues with merging")
    
  }

}



# Exploring p2  ----------------------------------------------------------------

{
  
  # Percentage of tender matched 
  p_covid_match <- format((nrow(tender_covid %>% filter(tender_covid_bin == "Matched"))/nrow(tender_covid))*100, nsmall = 0, digits = 2)
  p_covid_match
  
  # Create two way freq tab to see how the unmatched tenders are distributed
  tab_1 <- tender_covid %>%                      # set the dataset to work on
    tabyl(ClaseDeCompra, tender_covid_bin)  %>%  # select the variables of interest and compute a two-way frequency table
    adorn_totals( where = c("row", "col")) %>%   # compute totals by row and cols
    adorn_percentages("all")               %>%   # add percentages to the table
    adorn_pct_formatting(digits = 0)       %>%   # format with 0 digits
    adorn_ns( position = "front" )  
  
  names(tab_1)[1] <-"Tender Type"
  
  # Number of tenders from Licitation Publica and Privada
  n_tenders_pub_priv <- format(nrow(tender_covid %>% filter(ClaseDeCompra == "LICITACION PUBLICA" | ClaseDeCompra == "LICITACION PRIVADA")), nsmall = 1, digits = 2)
  
  # Percentage of tenders from Licitation Publica and Privada
  p_tenders_pub_priv <- format((nrow(tender_covid %>% filter(ClaseDeCompra == "LICITACION PUBLICA" | ClaseDeCompra == "LICITACION PRIVADA"))/nrow(tender_covid))*100, nsmall = 1, digits = 2)
  
  # Number of tenders from Licitation Publica and Privada
  n_tenders_success <- format(nrow(tender_covid %>% filter(ClaseDeCompra != "Enviada al Proveedor" | ClaseDeCompra != "Aceptada")), nsmall = 1, digits = 2)
  
  # Percentage of tenders from Licitation Publica and Privada
  p_tenders_success <- format((nrow(tender_covid %>% filter(ClaseDeCompra != "Enviada al Proveedor" | ClaseDeCompra != "Aceptada"))/nrow(tender_covid))*100, nsmall = 0, digits = 2)
  
  # Number of tenders without ID
  n_tenders_without_id <- format(nrow(tender_covid %>% filter(is.na(ID_TENDER))), nsmall = 1, digits = 2)
  
  # Percentage of tenders without ID
  p_tenders_without_id <- format((nrow(tender_covid %>% filter(is.na(ID_TENDER)))/nrow(tender_covid))*100, nsmall = 1, digits = 2)
  
  # Create two way freq tab to see how the unmatched tenders are distributed
  tab_2 <- data_lot_sub %>%                      # set the dataset to work on
    filter(tender_covid_19 == 1) %>% 
    tabyl(medical_equipment, tender_covid_19) %>%  # select the variables of interest and compute a two-way frequency table
    adorn_totals( where = c("row", "col")) %>%   # compute totals by row and cols
    adorn_percentages("all")               %>%   # add percentages to the table
    adorn_pct_formatting(digits = 0)       %>%   # format with 0 digits
    adorn_ns( position = "front" )  
  
  tab_2              <- tab_2[,c(1,2)]
  colnames(tab_2)[2] <- "Emergency Tender"
  colnames(tab_2)[1] <- "Medical Equipment"
  
  # Remove unnecessary data frames
  rm(list = c(
    "tender_covid"        ,
    "list_matched"        ,
    "list_ID_TENDER_EXTERNAL_sub"))
}

# SAVING  -----------------------------------------------------------------

{
  
  # Save data frames
  saveRDS(data_lot_sub   , paste0(dropbox_dir, path_result, "/0-data/", "data_lot_sub.rds"   ))
  saveRDS(data_tender_sub, paste0(dropbox_dir, path_result, "/0-data/", "data_tender_sub.rds"))
  saveRDS(data_offer_sub , paste0(dropbox_dir, path_result, "/0-data/", "data_offer_sub.rds" ))
  
  # Remove data frames to free RAM
  rm(data_lot_sub,data_tender_sub, data_offer_sub)
  
  # Save data for the report
  save.image(file = paste0(dropbox_dir, "3 - data_clean/", "1-outputs/", "n_sample_pooling.RData"))
  
}
