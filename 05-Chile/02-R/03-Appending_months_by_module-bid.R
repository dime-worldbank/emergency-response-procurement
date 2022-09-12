# Made by Leandro Veloso
# main: Appending data and create architecture

# 1: Appending offer by year ----
{
  # Checking pattern
  {
    # Defying pattern
    year =2013
    patter_order_file <-  paste0("offer-",year) %R% or(DGT,DGT %R% DGT) %R% ".rds" 
    
    # testing pattern
    str_view(c("offer-201301.rds","offer-20198.rds","otherfile.rds"), pattern=patter_order_file)
  }
  
  # list of files
  file_list<-list(dir(paste0(dropbox_dir,"2 - data_construct/1-data_temp")))[[1]]
  
  # year seq
  year_seq<-unique(year(sequence_dates))
  for (year in year_seq) {
    print(paste("appending order",year))
    
    # starting with an empty list
    panel_list<- list()
    
    # Reading each file by year
    index<-0
    for (file in file_list) {
      # defying pattern
      patter_order_file <-  paste0("offer-",year) %R% or(DGT,DGT %R% DGT) %R% ".rds" 
      
      # Running if it is an specific year
      if (str_detect(file,pattern =patter_order_file )) {
        print(paste(">>",file))
        
        index <- index+1
        panel_list[[paste0("f-",index)]] <- read_rds(paste0(dropbox_dir,"2 - data_construct/1-data_temp/",file))
      }
    }
    
    # Appending files
    data_appended<-rbindlist(panel_list, fill = TRUE)    %>%
      as.data.table( )       %>% 
      relocate(year,month)    
    
    # Checking by year month
    print(data_appended[,.N,by=c("year","month")])
    
    # Saving in rds
    write_rds(data_appended,file.path(dropbox_dir,"2 - data_construct/2-data_compiled/",
                                      paste0("offer-",year,".rds")))
    
    # Removing file to save ram
    rm(panel_list)
    rm(data_appended)
  }
}

# 2: Appending lot by year ----
{
  # Checking pattern
  {
    # Defying pattern
    year =2013
    patter_order_file <-  paste0("lot-",year) %R% or(DGT,DGT %R% DGT) %R% ".rds" 
    
    # testing pattern
    str_view(c("lot-201301.rds","lot-20198.rds","otherfile.rds"), pattern=patter_order_file)
  }
  
  # list of files
  file_list<-list(dir(paste0(dropbox_dir,"2 - data_construct/1-data_temp")))[[1]]
  
  # year seq
  year_seq<-unique(year(sequence_dates))
  for (year in year_seq) {
    print(paste("appending order",year))
    
    # starting with an empty list
    panel_list<- list()
    
    # Reading each file by year
    index<-0
    for (file in file_list) {
      # defying pattern
      patter_order_file <-  paste0("lot-",year) %R% or(DGT,DGT %R% DGT) %R% ".rds" 
      
      # Running if it is an specific year
      if (str_detect(file,pattern =patter_order_file )) {
        print(paste(">>",file))
        
        index <- index+1
        panel_list[[paste0("f-",index)]] <- read_rds(paste0(dropbox_dir,"2 - data_construct/1-data_temp/",file))
      }
    }
    
    # Appending files
    data_appended<-rbindlist(panel_list, fill = TRUE)    %>%
      as.data.table( )       %>% 
      relocate(year,month)    
    
    # Checking by year month
    print(data_appended[,.N,by=c("year","month")])
    
    # Saving in rds
    write_rds(data_appended,file.path(dropbox_dir,"2 - data_construct/2-data_compiled/",
                                      paste0("lot-",year,".rds")))
    
    # Removing file to save ram
    rm(panel_list)
    rm(data_appended)
  }
}

# 3: Appending tender by year ----
{
  # Checking pattern
  {
    # Defying pattern
    year =2013
    patter_order_file <-  paste0("tender-",year) %R% or(DGT,DGT %R% DGT) %R% ".rds" 
    
    # testing pattern
    str_view(c("tender-201301.rds","tender-20198.rds","otherfile.rds"), pattern=patter_order_file)
  }
  
  # list of files
  file_list<-list(dir(paste0(dropbox_dir,"2 - data_construct/1-data_temp")))[[1]]
  
  # year seq
  year_seq<-unique(year(sequence_dates))
  for (year in year_seq) {
    print(paste("appending order",year))
    
    # starting with an empty list
    panel_list<- list()
    
    # Reading each file by year
    index<-0
    for (file in file_list) {
      # defying pattern
      patter_order_file <-  paste0("tender-",year) %R% or(DGT,DGT %R% DGT) %R% ".rds" 
      
      # Running if it is an specific year
      if (str_detect(file,pattern =patter_order_file )) {
        print(paste(">>",file))
        
        index <- index+1
        panel_list[[paste0("f-",index)]] <- read_rds(paste0(dropbox_dir,"2 - data_construct/1-data_temp/",file))
      }
    }
    
    # Appending files
    data_appended<-rbindlist(panel_list, fill = TRUE)    %>%
      as.data.table( )       %>% 
      relocate(year,month)    
    
    # Checking by year month
    print(data_appended[,.N,by=c("year","month")])
    
    # Saving in rds
    write_rds(data_appended,file.path(dropbox_dir,"2 - data_construct/2-data_compiled/",
                                      paste0("tender-",year,".rds")))
    
    # Removing file to save ram
    rm(panel_list)
    rm(data_appended)
  }
}

