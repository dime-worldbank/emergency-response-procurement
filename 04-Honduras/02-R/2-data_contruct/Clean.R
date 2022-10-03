# ---------------------------------------------------------------------------- #
#                                                                              #
#               FY23 MDTF - Emergency Response Procurement - Honduras          #
#                                                                              # 
#                                     CLEAN                                    #
#                                                                              #
#        Author: Hao Lyu (RA - DIME3)            Last Update: Sept 22 2022     #
#                                                                              #
# ---------------------------------------------------------------------------- #

# **************************************************************************** #
#       This script aims to clean Honduras data downloaded from COVID portal.  #               
#                                                                              #
#       The structure of this script is as followed:                           #
#
#
#                                                                              #
# **************************************************************************** #


# LOAD DATA -------------------------------------------------------------------

  # Datasets exist in both old portal and covid portal 

    # load the tender document data
    data_awards             <- as.data.frame(fread(file.path(data_covid,"awards.csv"                  ), encoding = "Latin-1", colClasses = "character")) 
    # load the documents contract data
    data_document_con       <- as.data.frame(fread(file.path(data_covid,"con_documents.csv"           ))) 
    # load the items data
    data_con_items          <- as.data.frame(fread(file.path(data_covid,"con_items.csv"               ))) 
    # load the supplier contract data
    data_suppliers_con      <- as.data.frame(fread(file.path(data_covid,"con_suppliers.csv"           ))) 
    # load the contract data
    data_contracts          <- as.data.frame(fread(file.path(data_covid,"contracts.csv"               ))) 
    # load the parties data
    data_parties            <- as.data.frame(fread(file.path(data_covid,"parties.csv"                 ))) 
    # load the contract data
    data_releases           <- as.data.frame(fread(file.path(data_covid,"releases.csv"                )))
    # load the tender document data 
    data_sources            <- as.data.frame(fread(file.path(data_covid,"sources.csv"                 ))) 

  # Datasets only exist in covid portal 

    bid_statistics          <- as.data.frame(fread(file.path(data_covid,"bid_statistics.csv"          ))) 
    con_imp_transactions    <- as.data.frame(fread(file.path(data_covid,"con_imp_transactions.csv"    ))) 
    con_ite_attributes      <- as.data.frame(fread(file.path(data_covid,"con_ite_attributes.csv"      ))) 
    con_milestones          <- as.data.frame(fread(file.path(data_covid,"con_milestones.csv"          ))) 
    con_val_exchangeRates   <- as.data.frame(fread(file.path(data_covid,"con_val_exchangeRates.csv"   ))) 
    con_val_exchangeRates   <- as.data.frame(fread(file.path(data_covid,"con_val_exchangeRates.csv"   ))) 
    links                   <- as.data.frame(fread(file.path(data_covid,"links.csv"                   ))) 
    par_det_classifications <- as.data.frame(fread(file.path(data_covid,"par_det_classifications.csv" ))) 
  
