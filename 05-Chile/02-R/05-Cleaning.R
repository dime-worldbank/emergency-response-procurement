
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
        
        # Load COVID-19 data
        tender_covid <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/OC_COVID19.csv"    ), encoding = "Latin-1", colClasses = "character")
        item_covid   <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/OCitem_COVID19.csv"), encoding = "Latin-1", colClasses = "character")
        
        # Delete tempfile
        unlink(temp)
        
      }
      
    }
    
    {# Conversion rate table as provided in their official website 
      
      if (!file.exists(paste0(dropbox_dir, "2 - data_construct/1-data_temp/CONVERSION_RATE_USD.csv"))){
        
        # Downlaod the file
        download.file("https://transparenciachc.blob.core.windows.net/oc-da/ParidadMoneda.csv", paste0(dropbox_dir, "2 - data_construct/1-data_temp/CONVERSION_RATE_USD.csv"), mode="wb")
        
        # Load COVID-19 data
        conversion_rates <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/CONVERSION_RATE_USD.csv"    ), encoding = "Latin-1", colClasses = c(rep("character", 4), rep("NULL", 4)))
        
      }
      
    }
    
    
  }
    
# Pooling datasets ------------------------------------------------------

  {
    
       # Create pooled data frames at tender/item/offer level from 2015 to 2021 
       
       for (level in c("tender","lot","offer")) {
         
         if (!file.exists(paste0(dropbox_dir, "/", path_imp, "/2-data_compiled/data_", level, ".rds"))){
         
            data <- readRDS(paste0(dropbox_dir, "/",path_imp, "/2-data_compiled/", level, "-2015.rds"))
            
            for (DT_TENDER_YEAR in seq(2016, 2022)) {
              
              # Assign each data frame to the same name
              data_to_append <- readRDS(paste0(dropbox_dir, "/",path_imp, "/2-data_compiled/", level, "-", DT_TENDER_YEAR, ".rds"))
              
              # Remove the old data frame
              rm(list = paste0("data_", level, "_", DT_TENDER_YEAR))
              
              # Append the data frame to the old one
              data <- rbind(data, data_to_append)
              
              # Remove data to append
              rm(data_to_append)
              
              # Remove data in the directory
              unlink(paste0(dropbox_dir, "/",path_imp, "/2-data_compiled/", level, "-", DT_TENDER_YEAR, ".rds"))
              
            }
            
            # Assign new name to the final data frame 
            assign(paste0("data_", level), data)
            
            # Remove the first data frame 2015
            rm(list = paste0("data_", level, "_2015"))
            rm(data)
            
            # Remove 2015 data in the directory
            unlink(paste0(dropbox_dir, "/",path_imp, "/2-data_compiled/", level, "-2015.rds"))
            
            # Save the new pooled dataset
            saveRDS(get(paste0("data_", level)) ,paste0(dropbox_dir, "/",path_imp, "/2-data_compiled/data_", level, ".rds"))
            
       }
    
    }
    
  }

 
# Exploring: e-procurement portal -------------------------------------

  {
    
    # Number of tenders 
    n_tenders <- format(nrow(data_tender), nsmall = 0, digits = 2, big.mark = ",")
    n_tenders
    
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
     colnames(tender_covid)[3]   <- "ID_TENDER"
     
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
    
    
  }



# Exploring p2  ----------------------------------------------------------------

  {
    
    # Percentage of tender matched 
    p_covid_match <- format((nrow(item_covid %>% filter(tender_covid_bin == "Matched") %>% distinct(ID_TENDER, tender_covid_bin))/nrow(tender_covid))*100, nsmall = 0, digits = 2)
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
    colnames(tab_2)[2] <- "Medical Equipment"
    
    # Remove unnecessary data frames
    rm(list = c(
              "tender_covid"        ,
              "list_matched"        ,
              "list_ID_TENDER_EXTERNAL_sub"))
  }

