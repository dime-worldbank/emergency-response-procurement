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
#       tender - buyer - contract 
#       tender - buyer - suppliers 


# LOAD DATA -------------------------------------------------------------------

    # aggregated data from 2018 to 2021
      data_participants_final   <- readRDS(file.path(raw_oncae, "DATA_PARTICIPANTS.RDS"))
      data_documents_final      <- readRDS(file.path(raw_oncae, "DATA_DOCUMENTS.RDS"   ))
      data_items_final          <- readRDS(file.path(raw_oncae, "DATA_ITEMS.RDS"       )) # 136882 unique tenders that have items 
      data_contracts_final      <- readRDS(file.path(raw_oncae, "DATA_CONTRACTS.RDS"   )) # 35930 unique tenders that have contracts 
      data_tenders_final        <- readRDS(file.path(raw_oncae, "DATA_TENDERS.RDS"     )) # 138873 unique tenders

    # intermediate datasets from cleaning file 
      tender_contract       <- as.data.frame(fread(file.path(intermediate,"Contract_Tender.csv"))) 
      
      tender_item           <- as.data.frame(fread(file.path(intermediate,"Tender_Item.csv"))) # add contract signature date 
      
      supplier_item         <- as.data.frame(fread(file.path(intermediate,"Supplier_Item.csv"))) # add contract signature date 
      
      contract_participants <- as.data.frame(fread(file.path(intermediate,"Contract_Participants.csv"))) 
      
      data_parties_merged   <- as.data.frame(fread(file.path(intermediate,"Data_Parties_Merged.csv"))) 
      
      
