# Load data ---------------------------------------------------------------
  
  { 
    
    # E-PROCUREMENT DATA
    
      # List of all files from data compiled folders
      files_to_load <- list.files(file.path(dropbox_dir, path_imp, "2-data_compiled"), pattern = "-")
      
      # Load all the data
      for (file in files_to_load) {
        
        data <- readRDS(file.path(dropbox_dir, path_imp, "2-data_compiled", file))
        
        assign(paste0("data_",substr(file, 0, nchar(file) - 9),"_",substr(file, str_locate(file, "-")[1] + 1, nchar(file) - 4)), data)
       
      }
      
      # Download supplementary data
      download.file("https://transparenciachc.blob.core.windows.net/oc-da/hist_moneda_H_vs_I.csv", destfile = paste0(dropbox_dir, "2 - data_construct/1-data_temp/currency.csv"))
      download.file("https://transparenciachc.blob.core.windows.net/oc-da/hist_OC_erroneas.csv"  , destfile = paste0(dropbox_dir, "2 - data_construct/1-data_temp/amount.csv"))
      download.file("https://transparenciachc.blob.core.windows.net/oc-da/ParidadMoneda.csv"     , destfile = paste0(dropbox_dir, "2 - data_construct/1-data_temp/currency_conversion.csv"))
      
      # Load data
      currency_issues     <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/currency.csv"    ), encoding = "Latin-1", colClasses = "character")
      amount_issues       <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/amount.csv"), encoding = "Latin-1", colClasses = "character")
      currency_conversion <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/currency_conversion.csv"), encoding = "Latin-1", colClasses = "character")
      
      
    # COVID-19 EMERGENCY PORTAL DATA

      # Download the covid-19 procurement list
      download.file("https://transparenciachc.blob.core.windows.net/covid/OC_COVID.zip"          , destfile = paste0(dropbox_dir, "2 - data_construct/1-data_temp/COVID19.zip"))
      
      # Unzip 
      unzip(paste0(dropbox_dir, "2 - data_construct/1-data_temp/COVID19.zip"), exdir = paste0(dropbox_dir, "2 - data_construct/1-data_temp"    ))
      
      # Load COVID-19 data
      tender_covid   <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/OC_COVID19.csv"    ), encoding = "Latin-1", colClasses = "character")
      item_covid     <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/OCItem_COVID19.csv"), encoding = "Latin-1", colClasses = "character")
      
  }


# Adjusting datasets ------------------------------------------------------

  {
    
    # Create a pooled tender-level dataset from 2015 to 2021 
    
    for (level in c("tender","lot","offer")) {
      
      assign("data" , get(paste0("data_", level, "_2015")))
      
      for (year in seq(2016, 2021)) {
        
        # Assign each data frame to the same name
        assign("data_to_append", get(paste0("data_", level, "_", year)))
        
        # Remove the old data frame
        rm(list = paste0("data_", level, "_", year))
        
        # Append the data frame to the old one
        data <- rbind(data, data_to_append)
        
      }
      
      # Assign new name to the final data frame 
      assign(paste0("data_", level), data)
      
      # Remove the first data frame 2015
      rm(list = paste0("data_", level, "_2015"))
      
    }
    
    
  }
  
# Explanatory Data Analysis -----------------------------------------------

  {
    

    
  }
 
 
# Label the tenders from 2022
tender_covid$year_2022  <- ifelse(tender_covid$ID %in% data_2022$tender_code, 1, 0)

# Change name of columns for ID
colnames(tender_covid)[3] <- "ID"
colnames(item_covid)[3]   <- "ITEM_ID"

 # Label treatment vs control ----------------------------------------------
 
   {

     # Add a variable to identify which tenders are covid-emergency related
     for (year in seq(2015, 2022)) {

       for (level in c("tender","lot","offer")) {

         # load the data
         data <- readRDS(paste0(dropbox_dir, "2 - data_construct/2-data_compiled/", level, "-", year,".rds"))

         # add the variable based on the ID from the covid-19 dataset
         data <- data %>%
           mutate(
             tender_covid_19 = ifelse(tender_code %in% tender_covid$ID, 1, 0)
           )

         # Save the new data
         saveRDS(data, paste0(dropbox_dir, "2 - data_construct/2-data_compiled/", level, "-", year,".rds"))

         # Clean the data from the workspace
         rm(data)

       }

     }

     # Add a variable to identify which products are covid-related
     for (year in seq(2015, 2022)) {

       # load the data
       data <- readRDS(paste0(dropbox_dir, "2 - data_construct/2-data_compiled/lot-", year,".rds"))

       # add the variable based on the ID from teh covid-19 dataset
       data <- data %>%
         mutate(
           tender_covid_19   = ifelse(data$tender_code %in% item_covid$ITEM_ID, 1, 0),
           medical_equipment = ifelse(substr(data$lot_code_onu, 0, 2) == 42, 1, 0)
         )

       # Save the new data
       saveRDS(data, paste0(dropbox_dir, "2 - data_construct/2-data_compiled/lot-", year,".rds"))

       # Clean the data from the workspace
       rm(data)

     }

   }




