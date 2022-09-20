# Load data ---------------------------------------------------------------
  
  { 
    
    # E-PROCUREMENT DATA
    
      # List of all files from data compiled folders
      files_to_load <- list.files(file.path(dropbox_dir, path_imp, "2-data_compiled"), pattern = "-")
      
      # Load all the data
      for (file in files_to_load) {
        
        data <- readRDS(file.path(dropbox_dir, path_imp, "2-data_compiled", file))
        
        assign(paste0("data_",substr(file, 0, nchar(file) - 9),"_",substr(file, str_locate(file, "-")[1] + 1, nchar(file) - 4)), data)
       
      }
      
      # Remove 2022 data to free memory
      rm(data_offer_2022, data_lot_2022)
      
      # Download supplementary data
      download.file("https://transparenciachc.blob.core.windows.net/oc-da/hist_OC_erroneas.csv"  , destfile = paste0(dropbox_dir, "2 - data_construct/1-data_temp/amount.csv"))
      download.file("https://transparenciachc.blob.core.windows.net/oc-da/ParidadMoneda.csv"     , destfile = paste0(dropbox_dir, "2 - data_construct/1-data_temp/currency_conversion.csv"))
      
      # Load data
      amount_issues       <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/amount.csv"), encoding = "Latin-1", colClasses = "character")
      currency_conversion <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/currency_conversion.csv"), encoding = "Latin-1", colClasses = "character")
      
      
    # COVID-19 EMERGENCY PORTAL DATA

      # Download the covid-19 procurement list
      download.file("https://transparenciachc.blob.core.windows.net/covid/OC_COVID.zip"          , destfile = paste0(dropbox_dir, "2 - data_construct/1-data_temp/COVID19.zip"))
      
      # Unzip 
      unzip(paste0(dropbox_dir, "2 - data_construct/1-data_temp/COVID19.zip"), exdir = paste0(dropbox_dir, "2 - data_construct/1-data_temp"    ))
      
      # Load COVID-19 data
      tender_covid   <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/OC_COVID19.csv"    ), encoding = "Latin-1", colClasses = "character")
      item_covid     <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/OCItem_COVID19.csv"), encoding = "Latin-1", colClasses = "character")
      
  }


# Pooling datasets ------------------------------------------------------

  {
    
    # Create pooled data frames at tender/item/offer level from 2015 to 2021 
    
    for (level in c("tender","lot","offer")) {
      
      assign("data" , get(paste0("data_", level, "_2015")))
      
      for (year in seq(2016, 2021)) {
        
        # Assign each data frame to the same name
        assign("data_to_append", get(paste0("data_", level, "_", year)))
        
        # Remove the old data frame
        rm(list = paste0("data_", level, "_", year))
        
        # Append the data frame to the old one
        data <- rbind(data, data_to_append)
        
        # Remove data to append
        rm(data_to_append)
        
      }
      
      # Assign new name to the final data frame 
      assign(paste0("data_", level), data)
      
      # Remove the first data frame 2015
      rm(list = paste0("data_", level, "_2015"))
      
    }
    
    
  }
 
# Data cleaning: e-procurement portal -------------------------------------

  {
    
    # I clean rename the columns for compatibility reasons
    currency_conversion <- currency_conversion %>% 
      rename(
        year           = YEAR   ,
        month          = MONTH  ,
        offer_currency = MONEDA 
      ) %>% 
      select(
        year           , 
        month          , 
        offer_currency ,
        VMUSD
      ) %>% 
      mutate(
        year  = as.integer(year)                 ,
        month = as.integer(month)                ,
        VMUSD = as.numeric(gsub(",",".", VMUSD))
      )
      
    # I merge the currency conversion rate matrix with the list of offers
    data_offer <- left_join(data_offer, currency_conversion, by = c("year","month","offer_currency"))
    
    # I convert the values in USD (and exclude data that are inconsistent following the list provided by Chile Compra)
    data_offer_usd <- data_offer %>% 
      mutate(
        offer_award_value        = ifelse(tender_code %in% amount_issues$NroLicitacion, NA, offer_award_value       * VMUSD), 
        offer_unit_price         = ifelse(tender_code %in% amount_issues$NroLicitacion, NA, offer_unit_price        * VMUSD), 
        offer_total_price        = ifelse(tender_code %in% amount_issues$NroLicitacion, NA, offer_total_price       * VMUSD),  
        offer_total_price_award  = ifelse(tender_code %in% amount_issues$NroLicitacion, NA, offer_total_price_award * VMUSD),
        offer_currency           = "USD"
      ) %>% 
    select(-c(VMUSD))
    
  }

# TREATMENT VS CONTROL ----------------------------------------------
 
   {
     
     # Change name of columns for ID
     colnames(tender_covid)[3] <- "ID"
     colnames(item_covid)[3]   <- "ITEM_ID"
     
     # Label the tenders from 2022
     tender_covid$year_2022       <- ifelse(tender_covid$ID %in% data_tender_2022$tender_code, 1, 0)
     
     # Label the tenders that can be matched with the e-procurement data
     tender_covid$tender_covid_bin <- ifelse(tender_covid$ID %in% data_tender$tender_code, "Matched", "Unmatched")
     
     # List of matched data
     list_matched <- (tender_covid[tender_covid$tender_covid_bin == "Matched",])
     
     # Extract the list of item purchased within COVID emergency tenders
     item_covid_list <- item_covid[!duplicated(item_covid$poiGoodAndService),c("ITEM_ID", "poiGoodAndService")] %>% 
       filter(ITEM_ID %in% list_matched$ID) %>% 
       filter(nchar(poiGoodAndService) > 2)

     # Add a variable to identify which tenders are COVID-emergency related
     for (level in c("tender","lot","offer")) {
       
       if (level == "tender" | level == "offer") {
         
         # load the data
         assign("data", get(paste0("data_", level)))
         
         # add the variable based on the ID from the COVID-19 data set
         data <- data %>%
           mutate(
             tender_covid_19 = ifelse(tender_code %in% tender_covid$ID, 1, 0)
           )
         
         assign(paste0("data_", level), data)
         
       } else {
         
         # load the data
         assign("data", data_lot)
         
         # add the variable based on the ID from the COVID-19 data set
         data <- data %>%
           mutate(
             tender_covid_19   = ifelse(tender_code %in% tender_covid$ID                   , 1, 0) ,
             item_covid_19     = ifelse(lot_code_onu %in% item_covid_list$poiGoodAndService, 1, 0) ,
             medical_equipment = ifelse(substr(data$lot_code_onu, 0, 2) == 42              , 1, 0)
           )
         
         assign("data_lot", data)
         
         rm(data)
         
       }
         
     }
     
     # Remove covid-related data frame
     rm(tender_covid, item_covid)
     
   }   

save.image("/Users/ruggerodoino/Documents/GitHub/emergency-response-procurement/05-Chile/Data.RData")