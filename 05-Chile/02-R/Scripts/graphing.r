
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

data_pos_raw <- fread(file = file.path(fin_data, "purchase_orders_raw.csv"), encoding = "Latin-1") 

data_po <- fread(file = file.path(int_data, "purchase_orders.csv"), encoding = "Latin-1") 

# Task 1

n_bidders_y_covid <- data_offer_sub[DT_TENDER_YEAR > 2015, 
                       list(
                         n_bidders                =    .N                                      ,
                         sme_bidders              = mean(sme                     , na.rm = TRUE),
                         sme_winners              = mean(sme_winner              , na.rm = TRUE),
                         same_municipality_bidder = mean(same_municipality_bidder, na.rm = TRUE),
                         same_region_bidder       = mean(same_region_bidder      , na.rm = TRUE),
                         same_municipality_winner = mean(same_municipality_winner, na.rm = TRUE),
                         same_region_winner       = mean(same_region_winner      , na.rm = TRUE),
                         DD_DECISION              = mean(DD_DECISION             , na.rm = TRUE),
                         DD_SUBMISSION            = mean(DD_SUBMISSION           , na.rm = TRUE),
                         DD_TOT_PROCESS           = mean(DD_TOT_PROCESS          , na.rm = TRUE),
                         DD_AWARD_CONTRACT        = mean(DD_AWARD_CONTRACT       , na.rm = TRUE)), 
                       by = list(DT_Y, ID_ITEM, COVID_LABEL)]

n_bidders_y_covid <- n_bidders_y_covid %>% mutate(only_one_bidder = if_else(n_bidders == 1, 1, 0))

n_bidders_y_covid <- n_bidders_y_covid[, 
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
                                      DD_AWARD_CONTRACT        = mean(DD_AWARD_CONTRACT        , na.rm = TRUE)), 
                                    by = list(DT_Y, COVID_LABEL)]

n_bidders_y_medicine <- data_offer_sub %>% mutate(MED_DUMMY = ifelse(substr(ID_ITEM_UNSPSC, 0, 2) == "42", 1, 0))

n_bidders_y_medicine <- n_bidders_y_medicine[DT_TENDER_YEAR > 2015, 
                                    list(
                                      n_bidders                =    .N                                      ,
                                      sme_bidders              = mean(sme                     , na.rm = TRUE),
                                      sme_winners              = mean(sme_winner              , na.rm = TRUE),
                                      same_municipality_bidder = mean(same_municipality_bidder, na.rm = TRUE),
                                      same_region_bidder       = mean(same_region_bidder      , na.rm = TRUE),
                                      same_municipality_winner = mean(same_municipality_winner, na.rm = TRUE),
                                      same_region_winner       = mean(same_region_winner      , na.rm = TRUE),
                                      DD_DECISION              = mean(DD_DECISION             , na.rm = TRUE),
                                      DD_SUBMISSION            = mean(DD_SUBMISSION           , na.rm = TRUE),
                                      DD_TOT_PROCESS           = mean(DD_TOT_PROCESS          , na.rm = TRUE),
                                      DD_AWARD_CONTRACT        = mean(DD_AWARD_CONTRACT       , na.rm = TRUE)), 
                                    by = list(DT_Y, ID_ITEM, MED_DUMMY)]

n_bidders_y_medicine <- n_bidders_y_medicine %>% mutate(only_one_bidder = if_else(n_bidders == 1, 1, 0))

n_bidders_y_medicine <- n_bidders_y_medicine[, 
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
                                         DD_AWARD_CONTRACT        = mean(DD_AWARD_CONTRACT        , na.rm = TRUE)), 
                                       by = list(DT_Y, MED_DUMMY)]


n_bidders_s_covid <- data_offer_sub[DT_TENDER_YEAR > 2015, 
                                    list(
                                      n_bidders                =    .N                                      ,
                                      sme_bidders              = mean(sme                     , na.rm = TRUE),
                                      sme_winners              = mean(sme_winner              , na.rm = TRUE),
                                      same_municipality_bidder = mean(same_municipality_bidder, na.rm = TRUE),
                                      same_region_bidder       = mean(same_region_bidder      , na.rm = TRUE),
                                      same_municipality_winner = mean(same_municipality_winner, na.rm = TRUE),
                                      same_region_winner       = mean(same_region_winner      , na.rm = TRUE),
                                      DD_DECISION              = mean(DD_DECISION             , na.rm = TRUE),
                                      DD_SUBMISSION            = mean(DD_SUBMISSION           , na.rm = TRUE),
                                      DD_TOT_PROCESS           = mean(DD_TOT_PROCESS          , na.rm = TRUE),
                                      DD_AWARD_CONTRACT        = mean(DD_AWARD_CONTRACT       , na.rm = TRUE)), 
                                    by = list(DT_S, ID_ITEM, COVID_LABEL)]

n_bidders_s_covid <- n_bidders_s_covid %>% mutate(only_one_bidder = if_else(n_bidders == 1, 1, 0))

n_bidders_s_covid <- n_bidders_s_covid[, 
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
                                         DD_AWARD_CONTRACT        = mean(DD_AWARD_CONTRACT        , na.rm = TRUE)), 
                                       by = list(DT_S, COVID_LABEL)]

n_bidders_s_medicine <- data_offer_sub %>% mutate(MED_DUMMY = ifelse(substr(ID_ITEM_UNSPSC, 0, 2) == "42", 1, 0))

n_bidders_s_medicine <- n_bidders_s_medicine[DT_TENDER_YEAR > 2015, 
                                             list(
                                               n_bidders                =    .N                                      ,
                                               sme_bidders              = mean(sme                     , na.rm = TRUE),
                                               sme_winners              = mean(sme_winner              , na.rm = TRUE),
                                               same_municipality_bidder = mean(same_municipality_bidder, na.rm = TRUE),
                                               same_region_bidder       = mean(same_region_bidder      , na.rm = TRUE),
                                               same_municipality_winner = mean(same_municipality_winner, na.rm = TRUE),
                                               same_region_winner       = mean(same_region_winner      , na.rm = TRUE),
                                               DD_DECISION              = mean(DD_DECISION             , na.rm = TRUE),
                                               DD_SUBMISSION            = mean(DD_SUBMISSION           , na.rm = TRUE),
                                               DD_TOT_PROCESS           = mean(DD_TOT_PROCESS          , na.rm = TRUE),
                                               DD_AWARD_CONTRACT        = mean(DD_AWARD_CONTRACT       , na.rm = TRUE)), 
                                             by = list(DT_S, ID_ITEM, MED_DUMMY)]

n_bidders_s_medicine <- n_bidders_s_medicine %>% mutate(only_one_bidder = if_else(n_bidders == 1, 1, 0))

n_bidders_s_medicine <- n_bidders_s_medicine[, 
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
                                               DD_AWARD_CONTRACT        = mean(DD_AWARD_CONTRACT        , na.rm = TRUE)), 
                                             by = list(DT_S, MED_DUMMY)]



# Number of bidders -------------------------------------------------------

# Yearly - Medicine

