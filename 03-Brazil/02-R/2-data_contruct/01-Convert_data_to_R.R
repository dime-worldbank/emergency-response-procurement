# Made by Leandro Veloso
# main: Convert Stata dta files to rds

# 0: Setting R ----
{
  # Loading package
  {
    packages <- 
      c( 
        # 01: Classic packages for data manipulation
        "tidyverse",
        "data.table",
        "haven"
      ) 
    
    # Leitura dos pacotes e dependencias
    if (!require("pacman")) install.packages("pacman")
    
    # Loading list of packages
    pacman::p_load(packages,
                   character.only = TRUE,
                   install = TRUE)
  } 
  
  # Setting path
  path_stata <- "C:/Users/leand/Dropbox/3-Profissional/07-World BANK/04-procurement/06-Covid_Brazil/1_data"
  path_r     <- "C:/Users/leand/Dropbox/3-Profissional/07-World BANK/04-procurement/06-Covid_Brazil/1_data"
  
  # Changing path
  setwd(path_stata)
  
  # Set of files
  file_list <-
    c("01-tender_data", 
      "02-firm_caracteristcs", 
      "03-covid_item-item_level", 
      "04-participants_data", 
      "05-winners_data")
}

# 1: Converting to R ----
for (file in file_list) { 
  print(file)
  
  # Reading and saving
  read_dta(paste0(path_stata,"/",file,".dta")) %>%
    saveRDS(paste0(path_stata,"/",file,".rds"))
}
