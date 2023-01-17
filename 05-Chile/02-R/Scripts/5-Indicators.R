# Load data ---------------------------------------------------------------

options(digits = 2)  

{
  
  # Cleaned DATA
  
  {
    
    # Load cleaned tender data
    data_offer_sub <- readRDS(file = file.path(fin_data, "data_offer_sub.rds"))
    
  }
  
}

# Same municipality + sme information at supplier level
data <- read_dta("/Users/ruggerodoino/Dropbox/ChilePaymentProcurement/Data/SII/SII_2015_2020.dta")

data <- data %>% 
  mutate(
    msme = ifelse(micro == 1 | small == 1, 1, 0)
  ) %>% 
  distinct(rut, year, province, commune, msme)