plot <- graph_trend(
  data = n_bidders_y_medicine, 
  treatment = MED_DUMMY,
  variable = n_bidders, 
  title = "Tender Competiviness",
  subtitle = "Avg Number of Bidders, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 2,
  limit_upper = 5,
  interval_limits_y = 1,
  legend_upper = 4.6,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_bidders_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = n_bidders, 
  title = "Tender Competiviness",
  subtitle = "Avg Number of Bidders, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 2,
  limit_upper = 5,
  interval_limits_y = 1,
  legend_upper = 4.6,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_bidders_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

# Quarterly - Covid-19

plot <- graph_trend(
  data = n_bidders_y_covid, 
  treatment = COVID_LABEL,
  variable = n_bidders, 
  title = "Tender Competiviness",
  subtitle = "Avg Number of Bidders, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 2,
  limit_upper = 5,
  interval_limits_y = 1,
  legend_upper = 4.6,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_bidders_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = n_bidders, 
  title = "Tender Competiviness",
  subtitle = "Avg Number of Bidders, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 2,
  limit_upper = 5,
  interval_limits_y = 1,
  legend_upper = 4.6,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_bidders_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Share of tenders with only one bidder (all tenders) --------------------------

# Quarterly - Medicine

# Yearly - Medicine

plot <- graph_trend(
  data = n_bidders_y_medicine, 
  treatment = MED_DUMMY,
  variable = only_one_bidder, 
  title = "Tender Competiviness",
  subtitle = "Share of Tenders with only one Bidder",
  caption = "Source: Chile Compra",
  limit_lower = 20,
  limit_upper = 40,
  interval_limits_y = 10,
  legend_upper = 36,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/one_bidder_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = only_one_bidder, 
  title = "Tender Competiviness",
  subtitle = "Share of Tenders with only one Bidder",
  caption = "Source: Chile Compra",
  limit_lower = 20,
  limit_upper = 40,
  interval_limits_y = 10,
  legend_upper = 36,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/one_bidder_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_y_covid, 
  treatment = COVID_LABEL,
  variable = only_one_bidder, 
  title = "Tender Competiviness",
  subtitle = "Share of Tenders with only one Bidder",
  caption = "Source: Chile Compra",
  limit_lower = 20,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/one_bidder_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = only_one_bidder, 
  title = "Tender Competiviness",
  subtitle = "Share of Tenders with only one Bidder",
  caption = "Source: Chile Compra",
  limit_lower = 20,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/one_bidder_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Share of SMEs firm (all tenders) --------------------------

# Quarterly - Medicine

# Quarterly - Medicine

plot <- graph_trend(
  data = n_bidders_y_medicine, 
  treatment = MED_DUMMY,
  variable = sme_bidders, 
  title = "SMEs participation",
  subtitle = "Share of SMEs firms bidding, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 40,
  limit_upper = 70,
  interval_limits_y = 10,
  legend_upper = 66,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_bid_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = sme_bidders, 
  title = "SMEs participation",
  subtitle = "Share of SMEs firms bidding, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 40,
  limit_upper = 70,
  interval_limits_y = 10,
  legend_upper = 66,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_bid_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_y_covid, 
  treatment = COVID_LABEL,
  variable = sme_bidders, 
  title = "SMEs participation",
  subtitle = "Share of SMEs firms bidding, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 50,
  limit_upper = 70,
  interval_limits_y = 10,
  legend_upper = 66,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_bid_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)
plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = sme_bidders, 
  title = "SMEs participation",
  subtitle = "Share of SMEs firms bidding, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 50,
  limit_upper = 70,
  interval_limits_y = 10,
  legend_upper = 66,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_bid_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Quarterly - Covid-19

# Share of SMEs firms bidding (all tenders) --------------------------

# Quarterly - Medicine

# Quarterly - Medicine

plot <- graph_trend(
  data = n_bidders_y_medicine, 
  treatment = MED_DUMMY,
  variable = sme_winners, 
  title = "SMEs participation",
  subtitle = "Share of SMEs firms winning, per contract",
  caption = "Source: Chile Compra",
  limit_lower = 30,
  limit_upper = 60,
  interval_limits_y = 10,
  legend_upper = 56,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_win_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = sme_winners, 
  title = "SMEs participation",
  subtitle = "Share of SMEs firms winning, per contract",
  caption = "Source: Chile Compra",
  limit_lower = 30,
  limit_upper = 60,
  interval_limits_y = 10,
  legend_upper = 56,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_win_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_y_covid, 
  treatment = COVID_LABEL,
  variable = sme_winners, 
  title = "SMEs participation",
  subtitle = "Share of SMEs firms winning, per contract",
  caption = "Source: Chile Compra",
  limit_lower = 40,
  limit_upper = 70,
  interval_limits_y = 10,
  legend_upper = 66,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_win_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = sme_winners, 
  title = "SMEs participation",
  subtitle = "Share of SMEs firms winning, per contract",
  caption = "Source: Chile Compra",
  limit_lower = 40,
  limit_upper = 70,
  interval_limits_y = 10,
  legend_upper = 66,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_win_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)


# Quarterly - Covid-19

# Share of SMEs firms bidding (all tenders) --------------------------

# Quarterly - Medicine

# Yearly - Medicine

plot <- graph_trend(
  data = n_bidders_y_medicine, 
  treatment = MED_DUMMY,
  variable = same_region_bidder, 
  title = "Geography of Tenders",
  subtitle = "Share of bidding firms from the same region, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 20,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_bid_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)
plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = same_region_bidder, 
  title = "Geography of Tenders",
  subtitle = "Share of bidding firms from the same region, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 20,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_bid_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_y_covid, 
  treatment = COVID_LABEL,
  variable = same_region_bidder, 
  title = "Geography of Tenders",
  subtitle = "Share of bidding firms from the same region, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 30,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_bid_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)
plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = same_region_bidder, 
  title = "Geography of Tenders",
  subtitle = "Share of bidding firms from the same region, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 30,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_bid_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)


# Quarterly - Covid-19


# Share of SMEs firms bidding from same municipality (all tenders) -------------

# Quarterly - Medicine

# Yearly - Medicine

plot <- graph_trend(
  data = n_bidders_y_medicine, 
  treatment = MED_DUMMY,
  variable = same_municipality_bidder, 
  title = "Geography of Tenders",
  subtitle = "Share of bidding firms from the same municipality, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 10,
  interval_limits_y = 2,
  legend_upper = 9,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_bid_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)
plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = same_municipality_bidder, 
  title = "Geography of Tenders",
  subtitle = "Share of bidding firms from the same municipality, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 10,
  interval_limits_y = 2,
  legend_upper = 9,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_bid_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_y_covid, 
  treatment = COVID_LABEL,
  variable = same_municipality_bidder, 
  title = "Geography of Tenders",
  subtitle = "Share of bidding firms from the same municipality, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 4,
  limit_upper = 10,
  interval_limits_y = 2,
  legend_upper = 9,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_bid_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)
plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = same_municipality_bidder, 
  title = "Geography of Tenders",
  subtitle = "Share of bidding firms from the same municipality, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 4,
  limit_upper = 10,
  interval_limits_y = 2,
  legend_upper = 9,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_bid_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Quarterly - Covid-19

# Share of SMEs firms bidding from same municipality (all tenders) -------------

# Quarterly - Medicine

# Yearly - Medicine

plot <- graph_trend(
  data = n_bidders_y_medicine, 
  treatment = MED_DUMMY,
  variable = same_region_winner, 
  title = "Geography of Tenders",
  subtitle = "Share of winning firms from the same region, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 20,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_win_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)
plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = same_region_winner, 
  title = "Geography of Tenders",
  subtitle = "Share of winning firms from the same region, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 20,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_win_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_y_covid, 
  treatment = COVID_LABEL,
  variable = same_region_winner, 
  title = "Geography of Tenders",
  subtitle = "Share of winning firms from the same region, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 30,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_win_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = same_region_winner, 
  title = "Geography of Tenders",
  subtitle = "Share of winning firms from the same region, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 30,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_win_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Quarterly - Covid-19

# Share of SMEs firms bidding from same municipality (all tenders) -------------

# Quarterly - Medicine

# Yearly - Medicine

plot <- graph_trend(
  data = n_bidders_y_medicine, 
  treatment = MED_DUMMY,
  variable = same_municipality_winner, 
  title = "Geography of Tenders",
  subtitle = "Share of winning firms from the same municipality, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 10,
  interval_limits_y = 1,
  legend_upper = 10.5,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_win_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = same_municipality_winner, 
  title = "Geography of Tenders",
  subtitle = "Share of winning firms from the same municipality, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 10,
  interval_limits_y = 1,
  legend_upper = 10.5,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_win_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_y_covid, 
  treatment = COVID_LABEL,
  variable = same_municipality_winner, 
  title = "Geography of Tenders",
  subtitle = "Share of winning firms from the same municipality, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 5,
  limit_upper = 12,
  interval_limits_y = 1,
  legend_upper = 11.5,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_win_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = same_municipality_winner, 
  title = "Geography of Tenders",
  subtitle = "Share of winning firms from the same municipality, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 5,
  limit_upper = 12,
  interval_limits_y = 1,
  legend_upper = 11.5,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_win_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Quarterly - Covid-19

# Time to last bid (months)
last_bid_covid <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  distinct(ID_FIRM_RUT, ID_ITEM, DT_OFFER_SEND, DT_Y, DT_M, DT_S, COVID_LABEL) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_FIRM_RUT, ID_ITEM, MONTHS, DT_M, DT_Y, DT_S, COVID_LABEL) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

last_bid_y_covid <- last_bid_covid %>% 
  
  mutate(
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_Y, DT_M, ID_ITEM, COVID_LABEL) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE),
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE),
    new_bidder_24 = mean(new_bidder_24, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_Y, COVID_LABEL) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE)*100,
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE)*100,
    new_bidder_24 = mean(new_bidder_24, na.rm = TRUE)*100
  ) 

