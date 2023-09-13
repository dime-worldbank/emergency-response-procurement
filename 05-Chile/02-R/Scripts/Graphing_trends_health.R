
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
    label_treatment_legend = "Health",
    label_control_legend = "Food Beverage and Tobacco",
    label_control_2_legend = "Office Equipment",
    label_control_3_legend = "Building and Maintenance Services",
    label_control_4_legend = "Other Sectors",
    percentage = FALSE,
    yearly = FALSE,
    adjust_value = 0.1
) {
  
  variable <- enquo(variable)
  treatment <- enquo(treatment)
  
  if (yearly == FALSE) {
    
    y_values = seq(from = limit_upper + 0.1, by = interval_limits_y*adjust_value, length.out = 5)
    
    plot <- ggplot() +
      
      ggplot2::annotate("segment", x = 8.5, xend = 8.5, y = limit_lower - limit_lower*0.1, yend = limit_upper, color = "black", alpha = 0.5, size = 1, linetype = 2) +
      
      geom_point(data = data %>% filter(!!treatment == 1), aes(x = DT_S, y = !!variable), shape = 16, size = 3, color = "#FF0100") +
      geom_line(data = data %>% filter(!!treatment == 1), aes(x = DT_S, y = !!variable), size = 0.7, color = "#FF0100") +
      geom_point(data = data %>% filter(!!treatment == 0), aes(x = DT_S, y = !!variable), shape = 17, size = 3, color = "#18466E") +
      geom_line(data = data %>% filter(!!treatment == 0), aes(x = DT_S, y = !!variable), size = 0.7, color = "#18466E", linetype = 2)  +
      geom_point(data = data %>% filter(!!treatment == 2), aes(x = DT_S, y = !!variable), shape = 18, size = 3, color = "#6BA841") +
      geom_line(data = data %>% filter(!!treatment == 2), aes(x = DT_S, y = !!variable), size = 0.7, color = "#6BA841", linetype = 3)  +
      geom_point(data = data %>% filter(!!treatment == 3), aes(x = DT_S, y = !!variable), shape = 19, size = 3, color = "#F79D31") +
      geom_line(data = data %>% filter(!!treatment == 3), aes(x = DT_S, y = !!variable), size = 0.7, color = "#F79D31", linetype = 4) +
      geom_point(data = data %>% filter(!!treatment == 4), aes(x = DT_S, y = !!variable), shape = 8, size = 3, color = "#873F76") +
      geom_line(data = data %>% filter(!!treatment == 4), aes(x = DT_S, y = !!variable), size = 0.7, color = "#873F76", linetype = 5) +

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
        legend.position="none")  +
      
      labs(
        title = title,
        caption = caption,
        x = "",
        y = ""
      ) +
      
      guides(
        color = guide_legend(override.aes = list(shape = c(16, 17, 18, 19, 8), linetype = c(1, 2, 3, 4, 5))),
        shape = guide_legend(override.aes = list(color = c("#FF0100", "#18466E", "#6BA841", "#F79D31", "#873F76")))
      ) +
      
      scale_color_manual(
        values = c("#FF0100", "#18466E", "#6BA841", "#F79D31", "#873F76"),
        labels = c(label_treatment_legend, label_control_legend, label_control_2_legend, label_control_3_legend, label_control_4_legend),
        breaks = c("#FF0100", "#18466E", "#6BA841", "#F79D31", "#873F76")
      )  +
      
      geom_segment(aes(x = 13, xend = 14, y = y_values[1], yend = y_values[1]), colour = "#FF0100", linetype = 1, size = 0.7) +
      geom_point(aes(x = 13.5, y = y_values[1]), color = "#FF0100", shape = 16, size = 3) +
      geom_text(aes(x = 14.2, y = y_values[1]), label = label_treatment_legend, hjust = 0) +
      
      geom_segment(aes(x = 13, xend = 14, y = y_values[2], yend = y_values[2]), colour = "#18466E", linetype = 2, size = 0.7) +
      geom_point(aes(x = 13.5, y = y_values[2]), color = "#18466E", shape = 17, size = 3) +
      geom_text(aes(x = 14.2, y = y_values[2]), label = label_control_legend, hjust = 0) +
      
      geom_segment(aes(x = 13, xend = 14, y = y_values[3], yend = y_values[3]), colour = "#6BA841", linetype = 3, size = 0.7) +
      geom_point(aes(x = 13.5, y = y_values[3]), color = "#6BA841", shape = 18, size = 3) +
      geom_text(aes(x = 14.2, y = y_values[3]), label = label_control_2_legend, hjust = 0) +
      
      geom_segment(aes(x = 13, xend = 14, y = y_values[4], yend = y_values[4]), colour = "#F79D31", linetype = 4, size = 0.7) +
      geom_point(aes(x = 13.5, y = y_values[4]), color = "#F79D31", shape = 19, size = 3) +
      geom_text(aes(x = 14.2, y = y_values[4]), label = label_control_3_legend, hjust = 0) +
      
      geom_segment(aes(x = 13, xend = 14, y = y_values[5], yend = y_values[5]), colour = "#873F76", linetype = 5, size = 0.7) +
      geom_point(aes(x = 13.5, y = y_values[5]), color = "#873F76", shape = 8, size = 3) +
      geom_text(aes(x = 14.2, y = y_values[5]), label = label_control_4_legend, hjust = 0) 
      
    
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
  }
}
  