# DATA CLEANING: offer value ---------------------------------------------------

  {
    
    { # Checking values
      
      {# Negative values
        
        n_negative_amount_awarded <- format(nrow(data_offer_sub %>% filter(AMT_VALUE_AWARDED < 0)), nsmall = 0, digits = 2)
        
      }
      
      {# Very large numbers
        
        # I checked 10 randoms and they all have the same issue. They all offer 1 item but then the ATM_QUANTITY_AWARD is equal to AMT_TOTAL_PRICE
        # I believe that this is a classic mistype
        View(test_1 <- data_offer_sub %>% 
               filter((AMT_QUANTITY_AWARDED == AMT_TOTAL_PRICE) & (AMT_VALUE_AWARDED == (AMT_TOTAL_PRICE*AMT_QUANTITY_AWARDED))) %>% 
               filter(AMT_QUANTITY_AWARDED != 1) %>% 
               filter(IND_OFFER_WIN == 1))
        
        # Number of these cases
        n_case_check_1 <- format(nrow(test_1), nsmall = 0, digits = 2)
        
        # Check 10 random cases
        check_1 <- test_1[sample(nrow(test_1), 10), "ID_TENDER_EXTERNAL"]
        
        # Display URL of these cases
        check_1 <- data_tender_sub %>% select(URL_TENDER, ID_TENDER_EXTERNAL) %>% filter(ID_TENDER_EXTERNAL %in% check_1$ID_TENDER_EXTERNAL)
        
      }
      
      {# Very odd numbers: they are all 1
        
        # They are all 1
        View(test_2 <- data_offer_sub %>% 
               filter((AMT_QUANTITY_AWARDED == AMT_TOTAL_PRICE) & (AMT_VALUE_AWARDED == (AMT_TOTAL_PRICE*AMT_QUANTITY_AWARDED))) %>% 
               filter(AMT_QUANTITY_AWARDED == 1) %>% 
               filter(IND_OFFER_WIN == 1))
        
        # Number of these cases
        n_case_check_2 <- format(nrow(test_2), nsmall = 0, digits = 2)
        
        # Check 10 random cases
        check_2 <- test_1[sample(nrow(test_2), 10), "ID_TENDER_EXTERNAL"]
        
        # Display URL of these cases
        check_2 <- data_tender_sub %>% select(URL_TENDER, ID_TENDER_EXTERNAL) %>% filter(ID_TENDER_EXTERNAL %in% check_2$ID_TENDER_EXTERNAL)
        
      }
      
      {# Inconsistent values: if the offer did not win then the awarded value needs to be coded as 0
        
        # Number of these cases
        n_case_check_3 <- format(nrow(data_offer_sub %>% filter((IND_OFFER_WIN == 0) & ((AMT_VALUE_AWARDED != 0) | (AMT_QUANTITY_AWARDED != 0)))), nsmall = 0, digits = 2)
        
      }

    }
    
    { # Convert values based on aforementioned issues
      
      data_offer_sub <- data_offer_sub %>% 
        
        mutate(
          AMT_VALUE_AWARDED = ifelse(AMT_VALUE_AWARDED < 0, NA, AMT_VALUE_AWARDED)
        ) %>% 
        
        mutate(
          AMT_VALUE_AWARDED = ifelse((AMT_QUANTITY_AWARDED == AMT_TOTAL_PRICE) & (AMT_VALUE_AWARDED == (AMT_TOTAL_PRICE*AMT_QUANTITY_AWARDED) & (AMT_QUANTITY_AWARDED != 1)),
          AMT_PRICE_UNIT,
          AMT_VALUE_AWARDED)
        ) %>% 
        mutate(
          AMT_VALUE_AWARDED = ifelse((AMT_QUANTITY_AWARDED == AMT_TOTAL_PRICE) & (AMT_VALUE_AWARDED == (AMT_TOTAL_PRICE*AMT_QUANTITY_AWARDED)) & (AMT_QUANTITY_AWARDED == 1) & (IND_OFFER_WIN == 1),
                                     AMT_PRICE_UNIT*AMT_QUANTITY_AWARDED,
                                     AMT_VALUE_AWARDED)
        ) %>% 
        
        mutate( # there are 7 wrong cases
          AMT_VALUE_AWARDED    = ifelse(IND_OFFER_WIN == 0, 0, AMT_VALUE_AWARDED   ),
          AMT_QUANTITY_AWARDED = ifelse(IND_OFFER_WIN == 0, 0, AMT_QUANTITY_AWARDED)
        ) 
      
    }
    
    { # Other changes
      
      # Add trimmed values 
      data_offer_sub <- data_offer_sub %>% 
        
      mutate(
        
        AMT_VALUE_AWARDED_99 = ifelse(AMT_VALUE_AWARDED > quantile(AMT_VALUE_AWARDED, 0.99, na.rm = TRUE), NA, ifelse(
          AMT_VALUE_AWARDED < quantile(AMT_VALUE_AWARDED, 0.01, na.rm = TRUE), NA, AMT_VALUE_AWARDED)),
        
        AMT_VALUE_AWARDED_95 = ifelse(AMT_VALUE_AWARDED > quantile(AMT_VALUE_AWARDED, 0.95, na.rm = TRUE), NA, ifelse(
          AMT_VALUE_AWARDED < quantile(AMT_VALUE_AWARDED, 0.05, na.rm = TRUE), NA, AMT_VALUE_AWARDED)),
        
        AMT_VALUE_AWARDED_90 = ifelse(AMT_VALUE_AWARDED > quantile(AMT_VALUE_AWARDED, 0.9, na.rm = TRUE), NA, ifelse(
          AMT_VALUE_AWARDED < quantile(AMT_VALUE_AWARDED, 0.1, na.rm = TRUE), NA, AMT_VALUE_AWARDED))
        
      ) 
      
    }
    
  }


# SAVING  -----------------------------------------------------------------

    {
      
      # Save data for the report
      save(data_tender, tender_covid, file = "/Users/ruggerodoino/Documents/GitHub/emergency-response-procurement/05-Chile/Data.RData")
      
    }
