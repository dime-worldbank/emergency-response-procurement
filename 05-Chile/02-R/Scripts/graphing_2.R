
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
        "extrafont",
        "fixest"
      )
    
    # If the package is not installed, then install it 
    if (!require("pacman")) install.packages("pacman")
    
    # Load the packages 
    pacman::p_load(packages, character.only = TRUE, install = TRUE)
    
  }
}


set_theme <- function(
    
  theme = theme_classic(),
  size = 16, 
  title_size = size + 0.4*size,
  title_hjust = 0.5,
  y_title_size = size,
  x_title_size = size,
  y_title_margin = NULL,
  x_title_margin = NULL,
  y_text_size = size,
  x_text_size = size,
  y_text_color = "black",
  x_text_color = "black",
  y_title_color = "black", 
  x_title_color = "black",
  legend_text_size = size,
  legend_position = "none",
  legend_key_fill = NA,
  legend_key_color = NA,
  plot_title_position = NULL,
  plot_margin = margin(25, 25, 10, 25),
  axis_title_y_blank = FALSE, # to fully left-align
  aspect_ratio = NULL,
  plot_caption_position = "plot",
  axis_line_x  = element_blank(),
  axis_line_y = element_blank()
  
) {
  
  # Dependencies
  require(ggplot2)
  require(stringr)
  require(ggtext)
  
  # Size
  size_ <- str_c("size = ", size) # this argument always included
  
  if (is.na(y_title_size)) {
    y_title <- "element_blank()"
  } else {
    
    # y-title margin
    if (!is.null(y_title_margin)) y_title_margin_ <- str_c("margin = margin(", y_title_margin, ")")
    else y_title_margin_ <- ""
    
    
    # y-title color
    if (!is.null(y_title_color)) y_title_color_ <- str_c("color = '", y_title_color, "'")
    else y_title_color_ <- ""
    
    # create y_title
    y_title <- str_c("element_text(", size_, ",", y_title_margin_, ",", y_title_color_, ")")
    
  }
  if (is.na(x_title_size)) {
    x_title <- "element_blank()"
  }
  else {
    # x-title margin
    if (!is.null(x_title_margin)) x_title_margin_ <- str_c("margin = margin(", x_title_margin, ")")
    else x_title_margin_ <- ""
    
    # x-title color
    if (!is.null(x_title_color)) x_title_color_ <- str_c("color = '", x_title_color, "'")
    else x_title_color_ <- ""
    
    # create x_title
    x_title <- str_c("element_text(", size_, ",", x_title_margin_, ",", x_title_color_, ")")
  }
  
  if (axis_title_y_blank) {
    y_title <- "element_blank()" # overwrite what it was written as above
  }
  
  # Legend key
  if (is.na(legend_key_fill) & is.na(legend_key_color)) {
    legend_key <- "element_blank()"
  } else {
    if (is.na(legend_key_fill) & !(is.na(legend_key_color))) {
      legend_key <- str_c("element_rect(", 
                          "fill = NA", ",",
                          "color = '", legend_key_color, "'", ", ",
                          ")"
      )      
    } else if (!(is.na(legend_key_fill)) & is.na(legend_key_color)) {
      legend_key <- str_c("element_rect(", 
                          "fill = '", legend_key_fill, "'", ", ",
                          "color = NA",
                          ")"
      )      
    } else { # neither missing
      legend_key <- str_c("element_rect(", 
                          "fill = '", legend_key_fill, "'", ", ",
                          "color = '", legend_key_color, "'",
                          ")"
      )
    }
  }
  
  theme + theme(
    plot.title =  element_text(hjust = -0.05, size = y_text_size, color = y_text_color, family="LM Roman 10"),
    axis.title.y = eval(parse(text = y_title)),
    axis.title.x = eval(parse(text = x_title)),
    axis.text.y = element_text(size = y_text_size, color = y_text_color, family="LM Roman 10"),
    axis.text.x = element_text(size = y_text_size, color = y_text_color, family="LM Roman 10"),
    axis.line.x = axis_line_x , # manual axes
    axis.line.y = axis_line_y,
    legend.key = eval(parse(text = legend_key)),
    legend.text = element_text(size = legend_text_size, family="LM Roman 10"),
    legend.title = element_text(size = legend_text_size, family="LM Roman 10"),
    aspect.ratio = aspect_ratio,
    plot.margin = plot_margin,
    legend.position = legend_position,
    plot.caption.position = plot_caption_position,
    plot.caption = element_text(size = 12, color = "gray50", family="LM Roman 10"),
    text         = element_text(family="LM Roman 10", color = "black"),
    axis.ticks.length = unit(.25, "cm")
  ) 
  
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

plot_bar_errors <- function(clfe, title, min, max) {
  
  results <- confint(clfe)
  colnames(results) <- c("ci_low", "ci_up")
  results$coefficients <- clfe$coefficients
  results$year         <- c(2017, 2018, 2019, 2020, 2021, 2022)
  
  plot <- ggplot()  +
    
    geom_errorbar(
      data = results,
      aes(
        x    = year, 
        y    = coefficients,
        ymin = ci_low,
        ymax = ci_up,
        width = 0.05,
        group = 1
      ),
      colour = "red"
    ) + 
    
    geom_point(
      data = results,
      aes(
        x = year       ,
        y = coefficients),
      size = 2) +
    
    scale_x_continuous(breaks = seq(2016, 2022)) +
    scale_y_continuous(limits = c(min, max)) +
    set_theme( 
      axis_line_x = element_line(),
      axis_line_y = element_line(),
    ) +
    geom_hline(yintercept = 0) +
    geom_vline(xintercept = 2020, size = 1, color = "red", alpha = 1, linetype = "dotted") +
    xlab("") +
    ylab("") +
    ggtitle(
      title
    ) +
    labs(caption = "The fixed effects included are monthly, product, sector and buyer.")
  
  return(plot)
  
}

# Task 1

data_covid <- data_offer_sub %>% 
  filter(DT_TENDER_YEAR > 2014) %>% 
  mutate(treat = COVID_LABEL == 1) %>% 
  mutate(ID_ITEM_UNSPSC = substr(ID_ITEM_UNSPSC, 0, 4))

n_bidders_y_covid <- data_covid[DT_TENDER_YEAR > 0, 
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
                                    by = list(DT_TENDER_MONTH, DT_S, ID_ITEM, ID_ITEM_UNSPSC, treat, ID_RUT_BUYER)]

n_bidders_y_covid <- n_bidders_y_covid %>% mutate(only_one_bidder = if_else(n_bidders == 1, 1, 0))

data_medic <- data_offer_sub %>% 
  filter(DT_TENDER_YEAR > 2014) %>% 
  mutate(treat = CAT_MEDICAL == 1) %>% 
  mutate(ID_ITEM_UNSPSC = substr(ID_ITEM_UNSPSC, 0, 4))

n_bidders_y_medicine <- data_medic[DT_TENDER_YEAR > 0, 
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
                          by = list(DT_TENDER_MONTH, DT_S, ID_ITEM, ID_ITEM_UNSPSC, treat, ID_RUT_BUYER)]

n_bidders_y_medicine <- n_bidders_y_medicine %>% mutate(only_one_bidder = if_else(n_bidders == 1, 1, 0))

# "Number of bidders (Covid Products)" s
clfe <- feols(
  data = n_bidders_y_covid,
  n_bidders ~ i(DT_S, treat, ref = 1)| DT_TENDER_MONTH + ID_ITEM_UNSPSC + DT_S)
plot <- plot_bar_errors(clfe, "Number of bidders (Covid Products)", min = - 1, max = 1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_bidders_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# "Number of bidders (Medical Products)" 
clfe <- feols(
  data = n_bidders_y_medicine,
  n_bidders ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Number of bidders (Medical Products)", min = - 1.5, max = 1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/n_bidders_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Only one bidder (Covid Products)" s
clfe <- feols(
  data = n_bidders_y_covid,
  only_one_bidder ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of Tenders with only one bidder (Covid Products)", min = - 0.1, max = 0.2)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/one_bidder_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Only one bidder (Medical Products)" 
clfe <- feols(
  data = n_bidders_y_medicine,
  only_one_bidder ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Number of bidders (Medical Products)", min = - 0.05, max = 0.05)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/one_bidder_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes bidding (Covid Products)
clfe <- feols(
  data = n_bidders_y_covid,
  sme_bidders ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of SMEs bidding (Covid Products)", min = - 0.1, max = 0.05)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_bid_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes bidding (Medical Products)
clfe <- feols(
  data = n_bidders_y_medicine,
  sme_bidders ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of SMEs bidding (Medical Products)", min = - 0.05, max = 0.05)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_bid_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = n_bidders_y_covid,
  sme_winners ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of SMEs bidding (Covid Products)", min = - 0.05, max = 0.05)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_win_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = n_bidders_y_medicine,
  sme_winners ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of SMEs bidding (Medical Products)", min = - 0.1, max = 0.05)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/smes_win_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = n_bidders_y_covid,
  same_municipality_bidder ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of bidders from the same municipalitys (Covid Products)", min = - 0.025, max = 0.025)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/same_mun_bid_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = n_bidders_y_medicine,
  same_municipality_bidder ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of bidders from the same municipality (Medical Products)", min = - 0.01, max = 0.02)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/same_mun_bid_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = n_bidders_y_covid,
  same_municipality_winner ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of winners from the same municipalitys (Covid Products)", min = - 0.025, max = 0.025)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/same_mun_win_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = n_bidders_y_medicine,
  same_municipality_winner ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of winners from the same municipality (Medical Products)", min = - 0.02, max = 0.02)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/same_mun_win_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = n_bidders_y_covid,
  same_region_bidder ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of bidders from the same region (Covid Products)", min = - 0.03, max = 0.03)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/same_reg_bid_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = n_bidders_y_medicine,
  same_region_bidder ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of bidders from the same region (Medical Products)", min = - 0.02, max = 0.02)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/same_reg_bid_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = n_bidders_y_covid,
  same_region_winner ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of winners from the same region (Covid Products)", min = - 0.04, max = 0.04)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/same_reg_win_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = n_bidders_y_medicine,
  same_region_winner ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of winners from the same region (Medical Products)", min = - 0.05, max = 0.02)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/same_reg_win_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = n_bidders_y_covid,
  DD_DECISION ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Average number of days between end of bidding and awarding (Covid Products)", min = - 30, max = 10)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/DD_decision_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = n_bidders_y_medicine,
  DD_DECISION ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Average number of days between end of bidding and awarding (Medical Products)", min = - 60, max = 10)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/DD_decision_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = n_bidders_y_covid,
  DD_SUBMISSION ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Average number of days between start and end of bidding (Covid Products)", min = - 2, max = 1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/DD_submission_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = n_bidders_y_medicine,
  DD_SUBMISSION ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Average number of days between start and end of bidding (Medical Products)", min = - 2.5, max = 2.5)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/DD_submission_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = n_bidders_y_covid,
  DD_SUBMISSION ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Average number of days between start and end of bidding (Covid Products)", min = - 2, max = 1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/DD_submission_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = n_bidders_y_medicine,
  DD_SUBMISSION ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Average number of days between start and end of bidding (Medical Products)", min = - 2.5, max = 1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/DD_submission_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = n_bidders_y_covid,
  DD_AWARD_CONTRACT ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Average number of days between declaring winner and awarding contract(Covid Products)", min = - 30, max = 10)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/DD_award_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = n_bidders_y_medicine,
  DD_AWARD_CONTRACT ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Average number of days between declaring winner and awarding contract (Medical Products)", min = - 40, max = 10)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/DD_award_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = n_bidders_y_covid,
  DD_TOT_PROCESS ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Average number of days between start of bidding and awarding contract (Covid Products)", min = - 35, max = 10)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/DD_award_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = n_bidders_y_medicine,
  DD_TOT_PROCESS ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Average number of days between start of bidding and awarding contract (Medical Products)", min = - 50, max = 10)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/DD_award_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Time to last bid (months)
last_bid_covid <- data_covid %>% 
  
  distinct(ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_TENDER_YEAR * 12 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  filter(DT_TENDER_YEAR > 0) %>% 
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) 

# Time to last bid (months)
last_bid_med <- data_covid %>% 
  
  distinct(ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_TENDER_YEAR * 12 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  filter(DT_TENDER_YEAR > 0) %>% 
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) 

# Smes winning (Covid Products)
clfe <- feols(
  data = last_bid_covid,
  new_bidder_6 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms bidding for the first time within the last 6 months (Covid Products)", min = - 0.01, max = 0.01)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_bid_6_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = last_bid_med,
  new_bidder_6 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms bidding for the first time within the last 6 months (Medical Products)", min = - 0.01, max = 0.01)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_bid_6_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = last_bid_covid,
  new_bidder_12 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms bidding for the first time within the last 12 months (Covid Products)", min = - 0.01, max = 0.01)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_bid_12_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = last_bid_med,
  new_bidder_12 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms bidding for the first time within the last 12 months (Medical Products)", min = - 0.01, max = 0.01)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_bid_12_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = last_bid_covid,
  new_bidder_24 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)

plot <- plot_bar_errors(clfe, "Share of firms bidding for the first time within the last 24 months (Covid Products)", min = - 0.01, max = 0.01)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_bid_24_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = last_bid_med,
  new_bidder_24 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms bidding for the first time within the last 24 months (Medical Products)", min = - 0.01, max = 0.01)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_bid_24_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Time to last bid (months)
last_win_covid <- data_covid %>% 
  
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_TENDER_YEAR * 12 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  filter(DT_TENDER_YEAR > 0) %>% 
  mutate(
    LAST_WIN_MONTHS = ifelse(is.na(LAST_WIN_MONTHS), 999999, LAST_WIN_MONTHS), 
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) 

# Time to last bid (months)
last_win_med <- data_medic %>% 
  
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_TENDER_YEAR * 12 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  filter(DT_TENDER_YEAR > 0) %>% 
  mutate(
    LAST_WIN_MONTHS = ifelse(is.na(LAST_WIN_MONTHS), 999999, LAST_WIN_MONTHS), 
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) 

# Smes winning (Covid Products)
clfe <- feols(
  data = last_win_covid,
  new_winner_6 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms winning for the first time within the last 6 months (Covid Products)", min = - 0.1, max = 0.1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_win_6_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = last_win_med,
  new_winner_6 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms winning for the first time within the last 6 months (Medical Products)", min = - 0.01, max = 0.01)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_win_6_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = last_win_covid,
  new_winner_12 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms winning for the first time within the last 12 months (Covid Products)", min = - 0.1, max = 0.1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_win_12_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = last_win_med,
  new_winner_12 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms winning for the first time within the last 12 months (Medical Products)", min = - 0.01, max = 0.01)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_win_12_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = last_win_covid,
  new_winner_24 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms winning for the first time within the last 24 months (Covid Products)", min = - 0.15, max = 0.15)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_win_24_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = last_win_med,
  new_winner_24 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms winning for the first time within the last 24 months (Medical Products)", min = - 0.01, max = 0.01)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_win_24_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Time to last bid (months)
# Time to last bid (months)
last_win_covid <- data_covid %>% 
  
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_TENDER_YEAR * 12 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT, ID_RUT_BUYER
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  filter(DT_TENDER_YEAR > 0) %>% 
  mutate(
    LAST_WIN_MONTHS = ifelse(is.na(LAST_WIN_MONTHS), 999999, LAST_WIN_MONTHS), 
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) 

# Time to last bid (months)
last_win_med <- data_medic %>% 
  
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_TENDER_YEAR * 12 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT, ID_RUT_BUYER
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  filter(DT_TENDER_YEAR > 0) %>% 
  mutate(
    LAST_WIN_MONTHS = ifelse(is.na(LAST_WIN_MONTHS), 999999, LAST_WIN_MONTHS), 
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) 
# Time to last bid (months)
last_bid_covid <- data_covid %>% 
  
  distinct(ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_TENDER_YEAR * 12 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  filter(DT_TENDER_YEAR > 0) %>% 
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) 

# Time to last bid (months)
last_bid_med <- data_covid %>% 
  
  distinct(ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_TENDER_YEAR * 12 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_FIRM_RUT, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_TENDER_YEAR, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_FIRM_RUT
  ) %>% 
  na.omit() %>% 
  group_by(ID_FIRM_RUT, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  filter(DT_TENDER_YEAR > 0) %>% 
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) 

# Smes winning (Covid Products)
clfe <- feols(
  data = last_win_covid,
  new_winner_6 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms winning for the first time to the establishment within the last 6 months(Covid Products)", min = - 0.1, max = 0.1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_establishment_win_6_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = last_win_med,
  new_winner_6 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms winning for the first time to the establishment within the last 6 months (Medical Products)", min = - 0.2, max = 0.2)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_establishment_win_6_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = last_win_covid,
  new_winner_12 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms winning for the first time to the establishment within the last 12 months (Covid Products)", min = - 0.1, max = 0.1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_establishment_win_12_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = last_win_med,
  new_winner_12 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms winning for the first time to the establishment within the last 12 months (Medical Products)", min = - 0.1, max = 0.1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_establishment_win_12_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = last_win_covid,
  new_winner_24 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms winning for the first time to the establishment within the last 24 months (Covid Products)", min = - 0.1, max = 0.1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_establishment_win_24_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = last_win_med,
  new_winner_24 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms winning for the first time to the establishment within the last 24 months (Medical Products)", min = - 0.1, max = 0.1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_establishment_win_24_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = last_bid_covid,
  new_bidder_6 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms bidding for the first time to the establishment within the last 6 months (Covid Products)", min = - 0.1, max = 0.1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_establishment_bid_6_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = last_bid_med,
  new_bidder_6 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms bidding for the first time to the establishment within the last 6 months (Medical Products)", min = - 0.1, max = 0.1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_establishment_bid_6_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = last_bid_covid,
  new_bidder_12 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms bidding for the first time to the establishment within the last 12 months (Covid Products)", min = - 0.1, max = 0.1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_establishment_bid_12_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = last_bid_med,
  new_bidder_12 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms bidding for the first time to the establishment within the last 12 months (Medical Products)", min = - 0.1, max = 0.1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_establishment_bid_12_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Covid Products)
clfe <- feols(
  data = last_bid_covid,
  new_bidder_24 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC  + ID_RUT_BUYER + DT_TENDER_YEAR)

plot <- plot_bar_errors(clfe, "Share of firms bidding for the first time to the establishment within the last 24 months (Covid Products)", min = - 0.1, max = 0.1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_establishment_bid_24_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

# Smes winning (Medical Products)
clfe <- feols(
  data = last_bid_med,
  new_bidder_24 ~ i(DT_TENDER_YEAR, treat, ref = 1) | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER + DT_TENDER_YEAR)
plot <- plot_bar_errors(clfe, "Share of firms bidding for the first time to the establishment within the last 24 months (Medical Products)", min = - 0.1, max = 0.1)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/first_establishment_bid_24_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

data_pos_raw <- data_pos_raw %>% mutate(CAT_DIRECT = ifelse(CAT_DIRECT == "Si", 1, 0))

data_po_collapse <- data_pos_raw[DT_YEAR > 2015 & !is.na(COVID_LABEL), 
                                 list(CAT_DIRECT     = mean(CAT_DIRECT, na.rm = TRUE)), 
                                 by = list(DT_MONTH, DT_YEAR, ID_PURCHASE_ORDER, ID_ITEM_UNSPSC, COVID_LABEL, ID_RUT_ISSUER)]

data_po_collapse <- data_po_collapse %>% filter(CAT_DIRECT == 0 | CAT_DIRECT == 1) %>% 
  filter(DT_YEAR > 2014) %>% 
  mutate(treat = COVID_LABEL == 1,
         DT_YEAR = ifelse(DT_YEAR == "2016", 1,
                                 ifelse(DT_YEAR == "2017", 2,
                                        ifelse(DT_YEAR == "2018", 3,
                                               ifelse(DT_YEAR == "2019", 4,
                                                      ifelse(DT_YEAR == "2020", 5,
                                                             ifelse(DT_YEAR == "2021", 6, 
                                                                    ifelse(DT_YEAR == "2022", 7, 0)))))))) 

clfe <- feols(
  data = data_po_collapse,
  CAT_DIRECT ~ i(DT_YEAR, treat, ref = 1) | DT_MONTH + ID_ITEM_UNSPSC + ID_RUT_ISSUER + DT_YEAR)
plot <- plot_bar_errors(clfe, "Share of direct contracts (Covid Products)", min = - 0.2, max = 0.2)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/direct_treat_covid.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

data_pos_raw <- data_pos_raw %>% mutate(MED_DUMMY = ifelse(substr(ID_ITEM_UNSPSC, 1, 2) == 42, 1, 0))
data_po_collapse <- data_pos_raw[DT_YEAR > 2015 & !is.na(MED_DUMMY), 
                                 list(
                                   CAT_DIRECT     = mean(CAT_DIRECT, na.rm = TRUE)
                                 ), 
                                 by = list(DT_MONTH, DT_YEAR, ID_PURCHASE_ORDER, ID_ITEM_UNSPSC, MED_DUMMY, ID_RUT_ISSUER)]

data_po_collapse <- data_po_collapse %>% filter(CAT_DIRECT == 0 | CAT_DIRECT == 1) %>% 
  filter(DT_YEAR > 2014) %>% 
  mutate(treat = MED_DUMMY == 1,
         DT_YEAR = ifelse(DT_YEAR == "2016", 1,
                          ifelse(DT_YEAR == "2017", 2,
                                 ifelse(DT_YEAR == "2018", 3,
                                        ifelse(DT_YEAR == "2019", 4,
                                               ifelse(DT_YEAR == "2020", 5,
                                                      ifelse(DT_YEAR == "2021", 6, 
                                                             ifelse(DT_YEAR == "2022", 7, 0))))))))


clfe <- feols(
  data = data_po_collapse,
  CAT_DIRECT ~ i(DT_YEAR, treat, ref = 1) | DT_MONTH + ID_ITEM_UNSPSC + ID_RUT_ISSUER + DT_YEAR)
  
plot <- plot_bar_errors(clfe, "Share of direct contracts (Medical Products)", min = - 0.3, max = 0.3)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/direct_treat_med.jpeg"),
  plot = plot                                                ,
  width    = 12                                            ,
  height   = 6.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

data <- fread("/Users/ruggerodoino/Dropbox/ChilePaymentProcurement/Reproducible-Package/Data/Final/Merged_data.csv")

tc <- data_covid %>% distinct(ID_ITEM_UNSPSC, treat)

data_covid_final <- data %>% filter(!is.na(N_PAYMENTS)) %>% 
  left_join(tc, by = "ID_ITEM_UNSPSC") %>%
  
  # create month and year date
  mutate(
    DT_Y = year(DT_TENDER_START),
    DT_M = month(DT_TENDER_START)) %>% 
  
  filter(DT_Y != 2015) %>% 
  
  # compute quarter for each year
  mutate(
    DT_S = if_else(DT_M <= 6, 1, 2) + 
      if_else(DT_Y == 2016, 0,
              if_else(DT_Y == 2017, 2,
                      if_else(DT_Y == 2018, 4, 
                              if_else(DT_Y == 2019, 6, 
                                      if_else(DT_Y == 2020, 8,
                                              if_else(DT_Y == 2021, 10, 12))))))) %>% 
  filter(!is.na(treat) & !is.na(DT_S))

data_covid_final <- data_covid_final[, 
             list(
               AMT_PAY_ACK_DD_AVG_W = mean(AMT_PAY_ACK_DD_AVG_W, na.rm = TRUE)), 
             by = list(DT_S, treat)]

plot <- graph_trend(
  data = data_covid_final %>% filter(DT_S < 13), 
  treatment = treat,
  variable = AMT_PAY_ACK_DD_AVG_W, 
  title = "Payment Executions",
  subtitle = "Average number of days for payment",
  caption = "Source: Chile Compra and SIGFE",
  limit_lower = 10,
  limit_upper = 100,
  interval_limits_y = 10,
  legend_upper = 99.7,
  percentage = FALSE,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/payment_delay_semester_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

data_covid_final <- data %>% filter(!is.na(N_PAYMENTS)) %>% 
  left_join(tc, by = "ID_ITEM_UNSPSC") %>%
  
  # create month and year date
  mutate(
    DT_Y = year(DT_TENDER_START),
    DT_M = month(DT_TENDER_START)) %>% 
  
  filter(DT_Y != 2015) %>% 
  
  # compute quarter for each year
  mutate(
    DT_S = if_else(DT_M <= 6, 1, 2) + 
      if_else(DT_Y == 2016, 0,
              if_else(DT_Y == 2017, 2,
                      if_else(DT_Y == 2018, 4, 
                              if_else(DT_Y == 2019, 6, 
                                      if_else(DT_Y == 2020, 8,
                                              if_else(DT_Y == 2021, 10, 12))))))) %>% 
  filter(!is.na(treat) & !is.na(DT_Y))

data_covid_final <- data_covid_final[, 
                                     list(
                                       AMT_PAY_ACK_DD_AVG_W = mean(AMT_PAY_ACK_DD_AVG_W, na.rm = TRUE)), 
                                     by = list(DT_Y, treat)]

plot <- graph_trend(
  data = data_covid_final, 
  treatment = treat,
  variable = AMT_PAY_ACK_DD_AVG_W, 
  title = "Payment Executions",
  subtitle = "Average number of days for payment",
  caption = "Source: Chile Compra and SIGFE",
  limit_lower = 10,
  limit_upper = 100,
  interval_limits_y = 10,
  legend_upper = 99.7,
  percentage = FALSE,
  yearly = TRUE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = file.path(dropbox_dir, "Outputs/payment_delay_yearly_covid.jpeg"),
  plot = plot                                                 ,
  width    = 9                                            ,
  height   = 5.75                                             ,
  dpi      = 600                                              ,
  units    = "in"                                             ,
  device   = 'jpeg'
)

