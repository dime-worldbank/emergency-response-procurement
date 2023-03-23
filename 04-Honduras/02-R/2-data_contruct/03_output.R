# ---------------------------------------------------------------------------- #
#                                                                              #
#               FY23 MDTF - Emergency Response Procurement - Honduras          #
#                                                                              # 
#                             Construct Variables                              #
#                                                                              #
#        Author: Hao Lyu (RA - DIME3)            Last Update:  Jan 1/18 2023   #
#                                                                              #
# ---------------------------------------------------------------------------- #

# **************************************************************************** #
#       This script aims to clean Honduras data downloaded from the standard
#       portal         
#                                                                              ##                                                                              
# **************************************************************************** #

# Procurement Data Structure: 
#       tender - buyer - contract 
#       tender - buyer - suppliers 


# LOAD DATA -------------------------------------------------------------------

# aggregated data from 2018 to 2021
data_participants_final   <- as.data.frame(fread(file.path(intermediate, "Data_Participants_Final.csv")))
data_items_final          <- as.data.frame(fread(file.path(intermediate, "Data_Items_Final.csv")))
data_contracts_final      <- as.data.frame(fread(file.path(intermediate, "Data_Contracts_Final.csv")))
data_tenders_final        <- as.data.frame(fread(file.path(intermediate, "Data_Tenders_Final.csv")))

# intermediate datasets obtained after data cleaning 
# contract level 
tender_contract       <- as.data.frame(fread(file.path(intermediate,"Contract_Tender.csv"))) # 2018 - 2022

contract_supplier     <- as.data.frame(fread(file.path(intermediate,"Contract_Supplier.csv")))

# item level 
tender_item           <- as.data.frame(fread(file.path(intermediate,"Tender_Item.csv"))) # add contract signature date  

supplier_item         <- as.data.frame(fread(file.path(intermediate,"Supplier_Item.csv"))) # add contract signature date 

# participant level 
data_parties_merged   <- as.data.frame(fread(file.path(intermediate,"Data_Parties_Merged.csv"))) 

# UNSPSC 
data_unspsc_commodity       <- read_xlsx(file.path(raw_data,"unspsc.xlsx"), sheet = 5)

data_unspsc_class           <- read_xlsx(file.path(raw_data,"unspsc.xlsx"), sheet = 4)

data_unspsc_family          <- read_xlsx(file.path(raw_data,"unspsc.xlsx"), sheet = 3)

# administrative divisions 
municipality                <- read_xlsx(file.path(raw_data,"Honduras_admin.xlsx"))


# 0.0 filter out outliers that have the top 1% contract values and appear as mistake 

# tender_contract$outliers <- ifelse(tender_contract$AMT_CONTRACT_VALUE > quantile(tender_contract$AMT_CONTRACT_VALUE, probs = 0.99, na.rm = T),
#                                    "FLAG", NA)
# # selected 138 observations
# outlier_detail <- tender_contract%>%filter(outliers == "FLAG")
# 
# # this seems too many. Thus, we find another way, plot a boxplot 
# # boxplot(tender_contract$AMT_CONTRACT_VALUE_USD,  ylab = "Contract Value (USD)", na.rm = TRUE)
# # need confirmation
# 
# outlier <- tender_contract%>%
#   filter(outliers == "FLAG")
# 
# fwrite(outlier, file = paste0(cleaned, "/Outlier.CSV"))
# 
# outlier <- outlier %>%
#   select(ID, ID_CONTRACT)

# step 1 check tender value 

# by item * value 
# fix exchange rate 
currency_matrix <- WDI(
  
  country   = "HN"                              ,
  indicator = "PA.NUS.FCRF"                     ,
  start     = 2015                              ,
  end       = 2023             
)

currency_matrix <- as.data.frame(currency_matrix[,c(4,5)])

colnames(currency_matrix) <- c("year", "EXCHANGE_RATE")

tender_item_usd <- left_join(tender_item, currency_matrix, by = "year")

tender_item_usd <- tender_item_usd %>% 
  mutate(PRICE_UNIT_ITEM_USD    = PRICE_UNIT_ITEM/EXCHANGE_RATE) %>% 
  mutate(CAT_CONTRACT_CURRENCY = "USD")

tender_item_usd$PRICE_UNIT_ITEM_USD <- as.numeric(formatC(tender_item_usd$PRICE_UNIT_ITEM_USD, 
                                                          digits = 2, format = "f"))


item_amount_value <- tender_item_usd%>%
  mutate(price_per_item = AMT_ITEM * PRICE_UNIT_ITEM_USD)%>%
  group_by(ID)%>%
  dplyr::summarise(tender_value = sum(price_per_item, na.rm = TRUE))%>%
  ungroup()


# by contract value 
contract_value <- tender_contract%>%
  group_by(ID)%>%
  dplyr::summarise(tender_value = sum(AMT_CONTRACT_VALUE, na.rm = TRUE))%>%
  ungroup()

# compare 
tender_value_compare <- contract_value%>%
  left_join(item_amount_value, by = "ID", suffix = c("_by_contract", "_by_item"))
# most of the values seems match 

tender_value_compare$match <- tender_value_compare$tender_value_by_contract/tender_value_compare$tender_value_by_item

tender_value_compare$not_match <- ifelse(tender_value_compare$match >= 1.5 | tender_value_compare$match <= 0.5 & tender_value_compare$match > 0, "Y", "N")

list_not_match <- tender_value_compare%>%
  filter_all(all_vars(!is.infinite(.)))%>%
  filter(not_match == "Y")

# filter out 1801 not match observations 
list_not_match


# step 2 check num of items per unspsc (items value -> tender value)
item_unspsc <- tender_item_usd%>%
  group_by(ID_ITEM_UNSPSC)%>%
  dplyr::summarise(num_item = n_distinct(ID_ITEM))%>%
  ungroup()
# the unspsc with the largest number of items is 25191513

# step 3 flag quantiles and rank by quantiles 
tender_unspsc <- tender_item_usd%>%
  filter(ID_ITEM_UNSPSC == "25191513")%>%
  mutate(price_per_item = AMT_ITEM * PRICE_UNIT_ITEM_USD)%>%
  group_by(ID)%>%
  dplyr::summarise(tender_value = sum(price_per_item))%>%
  ungroup()

quantile(tender_unspsc$tender_value, probs = c(0.75, 0.8, 0.85, 0.9, 0.95, 1), na.rm = TRUE)

#    75%      80%      85%      90%      95%        100% 
#  603.115  724.672  962.230  1341.068  2072.598  10509.330  


# step 4 trail & errors 

# double the amount of 95%  - suggest using this one 
tender_unspsc_outlier <-   tender_unspsc%>%
  filter(tender_value > 2 * as.vector(
    quantile(tender_unspsc$tender_value, probs = 0.95, na.rm = TRUE)
  )
  )
# filter out 22 obs

# trippled amount of the 95% 
tender_unspsc_outlier <-   tender_unspsc%>%
  filter(tender_value > 8446.2)
# filter out 5 obs 

# step 5 apply this method to the whole sample 
tender_unspsc <- tender_item_usd%>%
  group_by(ID, ID_ITEM_UNSPSC)%>%
  dplyr::summarise(tender_value = sum(PRICE_UNIT_ITEM_USD, na.rm = TRUE))%>%
  ungroup()

quant95 <- tender_item_usd%>%
  group_by(ID_ITEM_UNSPSC)%>%
  mutate(price_per_item = AMT_ITEM * PRICE_UNIT_ITEM_USD)%>%
  dplyr::summarize(quant95 = quantile(PRICE_UNIT_ITEM_USD, probs = 0.95, na.rm = TRUE))%>%
  ungroup()

tender_unspsc_outlier <- tender_unspsc%>%
  left_join(quant95, by = "ID_ITEM_UNSPSC")%>%
  mutate(outlier = ifelse(tender_value > 2 * quant95, "Y", "N"))%>%
  filter(outlier == "Y")
# filter out 564 tenders (0.7% out of 74445 observations )

# remove outliers from all intermediate files 
tender_contract     <- tender_contract[!tender_contract$ID %in% tender_unspsc_outlier$ID, ]

contract_supplier   <- contract_supplier[!contract_supplier$ID %in% tender_unspsc_outlier$ID, ]

tender_item         <- tender_item[!tender_item$ID %in% tender_unspsc_outlier$ID, ]

supplier_item       <- supplier_item[!supplier_item$ID %in% tender_unspsc_outlier$ID, ]

data_parties_merged <- data_parties_merged[!data_parties_merged$ID %in% tender_unspsc_outlier$ID, ]


# generate summary statistics of outliers 
tender_contract_outlier     <- tender_contract[tender_contract$ID %in% tender_unspsc_outlier$ID, ]


# 1.0 Identify COVID items --------------------------------------------------------      

# 1.1 flag COVID observations by detecting COVID key words in items, contracts, tenders descriptions, and IDs  

# at tender_item level 
covid_tender_item <- tender_item%>%
  # item level detection 
  mutate(covid_item = ifelse(str_detect(STR_ITEM_DESCRIPTION, "covid")|
                               str_detect(STR_ITEM_DESCRIPTION, "COVID")|
                               str_detect(STR_ITEM_DESCRIPTION, "Covid")|
                               str_detect(STR_ITEM_DESCRIPTION, "coronavirus")|
                               str_detect(STR_ITEM_DESCRIPTION, "coronavirus")|
                               str_detect(STR_ITEM_DESCRIPTION, "sars-cov-2"),1,0),
         # tender level detection 
         covid_tender = ifelse(str_detect(STR_TENDER_DESCRIPTION, "covid")|
                                 str_detect(STR_TENDER_DESCRIPTION, "COVID")|
                                 str_detect(STR_TENDER_DESCRIPTION, "Covid")|
                                 str_detect(STR_TENDER_DESCRIPTION, "coronavirus")|
                                 str_detect(STR_TENDER_DESCRIPTION, "coronavirus")|
                                 str_detect(STR_TENDER_DESCRIPTION, "sars-cov-2"),1,0),
         # detect by IDS 
         covid_id = ifelse(str_detect(ID_ITEM, "covid")|
                             str_detect(ID_ITEM, "COVID")|
                             str_detect(ID_ITEM, "Covid")|
                             str_detect(ID_ITEM, "coronavirus")|
                             str_detect(ID_ITEM, "coronavirus")|
                             str_detect(ID_ITEM, "sars-cov-2")|
                             str_detect(ID, "covid")|
                             str_detect(ID, "COVID")|
                             str_detect(ID, "Covid")|
                             str_detect(ID, "coronavirus")|
                             str_detect(ID, "coronavirus")|
                             str_detect(ID, "sars-cov-2"), 1,0))

# single out COVID by ID 
covid_tender_item_ID <- covid_tender_item%>%
  filter(covid_item == 0 &
           covid_tender == 0 &
           covid_id == 1) 
# identified 2 entries 
covid_tender_item_ID

# generate covid dummy from tender and item descriptions 
covid_tender_item <- covid_tender_item%>%
  mutate( covid = case_when(covid_item == 1 ~ 1,
                            covid_tender == 1 ~ 1))%>%
  mutate_at(c("covid"), ~replace_na(., 0))%>%
  select(ID, ID_ITEM, year, covid, covid_item, covid_tender, covid_id)%>%
  distinct()

