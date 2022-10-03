# ---------------------------------------------------------------------------- #
#                                                                              #
#               FY23 MDTF - Emergency Response Procurement - Honduras          #
#                                                                              # 
#                                     MERGE                                    #
#                                                                              #
#        Author: Hao Lyu (RA - DIME3)            Last Update: Sept 30 2022     #
#                                                                              #
# ---------------------------------------------------------------------------- #

# **************************************************************************** #
#       * covid              = covid data                 2020 - 2021          # 
#       * non-covid/old      = data from the 'old' portal 2020 - 2021          #
#                                                                              #
#       1) create variable list to compare                                     #
#       2) check supplier info                                                 #
#       3) check overlap -> decide to merge or append                          #
#       4) merge or append                                                     # 
#       5) get a variable list                                                 #
#                                                                              #
# **************************************************************************** #

# LOAD DATA -------------------------------------------------------------------

data_participants_covid <- readRDS(file.path(final_covid, "DATA_PARTICIPANTS.RDS"))
data_documents_covid    <- readRDS(file.path(final_covid, "DATA_DOCUMENTS.RDS"   ))
data_items_covid        <- readRDS(file.path(final_covid, "DATA_ITEMS.RDS"       ))
data_contracts_covid    <- readRDS(file.path(final_covid, "DATA_CONTRACTS.RDS"   ))
data_tenders_covid      <- readRDS(file.path(final_covid, "DATA_TENDERS.RDS"     ))


data_participants_old   <- readRDS(file.path(final, "DATA_PARTICIPANTS.RDS"))
data_documents_old      <- readRDS(file.path(final, "DATA_DOCUMENTS.RDS"   ))
data_items_old          <- readRDS(file.path(final, "DATA_ITEMS.RDS"       ))
data_contracts_old      <- readRDS(file.path(final, "DATA_CONTRACTS.RDS"   ))
data_tenders_old        <- readRDS(file.path(final, "DATA_TENDERS.RDS"     ))


