# ---------------------------------------------------------------------------- #
#                                                                              #
#               FY23 MDTF - Emergency Response Procurement - Honduras          #
#                                                                              # 
#                                  CONSTRUCT                                   #
#                                                                              #
#        Author: Hao Lyu (RA - DIME3)            Last Update: Oct 20 2022      #
#                                                                              #
# ---------------------------------------------------------------------------- #

# **************************************************************************** #
#                                                                              #
#                                                                              #
# **************************************************************************** #


# Create Aggregate datasets for contracts --------------------------------------
        
      # Merge tender with con_milestone to figure out the time variables 
        con_milestones          <- as.data.frame(fread(file.path(data_covid,"con_milestones.csv"          ))) 
        
        con_milestones          <- clean_names(con_milestones)
        
        con_milestones          <- con_milestones%>%
          dplyr::rename("ID"              = "id",
                        "DT_CON_DELIVERY" = "contracts_0_milestones_0_date_met")%>%
          select(ID, DT_CON_DELIVERY)
        
        tender_contract  <- left_join(data_tenders_agg, con_milestones,
                                      by = "ID")
        
        tender_contract  <- tender_contract[, c("ID",
                                                "CAT_TENDER_METHOD",
                                                "DT_TENDER_PUB",
                                                "DT_TENDER_START",
                                                "DT_TENDER_END", 
                                                "DT_CON_DELIVERY",
                                                "YEAR",
                                                "GROUP")]

        tender_contract$compare <- ifelse(tender_contract$DT_CON_DELIVERY < tender_contract$DT_TENDER_PUB, "FALSE", "YES")
        
        tender_contract <- as.data.table(tender_contract)
        
        d <- tender_contract[, .N, by = c("compare")]
        
        
        # Contract related (tender - buyer - contract - supplier)
        contract_agg            <- left_join(data_contracts_agg, data_documents_agg,
                                             by = c("ID", "ID_CONTRACT"))
        
        