# DATA CLEANING ---------------------------------------------------------------
    
  # DATA AWARDS ---------------------------------------------------------------
    
    # drop vars
    data_awards_new <- data_awards%>%
      select(-c("ocid"                 ,
                "awards/0/id"          ,
                "awards/0/title"       ,
                "awards/0/relatedBid"  , 
                "awards/0/date"         ))%>%
      dplyr::rename(ID = `id`)
    
    # drop the old dataset 
    rm(data_awards)
    
  ## DATA DOCUMENT CONTRACTS -------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_document_con
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                                 ,
      "contracts/0/documents/0/documentType" 
      
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
    
    # variable `contracts/0/documents/0/datePublished' does not exist 
    
    # We drop the old dataset 
    rm(data_document_con)
    
    
    
  ## DATA CONTRACTS ITEMS ---------------------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_con_items
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                                              ,
      "contracts/0/id"                                    ,
      "contracts/0/items/0/deliveryAddress/region"        ,
      "contracts/0/items/0/deliveryLocation/description"
      
    )
    
    # we drop the list of vars
    data_con_items_new <- data_con_items[,!colnames(data_con_items) 
                                         %in% drop] 
    # Here, we rename all the variables
    data_con_items_new <- data_con_items_new %>% 
      
      dplyr::rename(
        
        ID                       = `id`                                         ,
        ID_ITEM                  = `contracts/0/items/0/id`                     ,
        ITEM_AMOUNT              = `contracts/0/items/0/unit/value/amount`      ,
        ITEM_MEASURE_UNIT        = `contracts/0/items/0/unit/value/currency`    ,
        AMT_ITEM                 = `contracts/0/items/0/quantity`               ,
        STR_DESCRIPTION          = `contracts/0/items/0/description`            ,

      )
    
    # We drop the old dataset 
    rm(data_con_items)
    
    # Here, we rename all the variables
    data_con_items_new <- data_con_items_new %>% 
      
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
    
    
    
  ## DATA CONTRACTS ---------------------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_contracts
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                                 ,
      "contracts/0/title"                    ,
      "contracts/0/awardID"                  ,
      "contracts/0/period/durationInDays"    ,
      "contracts/0/period/endDate" 
      
    )
    
    # we drop the list of vars
    data_contracts_new <- data_contracts[,!colnames(data_contracts) 
                                         %in% drop] 
    
    
    # Here, we rename all the variables
    data_contracts_new <- data_contracts_new %>% 
      
      dplyr::rename(
        
        ID                        = `id`                          ,
        ID_CONTRACT               = `contracts/0/id`              , 
        AMT_CONTRACT_VALUE        = `contracts/0/value/amount`    ,
        CAT_CONTRACT_CURRENCY     = `contracts/0/value/currency`  ,
        STR_CONTRACT_DESCRIPTION  = `contracts/0/description` 
        
      )
    
    # Here, we create the new two variables about contract start day and contract value 

    data_contracts_new <- data_contracts_new %>% 
      mutate(
        
        # we extract the date from the contract signed start date variable
        DT_CONTRACT_START = as.Date(substr(`contracts/0/period/startDate`,
                                            0,
                                            10)),
        
        AMT_CONTRACT_VALUE = ifelse(AMT_CONTRACT_VALUE <= 0, NA, AMT_CONTRACT_VALUE)
        
      )
    
    data_contracts_new <- data_contracts_new %>% 
      
      mutate(
        DT_CONTRACT_START = dplyr::if_else(substr(data_contracts_new$DT_CONTRACT_START, 0, 4) == "2049" | substr(data_contracts_new$DT_CONTRACT_START, 0, 4) == "2219",
                                            paste0("2019", substr(data_contracts_new$DT_CONTRACT_START, 5, 12)), 
                                            as.character(data_contracts_new$DT_CONTRACT_START)
        )
      )
    
    # Then We study the distribution of contract values
    # First, we need to convert all the values in USD so that it is easier to understand the distribution
    # To do so, we use the average currency conversion rate provided by the WDI package
    currency_matrix <- WDI(
      
      country   = "HN"                              ,
      indicator = c("exchange_rate" = "PA.NUS.FCRF"),
      start     = 2020                              ,
      end       = 2021             
    )
    
    data_contracts_new_usd <- data_contracts_new %>% 
      
      mutate(YEAR = as.numeric(substr(DT_CONTRACT_START, 0, 4))) 
    
    currency_matrix <- currency_matrix[,c(3,4)]
    colnames(currency_matrix) <- c("EXCHANGE_RATE", "YEAR")
    data_contracts_new_usd <- left_join(data_contracts_new_usd, currency_matrix, by = "YEAR")
    
    data_contracts_new_usd <- data_contracts_new_usd %>% 
      mutate(AMT_CONTRACT_VALUE    = AMT_CONTRACT_VALUE/EXCHANGE_RATE) %>% 
      mutate(CAT_CONTRACT_CURRENCY = "USD")
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "contracts/0/period/startDate" 
      
    )
    
    # we drop the list of vars
    data_contracts_new_usd <- data_contracts_new_usd[,!colnames(data_contracts_new_usd) 
                                                     %in% drop] 
    
    # We drop the old dataset 
    rm(data_contracts, data_contracts_new)
    
    
  # DATA SUPPLIERS CON  ----------------------------------------------------------
    
    # Here, we start doing some general data cleaning for data_suppliers_con
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                         , 
      "contracts/0/suppliers/0/name" 
      
    )
    
    # we drop the list of vars
    data_suppliers_con_new <- data_suppliers_con[,!colnames(data_suppliers_con) 
                                                 %in% drop] 
    
    # Here, we rename all the variables
    data_suppliers_con_new <- data_suppliers_con_new %>% 
      
      dplyr::rename(
        
        ID             = `id`                         ,
        ID_CONTRACT            = `contracts/0/id`             , 
        ID_PARTY               = `contracts/0/suppliers/0/id`    
        
      )
    
    # We drop the old dataset 
    rm(data_suppliers_con)
    
    
    
    
  ## DATA PARTIES --------------------------------------------
    
    # Here, we start doing some general data cleaning for data_parties
    
    drop <- c( # List of variables we want to drop from the dataset
      
      "ocid"                               ,
      "parties/0/identifier/id"            ,
      "parties/0/contactPoint/name"        , 
      "parties/0/identifier/scheme"
      
    )
    
    # we drop the list of vars
    data_parties_new <- data_parties[,!colnames(data_parties) %in% drop] 
    
    # Here, we rename all the variables
    data_parties_new <- data_parties_new %>% 
      
      dplyr::rename(
        
        ID                       = `id`                              ,
        ID_PARTY                 = `parties/0/id`                    ,
        CAT_PARTY_ROLE           = `parties/0/roles`                 ,
        NAME_PARTY               = `parties/0/name`                  ,
        EMAIL                    = `parties/0/contactPoint/email`    ,
        TELEPHONE                = `parties/0/contactPoint/telephone`,
        ADDRESS                  = `parties/0/address/locality`         
        
      )
    
    # We drop the old dataset 
    rm(data_parties)
    
    # Here, we can drop observations that are redundant. 
    # Every buyer has another observation to describe the "member of", 
    # we can get that from the other dataset so that we can drop all 
    # these observations now. But we will add them like variables 
    # later on (extracting them from "data_par_member_of")
    
    data_parties_new <- data_parties_new[!(nchar(data_parties_new$ID_PARTY) == 6 & 
                                             data_parties_new$CAT_PARTY_ROLE == "buyer"),]
    
    # Some cleaning useful for merging later on
    data_parties_new <- data_parties_new %>% 
      
      # We create a new variable to identify the department identifier 
      mutate(
        
        # only buyers have a parties_member_id 
        # when there is a department the lenght of the string is 13
        ID_PARTY_MEMBEROF = ifelse(CAT_PARTY_ROLE != "buyer", NA,   
                                   ifelse(nchar(ID_PARTY) == 6, NA, 
                                          substr(ID_PARTY,8,13))) 
        
      )
    
    
    
    
  
  ## DATA RELEASES ----------------------------------------------------------------
    
    
    
    # Here, we create the new two variables
    data_releases_new <- data_releases %>% 
      mutate(
        
        # we extract the date from the main variable
        DT_TENDER_PUB = as.Date(substr(date,0,10))
        
      )
    
    
    # Here, we drop the old variable 
    drop <- c( # List of old vars we want to drop from the main dataset
      
      "buyer/name"                               , 
      "date"                                     ,
      "description"                              ,
      "initiationType"                           ,
      "language"                                 ,
      "ocid"                                     ,
      "planning/budget/amount/amount"            ,
      "planning/budget/amount/currency"          ,
      "planning/budget/description"              ,
      "tender/additionalProcurementCategories"   ,
      "tender/procuringEntity/id"                ,
      "tender/procuringEntity/name"              ,
      "tender/eligibilityCriteria"               ,
      "tender/id"                                ,
      "tender/legalBasis/scheme"                 ,
      "tender/title"
      
    )
    
    # we drop the list of vars
    data_releases_new <- data_releases_new[,!colnames(data_releases_new) %in% drop] 
    
    # Here, we rename all the variables
    data_releases_new <- data_releases_new %>% 
      
      dplyr::rename(
        
        ID                       = `id`                              ,
        ID_PARTY                 = `buyer/id`                        ,
        CAT_TENDER_TAG           = `tag`                             ,
        STR_TENDER_DESCRIPTION   = `tender/description`              ,
        CAT_TENDER_METHOD_DETAIL = `tender/procurementMethodDetails`   

      )
    
    # We drop the old dataset 
    rm(data_releases)
    
    
    

    
















































    