# generate a summary statistics about covid items 
stats_covid_item <- covid_tender_item %>%
  group_by(covid_item, year)%>%
  dplyr::summarise(n_item = n_distinct(ID_ITEM))%>%
  ungroup()

stats_covid_item

# generate a summary statistics about covid tender (for the tenders that have item level data )
stats_covid_tender <- covid_tender_item %>%
  group_by(covid_tender, year)%>%
  dplyr::summarise(n_tender = n_distinct(ID))%>%
  distinct()

stats_covid_tender


# at tender_contract level 
covid_tender_contract <- tender_contract%>%
  # contract level detection 
  mutate(covid_contract = ifelse(str_detect(STR_CONTRACT_DESCRIPTION, "covid")|
                                   str_detect(STR_CONTRACT_DESCRIPTION, "COVID")|
                                   str_detect(STR_CONTRACT_DESCRIPTION, "Covid")|
                                   str_detect(STR_CONTRACT_DESCRIPTION, "coronavirus")|
                                   str_detect(STR_CONTRACT_DESCRIPTION, "coronavirus")|
                                   str_detect(STR_CONTRACT_DESCRIPTION, "sars-cov-2"),1,0),
         # tender level detection 
         covid_tender = ifelse(str_detect(STR_TENDER_DESCRIPTION, "covid")|
                                 str_detect(STR_TENDER_DESCRIPTION, "COVID")|
                                 str_detect(STR_TENDER_DESCRIPTION, "Covid")|
                                 str_detect(STR_TENDER_DESCRIPTION, "coronavirus")|
                                 str_detect(STR_TENDER_DESCRIPTION, "coronavirus")|
                                 str_detect(STR_TENDER_DESCRIPTION, "sars-cov-2"),1,0),
         # detect by IDS 
         covid_id = ifelse(str_detect(ID_CONTRACT, "covid")|
                             str_detect(ID_CONTRACT, "COVID")|
                             str_detect(ID_CONTRACT, "Covid")|
                             str_detect(ID_CONTRACT, "coronavirus")|
                             str_detect(ID_CONTRACT, "coronavirus")|
                             str_detect(ID_CONTRACT, "sars-cov-2")|
                             str_detect(ID, "covid")|
                             str_detect(ID, "COVID")|
                             str_detect(ID, "Covid")|
                             str_detect(ID, "coronavirus")|
                             str_detect(ID, "coronavirus")|
                             str_detect(ID, "sars-cov-2"), 1,0))
# single out COVID by ID 
covid_tender_contract_ID <- covid_tender_contract%>%
  filter(covid_contract == 0 &
           covid_tender == 0 &
           covid_id == 1)
# identified 6 entries 

covid_tender_contract_ID

# generate a COVID dummy 
covid_tender_contract <- covid_tender_contract%>%
  mutate(covid = case_when(covid_tender == 1 ~ 1,
                           covid_contract == 1 ~ 1))%>%
  mutate_at(c("covid"), ~replace_na(., 0))%>%
  select(ID, ID_CONTRACT, year, covid, covid_contract, covid_tender)%>%
  distinct()

# generate a summary statistics about covid contracts 
stats_covid_contract <- covid_tender_contract %>%
  group_by(covid_contract, year)%>%
  dplyr::summarise(n_contract = n_distinct(ID_CONTRACT))%>%
  ungroup()

stats_covid_contract

# generate a summary statistics about covid tenders (the tenders that have contract level data )
stats_covid_tender_2 <- covid_tender_contract%>%
  group_by(covid_tender, year)%>%
  dplyr::summarise(n_tender = n_distinct(ID))%>%
  ungroup()

stats_covid_tender_2 # note: more tenders have contract information compared to item information 


# 1.2 Generate a list of tenders that contain COVID key words in contracts', items', and tenders' descriptions

# collapse item level information to tender level 
covid_tender_item <- covid_tender_item%>%
  mutate(covid = case_when(covid_item == 1 ~ 1,
                           covid_tender == 1 ~ 1))%>%
  mutate_at(c("covid"), ~replace_na(., 0))%>%
  select(ID, year, covid)%>%
  distinct()

# collapse contract level information to tender level 
covid_tender_contract <- covid_tender_contract%>%
  mutate(covid = case_when(covid_tender == 1 ~ 1,
                           covid_contract == 1 ~ 1))%>%
  mutate_at(c("covid"), ~replace_na(., 0))%>%
  select(ID, year, covid)%>%
  distinct()

length(unique(covid_tender_item$ID))      # 23458 tenders have item level data 
length(unique(covid_tender_contract$ID))  # 23622 tenders have contract level data 

# note: should merge tender-item data to tender-contract data because contracts are related to more unique tenders
# in other words, all tenders have contracts, but not all tenders have items. It's because of the quality of the data 
# rather than mistakenly merging. Already checked the raw data many times. 

covid_tender_item_contract <- covid_tender_contract%>%
  left_join(covid_tender_item,
            by = "ID", suffix = c("_tender_contract", "_tender_item"))%>%  
  mutate_at(c("covid_tender_contract", "covid_tender_item"), ~replace_na(., 0))%>%
  mutate(covid = case_when(covid_tender_item == 1 ~ 1,
                           covid_tender_contract == 1 ~ 1))%>%
  mutate_at(c("covid"), ~replace_na(., 0))%>%
  select(-c("year_tender_item"))%>%
  dplyr::rename(year = year_tender_contract)

# a list of COVID tender ID 
covid_tender <- covid_tender_item_contract%>%
  distinct(ID, covid)

# 1.3 Summary statistics about the number of COVID/non-COVID item, contracts, and tenders each year 

# the overlap between COVID item and contract 
table(covid_tender_item_contract[c("covid_tender_item", "covid_tender_contract", "year")])

# summary statistics of all the COVID and non-COVID tenders each year (the union of COVID item, contract, and tender)
stats_covid_union  <- covid_tender_item_contract%>%
  group_by(covid, year)%>%
  dplyr::summarise(n_union = n_distinct(ID))%>%
  ungroup()

stats_covid_union

# merge the summary statistics of tender, item, and contracts data together
stats_covid <- stats_covid_union%>%
  left_join(stats_covid_item, by = c("covid" = "covid_item", "year"))%>%
  left_join(stats_covid_contract, by = c("covid" = "covid_contract", "year"))%>%
  left_join(stats_covid_tender_2, by = c("covid" = "covid_tender", "year"))

stats_covid
# note: @team, the number of supplies in 2015 is extremely high compared to the supplies during COVID. 
# Why is that? My hypothesis is that supply chain crisis hit Honduras in 2020. 
# Does this affect our understandings of the change in supplies during COVID? 
# How to tease out the impact of supply chain crisis from the impact of 'COVID'? 
# This also leads to our definition of 'COVID'. How should we define the impact of COVID? It's not a usual economic crisis like 2008. 
# The pandemic might have changed governments' preferred public good, leading to the change in market and firm behavior. 
# Supply chain crisis and lockdown also changed firms behavior through increasing the cost of production. 
# Thus, how to define the impact of treatment 'COVID'? What does 'COVID' mean to government and firm interaction? 


# 2.0 Identify Comparison Groups in Intermediate Data --------------------------

# Definition: 
# treatment item: the item that has a UNSPSC code that is related to COVID before and during COVID 
# treatment firm: the firm that supplied items with COVID related UNSPSC code before and during COVID 

# 2.1 flag COVID items and generate a list of UNSPSC code 

# add COVID dummy to item level data 
supplier_item <- supplier_item%>%
  
  left_join(covid_tender, by = "ID")  %>%
  # note: 306 participants cannot link to any items. Cannot find their tender ID in contract level or item level. 
  # i.e. ocds-lcuori-grxXEr-COT. NÂ°10-2015-1/3 and ocds-lcuori-gGyD4L-COVID 19-CONTRATACIÃ"N DIRECTA No. 17-2021-HE-AME -2/3
  
  mutate_at(c("covid"), ~replace_na(., 0))

# construct UNSPSC list at commodity level (the most nuanced level, and the originally reported UNSPSC code) 
unspsc_commodity <- supplier_item%>%
  select(ID_ITEM_UNSPSC, STR_ITEM_UNSPSC, STR_ITEM_DESCRIPTION, covid)%>%
  distinct()

# construct UNSPSC list at class level  
unspsc_commodity$ID_ITEM_UNSPSC_CLASS = substr(unspsc_commodity$ID_ITEM_UNSPSC, start = 1, stop = 6)

unspsc_commodity$ID_ITEM_UNSPSC_CLASS = as.numeric(paste0(unspsc_commodity$ID_ITEM_UNSPSC_CLASS, "00"))

unspsc_commodity <- unspsc_commodity %>%
  # merge in UNSPSC class level description by the first 6 digits of the code 
  left_join(data_unspsc_class, 
            by = c("ID_ITEM_UNSPSC_CLASS" = "Class"))%>%
  dplyr::rename(STR_CLASS_UNSPSC = Description,
                STR_COMMODITY_UNSPSC = STR_ITEM_UNSPSC)

# construct UNSPSC list at family level
unspsc_commodity$ID_ITEM_UNSPSC_FAMILY = substr(unspsc_commodity$ID_ITEM_UNSPSC, start = 1, stop = 4)

unspsc_commodity$ID_ITEM_UNSPSC_FAMILY = as.numeric(paste0(unspsc_commodity$ID_ITEM_UNSPSC_FAMILY, "0000"))

unspsc_commodity <- unspsc_commodity%>%
  # merge in UNSPSC family level description by the first 4 digits of the code 
  left_join(data_unspsc_family, 
            by = c("ID_ITEM_UNSPSC_FAMILY" = "Family"))%>%
  dplyr::rename(STR_FAMILY_UNSPSC = Description)

# save UNSPSC lists at 3 levels 
unspsc_family <- unspsc_commodity%>%
  select(ID_ITEM_UNSPSC_FAMILY, STR_FAMILY_UNSPSC, ID_ITEM_UNSPSC, STR_ITEM_DESCRIPTION, covid)

fwrite(unspsc_family, file = paste0(cleaned, "/UNSPSC_FAMILY.CSV"))


unspsc_class <- unspsc_commodity%>%
  select(ID_ITEM_UNSPSC_CLASS, STR_CLASS_UNSPSC, ID_ITEM_UNSPSC, STR_ITEM_DESCRIPTION, covid)

fwrite(unspsc_class, file = paste0(cleaned, "/UNSPSC_CLASS.CSV"))


unspsc_commodity <- unspsc_commodity%>%
  select(ID_ITEM_UNSPSC, STR_COMMODITY_UNSPSC, STR_ITEM_DESCRIPTION, covid)

fwrite(unspsc_commodity, file = paste0(cleaned, "/UNSPSC_COMMODITY.CSV"))

# 27027 unique items 
length(unique(unspsc_commodity$ID_ITEM_UNSPSC))       # 3755 unique commodity code  
length(unique(unspsc_class$ID_ITEM_UNSPSC_CLASS))     # 1219 unique item code 
length(unique(unspsc_family$ID_ITEM_UNSPSC_FAMILY))   # 306  unique family code 