# DATA PARTICIPANTS -----------------------------------------------------------

      # Covid:  "ID"             "ID_PARTY"       "NAME_PARTY"     "EMAIL"          "TELEPHONE"     
      #         "CAT_PARTY_ROLE"

      # Old:    "ID"             "ID_PARTY"       "NAME_PARTY"     "EMAIL"          "TELEPHONE"     
      #         "CAT_PARTY_ROLE" "SUB_SAMPLE" 

      # check overlap on tender ID
        overlap <- data_participants_old %>% filter(data_participants_old$ID %in% data_participants_covid$ID)
        
        if (nrow(overlap) == 0) {
          
          cat("No Overlap. Please Go Ahead to Append!")
          
          } else {
            
            cat("Overlap. Please Go Ahead to Merge!")
            
            }

            # No Overlap, Append! 

         rm(overlap)


      # check matches of suppliers 
            
          # first check whether the supplier IDs in the covid portal match with the supplier IDs in the "old" portal
          overlap_ID <- data_participants_covid %>% filter(data_participants_covid$ID_PARTY %in% data_participants_old$ID_PARTY)

          overlap_ID <- overlap_ID%>% 
            left_join(data_participants_old, by = "ID_PARTY", suffix = c("", "_OLD"))%>%
            distinct()%>%
            select(-c("EMAIL", "TELEPHONE", "EMAIL_OLD", "TELEPHONE_OLD"))
          
            # Note: the old data has both tenderers and suppliers, but the covid data only contains supplier. 
            #       there are firms participated in both during COVID and before COVID 
          
          # Second check whether the supplier names in the covid portal match with the supplier names in the "old" portal
          
          data_participants_covid$NAME_PARTY <- tolower(data_participants_covid$NAME_PARTY)
          data_participants_old$NAME_PARTY   <- tolower(data_participants_old$NAME_PARTY)
          
          overlap_name <- data_participants_covid %>% filter(data_participants_covid$NAME_PARTY %in% data_participants_old$NAME_PARTY)
          
          overlap_name <- overlap_name%>% 
            left_join(data_participants_old, by = "NAME_PARTY", suffix = c("", "_OLD"))%>%
            distinct()%>%
            select(-c("EMAIL", "TELEPHONE", "EMAIL_OLD", "TELEPHONE_OLD"))
            
          overlap_name <- overlap_name[!(overlap_name$ID_PARTY %in% overlap_ID$ID_PARTY), ]
          
          overlap <- nrow(overlap_name%>%filter(overlap_name$ID_PARTY %in% overlap_ID$ID_PARTY))
          
          if(overlap == 0){
            cat("No overlap between matching suppliers by ID and matching suppliers by name.")
          } else{
            cat("Overlap between matching suppliers by ID and matching suppliers by name.")
          }
          
          rm(overlap)
      
      # arrange columns and sort observations to group
          data_participants_covid <- data_participants_covid%>% 
            mutate("SUB_SAMPLE" = 0,
                   "GROUP"      = "T")
          
          data_participants_old   <- data_participants_old%>%
            mutate("GROUP"      = "C")
      
      # append  
          data_participants_agg <- rbind(data_participants_old, data_participants_covid)

      
      # calculate the number of unique supplier in non-covid, covid, and matches 
          num_supp_covid <- data_participants_agg%>%
            filter(GROUP == "T")%>%
            summarise(num_supp_covid = n_distinct(ID_PARTY))               # 12431
          num_supp_covid <- as.numeric(num_supp_covid)
          print(paste0("Number of Suppliers in COVID Data = ", num_supp_covid))
          
          
          num_supp_non_covid <- data_participants_agg%>%
            filter(GROUP == "C" & 
                     CAT_PARTY_ROLE != "tenderer")%>%
            summarise(num_supp_non_covid = n_distinct(ID_PARTY))           # 3113
          num_supp_non_covid <- as.numeric(num_supp_non_covid)
          print(paste0("Number of Suppliers in Non-Covid Data = ", num_supp_non_covid))
          
        
          num_supp_match_ID <- length(unique(overlap_ID$ID_PARTY))         # 136
          print(paste0("Number of Suppliers Matched by ID = ", num_supp_match_ID))
          
          num_supp_match_name <- length(unique(overlap_name$ID_PARTY))     # 121
          print(paste0("Number of Suppliers Matched by Name = ", num_supp_match_name))
          
          
          
      # calculate the number of tenderers, suppliers, and tenders and suppliers in non-covid data 
          supp_ten_distribute <- data_participants_agg%>%
            filter(GROUP == "C")%>%
            group_by(CAT_PARTY_ROLE)%>%
            dplyr::summarise(n = n())%>%
            ungroup()
          
          
      # delete un-necessary data 
          rm(
            
            data_participants_covid        ,
            data_participants_old          ,
            data_participants_final        ,
            num_supp_covid                 ,
            num_supp_non_covid             , 
            overlap_ID                     ,
            overlap_name                   ,
            supp_ten_distribute
          )

# DATA DOCUMENTS --------------------------------------------------------------
         
        # COVID: "ID"            "ID_DOC"        "ID_CONTRACT"   "CAT_DOC_TITLE"                 "URL_DOC" 
        # OLD:   "ID"            "ID_DOC"        "ID_CONTRACT"   "CAT_DOC_TITLE" "DT_DOC"        "URL_DOC"    

    
      # arrange columns
          data_documents_covid <- data_documents_covid%>%
            mutate(DT_DOC       = "")
        
          data_documents_covid <- data_documents_covid[, c(
            "ID"            ,
            "ID_DOC"        ,
            "ID_CONTRACT"   ,
            "CAT_DOC_TITLE" ,
            "DT_DOC"        ,
            "URL_DOC"
          )]
          
      # sort observations to groups
          data_documents_covid <- data_documents_covid%>% 
            mutate("GROUP"      = "T")
          
          data_documents_old   <- data_documents_old%>%
            mutate("GROUP"      = "C")
          
      # append 
          data_documents_agg <- rbind(data_documents_old, data_documents_covid)
          
      # delete unnecessary data 
          rm(
            
            data_document_final,
            data_documents_covid, 
            data_documents_old
          )
          
          
          