# COVID DUMMY ---------------------------------------------------------
      
      # Count COVID related item, contracts, and tenders  
      covid_item <- data_items_final%>%
        mutate(covid = ifelse(str_detect(STR_ITEM_DESCRIPTION, "covid")|
                                     str_detect(STR_ITEM_DESCRIPTION, "COVID")|
                                     str_detect(STR_ITEM_DESCRIPTION, "Covid")|
                                     str_detect(STR_ITEM_DESCRIPTION, "coronavirus")|
                                     str_detect(STR_ITEM_DESCRIPTION, "coronavirus")|
                                     str_detect(STR_ITEM_DESCRIPTION, "sars-cov-2"),1,0))%>%
        mutate_at(c("covid"), ~replace_na(., 0))%>%
        group_by(covid)%>%
        dplyr::summarise(covid_item = n_distinct(ID_ITEM))%>%
        ungroup()
      
      covid_contracts <- data_contracts_final%>%
        mutate(covid = ifelse(str_detect(STR_CONTRACT_DESCRIPTION, "covid")|
                                         str_detect(STR_CONTRACT_DESCRIPTION, "COVID")|
                                         str_detect(STR_CONTRACT_DESCRIPTION, "Covid")|
                                         str_detect(STR_CONTRACT_DESCRIPTION, "coronavirus")|
                                         str_detect(STR_CONTRACT_DESCRIPTION, "coronavirus")|
                                         str_detect(STR_CONTRACT_DESCRIPTION, "sars-cov-2"),1,0))%>%
        mutate_at(c("covid"), ~replace_na(., 0))%>%
        group_by(covid)%>%
        dplyr::summarise(covid_contracts = n_distinct(ID_CONTRACT))%>%
        ungroup()
      
      covid_tenders <- data_tenders_final%>%
        mutate(covid = ifelse(str_detect(STR_TENDER_DESCRIPTION, "covid")|
                                       str_detect(STR_TENDER_DESCRIPTION, "COVID")|
                                       str_detect(STR_TENDER_DESCRIPTION, "Covid")|
                                       str_detect(STR_TENDER_DESCRIPTION, "coronavirus")|
                                       str_detect(STR_TENDER_DESCRIPTION, "coronavirus")|
                                       str_detect(STR_TENDER_DESCRIPTION, "sars-cov-2"),1,0))%>%
        mutate_at(c("covid"), ~replace_na(., 0))%>%
        group_by(covid)%>%
        dplyr::summarise(covid_tenders = n_distinct(ID))%>%
        ungroup()
      
      covid_counts <- covid_tenders%>%
        left_join(covid_contracts, by = "covid")%>%
        left_join(covid_item, by = "covid")
      
      covid_counts
      
      # flag all COVID related items, contracts, tenders in intermediate datasets 
      covid_tender_item <- tender_item%>%
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
                                 covid_contract == 1 ~ 1))%>%
        mutate_at(c("covid"), ~replace_na(., 0))%>%
        select(ID, covid)%>%
        distinct()
      
      covid_tender_contract <- tender_contract%>%
        mutate(covid_contract = ifelse(str_detect(STR_CONTRACT_DESCRIPTION, "covid")|
                                     str_detect(STR_CONTRACT_DESCRIPTION, "COVID")|
                                     str_detect(STR_CONTRACT_DESCRIPTION, "Covid")|
                                     str_detect(STR_CONTRACT_DESCRIPTION, "coronavirus")|
                                     str_detect(STR_CONTRACT_DESCRIPTION, "coronavirus")|
                                     str_detect(STR_CONTRACT_DESCRIPTION, "sars-cov-2"),1,0),
               covid_tender = ifelse(str_detect(STR_TENDER_DESCRIPTION, "covid")|
                                         str_detect(STR_TENDER_DESCRIPTION, "COVID")|
                                         str_detect(STR_TENDER_DESCRIPTION, "Covid")|
                                         str_detect(STR_TENDER_DESCRIPTION, "coronavirus")|
                                         str_detect(STR_TENDER_DESCRIPTION, "coronavirus")|
                                         str_detect(STR_TENDER_DESCRIPTION, "sars-cov-2"),1,0),
               covid = case_when(covid_tender == 1 ~ 1,
                                 covid_contract == 1 ~ 1))%>%
        mutate_at(c("covid"), ~replace_na(., 0))%>%
        select(ID, covid)%>%
        distinct()
      
      covid_tender <- covid_tender_item%>%
        left_join(covid_tender_contract,
                  by = "ID", suffix = c("_tender_item", "_tender_contract"))%>%
        mutate_at(c("covid_tender_contract"), ~replace_na(., 0))
        
      covid_tender <- covid_tender%>%
        mutate(covid = case_when(covid_tender_item == 1 ~ 1,
                                 covid_tender_contract == 1 ~ 1))%>%
        mutate_at(c("covid"), ~replace_na(., 0))
        
      table(covid_tender[c("covid_tender_item", "covid_tender_contract")])
    
      covid_tender <- covid_tender%>%select(ID, covid)

      
