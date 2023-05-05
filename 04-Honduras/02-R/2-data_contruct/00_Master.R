# ---------------------------------------------------------------------------- #
#                                                                              #
#               FY23 MDTF - Emergency Response Procurement - Honduras          #
#                                                                              # 
#                                    MASTER                                    #
#                                                                              #
#        Author: Hao Lyu                         Last Update: Dec 7 2022       #
#                                                                              #
# ---------------------------------------------------------------------------- #

# **************************************************************************** #
#   This is the master code: running this script will allow you to run all the #
#   other scripts                                                              #
#                                                                              #
# **************************************************************************** #

# SET UP -----------------------------------------------------------------------

  # Clear the environment -----------------------------------------------------

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
  

  # Set working directory -----------------------------------------
      
      if (Sys.info()["user"] == "wb595473") {
  
      scriptFolder <- file.path("/Users/wb595473/OneDrive - WBG/Documents/emergency-response-procurement/04-Honduras/02-R") 
  
      projectFolder <- file.path("/Users/wb595473/WBG/DIME3 Files - FY23 MDTF project/Covid_datawork/03-Honduras/1_data")
  
      
      } else if (Sys.info()["user"] == "") {
      
      scriptFolder <- file.path("") 
      
      projectFolder <- file.path("")
      
      }


    scripts          <- file.path(scriptFolder,  "2-data_contruct"                                  ) # folder for the scripts
    raw_oncae        <- file.path(projectFolder, "1_Raw/Data_ONCAE/DCC/Final"                       ) # folder for raw data from the standard portal 
    raw_data         <- file.path(projectFolder, "1_Raw"                                            ) # folder for all raw datasets
    raw_oncae_interm <- file.path(projectFolder, "1_Raw/Data_ONCAE/DCC/Intermediate/1 - Panel data" )
    intermediate     <- file.path(projectFolder, "2_Intermediate"                                   ) # all datasets used for variable constructions 
    cleaned          <- file.path(projectFolder, "3_Cleaned"                                        ) # cleaned datasets 
    output           <- file.path(projectFolder, "4_Output"                                         ) # cleaned datasets 
    
    # data_covid  <- file.path(projectFolder, "1_Raw/Data_covid/IAIP_Emergencia_Covid19"         ) # folder for raw data from the covid portal 
    # final_covid <- file.path(projectFolder, "1_Raw/Data_covid"                                 ) # folder for constructed covid data 
    # data_agg    <- file.path(projectFolder, "1_Raw/Data_Aggregate")
    
    # Data        <- file.path(projectFolder, "1_Raw/DCC/Intermediate/1 - Panel data"            ) # folder for intermediate datasets of old data 
    # Data_final  <- file.path(projectFolder, "1_Raw/DCC/Intermediate/2 - Harmonized sub-sampled Panel Data") # folder for intermediate datasets of old data 
    # final       <- file.path(projectFolder, "1_Raw/Data_old/DCC/Final"                         ) # folder for constructed old data    
  
    # outputs     <- file.path(projectFolder, "4_Outputs"                                        ) # folder for all outputs produced
    
    
  # Install and load packages -------------------------------------------------

    # Packages 

            packages <-  c(
              
              "tidyverse"        ,
              "openxlsx"         ,
              "haven"            ,
              "plyr"             ,
              "dplyr"            ,
              "tidytext"         , 
              "ggplot2"          ,
              "sjlabelled"       ,
              "expss"            ,
              "labelled"         ,
              "survey"           ,
              "likert"           ,
              "hrbrthemes"       ,
              "viridis"          ,
              "here"             ,
              "devtools"         ,
              "lubridate"        , 
              "reshape2"         ,
              "scales"           ,
              "RColorBrewer"     ,
              "fmsb"             ,
              "expss"            ,
              "kableExtra"       ,
              "knitr"            ,
              "gmodels"          ,
              "janitor"          ,
              "png"              ,
              "questionr"        ,
              "lmtest"           ,
              "sandwich"         ,
              "stargazer"        ,
              "tinytex"          ,
              "cowplot"          ,
              "ggrepel"          ,
              "rnaturalearthdata",
              "rnaturalearth"    ,
              "sf"               ,
              "ggspatial"        ,
              "googleway"        ,
              "fastDummies"      ,
              "hrbrthemes"       ,
              "readxl"           ,
              "stringi"          ,
              "data.table"       ,
              "gdata"            ,
              "WDI"              ,
              "DescTools"        ,
              "cli"              ,
              "skimr"            ,
              "plotly"           ,
              "fixest"
              
              )


    # Only install the new packages
      
      new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
      if(length(new.packages)) install.packages(new.packages, repos = "http://cran.us.r-project.org")


    # Library the packages (needed for each new session)

      invisible(lapply(packages, library, character.only = TRUE))

    # devtools::install_github("grattan/grattantheme", dependencies = FALSE, upgrade = "always")
    # devtools::install_github("ricardo-bion/ggradar")

      options(scipen=999)


# RUNNING SCRIPTS


    # 1) Clean and Merge Honduras Covid Data 
     source(file.path(scripts, "01_Clean_standard.R"))

    # 2) Construct Variables 
     source(file.path(scripts, "02_Construct_standard.R"))
      # there is also a Rmarkdown version of this script - the markdown is the most up to date one 
 
    # 3) Output of Descriptive Analysis 
     source(file.path(scripts, "04_Output_final.Rmd"))
      
    # 4) Regression Analysis  
     source(file.path(scripts, "05_regression.R"))
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      