last_bid_s_covid <- last_bid_covid %>% 
  
  mutate(
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_S, ID_ITEM, COVID_LABEL) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE),
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE),
    new_bidder_24 = mean(new_bidder_24, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_S, COVID_LABEL) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE)*100,
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE)*100,
    new_bidder_24 = mean(new_bidder_24, na.rm = TRUE)*100
  ) 

# Time to last bid (months)
last_bid_medicine <- data_offer_sub %>% 
  
  mutate(MED_DUMMY = ifelse(substr(ID_ITEM_UNSPSC, 0, 2) == "42", 1, 0)) %>% 
  
  filter(DT_Y > 2014) %>% 
  distinct(ID_FIRM_RUT, ID_ITEM, DT_OFFER_SEND, DT_Y, DT_M, DT_S, MED_DUMMY) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_FIRM_RUT, ID_ITEM, MONTHS, DT_M, DT_Y, DT_S, MED_DUMMY) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

# last bid = 6 months

last_bid_y_medicine <- last_bid_medicine %>% 
  
  mutate(
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_Y, DT_M, ID_ITEM, MED_DUMMY) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE),
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE),
    new_bidder_24 = mean(new_bidder_24, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_Y, MED_DUMMY) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE)*100,
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE)*100,
    new_bidder_24 = mean(new_bidder_24, na.rm = TRUE)*100
  ) 

last_bid_s_medicine <- last_bid_medicine %>% 
  
  mutate(
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_S, ID_ITEM, MED_DUMMY) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE),
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE),
    new_bidder_24 = mean(new_bidder_24, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_S, MED_DUMMY) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_bidder_6 = mean(new_bidder_6, na.rm = TRUE)*100,
    new_bidder_12 = mean(new_bidder_12, na.rm = TRUE)*100,
    new_bidder_24 = mean(new_bidder_24, na.rm = TRUE)*100
  ) 

# Share of SMEs firms bidding from same municipality (all tenders) -------------

# Quarterly - Medicine

# Yearly - Medicine