# Identify Comparison Group ------------------------------------
      
      # add COVID dummy to supplier_item data 
      supplier_item <- supplier_item%>%
        left_join(covid_tender, by = "ID")  
          # note: 474 participants that cannot link to any items i.e. ocds-lcuori-grxXEr-COT. N°10-2019-1/3
      
      supplier_item <- supplier_item%>%
        mutate(covid_item = ifelse(str_detect(STR_ITEM_DESCRIPTION, "covid")|
                                         str_detect(STR_ITEM_DESCRIPTION, "COVID")|
                                         str_detect(STR_ITEM_DESCRIPTION, "Covid")|
                                         str_detect(STR_ITEM_DESCRIPTION, "coronavirus")|
                                         str_detect(STR_ITEM_DESCRIPTION, "coronavirus")|
                                         str_detect(STR_ITEM_DESCRIPTION, "sars-cov-2"),1,0),
               covid = case_when(covid == 1 ~ 1,
                                 covid_item == 1 ~ 1))%>%
        mutate_at(c("covid"), ~replace_na(., 0))
      
      # Construct and index to classify contracts to define comparison group.
      covid_item_unspsc <- supplier_item%>%
        filter(covid == 1)%>%
        select(ID, ID_PARTY, NAME_PARTY, ID_ITEM, ID_ITEM_UNSPSC, STR_ITEM_UNSPSC, STR_ITEM_DESCRIPTION, covid)
      
        # Question: should we use this list to construct 'medical' or just Segment 420000? Suggest using this list to flag medical products 
      
      # Construct Medical related dummy 
        # in UNSPSC code, 42000000 is the segment of Medical Equipment and Accessories and Supplies
        #                 41000000 is the segment of Laboratory and Measuring and Observing and Testing Equipment
        #                 51000000 is the segment of Drugs and Pharmaceutical Products
      
      # extract the first 2 charactors of unspsc and match with 42, 41, and 51  
      supplier_item$ID_ITEM_UNSPSC_SEG = substr(supplier_item$ID_ITEM_UNSPSC, start = 1, stop = 2)
      
      supplier_item <- supplier_item%>%
        mutate(medical = ifelse(ID_ITEM_UNSPSC_SEG == 42, 1,
                                ifelse(ID_ITEM_UNSPSC_SEG == 41, 1,
                                       ifelse(ID_ITEM_UNSPSC_SEG == 51, 1, 0))),
               sector = ifelse(covid == 1 & medical == 1, "Medical-COVID",
                              ifelse(covid != 1 &  medical == 1, "Medical-NonCOVID", 
                                     ifelse(covid == 1 & medical != 1, "NonMedical-COVID", "Non-Medical"))))
      
      supplier_item <- as.data.table(supplier_item)
      
      supplier_item_summary <- supplier_item[!is.na(sector),.N,by = "sector"]
      
      supplier_item_summary
      
      supplier_item <- as.data.frame(supplier_item)
      
      covid_sector <- supplier_item%>%
        # drop 474 observations that does not have item information 
        filter(!is.na(sector))%>%
        select(ID, covid, sector)%>%
        distinct()
      
      # identified sector for 85422 tenders 
      
      
      
## NEW WINNERS - construct with contract signature ---------------------------
      
      # Identify new winners 
      
          # single out suppliers between 2018 and 2022   
          contract_supplier <- contract_participants%>%
            filter(CAT_PARTY_ROLE == "supplier"|
                     CAT_PARTY_ROLE == "supplier;tenderer"&
                     YEAR <= 2022)%>%
            arrange(ID_PARTY, DT_CONTRACT_SIGNED)
          
          # calculate time lag 
          contract_supplier <- as.data.table(contract_supplier)
          
          contract_supplier = contract_supplier[, lag_date:= shift(DT_CONTRACT_SIGNED, 1, type="lag"), by="ID_PARTY"]
          
          # calculate how many days between the 2 contracts a firm has won 
          contract_supplier$lag_date <- as_datetime(contract_supplier$lag_date, tz = lubridate::tz(contract_supplier$lag_date))
          
          contract_supplier$diff_days_contract <- interval(contract_supplier$lag_date, contract_supplier$DT_CONTRACT_SIGNED) %/% days(1)
          
          # calculate the number of months from the previous contract by the same firm 
          contract_supplier$diff_months_contract <- interval(contract_supplier$lag_date, contract_supplier$DT_CONTRACT_SIGNED) %/% months(1)
          
          # identity new winners by days 
          contract_supplier <- as.data.frame(contract_supplier)
          
          contract_supplier <- contract_supplier%>%
            mutate(new_winner = case_when(is.na(diff_days_contract) ~ 1 ,
                                          diff_days_contract > 365 ~ 1 ,
                                          TRUE ~ 0 ))
          # summary statistics by year 
          new_winner_year <- contract_supplier%>%
            group_by(YEAR)%>%
            dplyr::summarise(num_new_winner = sum(new_winner))%>%
            ungroup()
          
          # summary statistics by month 
          contract_supplier$month <- strftime(contract_supplier$DT_CONTRACT_SIGNED, "%m")
          
          contract_supplier$year_month <- paste0(contract_supplier$YEAR, contract_supplier$month)
          
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
      
      # Add Groups 
          contract_supplier <- left_join(contract_supplier, covid_tender,
                                         by = "ID")
          # note: 329 contracts that do not exist in tender data i.e. ocds-lcuori-MLQnAG-LPNº047-2019-HGS-2/6
          
          contract_supplier <- contract_supplier%>%
            mutate(covid_contract = ifelse(str_detect(STR_CONTRACT_DESCRIPTION, "covid")|
                                             str_detect(STR_CONTRACT_DESCRIPTION, "COVID")|
                                             str_detect(STR_CONTRACT_DESCRIPTION, "Covid")|
                                             str_detect(STR_CONTRACT_DESCRIPTION, "coronavirus")|
                                             str_detect(STR_CONTRACT_DESCRIPTION, "coronavirus")|
                                             str_detect(STR_CONTRACT_DESCRIPTION, "sars-cov-2"),1,0),
                   covid = case_when(covid == 1 ~ 1,
                                     covid_contract == 1 ~ 1))%>%
            mutate_at(c("covid"), ~replace_na(., 0))
    
          new_winner_month_group <- contract_supplier%>%
            filter(year_month >= 201901)%>%
            group_by(year_month, covid)%>%
            dplyr::summarise(num_new_winner = sum(new_winner))%>%
            ungroup()
          
          new_winner_month_group$covid <- replace(new_winner_month_group$covid, new_winner_month_group$covid == 0, "Non-COVID")

          new_winner_month_group$covid <- replace(new_winner_month_group$covid, new_winner_month_group$covid == 1, "COVID")
          
          ggplot(new_winner_month_group, aes(x = year_month, y = num_new_winner, group = covid, color = covid))+
            geom_line()+
            theme_classic()+
            theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+
            labs(x = "Month", y = "Number of New Winners", title = "New Winners")

      
