# Adjusted by Ruggero Doino (Originally Made by Leandro Veloso)
# main: download bidding data (Reporte de Licitaciones) from Chile procurement and unzip

# 0: Setting R ----

options(scipen=99999)

{
  # 1: Cleaning R
  rm(list=ls()) 
  
  # 2: Loading package
  {
    packages <- 
      c( 
         "cli",
         "skimr",
         "writexl",
         "tidyverse",
         "labelled",
         "huxtable",
         "data.table",
         "rebus", 
         "R.utils",
         "janitor",
         "kableExtra",
         "Hmisc",
         "httr",
         "xlsx",
         "plotly",
         "lubridate",
         "readxl"
      )
    
    # Leitura dos pacotes e dependencias
    if (!require("pacman")) install.packages("pacman")
    
    # Loading list of packages
    pacman::p_load(packages,
                   character.only = TRUE,
                   install = TRUE)
  }
  
  # Setting path
  if (Sys.getenv("USER") == "ruggerodoino") {
    print("Ruggero user has been selected")
    dropbox_dir  <- "/Users/ruggerodoino/Dropbox/COVID_19/CHILE/"
    github_dir   <- "/Users/ruggerodoino/Documents/GitHub/emergency-response-procurement/05-Chile/02-R/Scripts"
  } else if (Sys.getenv("USERNAME") == "........") {
    print("............")
    github_dir   <- ""
  }

    # 3: Defying range files
  {
    # first DT_TENDER_MONTH/DT_TENDER_YEAR - MM/01/YYYY
    year_month_start = mdy("01/01/2015")
    year_month_end   = mdy("01/06/2022")
    
    # To use in the loop
    sequence_dates <- seq.Date( from = year_month_start,
                                to = year_month_end,
                                by = 'month')
    #by = 'DT_TENDER_YEAR')
  }
  
  # 4: Creating folder to save files
  {
    path_raw <- "1 - import"
    
    # Creating folder -raw
    dir.create(file.path(dropbox_dir, path_raw), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_raw, "1-compress"), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_raw, "2-unzipped"), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_raw, "3-pdf"     ), showWarnings = FALSE)
    
    # Importeded
    path_imp <-"2 - data_construct"
    
    # Creating folder -raw
    dir.create(file.path(dropbox_dir,path_imp), showWarnings = FALSE)
    
    # Creating folder -raw
    dir.create(file.path(dropbox_dir, path_imp), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_imp, "1-data_temp"     ), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_imp, "2-data_compiled" ), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_imp, "3-data_pooled" ), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_imp, "4-data_tables" ), showWarnings = FALSE)
    
    # Results
    path_result <-"3 - data_clean"
    
    # Creating folder -raw
    dir.create(file.path(dropbox_dir, path_result), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_result, "0-data"), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_result, "1-data_cleaned"), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_result, "1-outputs"     ), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_result, "2-graphs"), showWarnings = FALSE)
    
    # Results
    path_out <-"data_temporary"
    
    # Creating folder -raw
    dir.create(file.path(dropbox_dir, path_out), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_out, "0-old"), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_out, "1-data_temp"     ), showWarnings = FALSE)
    dir.create(file.path(dropbox_dir, path_out, "2-tables"), showWarnings = FALSE)
    
  }
  
}

# 1: Downloading and unzip file
     source(file.path(github_dir,"01-download_data_and_unzip-bid.R"))

# 2: Splitting the data in four modules
     source(file.path(github_dir,"02-Data_split-bid.R"))

# 3: Appending the DT_TENDER_MONTH level data of the four modules and architecture
     source(file.path(github_dir,"03-Appending_months_by_module-bid.R"))

# 4: Deleting raw files used in the previous codes
     source(file.path(github_dir,"04-Removing-extra-files-bid.R"))

# 5: Deleting raw files used in the previous codes
     source(file.path(github_dir,"05-Pooling_Subsampling.R"))

# 6: Deleting raw files used in the previous codes
     source(file.path(github_dir,"06-Cleaning.R"))

# 7: Labelling Treatment (emergency COVID-19 purchases) vs Control
     source(file.path(github_dir,"07-Outputs.R"))