# Check supplier --------------------------------------------------------------
        
      data_participants_agg <- readRDS(file.path(data_agg, "DATA_PARTICIPANTS.RDS"))

    # calculate the number of unique supplier in non-covid, covid, and matches 
      num_supp_covid                <- data_participants_agg%>%
        filter(GROUP == "T" &
                 CAT_PARTY_ROLE != "tenderer")%>%
        mutate(combo = paste0(ID_PARTY, NAME_PARTY))%>%
        summarise(num_id     = n_distinct(ID_PARTY),
                  num_name   = n_distinct(NAME_PARTY),
                  num_combo  = n_distinct(combo))         

      num_supp_noncovid <- data_participants_agg%>%
        filter(GROUP == "C" & 
                 CAT_PARTY_ROLE != "tenderer")%>%
        mutate(combo = paste0(ID_PARTY, NAME_PARTY))%>%
        summarise(num_id     = n_distinct(ID_PARTY),
                  num_name   = n_distinct(NAME_PARTY),
                  num_combo  = n_distinct(combo))  
      
      num_supp_total                <- data_participants_agg%>%
        filter(CAT_PARTY_ROLE != "tenderer")%>%
        mutate(combo = paste0(ID_PARTY, NAME_PARTY))%>%
        summarise(num_id     = n_distinct(ID_PARTY),
                  num_name   = n_distinct(NAME_PARTY),
                  num_combo  = n_distinct(combo))  
      

      num_supp_match_ID <- length(unique(overlap_ID$ID_PARTY))         # 136

      num_supp_match_name <- length(unique(overlap_name$ID_PARTY))     # 121
      
      
    # checking the cases where supplier ID is associated to multiple supplier name (for both)
      
      # delete white space 
      data_participants_agg$ID_PARTY <- gsub(" ", "", data_participants_agg$ID_PARTY)
      

      # only covid portal
      data_participants_agg <- as.data.frame(data_participants_agg)
      
      suppliers <- data_participants_agg%>%
        filter(GROUP == "T")%>%
        filter(CAT_PARTY_ROLE == "supplier" |
                 CAT_PARTY_ROLE == "supplier;tenderer")%>%
        group_by(ID_PARTY)%>%
        dplyr::summarise(NAME_COUNT = n_distinct(NAME_PARTY))%>%
        ungroup()
      
      suppliers <- as.data.table(suppliers)
      
      count <- suppliers[,.N, by = c("NAME_COUNT")]
      
      # only non-covid 
      data_participants_agg <- as.data.frame(data_participants_agg)
      
      suppliers <- data_participants_agg%>%
        filter(GROUP == "C")%>%
        filter(CAT_PARTY_ROLE == "supplier" |
                 CAT_PARTY_ROLE == "supplier;tenderer")%>%
        group_by(ID_PARTY)%>%
        dplyr::summarise(NAME_COUNT = n_distinct(NAME_PARTY))%>%
        ungroup()
      
      suppliers <- as.data.table(suppliers)
      
      count <- suppliers[,.N, by = c("NAME_COUNT")]
      
      # both covid and non-covid
      data_participants_agg <- as.data.frame(data_participants_agg)
      
      suppliers <- data_participants_agg%>%
        filter(CAT_PARTY_ROLE == "supplier" |
                 CAT_PARTY_ROLE == "supplier;tenderer")%>%
        group_by(ID_PARTY)%>%
        dplyr::summarise(NAME_COUNT = n_distinct(NAME_PARTY))%>%
        ungroup()
      
      suppliers <- as.data.table(suppliers)
      
      count     <- suppliers[,.N, by = c("NAME_COUNT")]
      
      suppliers <- suppliers[NAME_COUNT > 1, ,]
      
      
      # mark those ID that supplier ID is associated to multiple supplier name
      data_participants_agg <- data_participants_agg%>%
        mutate(MULTIPLE_NAMES = ifelse(ID_PARTY %in% suppliers$ID_PARTY, suppliers$NAME_COUNT, "NO"))
      
      d <- data_participants_agg%>% filter(MULTIPLE_NAMES != "NO")

      
    
      
      # calculate the number of suppliers ID only contains numbers (covid, double check both)
      
      d <- data_participants_agg[grep("[[:digit:]]", data_participants_agg$ID_PARTY), ]
      
      count_supplier <- data_participants_agg
      
      count_supplier$non_numeric <- grepl("[[:alpha:]]", count_supplier$ID_PARTY)
      
      count_supplier <- count_supplier%>%
        filter(non_numeric == "FALSE")
      
      length(unique(count_supplier$ID_PARTY))  # 3699 pure numeric ID 
      


    # calculate the number of tenderers, suppliers, and tenders and suppliers in non-covid data 
      supp_ten_distribute <- data_participants_agg%>%
        filter(GROUP == "C")%>%
        group_by(CAT_PARTY_ROLE)%>%
        dplyr::summarise(n = n())%>%
        ungroup()
      
      

      
      # merge data_tender_agg and data_participants_agg to check by procurement method 
      tender_participants <- left_join(data_tenders_agg, data_participants_agg, 
                                       by = "ID")

      tender_participants <- as.data.table(tender_participants)
        
      bidder_tender <- tender_participants[, .N, by = list(CAT_TENDER_METHOD, CAT_TENDER_STATUS)]
        
      bidder_tender_bygroup <- tender_participants[, .N, by = list(CAT_TENDER_METHOD, CAT_TENDER_STATUS, GROUP.x)]
      
      bidder_tender_byrole <- tender_participants[, .N, by = list(CAT_TENDER_METHOD, CAT_TENDER_STATUS,  CAT_TENDER_TAG)]
      
      
     
# check procurement method and tenderer ---------------------------------------

  # how many tenderer per tender 

  # how many tenderer by procurement method 

  # check time variable used to construct 
        
        



# construct variables ---------------------------------------------------------

      
      
      
      
      
      
      
      
      
      
      
