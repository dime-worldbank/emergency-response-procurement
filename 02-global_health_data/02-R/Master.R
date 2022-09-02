# ---------------------------------------------------------------------------- #
#
#                            Global Health Data 

#                                  MASTER 

#       Author: Hao Lyu                           Update: 09/02/2022
#
# ---------------------------------------------------------------------------- #


# =============================== Structure ================================== #
# 
#
#        1)  import dataset 
#
#        2)  draw graphs :plot the time trends of number of deaths and number 
#                         of cases at weekly level
#
#                                                                                 
# ---------------------------------------------------------------------------- #


# SET UP  --------------------------------------------------------------------

# Cleaning the environment 
  rm(list=ls()) 


# Setting paths
  if (Sys.info()["user"] == "wb595473"){ 
    
    projectFolder     <- "/Users/wb595473/WBG/DIME3 Files - FY23 MDTF project/Covid_datawork/01-global_health_data/1_data"
    scriptFolder      <- "/Users/wb595473/OneDrive - WBG/Documents/emergency-response-procurement/02-global_health_data"

    } else if (Sys.info()["user"] == "") {
      
      projectFolder    <- "" 
      scriptFolder     <- ""
      
      }   # Maria - please enter your path here


    scripts         <- file.path(scriptFolder,  "02-R/" )    
    raw             <- file.path(projectFolder, "1_Raw//")                                             
    intermediate    <- file.path(projectFolder, "2_Intermediate//")
    cleaned         <- file.path(projectFolder, "3_Cleaned//")
    output          <- file.path(projectFolder, "4_Output//")


# Loading packages
  packages <- c(
    
    "here"                 ,
    "readxl"               ,
    "haven"                ,
    "tidyverse"            ,
    "dplyr"                ,
    "tidyr"                , 
    "data.table"           ,
    "tidyfast"             ,
    "stringi"              ,
    "pacman"               ,
    "janitor"              ,
    "devtools"             ,
    "lubridate"            ,
    "stringr"              ,
    "stargazer"            ,
    "ggplot2"              ,
    "purrr"                ,
    "kableExtra"           , 
    "parallel"             ,
    "ggpubr"
   
     )


  load_package <- function(pkg){
    
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    
    if (length(new.pkg))
      
      install.packages(new.pkg, dependencies = TRUE)
    
    sapply(pkg, require, character.only = TRUE)
    
    }


  load_package(packages)



# RUNNING SCRIPTS 

    # 1) Draw Graph
        source(file.path(scripts, "Graphs.R"))
  
  
  
  