plot <- graph_trend(
  data = last_bid_y_medicine, 
  treatment = MED_DUMMY,
  variable = new_bidder_6, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (6 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 4,
  interval_limits_y = 1,
  legend_upper = 3.7,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_6_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_y_covid, 
  treatment = COVID_LABEL,
  variable = new_bidder_6, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (6 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 1,
  limit_upper = 4,
  interval_limits_y = 1,
  legend_upper = 4.7,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_6_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = last_bid_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_bidder_6, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (6 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 4,
  interval_limits_y = 1,
  legend_upper = 3.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_6_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_covid, 
  treatment = COVID_LABEL,
  variable = new_bidder_6, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (6 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 1,
  limit_upper = 4,
  interval_limits_y = 1,
  legend_upper = 4.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_6_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Quarterly - Covid-19

# Share of SMEs firms bidding from same municipality (all tenders) -------------

# Quarterly - Medicine

# Yearly - Medicine

plot <- graph_trend(
  data = last_bid_y_medicine, 
  treatment = MED_DUMMY,
  variable = new_bidder_12, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (12 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 2,
  interval_limits_y = 0.5,
  legend_upper = 1.7,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_12_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_y_covid, 
  treatment = COVID_LABEL,
  variable = new_bidder_12, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (12 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 3,
  interval_limits_y = 0.5,
  legend_upper = 2.7,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_12_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = last_bid_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_bidder_12, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (12 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 2,
  interval_limits_y = 0.5,
  legend_upper = 1.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_12_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_covid, 
  treatment = COVID_LABEL,
  variable = new_bidder_12, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (12 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 3,
  interval_limits_y = 0.5,
  legend_upper = 2.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_12_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = last_bid_y_medicine, 
  treatment = MED_DUMMY,
  variable = new_bidder_24, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (24 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 2,
  interval_limits_y = 0.5,
  legend_upper = 1.7,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_24_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_y_covid, 
  treatment = COVID_LABEL,
  variable = new_bidder_24, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (24 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 3,
  interval_limits_y = 0.5,
  legend_upper = 2.7,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_24_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = last_bid_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_bidder_24, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (24 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 2,
  interval_limits_y = 0.5,
  legend_upper = 1.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_24_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_covid, 
  treatment = COVID_LABEL,
  variable = new_bidder_24, 
  title = "Firms Participation",
  subtitle = "Share of new bidding firms (24 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 3,
  interval_limits_y = 0.5,
  legend_upper = 2.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_24_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Quarterly - Covid-19

# Time to last bid (months)
last_win_covid <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_FIRM_RUT, ID_ITEM, DT_OFFER_SEND, DT_Y, DT_M, DT_S, COVID_LABEL) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_FIRM_RUT, ID_ITEM, MONTHS, DT_M, DT_Y, DT_S, COVID_LABEL) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

# last bid = 6 months
last_win_y_covid <- last_win_covid %>% 
  
  mutate(
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_Y, ID_ITEM, COVID_LABEL) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE),
    new_winner_12 = mean(new_winner_12, na.rm = TRUE),
    new_winner_24 = mean(new_winner_24, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_Y, COVID_LABEL) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE)*100,
    new_winner_12 = mean(new_winner_12, na.rm = TRUE)*100,
    new_winner_24 = mean(new_winner_24, na.rm = TRUE)*100
    
  ) 

last_win_s_covid <- last_win_covid %>% 
  
  mutate(
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_S, ID_ITEM, COVID_LABEL) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE),
    new_winner_12 = mean(new_winner_12, na.rm = TRUE),
    new_winner_24 = mean(new_winner_24, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_S, COVID_LABEL) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE)*100,
    new_winner_12 = mean(new_winner_12, na.rm = TRUE)*100,
    new_winner_24 = mean(new_winner_24, na.rm = TRUE)*100
    
  ) 

# Time to last bid (months)
last_win_medicine <- data_offer_sub %>% 
  
  mutate(MED_DUMMY = ifelse(substr(ID_ITEM_UNSPSC, 0, 2) == "42", 1, 0)) %>% 
  
  filter(DT_Y > 2014) %>% 
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_FIRM_RUT, ID_ITEM, DT_OFFER_SEND, DT_Y, DT_M, DT_S, MED_DUMMY) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_FIRM_RUT, ID_ITEM, MONTHS, DT_M, DT_Y, DT_S, MED_DUMMY) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

# last bid = 6 months
# last bid = 6 months
last_win_y_medicine <- last_win_medicine %>% 
  
  mutate(
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_Y, ID_ITEM, MED_DUMMY) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE),
    new_winner_12 = mean(new_winner_12, na.rm = TRUE),
    new_winner_24 = mean(new_winner_24, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_Y, MED_DUMMY) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE)*100,
    new_winner_12 = mean(new_winner_12, na.rm = TRUE)*100,
    new_winner_24 = mean(new_winner_24, na.rm = TRUE)*100
  ) 

last_win_s_medicine <- last_win_medicine %>% 
  
  mutate(
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) %>% 
  
  # Collapse at the item (tender-level)
  group_by(DT_S, ID_ITEM, MED_DUMMY) %>% 
  
  # Summarise main variables we will need in the next graphs
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE),
    new_winner_12 = mean(new_winner_12, na.rm = TRUE),
    new_winner_24 = mean(new_winner_24, na.rm = TRUE)
  )   %>%
  
  # Collapse at the quarter level and distinguishing between T and C 
  group_by(DT_S, MED_DUMMY) %>% 
  
  # Summarise main variables needed
  dplyr::summarise(
    new_winner_6 = mean(new_winner_6, na.rm = TRUE)*100,
    new_winner_12 = mean(new_winner_12, na.rm = TRUE)*100,
    new_winner_24 = mean(new_winner_24, na.rm = TRUE)*100
  ) 

# Share of SMEs firms bidding from same municipality (all tenders) -------------

# Quarterly - Medicine

# Yearly - Medicine

plot <- graph_trend(
  data = last_win_y_medicine, 
  treatment = MED_DUMMY,
  variable = new_winner_12, 
  title = "Firms Participation",
  subtitle = "Share of new winning firms (12 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 3,
  interval_limits_y = 0.5,
  legend_upper = 2.7,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_12_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_y_covid, 
  treatment = COVID_LABEL,
  variable = new_winner_12, 
  title = "Firms Participation",
  subtitle = "Share of new winning firms (12 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 4,
  interval_limits_y = 0.5,
  legend_upper = 3.7,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_12_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = last_win_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_winner_12, 
  title = "Firms Participation",
  subtitle = "Share of new winning firms (12 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 3,
  interval_limits_y = 0.5,
  legend_upper = 2.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_12_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_covid, 
  treatment = COVID_LABEL,
  variable = new_winner_12, 
  title = "Firms Participation",
  subtitle = "Share of new winning firms (12 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 4,
  interval_limits_y = 0.5,
  legend_upper = 3.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_12_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)
# Quarterly - Covid-19

# Share of SMEs firms bidding from same municipality (all tenders) -------------

# Quarterly - Medicine
# Yearly - Medicine

plot <- graph_trend(
  data = last_win_y_medicine, 
  treatment = MED_DUMMY,
  variable = new_winner_6, 
  title = "Firms Participation",
  subtitle = "Share of new winning firms (6 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 5,
  interval_limits_y = 0.5,
  legend_upper = 4.7,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_6_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_y_covid, 
  treatment = COVID_LABEL,
  variable = new_winner_6, 
  title = "Firms Participation",
  subtitle = "Share of new winning firms (6 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 7,
  interval_limits_y = 0.5,
  legend_upper = 6.7,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_6_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = last_win_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_winner_6, 
  title = "Firms Participation",
  subtitle = "Share of new winning firms (6 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 5,
  interval_limits_y = 0.5,
  legend_upper = 4.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_6_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_covid, 
  treatment = COVID_LABEL,
  variable = new_winner_6, 
  title = "Firms Participation",
  subtitle = "Share of new winning firms (6 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 7,
  interval_limits_y = 0.5,
  legend_upper = 6.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_6_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = last_win_y_medicine, 
  treatment = MED_DUMMY,
  variable = new_winner_24, 
  title = "Firms Participation",
  subtitle = "Share of new winning firms (24 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 5,
  interval_limits_y = 0.5,
  legend_upper = 4.7,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_24_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_y_covid, 
  treatment = COVID_LABEL,
  variable = new_winner_24, 
  title = "Firms Participation",
  subtitle = "Share of new winning firms (24 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 7,
  interval_limits_y = 0.5,
  legend_upper = 6.7,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_24_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = last_win_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_winner_24, 
  title = "Firms Participation",
  subtitle = "Share of new winning firms (24 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 5,
  interval_limits_y = 0.5,
  legend_upper = 4.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_24_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_covid, 
  treatment = COVID_LABEL,
  variable = new_winner_24, 
  title = "Firms Participation",
  subtitle = "Share of new winning firms (24 months), per tender",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 7,
  interval_limits_y = 0.5,
  legend_upper = 6.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_24_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)


# Decision Time  ---------------------------------------------------------------

# Yearly - Medicine

plot <- graph_trend(
  data = n_bidders_y_medicine, 
  treatment = MED_DUMMY,
  variable = DD_DECISION, 
  title = "Tender process duration",
  subtitle = "Avg number of days for decision time, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 35,
  limit_upper = 95,
  interval_limits_y = 5,
  legend_upper = 90,
  percentage = FALSE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_time_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_y_covid, 
  treatment = COVID_LABEL,
  variable = DD_DECISION, 
  title = "Tender process duration",
  subtitle = "Avg number of days for decision time, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 35,
  limit_upper = 95,
  interval_limits_y = 5,
  legend_upper = 90,
  percentage = FALSE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_time_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)
  
plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = DD_DECISION, 
  title = "Tender process duration",
  subtitle = "Avg number of days for decision time, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 35,
  limit_upper = 95,
  interval_limits_y = 5,
  legend_upper = 90,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_time_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = DD_DECISION, 
  title = "Tender process duration",
  subtitle = "Avg number of days for decision time, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 35,
  limit_upper = 95,
  interval_limits_y = 5,
  legend_upper = 90,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_time_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Decision Time  ---------------------------------------------------------------

# Yearly - Medicine

plot <- graph_trend(
  data = n_bidders_y_medicine, 
  treatment = MED_DUMMY,
  variable = DD_TOT_PROCESS, 
  title = "Tender process duration",
  subtitle = "Avg number of days for total process time, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 45,
  limit_upper = 125,
  interval_limits_y = 5,
  legend_upper = 120,
  percentage = FALSE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_process_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_y_covid, 
  treatment = COVID_LABEL,
  variable = DD_TOT_PROCESS, 
  title = "Tender process duration",
  subtitle = "Avg number of days for total process time, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 35,
  limit_upper = 95,
  interval_limits_y = 5,
  legend_upper = 90,
  percentage = FALSE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_process_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = DD_TOT_PROCESS, 
  title = "Tender process duration",
  subtitle = "Avg number of days for total process time, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 45,
  limit_upper = 125,
  interval_limits_y = 5,
  legend_upper = 120,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_process_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = DD_TOT_PROCESS, 
  title = "Tender process duration",
  subtitle = "Avg number of days for total process time, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 35,
  limit_upper = 95,
  interval_limits_y = 5,
  legend_upper = 90,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_process_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)


# Decision Time  ---------------------------------------------------------------

# Yearly - Medicine

