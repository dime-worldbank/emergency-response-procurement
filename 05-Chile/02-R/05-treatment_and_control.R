{
  
  # Read all the procurement data
  data_2020 <- readRDS(paste0(dropbox_dir, "2 - data_construct/2-data_compiled/tender-2020.rds"))
  data_2021 <- readRDS(paste0(dropbox_dir, "2 - data_construct/2-data_compiled/tender-2021.rds"))
  data_2022 <- readRDS(paste0(dropbox_dir, "2 - data_construct/2-data_compiled/tender-2022.rds"))
  
  # Join all the previous datasets together  
  data_tenders <- rbind(data_2020, data_2021)
  data_tenders <- rbind(data_tenders, data_2022)
  
  # Delete old datasets
  rm(data_2020, data_2021, data_2022)
  
  # Download the covid-19 procurement list
  download.file("https://transparenciachc.blob.core.windows.net/covid/OC_COVID.zip", destfile = paste0(dropbox_dir, "2 - data_construct/1-data_temp/COVID19.zip"))
  
  # Unzip 
  unzip(paste0(dropbox_dir, "2 - data_construct/1-data_temp/COVID19.zip"), exdir = paste0(dropbox_dir, "2 - data_construct/1-data_temp"))
  
  # Load COVID-19 data
  tender_covid <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/OC_COVID19.csv"    ))
  item_covid   <- fread(paste0(dropbox_dir, "2 - data_construct/1-data_temp/OCItem_COVID19.csv"))
  
  colnames(tender_covid)[3] <- "ID"
  colnames(item_covid)[3] <- "ITEM_ID"
  
  tender_covid$tender_covid_bin <- ifelse(tender_covid$ID %in% data_tenders$tender_code, "Matched", "Unmatched")
  
  # Compute the distribution of matched and unmatched 
  {
    
    tab_1 <- tender_covid %>%                     # set the dataset to work on
      tabyl(ClaseDeCompra,tender_covid_bin)  %>%  # select the variables of interest and compute a two-way frequency table
      adorn_totals( where = c("row", "col")) %>%  # compute totals by row and cols
      adorn_percentages("all")               %>%  # add percentages to the table
      adorn_pct_formatting(digits = 0)       %>%  # format with 0 digits
      adorn_ns( position = "front" )  
    
  }
  
  # Add a variable to identify which tenders are covid-emergency related 
  for (year in seq(2015, 2022)) {
    
    for (level in c("tender","lot","offer")) {
      
      # load the data
      data <- readRDS(paste0(dropbox_dir, "2 - data_construct/2-data_compiled/", level, "-", year,".rds"))
      
      # add the variable based on the ID from teh covid-19 dataset
      data %>%  
        mutate(
          tender_covid_19 = ifelse(data$tender_code %in% tender_covid$ID, 1, 0)
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
      data %>%  
        mutate(
          tender_covid_19 = ifelse(data$tender_code %in% item_covid$ITEM_ID, 1, 0)
        )
      
      # Save the new data
      saveRDS(data, paste0(dropbox_dir, "2 - data_construct/2-data_compiled/", level, "-", year,".rds"))
      
      # Clean the data from the workspace  
      rm(data)
    
  }
  
}
