# Made by Leandro Veloso
# main: Appending data and create architecture

# 1: Appending offer by DT_TENDER_YEAR ----
{
  # Checking pattern
  {
    # Defying pattern
    DT_TENDER_YEAR =2013
    patter_order_file <-  paste0("offer-",DT_TENDER_YEAR) %R% or(DGT,DGT %R% DGT) %R% ".rds" 
    
    # testing pattern
    str_view(c("offer-201301.rds","offer-20198.rds","otherfile.rds"), pattern=patter_order_file)
  }
  
  # list of files
  file_list<-list(dir(paste0(dropbox_dir,"2 - data_construct/1-data_temp")))[[1]]
  
  # DT_TENDER_YEAR seq
  DT_TENDER_YEAR_seq<-unique(year(sequence_dates))
  for (DT_TENDER_YEAR in DT_TENDER_YEAR_seq) {
    print(paste("appending order",DT_TENDER_YEAR))
    
    # starting with an empty list
    panel_list<- list()
    
    # Reading each file by DT_TENDER_YEAR
    index<-0
    for (file in file_list) {
      # defying pattern
      patter_order_file <-  paste0("offer-",DT_TENDER_YEAR) %R% or(DGT,DGT %R% DGT) %R% ".rds" 
      
      # Running if it is an specific DT_TENDER_YEAR
      if (str_detect(file,pattern =patter_order_file )) {
        print(paste(">>",file))
        
        index <- index+1
        panel_list[[paste0("f-",index)]] <- read_rds(paste0(dropbox_dir,"2 - data_construct/1-data_temp/",file))
      }
    }
    
    # Appending files
    data_appended<-rbindlist(panel_list, fill = TRUE)    %>%
      as.data.table( )       %>% 
      relocate(DT_TENDER_YEAR,DT_TENDER_MONTH)    
    
    # Checking by DT_TENDER_YEAR DT_TENDER_MONTH
    print(data_appended[,.N,by=c("DT_TENDER_YEAR","DT_TENDER_MONTH")])
    
    # Saving in rds
    write_rds(data_appended,file.path(dropbox_dir,"2 - data_construct/2-data_compiled/",
                                      paste0("offer-",DT_TENDER_YEAR,".rds")))
    
    # Removing file to save ram
    rm(panel_list)
    rm(data_appended)
  }
}

# 2: Appending lot by DT_TENDER_YEAR ----
{
  # Checking pattern
  {
    # Defying pattern
    DT_TENDER_YEAR =2013
    patter_order_file <-  paste0("lot-",DT_TENDER_YEAR) %R% or(DGT,DGT %R% DGT) %R% ".rds" 
    
    # testing pattern
    str_view(c("lot-201301.rds","lot-20198.rds","otherfile.rds"), pattern=patter_order_file)
  }
  
  # list of files
  file_list<-list(dir(paste0(dropbox_dir,"2 - data_construct/1-data_temp")))[[1]]
  
  # DT_TENDER_YEAR seq
  DT_TENDER_YEAR_seq<-unique(year(sequence_dates))
  for (DT_TENDER_YEAR in DT_TENDER_YEAR_seq) {
    print(paste("appending order",DT_TENDER_YEAR))
    
    # starting with an empty list
    panel_list<- list()
    
    # Reading each file by DT_TENDER_YEAR
    index<-0
    for (file in file_list) {
      # defying pattern
      patter_order_file <-  paste0("lot-",DT_TENDER_YEAR) %R% or(DGT,DGT %R% DGT) %R% ".rds" 
      
      # Running if it is an specific DT_TENDER_YEAR
      if (str_detect(file,pattern =patter_order_file )) {
        print(paste(">>",file))
        
        index <- index+1
        panel_list[[paste0("f-",index)]] <- read_rds(paste0(dropbox_dir,"2 - data_construct/1-data_temp/",file))
      }
    }
    
    # Appending files
    data_appended<-rbindlist(panel_list, fill = TRUE)    %>%
      as.data.table( )       %>% 
      relocate(DT_TENDER_YEAR,DT_TENDER_MONTH)    
    
    # Checking by DT_TENDER_YEAR DT_TENDER_MONTH
    print(data_appended[,.N,by=c("DT_TENDER_YEAR","DT_TENDER_MONTH")])
    
    # Saving in rds
    write_rds(data_appended,file.path(dropbox_dir,"2 - data_construct/2-data_compiled/",
                                      paste0("lot-",DT_TENDER_YEAR,".rds")))
    
    # Removing file to save ram
    rm(panel_list)
    rm(data_appended)
  }
}

