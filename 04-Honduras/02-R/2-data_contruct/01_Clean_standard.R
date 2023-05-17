# ---------------------------------------------------------------------------- #
#                                                                              #
#               FY23 MDTF - Emergency Response Procurement - Honduras          #
#                                                                              # 
#                                     Clean                                    #
#                                                                              #
#        Author: Hao Lyu (RA - DIME3)            Last Update:  Oct 30 2022     #
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
# tender - buyer - item 

# LOAD DATA -------------------------------------------------------------------

    # aggregated data from 2018 to 2021
      data_participants_final   <- readRDS(file.path(raw_oncae, "DATA_PARTICIPANTS.RDS"))
      data_documents_final      <- readRDS(file.path(raw_oncae, "DATA_DOCUMENTS.RDS"   ))
      data_items_final          <- readRDS(file.path(raw_oncae, "DATA_ITEMS.RDS"       ))
      data_contracts_final      <- readRDS(file.path(raw_oncae, "DATA_CONTRACTS.RDS"   ))
      data_tenders_final        <- readRDS(file.path(raw_oncae, "DATA_TENDERS.RDS"     ))

    # original data sets from 2018 to 2021 
    
      # tender level 
      data_releases      <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_releases.csv"             )))  # tender level - 138873 obs,  138873 ID, 138872 OCID

      data_parties       <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_parties.csv"               ))) # tender_participants 

      data_par_member    <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_par_memberof.csv"          ))) # tender_participants 

      data_ten_items     <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_ten_items.csv"             ))) # tender_item  -  198164 obs, 136882 ID, 136881 OCID, 
    
      data_ten_tenderers <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_ten_tenderers.csv"         ))) # tender_tenderers 
    

      # contract level 
      data_contracts     <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_contracts.csv"             ))) # contract - 38832 obs, 35930 OCID, 35930 ID
    
      data_suppliers_con <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_con_suppliers.csv"         ))) # contract_supplier level 
    
    
      # awards level 
      data_awards        <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_awards.csv"                ), encoding = "Latin-1", colClasses = "character")) # award

      data_awa_doc       <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_awa_documents.csv"         ))) # award
    
      data_awa_items     <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_awa_items.csv"             ))) # awards_item 

      data_awa_suppliers <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_awa_suppliers.csv"         ))) # awards_supplier 

    
      # UNSPSC code 
      data_unspsc_commodity       <- read_xlsx(file.path(raw_data,"unspsc.xlsx"), sheet = 5)
    
    
      # useless datasets 
      data_plan_budget   <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_pla_bud_budgetbreakdown.csv"))) 
    
      data_garantees_con <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_con_guarantees.csv"        ))) # contract_guarantees 
    
      data_ten_fees      <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_ten_participationfees.csv" ))) # tender_participants 
    
      data_document_ten  <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_ten_documents.csv"         ))) # tender
    
      data_document_con  <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_con_documents.csv"         ))) # contract 
    
      data_sources       <- as.data.frame(fread(file.path(raw_oncae_interm,"DCC_sources.csv"               ))) 
    
    
    
    
      
# CHECK UNIQUE ID ----------------------------------------------------

# tenders data- data exploration -----------------------------------------
      
      length(unique(data_tenders_final$ID))
        # 1 tender, 1 ID - 138873 - old code
      
    # buyer
    
      buyer <- data_tenders_final%>%
        group_by(ID_BUYER)%>%
        dplyr::summarise(N = n_distinct(NAME_BUYER))%>%
        ungroup() %>%
        view()
        # 1 buyer, 1 ID (but 1 buyer could have multiple names)
      
    # tender_buyer
      
      tender_buyer <- data_tenders_final%>%
        group_by(ID)%>%
        dplyr::summarise(N = n_distinct(ID_BUYER))%>%
        ungroup() %>%
        view()
        # 1 tender, 1 buyer 
      
      
    # participants - "tenderer"  "supplier;tenderer" "supplier" 
      # 1 tender, multiple participants 

      # suppliers: 
      suppliers <- data_participants_final%>%
            filter(CAT_PARTY_ROLE == "supplier"|
                     CAT_PARTY_ROLE == "supplier;tenderer")%>%
            relocate(CAT_PARTY_ROLE, .after = ID) %>%
        view()
  
      suppliers_duplicate <- suppliers%>%
        group_by(ID_PARTY)%>%
        dplyr::summarise(N = n_distinct(NAME_PARTY))%>%
        ungroup() %>%
        view()
        # 1 ID_PARTY is associated with 1 firm. 
        # 5950 supplier ID. 
        # Supplier ID is more accurate than supplier name 
      
      length(unique(suppliers$ID))
        # the number of tender that has suppliers/winners: 85722 (88653)
      
       tender_supplier <- suppliers%>%
        group_by(ID)%>%
        dplyr::summarise(num_suppliers = n_distinct(ID_PARTY))%>%
        ungroup() %>%
         view()
        # some tenders have multiple suppliers 
       
    
    # tender_ contract
      tender_contract <- data_contracts_final%>%
        group_by(ID)%>%
        dplyr::summarise(num_contract = n_distinct(ID_CONTRACT))%>%
        ungroup()
      # 1 tender, multiple contracts 
      
    
    # tender_item
      tender_item <- data_items_final%>%
        group_by(ID)%>%
        dplyr::summarise(num_item = n_distinct(ID_ITEM))%>%
        ungroup()
      # 1 tender, multiple items  
    
    # contract_supplier 
      supplier_con <- clean_names(data_suppliers_con)
      
      supplier_con <- supplier_con %>%
        group_by(contracts_0_id)%>%
        dplyr::summarise(count = n_distinct(contracts_0_suppliers_0_id))%>%
        ungroup()
      
      unique(supplier_con$count)
      # 1 contract, 1 supplier 
      
    
    
