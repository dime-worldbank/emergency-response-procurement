# ---------------------------------------------------------------------------- #
#                   Chilean Covid Report: replication package                  #
#                                   World Bank - DIME                          #
#                                                                              #
# ---------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------- #
# ++++++++++++++++++++++++ TABLE OF CONTENTS +++++++++++++++++++++++++++++++++ #
#                                                                              #
#        1) SETUP    : general settings, set directories, and load data.       #
#        2) FUNCTIONS: here, you can find the list of all functions created.   #  
#        3) RUNNING  : all the section dedicated to clean the dataset.         #
#        4) SAVE     : save the dataset and all the main objects.              #
#                                                                              #
# **************************************************************************** #

# 0: Setting R ----------------------------------------------------------------

{
  { # 0.1: Prepare the workspace 
    
    # Clean the workspace
    rm(list=ls()) 
    
    # Free Unused R memory
    gc()
    
    # Options for avoid scientific notation
    options(scipen = 9999)
    
    # Set the same seed
    set.seed(123)
    
  }
  
  { # 0.2: Loading the packages
    
    # list of package needed
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
        "readxl",
        "zoo",
        "haven"
      )
    
    # If the package is not installed, then install it 
    if (!require("pacman")) install.packages("pacman")
    
    # Load the packages 
    pacman::p_load(packages, character.only = TRUE, install = TRUE)
    
  }
}

# 1: Setting Working Directories ----------------------------------------------

{
  { # Setting path
    
    if (Sys.getenv("USER") == "ruggerodoino") { # RA (World Bank-DIME)
      
      print("Ruggero has been selected")
      
      dropbox_dir  <- "/Users/ruggerodoino/Dropbox/COVID_19/CHILE/Reproducible-Package"
      github_dir   <- "/Users/ruggerodoino/Documents/GitHub/emergency-response-procurement/05-Chile/02-R/Scripts"
      
    }
    
  }
  
  { # Set working directories
    
    # DATA
    raw_data <- file.path(dropbox_dir, "Data/Raw")
    int_data <- file.path(dropbox_dir, "Data/Intermediate")
    fin_data <- file.path(dropbox_dir, "Data/Final")
    
    # DOCUMENTATION
    code_doc <- file.path(dropbox_dir, "Documentation/Codebooks")
    dic_doc  <- file.path(dropbox_dir, "Documentation/Dictionaries")
    
    # OUTPUTS
    graph_output <- file.path(dropbox_dir, "Outputs/Graphs")
    table_output <- file.path(dropbox_dir, "Outputs/Tables")
    
    # CODE
    function_code <- file.path(github_dir, "Functions")
    scripts_code  <- file.path(github_dir, "Scripts")
    
  }
}

# 2: Master Script ------------------------------------------------------------

# 0: Load all the functions needed 
invisible(sapply(list.files(function_code, full.names = TRUE), source, .GlobalEnv))

# 1: Download and clean tender data
source(file.path(github_dir, "1_tender_cleaning.R"))