# 3: Appending tender by DT_TENDER_YEAR ----
{
  # Checking pattern
  {
    # Defying pattern
    DT_TENDER_YEAR =2013
    patter_order_file <-  paste0("tender-",DT_TENDER_YEAR) %R% or(DGT,DGT %R% DGT) %R% ".rds" 
    
    # testing pattern
    str_view(c("tender-201301.rds","tender-20198.rds","otherfile.rds"), pattern=patter_order_file)
  }
  
  # list of files
  file_list<-list(dir(paste0(dropbox_dir,"2 - data_construct/1-data_temp")))[[1]]
  
  # DT_TENDER_YEAR seq
  DT_TENDER_YEAR_seq<-unique(year(sequence_dates))
  for (DT_TENDER_YEAR in DT_TENDER_YEAR_seq) {
    print(paste("appending order",DT_TENDER_YEAR))
    
    # starting with an empty list
    panel_list<- list()
    
    # Reading each file by DT_TENDER_YEAR
    index<-0
    for (file in file_list) {
      # defying pattern
      patter_order_file <-  paste0("tender-",DT_TENDER_YEAR) %R% or(DGT,DGT %R% DGT) %R% ".rds" 
      
      # Running if it is an specific DT_TENDER_YEAR
      if (str_detect(file,pattern =patter_order_file )) {
        print(paste(">>",file))
        
        index <- index+1
        panel_list[[paste0("f-",index)]] <- read_rds(paste0(dropbox_dir,"2 - data_construct/1-data_temp/",file))
      }
    }
    
    # Appending files
    data_appended<-rbindlist(panel_list, fill = TRUE)    %>%
      as.data.table( )       %>% 
      relocate(DT_TENDER_YEAR,DT_TENDER_MONTH)    
    
    # Checking by DT_TENDER_YEAR DT_TENDER_MONTH
    print(data_appended[,.N,by=c("DT_TENDER_YEAR","DT_TENDER_MONTH")])
    
    # Saving in rds
    write_rds(data_appended,file.path(dropbox_dir,"2 - data_construct/2-data_compiled/",
                                      paste0("tender-",DT_TENDER_YEAR,".rds")))
    
    # Removing file to save ram
    rm(panel_list)
    rm(data_appended)
  }
}

# 4: Buyer ----
{
  # Reading each file by DT_TENDER_YEAR
  index<-0
  panel_list<-list()
  for (k in seq_along(sequence_dates)) { 
    # Getting DT_TENDER_YEAR DT_TENDER_MONTH
    DT_TENDER_YEAR  <- year(sequence_dates[k])
    DT_TENDER_MONTH <- month(sequence_dates[k])  
    
    # Filling left zero
    DT_TENDER_MONTH_str<- str_pad(DT_TENDER_MONTH, 2, pad = "0")
    
    # Checking
    file<-paste0("buyer-",DT_TENDER_YEAR,DT_TENDER_MONTH_str,".rds")
    print(paste(">>",file))
    
    panel_list[[paste0("f-",k)]] <- read_rds(paste0(dropbox_dir,"2 - data_construct/1-data_temp/",file)) %>%
      mutate(DT_TENDER_YEAR_DT_TENDER_MONTH_aux = dmy(paste0("01",DT_TENDER_MONTH_str,DT_TENDER_YEAR)))
  }
  
  # Appending files
  data_appended<-rbindlist(panel_list, fill = TRUE)    %>%
    as.data.table( )      
  
  # Checking by DT_TENDER_YEAR DT_TENDER_MONTH
  print(data_appended[,.N,by=c("DT_TENDER_YEAR_DT_TENDER_MONTH_aux")])
  
  # Removing duplicates. Keep most recent
  data_appended <- data_appended %>%
    arrange(desc(DT_TENDER_YEAR_DT_TENDER_MONTH_aux),STR_BUYER_UNIT) %>%
    distinct(STR_BUYER_UNIT, .keep_all = TRUE) %>% 
    select(-DT_TENDER_YEAR_DT_TENDER_MONTH_aux)
  
  # checking
  glimpse(data_appended)
  
  # Saving in rds
  write_rds(data_appended,file.path(dropbox_dir,"2 - data_construct/2-data_compiled/",
                                    paste0("buyer.rds")))
  
  # Removing file to save ram
  rm(panel_list)
  rm(data_appended)
}