# PREPARE DATASETS -----------------------------------------------------------
      
      
# To construct new winner, generate tender-contract-supplier data -----------------------------
      
    # DATA RELEASES -------------------------------------------------
      
      # drop a list of vars
      drop <- c(
        
        "ocid"                                   ,
        "buyer/name"                             ,
        "planning/budget/id"                     ,
        "tender/title"                           ,
        "tender/mainProcurementCategory"         ,
        "tender/procuringEntity/id"              ,
        "tender/procuringEntity/name"            ,
        "tender/additionalProcurementCategories" ,
        "tender/tenderPeriod/endDate"            ,
        "tender/tenderPeriod/startDate"          ,
        "tender/legalBasis/id"                   ,
        "tender/localProcurementCategory"        ,
        "initiationType"                         ,  
        "language"                               ,
        "publisher/name"                         ,
        "tender/id"                              ,
        "tender/legalBasis/scheme"               ,
        "date"
        
      )
      
      data_releases_new <- data_releases[,!colnames(data_releases) %in% drop] 
      
      # create time variables
      data_releases_new <- data_releases_new %>% 
        mutate(
          
          DT_TENDER_START = as.Date(substr(`tender/enquiryPeriod/startDate`, 0, 10)),
          
          DT_TENDER_END = as.Date(substr(`tender/enquiryPeriod/endDate`, 0, 10)),
          
          DT_TENDER_PUB = as.Date(substr( `tender/datePublished`, 0,10)))
    
      
      drop <- c( # List of old vars we want to drop from the main dataset
        
        "tender/enquiryPeriod/endDate",
        "tender/enquiryPeriod/startDate",
        "tender/datePublished"
        
      )
      
      data_releases_new <- data_releases_new[,!colnames(data_releases_new) %in% drop] 
      
      data_releases_new <- data_releases_new %>% 
        
        dplyr::rename(
          
          ID                       = `id`                              ,
          ID_BUYER                 = `buyer/id`                        ,
          CAT_TENDER_TAG           = `tag`                             ,
          CAT_TENDER_METHOD        = `tender/procurementMethod`        ,
          STR_TENDER_DESCRIPTION   = `tender/description`              ,
          CAT_TENDER_METHOD_DETAIL = `tender/procurementMethodDetails` ,  
          CAT_TENDER_STATUS_DETAIL = `tender/statusDetails`            ,  
          CAT_TENDER_LEGAL_DESC    = `tender/legalBasis/description`   , 
          CAT_TENDER_STATUS        = `tender/status`     
          
        )
      
      # We drop the old dataset 
      rm(data_releases)
    
      
    # DATA CONTRACTS ------------------------------------------------
      drop <- c( 
        
        "contracts/0/title"                    ,
        "contracts/0/buyer/id"                 ,
        "contracts/0/buyer/name"               ,
        "contracts/0/localProcurementCategory" 
        
      )
      
      data_contracts_new <- data_contracts[,!colnames(data_contracts) 
                                           %in% drop] 
      
      data_contracts_new <- data_contracts_new %>% 
        
        dplyr::rename(
          
          ID                        = `id`                          ,
          ID_CONTRACT               = `contracts/0/id`              , 
          AMT_CONTRACT_VALUE        = `contracts/0/value/amount`    ,
          CAT_CONTRACT_CURRENCY     = `contracts/0/value/currency`  ,
          STR_CONTRACT_DESCRIPTION  = `contracts/0/description` 
          
        )
      
      data_contracts_new <- data_contracts_new %>% 
        mutate(
          
          DT_CONTRACT_SIGNED = as.Date(substr(`contracts/0/dateSigned`, 0, 10)),
          AMT_CONTRACT_VALUE = ifelse(AMT_CONTRACT_VALUE <= 0, NA, AMT_CONTRACT_VALUE)
          
        )
      
      data_contracts_new <- data_contracts_new %>% 
        
        mutate(
          DT_CONTRACT_SIGNED = dplyr::if_else(substr(data_contracts_new$DT_CONTRACT_SIGNED, 0, 4) == "2049" | 
                                                substr(data_contracts_new$DT_CONTRACT_SIGNED, 0, 4) == "2219",
                                              paste0("2016", substr(data_contracts_new$DT_CONTRACT_SIGNED, 5, 12)), 
                                              as.character(data_contracts_new$DT_CONTRACT_SIGNED)))
      
      currency_matrix <- WDI(
        
        country   = "HN"                              ,
        indicator = "PA.NUS.FCRF"                     ,
        start     = 2016                              ,
        end       = 2022             
      )
      
      currency_matrix <- as.data.frame(currency_matrix[,c(4,5)])
      
      colnames(currency_matrix) <- c("YEAR", "EXCHANGE_RATE")
      
      currency_matrix$CAT_CONTRACT_CURRENCY <- "HNL"
      
      data_contracts_new_usd <- data_contracts_new %>% 
        
        mutate(YEAR = as.numeric(substr(DT_CONTRACT_SIGNED, 0, 4)))

      data_contracts_new_usd <- left_join(data_contracts_new_usd, currency_matrix, by = c("YEAR", "CAT_CONTRACT_CURRENCY"))
      
      data_contracts_new_usd$EXCHANGE_RATE[data_contracts_new_usd$CAT_CONTRACT_CURRENCY == "USD"] <- 1
      
      data_contracts_new_usd <- data_contracts_new_usd %>% 
        mutate(AMT_CONTRACT_VALUE_USD    = AMT_CONTRACT_VALUE/EXCHANGE_RATE) %>% 
        mutate(CAT_CONTRACT_CURRENCY = "USD")
      
      data_contracts_new_usd$AMT_CONTRACT_VALUE_USD <- formatC(data_contracts_new_usd$AMT_CONTRACT_VALUE_USD, 
                                                               digits = 2, format = "f")
      
      drop <- c(
        
        "contracts/0/dateSigned" 
        
      )
      
      # we drop the list of vars
      data_contracts_new_usd <- data_contracts_new_usd[,!colnames(data_contracts_new_usd) 
                                                       %in% drop] 
      
      rm(data_contracts_new, data_contracts)
      
    