# Load cleaned tender data
data_offer_sub <- fread(file.path(fin_data, "data_offer_sub.csv" ), encoding = "Latin-1")

data_po <- fread(file = file.path(fin_data, "purchase_orders.csv"), encoding = "Latin-1") 

data_po = data_po[, SECTOR := substr(ID_ITEM_UNSPSC, 0, 2)] %>% 
  .[CAT_MEDICAL == 1, SECTOR := 42] %>% 
  .[SECTOR == 0, SECTOR := NA] %>% 
  .[,
    SECTOR := fcase(
      SECTOR == 42, "Health Sector",
      SECTOR == 50, "Food Beverage and Tobacco Products",
      SECTOR == 44, "Office Equipment and Accessories and Supplies",
      SECTOR == 72, "Building and Facility Construction and Maintenance Services", default = "Other Sectors"
    )
  ] %>% 
  .[,
    MED_DUMMY := fcase(
      SECTOR == "Health Sector", 1,
      SECTOR == "Food Beverage and Tobacco Products", 0, 
      SECTOR == "Office Equipment and Accessories and Supplies", 2, 
      SECTOR == "Building and Facility Construction and Maintenance Services", 3, default = 4
    )
  ]

data_offer_sub = data_offer_sub[, SECTOR := substr(ID_ITEM_UNSPSC, 0, 2)] %>% 
  .[CAT_MEDICAL == 1, SECTOR := 42] %>% 
  .[SECTOR == 0, SECTOR := NA] %>% 
  .[,
    SECTOR := fcase(
      SECTOR == 42, "Health Sector",
      SECTOR == 50, "Food Beverage and Tobacco Products",
      SECTOR == 44, "Office Equipment and Accessories and Supplies",
      SECTOR == 72, "Building and Facility Construction and Maintenance Services", default = "Other Sectors"
    )
  ] %>% 
  .[,
    MED_DUMMY := fcase(
      SECTOR == "Health Sector", 1,
      SECTOR == "Food Beverage and Tobacco Products", 0, 
      SECTOR == "Office Equipment and Accessories and Supplies", 2, 
      SECTOR == "Building and Facility Construction and Maintenance Services", 3, default = 4
    )
  ]

n_bidders_s_medicine <- data_offer_sub[DT_TENDER_YEAR > 2015, 
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
                                       by = list(DT_S, ID_ITEM, SECTOR, MED_DUMMY)]

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
                                             by = list(DT_S, SECTOR, MED_DUMMY)]


# Number of bidders -------------------------------------------------------

# Yearly - Medicine

plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = n_bidders, 
  title = "Average number of bidders per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 5,
  interval_limits_y = 1,
  legend_upper = 4,
  yearly = FALSE,
  adjust_value = 0.2
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_bidders_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19

# Quarterly - Covid-19


# Share of tenders with only one bidder (all tenders) --------------------------

# Quarterly - Medicine

