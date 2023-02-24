
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
        "plotly",
        "lubridate",
        "readxl",
        "zoo",
        "haven",
        "extrafont"
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
    fin_data <- file.path(dropbox_dir, "Data/Final")
    
    # CODE
    function_code <- file.path(github_dir, "Functions")
    
  }
}

# 0: Load all the functions needed 
invisible(sapply(list.files(function_code, full.names = TRUE), source, .GlobalEnv))

# Load cleaned tender data
data_offer_sub <- readRDS(file = file.path(fin_data, "data_offer_sub.rds"))

# Task 1

# Number of bidders per tender
n_bidders <- data_offer_sub %>% 
  
  # We select only the period of interest
  filter(DT_TENDER_YEAR > 2017) %>% 
  
  # One dummy for bidder being from the same municipality
  mutate(same_municipality_bidder = ifelse(STR_BUYER_CITY == STR_FIRM_CITY, 1, 0)) %>% 
  
  # One dummy for bidder being from the same region
  mutate(same_region_bidder       = ifelse(STR_BUYER_REGION == STR_FIRM_REGION, 1, 0)) %>% 
  
  # One dummy for winner being an SME
  mutate(sme_winner               = ifelse(CAT_OFFER_SELECT == "Seleccionada", sme, NA)) %>% 
  
  # One dummy for the winner being from the same municipality
  mutate(same_municipality_winner = ifelse(CAT_OFFER_SELECT == "Seleccionada", same_municipality_bidder, NA)) %>% 
  
  # One dummy for the winner being from the same region
  mutate(same_region_winner = ifelse(CAT_OFFER_SELECT == "Seleccionada", same_region_bidder, NA)) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_Y, DT_M, DT_Q, ID_ITEM, COVID_19) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    n_bidders                =    n()                                      ,
    sme_bidders              = mean(sme                     , na.rm = TRUE),
    sme_winners              = mean(sme_winner              , na.rm = TRUE),
    same_municipality_bidder = mean(same_municipality_bidder, na.rm = TRUE),
    same_region_bidder       = mean(same_region_bidder      , na.rm = TRUE),
    same_municipality_winner = mean(same_municipality_winner, na.rm = TRUE),
    same_region_winner       = mean(same_region_winner      , na.rm = TRUE)
  )   %>%
  
  # One dummy for tenders with only one bidder
  mutate(only_one_bidder = if_else(n_bidders == 1, 1, 0)) %>% 
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_Q, COVID_19) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    n_bidders                = mean(n_bidders                , na.rm = TRUE)    ,
    only_one_bidder          = mean(only_one_bidder          , na.rm = TRUE)*100,
    sme_bidders              = mean(sme_bidders              , na.rm = TRUE)*100,
    sme_winners              = mean(sme_winners              , na.rm = TRUE)*100,
    same_municipality_bidder = mean(same_municipality_bidder , na.rm = TRUE)*100,
    same_region_bidder       = mean(same_region_bidder       , na.rm = TRUE)*100,
    same_municipality_winner = mean(same_municipality_winner , na.rm = TRUE)*100,
    same_region_winner       = mean(same_region_winner       , na.rm = TRUE)*100
  ) 

# Avg Number of Bidders

plot <- graph_trend(
  data = n_bidders, 
  variable = n_bidders, 
  title = "Tender Competiviness",
  subtitle = "Avg Number of Bidders, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 2,
  limit_upper = 5,
  interval_limits_y = 1,
  legend_upper = 4.6
)
ggsave(
  
  filename = file.path(dropbox_dir, "Outputs/avg_number_bidder.jpeg"),
  plot = plot                                                 ,
  width    = 10                                            ,
  height   = 6.2                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
  
)

## Share of tenders with only one bidder (all tenders)

plot <- graph_trend(
  data = n_bidders, 
  variable = only_one_bidder, 
  title = "Tender Competiviness",
  subtitle = "Share of Tenders with only one Bidder",
  caption = "Source: Chile Compra",
  limit_lower = 20,
  limit_upper = 60,
  interval_limits_y = 10,
  legend_upper = 56,
  percentage = TRUE
)
ggsave(
  
  filename = file.path(dropbox_dir, "Outputs/share_one_bidder.jpeg"),
  plot = plot                                                 ,
  width    = 10                                            ,
  height   = 6.2                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
  
)


plot <- graph_trend(
  data = n_bidders, 
  variable = sme_bidders, 
  title = "SMEs participation",
  subtitle = "Share of SMEs firms bidding, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 50,
  limit_upper = 80,
  interval_limits_y = 10,
  legend_upper = 76,
  percentage = TRUE
)
ggsave(
  
  filename = file.path(dropbox_dir, "Outputs/share_smes_bidder.jpeg"),
  plot = plot                                                 ,
  width    = 10                                            ,
  height   = 6.2                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
  
)

plot <- graph_trend(
  data = n_bidders, 
  variable = sme_winners, 
  title = "SMEs participation",
  subtitle = "Share of SMEs firms winning, per contract",
  caption = "Source: Chile Compra",
  limit_lower = 40,
  limit_upper = 80,
  interval_limits_y = 10,
  legend_upper = 76,
  percentage = TRUE
)
ggsave(
  
  filename = file.path(dropbox_dir, "Outputs/share_smes_winner.jpeg"),
  plot = plot                                                 ,
  width    = 10                                            ,
  height   = 6.2                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
  
)

