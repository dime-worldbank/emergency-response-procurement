
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
    pacman::p_load(packages, character.only = TRUE, install = FALSE)
    
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

graph_trend <- function(
    data, 
    variable, 
    treatment, 
    title, 
    caption,
    limit_lower,
    limit_upper, 
    interval_limits_y,
    legend_upper,
    label_treatment_legend = "Covid-19 items",
    label_control_legend = "Other items",
    label_control_2_legend = "Other Medical Products",
    percentage = FALSE,
    yearly = FALSE
) {
  
  variable <- enquo(variable)
  treatment <- enquo(treatment)
  
  if (yearly == FALSE) {
    
    plot <- ggplot() +
      
      ggplot2::annotate("segment", x = 8.5, xend = 8.5, y = limit_lower - limit_lower*0.1, yend = limit_upper, color = "black", alpha = 0.5, size = 1, linetype = 2) +
      geom_point(data = data %>% filter(!!treatment == 1), aes(x = DT_S, y = !!variable), shape = 16, size = 3, color = "#FF0100") +
      geom_point(data = data %>% filter(!!treatment == 0), aes(x = DT_S, y = !!variable), shape = 18, size = 4, color = "#18466E") +
      geom_line(data = data %>% filter(!!treatment == 1), aes(x = DT_S, y = !!variable), size = 0.7, color = "#FF0100") +
      geom_line(data = data %>% filter(!!treatment == 0), aes(x = DT_S, y = !!variable), size = 0.7, color = "#18466E", linetype = 2)  +
      labs(title    = title,
           caption  = caption,
           x = NULL,
           y = NULL) +
      scale_x_continuous(breaks = seq(1,14),
                         labels = c(
                           "<b>2016 S1</b>",
                           "<b>2016 S2</b>",
                           "<b>2017 S1</b>",
                           "<b>2017 S2</b>",
                           "<b>2018 S1</b>",
                           "<b>2018 S2</b>",
                           "<b>2019 S1</b>",
                           "<b>2019 S2</b>",
                           "<b>2020 S1</b>",
                           "<b>2020 S2</b>",
                           "<b>2021 S1</b>",
                           "<b>2021 S2</b>",
                           "<b>2022 S1</b>",
                           "<b>2022 S2</b>"
                         ),
                         limits = c(0, 17),
                         expand = c(0, 0)) +
      scale_y_continuous(
        breaks = seq(limit_lower, limit_upper, by = interval_limits_y)
      ) +
      coord_cartesian(
        expand = FALSE,
        clip   = "off"
      ) + 
      theme(
        aspect.ratio = 3.2/7,
        text = element_text(family = "Roboto"),
        plot.margin = margin(0, 5, 0, 5),
        panel.background = element_rect(fill = "white"),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color = "darkgrey"),
        axis.ticks.length = unit(.25, "cm"),
        legend.text = element_blank(),
        legend.title = element_blank(),
        legend.key.width = unit(25,"pt"),
        legend.key.height = unit(15, "pt"),
        axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
        axis.text.y = element_blank(),
        axis.line.x  = element_line(color = "gray8"),
        axis.ticks.y = element_blank(),
        plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
        plot.caption = element_text(hjust = 0, size = 9),
        plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5),
        legend.position="none") + 
      ggplot2::annotate("segment", color = "#FF0100", x = 13, xend = 14, y = legend_upper + legend_upper * 0.03, yend = legend_upper + legend_upper * 0.03, size = 1) +
      ggplot2::annotate("segment", linetype = 2, color = "#18466E", x = 13, xend = 14, y = legend_upper - legend_upper * 0.1, yend = legend_upper - legend_upper * 0.1, size = 1) +
      geom_point(aes(x = 13.55, y = legend_upper + legend_upper * 0.03), shape = 16, size = 3, color = "#FF0100") +
      geom_point(aes(x = 13.55, y = legend_upper - legend_upper * 0.1), shape = 18, size = 4, color = "#18466E") +
      geom_text( family = "Roboto", fontface = "bold", x = 15.2, y = legend_upper + legend_upper * 0.03, aes(label = label_treatment_legend)) +
      geom_text( family = "Roboto", fontface = "bold", x = 15, y = legend_upper - legend_upper * 0.1, aes(label = label_control_legend)) 

    if (percentage == TRUE) {
      
      plot <- plot +
        geom_text(
          data = data.frame(x = 17, y = seq(limit_lower, limit_upper, by = interval_limits_y)),
          aes(x, y, label = paste0(y, "%")),
          hjust = 1, # Align to the right
          vjust = - 0.5, # Align to the bottom
          size = 5
        )
      
    } else {
      
      plot <- plot +
        geom_text(
          data = data.frame(x = 17, y = seq(limit_lower, limit_upper, by = interval_limits_y)),
          aes(x, y, label = y),
          hjust = 1, # Align to the right
          vjust = - 0.5, # Align to the bottom
          size = 5
        )
      
    }
  
  return(plot)
  
}}