# 2.2 Construct Medical related dummies 
# in UNSPSC code, 42000000 is the segment of Medical Equipment and Accessories and Supplies
#                 41000000 is the segment of Laboratory and Measuring and Observing and Testing Equipment
#                 51000000 is the segment of Drugs and Pharmaceutical Products

#  extract the first 2 characters of UNSPSC and match with 42, 41, and 51  
supplier_item$ID_ITEM_UNSPSC_SEG = substr(supplier_item$ID_ITEM_UNSPSC, start = 1, stop = 2)

supplier_item <- supplier_item%>%
  mutate(medical = ifelse(ID_ITEM_UNSPSC_SEG == 42, 1,
                          ifelse(ID_ITEM_UNSPSC_SEG == 41, 1,
                                 ifelse(ID_ITEM_UNSPSC_SEG == 51, 1, 0))),
         sector = ifelse(covid == 1 & medical == 1, "Medical-COVID",
                         ifelse(covid != 1 &  medical == 1, "Medical-NonCOVID", 
                                ifelse(covid == 1 & medical != 1, "NonMedical-COVID", "NonMedical-NonCOVID"))))

# summary statistics of the number of tenders each sectors each year 
supplier_item_summary <- supplier_item%>%
  group_by(sector, year)%>%
  dplyr::summarise(N = n_distinct(ID))%>%
  ungroup()%>%
  spread(sector, N)

supplier_item_summary # number of tenders 

covid_sector <- supplier_item%>%
  # drop 474 observations that does not have item information 
  filter(!is.na(sector))%>%
  select(ID, covid, sector)%>%
  distinct()                         # identified sectors for 85422 tenders 


# 2.3 assign to comparison groups 
# A COVID contract/tender means from 2020 to 2022, at least one item in a contract/tender has an UNSPSC code that is on the COVID product UNSPSC list. 
# A firm that is in the COVID group means from 2020 to 2022, that firm has supplied COVID items (the item that has an UNSPSC code that is on the COVID product UNSPSC list)

# generate a COVID/nonCOVID UNSPSC dictionary
covid_unspsc  <- unspsc_commodity %>% 
  select(ID_ITEM_UNSPSC, covid)%>%
  distinct()%>%
  # alert: some UNSPSC was related to both COVID and non-COVID items, as long as that UNSPSC has related to COVID product, I am marking it as COVID UNSPSC
  group_by(ID_ITEM_UNSPSC)%>%
  dplyr::summarise(covid = sum(covid))%>%
  ungroup()
# identified 64 COVID UNSPSC, 3691 non-COVID UNSPSC
# 3755 unique commodity UNSPSC total - matched with section 2.1 result!

# create a covid firm list 
supplier_item <- supplier_item%>%
  select(-c("covid"))%>%
  left_join(covid_unspsc,
            by = c("ID_ITEM_UNSPSC" = "ID_ITEM_UNSPSC"))%>%
  dplyr::rename(covid_item = covid)

covid_firm <- supplier_item%>%
  group_by(ID_PARTY)%>%
  dplyr::summarise(covid = sum(covid_item, na.rm = T))%>%
  ungroup()%>%
  mutate(covid_firm = case_when(covid >= 1 ~ 1))%>%
  mutate_at(c("covid_firm"), ~replace_na(., 0))%>%
  select(-c("covid"))    
# identified 3446 unique suppliers, 3446 unique obs, uniqueness check passed!

# create a covid tender list 
covid_tender <- supplier_item%>%
  group_by(ID)%>%
  dplyr::summarise(covid = sum(covid_item, na.rm = T))%>%
  ungroup()%>%
  mutate(covid_tender = case_when(covid >= 1 ~ 1))%>%
  mutate_at(c("covid_tender"), ~replace_na(., 0))%>%
  select(-c("covid"))
# identified 23458 tenders, 23458 obs, uniqueness check passed!
# matched with the number of suppliers in the other item level data - tender_item!

# create a covid item list 
covid_item <- supplier_item%>%
  group_by(ID_ITEM)%>%
  dplyr::summarise(covid = sum(covid_item, na.rm = T))%>%
  ungroup()%>%
  mutate(covid_item = case_when(covid >= 1 ~ 1))%>%
  mutate_at(c("covid_item"), ~replace_na(., 0))%>%
  select(-c("covid"))


# Variable Construction 



# 1 overall trend ---------------------------------------
# Total monetary value, average monetary value, and total number of tenders per month 
# generate a tender-value dataset 
# tender_value <- market_concentration%>%
#   group_by(year_month, ID, Group)%>%
#   dplyr::summarise(tender_value = sum(AMT_ITEM_TOTAL, na.rm = TRUE))%>%
#   ungroup()
#   
# tender_value$Group <- replace(tender_value$Group, tender_value$Group == 0, "Non-COVID")
# 
# tender_value$Group <- replace(tender_value$Group, tender_value$Group == 1, "COVID")
# 

#  the number of tenders in relation to tender publication dates

# add group dummy 
tender_contract_grouped <- left_join(tender_contract, covid_tender,
                             by = "ID")
# 221 observations are not in item level data (covid tender was created from supplier item data as we use UNSPSC to identify COVID related or not)

tender_contract_grouped <- tender_contract_grouped%>%
  dplyr::rename(Group = covid_tender)%>%
  # drop contracts that cannot link to item level data (in other words, those tenders only have contract data but don't have item data)
  filter(!is.na(Group))

tender_contract_grouped$Group <- replace(tender_contract_grouped$Group, tender_contract_grouped$Group == 0, "Non-COVID")

tender_contract_grouped$Group <- replace(tender_contract_grouped$Group, tender_contract_grouped$Group == 1, "COVID")

# construct a tender dataset 
tender <- tender_contract_grouped%>%
  select(ID, DT_TENDER_PUB, Group)%>%
  distinct()

tender$month <- as.numeric(strftime(tender$DT_TENDER_PUB, "%m"))

tender$year <- as.numeric(strftime(tender$DT_TENDER_PUB, "%Y"))

tender$year_month <- as.Date(paste0(tender$year, "-", tender$month, "-01"))

tender <- tender%>%
  
  mutate(semester = ifelse(month <= 6, "03", "09"))

tender$semester <- paste0(tender$year, "-", tender$semester, "-30")

tender <- tender %>%
  filter(year >= 2015 & 
           year <= 2022)%>%
  group_by(semester, Group)%>%
  dplyr::summarise(count = n_distinct(ID))%>%
  ungroup()


ggplot(tender, aes(x = semester, y = count, group = Group))+
  
  # draw a line graph for two groups
  geom_line(aes(color = Group, linetype = Group, size = Group))+
  
  # set line type separately 
  scale_linetype_manual(values=c("solid", "dotted"))+
  
  # set color separately 
  scale_color_manual(values=c('#FF0100','#18466E'))+
  
  # set size separately 
  scale_size_manual(values=c(1, 0.8))+
  
  # add point plots and define colors 
  geom_point(data = tender %>% filter(Group == "COVID"), aes(x = semester, y = count), shape = 16, size = 3, color = "#FF0100") +
  geom_point(data = tender %>% filter(Group == "Non-COVID"), aes(x = semester, y = count), shape = 18, size = 4, color = "#18466E") +
  
  # add a vertical line to show treatment 
  geom_vline(xintercept= 10.5, color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Tender Publication Date (aggregate by Month)", 
       y = "Number of Tenders", title = "The Number of Tenders Published Per Month",
       subtitle =  "Jan 2015 - Ang 2022",
       caption ="Note: data retrieved from ONCAE in Mar 2023.")+
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.9, 0.8),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank())+
  
  # add percent to x axis, if needed 
  scale_y_continuous(position = "right")

ggsave(filename = paste0(output, "/Total_tender_number.jpeg"),
       width = 10,
       height = 8,
       units = c("in"),
       dpi = 300)



# 7.2 the number of contracts signed in relation to the contract signature date 
contract <- tender_contract_grouped%>%
  select(ID_CONTRACT, DT_CONTRACT_SIGNED, Group)%>%
  distinct()

contract$month <- as.numeric(strftime(contract$DT_CONTRACT_SIGNED, "%m"))

contract$year <- as.numeric(strftime(contract$DT_CONTRACT_SIGNED, "%Y"))

# contract$year_month <- as.Date(paste0(contract$year, "-", contract$month, "-01"))

contract <- contract%>%
  
  mutate(semester = ifelse(month <= 6, "03", "09"))

contract$semester <- paste0(contract$year, "-", contract$semester, "-30")


contract <- contract %>%
  filter(year >= 2015 & 
           year <= 2022)%>%
  group_by(semester, Group)%>%
  dplyr::summarise(count = n_distinct(ID_CONTRACT))%>%
  ungroup()


ggplot(contract, aes(x = semester, y = count, group = Group))+
  
  # draw a line graph for two groups
  geom_line(aes(color = Group, linetype = Group, size = Group))+
  
  # set line type separately 
  scale_linetype_manual(values=c("solid", "dotted"))+
  
  # set color separately 
  scale_color_manual(values=c('#FF0100','#18466E'))+
  
  # set size separately 
  scale_size_manual(values=c(1, 0.8))+
  
  # add point plots and define colors 
  geom_point(data = contract %>% filter(Group == "COVID"), aes(x = semester, y = count), shape = 16, size = 3, color = "#FF0100") +
  geom_point(data = contract %>% filter(Group == "Non-COVID"), aes(x = semester, y = count), shape = 18, size = 4, color = "#18466E") +
  
  # add a vertical line to show treatment 
  geom_vline(xintercept=10.5, color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Contract Signed Date (aggregate by Month)", 
       y = "Number of Contracts signed", title = "The Number of Contracts Signed per Month ",
       subtitle =  "Jan 2015 - Ang 2022",
       caption ="Note: data retrieved from ONCAE in Mar 2023.")+
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.9, 0.8),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank())+
  
  # add percent to x axis, if needed 
  scale_y_continuous(position = "right")


ggsave(filename = paste0(output, "/Total_contract_number.jpeg"),
       width = 10,
       height = 8,
       units = c("in"),
       dpi = 300)


# 7.3 the value of contracts in relation to contract signature date (also use the contract value data)
# merging in COVID tender  
contract_supplier_grouped <- left_join(contract_supplier, covid_firm,
                               by = c("ID_SUPPLIER" = "ID_PARTY"))         # note: 100% merge 

contract_value <- contract_supplier_grouped%>%
  select(ID_CONTRACT, AMT_CONTRACT_VALUE_USD, DT_CONTRACT_SIGNED, covid_firm)%>%
  distinct()

# add group dummy 
contract_value$covid_firm <- replace(contract_value$covid_firm, contract_value$covid_firm == 0 |
                                       is.na(contract_value$covid_firm), "Non-COVID")

contract_value$covid_firm <- replace(contract_value$covid_firm, contract_value$covid_firm == 1, "COVID")


contract_value$month <- as.numeric(strftime(contract_value$DT_CONTRACT_SIGNED, "%m"))