# Contract_supplier-------------------------------------------------------
      drop <- c( "ocid" )
      
      # we drop the list of vars
      data_suppliers_con_new <- data_suppliers_con[,!colnames(data_suppliers_con) 
                                                   %in% drop] 
      
      # rename all the variables
      data_suppliers_con_new <- data_suppliers_con_new %>% 
        
        dplyr::rename(
          
          ID                     = `id`                         ,
          ID_CONTRACT            = `contracts/0/id`             , 
          ID_SUPPLIER               = `contracts/0/suppliers/0/id` ,
          NAME_SUPPLIER             = `contracts/0/suppliers/0/name`
          
        )
      
      # We drop the old dataset 
      rm(data_suppliers_con)
      

    # merge contract and tender data 
      # only select awarded tenders 
      data_releases_awarded <- data_releases_new%>%
        filter(CAT_TENDER_STATUS_DETAIL == "Adjudicado")    #  88060 tenders, 35930 contracts, 38831 contracts with suppliers 
      
      # merge contract with suppliers 
      contract_supplier <- left_join(data_contracts_new_usd, data_suppliers_con_new,
                                     by = c("ID", "ID_CONTRACT"))                    # perfect match between contract and supplier 

      # merge tender publication date to contract-supplier 
      tender_pub_date <- data_releases_awarded%>%
        select(ID, DT_TENDER_PUB)
        
      contract_supplier <- left_join(contract_supplier, tender_pub_date,
                                      by = "ID")
      
      # drop unsuccessful contracts 
      contract_supplier <- contract_supplier%>%
        filter(!is.na(DT_TENDER_PUB))
      
      fwrite(contract_supplier, file = paste0(intermediate, "/Contract_Supplier.csv"))
      
    
# Year variable ---------------------------------------------------------
    contract_date <- data_contracts_new_usd%>%
      select(ID, DT_CONTRACT_SIGNED)
    