# 4: Buyer ----
{
  # Reading each file by year
  index<-0
  panel_list<-list()
  for (k in seq_along(sequence_dates)) { 
    # Getting year month
    year  <- year(sequence_dates[k])
    month <- month(sequence_dates[k])  
    
    # Filling left zero
    month_str<- str_pad(month, 2, pad = "0")
    
    # Checking
    file<-paste0("buyer-",year,month_str,".rds")
    print(paste(">>",file))
    
    panel_list[[paste0("f-",k)]] <- read_rds(paste0(dropbox_dir,"2 - data_construct/1-data_temp/",file)) %>%
      mutate(year_month_aux = dmy(paste0("01",month_str,year)))
  }
  
  # Appending files
  data_appended<-rbindlist(panel_list, fill = TRUE)    %>%
    as.data.table( )      
  
  # Checking by year month
  print(data_appended[,.N,by=c("year_month_aux")])
  
  # Removing duplicates. Keep most recent
  data_appended <- data_appended %>%
    arrange(desc(year_month_aux),buyer_id) %>%
    distinct(buyer_id, .keep_all = TRUE) %>% 
    select(-year_month_aux)
  
  # checking
  glimpse(data_appended)
  
  # Checking rut correct
  data_appended[,.N, by=c("D_rut_buyer_ok")]
  
  # Saving in rds
  write_rds(data_appended,file.path(dropbox_dir,"2 - data_construct/2-data_compiled/",
                                    paste0("buyer.rds")))
  
  # Removing file to save ram
  rm(panel_list)
  rm(data_appended)
}

# 5: Appending participant ----
{
  # Reading each file by year
  index<-0
  panel_list<-list()
  for (k in seq_along(sequence_dates)) { 
    # Getting year month
    year  <- year(sequence_dates[k])
    month <- month(sequence_dates[k])  
    
    # Filling left zero
    month_str<- str_pad(month, 2, pad = "0")
    
    # Checking
    file<-paste0("seller-",year,month_str,".rds")
    print(paste(">>",file))
    
    panel_list[[paste0("f-",k)]] <- read_rds(paste0(dropbox_dir,"2 - data_construct/1-data_temp/",file)) %>%
      mutate(year_month_aux = dmy(paste0("01",month_str,year)))
  }
  
  # Appending files
  data_appended<-rbindlist(panel_list, fill = TRUE)    %>%
    as.data.table( )      
  
  # Checking by year month
  print(data_appended[,.N,by=c("year_month_aux")])
  
  # Removing duplicates. Keep most recent
  data_appended <- data_appended %>%
    arrange(desc(year_month_aux),participant_estab_id) %>%
    distinct(participant_estab_id, .keep_all = TRUE) %>% 
    select(-year_month_aux)
  
  # checking
  glimpse(data_appended)
  
  # Checking rut correct
  data_appended[,.N, by=c("D_rut_participant_ok")]
  
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
      relocate( skim_variable,Label ,Original_names, label_pdf ,skim_type  ) %>%
      select(-Level)  
    
    # Joing with data_output to keep the order variable
    data_output <-data_output %>%
      left_join(aux_struct, by=c("names"="skim_variable"))
    
    return(data_output)
  }
  
  # Load the list of original names and R names
  rename_variables <- 
    read_csv(file.path(github_dir,"Auxilary_files",
                       "01-tender_name_label.csv")) %>% 
    filter(!is.na(New_names))
  
  # Offer
  offer_data <- read_rds(paste0(dropbox_dir,"2 - data_construct/2-data_compiled/offer-",year_seq[length(year_seq)],".rds"))
  arq_offer  <- arq_function(offer_data) 
  
  # Lot
  lot_data <- read_rds(paste0(dropbox_dir,"2 - data_construct/2-data_compiled/lot-",year_seq[length(year_seq)],".rds"))
  arq_lot  <- arq_function(lot_data) 
  
  # Tender
  tender_data <- read_rds(paste0(dropbox_dir,"2 - data_construct/2-data_compiled/tender-",year_seq[length(year_seq)],".rds"))
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
             path = paste0(dropbox_dir,"2 - data_construct/3-data_tables/", 
                              "4-arquiteture.xlsx")) 
}
