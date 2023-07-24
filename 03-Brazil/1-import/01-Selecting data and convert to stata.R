## Made by Leandro Justino Pereira Veloso
## main: Copy the tender data to the raw folder

# 00: Setting R ----
{
  # 1: Cleaning R
  rm(list=ls()) 
  
  # 2: Loading package
  {
    # 2: Loading package
    {
      packages <- 
        c( 
          # 01: Classic packages for data manipulation
          "tidyverse",
          "data.table",
          # 02: Text manupulation pacages
          "stringr",
          "stringi",
          "rebus",
          "tm",
          # 03: Date formats
          "lubridate",
          # 04: Reading/writting xls,xlsx
          "readxl",
          "writexl",
          # 05: Labelling from auxiliar file
          "labelled",
          # 06: Nice statitics
          "skimr",
          # 07: Compress files
          "archive",
          "cli",
          "R.utils",
          "haven"
        ) 
      
      # Leitura dos pacotes e dependencias
      if (!require("pacman")) install.packages("pacman")
      
      # Loading list of packages
      pacman::p_load(packages,
                     character.only = TRUE,
                     install = TRUE)
    }
    
    # Leitura dos pacotes e dependencias
    if (!require("pacman")) install.packages("pacman")
    
    # Loading list of packages
    pacman::p_load(packages,
                   character.only = TRUE,
                   install = TRUE)
  }

  # 3: Setting path
  if (Sys.getenv("USERNAME") == "leand") {
    print("Leandro user has been selected")
    # PAth to save
    path_data  <- "C:/Users/leand/Dropbox/3-Profissional/07-World BANK/04-procurement/01-dados/01-Brasil/01-portal_da_transparencia/02-import"
    path_kcp   <- "C:/Users/leand/Dropbox/3-Profissional/07-World BANK/04-procurement/04-KCP/01-KCP-Brazil/1-data/2-imported" 
    path_covid <- "C:/Users/leand/Dropbox/3-Profissional/07-World BANK/04-procurement/06-Covid_Brazil/1_data/01-import-data" 
    path_dtb   <- "C:/Users/leand/Dropbox/3-Profissional/07-World BANK/04-procurement/01-dados/01-Brasil/03-extra_sources/01-raw"
  }
}

# 01: Auxiliary function ----
{
  # Cleanning string
  # 1: Clean string
  {
    clean_strings = function(var,rm_pontuation = FALSE) { 
      # Removing all that is not letter or number or space
      pattern_all_not_letter_numbers =  "[^a-zA-Z0-9 ]"
      
      #  Change LATIN to ASCII
      if (rm_pontuation == FALSE) {
        str_trim( 
          stripWhitespace( 
            tolower(
              stri_trans_general(str = var, 
                                 id = "Latin-ASCII")))
          , side = c("both")) 
      } else { 
        str_trim( 
          stripWhitespace( 
            str_replace_all(
              tolower(
                stri_trans_general(str = var, 
                                   id = "Latin-ASCII")
              )
              
              ,  
              pattern = pattern_all_not_letter_numbers, 
              replace=" "
            )
          )
          ,side = c("both"))
      }
    }
    
    # An example
    example = c(" / PAPEL COUCHÊ / ", "Lente intraocular  mono   ",
                "A, B, C. ETsats!","12-1654-LP15")
    
    #checking function
    clean_strings(example)
    clean_strings(example, TRUE)
  }
  
  # 2: Converting to string
  {
    # 1: Function to fill the ids and remove strange charactere
    format_fix = function(x, digits=11) {
      #stringr::str_pad(format(x,trim = TRUE, scientific = FALSE), digits,pad="0")
      if (is.numeric(x)) {
        stringr::str_pad(as.character(x),digits,pad="0")      
      } else if (is.character(x)) {
        stringr::str_pad(
          str_remove_all(x, pattern = "[^0-9]")
          ,digits,pad="0"
        )         
      }
    }
    
    # Checking
    format_fix("1",digits=6)
    format_fix(312,digits=6)
  }
}

# 02: tender panel ---- 
{
  # Year list 
  year_list  = 2013:2022
  
  # Creating list to save all data
  tender_year_list = list()
  for (year in year_list ) {
    # Pattern files
    # year = year_list[1]
    pattern_tender = paste0("01-tender-", year, ".rds" )
  
    # Printing file 
    print(paste0("Appending tender file: ", year))
  
    # reading raw file
    tender_year_list[[paste0(year)]] = readRDS(file.path(path_data,pattern_tender)) 
  }
    
  # Append all months of a same year
  tender_panel <-
    rbindlist(tender_year_list) 
  
  # export to stata
  tender_panel %>%
    write_dta(file.path(path_covid, "Portal-01-tender-panel.dta"))
  
  # removing
  rm(tender_panel)
  rm(tender_year_list)
}  

