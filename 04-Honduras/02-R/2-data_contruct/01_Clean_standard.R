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

    # tenders
      
      length(unique(data_tenders_final$ID))
        # 1 tender, 1 ID - 138873 
    
    # buyer
    
      buyer <- data_tenders_final%>%
        group_by(ID_BUYER)%>%
        dplyr::summarise(N = n_distinct(NAME_BUYER))%>%
        ungroup()
        # 1 buyer, 1 ID (but 1 buyer could have multiple names)
      
    # tender_buyer
      
      tender_buyer <- data_tenders_final%>%
        group_by(ID)%>%
        dplyr::summarise(N = n_distinct(ID_BUYER))%>%
        ungroup()
        # 1 tender, 1 buyer 

    # participants - "tenderer"  "supplier;tenderer" "supplier" 
      # 1 tender, multiple participants 

      # suppliers: 
      suppliers <- data_participants_final%>%
            filter(CAT_PARTY_ROLE == "supplier"|
                     CAT_PARTY_ROLE == "supplier;tenderer")%>%
            relocate(CAT_PARTY_ROLE, .after = ID)
  
      suppliers_duplicate <- suppliers%>%
        group_by(ID_PARTY)%>%
        dplyr::summarise(N = n_distinct(NAME_PARTY))%>%
        ungroup()
        # 1 ID_PARTY is associated with 1 firm. 
        # 5950 supplier ID. 
        # Supplier ID is more accurate than supplier name 
      
      length(unique(suppliers$ID))
        # the number of tender that has suppliers/winners: 85722 (88653)
      
       tender_supplier <- suppliers%>%
        group_by(ID)%>%
        dplyr::summarise(num_suppliers = n_distinct(ID_PARTY))%>%
        ungroup()
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
    
    
    

    
    
    
    