# Yearly - Medicine

plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = only_one_bidder, 
  title = "Share of lots (ItemXLicitacion) with only one bidder",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 70,
  interval_limits_y = 10,
  legend_upper = 60,
  percentage = TRUE,
  yearly = FALSE,
  adjust_value = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/one_bidder_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Share of SMEs firm bidding (all tenders) --------------------------

# Quarterly - Medicine

# Quarterly - Medicine

plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = sme_bidders, 
  title = "Share of bidding firms per lot (ItemXLicitacion) that are SMEs",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 100,
  interval_limits_y = 10,
  legend_upper = 66,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical",
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_bid_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Quarterly - Covid-19

# Share of SMEs firms winning (all tenders) --------------------------

# Quarterly - Medicine

# Quarterly - Medicine
plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = sme_winners, 
  title = "Share of winning bidders per lot (ItemXLicitacion) that are SMEs",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 100,
  interval_limits_y = 10,
  legend_upper = 56,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical",
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_win_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19

# Quarterly - Covid-19

# Share of bidders from the same region (all tenders) --------------------------

# Quarterly - Medicine

# Yearly - Medicine

plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = same_region_bidder, 
  title = "Share of winning firms per lot (ItemXLicitacion) that are from the same region",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 100,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical",
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_bid_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Quarterly - Covid-19


# Share of bidders from the same municipality (all tenders) -------------

# Quarterly - Medicine

# Yearly - Medicine


plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = same_municipality_bidder, 
  title = "Share of bidding firms per lot (ItemXLicitacion) that are from the same municipality",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 35,
  interval_limits_y = 5,
  legend_upper = 9,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical",
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_bid_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Quarterly - Covid-19

# Share of winners from the same region (all tenders) -------------

# Quarterly - Medicine

# Yearly - Medicine


plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = same_region_winner, 
  title = "Share of winning firms per lot (ItemXLicitacion) that are from the same region",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 100,
  interval_limits_y = 10,
  legend_upper = 46,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical",
  adjust = 0.35
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/region_win_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Quarterly - Covid-19

# Share of winners from the same municipality (all tenders) -------------

# Quarterly - Medicine

# Yearly - Medicine


plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = same_municipality_winner, 
  title = "Share of winning firms per lot (ItemXLicitacion) that are from the same municipality",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 40,
  interval_limits_y = 5,
  legend_upper = 10.5,
  percentage = TRUE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical",
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/municipality_win_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19



# Time to last bid (months)
last_bid_medicine <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, DT_OFFER_SEND, DT_Y, DT_M, DT_S, MED_DUMMY) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, MONTHS, DT_M, DT_Y, DT_S, MED_DUMMY) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

# last bid = 6 months

last_bid_s_medicine <- last_bid_medicine %>% 
  
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
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

# Share of new bidders within the last 6 months (all tenders) -------------

# Quarterly - Medicine

# Yearly - Medicine