# To construct product classification, we need Supplier - Item Data ---------------------------------------------------
      # market concentration: number of winners per sector
      # firms that have increased the product code during COVID. Number of different products (UNSPC codes) supplied by the same firm over 1 year (or 6 months) [Do firms during covid supply a broader range of products?]
      # Construct a market concentration (at sector level - number of winners per sector). 
      # Look at the common market concentration construction - Herfindahl-Hirschman Index (HHI). 
      # Note: sector level means by product sector// medical/non-medical, covid/non-covid 
    
      
      # DATA PARTIES -------------------------------------------------------
      drop <- c( # List of variables we want to drop from the dataset
        
        "parties/0/contactPoint/faxNumber"   ,
        "parties/0/identifier/id"            ,
        "parties/0/contactPoint/name"        ,
        "parties/0/contactPoint/url"         ,
        "parties/0/identifier/scheme"        ,
        "parties/0/contactPoint/email"       ,
        "parties/0/contactPoint/telephone"  
        
      )
      
      data_parties_new <- data_parties[,!colnames(data_parties) %in% drop] 
      
      data_parties_new <- data_parties_new %>% 
        
        dplyr::rename(
          ID                       = `id`                              ,
          ID_PARTY                 = `parties/0/id`                    ,
          CAT_PARTY_ROLE           = `parties/0/roles`                 ,
          NAME_PARTY               = `parties/0/name`                  ,
          ADDRESS_REGION           = `parties/0/address/region`        ,
          ADDRESS_LOCALITY         = `parties/0/address/locality`      ,
          ADDRESS_ST               = `parties/0/address/streetAddress`
          
        )
      
      rm(data_parties)
      
      #  DATA PAR MEMBER OF ------------------------------------------------
      drop <- c( # List of variables we want to drop from the dataset
        
        "ocid"                   ,
        "id"                     ,
        "parties/0/id"
        
      )
      
      data_par_member_new <- data_par_member[,!colnames(data_par_member) %in% drop] 
      
      data_par_member_new <- data_par_member_new %>% 
        
        dplyr::rename(
          
          ID_PARTY_MEMBEROF              = `parties/0/memberOf/0/id`        ,
          NAME_PARTY_MEMBEROF            = `parties/0/memberOf/0/name`    
          
        )
      
      rm(data_par_member)
      
      # drop observations that are redundant. 
      # Every buyer has another observation to describe the "member of", 
      # we can get that from the other dataset so that we can drop all 
      # these observations now. But we will add them like variables 
      # later on (extracting them from "data_par_member_of")
      
      data_parties_new <- data_parties_new[!(nchar(data_parties_new$ID_PARTY) == 6 & 
                                               data_parties_new$CAT_PARTY_ROLE == "buyer"),]
      
      data_parties_new <- data_parties_new %>% 
        mutate(
          # only buyers have a parties_member_id 
          # when there is a department the lenght of the string is 13
          ID_PARTY_MEMBEROF = ifelse(CAT_PARTY_ROLE != "buyer", NA,   
                                     ifelse(nchar(ID_PARTY) == 6, NA, 
                                            substr(ID_PARTY,8,13))))
      
      # Merge the dataset with all the parties with the name of the departments 
      # (only for buyers)
      data_parties_merged <- left_join(data_parties_new, 
                                       data_par_member_new %>% distinct(), by = "ID_PARTY_MEMBEROF")
      
      fwrite(data_parties_merged, file = paste0(intermediate, "/Data_Parties_Merged.csv"))
      
      # Remove the two datasets that have been merged together
      rm(data_par_member_new, data_parties_new)
      
      
      # single out suppliers between 2018 and 2022   
      data_supplier <- data_parties_merged%>%
        filter(CAT_PARTY_ROLE == "supplier"|
                 CAT_PARTY_ROLE == "supplier;tenderer")%>%
        mutate(CAT_PARTY_ROLE = replace(CAT_PARTY_ROLE, CAT_PARTY_ROLE == "supplier;tenderer", "supplier"))
      
      supplier_item <- left_join(data_supplier, data_items_final,
                                 by = "ID")
      
     
      # merge UNSPSC code 
      data_unspsc_commodity <- data_unspsc_commodity%>%
        dplyr::rename(ID_ITEM_UNSPSC = Commodity,
                      STR_ITEM_UNSPSC = Description)
      
      supplier_item <- supplier_item%>% 
        left_join(data_unspsc_commodity, by = "ID_ITEM_UNSPSC")%>%
        dplyr::relocate(STR_ITEM_UNSPSC, .after = ID_ITEM_UNSPSC)
      
      # merge contract signature date variable to supplier-item
      supplier_item <- left_join(supplier_item, contract_date,
                                 by = "ID")
      
      # drop items before 2018 
      supplier_item$year <- strftime(supplier_item$DT_CONTRACT_SIGNED, "%Y")
      
      supplier_item <- supplier_item%>%
        filter(year >= 2016 & 
                 year < 2025)%>%
        distinct()%>%
        # drop items that do not link to any suppliers 
        filter(!is.na(ID_ITEM))
        
      fwrite(supplier_item, file = paste0(intermediate, "/Supplier_Item.csv"))
      

