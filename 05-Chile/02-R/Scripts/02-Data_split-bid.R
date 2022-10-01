# Made by Leandro Veloso
# main: Separate the data set in groups

# DT_TENDER_YEAR seq
for (k in seq_along(sequence_dates)) { 
  # 1: reading data  ----
  {  
    # Getting DT_TENDER_YEAR DT_TENDER_MONTH
    DT_TENDER_YEAR  <- year(sequence_dates[k])
    DT_TENDER_MONTH <- month(sequence_dates[k])
    
    # Filling left zero
    
    # displaying
    print(paste0("Running ", DT_TENDER_MONTH_str, "/",DT_TENDER_YEAR )) 
    
    # DT_TENDER_MONTH leading zero
    DT_TENDER_MONTH_str<- str_pad(DT_TENDER_MONTH, 2, pad = "0")
    
    # File
    file <- paste0("lic_",DT_TENDER_YEAR,"-", DT_TENDER_MONTH,".csv")
    
    # Raw path
    raw_path <- paste0(dropbox_dir,"1 - import/2-unzipped")
    
    # reading payment
    #bid_data<- read.csv2(paste0(raw_path, "/", file), encoding = "latin") %>%
    #	mutate(DT_TENDER_YEAR= DT_TENDER_YEAR,DT_TENDER_MONTH=DT_TENDER_MONTH) %>%
    #  as.data.table()
    
    bid_data<- data.table::fread(
      paste0(raw_path, "/", file), 
      encoding = "Latin-1", colClasses = "character") %>%
      mutate(year = DT_TENDER_YEAR , month = DT_TENDER_MONTH) %>%
      as.data.table()
    
    # %>% slice_sample(prop=0.05) # Making faster
  } 

  # 2: Renaming and labeling  ----
  {
    # Checking file size
    print(object.size(bid_data), units = "Mb")
    
    # List of existing variables
    filter_var_names= colnames(bid_data)
    
    # Delete some variables that are redundant
    var_delete <- c(
      "UnidadTiempoContratoLicitacion" ,
      "ValorTiempoRenovacion"          ,
      "PeriodoTiempoRenovacion"        ,
      "Tiempo"                         ,
      "UnidadTiempo"                   ,
      "Rubro1"                         ,
      "Rubro2"                         ,
      "Rubro3"                         ,
      "FechasUsuario"                  ,
      "FechaVisitaTerreno"             ,
      "DireccionVisita"                ,
      "FechaEntregaAntecedentes"       ,      
      "DireccionEntrega"               ,
      "CodigoEstado"                   ,
      "FechaTiempoEvaluacion"          ,
      "Informada"                      ,
      "EstadoEtapas"                   ,
      "EsRenovable"                    ,
      "CodigoEstadoLicitacion"         ,
      "Moneda Adquisicion"
    )
    
    bid_data <- select(bid_data, -var_delete)
    
    # Load the list of original names and R names
    rename_variables <- 
      data.table::fread(file.path(github_dir,"auxilary_files",
                                  "01-tender_name_label.csv")) %>% 
      filter(Original_names %in% filter_var_names) %>%
      filter(!is.na(New_names))
    
    # Apply the changes listed in the Excel file
    bid_data_rename <- bid_data
    setnames(bid_data_rename, old = rename_variables$Original_names, 
             new = rename_variables$New_names, skip_absent=TRUE)
    
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
      
      # Creating an offer id
      bid_data_rename<-bid_data_rename %>%
        dplyr::group_by(ID_ITEM, ID_RUT_PARTICIPANT, ID_TENDER, DT_OFFER_SEND) %>%
        arrange(DT_OFFER_SEND) %>% 
        dplyr::mutate(ID_OFFER = paste0(ID_ITEM, "_", row_number())) %>%
        dplyr::ungroup() %>%
        relocate(DT_TENDER_YEAR, DT_TENDER_MONTH, ID_TENDER,STR_BUYER_UNIT,ID_ITEM_UNSPSC,ID_RUT_PARTICIPANT,ID_OFFER ) %>%
        as.data.table() 
      
      # Checking the unique id
      checking_select <- bid_data_rename %>%
        select(ID_ITEM, ID_RUT_PARTICIPANT, ID_TENDER, ID_OFFER)
      
      # Checking duplications in the restrict data
      sum(duplicated(checking_select))
      
      # Rate duplicaitoin
      dup_rate = round(100*sum(duplicated(checking_select))/nrow(checking_select), d=2)
      
      if (dup_rate == 0) {
        
        View(checking_select[duplicated(checking_select) | duplicated(checking_select, fromLast=TRUE),])
        
      }
      
      # Counting 
      print( paste0("We have ", dup_rate, "% of duplication"))
      
      # Checking missing
      
      if (
      sum(is.na(checking_select$ID_TENDER)) != 0
      |
      sum(is.na(checking_select$ID_ITEM_UNSPSC)) != 0
      |
      sum(is.na(checking_select$ID_OFFER)) != 0
      |
      sum(is.na(checking_select$ID_RUT_PARTICIPANT)) != 0
      |
      sum(is.na(checking_select$ID_ITEM)) != 0
      ) {
        
        stop(paste0("There is a missing ID: ", DT_TENDER_MONTH, "/", DT_TENDER_YEAR))
        
      }
      
    }
    
    # 1: tender id
    {
      # Couting duplications
      bid_data_rename[, N_rep_item:= .N , by= c("ID_TENDER")]
      
      # Fiding duplication
      bid_data_rename[, .N , by= c("N_rep_item")]
      
      # Filter 1: First Filter ( NO item id)
      print(paste0("Number of tender id missing ", bid_data_rename[is.na(ID_TENDER) , .N]))
      
      # Checking id item - Eye check structure
      fast_panel <- select(bid_data_rename,ID_TENDER,ID_TENDER_EXTERNAL) %>%
        mutate(length_id= str_length(ID_TENDER),
               length_code= str_length(ID_TENDER_EXTERNAL))
      
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
      bid_data_rename[, N_rep_item:= .N , by= c("ID_ITEM")]
      
      # Fiding duplication
      bid_data_rename[,   .N , by= c("N_rep_item")] 
      
      # Filter 2: First Filter ( NO OC)
      print(paste0("Number of Codigo missing ", bid_data_rename[is.na(ID_ITEM_UNSPSC) , .N]))
      
      # Checking id item - Eye check structure
      fast_panel <- select(bid_data_rename,ID_ITEM_UNSPSC,STR_ITEM_NAME_GENERAL) %>%
        mutate(length_id= str_length(ID_ITEM_UNSPSC),
               length_code= str_length(STR_ITEM_NAME_GENERAL))
      
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
        mutate( ID_BUYER_UNIT       = str_remove_all( str_to_lower(ID_BUYER_UNIT), pattern = SPACE),
                STR_PARTICIPANT_NAME      = str_remove_all( str_to_lower(STR_PARTICIPANT_NAME    ), pattern = SPACE),
                D_rut_participant_ok = str_detect(STR_PARTICIPANT_NAME, pattern = pattern_rut),
                D_rut_buyer_ok  = str_detect(ID_BUYER_UNIT, pattern = pattern_rut)
        )
    }
    
    # 5: Buyer id analysis 
    {
      # Generate rut index
      bid_data_rename[,.N, by =c("D_rut_buyer_ok") ]
      
      # Filter 3: First Filter ( NO OC)
      print(paste0("Number of Codigo missing ", bid_data_rename[is.na(ID_BUYER_UNIT) , .N]))
      
      # Checking
      dim(bid_data_rename)
      n_distinct(bid_data_rename$ID_BUYER_UNIT) 
      n_distinct(bid_data_rename$STR_BUYER_UNIT) 
      
      # Checking id item - Eye check structure
      fast_panel <- select(bid_data_rename,D_rut_buyer_ok,ID_BUYER_UNIT,STR_BUYER_UNIT) %>%
        mutate(length_id= str_length(STR_BUYER_UNIT),
               length_code= str_length(ID_BUYER_UNIT))
      
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
      sample( bid_data_rename[D_rut_participant_ok==FALSE]$STR_PARTICIPANT_NAME,size=26)
      
      # Filter 4: First Filter ( NO OC)
      print(paste0("Number of Codigo missing ", bid_data_rename[is.na(STR_PARTICIPANT_NAME) , .N]))
      
      # Checking
      dim(bid_data_rename)
      n_distinct(bid_data_rename$STR_PARTICIPANT_NAME) 
      n_distinct(bid_data_rename$ID_RUT_PARTICIPANT)  
      
      # Checking id item - Eye check structure
      fast_panel <- select(bid_data_rename,D_rut_participant_ok,STR_PARTICIPANT_NAME,ID_RUT_PARTICIPANT) %>%
        mutate(length_id= str_length(ID_RUT_PARTICIPANT),
               length_code= str_length(STR_PARTICIPANT_NAME))
      
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
        "N_TENDER_COMPLAINS",             
        "AMT_TENDER_ESTIMATED",         
        "N_SUPPLIERS",                             
        "AMT_TOTAL_PRICE",                     
        "AMT_QUANTITY_AWARDED",                    
        "AMT_VALUE_AWARDED",                      
        "AMT_QUANTITY_AWARDED",
        "IND_TENDER_PUBLIC",
        "IND_TENDER_CALL",
        "IND_TENDER_STAGE",
        "IND_TENDER_JUSTIFICATION",
        "IND_OFFER_PUBLICITY",
        "IND_TENDER_CONTRACT",
        "IND_TENDER_WORKS",
        "IND_ESTIMATION_PUBLICITY",
        "IND_SUBCONTRACTION",
        "IND_CONTRACT_IMMEDIATE",
        "IND_TERM_EXTENSION",
        "IND_TENDER_STANDARDS",
        "IND_OFFER_ACCEPTED",
        "IND_OFFER_WIN",
        "AMT_PRICE_UNIT"
      )      
    
    bid_data_rename <- bid_data_rename %>% 
      mutate(
        IND_CONTRACT_IMMEDIATE = ifelse(IND_CONTRACT_IMMEDIATE == "RFB_CONTRACT_TIME_PERIOD_INMEDIATE_EXECUTION", 1, ifelse(IND_CONTRACT_IMMEDIATE == "", NA, 0)),
        IND_OFFER_ACCEPTED     = ifelse(IND_OFFER_ACCEPTED == "Aceptada", 1, 0),
        IND_OFFER_WIN          = ifelse(IND_OFFER_WIN == "Seleccionada", 1, 0)
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
      # Confirm pattern
      example <- c( "2019-01-31", "2012-02-31", "2019-30-12")
      ymd_pattern <- DGT %R% DGT %R% DGT %R% DGT %R% "-" %R%  DGT %R% DGT %R% "-"  %R%  DGT %R% DGT
      str_view(example, ymd_pattern)
      
      # Checking 
      count(bid_data_rename)
      
      sum(str_detect( bid_data_rename$oc_date_creation       ,ymd_pattern),rm.na=TRUE)
    } 
    
    # List of names to convert to date
    index = str_detect(colnames(bid_data_rename),pattern = "DT") &
      !(colnames(bid_data_rename) %in% c("DT_TENDER_FORMAT","DT_TENDER_YEAR","DT_TENDER_MONTH"))
    date_list<- colnames(bid_data_rename)[index] 
    
    # Changing date format
    for (var_date in date_list) {
      print( paste0("Adjusting ", var_date))
      bid_data_rename[[var_date]] = ymd(bid_data_rename[[var_date]])
      
      # Removing outliers
      bid_data_rename[[var_date]][!between(bid_data_rename[[var_date]],ymd("2000/01/01"),ymd("2022/12/31"))] <-
        NA
    }
    
    # Heading
    head(bid_data_rename %>% select(DT_TENDER_FORMAT))
    
    # Checking order of data
    {
      
      # Renaming
      date_list <- bid_data_rename %>% select(!starts_with("DT"),
                                          ID_TENDER,
                                          DT_TENDER_START,
                                          DT_APPROVAL,
                                          DT_OFFER_START ,
                                          DT_QUESTION_START,
                                          DT_QUESTION_END,
                                          DT_ANSWERS,
                                          DT_OFFER_END,
                                          DT_TENDER_SUPPORT,
                                          DT_ECONOMIC_ACT_OPEN,
                                          DT_TECHNICAL_ACT_OPEN,
                                          DT_TENDER_AWARD,
                                          DT_TENDER_EST_AWARD,
                                          DT_SIGNATURE_ESTIMATED,
                                          DT_OFFER_SEND)
          } 
  }
  
  # 6: Cleaning variables  ----
  {
    # Export to excel
    #write_xlsx(list("1-sample"  = slice_sample(bid_data_rename,n=100)),
    #           path = file.path(dropbox_dir,"Results/2-tables", 
    #                            "3-sample_100-help_clean.xlsx"))
    
    # 01: CAT_APPROVAL_TYPE
    bid_data_rename <- bid_data_rename %>%
      mutate(CAT_APPROVAL_TYPE = 
        case_when(CAT_APPROVAL_TYPE == 1 ~ "Autorización",
                  CAT_APPROVAL_TYPE == 2 ~ "Resolución",
                  CAT_APPROVAL_TYPE == 3 ~ "Acuerdo",
                  CAT_APPROVAL_TYPE == 4 ~ "Decreto",
                  CAT_APPROVAL_TYPE == 5 ~ "Otros",
                  CAT_APPROVAL_TYPE == 6 ~ "NOT IDENTIFIED"))
    
    # 02: Currency
    bid_data_rename[,.N,by = c("CAT_TENDER_CURRENCY",	"IND_TENDER_STAGE")]
    bid_data_rename[,.N,by = c("AMT_PRICE_UNIT")]
    
    bid_data_rename[,.N,by = c("IND_TENDER_STAGE","AMT_PRICE_UNIT")]
    
    # 03: offer select
    bid_data_rename[,.N,by = c("IND_OFFER_WIN")]
    
    # 04: STR_PAYMENT_TYPE
    bid_data_rename[,.N,by = c("STR_PAYMENT_TYPE")]
    
    bid_data_rename <- bid_data_rename %>%
      mutate(STR_PAYMENT_TYPE= 
        case_when(STR_PAYMENT_TYPE == -1 ~ "NA",
                  STR_PAYMENT_TYPE == 1  ~ "Pago a 30 días",
                  STR_PAYMENT_TYPE == 2 ~ "Pago a 30, 60 y 90 días",
                  STR_PAYMENT_TYPE == 3 ~ "Pago al día",
                  STR_PAYMENT_TYPE == 4 ~ "Pago Anual",
                  STR_PAYMENT_TYPE == 5 ~ "Pago Bimensual",
                  STR_PAYMENT_TYPE == 6 ~ "Pago Contra Entrega Conforme",
                  STR_PAYMENT_TYPE == 7 ~ "Pagos Mensuales",
                  STR_PAYMENT_TYPE == 8 ~ "Pago Por Estado de Avance",
                  STR_PAYMENT_TYPE == 9 ~ "Pago Trimestral",
                  STR_PAYMENT_TYPE == 10 ~ "Pago a 60 días"))
    
    bid_data_rename <- bid_data_rename %>% 
      mutate(
        IND_TENDER_WORKS = ifelse(IND_TENDER_WORKS == 1, 0, ifelse(IND_TENDER_WORKS == 0, NA, 0))
      )
    
    bid_data_rename <- bid_data_rename %>% 
      mutate(
        IND_OFFER_PUBLICITY = ifelse(IND_TENDER_WORKS == 1, 1, ifelse(IND_TENDER_WORKS == 0, 0, NA))
      )
    
  }
  
  # 7: Splitting Data  ----
  { 
    # 1: Tender X lot X offer
    {
      # Set var tender
      
      tender_list<- c( 
        
        "DT_TENDER_YEAR"          ,
        "DT_TENDER_MONTH"         ,
        "ID_BUYER_RUT"            ,
        "URL_TENDER"              ,
        "ID_TENDER_EXTERNAL"      ,  
        "STR_TENDER_NAME"         ,
        "STR_TENDER_DESCRIPTION"  ,      
        "STR_TENDER_TYPE"         ,
        "CAT_TENDER_STATUS"       , 
        "IND_TENDER_PUBLIC"       , 
        "CAT_TENDER_TYPE"         ,
        "IND_TENDER_CALL"         ,
        "CAT_TENDER_CURRENCY"     ,   
        "IND_TENDER_STAGE"        ,
        "IND_TENDER_JUSTIFICATION",        
        "IND_OFFER_PUBLICITY"     ,   
        "STR_OFFER_PUBLICITY"     ,   
        "CAT_CS_STATUS"           ,
        "IND_TENDER_CONTRACT"     ,   
        "IND_TENDER_WORKS"        ,
        "N_TENDER_COMPLAINS"      ,  
        "DT_TENDER_START"         ,
        "DT_OFFER_END"            ,
        "DT_QUESTION_START"       , 
        "DT_QUESTION_END"         ,
        "DT_ANSWERS"              ,
        "DT_TECHNICAL_ACT_OPEN"   ,     
        "DT_ECONOMIC_ACT_OPEN"    ,    
        "DT_OFFER_START"          ,
        "DT_TENDER_AWARD"         ,
        "DT_TENDER_EST_AWARD"     ,   
        "DT_TENDER_SUPPORT"       , 
        "DT_TENDER_FORMAT"        ,
        "DT_SIGNATURE_ESTIMATED"  ,      
        "CAT_ESTIMATION"          ,
        "STR_FINANCING_SOURCE"    ,    
        "IND_ESTIMATION_PUBLICITY",        
        "AMT_TENDER_ESTIMATED"    ,    
        "STR_PAYMENT_TYPE"        ,
        "CAT_PAYMENT_TYPE"        ,
        "STR_CONTRACT_PROHIBITION",        
        "IND_SUBCONTRACTION"      ,  
        "TM_CONTRACT_UNIT"        ,
        "TM_CONTRACT_DD"          ,
        "IND_CONTRACT_IMMEDIATE"  ,      
        "STR_TENDER_ESTIMATED"    ,    
        "STR_FREE_TEXT_CONTRACT"  ,      
        "IND_TERM_EXTENSION"      ,  
        "IND_TENDER_STANDARDS"    ,    
        "CAT_APPROVAL_TYPE"       , 
        "ID_APPROVAL"             ,
        "DT_APPROVAL"             ,
        "N_SUPPLIERS"             ,
        "CAT_CORRELATIVE"            
        
      )
      
      buyer_list <- c(
      
        "ID_BUYER_RUT"       ,
        "ID_BUYER_DEPARTMENT",
        "STR_BUYER_NAME"     ,
        "STR_BUYER_SECTOR"   ,
        "ID_BUYER_UNIT"      ,
        "STR_BUYER_UNIT"     ,
        "STR_BUYER_ADDRESS"  ,
        "STR_BUYER_CITY"     ,
        "STR_BUYER_REGION"   
        
        )
      
      part_list  <- c(
        
        "ID_PARTICIPANT_INTERNAL"    ,
        "ID_SUB_PARTICIPANT_INTERNAL",
        "STR_PARTICIPANT_NAME"       ,
        "STR_PARTICIPANT_LEGAL_NAME" ,
        "STR_PARTICIPANT_DESCRIPTION"
        
        )
      
      item_list  <- c(
        
        
        "DT_TENDER_YEAR"        ,
        "DT_TENDER_MONTH"       ,
        "ID_ITEM_UNSPSC"        ,
        "STR_ITEM_NAME_GENERAL" , 
        "STR_ITEM_NAME_SPECIFIC",    
        "STR_ITEM_DESCRIPTION"  ,
        "CAT_ITEM_UNIT"         ,
        "AMT_ITEM"   
        
        )
      
      offer_list <- c(
        
        "DT_TENDER_YEAR"      ,
        "DT_TENDER_MONTH"     ,
        "AMT_VALUE_ESTIMATED" ,    
        "STR_OFFER_NAME"      ,
        "IND_OFFER_ACCEPTED"  ,  
        "AMT_OFFER_QUANTITY"  ,  
        "CAT_OFFER_CURRENCY"  ,  
        "AMT_PRICE_UNIT"      ,
        "AMT_TOTAL_PRICE"     ,
        "AMT_QUANTITY_AWARDED",    
        "AMT_VALUE_AWARDED"   , 
        "DT_OFFER_SEND"       ,
        "IND_OFFER_WIN"      
        
      )
      
      # Change type of vars
      bid_data_rename <- bid_data_rename %>% 
        dplyr::mutate(across(starts_with("AMT","IND","N"), as.numeric)) %>% 
        dplyr::mutate(across(starts_with("STR","ID","CAT"), as.character)) %>% 
        dplyr::mutate(across(starts_with("DT"), as.Date)) 
        
      
      offer_data <- select(bid_data_rename   ,
                           ID_OFFER          ,
                           ID_TENDER         ,
                           ID_ITEM           ,
                           ID_BUYER_RUT      ,
                           ID_PARTICIPANT_RUT,
                           !!tender_list     ,
                           !!buyer_list      ,
                           !!part_list       ,
                           !!item_list) %>%
        # removing duplicates
        distinct(ID_ITEM_UNSPSC, ID_RUT_PARTICIPANT, ID_OFFER, .keep_all = TRUE) %>%
        relocate(ID_TENDER,ID_ITEM_UNSPSC,ID_RUT_PARTICIPANT,ID_OFFER,IND_OFFER_WIN,ID_TENDER_EXTERNAL,STR_BUYER_UNIT,ID_BUYER_UNIT,
                 STR_PARTICIPANT_NAME,STR_ITEM_NAME_GENERAL, DT_TENDER_YEAR,DT_TENDER_MONTH) %>%
        arrange(ID_TENDER,ID_ITEM_UNSPSC,ID_RUT_PARTICIPANT) 
      
      
      # Checking file size
      print(object.size(offer_data), units = "Mb")
      
      write_rds(offer_data,paste0(dropbox_dir,"2 - data_construct/1-data_temp/offer-",DT_TENDER_YEAR,DT_TENDER_MONTH_str,".rds"))
    
      }
    
    # 2: Tender X lot
    
    { 
      
      lot_data <- select(bid_data_rename   ,
                         ID_TENDER         ,
                         ID_ITEM           ,
                         ID_BUYER_RUT      ,
                         !!offer_list      ,
                         !!buyer_list      ,
                         !!part_list       ,
                         !!tender_list) %>%
        # removing duplicates
        distinct(ID_ITEM, .keep_all = TRUE) %>%
        relocate(ID_TENDER_EXTERNAL,ID_ITEM,STR_ITEM_NAME_GENERAL) %>% 
        mutate(
          AMT_ITEM               = as.numeric(AMT_ITEM)
        )

      
      # Checking file size
      print(object.size(lot_data), units = "Mb")
      
      write_rds(lot_data,paste0(dropbox_dir,"2 - data_construct/1-data_temp/lot-",DT_TENDER_YEAR,DT_TENDER_MONTH_str,".rds"))
    } 
    
    # 3: Tender
    {
      tender_data <- select(bid_data_rename   ,
                            ID_TENDER         ,
                            ID_BUYER_RUT      ,
                            !!offer_list      ,
                            !!buyer_list      ,
                            !!part_list       ,
                            !!lot_list)  %>%
        # removing duplicates
        distinct(ID_TENDER, .keep_all = TRUE) %>%
        relocate(ID_TENDER,ID_TENDER_EXTERNAL,DT_TENDER_YEAR,DT_TENDER_MONTH) %>%
        arrange(ID_TENDER) 
    
      
      # Checking size 
      print(object.size(tender_data), units = "Mb")
      
      # Tender
      write_rds(tender_data,paste0(dropbox_dir,"2 - data_construct/1-data_temp/tender-",DT_TENDER_YEAR,DT_TENDER_MONTH_str,".rds"))
    }
    
    # 4: Buyer
    {
      
      buyer_data <- select(bid_data_rename   ,
                           ID_TENDER         ,
                           ID_BUYER_RUT      ,
                           !!offer_list      ,
                           !!tender_list     ,
                           !!part_list       ,
                           !!lot_list)  %>%
        # removing duplicates
        distinct(STR_BUYER_UNIT, .keep_all = TRUE) %>%
        relocate(STR_BUYER_UNIT,ID_BUYER_UNIT ) %>%
        arrange(STR_BUYER_UNIT)
    
      
      # Checking size 
      print(object.size(buyer_data), units = "Mb")
      
      # Tender
      write_rds(buyer_data,paste0(dropbox_dir,"2 - data_construct/1-data_temp/buyer-",DT_TENDER_YEAR, DT_TENDER_MONTH_str,".rds"))
    }
    
    # 5: Participant
    {
      
      seller_data <- select(bid_data_rename   ,
                            ID_TENDER         ,
                            ID_BUYER_RUT      ,
                            ID_RUT_PARTICIPANT,
                            !!offer_list      ,
                            !!tender_list     ,
                            !!buyer_list       ,
                            !!lot_list) %>%
        # removing duplicates
        distinct(ID_RUT_PARTICIPANT, .keep_all = TRUE) %>%
        relocate(ID_RUT_PARTICIPANT,STR_PARTICIPANT_NAME) %>%
        arrange(ID_RUT_PARTICIPANT)

      
      # Checking file size
      print(object.size(seller_data), units = "Mb")
      
      write_rds(seller_data,paste0(dropbox_dir,"2 - data_construct/1-data_temp/seller-",DT_TENDER_YEAR,DT_TENDER_MONTH_str,".rds"))
    
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
        semi_join(lot_data, by = c("ID_TENDER")) %>%
        count()
      
      # Anti-joing
      offer_data %>%  
        anti_join(lot_data, by = c("ID_TENDER")) %>%
        count()
      
      if (offer_data %>%  
          anti_join(lot_data, by = c("ID_TENDER")) %>%
          count() != 0){
        
        stop(paste0("There is an issue with offer vs item for ", DT_TENDER_MONTH_str, "/",DT_TENDER_YEAR ))
        
      }
    }
    
    # 2: Offer vs tender_data
    { 
      # Counting
      offer_data[,.N]
      
      # Matches
      offer_data %>%  
        semi_join(tender_data, by = c("ID_TENDER")) %>%
        count()
      
      # Anti-joing
      offer_data %>%  
        anti_join(tender_data, by = c("ID_TENDER")) %>%
        count()
      
      if (offer_data %>%  
          anti_join(tender_data, by = c("ID_TENDER")) %>%
          count() != 0){
        
        stop(paste0("There is an issue with offer vs tender for ", DT_TENDER_MONTH_str, "/",DT_TENDER_YEAR ))
        
      }
      
    }
    
    # 3: Offer vs buyer
    { 
      # Counting
      offer_data[,.N]
      
      # Matches
      offer_data %>%  
        semi_join(buyer_data, by = c("STR_BUYER_UNIT")) %>%
        count()
      
      # Anti-joing
      offer_data %>%  
        anti_join(buyer_data, by = c("STR_BUYER_UNIT")) %>%
        count()
      
      if (offer_data %>%  
          anti_join(buyer_data, by = c("STR_BUYER_UNIT")) %>%
          count() != 0){
        
        stop(paste0("There is an issue with offer vs buyer for ", DT_TENDER_MONTH_str, "/",DT_TENDER_YEAR ))
        
      }
      
    }
    
    # 4: Offer vs participant
    { 
      # Counting
      offer_data[,.N]
      
      # Matches
      offer_data %>%  
        semi_join(seller_data, by = c("ID_RUT_PARTICIPANT")) %>%
        count()
      
      # Anti-joing
      offer_data %>%  
        anti_join(seller_data, by = c("ID_RUT_PARTICIPANT")) %>%
        count()
      
      if (offer_data %>%  
          anti_join(seller_data, by = c("ID_RUT_PARTICIPANT")) %>%
          count() != 0){
        
        stop(paste0("There is an issue with offer vs participant for ", DT_TENDER_MONTH_str, "/",DT_TENDER_YEAR ))
        
      }
    }
  }
}
