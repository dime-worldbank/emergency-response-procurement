# ---------------------------------------------------------------------------- #
#                                                                              #
#               FY23 MDTF - Emergency Response Procurement - Honduras          #
#                                                                              # 
#                             Construct Variables                              #
#                                                                              #
#        Author: Hao Lyu (RA - DIME3)            Last Update:  Oct 31 2022     #
#                                                                              #
# ---------------------------------------------------------------------------- #

# **************************************************************************** #
#       This script aims to clean Honduras data downloaded from the standard
#       portal         
#                                                                              ##                                                                              #
# **************************************************************************** #

# Procurement Data Structure: 
# tender - buyer - contract 
# tender - buyer - suppliers 

# LOAD DATA -------------------------------------------------------------------

    # aggregated data from 2018 to 2021
      data_participants_final   <- readRDS(file.path(raw_oncae, "DATA_PARTICIPANTS.RDS"))
      data_documents_final      <- readRDS(file.path(raw_oncae, "DATA_DOCUMENTS.RDS"   ))
      data_items_final          <- readRDS(file.path(raw_oncae, "DATA_ITEMS.RDS"       ))
      data_contracts_final      <- readRDS(file.path(raw_oncae, "DATA_CONTRACTS.RDS"   ))
      data_tenders_final        <- readRDS(file.path(raw_oncae, "DATA_TENDERS.RDS"     ))

    # intermediate datasets from cleaning file 
      contract_participants <- as.data.frame(fread(file.path(intermediate,"Contract_Participants.csv"))) 
      
      contract_tender       <- as.data.frame(fread(file.path(intermediate,"Contract_Tender.csv"))) 
      
      data_parties_merged   <- as.data.frame(fread(file.path(intermediate,"Data_Parties_Merged.csv"))) 

      tender_item           <- as.data.frame(fread(file.path(intermediate,"Tender_Item.csv"))) 
      
      supplier_item         <- as.data.frame(fread(file.path(intermediate,"Supplier_Item.csv"))) 
      
      
# construct Variables ---------------------------------------------------------

    # identify covid dummy 
      covid <- data_items_final%>%
        mutate(covid = ifelse(str_detect(STR_ITEM_DESCRIPTION, "covid")|
                                str_detect(STR_ITEM_DESCRIPTION, "COVID")|
                                str_detect(STR_ITEM_DESCRIPTION, "Covid")|
                                str_detect(STR_ITEM_DESCRIPTION, "coronavirus")|
                                str_detect(STR_ITEM_DESCRIPTION, "coronavirus")|
                                str_detect(STR_ITEM_DESCRIPTION, "sars-cov-2"),1,0))
      
      covid2 <- data_contracts_final%>%
        mutate(covid = ifelse(str_detect(STR_CONTRACT_DESCRIPTION, "covid")|
                                str_detect(STR_CONTRACT_DESCRIPTION, "COVID")|
                                str_detect(STR_CONTRACT_DESCRIPTION, "Covid")|
                                str_detect(STR_CONTRACT_DESCRIPTION, "coronavirus")|
                                str_detect(STR_CONTRACT_DESCRIPTION, "coronavirus")|
                                str_detect(STR_CONTRACT_DESCRIPTION, "sars-cov-2"),1,0))
      
      covid3 <- data_tenders_final%>%
        mutate(covid = ifelse(str_detect(STR_TENDER_DESCRIPTION, "covid")|
                                str_detect(STR_TENDER_DESCRIPTION, "COVID")|
                                str_detect(STR_TENDER_DESCRIPTION, "Covid")|
                                str_detect(STR_TENDER_DESCRIPTION, "coronavirus")|
                                str_detect(STR_TENDER_DESCRIPTION, "coronavirus")|
                                str_detect(STR_TENDER_DESCRIPTION, "sars-cov-2"),1,0))
      
      # table(d["covid"])
      
      #     0     1 
      #   68429   540 
      
      # do tables by frequency 
      # check by year - 
      # by sector -  
      # by entity - buyers - by health entities or entire 
      
      tender_item <- tender_item%>%
        mutate(covid_item = ifelse(str_detect(STR_ITEM_DESCRIPTION, "covid")|
                                str_detect(STR_ITEM_DESCRIPTION, "COVID")|
                                str_detect(STR_ITEM_DESCRIPTION, "Covid")|
                                str_detect(STR_ITEM_DESCRIPTION, "coronavirus")|
                                str_detect(STR_ITEM_DESCRIPTION, "coronavirus")|
                                str_detect(STR_ITEM_DESCRIPTION, "sars-cov-2"),1,0),
               covid_contract = ifelse(str_detect(STR_TENDER_DESCRIPTION, "covid")|
                                str_detect(STR_TENDER_DESCRIPTION, "COVID")|
                                str_detect(STR_TENDER_DESCRIPTION, "Covid")|
                                str_detect(STR_TENDER_DESCRIPTION, "coronavirus")|
                                str_detect(STR_TENDER_DESCRIPTION, "coronavirus")|
                                str_detect(STR_TENDER_DESCRIPTION, "sars-cov-2"),1,0),
               covid = case_when(covid_item == 1 ~ 1,
                                 covid_contract == 1 ~ 1))

      
    ## new winners vs old winners - construct with contract signature ---------
      
      # single out suppliers between 2018 and 2022   
      contract_supplier <- contract_participants%>%
        filter(cat_party_role == "supplier"|
                 cat_party_role == "supplier;tenderer"&
                 year <= 2022)%>%
        arrange(id_party, dt_contract_signed)
      
      # calculate time lag 
      contract_supplier <- as.data.table(contract_supplier)
      
      contract_supplier = contract_supplier[, lag_date:= shift(dt_contract_signed, 1, type="lag"), by="id_party"]
      
      # calculate how many days between the 2 contracts a firm has won 
      contract_supplier$lag_date <- as_datetime(contract_supplier$lag_date, tz = lubridate::tz(contract_supplier$lag_date))
      
      contract_supplier$diff_days_contract <- interval(contract_supplier$lag_date, contract_supplier$dt_contract_signed) %/% days(1)
      
      # calculate the number of months from the previous contract by the same firm 
      contract_supplier$diff_months_contract <- interval(contract_supplier$lag_date, contract_supplier$dt_contract_signed) %/% months(1)
      
      # identity new winners by days 
      contract_supplier <- as.data.frame(contract_supplier)
      
      contract_supplier <- contract_supplier%>%
        mutate(new_winner = case_when(is.na(diff_days_contract) ~ 1 ,
                                      diff_days_contract > 365 ~ 1 ,
                                      TRUE ~ 0 ))
      # summary statistics by year 
      new_winner_year <- contract_supplier%>%
        group_by(year)%>%
        dplyr::summarise(num_new_winner = sum(new_winner))%>%
        ungroup()
      
      # summary statistics by month 
      contract_supplier$month <- strftime(contract_supplier$dt_contract_signed, "%m")
      
      contract_supplier$year_month <- paste0(contract_supplier$year, contract_supplier$month)
      
      new_winner_month <- contract_supplier%>%
        filter(year_month >= 201901)%>%
        group_by(year_month)%>%
        dplyr::summarise(num_new_winner = sum(new_winner))%>%
        ungroup()
      
      # Visualization for new winners 
      ggplot(new_winner_month, aes(x = year_month, y = num_new_winner, group = 1))+
        geom_line()+
        theme_classic()+
        theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))
      
      
      

    ## time variables --------------------------------------------------------- 
      
      # Total processing time: contract signature - tender initiation
      # Submission time: submission deadline - tender initiation
      # Decision time: contract signature - submission deadline
      contract_tender <- contract_tender%>%
        select(ID, 
               ID_CONTRACT, 
               DT_TENDER_PUB, 
               DT_TENDER_START, 
               DT_TENDER_END,
               DT_CONTRACT_SIGNED, 
               everything())%>%
        mutate(publication_start = DT_TENDER_PUB - DT_TENDER_START,
               submission_time = DT_TENDER_END - DT_TENDER_START,
               processing_time = DT_CONTRACT_SIGNED - DT_TENDER_START,
               decision_time   = DT_CONTRACT_SIGNED - DT_TENDER_END)
      
      contract_tender <- as.data.table(contract_tender)
      
      # check the overlap between contract signature, contract start and end date 
      check <- contract_tender[,.N, by = "publication_start"] # not consistent 
      
      check <- contract_tender[,.N, by = "submission_time"] # consistent: end > start 
      
      check <- contract_tender[,.N, by = "processing_time"] # consistent: signature > start 
      
      check <- contract_tender[,.N, by = "decision_time"] # consistent: signature > end 
      
      