# Time Related Variables --------------------------------------------------------- 
      
      # Total processing time: contract signature - tender initiation
      # Submission time: submission deadline - tender initiation
      # Decision time: contract signature - submission deadline
      tender_contract <- tender_contract%>%
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
      
      tender_contract <- as.data.table(tender_contract)
      
      # check the overlap between contract signature, contract start and end date 
      check <- tender_contract[,.N, by = "publication_start"] # not consistent 
      
      check <- tender_contract[,.N, by = "submission_time"] # consistent: end > start 
      
      check <- tender_contract[,.N, by = "processing_time"] # consistent: signature > start 
      
      check <- tender_contract[,.N, by = "decision_time"] # consistent: signature > end 
      
      # Create month dummy
      tender_contract$month <- strftime(tender_contract$DT_CONTRACT_SIGNED, "%m")
      
      tender_contract$year <- strftime(tender_contract$DT_CONTRACT_SIGNED, "%Y")
      
      tender_contract$year_month <- paste0(tender_contract$year, tender_contract$month)
      
      tender_contract <- tender_contract%>%
        filter(year_month >= 201901 &
                 year_month <= 202208)
      
      # Add covid dummy 
      tender_contract <- left_join(tender_contract, covid_tender,
                                   by = "ID")
      
      tender_contract$covid <- replace(tender_contract$covid, tender_contract$covid == 0, "Non-COVID")
      
      tender_contract$covid <- replace(tender_contract$covid, tender_contract$covid == 1, "COVID")
      
      # submission time 
      submission_time <- tender_contract%>%
        group_by(year_month, covid)%>%
        dplyr::summarise(submission_time_avg = mean(submission_time))%>%
        ungroup()
      
      ggplot(submission_time, aes(x = year_month, y = submission_time_avg, group = covid, color = covid))+
        geom_line()+
        theme_classic()+
        theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+
        labs(x = "Month", y = "Submission Time (days)", title = "Submission Time (Number of Days from Tender Inquiry Start to Tender Inquiry End)")
      
      # process time 
      processing_time <- tender_contract%>%
        group_by(year_month, covid)%>%
        dplyr::summarise(processing_time_avg = mean(processing_time))%>%
        ungroup()
      
      ggplot(processing_time, aes(x = year_month, y = processing_time_avg, group = covid, color = covid))+
        geom_line()+
        theme_classic()+
        theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+
        labs(x = "Month", y = "Processing Time (days)", title = "Processing Time (Number of Days from Tender Inquiry Start to Contract Signature Date)")
      
      # decision time 
      decision_time <- tender_contract%>%
        group_by(year_month, covid)%>%
        dplyr::summarise(decision_time_avg = mean(decision_time))%>%
        ungroup()
      
      ggplot(decision_time, aes(x = year_month, y = decision_time_avg, group = covid, color = covid))+
        geom_line()+
        theme_classic()+
        theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+
        labs(x = "Month", y = "Decision Time (days)", title = "Decision Time (Number of Days from Tender Inquiry End to Contract Signature Date)")
      