# Load cleaned tender data
data_offer_sub <- fread(file.path(fin_data, "data_offer_sub.csv" ), encoding = "Latin-1")

data_po <- fread(file = file.path(fin_data, "purchase_orders.csv"), encoding = "Latin-1") 

data = data_po[DT_YEAR > 2015, 
                             list(
                               N_CONTRACTS  = .N,
                               VOLUMES      = sum(AMT_VALUE, na.rm = TRUE)
                             ), 
                             by = list(DT_S, COVID_LABEL)]

plot <- graph_trend(
  data = data, 
  treatment = COVID_LABEL,
  variable = N_CONTRACTS/1000, 
  title = "Number of contracts (órdenes de compra) in thousands per semester",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 1200,
  interval_limits_y = 100,
  legend_upper = 1200,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/trend_n_contracts_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

plot <- graph_trend(
  data = data, 
  treatment = COVID_LABEL,
  variable = VOLUMES/1000000, 
  title = "Contracted amount in millions (usd) per semester",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 6000,
  interval_limits_y = 300,
  legend_upper = 6000,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/trend_volume_contracts_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Task 1

n_bidders_s_covid <- data_offer_sub[DT_TENDER_YEAR > 2015, 
                                    list(
                                      n_bidders                =    .N                                      ,
                                      sme_bidders              = mean(CAT_MSME                     , na.rm = TRUE),
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

# Yearly - Covid-19

# Quarterly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = n_bidders, 
  title = "Average number of bidders per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 5,
  interval_limits_y = 1,
  legend_upper = 4.6,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_bidders_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Share of tenders with only one bidder (all tenders) --------------------------

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = only_one_bidder, 
  title = "Share of lots (ItemXLicitacion) with only one bidder",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/one_bidder_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Share of SMEs firm bidding (all tenders) --------------------------

# Yearly - Covid-19


plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = sme_bidders, 
  title = "Share of bidders per lot (ItemXLicitacion) that are SMEs",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 80,
  interval_limits_y = 10,
  legend_upper = 85,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_bid_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Share of SMEs firms winning (all tenders) --------------------------

# Yearly - Covid-19



plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = sme_winners, 
  title = "Share of winning bidders per lot (ItemXLicitacion) that are SMEs",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 80,
  interval_limits_y = 10,
  legend_upper = 80,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_win_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Quarterly - Covid-19

# Share of bidders from the same region (all tenders) --------------------------

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = same_region_bidder, 
  title = "Share of bidding firms per lot (ItemXLicitacion) that are from the same region",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 50,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_bid_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Quarterly - Covid-19


# Share of bidders from the same municipality (all tenders) -------------
# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = same_municipality_bidder, 
  title = "Share of bidding firms per lot (ItemXLicitacion) that are from the same municipality",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 10,
  interval_limits_y = 2,
  legend_upper = 9,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_bid_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Share of winners from the same region (all tenders) -------------

# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = same_region_winner, 
  title = "Share of winning firms per lot (ItemXLicitacion) that are from the same region",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 70,
  interval_limits_y = 10,
  legend_upper = 65,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_win_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Share of winners from the same municipality (all tenders) -------------

# Yearly - Covid-19


plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = same_municipality_winner, 
  title = "Share of winning firms per lot (ItemXLicitacion) that are from the same municipality",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 12,
  interval_limits_y = 1,
  legend_upper = 11.5,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_win_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Time to last bid (months)
last_bid_covid <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, DT_OFFER_SEND, DT_Y, DT_M, DT_S, COVID_LABEL) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, MONTHS, DT_M, DT_Y, DT_S, COVID_LABEL) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

last_bid_s_covid <- last_bid_covid %>% 
  
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
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

# Share of new bidders within the last 6 months (all tenders) -------------

# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_covid, 
  treatment = COVID_LABEL,
  variable = new_bidder_6, 
  title = "Share of new bidding firms (6 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 6,
  interval_limits_y = 1,
  legend_upper = 5.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_6_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Share of new bidders within the last 12 months (all tenders) -------------
# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_covid, 
  treatment = COVID_LABEL,
  variable = new_bidder_12, 
  title = "Share of new bidding firms (12 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 5,
  interval_limits_y = 0.5,
  legend_upper = 4.5,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_12_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)
# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_covid, 
  treatment = COVID_LABEL,
  variable = new_bidder_24, 
  title = "Share of new bidding firms (24 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 4,
  interval_limits_y = 0.5,
  legend_upper = 4,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_24_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Time to last bid (months)
last_win_covid <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, DT_OFFER_SEND, DT_Y, DT_M, DT_S, COVID_LABEL) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, MONTHS, DT_M, DT_Y, DT_S, COVID_LABEL) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