# Market concentration: number of winners per sector (sector = covid/non-covid) -----
      
      supplier_item <- supplier_item%>%
        mutate(covid_item = ifelse(str_detect(STR_ITEM_DESCRIPTION, "covid")|
                                     str_detect(STR_ITEM_DESCRIPTION, "COVID")|
                                     str_detect(STR_ITEM_DESCRIPTION, "Covid")|
                                     str_detect(STR_ITEM_DESCRIPTION, "coronavirus")|
                                     str_detect(STR_ITEM_DESCRIPTION, "coronavirus")|
                                     str_detect(STR_ITEM_DESCRIPTION, "sars-cov-2"),1,0))
      
      supplier_item <- as.data.table(supplier_item)
      
      market_concentration <- supplier_item[,.N,by = "covid_item"]
      
    # Number of different products (UNSPC codes) supplied by the same firm over 1 year (or 6 months). 
    # [Do firms during covid supply a broader range of different products?]
    # Besides the shares, explore the number of products sold by the firm before, during and after COVID
    # Number of different product items (and sectors) sold in one year by the firm
      
      firm_item <- supplier_item%>%
        group_by(ID_PARTY, YEAR)%>%
        dplyr::summarise(num_unspsc = n_distinct(ID_ITEM_UNSPSC))%>%
        ungroup()
      
      # firms that have increased the product code during COVID
      firm_uspsc_panel <- firm_item%>%
        spread(YEAR, num_unspsc)%>%
        clean_names()%>%
        select(-x2025, -na, -x2018)%>%
        replace(is.na(.), 0)%>%
        mutate(product_increase = case_when(x2020 > x2019 | x2021 > x2019 ~ 1,
                                            TRUE ~ 0))
      
    # Construct and index to classify contracts to define comparison group. To define COVID products: use the TED classification on COVID products
      covid_item_unspsc <- supplier_item%>%
        filter(covid_item == 1)%>%
        select(ID, ID_PARTY, NAME_PARTY, ID_ITEM, ID_ITEM_UNSPSC, STR_ITEM_UNSPSC, STR_ITEM_DESCRIPTION, covid_item)
      
      