# DATA ITEM ------------------------------------------------------------------- 
          
          # COVID:      "ID"                "ID_ITEM"           "STR_DESCRIPTION"   "ITEM_MEASURE_UNIT"
          #             "AMT_ITEM"          "ITEM_AMOUNT"      
          # Non-COVID:  "ID"                   "ID_ITEM"              "ID_ITEM_UNSPSC"       "STR_ITEM_DESCRIPTION"
          #             "ITEM_MEASURE_UNIT"    "AMT_ITEM"             "PRICE_UNIT_ITEM"      "TYPE_GOOD_SERVICE"   
          #             "SUB_SAMPLE" 
          
       #  arrange columns 
          data_items_covid <- data_items_covid%>%
            dplyr::rename(PRICE_UNIT_ITEM      = ITEM_AMOUNT,
                          STR_ITEM_DESCRIPTION =  STR_DESCRIPTION)%>%
            mutate(ID_ITEM_UNSPSC    = "", 
                   TYPE_GOOD_SERVICE = "",   
                   SUB_SAMPLE        = "",
                   )

          data_items_covid <- data_items_covid[,c(
            
                      "ID"                   ,
                      "ID_ITEM"              ,
                      "ID_ITEM_UNSPSC"       ,
                      "STR_ITEM_DESCRIPTION" ,
                      "ITEM_MEASURE_UNIT"    ,
                      "AMT_ITEM"             ,
                      "PRICE_UNIT_ITEM"      ,
                      "TYPE_GOOD_SERVICE"    ,
                      "SUB_SAMPLE" 
          )]
          
        # sort observations to groups 
          data_items_covid <- data_items_covid%>% 
            mutate("GROUP"      = "T")
          
          data_items_old   <- data_items_old%>%
            mutate("GROUP"      = "C")
          
        # append 
          data_item_agg <- rbind(data_items_old, data_items_covid)
          
        # delete unnecessary data 
          rm(
            
            data_item_final     ,
            data_items_covid    ,
            data_items_old
            
          )
          
# DATA CONTRACTS -------------------------------------------------------------
          
          # COVID     : "ID"                       "ID_CONTRACT"              "CAT_CONTRACT_CURRENCY"   
          #             "AMT_CONTRACT_VALUE"       "STR_CONTRACT_DESCRIPTION" "DT_CONTRACT_START"       
          #             "YEAR"                     "EXCHANGE_RATE"  
          # Non-COVID:  "ID"                       "ID_CONTRACT"              "CAT_CONTRACT_CURRENCY"   
          #             "AMT_CONTRACT_VALUE"       "STR_CONTRACT_DESCRIPTION" "DT_CONTRACT_SIGNED"      
          #             "CAT_GUARANTEE"            "ID_GUARANTOR"             "NAME_GUARANTOR"          
          #             "SUB_SAMPLE"    
          
          
          # arrange columns 
          
          data_contracts_covid <- data_contracts_covid%>%
            select(-c("DT_CONTRACT_START" ,       
                      "YEAR"              ,               
                      "EXCHANGE_RATE"  ))%>%
            mutate(DT_CONTRACT_SIGNED = "", 
                   CAT_GUARANTEE      = "",           
                   ID_GUARANTOR       = "",             
                   NAME_GUARANTOR     = "",          
                   SUB_SAMPLE         = "")
          
          data_contracts_covid <- data_contracts_covid[, c(
            
                     "ID"                       ,
                     "ID_CONTRACT"              ,
                     "CAT_CONTRACT_CURRENCY"    ,
                     "AMT_CONTRACT_VALUE"       ,
                     "STR_CONTRACT_DESCRIPTION" ,
                     "DT_CONTRACT_SIGNED"       ,
                     "CAT_GUARANTEE"            ,
                     "ID_GUARANTOR"             ,
                     "NAME_GUARANTOR"           ,
                     "SUB_SAMPLE"         
                     
          )]
          
          # sort observations to groups
          data_contracts_covid <- data_contracts_covid%>% 
            mutate("GROUP"      = "T")
          
          data_contracts_old   <- data_contracts_old%>%
            mutate("GROUP"      = "C")
          
          # append 
          data_contracts_agg <- rbind(data_contracts_old, data_contracts_covid)
          
          # delete unnecessary data 
          rm(
            
            data_contracts_old,
            data_contracts_covid,
            data_contracts_final
            
          )