# Geographical Analysis ------------------------------------------------------------
      ## location dummy - no address, need to check original dataset 
      # Same location dummy: Whether the firm is from the same municipality, or 
      # from the same province or from the same state (we can look at different 
      # levels of geographical areas, depending on the country). [Are contracts
      # during covid more likely to be awarded to firms from the same location as 
      # the buyer? Are bidders during covid less likely to be from the same location as the buyer?
      
      supplier_buyer <- data_parties_merged%>%
        filter(CAT_PARTY_ROLE == "buyer"|
                 CAT_PARTY_ROLE == "supplier"|
                 CAT_PARTY_ROLE == "supplier;tenderer")%>%
        mutate(role_region_locality = paste0(ID, "___", ID_PARTY, "___", NAME_PARTY, "___", ADDRESS_REGION, "___", ADDRESS_LOCALITY),
               CAT_PARTY_ROLE = replace(CAT_PARTY_ROLE, CAT_PARTY_ROLE == "supplier;tenderer", "supplier"))%>%
        pivot_wider(names_from = CAT_PARTY_ROLE, 
                    values_from = role_region_locality)
      
      supplier_buyer <- data_parties_merged%>%
        filter(CAT_PARTY_ROLE == "buyer"|
                 CAT_PARTY_ROLE == "supplier"|
                 CAT_PARTY_ROLE == "supplier;tenderer")%>%
        mutate(CAT_PARTY_ROLE = replace(CAT_PARTY_ROLE, CAT_PARTY_ROLE == "supplier;tenderer", "supplier"))
      
      supplier_buyer_buyer    <- supplier_buyer%>%
        filter(CAT_PARTY_ROLE == "buyer")
      
      supplier_buyer_supplier <- supplier_buyer%>%
        filter(CAT_PARTY_ROLE == "supplier")
      
      supplier_buyer <- left_join(supplier_buyer_buyer, supplier_buyer_supplier, 
                                  by = c("ocid", "ID", "ID_PARTY"),
                                  suffix = c("_BUYER", "_SUPPLIER"))
      
      # load a county list 

      
# Market concentration (quantity) ---------------------------------
    
      # definition: the number of winners per sector 
      
      # Create month dummy
      supplier_item$month <- strftime(supplier_item$DT_CONTRACT_SIGNED, "%m")
      
      supplier_item$year <- strftime(supplier_item$DT_CONTRACT_SIGNED, "%Y")
      
      supplier_item$year_month <- paste0(supplier_item$year, supplier_item$month)
      
      supplier_item <- supplier_item%>%
        filter(year_month >= 201901 &
                 year_month <= 202208)
      
      # calculate the average number of winners per sector in each month 
      market_concentration <- supplier_item%>%
        filter(!is.na(sector))%>%
        group_by(year_month, sector)%>%
        dplyr::summarise(winner_number = n_distinct(ID_PARTY))%>%
        ungroup()
      
      
      ggplot(market_concentration, aes(x = year_month, y = winner_number, group = sector, color = sector))+
        geom_line()+
        theme_classic()+
        theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+
        labs(x = "Month", y = "Number of Winners", title = "Market Concentration (Number of Winners per Sector)")
      
      