plot <- graph_trend(
  data = last_bid_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_bidder_6, 
  title = "Share of new bidding firms (6 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 15,
  interval_limits_y = 3,
  legend_upper = 4.7,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_6_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19

# Quarterly - Covid-19

# Share of new bidders within the last 12 months (all tenders) -------------

# Quarterly - Medicine

# Yearly - Medicine


plot <- graph_trend(
  data = last_bid_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_bidder_12, 
  title = "Share of new bidding firms (12 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 8,
  interval_limits_y = 1,
  legend_upper = 2.7,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_12_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


plot <- graph_trend(
  data = last_bid_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_bidder_24, 
  title = "Share of new bidding firms (24 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 7,
  interval_limits_y = 0.5,
  legend_upper = 2.7,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.5
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_24_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19
# Quarterly - Covid-19

# Time to last bid (months)
last_win_medicine <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, DT_OFFER_SEND, DT_Y, DT_M, DT_S, MED_DUMMY) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, MONTHS, DT_M, DT_Y, DT_S, MED_DUMMY) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

# last bid = 6 months
# last
last_win_s_medicine <- last_win_medicine %>% 
  
  mutate(
    LAST_WIN_MONTHS = ifelse(is.na(LAST_WIN_MONTHS), 999999, LAST_WIN_MONTHS), 
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

# Share of new winners within the last 6 months (all tenders) -------------

# Quarterly - Medicine

# Yearly - Medicine


# Yearly - Covid-19


plot <- graph_trend(
  data = last_win_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_winner_12, 
  title = "Share of new winning firms (12 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 15,
  interval_limits_y = 3,
  legend_upper = 4.7,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_12_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19

# Quarterly - Covid-19

# Share of new winners within the last 12 months (all tenders) -------------

# Quarterly - Medicine
# Yearly - Medicine


# Yearly - Covid-19


plot <- graph_trend(
  data = last_win_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_winner_6, 
  title = "Share of new winning firms (6 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 25,
  interval_limits_y = 5,
  legend_upper = 6.7,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_6_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19


# Yearly - Covid-19


plot <- graph_trend(
  data = last_win_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_winner_24, 
  title = "Share of new winning firms (24 months) per lot (ItemXLicitacion)",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 10,
  interval_limits_y = 1,
  legend_upper = 3.7,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_24_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19


# Decision Time    ---------------------------------------------------------------

# Yearly - Medicine

# Yearly - Covid-19


plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = DD_DECISION, 
  title = "Decision time",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 90,
  interval_limits_y = 10,
  legend_upper = 90,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Medical",
  label_control_legend = "Non-medical",
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_time_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19




# Tot Process Time ---------------------------------------------------------------

# Yearly - Medicine
# Yearly - Covid-19


plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = DD_TOT_PROCESS, 
  title = "Total processing time",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 110,
  interval_limits_y = 10,
  legend_upper = 120,
  percentage = FALSE,
  yearly = FALSE,
  adjust = 0.35
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_process_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Submission Time  ---------------------------------------------------------------

# Yearly - Medicine

# Yearly - Covid-19


plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = DD_SUBMISSION, 
  title = "Submission time",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 20,
  interval_limits_y = 2,
  legend_upper = 13.5,
  percentage = FALSE,
  yearly = FALSE,
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_submission_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Yearly - Covid-19


plot <- graph_trend(
  data = n_bidders_s_medicine, 
  treatment = MED_DUMMY,
  variable = DD_AWARD_CONTRACT, 
  title = "Awarding time",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 90,
  interval_limits_y = 10,
  legend_upper = 95,
  percentage = FALSE,
  yearly = FALSE,
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/dd_award_contract_semester_health.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Medicine



data_po[, CAT_DIRECT := fcase(CAT_DIRECT == "No", 0,
                              CAT_DIRECT == "Si", 1, default = NA)]
data_po_collapse <- data_po[DT_YEAR > 2015, 
                            list(
                              CAT_DIRECT     = mean(CAT_DIRECT, na.rm = TRUE),
                              CAT_DIRECT_VAL = sum(AMT_VALUE, na.rm = TRUE)
                            ), 
                            by = list(DT_S, ID_PURCHASE_ORDER, MED_DUMMY)]

data_po_collapse <- data_po_collapse %>% filter(CAT_DIRECT == 0 | CAT_DIRECT == 1)

data_po_collapse <- data_po_collapse %>% 
  group_by(DT_S) %>% 
  mutate(AMT_VALUE_SUM = sum(CAT_DIRECT_VAL, na.rm = TRUE)) %>% 
  ungroup() 

data_po_collapse <- data_po_collapse %>% 
  mutate(
    AMT_VALUE = CAT_DIRECT_VAL*CAT_DIRECT
  )%>% 
  group_by(DT_S, MED_DUMMY, AMT_VALUE_SUM) %>% 
  dplyr::summarise(
    CAT_DIRECT_N   = mean(CAT_DIRECT, na.rm = TRUE)*100,
    CAT_DIRECT_VAL = sum(AMT_VALUE, na.rm = TRUE)
  )

data_po_collapse <- data_po_collapse %>% mutate(CAT_DIRECT_VAL = CAT_DIRECT_VAL/AMT_VALUE_SUM*100) %>% select(- AMT_VALUE_SUM)

plot <- graph_trend(
  data = data_po_collapse, 
  variable = CAT_DIRECT_N, 
  treatment = MED_DUMMY, 
  title = "Share of number of contracts (órdenes de compra) contracted through direct",
  caption = "Source: Chile Compra", 
  limit_lower = 0,
  limit_upper = 80,
  interval_limits_y = 10,
  legend_upper = 58,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_direct_contracts_semester_health.png"),
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
  treatment = MED_DUMMY, 
  title = "Share of volume of contracts (órdenes de compra) contracted through direct",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 25,
  interval_limits_y = 5,
  legend_upper = 28,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.3
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/value_direct_contracts_semester_health.png"),
  plot = plot                                                 ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Time to last bid (months)
last_bid_medicine <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, ID_RUT_BUYER, DT_OFFER_SEND, DT_Y, DT_M, DT_S, MED_DUMMY) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, ID_RUT_BUYER, MONTHS, DT_M, DT_Y, DT_S, MED_DUMMY) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM, ID_RUT_BUYER
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

# last bid = 6 months

last_bid_s_medicine <- last_bid_medicine %>% 
  
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
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

# Share of new firms bidding to the entity within the last 6 months (all tenders) -------------

# Yearly - Covid-19


plot <- graph_trend(
  data = last_bid_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_bidder_6, 
  title = "Share of bidders that are bidding for the first time in the last 6 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 45,
  interval_limits_y = 5,
  legend_upper = 3.7,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.5
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_6_semester_health_2.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Share of new firms bidding to the entity within the last 12 months -------------

# Yearly - Covid-19

plot <- graph_trend(
  data = last_bid_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_bidder_12, 
  title = "Share of bidders that are bidding for the first time in the last 12 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 40,
  interval_limits_y = 5,
  legend_upper = 2.7,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.5
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_12_semester_health_2.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19

# Yearly - Covid-19


plot <- graph_trend(
  data = last_bid_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_bidder_24, 
  title = "Share of bidders that are bidding for the first time in the last 24 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 35,
  interval_limits_y = 5,
  legend_upper = 1.7,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.5
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_bid_24_semester_health_2.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Yearly - Covid-19

# Time to last bid (months)
last_win_medicine <- data_offer_sub %>% 
  
  filter(DT_Y > 2014) %>% 
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_RUT_FIRM, ID_ITEM, ID_RUT_BUYER, DT_OFFER_SEND, DT_Y, DT_M, DT_S, MED_DUMMY) %>% 
  mutate(
    MONTHS = DT_Y * 12 + DT_M
  ) %>% 
  distinct(ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, MONTHS, DT_M, DT_Y, DT_S, MED_DUMMY) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM, ID_RUT_BUYER
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  filter(DT_Y > 2015)

# last bid = 6 months
# last bid = 6 

last_win_s_medicine <- last_win_medicine %>% 
  
  mutate(
    LAST_WIN_MONTHS = ifelse(is.na(LAST_WIN_MONTHS), 999999, LAST_WIN_MONTHS), 
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

# Share of new firms winning to the entity within the last 6 months -------------

# Quarterly - Medicine

# Yearly - Medicine

# Yearly - Covid-19


plot <- graph_trend(
  data = last_win_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_winner_12, 
  title = "Share of firms winning for the first time in the last 12 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 50,
  interval_limits_y = 5,
  legend_upper = 24.7,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.5
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_12_semester_health_2.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

# Share of new firms winning to the entity within the last 12 months -------------

# Quarterly - Medicine
# Yearly - Medicine


# Yearly - Covid-19

plot <- graph_trend(
  data = last_win_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_winner_6, 
  title = "Share of firms winning for the first time in the last 6 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 55,
  interval_limits_y = 5,
  legend_upper = 29.7,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.5
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_6_semester_health_2.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)


# Yearly - Covid-19


plot <- graph_trend(
  data = last_win_s_medicine, 
  treatment = MED_DUMMY,
  variable = new_winner_24, 
  title = "Share of firms winning for the first time in the last 24 months to a buyer",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 40,
  interval_limits_y = 5,
  legend_upper = 19.7,
  percentage = TRUE,
  yearly = FALSE,
  adjust = 0.5
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/new_win_24_semester_health_2.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