plot <- graph_trend(
  data = n_bidders_y_medicine, 
  treatment = MED_DUMMY,
  variable = DD_SUBMISSION, 
  title = "Tender process duration",
  subtitle = "Avg number of days for submission time, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 8,
  limit_upper = 14,
  interval_limits_y = 1,
  legend_upper = 13.5,
  percentage = FALSE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_submission_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_y_covid, 
  treatment = COVID_LABEL,
  variable = DD_SUBMISSION, 
  title = "Tender process duration",
  subtitle = "Avg number of days for submission time, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 8,
  limit_upper = 14,
  interval_limits_y = 1,
  legend_upper = 13.5,
  percentage = FALSE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_submission_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = DD_SUBMISSION, 
  title = "Tender process duration",
  subtitle = "Avg number of days for submission time, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 8,
  limit_upper = 14,
  interval_limits_y = 1,
  legend_upper = 13.5,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_submission_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = DD_SUBMISSION, 
  title = "Tender process duration",
  subtitle = "Avg number of days for submission time, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 8,
  limit_upper = 14,
  interval_limits_y = 1,
  legend_upper = 13.5,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_submission_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_y_medicine, 
  treatment = MED_DUMMY,
  variable = DD_AWARD_CONTRACT, 
  title = "Tender process duration",
  subtitle = "Avg number of days between award and contract, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 30,
  limit_upper = 100,
  interval_limits_y = 10,
  legend_upper = 95,
  percentage = FALSE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_award_contract_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_y_covid, 
  treatment = COVID_LABEL,
  variable = DD_AWARD_CONTRACT, 
  title = "Tender process duration",
  subtitle = "Avg number of days between award and contract, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 30,
  limit_upper = 80,
  interval_limits_y = 10,
  legend_upper = 75,
  percentage = FALSE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_award_contract_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = DD_AWARD_CONTRACT, 
  title = "Tender process duration",
  subtitle = "Avg number of days between award and contract, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 30,
  limit_upper = 100,
  interval_limits_y = 10,
  legend_upper = 95,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_award_contract_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = DD_AWARD_CONTRACT, 
  title = "Tender process duration",
  subtitle = "Avg number of days between award and contract, per tender",
  caption = "Source: Chile Compra",
  limit_lower = 30,
  limit_upper = 80,
  interval_limits_y = 10,
  legend_upper = 75,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_award_contract_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

table_product_firms_bid <- data_offer_sub %>% 
  
  filter(DT_Y > 2015) %>% 
  mutate(ID_ITEM_UNSPSC = ifelse(nchar(ID_ITEM_UNSPSC) == 9, NA, ID_ITEM_UNSPSC)) %>% 
  mutate(product = substr(ID_ITEM_UNSPSC, 0, 6)) %>% 
  distinct(ID_FIRM_RUT, DT_Y, product) %>% 
  group_by(ID_FIRM_RUT, DT_Y) %>% 
  dplyr::summarise(n_product = n()) %>% 
  group_by(DT_Y) %>% 
  dplyr::summarise(n_product = mean(n_product, na.rm = TRUE))

plot <- graph_trend_no_treat(
  data = table_product_firms_bid, 
  variable = n_product, 
  title = "Market Concentration",
  subtitle = "Number of different products bidded, per firm",
  caption = "Source: Chile Compra",
  limit_lower = 4,
  limit_upper = 6,
  interval_limits_y = 0.2,
  legend_upper = 5.8,
  percentage = FALSE
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_products_bid_.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

table_product_firms_bid <- data_offer_sub %>% 
  
  filter(DT_Y > 2015) %>% 
  mutate(ID_ITEM_UNSPSC = ifelse(nchar(ID_ITEM_UNSPSC) == 9, NA, ID_ITEM_UNSPSC)) %>% 
  mutate(product = substr(ID_ITEM_UNSPSC, 0, 6)) %>% 
  distinct(ID_FIRM_RUT, DT_S, product) %>% 
  group_by(ID_FIRM_RUT, DT_S) %>% 
  dplyr::summarise(n_product = n()) %>% 
  group_by(DT_S) %>% 
  dplyr::summarise(n_product = mean(n_product, na.rm = TRUE))

plot <- graph_trend_no_treat(
  data = table_product_firms_bid, 
  variable = n_product, 
  title = "Market Concentration",
  subtitle = "Number of different products bidded, per firm",
  caption = "Source: Chile Compra",
  limit_lower = 4,
  limit_upper = 6,
  interval_limits_y = 0.2,
  legend_upper = 5.8,
  percentage = FALSE,
  yearly = FALSE
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_products_semester_bid_.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

table_product_firms_win <- data_offer_sub %>% 
  
  filter(DT_Y > 2015 & CAT_OFFER_SELECT == 1) %>% 
  mutate(ID_ITEM_UNSPSC = ifelse(nchar(ID_ITEM_UNSPSC) == 9, NA, ID_ITEM_UNSPSC)) %>% 
  mutate(product = substr(ID_ITEM_UNSPSC, 0, 6)) %>% 
  distinct(ID_FIRM_RUT, DT_Y, product) %>% 
  group_by(ID_FIRM_RUT, DT_Y) %>% 
  dplyr::summarise(n_product = n()) %>% 
  group_by(DT_Y) %>% 
  dplyr::summarise(n_product = mean(n_product, na.rm = TRUE))

plot <- graph_trend_no_treat(
  data = table_product_firms_win, 
  variable = n_product, 
  title = "Market Concentration",
  subtitle = "Number of different products awarded, per firm",
  caption = "Source: Chile Compra",
  limit_lower = 3,
  limit_upper = 4.5,
  interval_limits_y = 0.2,
  legend_upper = 4.5,
  percentage = FALSE
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_products_win_.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

table_product_firms_win <- data_offer_sub %>% 
  
  filter(DT_Y > 2015 & CAT_OFFER_SELECT == 1) %>% 
  mutate(ID_ITEM_UNSPSC = ifelse(nchar(ID_ITEM_UNSPSC) == 9, NA, ID_ITEM_UNSPSC)) %>% 
  mutate(product = substr(ID_ITEM_UNSPSC, 0, 6)) %>% 
  distinct(ID_FIRM_RUT, DT_S, product) %>% 
  group_by(ID_FIRM_RUT, DT_S) %>% 
  dplyr::summarise(n_product = n()) %>% 
  group_by(DT_S) %>% 
  dplyr::summarise(n_product = mean(n_product, na.rm = TRUE))

plot <- graph_trend_no_treat(
  data = table_product_firms_win, 
  variable = n_product, 
  title = "Market Concentration",
  subtitle = "Number of different products awarded, per firm",
  caption = "Source: Chile Compra",
  limit_lower = 3,
  limit_upper = 4.5,
  interval_limits_y = 0.2,
  legend_upper = 4.5,
  percentage = FALSE,
  yearly = FALSE
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_products_semester_win_.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)
  
n_bidders_sector <- data_offer_sub %>% 
  
  filter(DT_Y > 2015) %>% 
  mutate(ID_ITEM_UNSPSC = ifelse(nchar(ID_ITEM_UNSPSC) == 9, NA, ID_ITEM_UNSPSC)) %>% 
  mutate(sector = substr(ID_ITEM_UNSPSC, 0, 2)) %>% 
  distinct(ID_FIRM_RUT, DT_Y, sector, CAT_MEDICAL) %>% 
  group_by(sector, DT_Y, CAT_MEDICAL) %>% 
  dplyr::summarise(n_bidders_sector = n()) %>% 
  group_by(DT_Y, CAT_MEDICAL) %>% 
  dplyr::summarise(n_bidders_sector = mean(n_bidders_sector, na.rm = TRUE))

plot <- graph_trend(
  data = n_bidders_sector, 
  treatment = CAT_MEDICAL,
  variable = n_bidders_sector, 
  title = "Market Concentration",
  subtitle = "Total Number of bidders, per sector",
  caption = "Source: Chile Compra",
  limit_lower = 1000,
  limit_upper = 4000,
  interval_limits_y = 500,
  legend_upper = 4100,
  percentage = FALSE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_bid_sector.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

n_bidders_sector <- data_offer_sub %>% 
  
  filter(DT_Y > 2015) %>% 
  mutate(ID_ITEM_UNSPSC = ifelse(nchar(ID_ITEM_UNSPSC) == 9, NA, ID_ITEM_UNSPSC)) %>% 
  mutate(sector = substr(ID_ITEM_UNSPSC, 0, 2)) %>% 
  distinct(ID_FIRM_RUT, DT_S, sector, CAT_MEDICAL) %>% 
  group_by(sector, DT_S, CAT_MEDICAL) %>% 
  dplyr::summarise(n_bidders_sector = n()) %>% 
  group_by(DT_S, CAT_MEDICAL) %>% 
  dplyr::summarise(n_bidders_sector = mean(n_bidders_sector, na.rm = TRUE))

plot <- graph_trend(
  data = n_bidders_sector, 
  treatment = CAT_MEDICAL,
  variable = n_bidders_sector, 
  title = "Market Concentration",
  subtitle = "Total Number of bidders, per sector",
  caption = "Source: Chile Compra",
  limit_lower = 1000,
  limit_upper = 3000,
  interval_limits_y = 500,
  legend_upper = 4100,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_bid_semester_sector.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

n_winners_sector <- data_offer_sub %>% 
  
  filter(DT_Y > 2015 & CAT_OFFER_SELECT == 1) %>% 
  mutate(ID_ITEM_UNSPSC = ifelse(nchar(ID_ITEM_UNSPSC) == 9, NA, ID_ITEM_UNSPSC)) %>% 
  mutate(sector = substr(ID_ITEM_UNSPSC, 0, 2)) %>% 
  distinct(ID_FIRM_RUT, DT_Y, sector, CAT_MEDICAL) %>% 
  group_by(sector, DT_Y, CAT_MEDICAL) %>% 
  dplyr::summarise(n_winner_sector = n()) %>% 
  group_by(DT_Y, CAT_MEDICAL) %>% 
  dplyr::summarise(n_winner_sector = mean(n_winner_sector, na.rm = TRUE))

plot <- graph_trend(
  data = n_winners_sector, 
  treatment = CAT_MEDICAL,
  variable = n_winner_sector, 
  title = "Market Concentration",
  subtitle = "Number of Suppliers, per sector",
  caption = "Source: Chile Compra",
  limit_lower = 800,
  limit_upper = 2400,
  interval_limits_y = 200,
  legend_upper = 2400,
  percentage = FALSE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_win_sector.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

n_winners_sector <- data_offer_sub %>% 
  
  filter(DT_Y > 2015 & CAT_OFFER_SELECT == 1) %>% 
  mutate(ID_ITEM_UNSPSC = ifelse(nchar(ID_ITEM_UNSPSC) == 9, NA, ID_ITEM_UNSPSC)) %>% 
  mutate(sector = substr(ID_ITEM_UNSPSC, 0, 2)) %>% 
  distinct(ID_FIRM_RUT, DT_S, sector, CAT_MEDICAL) %>% 
  group_by(sector, DT_S, CAT_MEDICAL) %>% 
  dplyr::summarise(n_winner_sector = n()) %>% 
  group_by(DT_S, CAT_MEDICAL) %>% 
  dplyr::summarise(n_winner_sector = mean(n_winner_sector, na.rm = TRUE))

plot <- graph_trend(
  data = n_winners_sector, 
  treatment = CAT_MEDICAL,
  variable = n_winner_sector, 
  title = "Market Concentration",
  subtitle = "Number of Suppliers, per sector",
  caption = "Source: Chile Compra",
  limit_lower = 400,
  limit_upper = 1800,
  interval_limits_y = 200,
  legend_upper = 1750,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_win_semester_sector.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

concentration <- data_offer_sub %>% 
  
  filter(DT_Y > 2015 & CAT_OFFER_SELECT == 1) %>% 
  mutate(ID_ITEM_UNSPSC = ifelse(nchar(ID_ITEM_UNSPSC) == 9, NA, ID_ITEM_UNSPSC)) %>% 
  na.omit() %>% 
  mutate(sector = substr(ID_ITEM_UNSPSC, 0, 2)) %>% 
  group_by(ID_FIRM_RUT, sector, DT_Y, CAT_MEDICAL) %>% 
  dplyr::summarise(firm_sum = sum(AMT_VALUE_AWARDED, na.rm = TRUE)) %>% 
  group_by(sector, DT_Y, CAT_MEDICAL) %>% 
  mutate(tot_sum = sum(firm_sum, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(concentration = ((firm_sum/tot_sum)*100)^2) %>% 
  group_by(sector, DT_Y, CAT_MEDICAL) %>% 
  summarise(concentration = sum(concentration, na.rm = TRUE)) %>% 
  group_by(CAT_MEDICAL, DT_Y) %>% 
  summarise(concentration = mean(concentration, na.rm = TRUE))

# Yearly - Medicine

plot <- graph_trend(
  data = concentration, 
  treatment = CAT_MEDICAL,
  variable = concentration, 
  title = "Market Concentration",
  subtitle = "HERFINDAHL-HIRSCHMAN INDEX, per sector",
  caption = "Source: Chile Compra",
  limit_lower = 50,
  limit_upper = 400,
  interval_limits_y = 50,
  legend_upper = 380,
  percentage = FALSE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/hhi_year_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

concentration <- data_offer_sub %>% 
  
  filter(DT_Y > 2015 & CAT_OFFER_SELECT == 1) %>% 
  mutate(ID_ITEM_UNSPSC = ifelse(nchar(ID_ITEM_UNSPSC) == 9, NA, ID_ITEM_UNSPSC)) %>% 
  na.omit() %>% 
  mutate(sector = substr(ID_ITEM_UNSPSC, 0, 2)) %>% 
  group_by(ID_FIRM_RUT, sector, DT_S, CAT_MEDICAL) %>% 
  dplyr::summarise(firm_sum = sum(AMT_VALUE_AWARDED, na.rm = TRUE)) %>% 
  group_by(sector, DT_S, CAT_MEDICAL) %>% 
  mutate(tot_sum = sum(firm_sum, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(concentration = ((firm_sum/tot_sum)*100)^2) %>% 
  group_by(sector, DT_S, CAT_MEDICAL) %>% 
  summarise(concentration = sum(concentration, na.rm = TRUE)) %>% 
  group_by(CAT_MEDICAL, DT_S) %>% 
  summarise(concentration = mean(concentration, na.rm = TRUE))

# Yearly - Medicine

plot <- graph_trend(
  data = concentration, 
  treatment = CAT_MEDICAL,
  variable = concentration, 
  title = "Market Concentration",
  subtitle = "HERFINDAHL-HIRSCHMAN INDEX, per sector",
  caption = "Source: Chile Compra",
  limit_lower = 50,
  limit_upper = 600,
  interval_limits_y = 50,
  legend_upper = 580,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/hhi_semester_medic.jpeg"),
  plot = plot                                                ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

data_pos_raw <- data_pos_raw %>% 
  mutate(
    CAT_DIRECT      = ifelse(CAT_DIRECT      == "Si", 1, 0),
    CAT_COMPRA_AGIL = ifelse(CAT_COMPRA_AGIL == "Si", 1, 0)
  )

data_po_collapse <- data_pos_raw %>% 
  filter(DT_YEAR > 2015) %>%  
  group_by(DT_YEAR) %>% 
  mutate(AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(
    CAT_DIRECT_SUM = AMT_VALUE*CAT_DIRECT
  )

data_po_collapse <- as.data.table(data_po_collapse)

data_po_collapse <- data_po_collapse[, 
                                  list(
                                    CAT_DIRECT_N    = mean(CAT_DIRECT, na.rm = TRUE),
                                    CAT_DIRECT_VAL  = sum(CAT_DIRECT_SUM, na.rm = TRUE),
                                    AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)
                                  ), 
                                      by = list(DT_YEAR, ID_PURCHASE_ORDER, COVID_LABEL)]

data_po_collapse <- data_po_collapse[, 
                                 list(
                                   CAT_DIRECT_N      = mean(CAT_DIRECT_N, na.rm = TRUE),
                                   CAT_DIRECT_VAL  = sum(CAT_DIRECT_VAL, na.rm = TRUE),
                                   AMT_VALUE_SUM = sum(AMT_VALUE_SUM, na.rm = TRUE)
                                 ), 
                                 by = list(DT_YEAR, COVID_LABEL)]

data_po_collapse <- data_po_collapse %>% mutate(CAT_DIRECT_VAL = CAT_DIRECT_VAL/AMT_VALUE_SUM) %>% select(- AMT_VALUE_SUM) %>% rename(DT_Y = DT_YEAR)

plot <- graph_trend(
  data = data_po_collapse, 
  variable = CAT_DIRECT_N, 
  treatment = COVID_LABEL, 
  title = "Direct tenders",
  subtitle = "Share of direct tender (number of contracts)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 0.6,
  interval_limits_y = 0.1,
  legend_upper = 0.58,
  percentage = TRUE,
  yearly = TRUE
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_direct_contracts_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

data_po_collapse <- data_pos_raw %>% 
  filter(DT_YEAR > 2015) %>%  
  group_by(DT_YEAR) %>% 
  mutate(AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(
    CAT_DIRECT_SUM = AMT_VALUE*CAT_DIRECT
  ) 

data_po_collapse <- as.data.table(data_po_collapse)

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N    = mean(CAT_DIRECT, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_SUM, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)
                                     ), 
                                     by = list(DT_YEAR, ID_PURCHASE_ORDER, CAT_MEDICAL)]

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N      = mean(CAT_DIRECT_N, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_VAL, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE_SUM, na.rm = TRUE)
                                     ), 
                                     by = list(DT_YEAR, CAT_MEDICAL)]

data_po_collapse <- data_po_collapse %>% mutate(CAT_DIRECT_VAL = CAT_DIRECT_VAL/AMT_VALUE_SUM) %>% select(- AMT_VALUE_SUM) %>% rename(DT_Y = DT_YEAR)

plot <- graph_trend(
  data = data_po_collapse, 
  variable = CAT_DIRECT_N, 
  treatment = CAT_MEDICAL, 
  title = "Direct tenders",
  subtitle = "Share of direct tender (number of contracts)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 0.6,
  interval_limits_y = 0.1,
  legend_upper = 0.58,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_direct_contracts_year_medical.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

data_po_collapse <- data_pos_raw %>% 
  filter(DT_YEAR > 2015) %>%  
  group_by(DT_S) %>% 
  mutate(AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(
    CAT_DIRECT_SUM = AMT_VALUE*CAT_DIRECT
  ) 

data_po_collapse <- as.data.table(data_po_collapse)

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N    = mean(CAT_DIRECT, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_SUM, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)
                                     ), 
                                     by = list(DT_S, ID_PURCHASE_ORDER, COVID_LABEL)]

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N      = mean(CAT_DIRECT_N, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_VAL, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE_SUM, na.rm = TRUE)
                                     ), 
                                     by = list(DT_S, COVID_LABEL)]

data_po_collapse <- data_po_collapse %>% mutate(CAT_DIRECT_VAL = CAT_DIRECT_VAL/AMT_VALUE_SUM) %>% select(- AMT_VALUE_SUM) 

plot <- graph_trend(
  data = data_po_collapse, 
  variable = CAT_DIRECT_N, 
  treatment = COVID_LABEL, 
  title = "Direct tenders",
  subtitle = "Share of direct tender (number of contracts)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 0.6,
  interval_limits_y = 0.1,
  legend_upper = 0.58,
  percentage = TRUE,
  yearly = FALSE
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_direct_contracts_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

data_po_collapse <- data_pos_raw %>% 
  filter(DT_YEAR > 2015) %>% 
  group_by(DT_S) %>% 
  mutate(AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(
    CAT_DIRECT_SUM = AMT_VALUE*CAT_DIRECT
  ) 

data_po_collapse <- as.data.table(data_po_collapse)

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N    = mean(CAT_DIRECT, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_SUM, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)
                                     ), 
                                     by = list(DT_S, ID_PURCHASE_ORDER, CAT_MEDICAL)]

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N      = mean(CAT_DIRECT_N, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_VAL, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE_SUM, na.rm = TRUE)
                                     ), 
                                     by = list(DT_S, CAT_MEDICAL)]

data_po_collapse <- data_po_collapse %>% mutate(CAT_DIRECT_VAL = CAT_DIRECT_VAL/AMT_VALUE_SUM) %>% select(- AMT_VALUE_SUM) 

plot <- graph_trend(
  data = data_po_collapse, 
  variable = CAT_DIRECT_N, 
  treatment = CAT_MEDICAL, 
  title = "Direct tenders",
  subtitle = "Share of direct tender (number of contracts)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 0.6,
  interval_limits_y = 0.1,
  legend_upper = 0.58,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_direct_contracts_semester_medical.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

data_po_collapse <- data_pos_raw %>% 
  filter(DT_YEAR > 2015) %>%  
  group_by(DT_YEAR) %>% 
  mutate(AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(
    CAT_DIRECT_SUM = AMT_VALUE*CAT_DIRECT
  )

data_po_collapse <- as.data.table(data_po_collapse)

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N    = mean(CAT_DIRECT, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_SUM, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)
                                     ), 
                                     by = list(DT_YEAR, ID_PURCHASE_ORDER, COVID_LABEL)]

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N      = mean(CAT_DIRECT_N, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_VAL, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE_SUM, na.rm = TRUE)
                                     ), 
                                     by = list(DT_YEAR, COVID_LABEL)]

data_po_collapse <- data_po_collapse %>% mutate(CAT_DIRECT_VAL = CAT_DIRECT_VAL/AMT_VALUE_SUM) %>% select(- AMT_VALUE_SUM) %>% rename(DT_Y = DT_YEAR)

plot <- graph_trend(
  data = data_po_collapse, 
  variable = CAT_DIRECT_VAL, 
  treatment = COVID_LABEL, 
  title = "Direct tenders",
  subtitle = "Share of direct tender (value of contracts)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 0.3,
  interval_limits_y = 0.1,
  legend_upper = 0.28,
  percentage = TRUE,
  yearly = TRUE
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/value_direct_contracts_year_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

data_po_collapse <- data_pos_raw %>% 
  filter(DT_YEAR > 2015) %>%  
  group_by(DT_YEAR) %>% 
  mutate(AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(
    CAT_DIRECT_SUM = AMT_VALUE*CAT_DIRECT
  ) 

data_po_collapse <- as.data.table(data_po_collapse)

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N    = mean(CAT_DIRECT, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_SUM, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)
                                     ), 
                                     by = list(DT_YEAR, ID_PURCHASE_ORDER, CAT_MEDICAL)]

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N      = mean(CAT_DIRECT_N, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_VAL, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE_SUM, na.rm = TRUE)
                                     ), 
                                     by = list(DT_YEAR, CAT_MEDICAL)]

data_po_collapse <- data_po_collapse %>% mutate(CAT_DIRECT_VAL = CAT_DIRECT_VAL/AMT_VALUE_SUM) %>% select(- AMT_VALUE_SUM) %>% rename(DT_Y = DT_YEAR)

plot <- graph_trend(
  data = data_po_collapse, 
  variable = CAT_DIRECT_VAL, 
  treatment = CAT_MEDICAL, 
  title = "Direct tenders",
  subtitle = "Share of direct tender (value of contracts)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 0.3,
  interval_limits_y = 0.1,
  legend_upper = 0.28,
  percentage = TRUE,
  yearly = TRUE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/value_direct_contracts_year_medical.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

data_po_collapse <- data_pos_raw %>% 
  filter(DT_YEAR > 2015) %>%  
  group_by(DT_S) %>% 
  mutate(AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(
    CAT_DIRECT_SUM = AMT_VALUE*CAT_DIRECT
  ) 

data_po_collapse <- as.data.table(data_po_collapse)

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N    = mean(CAT_DIRECT, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_SUM, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)
                                     ), 
                                     by = list(DT_S, ID_PURCHASE_ORDER, COVID_LABEL)]

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N      = mean(CAT_DIRECT_N, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_VAL, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE_SUM, na.rm = TRUE)
                                     ), 
                                     by = list(DT_S, COVID_LABEL)]

data_po_collapse <- data_po_collapse %>% mutate(CAT_DIRECT_VAL = CAT_DIRECT_VAL/AMT_VALUE_SUM) %>% select(- AMT_VALUE_SUM) 

plot <- graph_trend(
  data = data_po_collapse, 
  variable = CAT_DIRECT_VAL, 
  treatment = COVID_LABEL, 
  title = "Direct tenders",
  subtitle = "Share of direct tender (value of contracts)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 0.4,
  interval_limits_y = 0.1,
  legend_upper = 0.38,
  percentage = TRUE,
  yearly = FALSE
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/value_direct_contracts_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

data_po_collapse <- data_pos_raw %>% 
  filter(DT_YEAR > 2015) %>% 
  group_by(DT_S) %>% 
  mutate(AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(
    CAT_DIRECT_SUM = AMT_VALUE*CAT_DIRECT
  ) 

data_po_collapse <- as.data.table(data_po_collapse)

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N    = mean(CAT_DIRECT, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_SUM, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE, na.rm = TRUE)
                                     ), 
                                     by = list(DT_S, ID_PURCHASE_ORDER, CAT_MEDICAL)]

data_po_collapse <- data_po_collapse[, 
                                     list(
                                       CAT_DIRECT_N      = mean(CAT_DIRECT_N, na.rm = TRUE),
                                       CAT_DIRECT_VAL  = sum(CAT_DIRECT_VAL, na.rm = TRUE),
                                       AMT_VALUE_SUM = sum(AMT_VALUE_SUM, na.rm = TRUE)
                                     ), 
                                     by = list(DT_S, CAT_MEDICAL)]

data_po_collapse <- data_po_collapse %>% mutate(CAT_DIRECT_VAL = CAT_DIRECT_VAL/AMT_VALUE_SUM) %>% select(- AMT_VALUE_SUM)

plot <- graph_trend(
  data = data_po_collapse, 
  variable = CAT_DIRECT_VAL, 
  treatment = CAT_MEDICAL, 
  title = "Direct tenders",
  subtitle = "Share of direct tender (value of contracts)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 0.5,
  interval_limits_y = 0.1,
  legend_upper = 0.48,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/value_direct_contracts_semester_medical.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