contract_value$year <- as.numeric(strftime(contract_value$DT_CONTRACT_SIGNED, "%Y"))

contract_value <- contract_value%>%
  
  mutate(semester = ifelse(month <= 6, "03", "09"))

contract_value$semester <- paste0(contract_value$year, "-", contract_value$semester, "-30")


contract_value_avg <- contract_value%>%
  filter(year >= 2015 & 
           year <= 2022)%>%
  dplyr::rename(Group = covid_firm)%>%
  group_by(semester, Group)%>%
  dplyr::summarize(average_value = mean(AMT_CONTRACT_VALUE_USD, na.rm = TRUE))%>%
  ungroup()

ggplot(contract_value_avg, aes(x = semester, y = average_value/1000, group = Group))+
  
  # draw a line graph for two groups
  geom_line(aes(color = Group, linetype = Group, size = Group))+
  
  # set line type separately 
  scale_linetype_manual(values=c("solid", "dotted"))+
  
  # set color separately 
  scale_color_manual(values=c('#FF0100','#18466E'))+
  
  # set size separately 
  scale_size_manual(values=c(1, 0.8))+
  
  # add point plots and define colors 
  geom_point(data = contract_value_avg %>% filter(Group == "COVID"), aes(x = semester, y = average_value/1000), shape = 16, size = 3, color = "#FF0100") +
  geom_point(data = contract_value_avg %>% filter(Group == "Non-COVID"), aes(x = semester, y = average_value/1000), shape = 18, size = 4, color = "#18466E") +
  
  # add a vertical line to show treatment 
  geom_vline(xintercept=10.5, color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Contract Signed Date (aggregate by Month)", 
       y = "Average Value of Contracts (thousands)", title = "Average Contract Value per Month ",
       subtitle =  "Jan 2015 - Dec 2021",
       caption ="Note: data retrieved from ONCAE in Mar 2023.")+
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.9, 0.8),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank())+
  
  # add percent to x axis, if needed 
  scale_y_continuous(position = "right")



ggsave(filename = paste0(output, "/Avg_contract_value.jpeg"),
       width = 10,
       height = 8,
       units = c("in"),
       dpi = 300)


# 
# 
# # Total number of tenders per month 
# tender_number <- tender_value%>%
#   group_by(Group, year_month)%>%
#   dplyr::summarise(num_tender = n())%>%
#   ungroup()
# 
# 
# 
# # remove an outlier ocds-lcuori-gGyD4L-cm-229-amq-he-2021-1/3  
# tender_value$tender_value[tender_value$ID == "ocds-lcuori-gGyD4L-cm-229-amq-he-2021-1/3"] <- NA
# 
# # total monetary value
# tender_value_total <- tender_value%>%
#   group_by(year_month, Group)%>%
#   dplyr::summarise(total_value = sum(tender_value, na.rm = TRUE))%>%
#   ungroup()
# 
# head(tender_value_total)
#     # note: the gap between COVID and nonCOVID is too large such that the two lines cannot fit in one graph 
# 
# ggplot(tender_value_total, aes(x = year_month, y = total_value, group = Group, color = Group))+
#   geom_line()+
#   theme_classic()+
#   theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+
#   geom_vline(xintercept=10.5, color="gray", size=1)+
#   labs(x = "Month", y = "Total Value of Tenders", title = "Total Tender Monetary Value ",
#        subtitle =  "Jan 2015 - Jul 2022",
#        caption = "Note: data retrieved from ONCAE in Mar 2023. Tender ocds-lcuori-gGyD4L-cm-229-amq-he-2021-1/3, signed on January 2022, was removed, 
#                   \ndue to the extremely large total tender value. That tender aims to purchase 26,9928 CINTAS Glucometria test strips at a price of
#                   \n11,7900 Lempira each.")+
#   theme(legend.position = "bottom")+
#   theme(plot.caption = element_text(hjust = 0))
# 
# ggsave(filename = paste0(output, "/Total_tender_value.jpeg"),
#        width = 10,
#        height = 8,
#        units = c("in"),
#        dpi = 300)
# 
# # average monetary value 
# tender_value_avg <- tender_value%>%
#   group_by(year_month, Group)%>%
#   dplyr::summarise(average_value = mean(tender_value, na.rm = TRUE))%>%
#   ungroup()
# 
# ggplot(tender_value_avg, aes(x = year_month, y = average_value, group = Group, color = Group))+
#   geom_line()+
#   theme_classic()+
#   theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+
#   geom_vline(xintercept=10.5, color="gray", size=1)+
#   labs(x = "Month", y = "Average Value per Tender", title = "Average Tender Monetary Value",
#        subtitle =  "Jan 2015 - Jul 2022",
#        caption ="Note: data retrieved from ONCAE in Mar 2023. Tender ocds-lcuori-gGyD4L-cm-229-amq-he-2021-1/3, signed on January 2022, was removed, 
#                   \ndue to the extremely large total tender value. That tender aims to purchase 26,9928 CINTAS Glucometria test strips at a price of
#                   \n11,7900 Lempira each.")+
#   theme(legend.position = "bottom")+
#   theme(plot.caption = element_text(hjust = 0))
# 
# ggsave(filename = paste0(output, "/Average_tender_value.jpeg"),
#        width = 10,
#        height = 8,
#        units = c("in"),
#        dpi = 300)
# 

# 2 type of procedure -----------------------------------------------------


# Open Procurement Methods 


# assign COVID dummy to tender-item data 
tender_item <- left_join(tender_item, covid_item, by = "ID_ITEM") # perfect match 

# generate summary statistics 
method_num <- tender_item%>%
  mutate(noncovid_item = 1-covid_item)%>%
  group_by(CAT_TENDER_METHOD)%>%
  dplyr::summarise(across(c(covid_item, noncovid_item),sum),
                   .groups = 'drop') %>%
  ungroup()%>%
  dplyr::rename("Procurement Method" = "CAT_TENDER_METHOD",
                "COVID" = "covid_item",
                "Non-COVID" = "noncovid_item")

method_num %>%
  kbl(caption = "Summary Statistics about Procurement Method") %>%
  kable_classic(full_width = F, html_font = "Cambria")

# CAT_TENDER_METHOD_DETAIL
method_num_detail <- tender_item%>%
  mutate(noncovid_item = 1-covid_item)%>%
  group_by(CAT_TENDER_METHOD_DETAIL)%>%
  dplyr::summarise(across(c(covid_item, noncovid_item),sum),
                   .groups = 'drop') %>%
  ungroup()%>%
  dplyr::rename("Procurement Method" = "CAT_TENDER_METHOD_DETAIL",
                "COVID" = "covid_item",
                "Non-COVID" = "noncovid_item")

method_num_detail %>%
  kbl(caption = "Summary Statistics about Procurement Method") %>%
  kable_classic(full_width = F, html_font = "Cambria")


# 1 Minor Purchase 3136 16868
# 2 Private contest 57 76
# 3 International public tender 0 2
# 4 National public tender 14 72
# 5 Direct contracting 162 350
# 6 Private tender 1322 5885
# 7 International public bidding 5 15
# 8 National public tender 74 631

# add semester dummy
# tender_item$month <- strftime(tender_item$DT_TENDER_PUB, "%m")
# 
# tender_item$year <- strftime(tender_item$DT_TENDER_PUB, "%Y")
# 
# tender_item$month <- as.numeric(tender_item$month)
# 
# tender_item$year_month <- as.Date(paste0(tender_item$year, "-", tender_item$month, "-01"))
# 
# tender_item <- tender_item%>%
#   mutate(semester = ifelse(month <= 06, "03", "07"))
# 
# tender_item$semester <- paste0(tender_item$year, "-", tender_item$semester, "-30")

# classify procurement method 
contract_value <- contract_supplier%>%
  select(ID_CONTRACT, AMT_CONTRACT_VALUE_USD)%>%
  distinct()

tender_contract_value <- left_join(tender_contract, contract_value, by = "ID_CONTRACT")


# add semester dummy 
tender_contract_value$year_month <- as.Date(paste0(tender_contract_value$year, "-", tender_contract_value$month, "-01"))

tender_contract_value$month <- as.numeric(strftime(tender_contract_value$DT_TENDER_PUB, "%m"))

tender_contract_value$year <- as.numeric(strftime(tender_contract_value$DT_TENDER_PUB, "%Y"))


tender_contract_value <- tender_contract_value%>%
  
  mutate(semester = ifelse(month <= 6, "03", "09")) 

tender_contract_value$semester <- paste0(tender_contract_value$year, "-", tender_contract_value$semester, "-30")

tender_contract_value$semester <- as.Date(tender_contract_value$semester)

tender_contract_value <- tender_contract_value %>%
  filter(semester <= as.Date("2022-09-30"))


# add group 
tender_contract_value_grouped <- left_join(tender_contract_value, covid_tender, 
                                           by = "ID")

tender_contract_value_grouped$Group <- replace(tender_contract_value_grouped$Group, tender_contract_value_grouped$covid_tender == 0|is.na(tender_contract_value_grouped$covid_tender), "Open - Non-COVID")

tender_contract_value_grouped$Group <- replace(tender_contract_value_grouped$Group, tender_contract_value_grouped$covid_tender == 1, "Open - COVID")


# calculate the share of contract value of each procurement method 
method_share <- tender_contract_value_grouped %>%
  mutate(method = ifelse(CAT_TENDER_METHOD_DETAIL == "Compra Menor" |
                           CAT_TENDER_METHOD_DETAIL == "Concurso privado"|
                           CAT_TENDER_METHOD_DETAIL == "Contratación directa"|
                           CAT_TENDER_METHOD_DETAIL == "Licitación privada"|
                           CAT_TENDER_METHOD_DETAIL == "Convenio Marco", "close", "open"))


# Open-covid/total covid 
# Open-noncovid/total noncovid 

method_share_stats <- method_share%>%
  group_by(method, semester, Group)%>%
  dplyr::summarise(contract_sum = sum(AMT_CONTRACT_VALUE_USD, na.rm = TRUE))%>%
  ungroup()%>%
  pivot_wider(names_from = method, values_from = contract_sum)%>%
  mutate(total = open + close)%>%
  mutate(share_open = open/total)


# method_share_stats_long <- method_share_stats %>%
#   pivot_longer(cols = c(open, close),
#                names_to = "",
#                values_to = "value")

# visualization 
ggplot(method_share_stats %>% filter(semester != "2023-3-30" & semester != "2023-9-30"), aes(x = semester, y = share_open, Group = Group))+
  
  # draw a line graph for two groups
  geom_line(aes(color = Group, linetype = Group, size = Group))+
  
  # set line type separately 
  scale_linetype_manual(values=c("solid", "dotted"))+
  
  # set color separately 
  scale_color_manual(values=c('#FF0100', "#18466E"))+
  
  # set size separately 
  scale_size_manual(values=c(1, 0.8))+
  
  # add point plots and define colors 
  geom_point(data = method_share_stats %>% filter(Group == "Open - COVID"), aes(x = semester, y = share_open), shape = 16, size = 3, color = "#FF0100") +
  geom_point(data = method_share_stats %>% filter(Group == "Open - Non-COVID"), aes(x = semester, y = share_open), shape = 18, size = 3, color = "#18466E") +
  
  # add a vertical line to show treatment 
  geom_vline(xintercept= as.Date("2020-01-01"), color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Contract Signature Date (aggregate by semester)", y = "Share of Contract Value", title = "Procurement Method",
       subtitle = "The Share of Contract Value Purchased by Open Method",
       caption ="Note: data retrieved from ONCAE in Mar 2023.")+
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.85, 0.85),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank())+

  # add percent to x axis, if needed 
  scale_y_continuous(position = "right", labels = scales::percent_format(accuracy = 1))


