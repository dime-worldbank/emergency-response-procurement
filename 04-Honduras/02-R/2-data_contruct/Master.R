# ---------------------------------------------------------------------------- #
#                                                                              #
#               FY23 MDTF - Emergency Response Procurement - Honduras          #
#                                                                              # 
#                                       MASTER                                 #
#                                                                              #
#        Author: Hao Lyu (RA - DIME3)            Last Update: Sept 22 2022     #
#                                                                              #
# ---------------------------------------------------------------------------- #

# **************************************************************************** #
#   This is the master code: running this script will allow you to run all the #
#   other scripts                                                              #
#                                                                              #
# **************************************************************************** #

# SET UP -----------------------------------------------------------------------

  # Clear the environment -----------------------------------------------------

    rm(list=ls())

  # Set working directory -----------------------------------------

    if (Sys.info()["user"] == "ruggerodoino"){
  
      projectFolder <- file.path("/Users/ruggerodoino/Dropbox/KCP_Procurement_WB/R")
  
    } else if (Sys.info()["user"] == "wb595473") {
  
      scriptFolder <- file.path("/Users/wb595473/OneDrive - WBG/Documents/emergency-response-procurement/04-Honduras/02-R") 
  
      projectFolder <- file.path("/Users/wb595473/WBG/DIME3 Files - FY23 MDTF project/Covid_datawork/03-Honduras/1_data")
  
    }



    scripts     <- file.path(scriptFolder,  "2-data_contruct"                                  ) # folder for the scripts
    data_covid  <- file.path(projectFolder, "1_Raw/IAIP_Emergencia_Covid19"                    )
    final_covid <- file.path(projectFolder, "1_Raw/Data_covid"                                 )
    
    outputs     <- file.path(projectFolder, "4_Outputs"                                        ) # folder for all outputs produced
    raw_Data    <- file.path(projectFolder, "1_Raw"                                            ) # folder for all raw datasets
    Data        <- file.path(projectFolder, "1_Raw/DCC/Intermediate/1 - Panel data"           )
    Data_final  <- file.path(projectFolder, "1_Raw/DCC/Intermediate/2 - Harmonized sub-sampled Panel Data")
    final       <- file.path(projectFolder, "1_Raw/DCC/Final")
    data        <- file.path(projectFolder, "1_Raw")


    
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
              "DescTools"
              
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
    # source(file.path(scripts, "Clean.R"))
    # need to install "xlsx" package before running

    # 2) Task 1: Construct Variables 
    #source(file.path(scripts, "construct_var.R"))

    # 3) Part_2: this script creates graphs and outputs
    #source(file.path(scripts, "Part_3.R"))