# DATA TENDER -----------------------------------------------------------------
          
        # COVID:     "ID"                       "CAT_TENDER_METHOD_DETAIL" "CAT_TENDER_TAG"          
        #            "STR_TENDER_DESCRIPTION"   "DT_TENDER_PUB"            "ID_BUYER"                
        #            "NAME_BUYER"               "ID_BUYER_MEMBEROF"       
        # non-COVID:  "ID"                       "CAT_TENDER_METHOD"        "CAT_TENDER_METHOD_DETAIL"
        #             "CAT_TENDER_STATUS"        "CAT_TENDER_STATUS_DETAIL" "CAT_TENDER_TAG"          
        #             "CAT_TENDER_LEGAL_DESC"    "STR_TENDER_DESCRIPTION"   "DT_TENDER_PUB"           
        #             "DT_TENDER_START"          "DT_TENDER_END"            "AMT_PARTICIPATION_FEE"   
        #             "ID_BUYER"                 "NAME_BUYER"               "ID_BUYER_MEMBEROF"       
        #             "NAME_BUYER_MEMBEROF"      "NAME_SOURCE_1"            "CAT_SOURCE_1"            
        #             "NAME_SOURCE_2"            "CAT_SOURCE_2"             "SUB_SAMPLE"              
        #             "YEAR"  
          
        # arrange columns 
          
          data_tenders_covid <- data_tenders_covid%>%
            mutate( 
                      CAT_TENDER_METHOD        = "",
                      CAT_TENDER_STATUS        = "",
                      CAT_TENDER_STATUS_DETAIL = "",
                      CAT_TENDER_LEGAL_DESC    = "",
                      DT_TENDER_START          = "",        
                      DT_TENDER_END            = "",           
                      AMT_PARTICIPATION_FEE    = "", 
                      NAME_BUYER_MEMBEROF      = "",
                      NAME_SOURCE_1            = "",
                      CAT_SOURCE_1             = "",
                      NAME_SOURCE_2            = "",
                      CAT_SOURCE_2             = "",             
                      SUB_SAMPLE               = "",             
                      YEAR                     = "" 
                      
                      )
          
          data_tenders_covid <- data_tenders_covid[, c(
                       
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
                             "CAT_SOURCE_2"             ,
                             "SUB_SAMPLE"               ,
                             "YEAR" 
          )]
          
          # sort observations to groups
          data_tenders_covid <- data_tenders_covid%>% 
            mutate("GROUP"      = "T")
          
          data_tenders_old   <- data_tenders_old%>%
            mutate("GROUP"      = "C")
          
          # append 
          data_tenders_agg <- rbind(data_tenders_old, data_tenders_covid)
          
          # delete unnecessary data 
          rm(
            
            data_tender_final,
            data_tenders_covid, 
            data_tenders_old
          )
          
          
# SAVE DATA ------------------------------------------------------------------
          

          # Check whether there is the folder, if there is not we create one 
          
          if (file.exists(file.path(data_agg))) { # if the path with the new folder already exists, then nothing happens 
            
            cat("Saving Aggregate Data now ... ...")
            
          } else { # otherwise, we create a new path with the folder
            
            dir.create(file.path(data_agg))
          }
          
          # Save data at the tender-level
          saveRDS(
            data_tenders_agg, 
            file.path(data_agg, "DATA_TENDERS.RDS")
          )
          
          # Save data at the participant-level
          
          saveRDS(
            data_participants_agg, 
            file.path(data_agg, "DATA_PARTICIPANTS.RDS")
          )
          
          # Save data at the Item-level
          saveRDS(
            data_item_agg, 
            file.path(data_agg, "DATA_ITEMS.RDS")
          )
          
          # Save data at the document-level
          saveRDS(
            data_documents_agg, 
            file.path(data_agg, "DATA_DOCUMENTS.RDS")
          )
          
          # Save data at the tender-level
          saveRDS(
            data_contracts_agg, 
            file.path(data_agg, "DATA_CONTRACTS.RDS")
          )    
          
          
          if (file.exists(file.path(data_agg, "DATA_CONTRACTS.RDS"))) { # if the path with the new folder already exists, then nothing happens 
            
            cat("Aggregate Data Saved! Enjoy your data :)")
            
          } else { # otherwise, we create a new path with the folder to save the files again
            
            dir.create(file.path(data_agg))
          }
          
          
          
          
          