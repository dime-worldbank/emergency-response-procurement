# Load data --------------------------------------------------------------------

  {
    
    {
      
      # Load cleaned tender data
      data_offer_sub <- fread(file = file.path(int_data, "tenders.csv"), encoding = "Latin-1")

      
      # Load firm data
      data_firms <- fread("/Users/ruggerodoino/Dropbox/ChilePaymentProcurement/Reproducible-Package/Data/Intermediate/Firm Registry/firm_data.csv", encoding = "Latin-1")
      
      # Load PO data
      data_po <- fread(file = file.path(int_data, "purchase_orders.csv"), encoding = "Latin-1")

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
      
      data_po <- data_po  %>% 
        mutate(
          DT_YEAR  = as.character(DT_YEAR),
          DT_MONTH = as.character(DT_MONTH),
          ID_ITEM_UNSPSC = as.character(ID_ITEM_UNSPSC)
        )
      
      #
      data_po <- left_join(data_po, conversion_rates %>% mutate(VMUSD = gsub(",", ".", VMUSD)) %>%  filter(CAT_OFFER_CURRENCY == "CLP"), by = c("DT_YEAR" = "DT_TENDER_YEAR","DT_MONTH" = "DT_TENDER_MONTH"))
      
      #
      data_po <- data_po %>% 
        mutate(
          AMT_VALUE    = AMT_TOT_PESOS_OC    * as.numeric(VMUSD)
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
      
      data_po <- data_po %>% 
        
        mutate(
          AMT_VALUE = ifelse(AMT_VALUE > quantile(AMT_VALUE, 0.99, na.rm = TRUE), NA, ifelse(
            AMT_VALUE < quantile(AMT_VALUE, 0.01, na.rm = TRUE), NA, AMT_VALUE)
        ))
      
      item_covid   <- readxl::read_xlsx(file.path(raw_data, "Auxiliary files/covid_label_table.xlsx"))
      item_covid_list <- item_covid %>% select(ID_ITEM_UNSPSC, CAT_MEDICAL, COVID_LABEL)
      
      data_po = data_po %>% 
        left_join(item_covid_list, by = c("ID_ITEM_UNSPSC")) %>% 
        mutate(CAT_MEDICAL = ifelse(substr(ID_ITEM_UNSPSC, 0, 2) == "42", 1, 0)) %>% 
        mutate(COVID_LABEL = ifelse(is.na(COVID_LABEL), 1, 0))

    }
    

# DATA CLEANING: dates ---------------------------------------------------

{
  
  # We add the submission date from the PO dataset
  data_offer_sub <- data_offer_sub %>% 
    left_join(
      data_po %>% select(ID_RUT_FIRM, ID_TENDER, DT_ACCEPT_OC), by = c("ID_RUT_FIRM", "ID_TENDER")
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
      DT_S = if_else(DT_M <= 6, 1, 2) + 
        if_else(DT_Y == 2016, 0,
                if_else(DT_Y == 2017, 2,
                        if_else(DT_Y == 2018, 4, 
                                if_else(DT_Y == 2019, 6, 
                                        if_else(DT_Y == 2020, 8,
                                                if_else(DT_Y == 2021, 10, 12)))))))
  
  # Add trimmed values 
  data_po <- data_po %>%
    
    # create month and year date
    mutate(
      DT_YEAR = as.numeric(DT_YEAR),
      DT_MONTH = as.numeric(DT_MONTH)) %>% 
    
    # compute quarter for each year
    mutate(
      DT_S = if_else(DT_MONTH <= 6, 1, 2) + 
        if_else(DT_YEAR == 2016, 0,
                if_else(DT_YEAR == 2017, 2,
                        if_else(DT_YEAR == 2018, 4, 
                                if_else(DT_YEAR == 2019, 6, 
                                        if_else(DT_YEAR == 2020, 8,
                                                if_else(DT_YEAR == 2021, 10, 12)))))))
    
  data_offer_sub <- data_offer_sub %>% 
    mutate(
      DD_TOT_PROCESS    = difftime(DT_ACCEPT_OC, DT_TENDER_START, units = "days"),
      DD_SUBMISSION     = difftime(DT_OFFER_END, DT_OFFER_START, units = "days"),
      DD_DECISION       = difftime(DT_ACCEPT_OC, DT_OFFER_END, units = "days"),
      DD_AWARD_CONTRACT = difftime(DT_ACCEPT_OC, DT_TENDER_AWARD, units = "days")
    ) %>% 
    mutate(
      DD_TOT_PROCESS    = ifelse(CAT_OFFER_SELECT == 1, DD_TOT_PROCESS, NA),
      DD_SUBMISSION     = ifelse(CAT_OFFER_SELECT == 1, DD_SUBMISSION, NA),
      DD_DECISION       = ifelse(CAT_OFFER_SELECT == 1, DD_DECISION, NA),
      DD_AWARD_CONTRACT = ifelse(CAT_OFFER_SELECT == 1, DD_DECISION, NA)
    )
  
}

# DATA CLEANING: firms ---------------------------------------------------

{
  
  # adjust the rut code for the firm-level data
  data_firms_clean <- data_firms %>% 
    filter(YEAR == 2019) 
  
  # merge sme information to main dataset
  data_offer_sub <- data_offer_sub %>% 
    left_join(data_firms_clean, by = c("ID_RUT_FIRM"))

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
  data_offer_sub <- clean_string(data_offer_sub, STR_FIRM_CITY) %>% 
    select(-STR_FIRM_CITY) %>% 
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
  test <- data_offer_sub %>% 
    mutate(region = as.character(STR_FIRM_REGION)) %>% 
    mutate(region = substr(region, 0, str_locate(region, " ")[[1]] - 1)) %>% 
   mutate(
      STR_FIRM_REGION = ifelse(region == "I RE", "Región de Tarapacá",
                      ifelse(region == "II R", "Región de Antofagasta",
                             ifelse(region == "III ", "Región de Atacama",
                                    ifelse(region == "IV R", "Región de Coquimbo ",
                                           ifelse(region == "IX R", "Región de la Araucanía ",
                                                  ifelse(region == "V RE","Región de Valparaíso",
                                                         ifelse(region == "VI R", "Región del Libertador General Bernardo O´Higgins",
                                                                ifelse(region == "VII ", "Región del Maule",
                                                                       ifelse(region == "VIII", "Región del Biobío ",
                                                                              ifelse(region == "X RE", "Región de los Lagos",
                                                                                     ifelse(region == "XI R","Región Aysén del General Carlos Ibáñez del Campo",
                                                                                            ifelse(region == "XII ", "Región de Magallanes y de la Antártica",
                                                                                                   ifelse(STR_FIRM_REGION == "XIII", "Región Metropolitana de Santiago",
                                                                                                          ifelse(STR_FIRM_REGION == "XIV ", "Región de Los Ríos",
                                                                                                                 ifelse(STR_FIRM_REGION == "XV R","Región de Arica y Parinacota",
                                                                                                                        ifelse(STR_FIRM_REGION == "XVI ", "Región del Ñuble", NA))))))))))))))))) %>% 
    select(-region)
 
}


  
  data_offer_sub <- data_offer_sub %>% 
    
    # One dummy for bidder being from the same municipality
    mutate(same_municipality_bidder = ifelse(STR_BUYER_CITY == STR_FIRM_CITY, 1, 0)) %>% 
    
    # One dummy for bidder being from the same STR_FIRM_REGION
    mutate(same_region_bidder       = ifelse(STR_BUYER_REGION == STR_FIRM_REGION, 1, 0)) %>% 
    
    # One dummy for winner being an SME
    mutate(sme_winner               = ifelse(CAT_OFFER_SELECT == 1, CAT_MSME, NA)) %>% 
    
    # One dummy for the winner being from the same municipality
    mutate(same_municipality_winner = ifelse(CAT_OFFER_SELECT == 1, same_municipality_bidder, NA)) %>% 
    
    # One dummy for the winner being from the same STR_FIRM_REGION
    mutate(same_region_winner = ifelse(CAT_OFFER_SELECT == 1, same_region_bidder, NA))
    


# SAVE DATA --------------------------------------------------------------------

  {
  
    # Save data frames
    fwrite(data_offer_sub , file.path(fin_data, "data_offer_sub.csv" ))
    
    # Save data frames
    fwrite(data_pos_raw , file.path(fin_data, "purchase_orders_raw.csv" ))
    
    # Remove data frames to free RAM
    rm(data_offer_sub)
    
  }
