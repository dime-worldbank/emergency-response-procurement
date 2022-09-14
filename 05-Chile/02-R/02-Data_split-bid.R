# Made by Leandro Veloso
# main: Separate the data set in groups

# year seq
for (k in seq_along(sequence_dates)) { 
  # 1: reading data  ----
  {  
    # Getting year month
    year  <- year(sequence_dates[k])
    month <- month(sequence_dates[k])
    
    # Filling left zero
    month_str<- str_pad(month, 2, pad = "0")
    
    # displaying
    print(paste0("Running ",month_str,"/",year )) 
    
    # month leading zero
    month_str<- str_pad(month, 2, pad = "0")
    
    # File
    file <- paste0("lic_",year,"-", month,".csv")
    
    # Raw path
    raw_path <- paste0(dropbox_dir,"1 - import/2-unzipped")
    
    # reading payment
    #bid_data<- read.csv2(paste0(raw_path, "/", file), encoding = "latin") %>%
    #	mutate(year= year,month=month) %>%
    #  as.data.table()
    
    bid_data<- data.table::fread(
      paste0(raw_path, "/", file), 
      encoding = "Latin-1", colClasses = "character") %>%
      mutate(year= year,month=month) %>%
      as.data.table()
    
    # %>% slice_sample(prop=0.05) # Making faster
  } 
  
  # 2: Renaming and labeling  ----
  {
    # Checking file size
    print(object.size(bid_data), units = "Mb")
    
    # List of existing variables
    filter_var_names= colnames(bid_data)
    
    # Load the list of original names and R names
    rename_variables <- 
      data.table::fread(file.path(github_dir,"auxilary_files",
                                  "01-tender_name_label.csv")) %>% 
      filter(Original_names %in% filter_var_names) %>%
      filter(!is.na(New_names))
    
    # Apply the changes listed in the Excel file
    bid_data_rename <- bid_data
    setnames(bid_data_rename, old = rename_variables$Original_names, 
             new = rename_variables$New_names)
    
    # Formating data  
    var_labels <- setNames(as.list(rename_variables$Label), rename_variables$New_names)
    
    # Apply the changes listed in the Excel file
    bid_data_rename <-
      bid_data_rename %>%
      set_variable_labels(.labels = var_labels, .strict = FALSE)
  }
  
  # 3: id study ----
  { 
    # 0: From the previous:
    {
      # Counting full duplications
      sum(duplicated(bid_data_rename))
      
      # Removing them
      bid_data_rename <- bid_data_rename %>%
        filter(!duplicated(bid_data_rename)) 
      
      # Checking the unique id
      checking_select <- bid_data_rename %>%
        select(tender_id, buyer_id,lot_id,participant_estab_id,participant_firm_id)
      
      # Checking duplications in the restrict data
      sum(duplicated(select(checking_select,-buyer_id)))
      sum(duplicated(select(checking_select,-tender_id,-buyer_id)))
      sum(duplicated(select(checking_select,-tender_id,-buyer_id,-participant_firm_id)))
      
      # Rate duplicaitoin
      dup_rate = round(100*sum(duplicated(select(checking_select,lot_id,participant_estab_id)))/nrow(checking_select)
                       ,d=2)
      # Counting 
      print( paste0("We have ",dup_rate, "% of duplication"))
      
      # Checking missing
      sum(is.na(checking_select$tender_id))
      sum(is.na(checking_select$lot_id))
      sum(is.na(checking_select$buyer_id))
      sum(is.na(checking_select$participant_firm_id)) 
      
      # Creating an offer id
      bid_data_rename<-bid_data_rename %>%
        dplyr::group_by(lot_id, participant_estab_id) %>%
        dplyr::mutate(offer_id = row_number()) %>%
        dplyr::ungroup() %>%
        relocate(year, month, tender_id,buyer_id,lot_id,participant_estab_id,offer_id ) %>%
        as.data.table() 
      
      # Counting multiple offers
      bid_data_rename[,.N,by = c("offer_id")]
    }
    
    # 1: tender id
    {
      # Couting duplications
      bid_data_rename[, N_rep_item:= .N , by= c("tender_id")]
      
      # Fiding duplication
      bid_data_rename[, .N , by= c("N_rep_item")]
      
      # Filter 1: First Filter ( NO item id)
      print(paste0("Number of tender id missing ", bid_data_rename[is.na(tender_id) , .N]))
      
      # Checking id item - Eye check structure
      fast_panel <- select(bid_data_rename,tender_id,tender_code) %>%
        mutate(length_id= str_length(tender_id),
               length_code= str_length(tender_code))
      
      # Checking lower and upper value
      head(fast_panel)
      tail(fast_panel)
      
      # Counting
      fast_panel[,.N, by =c("length_id")]
      fast_panel[,.N, by =c("length_code")]
      
      # Removing extra data
      rm(fast_panel)
    }
    
    # 2: item id
    {
      # Couting duplications
      bid_data_rename[, N_rep_item:= .N , by= c("lot_id")]
      
      # Fiding duplication
      bid_data_rename[,   .N , by= c("N_rep_item")] 
      
      # Filter 2: First Filter ( NO OC)
      print(paste0("Number of Codigo missing ", bid_data_rename[is.na(lot_id) , .N]))
      
      # Checking id item - Eye check structure
      fast_panel <- select(bid_data_rename,lot_id,lot_code_onu) %>%
        mutate(length_id= str_length(lot_id),
               length_code= str_length(lot_code_onu))
      
      # Checking lower and upper value
      head(fast_panel)
      tail(fast_panel)
      
      # Counting
      fast_panel[,.N, by =c("length_id")]
      fast_panel[,.N, by =c("length_code")]
      
      # Removing extra data
      rm(fast_panel)
    }
    
    # 3 : RUT Adjust
    {
      # RUT structure
      {
        # XX.XXX.XXX - Y
        one_two_dgt <- or(DGT,DGT %R% DGT)
        two_dgt     <- DGT %R% DGT
        three_dgt   <- DGT %R% DGT %R% DGT
        
        example <- c("60.910.047-8", "61.608.401-1", "61.608.401-k", "1.608.401-2", "132.608.401-k")
        
        pattern_rut <- one_two_dgt %R%  "." %R% three_dgt %R% "." %R% three_dgt %R% "-" %R% DGT
        str_view(example, pattern = pattern_rut)
      }
      
      # Adjust proposal
      {
        RUT_problem_set <- c("61.601.000-K","6.091.7  -8"," 60. 000.660-2 ")
        
        # To lower
        str_to_lower(RUT_problem_set)
        
        # Removing space
        str_remove_all(RUT_problem_set, pattern = SPACE)
      }
      
      glimpse(bid_data_rename %>% select(contains("rut")))
      
      # First RUT adjust
      # Generate rut index
      bid_data_rename<-bid_data_rename %>%
        mutate( buyer_rut       = str_remove_all( str_to_lower(buyer_rut), pattern = SPACE),
                participant_rut      = str_remove_all( str_to_lower(participant_rut    ), pattern = SPACE),
                D_rut_participant_ok = str_detect(participant_rut, pattern = pattern_rut),
                D_rut_buyer_ok  = str_detect(buyer_rut, pattern = pattern_rut)
        )
    }
    
    # 5: Buyer id analysis 
    {
      # Generate rut index
      bid_data_rename[,.N, by =c("D_rut_buyer_ok") ]
      
      # Filter 3: First Filter ( NO OC)
      print(paste0("Number of Codigo missing ", bid_data_rename[is.na(buyer_rut) , .N]))
      
      # Checking
      dim(bid_data_rename)
      n_distinct(bid_data_rename$buyer_rut) 
      n_distinct(bid_data_rename$buyer_id) 
      
      # Checking id item - Eye check structure
      fast_panel <- select(bid_data_rename,D_rut_buyer_ok,buyer_rut,buyer_id) %>%
        mutate(length_id= str_length(buyer_id),
               length_code= str_length(buyer_rut))
      
      # Checking lower and upper value
      head(fast_panel)
      tail(fast_panel)
      
      # Counting
      fast_panel[,.N, by =c("length_id")]
      fast_panel[,.N, by =c("length_code")]
      
    }
    
    # 6: participant id analysis 
    {
      # Generate rut index
      bid_data_rename[,.N, by =c("D_rut_participant_ok") ]
      
      # Example of wrong pattern
      sample( bid_data_rename[D_rut_participant_ok==FALSE]$participant_rut,size=26)
      
      # Filter 4: First Filter ( NO OC)
      print(paste0("Number of Codigo missing ", bid_data_rename[is.na(participant_rut) , .N]))
      
      # Checking
      dim(bid_data_rename)
      n_distinct(bid_data_rename$participant_rut) 
      n_distinct(bid_data_rename$participant_estab_id)  
      
      # Checking id item - Eye check structure
      fast_panel <- select(bid_data_rename,D_rut_participant_ok,participant_rut,participant_estab_id) %>%
        mutate(length_id= str_length(participant_estab_id),
               length_code= str_length(participant_rut))
      
      # Checking lower and upper value
      head(fast_panel)
      tail(fast_panel)
      
      # Counting
      fast_panel[,.N, by =c("length_id")]
      fast_panel[,.N, by =c("length_code")]
      
      rm(fast_panel)
    }
  }
  
  # 4: Adjusting values  ----
  {
    set_var_num <-
      c(
        "tender_status_code",                   
        "tender_informed",                      
        "tender_type_code",                     
        "tender_type_call",                     
        "tender_stage",                         
        "tender_status_stage",                  
        "tender_justification",                 
        "tender_public_state_offer",            
        "tender_status_cs",                     
        "tender_contract",                      
        "tender_works",                         
        "tender_complains",                     
        "tender_date_evaluation",               
        "tender_Estimacion",                    
        "tender_VisibilidadMonto",              
        "tender_estimated_volume",              
        "tender_time",                          
        "tender_TipoPago",                      
        "tender_SubContratacion",               
        "tender_UnidadTiempoDuracionContrato",  
        "tender_TiempoDuracionContrato",        
        "tender_ExtensionPlazo",                
        "tender_EsBaseTipo",                    
        "tender_UnidadTiempoContratoLicitacion",
        "tender_ValorTiempoRenovacion",         
        "tender_EsRenovable",                   
        "tender_TipoAprobacion",                
        "tender_NumeroAprobacion",              
        "tender_NumeroOferentes",               
        "tender_Correlativo",                   
        "tender_CodigoEstadoLicitacion",        
        "lot_qtd",                              
        "participant_firm_id",                  
        "offer_award_value",                    
        "offer_quantity",                       
        "offer_unit_price",                     
        "offer_total_price",                    
        "offer_qtd_award",                      
        "offer_total_price_award"
      )             
    
    for( var in set_var_num) {
      bid_data_rename[[paste(var)]] = as.numeric(
        str_replace_all(bid_data_rename[[paste(var)]],
                        pattern= ",","."))
    } 
  }  
  
  # 5: Adjusting date  ----
  {
    # Checking if it works
    {
      # Confirm patterng
      example <- c( "2019-01-31", "2012-02-31", "2019-30-12")
      ymd_pattern <- DGT %R% DGT %R% DGT %R% DGT %R% "-" %R%  DGT %R% DGT %R% "-"  %R%  DGT %R% DGT
      str_view(example, ymd_pattern)
      
      # Checking 
      count(bid_data_rename)
      
      sum(str_detect( bid_data_rename$oc_date_creation       ,ymd_pattern),rm.na=TRUE)
    } 
    
    # List of names to convert to date
    index = str_detect(colnames(bid_data_rename),pattern = "date") &
      !(colnames(bid_data_rename) %in% c("tender_date_format","tender_date_evaluation"))
    date_list<- colnames(bid_data_rename)[index] 
    
    # Changing date format
    for (var_date in date_list) {
      print( paste0("Adjusting ", var_date))
      bid_data_rename[[var_date]] = ymd(bid_data_rename[[var_date]])
      
      # Removing outliers
      bid_data_rename[[var_date]][!between(bid_data_rename[[var_date]],ymd("2000/01/01"),ymd("2022/12/31"))] <-
        NA
    }
    
    
    # Adjusting duration variable
    bid_data_rename<- bid_data_rename %>%
      mutate( tender_time_to_evaluate = 
                case_when(str_detect(tender_date_format,pattern=or("day","DAY"))   ~ ddays( x = tender_date_evaluation),
                          str_detect(tender_date_format,pattern=or("hour","HOUR")) ~ dhours(x = tender_date_evaluation),
                          str_detect(tender_date_format,pattern=or("month","MONTH")) ~ dmonths(x = tender_date_evaluation),
                          str_detect(tender_date_format,pattern=or("week","WEEk")) ~ dweeks(x = tender_date_evaluation)
                )
      )  
    
    # Adjusting duration variable
    bid_data_rename<- bid_data_rename %>%
      mutate( tender_time    = 
                case_when(str_detect(tender_time_unit ,pattern=or("day","DAY"))   ~ ddays( x = tender_time  ),
                          str_detect(tender_time_unit ,pattern=or("hour","HOUR")) ~ dhours(x = tender_time  ),
                          str_detect(tender_time_unit ,pattern=or("month","MONTH")) ~ dmonths(x = tender_time  ),
                          str_detect(tender_time_unit ,pattern=or("week","WEEk")) ~ dweeks(x = tender_time  )
                )
      )  
    
    
    # Heading
    head(bid_data_rename %>% select( tender_date_format,tender_date_evaluation,tender_time_to_evaluate))
    
    # Checking order of data
    {
      # first order send
      indices <-seq_along(date_list)
      
      # Matrix
      mat_order <-matrix(rep(NA,length(indices)^2),length(indices),length(indices))
      
      # Checking orders
      estat_date_order <-1:length(indices)
      for (i in 1:length(indices)) {
        for (j in i:length(indices)) {
          # Checking
          order<- mean(bid_data_rename[[date_list[i]]] >bid_data_rename[[date_list[j]]],
                       rm.na=TRUE) > 0.5
          
          if ( !is.na(order) & order==TRUE) {
            
            temporary <-  estat_date_order[i]
            estat_date_order[i] <- estat_date_order[j]
            estat_date_order[j] <- temporary
          } 
        }
      }
      
      # Estitistical order
      date_list[estat_date_order]
      
      # Renaming
      bid_data_rename<- bid_data_rename %>%
        relocate(!!date_list[estat_date_order], .after =  tender_complains ) %>%
        select( -tender_date_format,-tender_date_evaluation,-tender_time_unit)
    } 
  }
  
  # 6: Cleaning variables  ----
  {
    # Export to excel
    #write_xlsx(list("1-sample"  = slice_sample(bid_data_rename,n=100)),
    #           path = file.path(dropbox_dir,"Results/2-tables", 
    #                            "3-sample_100-help_clean.xlsx"))
    
    # 01: tender status 
    bid_data_rename[,.N,by = c("tender_status_code",	"tender_status_name")]
    
    bid_data_rename<-bid_data_rename %>%
      select(-tender_status_code) %>%
      mutate(tender_status_name = as.factor(tender_status_name)) %>%
      dplyr::rename(tender_status = tender_status_name)
    
    # 02: Currency
    bid_data_rename[,.N,by = c("tender_currency_code",	"tender_currency")]
    bid_data_rename[,.N,by = c("offer_currency")]
    
    bid_data_rename <- bid_data_rename %>%
      mutate(offer_currency= as.factor(
        case_when(offer_currency=="Peso Chileno" ~ "CLP",
                  offer_currency=="Unidad de Fomento" ~ "CLF",
                  offer_currency=="Dolar" ~ "USD",
                  offer_currency=="Euro" ~ "EUR",
                  offer_currency=="Moneda revisar" ~ "UTM")
      ),
      tender_currency_code =as.factor(tender_currency_code)) %>%
      select(-tender_currency) %>%
      dplyr::rename(tender_currency =tender_currency_code)
    
    bid_data_rename[,.N,by = c("tender_currency","offer_currency")]
    
    # 03: offer sellect
    bid_data_rename[,.N,by = c("offer_select")]
    
    bid_data_rename <- bid_data_rename %>%
      mutate(offer_select= offer_select== "Seleccionada")
    
    bid_data_rename[,.N,by = c("offer_select")]
    
    # 04: tender_Modalidad
    bid_data_rename[,.N,by = c("tender_Modalidad")]
    
    bid_data_rename <- bid_data_rename %>%
      mutate(tender_Modalidad= as.factor("tender_Modalidad"))
  }
  
  # 7: Splitting Data  ----
  { 
    # 1: Tender X lot X offer
    {
      # Set var tender
      tender_list<- c("tender_id",
                      "tender_code",
                      "tender_date_creation",
                      "tender_date_close_offer",
                      "tender_estimated_volume",
                      "tender_type")
      buyer_list <- c("buyer_id", "buyer_rut")
      part_list  <- c("participant_estab_id", "participant_rut")
      item_list  <- c("lot_id","lot_code_onu","lot_qtd" )
      
      
      offer_data <- select(bid_data_rename,starts_with("offer"),year,month,
                           !!tender_list,
                           !!buyer_list,
                           !!part_list,
                           !!item_list) %>%
        # removing duplicates
        distinct(lot_id,participant_estab_id,offer_id, .keep_all = TRUE) %>%
        relocate(tender_id,lot_id,participant_estab_id,offer_id,offer_select,tender_code,buyer_id,buyer_rut,
                 participant_rut,lot_code_onu, year,month) %>%
        arrange(tender_id,lot_id,participant_estab_id)
      
      
      # Checking file size
      print(object.size(offer_data), units = "Mb")
      
      write_rds(offer_data,paste0(dropbox_dir,"2 - data_construct/1-data_temp/offer-",year,month_str,".rds"))
    }
    
    # 2: Tender X lot
    { 
      lot_data <- select(bid_data_rename,starts_with("lot"),year,month,
                         tender_id,
                         tender_code,
                         tender_date_creation,
                         tender_date_close_offer,
                         tender_estimated_volume,
                         buyer_id,
                         buyer_rut) %>%
        # removing duplicates
        distinct(lot_id, .keep_all = TRUE) %>%
        relocate(buyer_id,tender_code,lot_id,lot_code_onu,buyer_id,buyer_rut)  
    
      
      # Checking file size
      print(object.size(lot_data), units = "Mb")
      
      write_rds(lot_data,paste0(dropbox_dir,"2 - data_construct/1-data_temp/lot-",year,month_str,".rds"))
    } 
    
    # 3: Tender
    {
      tender_data <- select(bid_data_rename,starts_with("tender"),year,month)  %>%
        # removing duplicates
        distinct(tender_id, .keep_all = TRUE) %>%
        relocate(tender_id,tender_code,year,month) %>%
        arrange(tender_id)
    
      
      # Checking size 
      print(object.size(tender_data), units = "Mb")
      
      # Tender
      write_rds(tender_data,paste0(dropbox_dir,"2 - data_construct/1-data_temp/tender-",year,month_str,".rds"))
    }
    
    # 4: Buyer
    {
      buyer_data <- select(bid_data_rename,starts_with("buyer"),D_rut_buyer_ok)  %>%
        # removing duplicates
        distinct(buyer_id, .keep_all = TRUE) %>%
        relocate(buyer_id,buyer_rut ) %>%
        arrange(buyer_id)
    
      
      # Checking size 
      print(object.size(buyer_data), units = "Mb")
      
      # Tender
      write_rds(buyer_data,paste0(dropbox_dir,"2 - data_construct/1-data_temp/buyer-",year,month_str,".rds"))
    }
    
    # 5: Participant
    {
      seller_data <- select(bid_data_rename,starts_with("participant"),D_rut_participant_ok) %>%
        # removing duplicates
        distinct(participant_estab_id, .keep_all = TRUE) %>%
        relocate(participant_estab_id,participant_rut) %>%
        arrange(participant_estab_id)

      
      # Checking file size
      print(object.size(seller_data), units = "Mb")
      
      write_rds(seller_data,paste0(dropbox_dir,"2 - data_construct/1-data_temp/seller-",year,month_str,".rds"))
    }
  }
  
  # 8: Checking merge between data ----
  {
    # anti join and semi join to check
    
    # 1: Offer vs lot ( Perfect)
    { 
      # Counting
      offer_data[,.N]
      
      # Matches
      offer_data %>%  
        semi_join(lot_data, by = c("lot_id")) %>%
        count()
      
      # Anti-joing
      offer_data %>%  
        anti_join(lot_data, by = c("lot_id")) %>%
        count()
    }
    
    # 2: Offer vs tender_data
    { 
      # Counting
      offer_data[,.N]
      
      # Matches
      offer_data %>%  
        semi_join(tender_data, by = c("tender_id")) %>%
        count()
      
      # Anti-joing
      offer_data %>%  
        anti_join(tender_data, by = c("tender_id")) %>%
        count()
    }
    
    # 3: Offer vs buyer
    { 
      # Counting
      offer_data[,.N]
      
      # Matches
      offer_data %>%  
        semi_join(buyer_data, by = c("buyer_id")) %>%
        count()
      
      # Anti-joing
      offer_data %>%  
        anti_join(buyer_data, by = c("buyer_id")) %>%
        count()
    }
    
    # 4: Offer vs participant
    { 
      # Counting
      offer_data[,.N]
      
      # Matches
      offer_data %>%  
        semi_join(seller_data, by = c("participant_estab_id")) %>%
        count()
      
      # Anti-joing
      offer_data %>%  
        anti_join(seller_data, by = c("participant_estab_id")) %>%
        count()
    }
  }
}