# 03: item panel ---- 
{
  # Year list 
  year_list  = 2013:2022
  
  # catalog preparation to merge 
  { 
    # Read
    catalog <- read_dta(file.path(path_kcp,
                                "01-catalog-federal-procurement.dta")) 
  
    # catalog_to_merge
    catalog %>% 
      write_dta(file.path(path_covid,
         "Extra-01-catalog-federal-procurement.dta")) 
  
    # Selecting relevant variables to merge
    catalog_to_merge <- catalog %>%
      select(type_item, item_5d_name, item_5d_code) %>%
      distinct(item_5d_code, .keep_all = TRUE)
  }
  
  # Creating list to save all data
  item_year_list = list()
  for (year in year_list ) {
    # Pattern files
    # year = year_list[1]
    pattern_item = paste0("02-tender-item-", year, ".rds" )
    
    # Printing file 
    print(paste0("Appending tender file: ", year))
    
    # reading raw file
    item_year_list[[paste0(year)]] = readRDS(file.path(path_data,pattern_item))     %>%
      select(year_month,item_id, item_qtd, item_value,bidder_id, item_5d_name ) %>%
      mutate(item_5d_name = clean_strings(item_5d_name,rm_pontuation =TRUE)) %>%
      mutate(tender_id = str_sub(item_id, start=1, end=17)) %>%
      arrange(item_5d_name) %>%
      left_join(catalog_to_merge,by =c("item_5d_name")) %>%
      select(-item_5d_name )
  }
  
  # Append all months of a same year
  item_panel <-
    rbindlist(item_year_list)  %>%
    arrange(year_month, tender_id, item_id) %>%
    relocate(year_month, tender_id, item_id, type_item,bidder_id, item_5d_code, item_qtd, item_value) %>%
    distinct(item_id, .keep_all = TRUE)
  
  # Cheking data
  glimpse(item_panel)
  
  # export to stata
  item_panel %>%
    write_dta(file.path(path_covid, "Portal-02-item-panel.dta"))
  
  # removing
  rm(item_panel)
  rm(item_year_list)
}  

# 04: participants panel ---- 
{
  # Year list 
  year_list  = 2013:2022
  
  # Creating list to save all data
  part_year_list = list()
  for (year in year_list ) {
    # Pattern files
    # year = year_list[1]
    pattern_part = paste0("03-tender-participants-", year, ".rds" )
    
    # Printing file 
    print(paste0("Participants file: ", year))
    
    # reading raw file
    part_year_list[[paste0(year)]] = 
      readRDS(file.path(path_data,
                        pattern_part)) %>%
      mutate(tender_id = str_sub(item_id, start=1, end=17)) 
  }
  
  # Append all months of a same year
  part_panel <-
    rbindlist(part_year_list) %>%
    relocate(year_month, tender_id, item_id ,bidder_id, D_winner) %>%
    arrange(year_month, tender_id, item_id ,bidder_id, -D_winner )
  
  # Panel part
  glimpse(part_panel)
  
  # export to stata
  part_panel %>%
    write_dta(file.path(path_covid, 
                        "Portal-03-participants_level-panel.dta"))
  
  # removing
  rm(part_panel)
  rm(part_year_list)
}  

# 05: Buyer characteristics data ---- 
{
  # Year list 
  ug_data  = readRDS(file.path(path_data,"05-ug_data.rds"))
  
  # Creating ug code state 
  ug_data <- ug_data %>%
    mutate(ug_state_code = case_when(
        ug_state == "ro" ~ "11",
        ug_state == "ac" ~ "12",
        ug_state == "am" ~ "13",
        ug_state == "rr" ~ "14",
        ug_state == "pa" ~ "15",
        ug_state == "ap" ~ "16",
        ug_state == "to" ~ "17",
        ug_state == "ma" ~ "21",
        ug_state == "pi" ~ "22",
        ug_state == "ce" ~ "23",
        ug_state == "rn" ~ "24",
        ug_state == "pb" ~ "25",
        ug_state == "pe" ~ "26",
        ug_state == "al" ~ "27",
        ug_state == "se" ~ "28",
        ug_state == "ba" ~ "29",
        ug_state == "mg" ~ "31",
        ug_state == "es" ~ "32",
        ug_state == "rj" ~ "33",
        ug_state == "sp" ~ "35",
        ug_state == "pr" ~ "41",
        ug_state == "sc" ~ "42",
        ug_state == "rs" ~ "43",
        ug_state == "ms" ~ "50",
        ug_state == "mt" ~ "51",
        ug_state == "go" ~ "52",
        ug_state == "df" ~ "53",
        TRUE             ~ NA)
      )
  
  # Checking
  count(ug_data, ug_state_code)
  
  # Reading IBGE file
  data_munic =   read_excel(file.path(path_dtb,
                                      "01-ibge_divisao_territorial_municipality_level.xlsx")
  )   %>%
    select(UF,`Código Município Completo`,Nome_Município ) %>%
    rename(
       uf_code        = UF     ,
      ug_municipality_code     = `Código Município Completo`,
      ug_municipality_name     = Nome_Município) %>%
    mutate( ug_municipality_name =  clean_strings(ug_municipality_name, FALSE) ) 
  
  # Anti join
  ug_data %>%
    semi_join(data_munic, by = c("ug_municipality"="ug_municipality_name",
                                 "ug_state_code"="uf_code")) %>%
    count()
  
  # Semi join
  ug_data %>%
    anti_join(data_munic, by = c("ug_municipality"="ug_municipality_name",
                                 "ug_state_code"="uf_code")) %>%
    count(ug_municipality)
  
  # Including  ( apenas santana do livramento nao foi)
  ug_data = 
    ug_data %>%
    left_join(data_munic, by = c("ug_municipality"="ug_municipality_name",
                                 "ug_state_code"="uf_code"))  
  
  glimpse(ug_data)

  # export to stata
  ug_data %>%
    write_dta(file.path(path_covid, 
                        "Portal-04-buyer_data.dta"))
}  