# Load data --------------------------------------------------------------------

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
    
    {# Conversion rate table as provided in their official website 
      
      if (!file.exists(paste0(dropbox_dir, "2 - data_construct/1-data_temp/CONVERSION_RATE_USD.csv"))){
        
        # Downlaod the file
        download.file("https://transparenciachc.blob.core.windows.net/oc-da/ParidadMoneda.csv", paste0(dropbox_dir, "2 - data_construct/1-data_temp/CONVERSION_RATE_USD.csv"), mode="wb")
        
      }
      
      # Load COVID-19 data
      conversion_rates <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/CONVERSION_RATE_USD.csv"    ), encoding = "Latin-1", colClasses = c(rep("character", 4), rep("NULL", 4)))
    
    }

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
        
        # Display URL of these cases
        check_1 <- left_join(test_1, data_tender_sub %>% select(ID_TENDER, URL_TENDER))
        
      }
      
      {# Very odd numbers: they are all 1
        
        # They are all 1
        View(test_2 <- data_offer_sub %>% 
               filter((AMT_QUANTITY_AWARDED == AMT_TOTAL_PRICE) & (AMT_VALUE_AWARDED == (AMT_TOTAL_PRICE*AMT_QUANTITY_AWARDED))) %>% 
               filter(AMT_QUANTITY_AWARDED == 1) %>% 
               filter(IND_OFFER_WIN == 1))
        
        # Number of these cases
        n_case_check_2 <- format(nrow(test_2), nsmall = 0, digits = 2)
        
        # Display URL of these cases
        check_2 <- left_join(test_2[sample(nrow(test_2), 10)], data_tender_sub %>% select(ID_TENDER, URL_TENDER))
        
      }
      
      {# Inconsistent values: if the offer did not win then the awarded value needs to be coded as 0
        
        # Number of these cases
        n_case_check_3 <- format(nrow(data_offer_sub %>% filter((IND_OFFER_WIN == 0) & ((AMT_VALUE_AWARDED != 0) | (AMT_QUANTITY_AWARDED != 0)))), nsmall = 0, digits = 2)
        
        n_case_check_3
        
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
        
        mutate( # there is 1 wrong case
          AMT_VALUE_AWARDED    = ifelse(IND_OFFER_WIN == 0, NA, AMT_VALUE_AWARDED   ),
          AMT_QUANTITY_AWARDED = ifelse(IND_OFFER_WIN == 0, NA, AMT_QUANTITY_AWARDED)
        ) 
      
    }
    
    { # First, we need to convert all the values in USD
      
      # Adjust the matrix of conversion currency rates
      conversion_rates <- conversion_rates %>% 
        mutate(
          VMUSD = as.numeric(gsub(",",".",VMUSD))
        ) %>% 
        rename(
          CAT_OFFER_CURRENCY = MONEDA,
          DT_TENDER_YEAR     = YEAR  ,
          DT_TENDER_MONTH    = MONTH)
      
      # Homogenize the currency categories
      data_offer_sub <- data_offer_sub %>% 
        mutate(
          CAT_OFFER_CURRENCY = case_when(
            CAT_OFFER_CURRENCY == "Peso Chileno"      ~ "CLP",
            CAT_OFFER_CURRENCY == "Unidad de Fomento" ~ "CLP",
            CAT_OFFER_CURRENCY == "Dolar"             ~ "USD",
            CAT_OFFER_CURRENCY == "Euro"              ~ "EUR",
            CAT_OFFER_CURRENCY == "Moneda revisar"    ~ "UTM"
          )
        ) %>% 
        mutate(
          DT_TENDER_YEAR  = as.character(DT_TENDER_YEAR),
          DT_TENDER_MONTH = as.character(DT_TENDER_MONTH)
        )
      
      #
      data_offer_sub <- left_join(data_offer_sub, conversion_rates, by = c("DT_TENDER_YEAR","DT_TENDER_MONTH","CAT_OFFER_CURRENCY"))
      
      #
      data_offer_sub <- data_offer_sub %>% 
        mutate(
          AMT_VALUE_ESTIMATED = as.numeric(AMT_VALUE_ESTIMATED)
        ) %>% 
        mutate(
          AMT_VALUE_ESTIMATED = AMT_VALUE_ESTIMATED * VMUSD,
          AMT_VALUE_AWARDED   = AMT_VALUE_AWARDED   * VMUSD,
          AMT_PRICE_UNIT      = AMT_PRICE_UNIT      * VMUSD,
          AMT_TOTAL_PRICE     = AMT_TOTAL_PRICE     * VMUSD
        ) %>% 
        select(-VMUSD)
      
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
      
      data_plot <- data_offer_sub %>% 
        select(
          starts_with("AMT_VALUE_AWARDED")
        ) %>% 
        na.omit("AMT_VALUE_AWARDED") %>% 
        filter(AMT_VALUE_AWARDED != 0)
      
      plot_data_1 <- ggplot(data_offer_sub, aes(x=factor(0), y = AMT_VALUE_AWARDED)) +
        geom_boxplot() + 
        facet_grid("AMT_VALUE_AWARDED", "AMT_VALUE_AWARDED_99", "AMT_VALUE_AWARDED_95", "AMT_VALUE_AWARDED_90")
      
    }
    
  }

# SAVE DATA --------------------------------------------------------------------

  {
    
    # Save data frames
    saveRDS(data_lot_sub   , file.path(dropbox_dir, path_result, "1-data_cleaned", "data_lot_sub.rds"   ))
    saveRDS(data_tender_sub, file.path(dropbox_dir, path_result, "1-data_cleaned", "data_tender_sub.rds"))
    saveRDS(data_offer_sub , file.path(dropbox_dir, path_result, "1-data_cleaned", "data_offer_sub.rds" ))
    
    # Remove data frames to free RAM
    rm(data_lot_sub,data_tender_sub, data_offer_sub)
    
    # Save data for the report
    save.image(file = file.path(dropbox_dir, "3 - data_clean", "1-outputs", "sample_analysis_cleaning.RData"))
    
    
  }