# MERGING ---------------------------------------------------------------------
    
    
    # DATA MERGING: tender-level ---------------------------------------------------
    
    # First, we add information about the buyers
    data_releases_new$ID_PARTY<- as.character(data_releases_new$ID_PARTY)
    
    data_tender_final <- left_join(
      
      data_releases_new, data_parties_new, by= c("ID_PARTY","ID")
      
    )
    
    # Second, we drop "CAT_PARTY_ROLE" since they are all buyers, and we rename the vars so that 
    # from now on we talk about buyers here
    
    drop <- c( # List of variables we want to drop from the main dataset
      
      "CAT_PARTY_ROLE"      ,
      "ADDRESS"             ,
      "EMAIL"               ,
      "TELEPHONE"
      
    )
    
    # we drop the list of vars
    data_tender_final <- data_tender_final[,!colnames(data_tender_final) %in% drop] 
    
    # Here, we rename the variables
    data_tender_final <- data_tender_final %>% 
      
      dplyr::rename(
        
        ID_BUYER                 = `ID_PARTY`            ,
        NAME_BUYER               = `NAME_PARTY`          ,
        ID_BUYER_MEMBEROF        = `ID_PARTY_MEMBEROF`   ,

      )
    
 
    # Finally, we reorder the columns...  
    
    data_tender_final <- data_tender_final[,c(
      
      "ID"                       ,
      "CAT_TENDER_METHOD_DETAIL" ,
      "CAT_TENDER_TAG"           ,
      "STR_TENDER_DESCRIPTION"   ,
      "DT_TENDER_PUB"            ,
      "ID_BUYER"                 ,
      "NAME_BUYER"               ,
      "ID_BUYER_MEMBEROF"        

    )]
    
    # ... and we label the columns  
    
    var_label(data_tender_final$ID                       ) <- "Global unique identifier: tender-level"
    # var_label(data_tender_final$CAT_TENDER_METHOD        ) <- "Tender method applied"
    var_label(data_tender_final$CAT_TENDER_METHOD_DETAIL ) <- "Tender method applied in detail"
    # var_label(data_tender_final$CAT_TENDER_STATUS        ) <- "Status of the tender"
    # var_label(data_tender_final$CAT_TENDER_STATUS_DETAIL ) <- "Status of the tender in detail"
    var_label(data_tender_final$CAT_TENDER_TAG           ) <- "Tag that indicates if the tender have been awarded with or without contract"
    # var_label(data_tender_final$CAT_TENDER_LEGAL_DESC    ) <- "Laws that govern the contracting process and that grant legal authority to the procuring entity (DESCRIPTION)"
    # var_label(data_tender_final$DT_TENDER_START          ) <- "Enquiry period: date of start"
    # var_label(data_tender_final$DT_TENDER_END            ) <- "Enquiry period: date of end"
    var_label(data_tender_final$DT_TENDER_PUB            ) <- "Date of publication"
    # var_label(data_tender_final$AMT_PARTICIPATION_FEE    ) <- "Amount of participation fee paid by the tenderer to get acess to documents"
    var_label(data_tender_final$ID_BUYER                 ) <- "Global unique identifier for each BUYER"
    var_label(data_tender_final$NAME_BUYER               ) <- "Name of the BUYER"
    var_label(data_tender_final$ID_BUYER_MEMBEROF        ) <- "Global unique identifier for each department the party is part of (only for buyers)"
    # var_label(data_tender_final$NAME_BUYER_MEMBEROF      ) <- "Name of each department the BUYER is part of"
    # var_label(data_tender_final$NAME_SOURCE_1            ) <- "Name of the first budget source"
    # var_label(data_tender_final$CAT_SOURCE_1             ) <- "Type of the first budget source"
    # var_label(data_tender_final$NAME_SOURCE_2            ) <- "Name of the second budget source"
    # var_label(data_tender_final$CAT_SOURCE_2             ) <- "Type of the second budget source"
    var_label(data_tender_final$STR_TENDER_DESCRIPTION   ) <- "Detailed description of the deliverable associated with the tender"
    
    # We drop all the old datasets that we used and we do not longer need
    
    rm(
      
      data_releases_new      

    )
    
    
    ## DATA MERGING: Participant-level ---------------------------------------------
    
    data_participants_final <- data_parties_new %>% 
      
      filter( # we filter only the participants 
        CAT_PARTY_ROLE == "supplier"         |
          CAT_PARTY_ROLE == "supplier;tenderer"|
          CAT_PARTY_ROLE == "tenderer"     
      ) 
    
    # Second, we drop "ID_PARTY_MEMBEROF" and "NAME_PARTY_MEMBEROF" since these vars
    # are only for buyers 
    
    drop <- c( # List of variables we want to drop from the main dataset
      
      "ID_PARTY_MEMBEROF"  ,
      "ADDRESS"            

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
    

    # Here, we want to do check if all the information about participant that are in 
    # data_suppliers_con_new and data_awa_suppliers_new are already in the 
    # data_parties_merged
    
    # First, we create a combination of ID and ID_PARTY. This combination is unique,
    # it indicates if a firm has participated to one specific tender. 
    
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
    
    nrow(data_supp_con_check %>% 
           filter(!CHECK %in% data_parties_check$CHECK)) # 21610 missings!!! 
    
    data_supp_con_check <- data_supp_con_check %>% filter(!CHECK %in% data_parties_check$CHECK)
    
    #  data_suppliers_con_new and data_awa_suppliers_new are already inside
    # data_parties_merged and therefore are redundant. We can just drop them, and 
    # keep only using data_parties_merged
    
    #rm(
    #  data_suppliers_con_new,
    #  data_awa_suppliers_new,
    #  data_ten_tenderers_new
    #  )
    
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
    

    # DATA MERGING: item-level ---------------------------------------------------
    
    # don't have data_award_item to extract prices and measure units for prices
    
    # Finally, we reorder the columns... 
    data_item_final <- data_con_items_new[, c(
      
      "ID"                      ,
      "ID_ITEM"                 ,
      "STR_DESCRIPTION"         ,
      "ITEM_MEASURE_UNIT"       ,
      "AMT_ITEM"                ,
      "ITEM_AMOUNT"             )]
    

    # ... and we label the columns  
    
    var_label(data_item_final$ID                      ) <- "Global unique identifier: tender-level"
    var_label(data_item_final$ID_ITEM                 ) <- "Global unique identifier for each item"
    var_label(data_item_final$STR_DESCRIPTION         ) <- "Description of the deliverable"
    var_label(data_item_final$ITEM_MEASURE_UNIT       ) <- "Measure unit used for AMT_ITEM and PRICE_UNIT_ITEM"
    var_label(data_item_final$AMT_ITEM                ) <- "Amount of item"
    var_label(data_item_final$ITEM_AMOUNT             ) <- "Unit price for the item (only for awarded tenders)"
    # var_label(data_item_final$TYPE_GOOD_SERVICE      ) <- "Good vs Service"
    # var_label(data_item_final$ID_ITEM_UNSPSC          ) <- "UNSPC code"
    

    rm(
      
      data_con_items_new
      
      )
    
    
    # DATA MERGING: contract-level ---------------------------------------------------

        # we reorder the columns... 
    
    data_contracts_final <- data_contracts_new_usd[,c(
      
      "ID"                       ,
      "ID_CONTRACT"              ,
      "CAT_CONTRACT_CURRENCY"    ,
      "AMT_CONTRACT_VALUE"       ,
      "STR_CONTRACT_DESCRIPTION" ,
      "DT_CONTRACT_START"        ,
      "YEAR"                     ,
      "EXCHANGE_RATE"

    )]
    
    # ... and we label the columns  
    
    var_label(data_contracts_final$ID                        ) <- "Global unique identifier: tender-level"
    var_label(data_contracts_final$ID_CONTRACT               ) <- "Global unique identifier for each contract"
    var_label(data_contracts_final$CAT_CONTRACT_CURRENCY     ) <- "Currency used for AMT_CONTRACT_VALUE"
    var_label(data_contracts_final$AMT_CONTRACT_VALUE        ) <- "Value of the contract"
    var_label(data_contracts_final$STR_CONTRACT_DESCRIPTION  ) <- "Description of the deliverable"
    var_label(data_contracts_final$DT_CONTRACT_START         ) <- "Date of contract start"
    #var_label(data_contracts_final$CAT_GUARANTEE             ) <- "Description of the deliverable"
    #var_label(data_contracts_final$CAT_GUARANTEE             ) <- "Global unique identifier for each guarantor"
    #var_label(data_contracts_final$NAME_GUARANTOR            ) <- "Date of contract signature"
    
    # We drop all the old datasets that we used and we do not longer need
    
    rm(
      
      data_contracts_new_usd    

    )
    
    # DATA MERGING: document-level ---------------------------------------------------
    
    # We first need to create a new empty column called "ID_CONTRACT" for 
    # data_awa_doc_new and data_document_ten_new
    
    # data_awa_doc_new$ID_CONTRACT      <- NA
    # data_document_ten_new$ID_CONTRACT <- NA
    
    # We can append all three datasets together since they have the same columns
    #data_document_final <- rbind(
      
    #  data_awa_doc_new      ,
    #  data_document_con_new ,
    #  data_document_ten_new
      
    # )
    
    # We drop all the old datasets that we used and we do not longer need
    
    rm(
      
      data_document_con_new ,
      data_sources          ,
      data_awards_new 
      
    )
    
    # Finally, we reorder the columns...  
    
    data_document_final <- data_document_con_new[,c(
      
      "ID"            ,
      "ID_DOC"        ,
      "ID_CONTRACT"   ,
      "CAT_DOC_TITLE" ,
      "URL_DOC"       
      
    )]
    
    # ... and we label the columns 
    
    var_label(data_document_final$ID            ) <- "Global unique identifier: tender-level"
    var_label(data_document_final$ID_CONTRACT   ) <- "Global unique identifier for each contract"
    var_label(data_document_final$ID_DOC        ) <- "Global unique identifier for each document"
    var_label(data_document_final$CAT_DOC_TITLE ) <- "Title of the document"
    # var_label(data_document_final$DT_DOC        ) <- "Date of document publication"
    var_label(data_document_final$URL_DOC       ) <- "Source of the document: url link"
    
    
    
    
    
    
    
    
    
    

# SAVING ----------------------------------------------------------------------
    
    # Check whether there is the folder, if there is not we create one 
    
    if (file.exists(file.path(final))) { # if the path with the new folder already exists, then nothing happens 
      
      cat("The folder already exists: ")
      
    } else { # otherwise, we create a new path with the folder
      
      dir.create(file.path(final))
    }
    
    # Save data at the tender-level
    saveRDS(
      data_tender_final, 
      file.path(final, "DATA_TENDERS.RDS")
    )
    
    # Save data at the participant-level
    
    saveRDS(
      data_participants_final, 
      file.path(final, "DATA_PARTICIPANTS.RDS")
    )
    
    # Save data at the Item-level
    saveRDS(
      data_item_final, 
      file.path(final, "DATA_ITEMS.RDS")
    )
    
    # Save data at the document-level
    saveRDS(
      data_document_final, 
      file.path(final, "DATA_DOCUMENTS.RDS")
    )
    
    # Save data at the tender-level
    saveRDS(
      data_contracts_final, 
      file.path(final, "DATA_CONTRACTS.RDS")
    )    
    
