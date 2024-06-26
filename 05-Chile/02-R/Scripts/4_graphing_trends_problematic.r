
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
    int_data <- file.path(dropbox_dir, "Data/Intermediate")
    
    
    # CODE
    function_code <- file.path(github_dir, "Functions")
    
  }
}

# 0: Load all the functions needed 
invisible(sapply(list.files(function_code, full.names = TRUE), source, .GlobalEnv))

# Load cleaned tender data
data_offer_sub <- fread(file.path(fin_data, "data_offer_sub.csv" ), encoding = "Latin-1")

data_pos <- fread(file = file.path(fin_data, "purchase_orders.csv"), encoding = "Latin-1") 

data_offer_sub = data_offer_sub[CAT_PROBLEMATIC != "" | CAT_MEDICAL == 1, ] %>% 
  .[, CAT_PROBLEMATIC := fifelse(is.na(CAT_PROBLEMATIC), 2, CAT_PROBLEMATIC)]
data_po = data_po[CAT_PROBLEMATIC != "" | CAT_MEDICAL == 1, ]%>% 
  .[, CAT_PROBLEMATIC := fifelse(is.na(CAT_PROBLEMATIC), 2, CAT_PROBLEMATIC)]

# Task 1

n_bidders_s_problematic <- data_offer_sub[DT_TENDER_YEAR > 2015, 
                                    list(
                                      n_bidders                =    .N                                      ,
                                      sme_bidders              = mean(CAT_MSME                , na.rm = TRUE),
                                      sme_winners              = mean(sme_winner              , na.rm = TRUE),
                                      same_municipality_bidder = mean(same_municipality_bidder, na.rm = TRUE),
                                      same_region_bidder       = mean(same_region_bidder      , na.rm = TRUE),
                                      same_municipality_winner = mean(same_municipality_winner, na.rm = TRUE),
                                      same_region_winner       = mean(same_region_winner      , na.rm = TRUE),
                                      DD_DECISION              = mean(DD_DECISION             , na.rm = TRUE),
                                      DD_SUBMISSION            = mean(DD_SUBMISSION           , na.rm = TRUE),
                                      DD_TOT_PROCESS           = mean(DD_TOT_PROCESS          , na.rm = TRUE),
                                      DD_AWARD_CONTRACT        = mean(DD_AWARD_CONTRACT       , na.rm = TRUE),
                                      N = .N), 
                                    by = list(DT_S, ID_ITEM, CAT_PROBLEMATIC)]

n_bidders_s_problematic <- n_bidders_s_problematic %>% mutate(only_one_bidder = if_else(n_bidders == 1, 1, 0))

n_bidders_s_problematic <- n_bidders_s_problematic[, 
                                       list(
                                         n_bidders                = mean(n_bidders                , na.rm = TRUE)    ,
                                         only_one_bidder          = mean(only_one_bidder          , na.rm = TRUE)*100,
                                         sme_bidders              = mean(sme_bidders              , na.rm = TRUE)*100,
                                         sme_winners              = mean(sme_winners              , na.rm = TRUE)*100,
                                         same_municipality_bidder = mean(same_municipality_bidder , na.rm = TRUE)*100,
                                         same_region_bidder       = mean(same_region_bidder       , na.rm = TRUE)*100,
                                         same_municipality_winner = mean(same_municipality_winner , na.rm = TRUE)*100,
                                         same_region_winner       = mean(same_region_winner       , na.rm = TRUE)*100,
                                         DD_DECISION              = mean(DD_DECISION              , na.rm = TRUE),
                                         DD_SUBMISSION            = mean(DD_SUBMISSION            , na.rm = TRUE),
                                         DD_TOT_PROCESS           = mean(DD_TOT_PROCESS           , na.rm = TRUE),
                                         DD_AWARD_CONTRACT        = mean(DD_AWARD_CONTRACT        , na.rm = TRUE),
                                         N = sum(N)), 
                                       by = list(DT_S, CAT_PROBLEMATIC)]

# Number of bidders -------------------------------------------------------

# Quarterly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = n_bidders, 
  title = "Average number of bidders per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 10,
  interval_limits_y = 1,
  legend_upper = 10,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_bidders_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 350                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Share of tenders with only one bidder (all tenders) --------------------------
# Yearly - Covid-19