ggsave(filename = paste0(output, "/procurement_method.jpeg"),
       width = 10,
       height = 8,
       units = c("in"),
       dpi = 300)


# 3 competition ----------------------------------------------------

# Product Classification 

# 8.1 Do firms during covid supply a broader range of different products?
# explore the number of products sold by the firm before, during and after COVID
# create half year dummy 
supplier_item$month <- as.numeric(strftime(supplier_item$DT_CONTRACT_SIGNED, "%m"))

supplier_item$year <- as.numeric(strftime(supplier_item$DT_CONTRACT_SIGNED, "%Y"))

supplier_item$month <- as.numeric(supplier_item$month)

supplier_item$year_month <- as.Date(paste0(supplier_item$year, "-", supplier_item$month, "-30"))


firm_item <- supplier_item%>%
  mutate(semester = ifelse(month <= 06, "03", "07"))

firm_item$semester <- paste0(firm_item$year, "-", firm_item$semester, "-30")

# calculate the number of different products supplied by firms within 6 months 
firm_item_sum <- firm_item%>%
  group_by(ID_PARTY, semester)%>%
  dplyr::summarise(num_unspsc = n_distinct(ID_ITEM_UNSPSC))%>%
  ungroup()

firm_item_sum_stats <- firm_item_sum%>%
  group_by(semester)%>%
  dplyr::summarise(num_unspsc_sum = sum(num_unspsc))%>%
  ungroup()

# revise names 
firm_item_sum_stats$semester <- as.Date(firm_item_sum_stats$semester)

ggplot(firm_item_sum_stats, aes(x = semester, y = num_unspsc_sum))+
  
  # draw a line graph for two groups
  geom_line()+
  
  # add point plots and define colors 
  geom_point(data = firm_item_sum_stats, shape = 16, size = 3) +
  
  # add a vertical line to show treatment 
  geom_vline(xintercept=as.Date("2020-01-01"), color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Contract Signature Date (aggregate by semester)", y = "Number of Unique UNSPSC Commodity Code", title = "Product Classification",
       subtitle = "Number of different products supplied by firm from Jan 2015 - Jul 2022",
       caption ="Note: data retrieved from ONCAE in Mar 2023.")+
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.9, 0.8),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank())+
  
  scale_y_continuous(position = "right")


# add percent to x axis, if needed 
# scale_y_continuous(position = "right", labels = scales::percent_format(accuracy = 1))


ggsave(filename = file.path(output, "/product_classification_sum.jpeg"),
       width = 10,
       height = 8,
       units = c("in"),
       dpi = 300)


# 8.2 the average unique UNSPSC code firms have supplied within 6 months 

# assign observations to groups (covid firm) 
firm_item <- left_join(firm_item, covid_firm, by = "ID_PARTY")

# calculation 
firm_item_avg <- firm_item%>%
  dplyr::rename(Group = covid_firm)%>%
  group_by(ID_PARTY, semester, Group)%>%
  dplyr::summarise(num_unspsc = n_distinct(ID_ITEM_UNSPSC))%>%
  ungroup()

firm_item_stats <- firm_item_avg%>%
  group_by(semester, Group)%>%
  dplyr::summarise(num_unspsc_avg = mean(num_unspsc))%>%
  ungroup()

# revise names 
firm_item_stats$Group <- replace(firm_item_stats$Group, firm_item_stats$Group == 0|is.na(firm_item_stats$Group), "Non-COVID")

firm_item_stats$Group <- replace(firm_item_stats$Group, firm_item_stats$Group == 1, "COVID")

firm_item_stats$semester <- as.Date(firm_item_stats$semester)


ggplot(firm_item_stats, aes(x = semester, y = num_unspsc_avg, group = Group))+
  
  # draw a line graph for two groups
  geom_line(aes(color = Group, linetype = Group, size = Group))+
  
  # set line type separately 
  scale_linetype_manual(values=c("solid", "dotted"))+
  
  # set color separately 
  scale_color_manual(values=c('#FF0100','#18466E'))+
  
  # set size separately 
  scale_size_manual(values=c(1, 0.8))+
  
  # add point plots and define colors 
  geom_point(data = firm_item_stats %>% filter(Group == "COVID"), aes(x = semester, y = num_unspsc_avg), shape = 16, size = 3, color = "#FF0100") +
  geom_point(data = firm_item_stats %>% filter(Group == "Non-COVID"), aes(x = semester, y = num_unspsc_avg), shape = 18, size = 4, color = "#18466E") +
  
  # add a vertical line to show treatment 
  geom_vline(xintercept=as.Date("2020-01-01"), color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Contract Signature Date (aggregate by semester)", y = "Number of Unique UNSPSC Commodity Code", title = "Product Classification",
       subtitle = "Average number of different UNSPSC product codes that firms have supplied from Jan 2015 - Jul 2022",
       caption ="Note: data retrieved from ONCAE in Mar 2023.")+
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.9, 0.95),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank()) +
  
  scale_y_continuous(position = "right")


# add percent to x axis, if needed 
# scale_y_continuous(position = "right", labels = scales::percent_format(accuracy = 1))


ggsave(filename = file.path(output, "/product_classification_avg.jpeg"),
       width = 10,
       height = 8,
       units = c("in"),
       dpi = 300)


# 8.2 the share of firms that have increased the product code during COVID 
firm_item_year <- supplier_item%>%
  group_by(ID_PARTY, year)%>%
  dplyr::summarise(num_unspsc = n_distinct(ID_ITEM_UNSPSC))%>%
  ungroup()

firm_uspsc_panel <- firm_item_year%>%
  spread(year, num_unspsc)%>%
  clean_names()%>%
  replace(is.na(.), 0)%>%
  mutate(product_increase = case_when(x2020 > x2015 | x2021 > x2015 ~ 1,
                                      TRUE ~ 0))%>%
  dplyr::rename("2015" = "x2015",
                "2016" = "x2016",
                "2017" = "x2017",
                "2018" = "x2018",
                "2019" = "x2019",
                "2020" = "x2020",
                "2021" = "x2021",
                "2022" = "x2022")%>%
  dplyr::rename("ID_PARTY" = "id_party")%>%
  select(ID_PARTY, product_increase)

firm_product <- left_join(supplier_item, firm_uspsc_panel,
                          by = "ID_PARTY")

firm_product_stats <- firm_product%>%
  dplyr::rename(Group = covid_item)%>%
  group_by(Group, product_increase)%>%
  dplyr::summarise(num_firm = n())%>%
  ungroup()


firm_product_stats$Group <- replace(firm_product_stats$Group, firm_product_stats$Group == 0|is.na(firm_product_stats$Group), "Non-COVID")

firm_product_stats$Group <- replace(firm_product_stats$Group, firm_product_stats$Group == 1, "COVID")

firm_product_stats


# 8.3 firms that sold COVID products in 2015, do they sell COVID products in 2020? 

# flag firms that sell COVID products in 2015 
COVID_firm_2015 <- firm_item %>%
  filter(year == 2015 &
           covid_firm == 1)%>%
  distinct(ID_PARTY, covid_firm)

firm_item_COVID <- firm_item %>%
  left_join(COVID_firm_2015, by = "ID_PARTY", suffix = c("", "_2015"))%>%
  mutate_at(c("covid_firm_2015"), ~replace_na(., 0))%>%
  
  # whether a firm sells COVID items in 2020 
  mutate(covid_item_2020 = case_when(year_month >= "2020-01-01" & year_month <= "2020-12-01" & covid_item == 1 ~ 1))%>%
  mutate_at(c("covid_item_2020"), ~replace_na(., 0))%>%
  
  # whether a firm sells COVID items in 2020 and 2021
  mutate(covid_item_2021 = case_when(year_month >= "2020-01-01" & year_month <= "2021-12-01" & covid_item == 1 ~ 1))%>%
  mutate_at(c("covid_item_2021"), ~replace_na(., 0))


firm_item_covid_2020 <- firm_item_COVID%>%
  filter(year <= 2020)%>%
  group_by(covid_firm_2015, covid_item_2020)%>%
  dplyr::summarise(num_firm = n_distinct(ID_PARTY))%>%
  ungroup()

firm_item_covid_2020

firm_item_covid_2021 <- firm_item_COVID%>%
  filter(year <= 2021)%>%
  group_by(covid_firm_2015, covid_item_2021)%>%
  dplyr::summarise(num_firm = n_distinct(ID_PARTY))%>%
  ungroup()

firm_item_covid_2021
# thus, there are a good number of firms that sold COVID item in 2015 but did not sell COVID items during COVID. 

# DiD 

# assign observations to group 
firm_item_did <- firm_item %>%
  mutate(covid_firm_2019 = ifelse(year == 2019 & covid_item == 1, 1, 0),
         noncovid_firm_2019 = ifelse(year == 2019 & covid_item != 1, 1, 0),
         nocontract_firm_2019 = ifelse(covid_firm_2019 == 0 & noncovid_firm_2019 == 0, 1, 0))

firm_item_group_covid <- firm_item_did%>%
  group_by(ID_PARTY)%>%
  dplyr::summarise(COVID = sum(covid_firm_2019, na.rm = TRUE))%>%
  ungroup()%>%
  mutate(COVID = ifelse(COVID > 0, "COVID", "Other"))

firm_item_did <- left_join(firm_item_did, firm_item_group_covid, by = "ID_PARTY")

firm_item_group_noncovid <- firm_item_did%>%
  group_by(ID_PARTY)%>%
  dplyr::summarise(NONCOVID = sum(noncovid_firm_2019, na.rm = TRUE))%>%
  ungroup()%>%
  mutate(NONCOVID = ifelse(NONCOVID > 0, "NONCOVID", "Other"))

firm_item_did <- left_join(firm_item_did, firm_item_group_noncovid, by = "ID_PARTY")

firm_item_group_nocontract <- firm_item_did%>%
  group_by(ID_PARTY)%>%
  dplyr::summarise(NOCONTRACT = sum(nocontract_firm_2019, na.rm = TRUE))%>%
  ungroup()%>%
  mutate(NOCONTRACT = ifelse(NOCONTRACT > 0, "NOCONTRACT", "Other"))

firm_item_did <- left_join(firm_item_did, firm_item_group_nocontract, by = "ID_PARTY")

firm_item_did <- firm_item_did %>%
  mutate(Group = ifelse(COVID == "COVID", "COVID",
                        ifelse(NONCOVID == "NONCOVID", "Non-COVID", "No Contract")))


# generate a 2019 unspsc string non
firm_item_2019 <- firm_item_did%>%
  filter(year == 2019)%>%
  select(ID_PARTY, ID_ITEM_UNSPSC)%>%
  distinct()

