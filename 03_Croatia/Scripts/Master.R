# ---------------------------------------------------------------------------- #
#
#                         Emergency Response Procurement
#
#                                  Croatia
#
#                                   Master 
#
#       Author: Hao Lyu                           Update: 08/10/2022
#
# ---------------------------------------------------------------------------- #


# ============================== Introduction ================================ #
# 
#       This project aims to create statistical analysis using Croatia pubic 
#
#       procurement for the COVID19 Project. 
#                                                                                 
# ---------------------------------------------------------------------------- #


# SET UP  --------------------------------------------------------------------


      # Cleaning the environment 
      rm(list=ls()) 
  
      # Setting paths
      if (Sys.info()["user"] == "wb595473"){ 
        
        rawFolder       <- "/Users/wb595473/WBG/DIME3 Files - Data/Intermediate/"
        projectFolder   <- "/Users/wb595473/WBG/DIME3 Files - FY23 MDTF project/Covid_datawork/06-Croatia/1_data"
        scriptFolder    <- "/Users/wb595473/OneDrive - WBG/Documents/emergency-response-procurement/03_Croatia"
    
      } else if (Sys.info()["user"] == "") {
    
          projectFolder    <- "" 
          scriptFolder     <- ""
    
      }   # Maria - please enter your path here
  
  
      scripts         <- file.path(scriptFolder, "Scripts//" )    
      raw             <- file.path(rawFolder, "07242020//")            # data obtained by Sushimita
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
         "Knitr"                ,   
         "kableExtra"           , 
         "parallel"             
    
        )
  
  
       load_package <- function(pkg){
         
         new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
         
         if (length(new.pkg)) 
           
           install.packages(new.pkg, dependencies = TRUE)
         
         sapply(pkg, require, character.only = TRUE)
         
         }
       
       
       load_package(packages)
  
       
       
      
      # RUNNING SCRIPTS 
        
             # 1) IMPORT DATA 
                 source(file.path(scripts, "Import.R"))
       
             # 2) Create Indicators 
             #    source(file.path(scripts, "GenIndicators.R"))
  






