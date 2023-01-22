# ------------------------------------------------------------------------------ #
#                           HONDURAS DATA WORK PUBLIC PROCUREMENT                #
#                                       World Bank                               #
#                                    April - 2022                                #
#                                                                                #
# ------------------------------------------------------------------------------ #
# --------------------------------------- #
#     Authors: Doino Ruggero (RA - DIME)  #                                       
# --------------------------------------- #

# ****************************************************************************** #
# This code is meant to clean all the datasets and merge them down to 5 main     #
# datasets: participant-level, contract-level, document-level, tender-level and  #
# item-level.                                                                    #
# ****************************************************************************** #
# April 04 2022

# ------------------------------------------------------------------------------- #
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# ******************************************************************************* #

# ------------------------------------------------------------------------------- #
# ++++++++++++++++++++++++ TABLE OF CONTENTS ++++++++++++++++++++++++++++++++++++ #
#                                                                                 #
#        1) LOAD DATA    : load data.                                             #
#        2) DATA CLEANING: clean the data, changing names and labels.             #  
#        3) MERGING      : merge down to 5 levels.                                #
#        7) SAVING       : save the datasets.                                     #
#                                                                                 #
# ******************************************************************************* #

# LOAD DATA -----------------------------------------------------------------------

# Load data

# load the contract data
data_releases      <- as.data.frame(fread(file.path(Data,"DCC_releases.csv"             )))
# load the parties data
data_parties       <- as.data.frame(fread(file.path(Data,"DCC_parties.csv"               ))) 
# load the department data
data_par_member    <- as.data.frame(fread(file.path(Data,"DCC_par_memberof.csv"          ))) 
# load the items data
data_ten_items     <- as.data.frame(fread(file.path(Data,"DCC_ten_items.csv"             ))) 
# load the fees data
data_ten_fees      <- as.data.frame(fread(file.path(Data,"DCC_ten_participationfees.csv" ))) 
# load the doc awacsv data
data_awa_doc       <- as.data.frame(fread(file.path(Data,"DCC_awa_documents.csv"         ))) 
# load the contract-guarantees data
data_garantees_con <- as.data.frame(fread(file.path(Data,"DCC_con_guarantees.csv"        ))) 
# load the documents contract data
data_document_con  <- as.data.frame(fread(file.path(Data,"DCC_con_documents.csv"         ))) 
# load the budget data
data_plan_budget   <- as.data.frame(fread(file.path(Data,"DCC_pla_bud_budgetbreakdown.csv"))) 
# load the contract data
data_contracts     <- as.data.frame(fread(file.path(Data,"DCC_contracts.csv"             ))) 
# load the supplier contract data
data_suppliers_con <- as.data.frame(fread(file.path(Data,"DCC_con_suppliers.csv"         ))) 
# load the tender document data
data_document_ten  <- as.data.frame(fread(file.path(Data,"DCC_ten_documents.csv"         ))) 
# load the tender document data
data_awa_items     <- as.data.frame(fread(file.path(Data,"DCC_awa_items.csv"             ))) 
# load the tender document data
data_sources       <- as.data.frame(fread(file.path(Data,"DCC_sources.csv"               ))) 
# load the tender document data
data_awa_suppliers <- as.data.frame(fread(file.path(Data,"DCC_awa_suppliers.csv"         ))) 
# load the tender document data
data_awards        <- as.data.frame(fread(file.path(Data,"DCC_awards.csv"                ), encoding = "Latin-1", colClasses = "character")) 
# load the tender document data
data_ten_tenderers <- as.data.frame(fread(file.path(Data,"DCC_ten_tenderers.csv"         ))) 
# load data un
data_unspsc       <- read_xlsx(file.path(data,"unspsc.xlsx"), sheet = 1)


########################
#### DATA CLEANING #####
########################

# contract_participants -----------------------------------------------------


contract_participants <- left_join(data_contracts, data_parties, 
                                   by = "ocid",
                                   suffix = c("", "_y"))

contract_participants <- clean_names(contract_participants)

contract_participants <- contract_participants%>%
  filter(parties_0_roles != "funder")

# DATA RELEASES ----------------------------------------------------------------



# Here, we start doing some general data cleaning for data_releases

drop <- c( # List of variables we want to drop from the main dataset
  
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
  "tender/datePublished"                   ,
  "language"                               ,
  "publisher/name"                         ,
  "tender/id"                              ,
  "tender/legalBasis/scheme"
  
)

# we drop the list of vars
data_releases_new <- data_releases[,!colnames(data_releases) %in% drop] 

# Here, we create the new two variables
data_releases_new <- data_releases_new %>% 
  mutate(
    
    # we extract the date from the main variable
    DT_TENDER_START = as.Date(substr(`tender/enquiryPeriod/startDate`,
                                     0,
                                     10)),
    
    # we extract the date from the main variable
    DT_TENDER_END = as.Date(substr(`tender/enquiryPeriod/endDate`,
                                   0,
                                   10))
    
  )


