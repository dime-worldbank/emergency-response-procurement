# ---------------------------------------------------------------------------- #
#                              3 tender data:  cleaning process                #
#                                   World Bank - DIME                          #
#                                                                              #
# ---------------------------------------------------------------------------- #

# 1: Download Data ------------------------------------------------------------

{
  
  for (year in seq(2015, 2022)) {
    
    for (month in seq(1, 12)) {
      
      # download only if the raw file has not already been downloaded
      if (!file.exists(file.path(raw_data, paste0("Tender/lic_", year, "-", month, ".csv")))) {
        
        # to keep track of the process
        print(paste0("Downloading file for ", month, "/", year))
        
        # select the right url directory for downloading 
        url <- paste0("https://transparenciachc.blob.core.windows.net/lic-da/", year, "-", month, ".zip")
        
        # download the file from the API
        download.file(url, file.path(raw_data, paste0("Tender/tender_", year, "-", month, ".zip")), quiet = TRUE, mode = "wb")
        
        # unzip file
        unzip(
          zipfile = file.path(raw_data, paste0("Tender/tender_", year, "-", month, ".zip")),
          exdir   = file.path(raw_data, paste0("Tender/Tender"))
        )
        
        # remove zip extension
        file.remove(file.path(raw_data, paste0("Tender/tender_", year, "-", month, ".zip")))
        
      }
    }
  }
}

# 2: Load Data ----------------------------------------------------------------

{
  
  # create list for all the following datsets that we will append all together 
  datalist = vector("list", length = 1)
  
  # term for the following loop 
  i = 1
  
  # load  and clean the data from 2016 to 2021
  for (year in seq(2015, 2022)) {
    
    for (month in seq(1, 12)) {
      
      # to keep track of the process  
      print(paste0("Appending: file for ", month, "/", year))
      
      # load the dataset
      data <- fread(file         = file.path(raw_data, paste0("Tender/lic_", year, "-", month, ".csv")), 
                    showProgress = TRUE,
                    encoding     = "Latin-1")
                    
      # Append the loaded dataset to the list 
      datalist[[i]] <- data 
      
      # iterative term
      i = i + 1
      
      # remove data
      rm(data)
      
    }
  }
  
  { # load name conversion table
    
    data_names <- read_xlsx(file.path(code_doc, "codebook-tenders.xlsx"))
    
  }
  
  {
    
    # Load COVID-19 data
    item_covid   <- readxl::read_xlsx(file.path(raw_data, "Auxiliary files/covid_label_table.xlsx"))
    
  }
  
}

# 3: Clean Data ----------------------------------------------------------------

{
  
  # Select ID UNPSC codes related to covid
  item_covid_list <- item_covid %>% select(ID_ITEM_UNSPSC, CAT_MEDICAL, COVID_LABEL)
  
  # Loop of cleaning procedures for each dataset in the list of datasets
  for(i in 1:length(datalist)) {
    
    print(paste0(i, " out of ", length(datalist)))
    
    # 3.1: select only relevant variables 
    datalist[[i]] <- datalist[[i]] %>% 
      select(
        Codigoitem,
        CodigoExterno,
        ComunaUnidad,
        RegionUnidad,
        sector, 
        `Tipo de Adquisicion`, 
        RutUnidad,
        CodigoMoneda,
        FechaCreacion,
        FechaCierre,
        FechaInicio,
        FechaFinal,
        FechaPublicacion,
        CodigoTipo,
        Tipo,
        FechaAdjudicacion,
        Modalidad,
        RutProveedor,
        `Cantidad Ofertada`,
        `Moneda de la Oferta`,
        MontoUnitarioOferta,
        `Valor Total Ofertado`,
        CantidadAdjudicada,
        MontoLineaAdjudica,
        FechaEnvioOferta,
        CodigoProductoONU,
        `Estado Oferta`,
        `Oferta seleccionada`
      ) %>% 
      filter(
        (`Estado Oferta` == "Aceptada")
      ) %>% # therefore we exclude offers that have not been accepted and tenders that were "Cerrada", "Suspendida", "Revocada"
      select(-c("Estado Oferta"))
    
    # 3.2: format dates
    datalist[[i]] <- datalist[[i]] %>% 
      mutate(across(starts_with("Fecha"), ~ as.Date(.x, format = "%Y-%m-%d"))) 
    
    # 3.3: format numeric values
    datalist[[i]] <- datalist[[i]] %>% 
      mutate(across(starts_with("Monto"), ~ as.numeric(gsub(",",".", .x)))) %>% 
      mutate(across(c("MontoUnitarioOferta",
                      "Valor Total Ofertado",
                      "CantidadAdjudicada",
                      "MontoLineaAdjudica",
                      "Cantidad Ofertada"), ~ as.numeric(gsub(",",".", .x)))) 
    
    # 3.4: change names 
    datalist[[i]] <-
      datalist[[i]] %>%
      rename(!!set_names(data_names$Original_names, 
                         data_names$New_names))
    
    # 3.5: reformat RUT for suppliers
    datalist[[i]] <- rut_check(datalist[[i]], ID_RUT_FIRM) %>% 
      select(
        - c("ID_RUT_FIRM")
      ) %>% 
      rename(
        ID_RUT_FIRM = var
      ) %>% 
      mutate(
        ID_RUT_FIRM = gsub("\\.", "", ID_RUT_FIRM)
      )
    
    # 3.6: reformat RUT for buyers
    datalist[[i]] <- rut_check(datalist[[i]], ID_RUT_BUYER) %>% 
      select(
        - c("ID_RUT_BUYER")
      ) %>% 
      rename(
        ID_RUT_BUYER = var
      ) %>% 
      mutate(
        ID_RUT_BUYER = gsub("\\.", "", ID_RUT_BUYER)
      )
    
    datalist[[i]] = as.data.table(datalist[[i]])
    
    # 3.7: filtering out the intermediary cenabast R.U.T.: 61608700-2
    datalist[[i]] = datalist[[i]][ID_RUT_BUYER != "61608700-2", ] # 17,027
    
    # 3.8: convert the string for selected offer into dummy
    datalist[[i]] <- datalist[[i]][, CAT_OFFER_SELECT := fifelse(CAT_OFFER_SELECT == "Seleccionada", 1, 0)]
    
  }
  
  # append all the loaded datasets together to create one dataset  
  tender_data = do.call(rbind, datalist)
  
  # flag covid items
  tender_data = tender_data %>% 
    left_join(item_covid, by = c("ID_ITEM_UNSPSC")) %>% 
    mutate(CAT_MEDICAL = ifelse(substr(ID_ITEM_UNSPSC, 0, 2) == "42" | 
                                  substr(ID_ITEM_UNSPSC, 0, 2) == "41" |
                                    substr(ID_ITEM_UNSPSC, 0, 2) == "51", 1, 0)) %>% 
    mutate(COVID_LABEL = ifelse(is.na(COVID_LABEL), 1, 0))
  
  # remove list of data
  rm(datalist, data_names)
  
}


# Save data ---------------------------------------------------------------

{
  
  # save the intermediate dataset
  fwrite(tender_data, 
          file = file.path(int_data, "tenders.csv"))
  
  # clean the workspace from the dataframe
  rm(item_covid, item_covid_list, tender_data)
  
  # free unused memory usage
  gc()
  
}