# 5: Appending participant ----
{
  # Reading each file by DT_TENDER_YEAR
  index<-0
  panel_list<-list()
  for (k in seq_along(sequence_dates)) { 
    # Getting DT_TENDER_YEAR DT_TENDER_MONTH
    DT_TENDER_YEAR  <- year(sequence_dates[k])
    DT_TENDER_MONTH <- month(sequence_dates[k])  
    
    # Filling left zero
    DT_TENDER_MONTH_str<- str_pad(DT_TENDER_MONTH, 2, pad = "0")
    
    # Checking
    file<-paste0("seller-",DT_TENDER_YEAR,DT_TENDER_MONTH_str,".rds")
    print(paste(">>",file))
    
    panel_list[[paste0("f-",k)]] <- read_rds(paste0(dropbox_dir,"2 - data_construct/1-data_temp/",file)) %>%
      mutate(DT_TENDER_YEAR_DT_TENDER_MONTH_aux = dmy(paste0("01",DT_TENDER_MONTH_str,DT_TENDER_YEAR)))
  }
  
  # Appending files
  data_appended<-rbindlist(panel_list, fill = TRUE)    %>%
    as.data.table( )      
  
  # Checking by DT_TENDER_YEAR DT_TENDER_MONTH
  print(data_appended[,.N,by=c("DT_TENDER_YEAR_DT_TENDER_MONTH_aux")])
  
  # Removing duplicates. Keep most recent
  data_appended <- data_appended %>%
    arrange(desc(DT_TENDER_YEAR_DT_TENDER_MONTH_aux),ID_RUT_PARTICIPANT) %>%
    distinct(ID_RUT_PARTICIPANT, .keep_all = TRUE) %>% 
    select(-DT_TENDER_YEAR_DT_TENDER_MONTH_aux)
  
  # checking
  glimpse(data_appended)
  
  # Saving in rds
  write_rds(data_appended,file.path(dropbox_dir,"2 - data_construct/2-data_compiled/",
                                    paste0("participant.rds")))
  
  # Removing file to save ram
  rm(panel_list)
  rm(data_appended)
}

# 6: architecture  data ----
{
  # 1: Creating structing function
  arq_function <- function(data) {
    
    # Creating data to keep the order variable
    data_output <- tibble(
      names = colnames(data)
    )
    
    # Getting stat
    aux_struct <-skim(data)   %>%  
      mutate(N_obs = round(n_missing/(1- complete_rate))) %>% 
      mutate(N_obs =max(N_obs, na.rm=TRUE))   %>%
      relocate(skim_type, skim_variable, N_obs)
    
    # Joing with rename data
    aux_struct<- aux_struct %>%
      left_join(rename_variables, by=c("skim_variable"="New_names") ) %>%
      relocate( skim_variable,Label ,Original_names ,skim_type  ) %>%
      select(-Level)  
    
    # Joing with data_output to keep the order variable
    data_output <-data_output %>%
      left_join(aux_struct, by=c("names"="skim_variable"))
    
    return(data_output)
  }
  
  # Load the list of original names and R names
  rename_variables <- 
    read_csv(file.path(github_dir,"auxilary_files",
                       "01-tender_name_label.csv")) %>% 
    filter(!is.na(New_names))
  
  # Offer
  offer_data <- read_rds(paste0(dropbox_dir,"2 - data_construct/2-data_compiled/offer-",DT_TENDER_YEAR_seq[length(DT_TENDER_YEAR_seq)],".rds"))
  arq_offer  <- arq_function(offer_data) 
  
  # Lot
  lot_data <- read_rds(paste0(dropbox_dir,"2 - data_construct/2-data_compiled/lot-",DT_TENDER_YEAR_seq[length(DT_TENDER_YEAR_seq)],".rds"))
  arq_lot  <- arq_function(lot_data) 
  
  # Tender
  tender_data <- read_rds(paste0(dropbox_dir,"2 - data_construct/2-data_compiled/tender-",DT_TENDER_YEAR_seq[length(DT_TENDER_YEAR_seq)],".rds"))
  arq_tender  <- arq_function(tender_data)
  
  # Buyer
  buyer_data <- read_rds(paste0(dropbox_dir,"2 - data_construct/2-data_compiled/buyer.rds"))
  arq_buyer  <-arq_function(buyer_data)
  
  # Participant
  seller_data <- read_rds(paste0(dropbox_dir,"2 - data_construct/2-data_compiled/participant.rds"))
  arq_seller  <-arq_function(seller_data)
  
  # notes
  notes <- tibble(
    notes = c("oc id structure = XXXX-XXX-CCXX",
              "RUT - taxation id: XX.XXX.XXX-D D= verification digit",
              "For each data we have an index id and also a identification number",
              "If we have some mistake in the identification number, such as RUT, it cames with two codes")
  )
  
  # Export to excel
  write_xlsx(list("1-Offer"       = arq_offer,
                  "2-lot"         = arq_lot,
                  "3-tender"      = arq_tender,
                  "4-buyer"       = arq_buyer,
                  "5-participant" = arq_seller,
                  "6-notes"       = notes),
             path = paste0(dropbox_dir,"2 - data_construct/4-data_tables/", 
                              "4-arquiteture.xlsx")) 
}