# la
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
# Share of new winners within the last 6 months (all tenders) -------------

# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_covid, 
  treatment = COVID_LABEL,
  variable = new_winner_12, 
  title = "Share of new winning firms (12 months) per lot (ItemXLicitacion)",
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
  filename = file.path(dropbox_dir, "Outputs/new_win_12_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)
# Quarterly - Covid-19

# Share of new winners within the last 12 months (all tenders) -------------

# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_covid, 
  treatment = COVID_LABEL,
  variable = new_winner_6, 
  title = "Share of new winning firms (6 months) per lot (ItemXLicitacion)",
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
  filename = file.path(dropbox_dir, "Outputs/new_win_6_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19


# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_covid, 
  treatment = COVID_LABEL,
  variable = new_winner_24, 
  title = "Share of new winning firms (24 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 2,
  interval_limits_y = 0.5,
  legend_upper = 2,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_24_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Decision Time    ---------------------------------------------------------------
# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = DD_DECISION, 
  title = "Decision time",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 80,
  interval_limits_y = 10,
  legend_upper = 70,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_time_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Tot Process Time ---------------------------------------------------------------
# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = DD_TOT_PROCESS, 
  title = "Total processing time",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 100,
  interval_limits_y = 10,
  legend_upper = 100,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_process_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Submission Time  ---------------------------------------------------------------
# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = DD_SUBMISSION, 
  title = "Submission time",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 16,
  interval_limits_y = 2,
  legend_upper = 16,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_submission_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19


# Yearly - Covid-19

plot <- graph_trend(
  data = n_bidders_s_covid, 
  treatment = COVID_LABEL,
  variable = DD_AWARD_CONTRACT, 
  title = "Awarding time",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 80,
  interval_limits_y = 10,
  legend_upper = 75,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_award_contract_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)
data_po <- data_po %>% 
  mutate(
    CAT_DIRECT      = ifelse(cat_direct      == "Si", 1, 0))

data_po_collapse <- data_po[DT_YEAR > 2015, 
                            list(
                              CAT_DIRECT     = mean(cat_direct, na.rm = TRUE),
                              CAT_DIRECT_VAL = sum(amt_tot_usd_oc_win, na.rm = TRUE)
                            ), 
                            by = list(DT_S, id_purchase_order, COVID_LABEL)]

data_po_collapse <- data_po_collapse %>% filter(CAT_DIRECT == 0 | CAT_DIRECT == 1)

data_po_collapse <- data_po_collapse %>% 
  group_by(DT_S) %>% 
  mutate(AMT_VALUE_SUM = sum(CAT_DIRECT_VAL, na.rm = TRUE)) %>% 
  ungroup() 


data_po_collapse <- data_po_collapse %>% 
  mutate(
    AMT_VALUE = CAT_DIRECT_VAL*CAT_DIRECT
  )%>% 
  group_by(DT_S, COVID_LABEL, AMT_VALUE_SUM) %>% 
  dplyr::summarise(
    CAT_DIRECT_N   = mean(CAT_DIRECT, na.rm = TRUE)*100,
    CAT_DIRECT_VAL = sum(AMT_VALUE, na.rm = TRUE)
  )

# Compute the total volume by DT_S
total_volume <- copy(data_po_collapse)[, .(
  Total_Volume = sum(CAT_DIRECT_VAL)
  ), 
  by = .(DT_S, COVID_LABEL)]

# Merge the total volume with the original data
data_po_collapse <- merge(data_po_collapse, total_volume, by = c("DT_S", "COVID_LABEL"))

# Compute the share of volumes by DT_S and CAT_DIRECT
data_po_collapse[, 
                 .(Share_Volume = CAT_DIRECT_VAL / Total_Volume,
                   CAT_DIRECT_N = mean(CAT_DIRECT)), 
                 by = .(DT_S, COVID_LABEL)]

plot <- graph_trend(
  data = data_po_collapse, 
  variable = CAT_DIRECT_N, 
  treatment = COVID_LABEL, 
  title = "Share of number of contracts (órdenes de compra) contracted through direct",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 30,
  interval_limits_y = 5,
  legend_upper = 28,
  percentage = TRUE,
  yearly = FALSE
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_direct_contracts_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

plot <- graph_trend(
  data = data_po_collapse, 
  variable = Share_Volume, 
  treatment = COVID_LABEL, 
  title = "Share of volume of órdenes de compra (órdenes de compra) contracted through direct",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 40,
  interval_limits_y = 5,
  legend_upper = 38,
  percentage = TRUE,
  yearly = FALSE
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/value_direct_contracts_semester_covid.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


last_bid_covid <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, ID_RUT_BUYER, DT_OFFER_SEND, DT_Y, DT_M, DT_S, COVID_LABEL) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, ID_RUT_BUYER, MONTHS, DT_M, DT_Y, DT_S, COVID_LABEL) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM, ID_RUT_BUYER
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

last_bid_s_covid <- last_bid_covid %>% 
  
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
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

# Time to last

# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_covid, 
  treatment = COVID_LABEL,
  variable = new_bidder_6, 
  title = "Share of firms bidding for the first time in the last 6 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 20,
  interval_limits_y = 2,
  legend_upper = 20,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_6_semester_covid_2.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Share of new firms bidding to the entity within the last 12 months -------------

# Yearly - Covid-19

# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_covid, 
  treatment = COVID_LABEL,
  variable = new_bidder_12, 
  title = "Share of firms bidding for the first time in the last 12 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 17,
  interval_limits_y = 1,
  legend_upper = 16.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_12_semester_covid_2.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19


# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_covid, 
  treatment = COVID_LABEL,
  variable = new_bidder_24, 
  title = "Share of firms bidding for the first time in the last 24 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 15,
  interval_limits_y = 1,
  legend_upper = 14.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_24_semester_covid_2.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Time to last bid (months)
last_win_covid <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, ID_RUT_BUYER, DT_OFFER_SEND, DT_Y, DT_M, DT_S, COVID_LABEL) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, ID_RUT_BUYER, MONTHS, DT_M, DT_Y, DT_S, COVID_LABEL) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM, ID_RUT_BUYER
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

# last bi

last_win_s_covid <- last_win_covid %>% 
  
  mutate(
    LAST_WIN_MONTHS = ifelse(is.na(LAST_WIN_MONTHS), 999999, LAST_WIN_MONTHS), 
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
# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_covid, 
  treatment = COVID_LABEL,
  variable = new_winner_12, 
  title = "Share of firms winning for the first time in the last 12 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 25,
  interval_limits_y = 5,
  legend_upper = 24.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_12_semester_covid_2.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)
# Quarterly - Covid-19

# Share of new firms winning to the entity within the last 12 months -------------

# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_covid, 
  treatment = COVID_LABEL,
  variable = new_winner_6, 
  title = "Share of firms winning for the first time in the last 6 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 30,
  interval_limits_y = 5,
  legend_upper = 29.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_6_semester_covid_2.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Yearly - Covid-19

# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_covid, 
  treatment = COVID_LABEL,
  variable = new_winner_24, 
  title = "Share of firms winning for the first time in the last 24 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 25,
  interval_limits_y = 5,
  legend_upper = 24.7,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_24_semester_covid_2.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height  = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