# Previous Merging Part 2 --------DONT RUN CODE BELOW--------------------------
    
    
# DATA TEN FEES ----------------------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_ten_fees
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                               ,
      "tender/id"                          ,
      "tender/participationFees/0/id"      ,
      "tender/participationFees/0/type"    
      
    )
    
    # we drop the list of vars
    data_ten_fees_new <- data_ten_fees[,!colnames(data_ten_fees) %in% drop] 
    
    # Here, we rename all the variables
    data_ten_fees_new <- data_ten_fees_new %>% 
      
      dplyr::rename(
        
        ID                       = `id`                                    ,
        AMT_PARTICIPATION_FEE            = `tender/participationFees/0/value/amount`    
        
      )
    
    # We drop the old dataset 
    rm(data_ten_fees)
    
    # DATA TEN ITEMS ---------------------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_ten_fees
    
    # Here, we add the description of UNSPC codes
    
    data_ten_items_new <- data_ten_items %>% 
      mutate(MERGE = substr(`tender/items/0/classification/id`, 0, 2))
    
    data_unspsc_commodity        <- data_unspsc_commodity         %>% 
      mutate(MERGE = substr(Segment, 0, 2))
    
    data_ten_items_new <- left_join(data_ten_items_new, data_unspsc_commodity, by = "MERGE")  
    
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                                       ,
      "tender/id"                                  ,
      "tender/items/0/classification/description"  ,
      "tender/items/0/classification/scheme"       ,
      "MERGE"                                      ,
      "Segment"                                   
      
    )
    
    # we drop the list of vars
    
    # Here, we rename all the variables
    data_ten_items_new <- data_ten_items_new %>% 
      
      dplyr::rename(
        
        ID                       = `id`                                ,
        ID_ITEM                  = `tender/items/0/id`                 ,
        STR_ITEM_DESCRIPTION     = `tender/items/0/description`        ,
        ITEM_MEASURE_UNIT        = `tender/items/0/unit/name`          ,
        ID_ITEM_UNSPSC           = `tender/items/0/classification/id`  ,
        AMT_ITEM                 = `tender/items/0/quantity`           ,
        STR_UNSPSC_DECSRIPTION   = `Description`                       ,
        TYPE_GOOD_SERVICE        = `Type of good` 
        
      )
    
    # We drop the old dataset 
    rm(data_ten_items)
    
    # Here, we rename all the variables
    data_ten_items_new <- data_ten_items_new %>% 
      
      # this function cleans the string from all the special 
      # characters and lower cases
      mutate_at(c("ITEM_MEASURE_UNIT"), function(x) { 
        
        # lower case
        x <- stri_trans_general(x, "Lower"             ) 
        # no accents
        x <- stri_trans_general(x, "Latin-ASCII"       )
        # take out everything that is not alphanumeric
        x <-    str_replace_all(x, "[^[:alnum:]]", " " ) 
        # take out punctuations
        x <-    str_replace_all(x, "[[:punct:]]", " "  ) 
        # remove double spaces
        x <-         str_squish(x)    
        
      })
    
    
    # DATA PLAN BUDGET -------------------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_plan_budget
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                                             ,
      "planning/budget/budgetBreakdown/0/id"             , 
      "planning/budget/budgetBreakdown/0/sourceParty/id" ,
      "tender/id"                                        ,
      "planning/budget/id"
      
    )
    
    # we drop the list of vars
    data_plan_budget_new <- data_plan_budget[,!colnames(data_plan_budget) %in% drop] 
    
    # Here, we rename all the variables
    data_plan_budget_new <- data_plan_budget_new %>% 
      
      dplyr::rename(
        
        ID                = `id`                                                 ,
        NAME_SOURCE       = `planning/budget/budgetBreakdown/0/sourceParty/name` ,
        CAT_SOURCE        = `planning/budget/budgetBreakdown/0/description`
        
      )
    
    # We drop the old dataset 
    rm(data_plan_budget)
    
    
    
    # DATA AWARDS DOC  -------------------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_awa_doc
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                              ,
      "awards/0/documents/0/documentType" ,
      "awards/0/documents/0/format"       ,
      "awards/0/documents/0/description"  ,
      "awards/0/id"
      
    )
    
    # we drop the list of vars
    data_awa_doc_new <- data_awa_doc[,!colnames(data_awa_doc) %in% drop] 
    
    # Here, we rename all the variables
    data_awa_doc_new <- data_awa_doc_new %>% 
      
      dplyr::rename(
        
        ID                = `id`                                                 ,
        ID_DOC            = `awards/0/documents/0/id`                            ,
        CAT_DOC_TITLE     = `awards/0/documents/0/title`                         ,
        URL_DOC           = `awards/0/documents/0/url`                               
        
      )
    
    # Here, we create the new two variables
    data_awa_doc_new <- data_awa_doc_new %>% 
      mutate(
        
        # we extract the date from the main variable
        DT_DOC = as.Date(substr(`awards/0/documents/0/datePublished`,
                                0,
                                10))
        
      )
    
    
    # Here, we drop the old variable 
    drop <- c( # List of old vars we want to drop from the main dataset
      
      "awards/0/documents/0/datePublished"
      
    )
    
    # we drop the list of vars
    data_awa_doc_new <- data_awa_doc_new[,!colnames(data_awa_doc_new) %in% drop] 
    
    # We drop the old dataset 
    rm(data_awa_doc)
    
    
    # DATA AWARDS ITEMS ------------------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_awa_items
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                                         ,
      "awards/0/items/0/classification/description"  ,
      "awards/0/items/0/classification/scheme"       ,
      "awards/0/id"
      
      
    )
    
    # we drop the list of vars
    data_awa_items_new <- data_awa_items[,!colnames(data_awa_items) %in% drop] 
    
    # Here, we rename all the variables
    data_awa_items_new <- data_awa_items_new %>% 
      
      dplyr::rename(
        
        ID                       = `id`                                  ,
        ID_ITEM                  = `awards/0/items/0/id`                 ,
        STR_ITEM_DESCRIPTION     = `awards/0/items/0/description`        ,
        PRICE_ITEM_MEASURE_UNIT  = `awards/0/items/0/unit/name`          ,
        ID_ITEM_UNSPSC           = `awards/0/items/0/classification/id`  ,
        AMT_ITEM                 = `awards/0/items/0/quantity`           ,
        PRICE_UNIT_ITEM          = `awards/0/items/0/unit/value/amount`
        
      )
    
    # We drop the old dataset 
    rm(data_awa_items)
    
    
    
    # DATA AWARDS SUPPLIERS --------------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_awa_suppliers
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                                       ,
      "awards/0/id"                                ,
      "awards/0/suppliers/0/name"    
      
    )
    
    # we drop the list of vars
    data_awa_suppliers_new <- data_awa_suppliers[,!colnames(data_awa_suppliers) %in% drop] 
    
    # DATA CLEANING: rename vars ---------------------------------------------------
    
    # Here, we rename all the variables
    data_awa_suppliers_new <- data_awa_suppliers_new %>% 
      
      dplyr::rename(
        
        ID                       = `id`                                ,
        ID_PARTY                 = `awards/0/suppliers/0/id`            
        
      )
    
    # We drop the old dataset 
    rm(data_awa_suppliers)
    
    
    # DATA DOC CONTRACTS -----------------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_document_con
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                              ,
      "contracts/0/documents/0/documentType" ,
      "contracts/0/documents/0/format"       ,
      "contracts/0/documents/0/description"  
      
    )
    
    # we drop the list of vars
    data_document_con_new <- data_document_con[,!colnames(data_document_con) %in% drop] 
    
    # Here, we rename all the variables
    data_document_con_new <- data_document_con_new %>% 
      
      dplyr::rename(
        
        ID                = `id`                                                 ,
        ID_DOC            = `contracts/0/documents/0/id`                         ,
        CAT_DOC_TITLE     = `contracts/0/documents/0/title`                      ,
        URL_DOC           = `contracts/0/documents/0/url`                        ,
        ID_CONTRACT       = `contracts/0/id`
        
      )
    
    # Here, we create the new two variables
    data_document_con_new <- data_document_con_new %>% 
      mutate(
        
        # we extract the date from the main variable
        DT_DOC = as.Date(substr(`contracts/0/documents/0/datePublished`,
                                0,
                                10))
        
      )
    
    
    # Here, we drop the old variable 
    drop <- c( # List of old vars we want to drop from the main dataset
      
      "contracts/0/documents/0/datePublished"
      
    )
    
    # we drop the list of vars
    data_document_con_new <- data_document_con_new[,!colnames(data_document_con_new) %in% drop] 
    
    # We drop the old dataset 
    rm(data_document_con)
    
    
    # DATA TEN TENDERERS -----------------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_suppliers_con
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                         , 
      "tender/id"                    ,
      "tender/tenderers/0/name"
      
    )
    
    # we drop the list of vars
    data_ten_tenderers_new <- data_ten_tenderers[,!colnames(data_ten_tenderers) 
                                                 %in% drop] 
    
    # DATA CLEANING: rename vars ---------------------------------------------------
    
    # Here, we rename all the variables
    data_ten_tenderers_new <- data_ten_tenderers_new %>% 
      
      dplyr::rename(
        
        ID                     = `id`                         ,
        ID_PARTY               = `tender/tenderers/0/id`        
        
      )
    
    # We drop the old dataset 
    rm(data_ten_tenderers)
    
    
    # DATA DOC TENDERS -------------------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_document_ten
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                            ,
      "tender/documents/0/documentType" ,
      "tender/documents/0/format"       ,
      "tender/documents/0/description"  ,
      "tender/id"
      
    )
    
    # we drop the list of vars
    data_document_ten_new <- data_document_ten[,!colnames(data_document_ten) %in% drop] 
    
    # Here, we create the new two variables
    data_document_ten_new <- data_document_ten_new %>% 
      mutate(
        
        # we extract the date from the main variable
        DT_DOC = as.Date(substr(`tender/documents/0/datePublished`,0,10))
        
      )
    
    
    # Here, we drop the old variable 
    drop <- c( # List of old vars we want to drop from the main dataset
      
      "tender/documents/0/datePublished"
      
    )
    
    # we drop the list of vars
    data_document_ten_new <- data_document_ten_new[,!colnames(data_document_ten_new) %in% drop] 
    
    # Here, we rename all the variables
    data_document_ten_new <- data_document_ten_new %>% 
      
      dplyr::rename(
        
        ID             = `id`                       ,
        ID_DOC         = `tender/documents/0/id`	  ,
        CAT_DOC_TITLE  = `tender/documents/0/title` ,
        URL_DOC        = `tender/documents/0/url`	  	
        
      )
    
    # We drop the old dataset 
    rm(data_document_ten)
    
    
    
    # DATA AWARDS ------------------------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_awards
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"              ,
      "awards/0/id"
      
    )
    
    # we drop the list of vars
    data_awards_new <- data_awards%>%
      select(-c("ocid"              ,
                "awards/0/id"))
    
    # Here, we rename all the variables
    data_awards_new <- data_awards_new %>% 
      
      dplyr::rename(
        
        ID             = `id`                       	
        
      )
    
    # We drop the old dataset 
    rm(data_awards)
    
    
    
    
    ########################
    #### MERGING      ######
    ########################
    
    # DATA MERGING: tender-level ---------------------------------------------------
    
    # First, we add information about the buyers
    
    data_tender_final <- left_join(
      
      data_releases_new, data_parties_merged, by= c("ID_PARTY","ID")
      
    )
    
    # Second, we drop "CAT_PARTY_ROLE" since they are all buyers, and we rename the vars so that 
    # from now on we talk about buyers here
    
    drop <- c( # List of variables we want to drop from the main dataset
      
      "CAT_PARTY_ROLE"                            
      
    )
    
    # we drop the list of vars
    data_tender_final <- data_tender_final[,!colnames(data_tender_final) %in% drop] 
    
    # Here, we rename the variables
    data_tender_final <- data_tender_final %>% 
      
      dplyr::rename(
        
        ID_BUYER                 = `ID_PARTY`            ,
        NAME_BUYER               = `NAME_PARTY`          ,
        ID_BUYER_MEMBEROF        = `ID_PARTY_MEMBEROF`   ,
        NAME_BUYER_MEMBEROF      = `NAME_PARTY_MEMBEROF`                            
        
      )
    
    data_tender_final <- left_join(
      
      data_tender_final, data_ten_fees_new, by = c("ID")
      
    )
    
    
    # We first take all the unique values that will become source_1
    data_plan_budget_new_1 <- data_plan_budget_new[
      !duplicated(data_plan_budget_new$ID),] %>% 
      dplyr::rename(
        
        NAME_SOURCE_1 = NAME_SOURCE,
        CAT_SOURCE_1  = CAT_SOURCE
        
      )
    
    # We then take all the duplicated values that will become source_2 
    data_plan_budget_new_2 <- data_plan_budget_new[
      duplicated(data_plan_budget_new$ID),] %>% 
      dplyr::rename(
        
        NAME_SOURCE_2 = NAME_SOURCE,
        CAT_SOURCE_2  = CAT_SOURCE
        
      )
    
    # We merge the two dataset sources with the data_tender_final
    
    data_tender_final <- left_join(
      
      data_tender_final, data_plan_budget_new_1, by = c("ID")
      
    )
    
    data_tender_final <- left_join(
      
      data_tender_final, data_plan_budget_new_2, by = c("ID")
      
    )
    
    # Finally, we reorder the columns...  
    
    data_tender_final <- data_tender_final[,c(
      
      "ID"                       ,
      "CAT_TENDER_METHOD"        ,
      "CAT_TENDER_METHOD_DETAIL" ,
      "CAT_TENDER_STATUS"        ,
      "CAT_TENDER_STATUS_DETAIL" ,
      "CAT_TENDER_TAG"           ,
      "CAT_TENDER_LEGAL_DESC"    ,
      "STR_TENDER_DESCRIPTION"   ,
      "DT_TENDER_PUB"            ,
      "DT_TENDER_START"          ,
      "DT_TENDER_END"            ,
      "AMT_PARTICIPATION_FEE"    ,
      "ID_BUYER"                 ,
      "NAME_BUYER"               ,
      "ID_BUYER_MEMBEROF"        ,
      "NAME_BUYER_MEMBEROF"      ,
      "NAME_SOURCE_1"            ,
      "CAT_SOURCE_1"             ,
      "NAME_SOURCE_2"            ,
      "CAT_SOURCE_2"               
      
    )]
    
    # ... and we label the columns  
    
    var_label(data_tender_final$ID                       ) <- "Global unique identifier: tender-level"
    var_label(data_tender_final$CAT_TENDER_METHOD        ) <- "Tender method applied"
    var_label(data_tender_final$CAT_TENDER_METHOD_DETAIL ) <- "Tender method applied in detail"
    var_label(data_tender_final$CAT_TENDER_STATUS        ) <- "Status of the tender"
    var_label(data_tender_final$CAT_TENDER_STATUS_DETAIL ) <- "Status of the tender in detail"
    var_label(data_tender_final$CAT_TENDER_TAG           ) <- "Tag that indicates if the tender have been awarded with or without contract"
    var_label(data_tender_final$CAT_TENDER_LEGAL_DESC    ) <- "Laws that govern the contracting process and that grant legal authority to the procuring entity (DESCRIPTION)"
    var_label(data_tender_final$DT_TENDER_START          ) <- "Enquiry period: date of start"
    var_label(data_tender_final$DT_TENDER_END            ) <- "Enquiry period: date of end"
    var_label(data_tender_final$DT_TENDER_PUB            ) <- "Date of publication"
    var_label(data_tender_final$AMT_PARTICIPATION_FEE    ) <- "Amount of participation fee paid by the tenderer to get acess to documents"
    var_label(data_tender_final$ID_BUYER                 ) <- "Global unique identifier for each BUYER"
    var_label(data_tender_final$NAME_BUYER               ) <- "Name of the BUYER"
    var_label(data_tender_final$ID_BUYER_MEMBEROF        ) <- "Global unique identifier for each department the party is part of (only for buyers)"
    var_label(data_tender_final$NAME_BUYER_MEMBEROF      ) <- "Name of each department the BUYER is part of"
    var_label(data_tender_final$NAME_SOURCE_1            ) <- "Name of the first budget source"
    var_label(data_tender_final$CAT_SOURCE_1             ) <- "Type of the first budget source"
    var_label(data_tender_final$NAME_SOURCE_2            ) <- "Name of the second budget source"
    var_label(data_tender_final$CAT_SOURCE_2             ) <- "Type of the second budget source"
    var_label(data_tender_final$STR_TENDER_DESCRIPTION   ) <- "Detailed description of the deiverable associated with the tender"
    
    # We drop all the old datasets that we used and we do not longer need
    
    rm(
      
      data_releases_new     , 
      data_plan_budget_new  , 
      data_plan_budget_new_1, 
      data_plan_budget_new_2, 
      data_ten_fees_new
      
    )
    
    
    ## DATA MERGING: Participant-level ---------------------------------------------
    
    data_participants_final <- data_parties_merged %>% 
      
      filter( # we filter only the participants 
        CAT_PARTY_ROLE == "supplier"         |
          CAT_PARTY_ROLE == "supplier;tenderer"|
          CAT_PARTY_ROLE == "tenderer"     
      ) 
    
    # Second, we drop "ID_PARTY_MEMBEROF" and "NAME_PARTY_MEMBEROF" since these vars
    # are only for buyers 
    
    drop <- c( # List of variables we want to drop from the main dataset
      
      "ID_PARTY_MEMBEROF"  ,
      "NAME_PARTY_MEMBEROF",
      "ADDRESS"            ,
      "REGION"             ,
      "URL"
      
    )
    
    data_participants_final <- data_participants_final[
      ,!colnames(data_participants_final) %in% drop] 
    
    data_participants_final <- data_participants_final %>% 
      
      # this function cleans the string from all the special characters 
      # and lower-case letters
      mutate_at(c("ID_PARTY"), function(x) {  
        
        x <- gsub("HND-IDCARD-", ""   , x,fixed = TRUE)     
        x <- gsub("HN-RTN-", ""       , x,fixed = TRUE)     
        x <- gsub("HND-PASSPORT-", "" , x,fixed = TRUE)    
        x <- str_replace_all(x, "[[:punct:]]", " "  ) 
        
      }) %>% 
      
      distinct()
    
    # we drop the list of vars
    
    # Here, we want to do check if all the information aobut participant that are in 
    # data_suppliers_con_new and data_awa_suppliers_new are already in the 
    # data_parties_merged
    
    # First, we create a combination of ID and ID_PARTY. This combination is unique,
    # it indicates if a firm has participated to one specific tender. 
    
    # We do this for the award suppliers
    data_supp_check <- data_awa_suppliers_new %>% 
      mutate(
        CHECK = paste0(ID, ID_PARTY)
      ) %>%  
      na.omit()
    
    # We do this for the main dataset
    data_parties_check <- data_participants_final %>%
      mutate(
        CHECK = paste0(ID, ID_PARTY)
      )
    
    # We do this for contract suppliers
    data_supp_con_check <- data_suppliers_con_new %>% 
      mutate(
        CHECK = paste0(ID, ID_PARTY)
      )
    
    # Then we check if some of those string are missing in the master data:
    
    nrow(data_supp_check %>% 
           filter(!CHECK %in% data_parties_check$CHECK)) # 0 missings
    
    nrow(data_supp_con_check %>% 
           filter(!CHECK %in% data_parties_check$CHECK)) # 0 missings
    
    
    #  data_suppliers_con_new and data_awa_suppliers_new are already inside
    # data_parties_merged and therefore are redundant. We can just drop them, and 
    # keep only using data_parties_merged
    
    rm(
      data_suppliers_con_new,
      data_awa_suppliers_new,
      data_ten_tenderers_new
    )
    
    # Finally, we reorder the columns...  
    data_participants_final <- data_participants_final[,c(
      
      "ID"             ,
      "ID_PARTY"       ,
      "NAME_PARTY"     ,
      "EMAIL"          ,
      "TELEPHONE"      ,
      "CAT_PARTY_ROLE"             
      
    )]
    
    # ... and we label the columns 
    
    var_label(data_participants_final$ID                    ) <- "Global unique identifier: tender-level"
    var_label(data_participants_final$ID_PARTY              ) <- "Global unique identifier for each participant"
    var_label(data_participants_final$NAME_PARTY            ) <- "Name of the participant"
    var_label(data_participants_final$CAT_PARTY_ROLE        ) <- "Role of the participant: tenderer or supplier"
    
    # We drop the dataset we used and we do not longer need
    rm(data_parties_merged)
    
    # DATA MERGING: item-level ---------------------------------------------------
    
    # We extract only the information we need from this following dataset 
    # (prices and measure units for prices)
    
    data_to_merge <- data_awa_items_new %>% 
      
      select(
        
        "ID_ITEM"                , 
        "PRICE_ITEM_MEASURE_UNIT",
        "PRICE_UNIT_ITEM"
        
      )
    
    data_item_final <- left_join(data_ten_items_new, data_to_merge, by = "ID_ITEM")
    
    # Finally, we reorder the columns... 
    data_item_final <- data_item_final[,c(
      
      "ID"                      ,
      "ID_ITEM"                 ,
      "ID_ITEM_UNSPSC"          ,
      "STR_ITEM_DESCRIPTION"    ,
      "ITEM_MEASURE_UNIT"   ,
      "AMT_ITEM"                ,
      "PRICE_UNIT_ITEM"         ,
      "TYPE_GOOD_SERVICE"
    )]
    
    # ... and we label the columns  
    
    var_label(data_item_final$ID                      ) <- "Global unique identifier: tender-level"
    var_label(data_item_final$ID_ITEM                 ) <- "Global unique identifier for each item"
    var_label(data_item_final$ID_ITEM_UNSPSC          ) <- "UNSPC code"
    var_label(data_item_final$STR_ITEM_DESCRIPTION    ) <- "Description of the deliverable"
    var_label(data_item_final$ITEM_MEASURE_UNIT       ) <- "Measure unit used for AMT_ITEM and PRICE_UNIT_ITEM"
    var_label(data_item_final$AMT_ITEM                ) <- "Amount of item"
    var_label(data_item_final$PRICE_UNIT_ITEM         ) <- "Unit price for the item (only for awarded tenders)"
    var_label(data_item_final$TYPE_GOOD_SERVICE       ) <- "Good vs Service"
    
    rm(
      
      data_ten_items_new     , 
      data_awa_items_new     ,
      data_to_merge
      
    )
    
    # DATA MERGING: contract-level ---------------------------------------------------
    
    data_contracts_new <- left_join(data_contracts_new_usd, 
                                    data_garantees_con_new, 
                                    by = c("ID_CONTRACT","ID"))
    
    # Finally, we reorder the columns... 
    
    data_contracts_final <- data_contracts_new[,c(
      
      "ID"                       ,
      "ID_CONTRACT"              ,
      "CAT_CONTRACT_CURRENCY"    ,
      "AMT_CONTRACT_VALUE"       ,
      "STR_CONTRACT_DESCRIPTION" ,
      "DT_CONTRACT_SIGNED"       ,
      "CAT_GUARANTEE"            ,
      "ID_GUARANTOR"             ,
      "NAME_GUARANTOR"           
      
    )]
    
    # ... and we label the columns  
    
    var_label(data_contracts_final$ID                        ) <- "Global unique identifier: tender-level"
    var_label(data_contracts_final$ID_CONTRACT               ) <- "Global unique identifier for each contract"
    var_label(data_contracts_final$CAT_CONTRACT_CURRENCY     ) <- "Currency used for AMT_CONTRACT_VALUE"
    var_label(data_contracts_final$AMT_CONTRACT_VALUE        ) <- "Value of the contract"
    var_label(data_contracts_final$STR_CONTRACT_DESCRIPTION  ) <- "Description of the deliverable"
    var_label(data_contracts_final$DT_CONTRACT_SIGNED        ) <- "Date of contract signature"
    var_label(data_contracts_final$CAT_GUARANTEE             ) <- "Description of the deliverable"
    var_label(data_contracts_final$CAT_GUARANTEE             ) <- "Global unique identifier for each guarantor"
    var_label(data_contracts_final$NAME_GUARANTOR            ) <- "Date of contract signature"
    
    # We drop all the old datasets that we used and we do not longer need
    
    rm(
      
      data_contracts_new     ,
      data_garantees_con_new 
      
    )
    
    # DATA MERGING: document-level ---------------------------------------------------
    
    # We first need to create a new empty column called "ID_CONTRACT" for 
    # data_awa_doc_new and data_document_ten_new
    
    data_awa_doc_new$ID_CONTRACT      <- NA
    data_document_ten_new$ID_CONTRACT <- NA
    
    # We can append all three datasets together since they have the same columns
    data_document_final <- rbind(
      
      data_awa_doc_new      ,
      data_document_con_new ,
      data_document_ten_new
      
    )
    
    # We drop all the old datasets that we used and we do not longer need
    
    rm(
      
      data_awa_doc_new      ,
      data_document_con_new ,
      data_document_ten_new ,
      data_sources          ,
      data_awards_new 
      
    )
    
    # Finally, we reorder the columns...  
    
    data_document_final <- data_document_final[,c(
      
      "ID"            ,
      "ID_DOC"        ,
      "ID_CONTRACT"   ,
      "CAT_DOC_TITLE" ,
      "DT_DOC"        ,
      "URL_DOC"       
      
    )]
    
    # ... and we label the columns 
    
    var_label(data_document_final$ID            ) <- "Global unique identifier: tender-level"
    var_label(data_document_final$ID_CONTRACT   ) <- "Global unique identifier for each contract"
    var_label(data_document_final$ID_DOC        ) <- "Global unique identifier for each document"
    var_label(data_document_final$CAT_DOC_TITLE ) <- "Title of the document"
    var_label(data_document_final$DT_DOC        ) <- "Date of document publication"
    var_label(data_document_final$URL_DOC       ) <- "Source of the document: url link"

    