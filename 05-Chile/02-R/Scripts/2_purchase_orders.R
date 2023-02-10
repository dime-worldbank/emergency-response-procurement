# ---------------------------------------------------------------------------- #
#                              2 purchase data: cleaning process               #
#                                   World Bank - DIME                          #
#                                                                              #
# ---------------------------------------------------------------------------- #

# 1: Download Data ------------------------------------------------------------

{
  
  for (year in seq(2015, 2022)) {
    
    for (month in seq(1, 12)) {
      
      # download only if the raw file has not already been downloaded
      if (!file.exists(file.path(raw_data, paste0("Purchase/", year, "-", month, ".csv")))) {
        
        # to keep track of the process
        print(paste0("Downloading file for ", month, "/", year))
        
        # select the right url directory for downloading 
        url <- paste0("https://transparenciachc.blob.core.windows.net/oc-da/", year, "-", month, ".zip")
        
        # download the file from the API
        download.file(url, file.path(raw_data, paste0("purchase_orders_", year, "-", month, ".zip")), quiet = TRUE, mode = "wb")
        
        # unzip file
        unzip(
          file.path(raw_data, paste0("purchase_orders_", year, "-", month, ".zip")),
          exdir = file.path(raw_data, paste0("Purchase"))
        )
        
        # remove zip extension
        file.remove(file.path(raw_data, paste0("Purchase/purchase_orders_", year, "-", month, ".zip")))
        
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
      data <- fread(file         = file.path(raw_data, paste0("Purchase/", year, "-", month, ".csv")), 
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
    
    data_names <- read_xlsx(file.path(code_doc, "codebook-purchase_orders.xlsx"))
    
  } 
  
}

# 3: Clean Data ----------------------------------------------------------------

{
  
  # Loop of cleaning procedures for each dataset in the list of datasets
  for (i in 1:length(datalist)) {
    
    print(paste0(i, " out of ", length(datalist)))
    
    # 3.1: select only relevant variables 
    datalist[[i]] <- datalist[[i]] %>% 
      dplyr::select(
        Codigo,
        CodigoLicitacion,
        codigoProductoONU,
        CodigoAbreviadoTipoOC,
        EsTratoDirecto, 
        EsCompraAgil, 
        Estado,
        FechaCreacion,
        FechaEnvio,
        FechaAceptacion,
        RutSucursal,
        RutUnidadCompra,
        MontoTotalOC,
        TipoMonedaOC)
    
    # 3.3: format dates
    datalist[[i]] <- datalist[[i]] %>% 
      mutate(across(starts_with("Fecha"), ~ as.Date(.x, format = "%Y-%m-%d"))) %>% 
      mutate(DT_YEAR = year(FechaEnvio)) %>% 
      mutate(DT_MONTH = month(FechaEnvio))
    
    # 3.4: format numeric values
    datalist[[i]] <- datalist[[i]] %>% 
      mutate(
        MontoTotalOC = as.numeric(gsub(",", ".", MontoTotalOC))
      ) 
    
    # 3.5: change names 
    datalist[[i]] <-
      datalist[[i]] %>%
      rename(!!set_names(data_names$Original_names, 
                         data_names$New_names))
    
    # 3.6: filter only purchases that have gone through ("Aceptada"+"Enviada a proveedor"+"Recepcion Conforme")
    datalist[[i]] <-
      datalist[[i]] %>%
      filter(
        CAT_STATUS_OC != "Cancelacion solicitada" & 
          CAT_STATUS_OC != "En proceso" 
      )
    
    # 3.7: adjust the id for matching
    datalist[[i]] <-
      datalist[[i]] %>%
      # all uppercase
      mutate(ID_PURCHASE_ORDER = str_to_upper(ID_PURCHASE_ORDER)) %>% 
      # no whitespaces
      mutate(ID_PURCHASE_ORDER = gsub("\\s", "", ID_PURCHASE_ORDER)) %>% 
      # only alphanumeric values
      mutate(ID_PURCHASE_ORDER = gsub("[^[:alpha:][:alnum:]]", "", ID_PURCHASE_ORDER))
    
    # 3.8: adjust ID_RUT_FIRM
    datalist[[i]] <- rut_check(datalist[[i]], ID_RUT_FIRM, without_dots = FALSE) %>% 
      dplyr::select(
        - c("ID_RUT_FIRM")
      ) %>% 
      rename(
        ID_RUT_FIRM = var
      ) %>% 
      mutate(
        ID_RUT_FIRM = gsub("\\.", "", ID_RUT_FIRM)
      )
    
    # 3.9: filtering out the intermediary cenabast R.U.T.: 61608700-2
    datalist[[i]] <- datalist[[i]] %>% 
      filter(ID_RUT_ISSUER != "61608700-2")
    
    # 3.12: drop 3 observations without an ID_PURCHASE_ORDER
    datalist[[i]] <- datalist[[i]] %>% 
      filter(!is.na(ID_PURCHASE_ORDER))
    
  }
  
  # append all the loaded datasets together to create one dataset  
  purchase_data = do.call(rbind, datalist)
  
  # remove list of data
  rm(datalist)
  
}

# 4: Collapse data -------------------------------------------------------------

{
  
  # We collapse data at the PO X SELLER X TENDER level for all POs coming from competitive processes    
  data_po <- purchase_data %>% 
    group_by(
      ID_RUT_FIRM, 
      ID_TENDER) %>% 
    dplyr::summarise(
      DT_ACCEPT_OC = first(DT_ACCEPT_OC)
    )
    
  
  
}

# 5: Save data ---------------------------------------------------------------

{

  # save the collapsed dataset
  fwrite(purchase_data, 
         file = file.path(int_data, "purchase_orders_raw.csv"))
  
  # save the collapsed dataset
  fwrite(data_po, 
         file = file.path(int_data, "purchase_orders.csv"))
  
  # We create and save a dataset at the 
  
  # clean the workspace from the dataframe
  rm(data_names, purchase_data, data_po)
  
  # free unused memory usage
  gc()
  
}