firm_item_2019 = as.data.table(firm_item_2019)

firm_item_2019 = firm_item_2019[,id := order(ID_ITEM_UNSPSC), by  = ID_PARTY]

firm_item_2019 <- as.data.frame(firm_item_2019)

firm_item_2019$id <- as.character(firm_item_2019$id)

firm_item_2019$sequence <- "a"

firm_item_2019$sequence <- paste0(firm_item_2019$sequence, firm_item_2019$id)

firm_item_string <- firm_item_2019%>%
  select(-id)%>%
  pivot_wider(names_from = sequence, values_from = ID_ITEM_UNSPSC)%>%
  tidyr::unite("unspsc_2019", a1:a99, na.rm = TRUE, remove = FALSE)%>%
  select(ID_PARTY, unspsc_2019)

# flag unspsc that does not occur in 2019 string 
firm_item_did <- left_join(firm_item_did, firm_item_string, by = "ID_PARTY")

firm_item_did$Flag <-  mapply(grepl, firm_item_did$ID_ITEM_UNSPSC, firm_item_did$unspsc_2019)

firm_item_did$unspsc_new <- ifelse(firm_item_did$Flag == "TRUE", 0, 1)


# average number of new product sold since 2020 by semester
firm_item_did$month <- as.numeric(firm_item_did$month)

firm_item_did <- firm_item_did%>%
  mutate(semester = ifelse(month <= 06, "03", "09"))

firm_item_did$semester <- paste0(firm_item_did$year, "-", firm_item_did$semester, "-30")

firm_item_avg_new <- firm_item_did%>%
  filter(year >= 2020 & year <= 2022)%>%
  group_by(ID_PARTY, Group, semester)%>%
  dplyr::summarise(sum_new = sum(unspsc_new, na.rm = TRUE))%>%
  group_by(Group, semester)%>%
  dplyr::summarise(avg_new = mean(sum_new, na.rm = TRUE))%>%
  ungroup()%>%
  ungroup()


ggplot(firm_item_avg_new, aes(x = semester, y = avg_new, group = Group))+
  
  # draw a line graph for two groups
  geom_line(aes(color = Group, linetype = Group, size = Group))+
  
  # set line type separately 
  scale_linetype_manual(values=c("solid", "dotted", "dotdash"))+
  
  # set color separately 
  scale_color_manual(values=c('#FF0100','#18466E', "#66CC99"))+
  
  # set size separately 
  scale_size_manual(values=c(1, 0.8, 0.8))+
  
  # add point plots and define colors 
  geom_point(data = firm_item_avg_new %>% filter(Group == "COVID"), aes(x = semester, y = avg_new), shape = 16, size = 3, color = "#FF0100") +
  geom_point(data = firm_item_avg_new %>% filter(Group == "Non-COVID"), aes(x = semester, y = avg_new), shape = 18, size = 3, color = "#66CC99") +
  geom_point(data = firm_item_avg_new %>% filter(Group == "No Contract"), aes(x = semester, y = avg_new), shape = 17, size = 3, color = "#18466E") +
  
  # add a vertical line to show treatment 
  # geom_vline(xintercept=10.5, color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Tender Publication Date (by Month)", y = "Average Number of New Products Sold", title = "Product Classification",
       subtitle = "Average Number of New Products Sold Since 2020",
       caption ="Note: data retrieved from ONCAE in Mar 2023.")+
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.15, 0.85),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank())+
  
  # add percent to x axis, if needed 
  scale_y_continuous(position = "right")


ggsave(filename = paste0(output, "/product_classification_new_product_2020.jpeg"),
       width = 10,
       height = 8,
       units = c("in"),
       dpi = 300)


# average number of new COVID product 
firm_item_avg_new_COVID <- firm_item_did%>%
  filter(year >= 2020 & year <= 2022)%>%
  mutate(new_COVID = unspsc_new * covid_item)%>%
  group_by(ID_PARTY, Group, semester)%>%
  dplyr::summarise(sum_new = sum(new_COVID, na.rm = TRUE))%>%
  group_by(Group, semester)%>%
  dplyr::summarise(avg_new = mean(sum_new, na.rm = TRUE))%>%
  ungroup()%>%
  ungroup()


ggplot(firm_item_avg_new_COVID, aes(x = semester, y = avg_new, group = Group))+
  
  # draw a line graph for two groups
  geom_line(aes(color = Group, linetype = Group, size = Group))+
  
  # set line type separately 
  scale_linetype_manual(values=c("solid", "dotted", "dotdash"))+
  
  # set color separately 
  scale_color_manual(values=c('#FF0100','#18466E', "#66CC99"))+
  
  # set size separately 
  scale_size_manual(values=c(1, 0.8, 0.8))+
  
  # add point plots and define colors 
  geom_point(data = firm_item_avg_new_COVID %>% filter(Group == "COVID"), aes(x = semester, y = avg_new), shape = 16, size = 3, color = "#FF0100") +
  geom_point(data = firm_item_avg_new_COVID %>% filter(Group == "Non-COVID"), aes(x = semester, y = avg_new), shape = 18, size = 3, color = "#66CC99") +
  geom_point(data = firm_item_avg_new_COVID %>% filter(Group == "No Contract"), aes(x = semester, y = avg_new), shape = 17, size = 3, color = "#18466E") +
  
  
  # add a vertical line to show treatment 
  # geom_vline(xintercept=10.5, color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Tender Publication Date (by Month)", y = "Average Number of New COVID Products Sold", title = "Product Classification",
       subtitle = "Average Number of New COVID Products Sold Since 2020",
       caption ="Note: data retrieved from ONCAE in Mar 2023.")+
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.15, 0.85),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank())+
  
  # add percent to x axis, if needed 
  scale_y_continuous(position = "right")



ggsave(filename = paste0(output, "/product_classification_new_covid_product_2020.jpeg"),
       width = 10,
       height = 8,
       units = c("in"),
       dpi = 300)



# average number of new non-COVID product 
firm_item_avg_new_non_COVID <- firm_item_did%>%
  filter(year >= 2020)%>%
  mutate(new_non_COVID = ifelse(unspsc_new == 1 & covid_item == 0, 1, 0))%>%
  group_by(ID_PARTY, Group, semester)%>%
  dplyr::summarise(sum_new = sum(new_non_COVID, na.rm = TRUE))%>%
  group_by(Group, semester)%>%
  dplyr::summarise(avg_new = mean(sum_new, na.rm = TRUE))%>%
  ungroup()%>%
  ungroup()


ggplot(firm_item_avg_new_non_COVID, aes(x = semester, y = avg_new, group = Group))+
  
  # draw a line graph for two groups
  geom_line(aes(color = Group, linetype = Group, size = Group))+
  
  # set line type separately 
  scale_linetype_manual(values=c("solid", "dotted", "dotdash"))+
  
  # set color separately 
  scale_color_manual(values=c('#FF0100','#18466E', "#66CC99"))+
  
  # set size separately 
  scale_size_manual(values=c(1, 0.8, 0.8))+
  
  # add point plots and define colors 
  geom_point(data = firm_item_avg_new_non_COVID %>% filter(Group == "COVID"), aes(x = semester, y = avg_new), shape = 16, size = 3, color = "#FF0100") +
  geom_point(data = firm_item_avg_new_non_COVID %>% filter(Group == "Non-COVID"), aes(x = semester, y = avg_new), shape = 18, size = 3, color = "#66CC99") +
  geom_point(data = firm_item_avg_new_non_COVID %>% filter(Group == "No Contract"), aes(x = semester, y = avg_new), shape = 17, size = 3, color = "#18466E") +
  
  
  
  # add a vertical line to show treatment 
  # geom_vline(xintercept=10.5, color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Tender Publication Date (by Month)", y = "Average Number of New Non-COVID Products Sold", title = "Product Classification",
       subtitle = "Average Number of New Non-COVID Products Sold Since 2020",
       caption ="Note: data retrieved from ONCAE in Mar 2023.")+
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.15, 0.85),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank())+
  
  # add percent to x axis, if needed 
  scale_y_continuous(position = "right")


ggsave(filename = paste0(output, "/product_classification_new_non_covid_product_2020.jpeg"),
       width = 10,
       height = 8,
       units = c("in"),
       dpi = 300)






# 4 market concentration --------------------------------- 
# Market concentration 

# merging in COVID tender  
contract_supplier <- left_join(contract_supplier, covid_tender,
                               by = "ID")          # note: 100% merge 

# Month version 

# # Create month 
# contract_supplier$month <- strftime(contract_supplier$DT_CONTRACT_SIGNED, "%m")
# 
# contract_supplier$year <- strftime(contract_supplier$DT_CONTRACT_SIGNED, "%Y")
# 
# contract_supplier$contract_sign_month <- as.Date(paste0(contract_supplier$year, "-", contract_supplier$month, "-01"))
# 
# contract_supplier$quarter <- lubridate::quarter(contract_supplier$DT_CONTRACT_SIGNED)
# 
# contract_supplier$quarter <- ifelse(contract_supplier$quarter == 1, "01-01", 
#                                     ifelse(contract_supplier$quarter == 2, "04-01",
#                                            ifelse(contract_supplier$quarter == 3, "07-01",
#                                                   ifelse(contract_supplier$quarter == 4, "10-01", NA))))
# 
# contract_supplier$contract_sign_quarter  <- as.Date(paste0(contract_supplier$year, "-", contract_supplier$quarter))
# 
# # clean contract amount values 
# contract_supplier$AMT_CONTRACT_VALUE_USD[contract_supplier$AMT_CONTRACT_VALUE_USD == 0] <- NA
# 
# contract_supplier$AMT_CONTRACT_VALUE_USD <- as.numeric(contract_supplier$AMT_CONTRACT_VALUE_USD)
# 
# 
# # flag the top 3 suppliers in each sector (covid/non-covid)
# market_concentration <- contract_supplier%>%
#   filter(contract_sign_quarter >= as.Date("2015-01-01")&
#            contract_sign_quarter < as.Date("2022-08-01"))%>%
#   dplyr::rename(Group = covid_tender)%>%
#   # 191 contracts cannot be identified whether COVID or not 
#   filter(!is.na(Group))
# 
# check <- market_concentration%>%
#   filter(is.na(AMT_CONTRACT_VALUE_USD))    # 878 out of 35344 contracts has missing contract value 
# 
# # calculate sector(COVID/nonCOVID) total 
# sector_total <- market_concentration%>%
#   group_by(Group, contract_sign_quarter)%>%
#   dplyr::summarise(sector_total = sum(AMT_CONTRACT_VALUE_USD, na.rm = TRUE),
#             num_contract = n())%>%
#   ungroup()
# 
# # calculate firm total 
# firm_total <- market_concentration%>%
#   group_by(Group, contract_sign_quarter, ID_SUPPLIER)%>%
#   dplyr::summarise(firm_total = sum(AMT_CONTRACT_VALUE_USD, na.rm = TRUE),
#                    num_contract = n())%>%
#   ungroup()
#     # @team: some suppliers have many contracts in one months, but the value of those contracts is missing. 
#     # Also, check HN-RTN-0107956011840. It is an example of this. And it is a medical-nonCOVID firm. Neglecting firms like this could bias our result. 
# 
# # aggregate to firm-sector level 
# firm_sector_total <- firm_total%>%
#   left_join(sector_total, by = c("Group", "contract_sign_quarter"), suffix = c("_firm", "_sector"))
# 
# # select top 3 firms and calculate their share 
# firm_sector_total <-firm_sector_total%>%
#   group_by(Group, contract_sign_quarter)%>%
#   arrange(Group, contract_sign_quarter, desc(firm_total))%>%
#   dplyr::mutate(firm_share = (firm_total/sector_total),
#          rank = row_number())%>%
#   ungroup()
# 
# firm_sector_total_top3 <- firm_sector_total%>%
#   filter(rank <= 3)%>%
#   group_by(Group, contract_sign_quarter)%>%
#   dplyr::summarise(top3_share = sum(firm_share))%>%
#   ungroup()
#     # note: there was only 1 firm in May 2022 and 2 firms in July 2022, should we adjust the time period of interest? 
#     # @team: should we also do an analysis using the number of contracts? As there are a large number of contracts that have missing total value 
# 
# # plot
# firm_sector_total_top3$Group <- replace(firm_sector_total_top3$Group, firm_sector_total_top3$Group == 0, "Non-COVID")
# 
# firm_sector_total_top3$Group <- replace(firm_sector_total_top3$Group, firm_sector_total_top3$Group == 1, "COVID")