plot <- graph_trend(
  data = n_bidders, 
  variable = same_region_bidder, 
  title = "Geography of Tenders",
  subtitle = "Share of bidding firms from the same region, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 30,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 47.5,
  percentage = TRUE
)
ggsave(
  
  filename = file.path(dropbox_dir, "Outputs/same_region_bidder.jpeg"),
  plot = plot                                                 ,
  width    = 10                                            ,
  height   = 6.2                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
  
)

plot <- graph_trend(
  data = n_bidders, 
  variable = same_municipality_bidder, 
  title = "Geography of Tenders",
  subtitle = "Share of bidding firms from the same municipality, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 5,
  limit_upper = 11,
  interval_limits_y = 1,
  legend_upper = 10.6,
  percentage = TRUE
)
ggsave(
  
  filename = file.path(dropbox_dir, "Outputs/same_mun_bidder.jpeg"),
  plot = plot                                                 ,
  width    = 10                                            ,
  height   = 6.2                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
  
)

plot <- graph_trend(
  data = n_bidders, 
  variable = same_region_winner, 
  title = "Geography of Tenders",
  subtitle = "Share of winning firms from the same region, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 30,
  limit_upper = 50,
  interval_limits_y = 5,
  legend_upper = 47.5,
  percentage = TRUE
)
ggsave(
  
  filename = file.path(dropbox_dir, "Outputs/same_region_winner.jpeg"),
  plot = plot                                                 ,
  width    = 10                                            ,
  height   = 6.2                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
  
)

plot <- graph_trend(
  data = n_bidders, 
  variable = same_municipality_winner, 
  title = "Geography of Tenders",
  subtitle = "Share of winning firms from the same municipality, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 5,
  limit_upper = 12,
  interval_limits_y = 1,
  legend_upper = 11.5,
  percentage = TRUE
)
ggsave(
  
  filename = file.path(dropbox_dir, "Outputs/same_mun_winner.jpeg"),
  plot = plot                                                 ,
  width    = 10                                            ,
  height   = 6.2                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
  
)

# Time to last bid (months)
last_bid <- data_offer_sub %>% 
  
  filter(DT_Y > 2016) %>% 
  distinct(ID_FIRM_RUT, ID_ITEM, DT_OFFER_SEND, DT_Y, DT_M, DT_Q, COVID_19) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_FIRM_RUT, ID_ITEM, MONTHS, DT_M, DT_Y, DT_Q, COVID_19) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2017)

# last bid = 6 months
last_bid <- last_bid %>% 
  
  mutate(
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_Y, DT_M, DT_Q, ID_ITEM, COVID_19) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE),
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_Q, COVID_19) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE)*100,
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE)*100
  ) 

plot <- graph_trend(
  data = last_bid, 
  variable = new_bidder_6, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (6 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 1,
  limit_upper = 5,
  interval_limits_y = 1,
  legend_upper = 4.7,
  percentage = TRUE
)

ggsave(
  
  filename = file.path(dropbox_dir, "Outputs/share_new_bidders_6.jpeg"),
  plot = plot                                                 ,
  width    = 10                                            ,
  height   = 6.2                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
  
)

plot <- graph_trend(
  data = last_bid, 
  variable = new_bidder_12, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (12 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 4,
  interval_limits_y = 0.5,
  legend_upper = 3.7,
  percentage = TRUE
)

ggsave(
  
  filename = file.path(dropbox_dir, "Outputs/share_new_bidders_12.jpeg"),
  plot = plot                                                 ,
  width    = 10                                            ,
  height   = 6.2                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
  
)

# Time to last bid (months)
last_win <- data_offer_sub %>% 
  
  filter(DT_Y > 2016) %>% 
  filter(CAT_OFFER_SELECT == "Seleccionada") %>% 
  distinct(ID_FIRM_RUT, ID_ITEM, DT_OFFER_SEND, DT_Y, DT_M, DT_Q, COVID_19) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_FIRM_RUT, ID_ITEM, MONTHS, DT_M, DT_Y, DT_Q, COVID_19) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2017)

# last bid = 6 months
last_win <- last_win %>% 
  
  mutate(
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_Y, DT_M, DT_Q, ID_ITEM, COVID_19) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE),
    new_winner_12 = mean(new_winner_12, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_Q, COVID_19) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE)*100,
    new_winner_12 = mean(new_winner_12, na.rm = TRUE)*100
  ) 


## Share of New Awarded Firms (6 months)

plot <- graph_trend(
  data = last_win, 
  variable = new_winner_6, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (6 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 1,
  limit_upper = 8,
  interval_limits_y = 1,
  legend_upper = 7.6,
  percentage = TRUE
)

ggsave(
  
  filename = file.path(dropbox_dir, "Outputs/share_new_winners_6.jpeg"),
  plot = plot                                                 ,
  width    = 10                                            ,
  height   = 6.2                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
  
)

plot <- graph_trend(
  data = last_win, 
  variable = new_winner_12, 
  title = "Firms Participation",
  subtitle = "Share of new winning firms (12 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 4.5,
  interval_limits_y = 0.5,
  legend_upper = 4.2,
  percentage = TRUE
)

ggsave(
  
  filename = file.path(dropbox_dir, "Outputs/share_new_winners_12.jpeg"),
  plot = plot                                                 ,
  width    = 10                                            ,
  height   = 6.2                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
  
)