plot <- graph_trend(
  data = n_bidders_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = only_one_bidder, 
  title = "Share of lots (ItemXLicitacion) with only one bidder",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 45,
  interval_limits_y = 10,
  legend_upper = 45,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/one_bidder_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Share of SMEs firm bidding (all tenders) --------------------------

# Yearly - Covid-19


plot <- graph_trend(
  data = n_bidders_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = sme_bidders, 
  title = "Share of bidders per lot (ItemXLicitacion) that are SMEs",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 70,
  interval_limits_y = 10,
  legend_upper = 70,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_bid_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Share of SMEs firms winning (all tenders) --------------------------

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = sme_winners, 
  title = "Share of winning bidders per lot (ItemXLicitacion) that are SMEs",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 70,
  interval_limits_y = 10,
  legend_upper = 66,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_win_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Quarterly - Covid-19

# Share of bidders from the same region (all tenders) --------------------------

plot <- graph_trend(
  data = n_bidders_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = same_region_bidder, 
  title = "Share of bidding firms per lot (ItemXLicitacion) that are from the same region",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 45,
  interval_limits_y = 5,
  legend_upper = 45,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_bid_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Quarterly - Covid-19


# Share of bidders from the same municipality (all tenders) -------------

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = same_municipality_bidder, 
  title = "Share of bidding firms per lot (ItemXLicitacion) that are from the same municipality",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 5,
  interval_limits_y = 1,
  legend_upper = 5,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_bid_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Share of winners from the same region (all tenders) -------------
# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = same_region_winner, 
  title = "Share of winning firms per lot (ItemXLicitacion) that are from the same region",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 70,
  interval_limits_y = 10,
  legend_upper = 70,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_win_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Share of winners from the same municipality (all tenders) -------------

plot <- graph_trend(
  data = n_bidders_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = same_municipality_winner, 
  title = "Share of winning firms per lot (ItemXLicitacion) that are from the same municipality",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 6,
  interval_limits_y = 1,
  legend_upper = 6,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_win_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Time to last bid (months)
last_bid_problematic <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, DT_OFFER_SEND, DT_Y, DT_M, DT_S, CAT_PROBLEMATIC) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, MONTHS, DT_M, DT_Y, DT_S, CAT_PROBLEMATIC) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

last_bid_s_problematic <- last_bid_problematic %>% 
  
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_S, ID_ITEM, CAT_PROBLEMATIC) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE),
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE),
    new_bidder_24 = mean(new_bidder_24, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_S, CAT_PROBLEMATIC) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE)*100,
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE)*100,
    new_bidder_24 = mean(new_bidder_24, na.rm = TRUE)*100
  ) 
# Share of new bidders within the last 6 months (all tenders) -------------

# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = new_bidder_6, 
  title = "Share of new bidding firms (6 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 3,
  interval_limits_y = 1,
  legend_upper = 3,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_6_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Share of new bidders within the last 12 months (all tenders) -------------
# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = new_bidder_12, 
  title = "Share of new bidding firms (12 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 3,
  interval_limits_y = 0.5,
  legend_upper = 3,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_12_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = new_bidder_24, 
  title = "Share of new bidding firms (24 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 2.5,
  interval_limits_y = 0.5,
  legend_upper = 2.5,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_24_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Time to last bid (months)
last_win_problematic <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, DT_OFFER_SEND, DT_Y, DT_M, DT_S, CAT_PROBLEMATIC) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, MONTHS, DT_M, DT_Y, DT_S, CAT_PROBLEMATIC) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

# la
last_win_s_problematic <- last_win_problematic %>% 
  
  mutate(
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_S, ID_ITEM, CAT_PROBLEMATIC) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE),
    new_winner_12 = mean(new_winner_12, na.rm = TRUE),
    new_winner_24 = mean(new_winner_24, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_S, CAT_PROBLEMATIC) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE)*100,
    new_winner_12 = mean(new_winner_12, na.rm = TRUE)*100,
    new_winner_24 = mean(new_winner_24, na.rm = TRUE)*100
    
  ) 

# Share of new winners within the last 6 months (all tenders) -------------

# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = new_winner_12, 
  title = "Share of new winning firms (12 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 2,
  interval_limits_y = 0.5,
  legend_upper = 2,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_12_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)
# Quarterly - Covid-19

# Share of new winners within the last 12 months (all tenders) -------------
# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = new_winner_6, 
  title = "Share of new winning firms (6 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 4,
  interval_limits_y = 0.5,
  legend_upper = 4,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_6_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19



# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = new_winner_24, 
  title = "Share of new winning firms (24 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 1,
  interval_limits_y = 0.5,
  legend_upper = 1,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_24_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Decision Time    ---------------------------------------------------------------
# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = DD_DECISION, 
  title = "Decision time",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 100,
  interval_limits_y = 5,
  legend_upper = 90,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_time_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Tot Process Time ---------------------------------------------------------------
# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = DD_TOT_PROCESS, 
  title = "Total processing time",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 120,
  interval_limits_y = 10,
  legend_upper = 120,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_process_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Submission Time  ---------------------------------------------------------------
# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = DD_SUBMISSION, 
  title = "Submission time",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 18,
  interval_limits_y = 2,
  legend_upper = 18,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_submission_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19


# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = DD_AWARD_CONTRACT, 
  title = "Awarding time",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 95,
  interval_limits_y = 10,
  legend_upper = 90,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_award_contract_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

data_po[, CAT_DIRECT := fcase(CAT_DIRECT == "No", 0,
                              CAT_DIRECT == "Si", 1, default = NA)]
data_po_collapse <- data_po[DT_YEAR > 2015, 
                                 list(
                                   CAT_DIRECT     = mean(cat_direct, na.rm = TRUE),
                                   CAT_DIRECT_VAL = sum(amt_tot_usd_oc_win, na.rm = TRUE)
                                 ), 
                                 by = list(DT_S, id_purchase_order, CAT_PROBLEMATIC)]

