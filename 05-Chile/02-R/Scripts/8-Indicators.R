# Load data ---------------------------------------------------------------

options(digits = 2)  

{
  
  # Cleaned DATA
  
  # List of all files from data compiled folders
  files_to_load <- list.files(paste0(dropbox_dir, "3 - data_clean/1-data_cleaned"))
  
  # Load all the data
  for (file in files_to_load) {
    
    data <- readRDS(paste0(dropbox_dir, "3 - data_clean/1-data_cleaned/", file))
    
    assign(substr(file, 0, nchar(file) - 4), data)
    
    rm(data)
    
  }
  
}

# Number of bidders per tender
n_bidders <- data_offer_sub %>% 
  group_by(ID_TENDER, ID_ITEM, ID_ITEM_UNSPSC) %>% 
  dplyr::summarise(
    n_bidders = n()
  )

# Number of bidders per tender
first_winnners <- data_offer_sub %>% 
  filter(IND_OFFER_WIN == 1) %>% 
  group_by(ID_RUT_PARTICIPANT) %>% 
  slice(n = 1) %>% 
  select(ID_TENDER, ID_ITEM, ID_ITEM_UNSPSC) %>% 
  mutate(
    first_winner = 1
  )

# Same municipality + sme information at supplier level
data <- read_dta("/Users/ruggerodoino/Dropbox/ChilePaymentProcurement/Data/SII/SII_2015_2020.dta")

data <- data %>% 
  mutate(
    msme = ifelse(micro == 1 | small == 1, 1, 0)
  ) %>% 
  distinct(rut, year, province, commune, msme)

# Time to last bid (months)
test <- data_offer_sub %>% 
  distinct(ID_RUT_PARTICIPANT, ID_TENDER, ID_ITEM, DT_OFFER_SEND) %>% 
  mutate(
    YEAR   = as.numeric(substr(DT_OFFER_SEND, 0, 4))  ,
    MONTH  = as.numeric (substr(DT_OFFER_SEND, 6, 7)),
    MONTHS = YEAR * 12 + MONTH
    
  ) %>% 
  distinct(ID_RUT_PARTICIPANT, ID_TENDER, MONTHS) %>% 
  arrange(
    MONTHS, ID_RUT_PARTICIPANT
  ) %>% 
  group_by(ID_RUT_PARTICIPANT) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>% 
  replace_na(list(before_date = 0)) %>% 
  mutate(LAST_BID_MONTHS = MONTHS - before_date)

# Time to last bid (months)
test_1 <- data_offer_sub %>% 
  distinct(ID_RUT_PARTICIPANT, ID_TENDER, ID_ITEM, DT_OFFER_SEND) %>% 
  mutate(
    YEAR   = as.numeric(substr(DT_OFFER_SEND, 0, 4))  ,
    MONTH  = as.numeric (substr(DT_OFFER_SEND, 6, 7)),
    MONTHS = YEAR * 12 + MONTH
    
  ) %>% 
  distinct(ID_RUT_PARTICIPANT, ID_TENDER, MONTHS) %>% 
  arrange(
    MONTHS, ID_RUT_PARTICIPANT
  ) %>% 
  group_by(ID_RUT_PARTICIPANT) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  replace_na(list(LAST_BID_MONTHS = 1000000))

# Time to last bid (months)
test_2 <- data_offer_sub %>% 
  filter(IND_OFFER_WIN == 0) %>% 
  distinct(ID_RUT_PARTICIPANT, ID_TENDER, ID_ITEM, DT_OFFER_SEND) %>% 
  mutate(
    YEAR   = as.numeric(substr(DT_OFFER_SEND, 0, 4))  ,
    MONTH  = as.numeric (substr(DT_OFFER_SEND, 6, 7)),
    MONTHS = YEAR * 12 + MONTH
    
  ) %>% 
  distinct(ID_RUT_PARTICIPANT, ID_TENDER, MONTHS) %>% 
  arrange(
    MONTHS, ID_RUT_PARTICIPANT
  ) %>% 
  group_by(ID_RUT_PARTICIPANT) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  replace_na(list(LAST_BID_MONTHS = 1000000))


