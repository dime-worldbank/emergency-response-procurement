# ------------------------------------------------------------------------------ #
#                     COVID-19 emergency procurement (CHILE) - MASTER            #
#                                       World Bank                               #
#                                         2022                                   #
#                                                                                #
# ------------------------------------------------------------------------------ #
# --------------------------------------- #
#     Authors: Doino Ruggero (RA - DIME)  #                                       
# --------------------------------------- #

# ****************************************************************************** #
#   This is the Master script which allows one to run all the project's scripts  #
# ****************************************************************************** #


    rm(list=ls()) # clear the environment


#### Set the current working directory -----------------------------------------

    if (Sys.info()["user"] == "ruggerodoino"){
      
      
        projectFolder <- file.path("/Users/ruggerodoino/Dropbox/COVID_19/CHILE")
      
        
      } else if (Sys.info()["user"] == "CHANGE_USERNAME") { # add a new user name
      
        
        projectFolder <- file.path("CHANGE_DIRECTORY") # add new directory
      
        
      }

    import_data     <- file.path(projectFolder,"1 - import"        )
    construct_data  <- file.path(projectFolder,"2 - data_construct")
    
#### Install and load packages -------------------------------------------------

#### Packages (standard list of useful packages)
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
  "grattantheme"     ,
  "png"              ,
  "questionr"        ,
  "ggradar"          ,
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
  "xlsx"             ,
  "stringi"          ,
  "data.table"       ,
  "gdata"
  
)

## Only install the new packages
new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.us.r-project.org")

## Library the packages (needed for each new session)

invisible(lapply(packages, library, character.only = TRUE))
# devtools::install_github("grattan/grattantheme", dependencies = FALSE, upgrade = "always")
# devtools::install_github("ricardo-bion/ggradar")

options(scipen=999)