# definition:the market share of the top 3 suppliers in each sector per semester (ranking firms by total market value of their items)
# contract_signature, by semester 

# Create semester 
contract_supplier$month <- as.numeric(strftime(contract_supplier$DT_CONTRACT_SIGNED, "%m"))

contract_supplier$year <- as.numeric(strftime(contract_supplier$DT_CONTRACT_SIGNED, "%Y"))

contract_supplier$contract_sign_month <- as.Date(paste0(contract_supplier$year, "-", contract_supplier$month, "-01"))


contract_supplier <- contract_supplier%>%
  
  mutate(semester = ifelse(month <= 6, "03", "09"))


contract_supplier$semester <- paste0(contract_supplier$year, "-", contract_supplier$semester, "-30")


# clean contract amount values 
contract_supplier$AMT_CONTRACT_VALUE_USD[contract_supplier$AMT_CONTRACT_VALUE_USD == 0] <- NA

contract_supplier$AMT_CONTRACT_VALUE_USD <- as.numeric(contract_supplier$AMT_CONTRACT_VALUE_USD)


# flag the top 3 suppliers in each sector (covid/non-covid)
market_concentration <- contract_supplier%>%
  filter(year >= 2015 &
           year <= 2022)%>%
  dplyr::rename(Group = covid_firm)%>%
  # 191 contracts cannot be identified whether COVID or not 
  filter(!is.na(Group))

check <- market_concentration%>%
  filter(is.na(AMT_CONTRACT_VALUE_USD))    # 878 out of 35344 contracts has missing contract value 

# calculate sector(COVID/nonCOVID) total 
sector_total <- market_concentration%>%
  group_by(Group, semester)%>%
  dplyr::summarise(sector_total = sum(AMT_CONTRACT_VALUE_USD, na.rm = TRUE),
                   num_contract = n())%>%
  ungroup()

# calculate firm total 
firm_total <- market_concentration%>%
  group_by(Group, semester, ID_SUPPLIER)%>%
  dplyr::summarise(firm_total = sum(AMT_CONTRACT_VALUE_USD, na.rm = TRUE),
                   num_contract = n())%>%
  ungroup()
# @team: some suppliers have many contracts in one months, but the value of those contracts is missing. 
# Also, check HN-RTN-0107956011840. It is an example of this. And it is a medical-nonCOVID firm. Neglecting firms like this could bias our result. 

# aggregate to firm-sector level 
firm_sector_total <- firm_total%>%
  left_join(sector_total, by = c("Group", "semester"), suffix = c("_firm", "_sector"))

# select top 3 firms and calculate their share 
firm_sector_total <-firm_sector_total%>%
  group_by(Group, semester)%>%
  arrange(Group, semester, desc(firm_total))%>%
  dplyr::mutate(firm_share = (firm_total/sector_total),
                rank = row_number())%>%
  ungroup()

firm_sector_total_top3 <- firm_sector_total%>%
  filter(rank <= 3)%>%
  group_by(Group, semester)%>%
  dplyr::summarise(top3_share = sum(firm_share))%>%
  ungroup()
# note: there was only 1 firm in May 2022 and 2 firms in July 2022, should we adjust the time period of interest? 
# @team: should we also do an analysis using the number of contracts? As there are a large number of contracts that have missing total value 

# plot
firm_sector_total_top3$Group <- replace(firm_sector_total_top3$Group, firm_sector_total_top3$Group == 0, "Non-COVID")

firm_sector_total_top3$Group <- replace(firm_sector_total_top3$Group, firm_sector_total_top3$Group == 1, "COVID")


ggplot(firm_sector_total_top3, aes(x = semester, y = top3_share, group = Group))+
  
  # draw a line graph for two groups
  geom_line(aes(color = Group, linetype = Group, size = Group))+
  
  # set line type separately 
  scale_linetype_manual(values=c("solid", "dotted"))+
  
  # set color separately 
  scale_color_manual(values=c('#FF0100','#18466E'))+
  
  # set size separately 
  scale_size_manual(values=c(1, 0.8))+
  
  # add point plots and define colors 
  geom_point(data = firm_sector_total_top3 %>% filter(Group == "COVID"), aes(x = semester, y = top3_share), shape = 16, size = 3, color = "#FF0100") +
  geom_point(data = firm_sector_total_top3 %>% filter(Group == "Non-COVID"), aes(x = semester, y = top3_share), shape = 18, size = 4, color = "#18466E") +
  
  # add a vertical line to show treatment 
  geom_vline(xintercept=10.5, color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Tender Publication Date (aggregate by semester)", y = "Market Share of Top 3 Firms (%)", title = "Market Concentration",
       subtitle =  "The Market Share of Top 3 Suppliers in Each Semester from Jan 2015 to Jul 2022",
       caption = "Note: data retrieved from ONCAE in Mar 2023.The graph excludes the contracts that have top 1% total value as those contracts appears to be mistake.")+
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.2, 0.85),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank())+
  
  # add percent to x axis, if needed 
  scale_y_continuous(position = "right", labels = scales::percent_format(accuracy = 1))


ggsave(filename = paste0(output, "/Market_concentration.jpeg"),
       width = 10,
       height = 8,
       units = c("in"),
       dpi = 300)




# 5 duration --------------------------------------------------------

# Time Related Variables 

# Total processing time: contract signature - tender initiation 
# Submission time: submission deadline - tender initiation
# Decision time: contract signature - submission deadline

# calculate variables at contract level 
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


# check the overlap between contract signature, contract start and end date 
tender_contract <- as.data.table(tender_contract)

check <- tender_contract[,.N, by = "publication_start"] # not consistent 

check <- tender_contract[,.N, by = "submission_time"]   # consistent: end > start 

check <- tender_contract[,.N, by = "processing_time"]   # consistent: signature > start 

check <- tender_contract[,.N, by = "decision_time"]     # consistent: signature > end 

# add group dummy 
tender_contract <- left_join(tender_contract, covid_tender,
                             by = "ID")
# 221 observations are not in item level data (covid tender was created from supplier item data as we use UNSPSC to identify COVID related or not)

tender_contract <- tender_contract%>%
  dplyr::rename(Group = covid_tender)%>%
  # drop contracts that cannot link to item level data (in other words, those tenders only have contract data but don't have item data)
  filter(!is.na(Group))

tender_contract$Group <- replace(tender_contract$Group, tender_contract$Group == 0, "Non-COVID")

tender_contract$Group <- replace(tender_contract$Group, tender_contract$Group == 1, "COVID")

# add semester dummy
tender_contract$year_month <- as.Date(paste0(tender_contract$year, "-", tender_contract$month, "-01"))

tender_contract$month <- as.numeric(strftime(tender_contract$DT_TENDER_PUB, "%m"))

tender_contract$year <- as.numeric(strftime(tender_contract$DT_TENDER_PUB, "%Y"))


tender_contract <- tender_contract%>%
  
  mutate(semester = ifelse(month <= 6, "03", "09"))


tender_contract$semester <- paste0(tender_contract$year, "-", tender_contract$semester, "-30")


# submission time: submission deadline - tender initiation in relation to tender inquiry start

# tender_contract$tender_pub_semester <- strftime(tender_contract$DT_TENDER_START, "%m")
# 
# tender_contract$tender_start_year <- strftime(tender_contract$DT_TENDER_START, "%Y")
# 
# tender_contract$tender_start_year_month <- as.Date(paste0(tender_contract$tender_start_year, "-", tender_contract$tender_start_month, "-01"))

submission_time <- tender_contract%>%
  filter(year >= 2015 &
           year <= 2022)%>%
  group_by(semester , Group)%>%
  dplyr::summarise(submission_time_avg = mean(submission_time))%>%
  ungroup()


# @team: check the caption - there should be a way to improve this graph. It would be misleading if we are trying to tell whether submission time increase or decrease from this graph.
# there are large outliers in 2015 and 2020, but this graph cannot show that 


ggplot(submission_time, aes(x = semester , y = submission_time_avg, group = Group))+
  
  # draw a line graph for two groups
  geom_line(aes(color = Group, linetype = Group, size = Group))+
  
  # set line type separately 
  scale_linetype_manual(values=c("solid", "dotted"))+
  
  # set color separately 
  scale_color_manual(values=c('#FF0100','#18466E'))+
  
  # set size separately 
  scale_size_manual(values=c(1, 0.8))+
  
  # add point plots and define colors 
  geom_point(data = submission_time %>% filter(Group == "COVID"), aes(x = semester , y = submission_time_avg), shape = 16, size = 3, color = "#FF0100") +
  geom_point(data = submission_time %>% filter(Group == "Non-COVID"), aes(x = semester , y = submission_time_avg), shape = 18, size = 4, color = "#18466E") +
  
  # add a vertical line to show treatment 
  geom_vline(xintercept=10.5, color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Tender Publication Date (aggregate by semester)", y = "Submission Time (days)", 
       title = "Submission Time",
       subtitle = "Average Number of Days from Tender Inquiry Start to Tender Inquiry End from Jan 2015 to Aug 2022",
       caption = "Note: data retrieved from ONCAE in Mar 2023.the peak in COVID submission time was a contract signed in May 2022. The reason is that there was only 1 contract signed in May 2022.
                        \nAs the other months have many contracts with extremely low submission time (below 10 days), the impact of outliers (100+days) was cancelled out.")+
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.2, 0.85),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank()) + 
  
  # add percent to x axis, if needed 
  scale_y_continuous(position = "right")


ggsave(filename = paste0(output, "/Submission_time.jpeg"),
       width = 10,
       height = 8,
       units = c("in"),
       dpi = 300)