# Market concentration: the share of winners per sector (sector = covid/non-covid/medical/non-medical) ----------
      
      # change market concentration indicator from long to wide 
      market_concentration_share <- market_concentration%>%
        spread(sector, winner_number)
      
      market_concentration_share <- clean_names(market_concentration_share)
      
      market_concentration_share <- market_concentration_share%>%
        mutate_if(is.numeric, ~replace(., is.na(.), 0))%>%
        mutate(total         = medical_covid + medical_non_covid + non_medical +non_medical_covid,
               medical       = medical_covid + medical_non_covid,
               covid         = medical_covid + non_medical_covid,
               
               # the share of medical items in market 
               medical_share = medical/total,
               
               # the share of covid related items in market 
               covid_share   = covid/total,
               
               medical_covid_share = medical_covid/total)
        
      market_concentration_share_long <- market_concentration_share%>%
        select(year_month, medical_share:medical_covid_share)%>%
        gather(sector, share, medical_share:medical_covid_share, factor_key = TRUE)%>%
        mutate(sector = str_replace(sector, "medical_share", "Medical"))%>%
        mutate(sector = str_replace(sector, "covid_share", "COVID"))%>%
        mutate(sector = str_replace(sector, "medical_covid_share", "Medical-COVID"))%>%
        mutate(share = share*100)

      # plot 
      ggplot(market_concentration_share_long, aes(x = year_month, y = share, group = sector, color = sector))+
        geom_line()+
        theme_classic()+
        theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+
        labs(x = "Month", y = "Market Share (%)", title = "Market Concentration (Share of Sectors in Market)")
          # maybe change this to proportion plot? 
      

# Product Classification ------------------------------------------------
      # [Do firms during covid supply a broader range of different products?]
      # explore the number of products sold by the firm before, during and after COVID
      # Number of different product items (and sectors) sold in one year by the firm
      
      # create half year dummy 
      supplier_item$month <- as.numeric(supplier_item$month)
      
      firm_item <- supplier_item%>%
        mutate(half_year = ifelse(month <= 06, "01", "02"))

      firm_item$year_half <- paste0(firm_item$year, firm_item$half_year)
      
      # calculate average UNSPSC code firms have supplied within 6 months 
      firm_item <- firm_item%>%
        group_by(ID_PARTY, year_half)%>%
        dplyr::summarise(num_unspsc = n_distinct(ID_ITEM_UNSPSC))%>%
        ungroup()
      
      firm_item_stats <- firm_item%>%
        group_by(year_half)%>%
        dplyr::summarise(num_unspsc_avg = mean(num_unspsc))%>%
        ungroup()
      
      # plot 
      ggplot(firm_item_stats, aes(x = year_half, y = num_unspsc_avg, group = 1))+
        geom_line()+
        theme_classic()+
        theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+
        labs(x = "Year (every 6 months)", y = "Number of Different UNSPSC Commodity Code", title = "Change of the Number of Items")

      
      # flag firms that have increased the product code during COVID
      firm_item_year <- supplier_item%>%
        group_by(ID_PARTY, year)%>%
        dplyr::summarise(num_unspsc = n_distinct(ID_ITEM_UNSPSC))%>%
        ungroup()
      
      firm_uspsc_panel <- firm_item_year%>%
        spread(year, num_unspsc)%>%
        clean_names()%>%
        replace(is.na(.), 0)%>%
        mutate(product_increase = case_when(x2020 > x2019 | x2021 > x2019 ~ 1,
                                            TRUE ~ 0))%>%
        dplyr::rename("2019" = "x2019",
                      "2020" = "x2020",
                      "2021" = "x2021",
                      "2022" = "x2022")%>%
        dplyr::rename("ID_PARTY" = "id_party")%>%
        select(ID_PARTY, product_increase)
      
      firm_product <- left_join(supplier_item, firm_uspsc_panel,
                                by = "ID_PARTY")
      
      table(firm_product["product_increase"])
    
      
      
      
      
      