# To construct COVID dummy, we need tender-item & tender-contract data --------
      
    # tender-item -------------------------------------------------------------
      # merge item level to tender data 
      tender_item <- left_join(data_tenders_final, data_items_final,
                               by = "ID")  
      # note: all tenders link to items 
      
      # merge in time variable 
      tender_item <- left_join(tender_item, contract_date,
                               by = "ID")
      
      tender_item$year <- strftime(tender_item$DT_CONTRACT_SIGNED, "%Y")
      
      # drop tenders that were signed before 2016 
      tender_item <- tender_item %>%
        filter(year >= 2016 &
                 year < 2025)%>%
        distinct() 
      
      fwrite(tender_item, file = paste0(intermediate, "/Tender_Item.csv"))
      
    # tender-contract ---------------------------------------------------------
      # Total processing time: contract signature - tender initiation
      # Delivery time: delivery date - contract signature
      # check if tender_end is always after contract_signature to confirm whether
      # we can assume that tender_end is the delivery date 
    
      tender_contract <- left_join(data_contracts_final, data_tenders_final,
                                   by = "ID")
      
      # Create month dummy
      tender_contract$month <- strftime(tender_contract$DT_CONTRACT_SIGNED, "%m")
      
      tender_contract$year <- strftime(tender_contract$DT_CONTRACT_SIGNED, "%Y")
      
      tender_contract$year_month <- paste0(tender_contract$year, tender_contract$month)
      
      tender_contract <- tender_contract%>%
        filter(year_month >= 201601 &
                 year_month <= 202303)
      
    fwrite(tender_contract, file = paste0(intermediate, "/Contract_Tender.csv"))
    

    
# Clean single level data -----------------------------------------------------
    
    # filter out 2016 - 2022 data 
    data_participants_final   <- readRDS(file.path(raw_oncae, "DATA_PARTICIPANTS.RDS"))
    data_documents_final      <- readRDS(file.path(raw_oncae, "DATA_DOCUMENTS.RDS"   ))
    data_items_final          <- readRDS(file.path(raw_oncae, "DATA_ITEMS.RDS"       ))
    data_contracts_final      <- readRDS(file.path(raw_oncae, "DATA_CONTRACTS.RDS"   ))
    data_tenders_final        <- readRDS(file.path(raw_oncae, "DATA_TENDERS.RDS"     ))
    
    # Participants Level
    data_participants_final   <- left_join(data_participants_final, contract_date,
                                           by = "ID")
    
    data_participants_final$year <- strftime(data_participants_final$DT_CONTRACT_SIGNED, "%Y")
    
    data_participants_final <- data_participants_final%>%
      filter(year >= 2016 & 
               year < 2024)
    
    fwrite(data_participants_final, file = paste0(intermediate, "/Data_Participants_Final.csv"))
    
    # Item Level   
    data_items_final          <-  left_join(data_items_final, contract_date,
                                            by = "ID")
    
    data_items_final$year <- strftime(data_items_final$DT_CONTRACT_SIGNED, "%Y")
    
    data_items_final <- data_items_final%>%
      filter(year >= 2016 &
             year < 2024)
    
    fwrite(data_items_final, file = paste0(intermediate, "/Data_Items_Final.csv"))
      
    # Contract level   
    data_contracts_final$year <- strftime(data_contracts_final$DT_CONTRACT_SIGNED, "%Y")
    
    data_contracts_final <- data_contracts_final%>%
      filter(year >= 2016 &
            year < 2024)
    
    fwrite(data_contracts_final, file = paste0(intermediate, "/Data_Contracts_Final.csv"))
    
    # Tender Level 
    data_tenders_final$tender_pub_year   <- strftime(data_tenders_final$DT_TENDER_PUB, "%Y")
    
    data_tenders_final        <- data_tenders_final%>%
      filter(tender_pub_year >= 2016 &
               tender_pub_year < 2024)
    
    fwrite(data_tenders_final, file = paste0(intermediate, "/Data_Tenders_Final.csv"))
    