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
      
if (Sys.info()["user"] == "wb554125") {
  
  scriptFolder <- file.path("C:/Users/wb554125/GitHub/emergency-response-procurement/04-Honduras")
  
  projectFolder <- file.path("C:/Users/wb554125/WBG/DIME3 Files - FY23 MDTF project/Covid_datawork/03-Honduras/Data")
  
} 



    scripts          <- file.path(scriptFolder,  "02-R/2-data_contruct"                                  ) # folder for the scripts
    raw_oncae        <- file.path(projectFolder, "1_Raw/Data_ONCAE/DCC/Final"                       ) # folder for raw data from the standard portal 
    raw_data         <- file.path(projectFolder, "1_Raw"                                            ) # folder for all raw datasets
    raw_oncae_interm <- file.path(projectFolder, "1_Raw/Data_ONCAE/DCC/Intermediate/1 - Panel data" )
    intermediate     <- file.path(projectFolder, "2_Intermediate"                                   ) # all datasets used for variable constructions 
    cleaned          <- file.path(projectFolder, "3_Cleaned"                                        ) # cleaned datasets 
    output           <- file.path(projectFolder, "4_Output"                                         ) # cleaned datasets 
    

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
     source(file.path(scripts, "02_Construct_standard.Rmd")) ##line 1748 code breaks, that chunck cannot be run
      # there is also a Rmarkdown version of this script - the markdown is the most up to date one 
 
    # 3) Output of Descriptive Analysis 
     source(file.path(scripts, "04_Output_final.Rmd"))
      
    # 4) Regression Analysis  
     source(file.path(scripts, "05_regression.R")) ##markdown breaks at line 322 and the R breaks in line 229, but only that regression
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      