data_po_collapse <- data_po_collapse %>% filter(CAT_DIRECT == 0 | CAT_DIRECT == 1)

data_po_collapse <- data_po_collapse %>% 
  group_by(DT_S) %>% 
  mutate(AMT_VALUE_SUM = sum(CAT_DIRECT_VAL, na.rm = TRUE)) %>% 
  ungroup() 

data_po_collapse <- data_po_collapse %>% 
  mutate(
    AMT_VALUE = CAT_DIRECT_VAL*CAT_DIRECT
  )%>% 
  group_by(DT_S, CAT_PROBLEMATIC, AMT_VALUE_SUM) %>% 
  dplyr::summarise(
    CAT_DIRECT_N   = mean(CAT_DIRECT, na.rm = TRUE)*100,
    CAT_DIRECT_VAL = sum(AMT_VALUE, na.rm = TRUE)
  )

data_po_collapse <- data_po_collapse %>% mutate(CAT_DIRECT_VAL = CAT_DIRECT_VAL/AMT_VALUE_SUM*100) %>% select(- AMT_VALUE_SUM)

plot <- graph_trend(
  data = data_po_collapse, 
  variable = CAT_DIRECT_N, 
  treatment = CAT_PROBLEMATIC, 
  title = "Share of number of contracts (órdenes de compra) contracted through direct",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 45,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_direct_contracts_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

plot <- graph_trend(
  data = data_po_collapse, 
  variable = CAT_DIRECT_VAL, 
  treatment = CAT_PROBLEMATIC, 
  title = "Share of volume of contracts (órdenes de compra) contracted through direct",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 4,
  interval_limits_y = 0.5,
  legend_upper = 3.5,
  percentage = TRUE,
  yearly = FALSE
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/value_direct_contracts_semester_problematic.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

last_bid_problematic <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, ID_RUT_BUYER, DT_OFFER_SEND, DT_Y, DT_M, DT_S, CAT_PROBLEMATIC) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, ID_RUT_BUYER, MONTHS, DT_M, DT_Y, DT_S, CAT_PROBLEMATIC) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM, ID_RUT_BUYER
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

last_bid_s_problematic <- last_bid_problematic %>% 
  
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_S, ID_ITEM, CAT_PROBLEMATIC) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE),
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE),
    new_bidder_24 = mean(new_bidder_24, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_S, CAT_PROBLEMATIC) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE)*100,
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE)*100,
    new_bidder_24 = mean(new_bidder_24, na.rm = TRUE)*100
  ) 

# Time to 
# Share of new firms bidding to the entity within the last 6 months (all tenders) -------------

# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = new_bidder_6, 
  title = "Share of firms bidding for the first time in the last 6 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 25,
  interval_limits_y = 5,
  legend_upper = 25,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_6_semester_problematic_2.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Share of new firms bidding to the entity within the last 12 months -------------
# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = new_bidder_12, 
  title = "Share of firms bidding for the first time in the last 12 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 20,
  interval_limits_y = 5,
  legend_upper = 20,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_12_semester_problematic_2.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19


# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = new_bidder_24, 
  title = "Share of firms bidding for the first time in the last 24 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 20,
  interval_limits_y = 5,
  legend_upper = 20,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_24_semester_problematic_2.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Time to last bid (months)
last_win_problematic <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, ID_RUT_BUYER, DT_OFFER_SEND, DT_Y, DT_M, DT_S, CAT_PROBLEMATIC) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, ID_RUT_BUYER, MONTHS, DT_M, DT_Y, DT_S, CAT_PROBLEMATIC) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM, ID_RUT_BUYER
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

# last bi

last_win_s_problematic <- last_win_problematic %>% 
  
  mutate(
    LAST_WIN_MONTHS = ifelse(is.na(LAST_WIN_MONTHS), 999999, LAST_WIN_MONTHS), 
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_S, ID_ITEM, CAT_PROBLEMATIC) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE),
    new_winner_12 = mean(new_winner_12, na.rm = TRUE),
    new_winner_24 = mean(new_winner_24, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_S, CAT_PROBLEMATIC) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE)*100,
    new_winner_12 = mean(new_winner_12, na.rm = TRUE)*100,
    new_winner_24 = mean(new_winner_24, na.rm = TRUE)*100
    
  ) 

# Time 

# Share of new firms winning to the entity within the last 6 months -------------
# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = new_winner_12, 
  title = "Share of firms winning for the first time in the last 12 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 40,
  interval_limits_y = 5,
  legend_upper = 40,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_12_semester_problematic_2.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)
# Quarterly - Covid-19

# Share of new firms winning to the entity within the last 12 months -------------
# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = new_winner_6, 
  title = "Share of firms winning for the first time in the last 6 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 40,
  interval_limits_y = 5,
  legend_upper = 40,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_6_semester_problematic_2.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Yearly - Covid-19


# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_problematic, 
  treatment = CAT_PROBLEMATIC,
  variable = new_winner_24, 
  title = "Share of firms winning for the first time in the last 24 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 35,
  interval_limits_y = 5,
  legend_upper = 35,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_24_semester_problematic_2.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)