# process time: contract signature - tender initiation // tender inquiry start
processing_time <- tender_contract%>%
  filter(year >= 2015 &
           year <= 2022)%>%
  group_by(semester , Group)%>%
  dplyr::summarise(processing_time_avg = mean(processing_time))%>%
  ungroup()


ggplot(processing_time, aes(x = semester, y = processing_time_avg, group = Group))+
  
  # draw a line graph for two groups
  geom_line(aes(color = Group, linetype = Group, size = Group))+
  
  # set line type separately 
  scale_linetype_manual(values=c("solid", "dotted"))+
  
  # set color separately 
  scale_color_manual(values=c('#FF0100','#18466E'))+
  
  # set size separately 
  scale_size_manual(values=c(1, 0.8))+
  
  # add point plots and define colors 
  geom_point(data = processing_time %>% filter(Group == "COVID"), aes(x = semester, y = processing_time_avg), shape = 16, size = 3, color = "#FF0100") +
  geom_point(data = processing_time %>% filter(Group == "Non-COVID"), aes(x = semester, y = processing_time_avg), shape = 18, size = 4, color = "#18466E") +
  
  # add a vertical line to show treatment 
  geom_vline(xintercept=10.5, color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Tender Publication Date (aggregate by semester)", y = "Processing Time (days)", 
       title = "Processing Time",
       subtitle = " Average Number of Days from Tender Inquiry Start to Contract Signature Date from Jan 2015 to Aug 2022",
       caption = "Note: data retrieved from ONCAE in Mar 2023.")+
  
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.2, 0.85),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank()) + 
  
  # add percent to x axis, if needed 
  scale_y_continuous(position = "right")


ggsave(filename = paste0(output, "/Processing_time.jpeg"),
       width = 10,
       height = 8,
       units = c("in"),
       dpi = 300)


# decision time: contract signature - submission deadline in relation to submission deadline 

# tender_contract$tender_end_month <- strftime(tender_contract$DT_TENDER_END, "%m")
# 
# tender_contract$tender_end_year <- strftime(tender_contract$DT_TENDER_END, "%Y")
# 
# tender_contract$tender_end_year_month <- as.Date(paste0(tender_contract$tender_end_year, "-", tender_contract$tender_end_month, "-01"))

decision_time <- tender_contract%>%
  filter(year >= 2015 &
           year <= 2022)%>%
  group_by(semester, Group)%>%
  dplyr::summarise(decision_time_avg = mean(decision_time))%>%
  ungroup()


# @team: it seems the surge in processing and decision times after Jan 2022 was not driven by outliers. Why is that? 
# Is it true that it takes longer time to process and make decisions on both COVID and non-COVID procurements in 2022?


ggplot(decision_time, aes(x = semester, y = decision_time_avg, group = Group))+
  
  # draw a line graph for two groups
  geom_line(aes(color = Group, linetype = Group, size = Group))+
  
  # set line type separately 
  scale_linetype_manual(values=c("solid", "dotted"))+
  
  # set color separately 
  scale_color_manual(values=c('#FF0100','#18466E'))+
  
  # set size separately 
  scale_size_manual(values=c(1, 0.8))+
  
  # add point plots and define colors 
  geom_point(data = decision_time %>% filter(Group == "COVID"), aes(x = semester, y = decision_time_avg,), shape = 16, size = 3, color = "#FF0100") +
  geom_point(data = decision_time %>% filter(Group == "Non-COVID"), aes(x = semester, y = decision_time_avg,), shape = 18, size = 4, color = "#18466E") +
  
  # add a vertical line to show treatment 
  geom_vline(xintercept=10.5, color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Tender Publication Date (aggregate by semester)", y = "Decision Time (days)", 
       title = "Decision Time",
       subtitle = "Number of Days from Tender Inquiry End to Contract Signature Date from Jan 2015 to Aug 2022",
       caption = "Note: data retrieved from ONCAE in Mar 2023.")+
  
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.2, 0.85),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank()) + 
  
  # add percent to x axis, if needed 
  scale_y_continuous(position = "right")

ggsave(filename = paste0(output, "/Decision_time.jpeg"),
       width = 10,
       height = 8,
       units = c("in"),
       dpi = 300)



# 6 characteristic of winners ----------------------------------------------
## NEW WINNERS - construct with contract signature 

# New winner: tender publication date and contract signature date for previous contracts 
# x: tender publication date 
# y: number of new winners 
# the share of new winners: new winners// all contracts 


# Identify new winners 

# calculate time lag 
contract_supplier <- as.data.table(contract_supplier)

contract_supplier = contract_supplier[order(DT_TENDER_PUB), lag_date:= shift(DT_CONTRACT_SIGNED, n=1, type="lag"), by="ID_SUPPLIER"]

# calculate how many days between previous contract signature date and tender publication date 
contract_supplier$lag_date <- as_datetime(contract_supplier$lag_date, tz = lubridate::tz(contract_supplier$lag_date))

contract_supplier$diff_days_contract <- interval(contract_supplier$lag_date, contract_supplier$DT_TENDER_PUB) %/% days(1)

# calculate the number of months from the previous contract by the same firm 
contract_supplier$diff_months_contract <- interval(contract_supplier$lag_date, contract_supplier$DT_CONTRACT_SIGNED) %/% months(1)

# identity new winners by days 
contract_supplier <- as.data.frame(contract_supplier)

contract_supplier <- contract_supplier%>%
  mutate(new_winner = case_when(is.na(diff_days_contract) ~ 1 ,
                                diff_days_contract > 365 ~ 1 ,
                                TRUE ~ 0 ))
# add semester dummy 
contract_supplier$month <- as.numeric(strftime(contract_supplier$DT_TENDER_PUB, "%m"))

contract_supplier$year <- as.numeric(strftime(contract_supplier$DT_TENDER_PUB, "%Y"))

# contract_supplier$tender_pub_month <- as.Date(paste0(contract_supplier$year, "-", contract_supplier$month, "-01"))


contract_supplier <- contract_supplier%>%
  
  mutate(semester = ifelse(month <= 6, "03", "09"))


contract_supplier$semester <- paste0(contract_supplier$year, "-", contract_supplier$semester, "-30")


# # summary statistics by month 
# new_winner_month <- contract_supplier%>%
#   filter(tender_pub_month >= "2015-01-01")%>%
#   group_by(tender_pub_month)%>%
#   dplyr::summarise(num_new_winner = sum(new_winner))%>%
#   ungroup()
# 
# new_winner_month
# 
# # summary statistics by year 
# new_winner_year <- contract_supplier%>%
#   filter(year >= 2015 & 
#            year <= 2022)%>%

#   group_by(YEAR)%>%
#   dplyr::summarise(num_new_winner = sum(new_winner),
#                    num_contract   = n_distinct(ID_CONTRACT))%>%
#   mutate(share_new_winner = num_new_winner/num_contract)%>%
#   ungroup()
# 
# new_winner_year     

# YEAR num_new_winner
# <int>          <dbl>
# 1  2018          13060
# 2  2015          13558
# 3  2020           3694
# 4  2021           7352
# 5  2022            866
# 6  2025              1


# add Group dummy (merge covid firm ID to firm level data)
contract_supplier <- left_join(contract_supplier, covid_firm,
                               by = c("ID_SUPPLIER" = "ID_PARTY"))          # note: 100% merge 

# summary statistics 
new_winner_month_group <- contract_supplier%>%
  dplyr::rename(Group = covid_firm)%>%
  filter(year >= 2016 &
           year <= 2022)%>%
  filter(!is.na(Group))%>%
  group_by(semester, Group)%>%
  dplyr::summarise(num_new_winner = sum(new_winner),
                   num_contract   = n_distinct(ID_CONTRACT))%>%
  mutate(share_new_winner = num_new_winner/num_contract)%>%
  ungroup()

new_winner_month_group$Group <- replace(new_winner_month_group$Group, new_winner_month_group$Group == 0, "Non-COVID")

new_winner_month_group$Group <- replace(new_winner_month_group$Group, new_winner_month_group$Group == 1, "COVID")


# visualization 
ggplot(new_winner_month_group, aes(x = semester, y = share_new_winner, group = Group))+
  
  # draw a line graph for two groups
  geom_line(aes(color = Group, linetype = Group, size = Group))+
  
  # set line type separately 
  scale_linetype_manual(values=c("solid", "dotted"))+
  
  # set color separately 
  scale_color_manual(values=c('#FF0100','#18466E'))+
  
  # set size separately 
  scale_size_manual(values=c(1, 0.8))+
  
  # add point plots and define colors 
  geom_point(data = new_winner_month_group %>% filter(Group == "COVID"), aes(x = semester, y = share_new_winner), shape = 16, size = 3, color = "#FF0100") +
  geom_point(data = new_winner_month_group %>% filter(Group == "Non-COVID"), aes(x = semester, y = share_new_winner), shape = 18, size = 4, color = "#18466E") +
  
  # add a vertical line to show treatment 
  geom_vline(xintercept= 8.5, color = "gray80", alpha = 0.5, size = 1, linetype = 2)+
  
  # geom_segment(aes(x = 4, y = 15, xend = 4, yend = 27))+
  
  # set the theme, including background, and present the axis of the line graphs 
  theme(
    aspect.ratio = 3.2/7,
    text = element_text(family = "Roboto"),
    plot.margin = margin(0, 5, 0, 5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "darkgrey"),
    axis.ticks.length = unit(.25, "cm"),
    # legend.text = element_blank(),
    # legend.title = element_blank(),
    legend.key.width = unit(25,"pt"),
    legend.key.height = unit(15, "pt"),
    axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
    axis.text.y = ggtext::element_markdown(size = 12, color = "black"),
    axis.line.x  = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
    plot.caption = element_text(hjust = 0, size = 9),
    plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5))+
  
  # change title and subtitles 
  labs(x = "Tender Publication Date (aggregate by semester)", y = "Share of New Winners (%)", title = "Share of New Winners Jan 2015 - Aug 2022",
       caption = "Note: data retrieved from ONCAE in Mar 2023.")+
  
  # add legend to the middle of the graph 
  theme(legend.position = c(0.2, 0.85),
        legend.background = element_rect(fill = "white"))+
  theme(plot.caption = element_text(hjust = 0))+
  
  # set the background of the legend as blank. ps. you have to add this for line graphs 
  theme(legend.key=element_blank())+
  
  # add percent to x axis, if needed 
  scale_y_continuous(position = "right", labels = scales::percent_format(accuracy = 1))


ggsave(filename = paste0(output, "/New_winner_per_month.jpeg"),
       width = 9,
       height = 5.75,
       units = c("in"),
       dpi = 600,
       device = 'jpeg')


# annotate(geom = "text", x= as.Date("2020-9-01"), y = 50, label = "Dec 2020")+
# annotate("segment", x = as.Date("2020-11-01"), xend = as.Date("2020-12-01"), y = 50, yend = 50, colour = "darkgray", size=1, alpha=1)+
# annotate(geom = "text", x= as.Date("2021-06-01"), y = 147, label = "Sept 2021")+
# annotate("segment", x = as.Date("2021-08-01"), xend = as.Date("2021-09-01"), y = 147, yend = 147, colour = "darkgray", size=1, alpha=1)+

