# Here, we drop the old variable 
drop <- c( # List of old vars we want to drop from the main dataset
  
  "tender/enquiryPeriod/endDate",
  "tender/enquiryPeriod/startDate"
  
)

# Here, we create the new two variables
data_releases_new <- data_releases_new %>% 
  mutate(
    
    # we extract the date from the main variable
    DT_TENDER_PUB = as.Date(substr(date,0,10))
    
  )


# Here, we drop the old variable 
drop <- c( # List of old vars we want to drop from the main dataset
  
  "date"
  
)

# we drop the list of vars
data_releases_new <- data_releases_new[,!colnames(data_releases_new) %in% drop] 

# we drop the list of vars
data_releases_new <- data_releases_new[,!colnames(data_releases_new) %in% drop] 

# Here, we rename all the variables
data_releases_new <- data_releases_new %>% 
  
  dplyr::rename(
    
    ID               = `id`                              ,
    ID_PARTY                 = `buyer/id`                        ,
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

# DATA PARTIES & DATA PAR MEMBER OF --------------------------------------------

# Here, we start doing some general data cleaning for data_parties

drop <- c( # List of variables we want to drop from the dataset
  
  "ocid"                               ,
  "parties/0/contactPoint/faxNumber"   ,
  "parties/0/identifier/id"            ,
  "parties/0/address/streetAddress"    ,
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
    URL                      = `parties/0/contactPoint/url`      ,
    TELEPHONE                = `parties/0/contactPoint/telephone`,
    REGION                   = `parties/0/address/region`        ,
    ADDRESS                  = `parties/0/address/locality`         
    
  )

# We drop the old dataset 
rm(data_parties)

# Here, we start doing some general data cleaning for data_par_member

drop <- c( # List of variables we want to drop from the dataset
  
  "ocid"                   ,
  "id"                     ,
  "parties/0/id"
  
)

# we drop the list of vars
data_par_member_new <- data_par_member[,!colnames(data_par_member) %in% drop] 

# Here, we rename all the variables
data_par_member_new <- data_par_member_new %>% 
  
  dplyr::rename(
    
    ID_PARTY_MEMBEROF              = `parties/0/memberOf/0/id`        ,
    NAME_PARTY_MEMBEROF            = `parties/0/memberOf/0/name`    
    
  )

# We drop the old dataset 

rm(data_par_member)

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

# Merge the dataset with all the parties with the name of the departments 
# (only for buyers)
data_parties_merged <- left_join(data_parties_new, 
                                 data_par_member_new %>% distinct(), by = "ID_PARTY_MEMBEROF")

# We remove the two datasets that have been merged together
rm(data_par_member_new, data_parties_new)

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

data_unspsc        <- data_unspsc         %>% 
  mutate(MERGE = substr(Segment, 0, 2))

data_ten_items_new <- left_join(data_ten_items_new, data_unspsc, by = "MERGE")  


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

# DATA CONTRACTS ---------------------------------------------------------------

# Here, we start doing some general data cleaning for data_contracts

drop <- c( # List of variables we want to drop from the dataset
  
  "ocid"                                 ,
  "contracts/0/title"                    ,
  "contracts/0/buyer/id"                 ,
  "contracts/0/buyer/name"               ,
  "contracts/0/localProcurementCategory" 
  
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

# Here, we create the new two variables
data_contracts_new <- data_contracts_new %>% 
  mutate(
    
    # we extract the date from the main variable
    DT_CONTRACT_SIGNED = as.Date(substr(`contracts/0/dateSigned`,
                                        0,
                                        10)),
    
    AMT_CONTRACT_VALUE = ifelse(AMT_CONTRACT_VALUE <= 0, NA, AMT_CONTRACT_VALUE)
    
  )

data_contracts_new <- data_contracts_new %>% 
  
  mutate(
    DT_CONTRACT_SIGNED = dplyr::if_else(substr(data_contracts_new$DT_CONTRACT_SIGNED, 0, 4) == "2049" | substr(data_contracts_new$DT_CONTRACT_SIGNED, 0, 4) == "2219",
                                        paste0("2019", substr(data_contracts_new$DT_CONTRACT_SIGNED, 5, 12)), 
                                        as.character(data_contracts_new$DT_CONTRACT_SIGNED)
    )
  )
# 4) We study the distribution of contract values
# First, we need to convert all the values in USD so that it is easier to understand the distribution
# To do so, we use the average currency conversion rate provided by the WDI package
currency_matrix <- WDI(
  
  country   = "HN"                              ,
  indicator = c("exchange_rate" = "PA.NUS.FCRF"),
  start     = 2005                              ,
  end       = 2019             
)

data_contracts_new_usd <- data_contracts_new %>% 
  
  mutate(YEAR = as.numeric(substr(DT_CONTRACT_SIGNED, 0, 4))) 
currency_matrix <- currency_matrix[,c(3,4)]
colnames(currency_matrix) <- c("EXCHANGE_RATE", "YEAR")
data_contracts_new_usd <- left_join(data_contracts_new_usd, currency_matrix, by = "YEAR")

data_contracts_new_usd <- data_contracts_new_usd %>% 
  mutate(AMT_CONTRACT_VALUE    = AMT_CONTRACT_VALUE/EXCHANGE_RATE) %>% 
  mutate(CAT_CONTRACT_CURRENCY = "USD")

drop <- c( # List of variables we want to drop from the dataset
  
  "contracts/0/dateSigned" 
  
)

# we drop the list of vars
data_contracts_new_usd <- data_contracts_new_usd[,!colnames(data_contracts_new_usd) 
                                     %in% drop] 

# We drop the old dataset 
rm(data_contracts, data_contracts_new)

# Here, we start doing some general data cleaning for data_garantees_con

drop <- c( # List of variables we want to drop from the dataset
  
  "ocid"                                  ,
  "contracts/0/guarantees/0/guarantor/id" 
  
)

# we drop the list of vars
data_garantees_con_new <- data_garantees_con[,!colnames(data_garantees_con) 
                                             %in% drop] 


# Here, we rename all the variables
data_garantees_con_new <- data_garantees_con_new %>% 
  
  dplyr::rename(
    
    ID                     = `id`                                      ,
    ID_CONTRACT            = `contracts/0/id`                          , 
    CAT_GUARANTEE          = `contracts/0/guarantees/0/type`           ,
    NAME_GUARANTOR         = `contracts/0/guarantees/0/guarantor/name` ,
    ID_GUARANTOR           = `contracts/0/guarantees/0/id`          
    
  )

# We drop the old dataset 
rm(data_garantees_con)

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

##################
#### SAVING ######
##################

########################
#### SUB_SAMPLING ######
########################

# First, we sub-sample observations from 2001 to 2019 --------------------------

data_tenders_sub <- data_tender_final %>%
  
  filter(substr(DT_TENDER_START, 0, 4) %in% seq(2011, 2019))   %>% 
  mutate(YEAR = as.numeric(substr(DT_TENDER_START, 0, 4))) 


# Secondly, we sub-sample observations that have been awarded ------------------
# wtih or without contracts 

data_tenders_sub_win <- data_tenders_sub %>%
  
  filter(CAT_TENDER_TAG == "tender;award;contract" | CAT_TENDER_TAG == "tender;award") # We select only tenders that have been awarded with or without contract


# Third, we sub-sample observations that have a corresponding supplier ---------

# drop all the tenders that do not have a supplier/winner
list_sup_win <- data_participants_final %>% # we create a list of IDs with suppliers 
  
  filter(CAT_PARTY_ROLE == "supplier;tenderer" | CAT_PARTY_ROLE == "supplier") %>% 
  distinct(ID)

# Subsamping DATA TENDERS ------------------------------------------------------
data_tenders_sub_win_full <- data_tenders_sub_win %>%
  
  filter(ID %in% list_sup_win$ID)

# Subsamping DATA CONTRACTS ----------------------------------------------------

data_contracts_sub <- data_contracts_final %>% 
  
  filter(ID %in% data_tenders_sub_win_full$ID)

# Subsamping DATA ITEMS --------------------------------------------------------

data_items_sub <- data_item_final %>% 
  
  filter(ID %in% data_tenders_sub_win_full$ID) 

# Subsamping DATA PARTICIPANTS -------------------------------------------------

data_participants_sub_tenders <- data_participants_final %>% 
  select(-c("CAT_PARTY_ROLE"))                           %>% 
  filter(ID %in% data_tenders_sub_win_full$ID)           

data_participants_sub <- data_participants_sub_tenders %>% 
  select(-c("ID"))                                     %>%  
  distinct()

data_participants_sub[data_participants_sub == "NA"] <- ""
data_participants_sub <- as.data.table(data_participants_sub)
data_participants_sub <- data_participants_sub[,lapply(.SD, function(x) paste(x,collapse=";")), by=ID_PARTY]
data_participants_sub <- data_participants_sub[,lapply(.SD, function(x) gsub("\\;.*","",x))]

# Subsamping DATA PARTICIPANTS -------------------------------------------------

data_document_sub <- data_document_final %>% 
  
  filter(ID %in% data_tenders_sub_win_full$ID) 

# 

data_tender_final <- data_tender_final %>% 
  mutate(SUB_SAMPLE = ifelse(ID %in% data_tenders_sub_win_full$ID, 1, 0)) %>% 
  mutate(YEAR = substr(DT_TENDER_PUB, 0, 4)) 

data_participants_final <- data_participants_final %>% 
  mutate(SUB_SAMPLE = ifelse(ID %in% data_tenders_sub_win_full$ID, 
                             ifelse(CAT_PARTY_ROLE == "supplier" | CAT_PARTY_ROLE == "supplier;tenderer", 1, 0), 0))

data_item_final <- data_item_final %>% 
  mutate(SUB_SAMPLE = ifelse(ID %in% data_tenders_sub_win_full$ID, 1, 0))

data_contracts_final <- data_contracts_final %>% 
  mutate(SUB_SAMPLE = ifelse(ID %in% data_tenders_sub_win_full$ID, 1, 0))

##################
#### SAVING ######
##################

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