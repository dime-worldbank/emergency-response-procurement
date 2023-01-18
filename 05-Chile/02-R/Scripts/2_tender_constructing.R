# Load data --------------------------------------------------------------------

  {
    
    {
      
      # Load cleaned tender data
      data_offer_sub <- fread(file = file.path(int_data, "tenders.csv"))
      
      # Load firm data
      data_firms <- read_dta(file = file.path(fin_data, "SII_2015_2020.dta"))
      
      # Load PO data
      data_po <- fread(file = file.path(int_data, "purchase_orders.csv"))
      
      }
    
    {# Conversion rate table as provided in their official website 
      
      # Load COVID-19 data
      conversion_rates <- fread(paste0(raw_data, "/Auxiliary Files/CONVERSION_RATE_USD.csv"), encoding = "Latin-1", colClasses = c(rep("character", 4), rep("NULL", 4)))
    
    }

  }


# DATA CLEANING: offer value ---------------------------------------------------

  {
    
    # { # Checking values
    #   
    #   {# Negative values
    #     
    #     n_negative_amount_awarded <- format(nrow(data_offer_sub %>% filter(AMT_VALUE_AWARDED < 0)), nsmall = 0, digits = 2)
    #     
    #   }
    #   
    #   {# Very large numbers
    #     
    #     # I checked 10 randoms and they all have the same issue. They all offer 1 item but then the ATM_QUANTITY_AWARD is equal to AMT_VALUE_OFFER_TOT
    #     # I believe that this is a classic mistype
    #     View(data_offer_sub %>% 
    #            filter((AMT_QUANTITY_AWARDED == AMT_VALUE_OFFER_TOT) & (AMT_VALUE_AWARDED == (AMT_VALUE_OFFER_TOT*AMT_QUANTITY_AWARDED))) %>% 
    #            filter(AMT_QUANTITY_AWARDED != 1) %>% 
    #            filter(CAT_OFFER_SELECT == 1))
    #     
    #     # Number of these cases
    #     n_case_check_1 <- format(nrow(test_1), nsmall = 0, digits = 2)
    #     
    #     # Display URL of these cases
    #     check_1 <- left_join(test_1, data_offer_sub %>% select(ID_TENDER, URL_TENDER))
    #     
    #   }
    #   
    #   {# Very odd numbers: they are all 1
    #     
    #     # They are all 1
    #     View(test_2 <- data_offer_sub %>% 
    #            filter((AMT_QUANTITY_AWARDED == AMT_VALUE_OFFER_TOT) & (AMT_VALUE_AWARDED == (AMT_VALUE_OFFER_TOT*AMT_QUANTITY_AWARDED))) %>% 
    #            filter(AMT_QUANTITY_AWARDED == 1) %>% 
    #            filter(CAT_OFFER_SELECT == "Seleccionada"))
    #     
    #     # Number of these cases
    #     n_case_check_2 <- format(nrow(test_2), nsmall = 0, digits = 2)
    #     
    #     # Display URL of these cases
    #     check_2 <- left_join(test_2[sample(nrow(test_2), 10)], data_offer_sub %>% select(ID_TENDER, URL_TENDER))
    #     
    #   }
    #   
    #   {# Inconsistent values: if the offer did not win then the awarded value needs to be coded as 0
    #     
    #     # Number of these cases
    #     n_case_check_3 <- format(nrow(data_offer_sub %>% filter((CAT_OFFER_SELECT != "Seleccionada") & ((AMT_VALUE_AWARDED != 0) | (AMT_QUANTITY_AWARDED != 0)))), nsmall = 0, digits = 2)
    #     
    #     n_case_check_3
    #     
    #   }

    }
    
    { # Convert values based on aforementioned issues
      
      data_offer_sub <- data_offer_sub %>% 
        
        mutate(across(starts_with("AMT"), as.numeric)) %>% 
        
        mutate(
          AMT_VALUE_AWARDED = ifelse(AMT_VALUE_AWARDED < 0, NA, AMT_VALUE_AWARDED)
        ) %>% 
        
        mutate(
          AMT_VALUE_AWARDED = ifelse((AMT_QUANTITY_AWARDED == AMT_VALUE_OFFER_TOT) & (AMT_VALUE_AWARDED == (AMT_VALUE_OFFER_TOT*AMT_QUANTITY_AWARDED) & (AMT_QUANTITY_AWARDED != 1)),
          AMT_PRICE_OFFER_UNIT,
          AMT_VALUE_AWARDED)
        ) %>% 
        mutate(
          AMT_VALUE_AWARDED = ifelse((AMT_QUANTITY_AWARDED == AMT_VALUE_OFFER_TOT) & (AMT_VALUE_AWARDED == (AMT_VALUE_OFFER_TOT*AMT_QUANTITY_AWARDED)) & (AMT_QUANTITY_AWARDED == 1) & (CAT_OFFER_SELECT == "Seleccionada"),
                                     AMT_PRICE_OFFER_UNIT*AMT_QUANTITY_AWARDED,
                                     AMT_VALUE_AWARDED)
        ) %>% 
        
        mutate( # there is 1 wrong case
          AMT_VALUE_AWARDED    = ifelse(CAT_OFFER_SELECT != 1, NA, AMT_VALUE_AWARDED   ),
          AMT_QUANTITY_AWARDED = ifelse(CAT_OFFER_SELECT != 1, NA, AMT_QUANTITY_AWARDED)
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
          DT_TENDER_YEAR  = as.character(year(DT_TENDER_START)),
          DT_TENDER_MONTH = as.character(month(DT_TENDER_START)),
          DT              = zoo::as.yearmon(paste(year(DT_TENDER_START), month(DT_TENDER_START)), "%Y %m")
        ) 
      
      #
      data_offer_sub <- left_join(data_offer_sub, conversion_rates, by = c("DT_TENDER_YEAR","DT_TENDER_MONTH","CAT_OFFER_CURRENCY"))
      
      #
      data_offer_sub <- data_offer_sub %>% 
        mutate(
          AMT_VALUE_AWARDED    = AMT_VALUE_AWARDED    * VMUSD,
          AMT_PRICE_OFFER_UNIT = AMT_PRICE_OFFER_UNIT * VMUSD,
          AMT_VALUE_OFFER_TOT  = AMT_VALUE_OFFER_TOT  * VMUSD
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
      
data <- summary_table(data_offer_sub, c("AMT_VALUE_AWARDED", "AMT_VALUE_AWARDED_99"))
      

    }
    

# DATA CLEANING: dates ---------------------------------------------------

{
  
  # We add the submission date from the PO dataset
  data_offer_sub <- data_offer_sub %>% 
    left_join(
      data_po, by = c("ID_RUT_FIRM", "ID_TENDER")
    ) 
  
  # Add trimmed values 
  data_offer_sub <- data_offer_sub %>%
    
    # create month and year date
    mutate(
      DT_Y = year(DT_TENDER_START),
      DT_M = month(DT_TENDER_START)) %>% 
  
    # compute quarter for each year
    mutate(
      DT_Q = if_else(DT_M < 4, 1, 
                     if_else(DT_M < 7, 2,
                             if_else(DT_M < 10, 3, 4))) + 
        if_else(DT_Y == 2018, 0,
                if_else(DT_Y == 2019, 4,
                        if_else(DT_Y == 2020, 8, 12)))
    )
  
}

# DATA CLEANING: dates ---------------------------------------------------

{
  
  # Add trimmed values 
  data_offer_sub <- data_offer_sub %>%
    
    # create month and year date
    mutate(
      DT_Y = year(DT_TENDER_START),
      DT_M = month(DT_TENDER_START)) %>% 
    
    # compute quarter for each year
    mutate(
      DT_Q = if_else(DT_M < 4, 1, 
                     if_else(DT_M < 7, 2,
                             if_else(DT_M < 10, 3, 4))) + 
        if_else(DT_Y == 2018, 0,
                if_else(DT_Y == 2019, 4,
                        if_else(DT_Y == 2020, 8, 12)))
    )
  
  data_offer_sub <- data_offer_sub %>% 
    mutate(
      DD_TOT_PROCESS = difftime(DT_ACCEPT_OC, DT_TENDER_START, units = "days"),
      DD_SUBMISSION  = difftime(DT_OFFER_END, DT_OFFER_START, units = "days"),
      DD_DECISION    = difftime(DT_ACCEPT_OC, DT_OFFER_END, units = "days") 
    ) %>% 
    mutate(
      DD_TOT_PROCESS = ifelse(CAT_OFFER_SELECT == 1, DD_TOT_PROCESS, NA),
      DD_SUBMISSION  = ifelse(CAT_OFFER_SELECT == 1, DD_SUBMISSION, NA),
      DD_DECISION    = ifelse(CAT_OFFER_SELECT == 1, DD_DECISION, NA)
    )
  
}

# DATA CLEANING: firms ---------------------------------------------------

{
  
  # adjust the rut code for the firm-level data
  data_firms_clean <- rut_check(data_firms, rut, without_dots = FALSE, SII = TRUE) %>% 
    rename(
      ID_FIRM_RUT = var
    ) %>% 
    group_by(ID_FIRM_RUT) %>% 
    dplyr::summarise(
      sme     = first(sme)    ,
      region  = first(region) ,
      commune = first(commune)
    )
  
  # merge sme information to main dataset
  data_offer_sub <- data_offer_sub %>% 
    mutate(ID_FIRM_RUT = gsub('[^[:alnum:] ]','', ID_RUT_FIRM)) %>% 
    left_join(data_firms_clean, by = c("ID_FIRM_RUT"))

}

# DATA CLEANING: location ---------------------------------------------------

{
  
  # adjust the rut code for the firm-level data
  data_offer_sub <- clean_string(data_offer_sub, STR_BUYER_CITY) %>% 
    select(- STR_BUYER_CITY) %>% 
    rename(STR_BUYER_CITY = new_string) %>% 
    mutate(
      STR_BUYER_CITY = ifelse(STR_BUYER_CITY == "MELIPILLA" | STR_BUYER_CITY == "SANPEDRO", "SANPEDRODEMELIPILLA", 
                              ifelse(substr(STR_BUYER_CITY, 0 ,8) == "SANTIAGO", "SANTIAGO",
                                     ifelse(STR_BUYER_CITY == "GENERALLAGOS", "LOSLAGOS", 
                                            ifelse(STR_BUYER_CITY == "TORRESDELPAYNE", "PAINE", STR_BUYER_CITY))))
    )
  
  # adjust the rut code for the firm-level data
  data_offer_sub <- clean_string(data_offer_sub, commune) %>% 
    select(-commune) %>% 
    rename(STR_FIRM_CITY = new_string) %>% 
    mutate(
      STR_FIRM_CITY = ifelse(
        STR_FIRM_CITY == "SANVICENTETT", "SANVICENTEDETAGUATAGUA",
        ifelse(STR_FIRM_CITY == "ESTCENTRAL", "ESTACIONCENTRAL",
               ifelse(STR_FIRM_CITY == "QUINTATILCOCO", "QUINTADETILCOCO",
                      ifelse(STR_FIRM_CITY == "SANFCODEMOSTAZAL", "MOSTAZAL",
                             ifelse(STR_FIRM_CITY == "SANJOSEMAIPO", "SANJOSEDEMAIPO",
                                    ifelse(STR_FIRM_CITY == "SAAVEDRA", "PUERTOSAAVEDRA",
                                           ifelse(STR_FIRM_CITY == "GUAITECAS", "LASGUAITECAS",
                                                  ifelse(STR_FIRM_CITY == "TORRESDEPAINE", "PAINE",
                                                         ifelse(STR_FIRM_CITY == "PAGUIRRECERDA", "PEDROAGUIRRECERDA", STR_FIRM_CITY))))))))))
  
  
  # adjust the rut code for the firm-level data
  data_offer_sub <- data_offer_sub %>% 
    mutate(region = as.character(region)) %>% 
    mutate(
      STR_FIRM_REGION = ifelse(region == 1, "Región de Tarapacá  ",
                      ifelse(region == 2, "Región de Antofagasta ",
                             ifelse(region == 3, "Región de Atacama ",
                                    ifelse(region == 4, "Región de Coquimbo ",
                                           ifelse(region == 5, "Región de la Araucanía ",
                                                  ifelse(region == 7,"Región de Valparaíso ",
                                                         ifelse(region == 8, "Región del Libertador General Bernardo O´Higgins",
                                                                ifelse(region == 9, "Región del Maule ",
                                                                       ifelse(region == 10, "Región del Biobío ",
                                                                              ifelse(region == 11, "Región de los Lagos ",
                                                                                     ifelse(region == 12,"Región Aysén del General Carlos Ibáñez del Campo",
                                                                                            ifelse(region == 13, "Región de Magallanes y de la Antártica",
                                                                                                   ifelse(region == 14, "Región Metropolitana de Santiago",
                                                                                                          ifelse(region == 15, "Región de Los Ríos",
                                                                                                                 ifelse(region == 16,"Región de Arica y Parinacota",
                                                                                                                        ifelse(region == 17, "Región del Ñuble", NA))))))))))))))))) %>% 
    select(-region)

  
}


# SAVE DATA --------------------------------------------------------------------

  {
  
    # Save data frames
    fwrite(data_offer_sub , file.path(fin_data, "data_offer_sub.csv" ))
    
    # Remove data frames to free RAM
    rm(data_offer_sub)
    
    # Save data for the report
    save.image(file = file.path(fin_data, "sample_analysis_cleaning.RData"))
    
  }


