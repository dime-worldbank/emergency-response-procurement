# ------------------------------------------------------------------------------ #
#                          ONCAE - Honduras Procurement Project                  #
#                                       World Bank                               #
#                                       Nov - 2022                               #
#                                                                                #
# ------------------------------------------------------------------------------ #
# --------------------------------------- #
#     Authors: Hao Lyu (RA - DIME)  # 
#              Maria Arnal Canudo 
# --------------------------------------- #

# ****************************************************************************** #
#   This is the master code: running this script will allow you to run all the   #
#   other scripts                                                                #
#                                                                                #
# ****************************************************************************** #
# 11/10/2022
# Last update: May 12, 2023

######################
####   SETUP    ######
######################

#### Clear the environment -----------------------------------------------------

rm(list=ls())

#### Set the current working directory -----------------------------------------

if (Sys.info()["user"] == "wb554125") {
  
  scriptFolder <- file.path("C:/Users/wb554125/GitHub/emergency-response-procurement/04-Honduras")
  
  projectFolder <- file.path("C:/Users/wb554125/Dropbox/KCP_Procurement_WB/R")

} else if (Sys.info()["user"] == "haolyu"){
  
  scriptFolder <- file.path("/Users/haolyu/Documents/GitHub/honduras-procurement") 
  
  projectFolder <- file.path("/Users/haolyu/Dropbox/Honduras_Procurement") 
  
} # <- put your path here 



scripts     <- file.path(scriptFolder,"02-RScripts"                                             ) # folder for the scripts
outputs     <- file.path(projectFolder,"Outputs"                                                    ) # folder for all outputs produced
raw_Data    <- file.path(projectFolder,"Data/Raw"                                                   ) # folder for all raw datasets
Data        <- file.path(projectFolder,"Data/DCC/Intermediate/1 - Panel data"                       )
Data_final  <- file.path(projectFolder,"Data/DCC/Intermediate/2 - Harmonized sub-sampled Panel Data")
final       <- file.path(projectFolder,"Data/DCC/Final")
data        <- file.path(projectFolder,"Data")


# Install and load packages -------------------------------------------------

    # Packages (standard list of useful packages)
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
  "WDI"              

)


## Only install the new packages
new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.us.r-project.org")

## Library the packages (needed for each new session)

invisible(lapply(packages, library, character.only = TRUE))

# devtools::install_github("grattan/grattantheme", dependencies = FALSE, upgrade = "always")
# devtools::install_github("ricardo-bion/ggradar")

options(scipen=999)


################################
####   RUNNING SCRIPTS    ######
################################


    # 1) Part_1: this script will allow you to download the data and construct our folder structure
      source(file.path(scripts, "1-import/Part_1.R"))
    # need to install "xlsx" package before running

    # 2) Part_2: this script cleans the main datasets and merge them all down to the main 5 datasets
    # source(file.path(scripts, "Part_2.R"))

    # 3) Part_3: this script creates graphs and outputs
    # source(file.path(scripts, "Part_3.R"))


