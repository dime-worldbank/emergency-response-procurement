
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
        "fixest",
        "modelsummary",
        "kableExtra"
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
      
      dropbox_dir  <- "/Users/ruggerodoino/Dropbox/COVID_19"
      github_dir   <- "/Users/ruggerodoino/Documents/GitHub/emergency-response-procurement/05-Chile/02-R/Scripts"
      
    }
    
  }
  
  { # Set working directories
    
    # DATA
    fin_data <- file.path(dropbox_dir, "CHILE/Reproducible-Package/Data/Final")
    int_data <- file.path(dropbox_dir, "CHILE/Reproducible-Package/Data/Intermediate")
    
    
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

plot_bar_errors <- function(clfe, title) {
  
  results <- confint(clfe)
  colnames(results) <- c("ci_low", "ci_up")
  results$coefficients <- clfe$coefficients
  results$year         <- seq(2016.5, 2022.5, by = 0.5)
  results <- results %>% add_row(
    ci_low = 0, 
    ci_up = 0,
    year = 2016,
    coefficients = 0
  )
  
  min = min(unique(results[,1]))
  min = data.table::fcase(
    min < 5 & min > -5, plyr::round_any(min, accuracy = 0.05, f = floor),
    min > 5 & min < -5, floor(min)
  )
  
  max = max(unique(results[,2]))
  max = data.table::fcase(
    max < 5 & max > -5, plyr::round_any(max, accuracy = 0.05, f = ceiling),
    max > 5 & max < -5, ceiling(min)
  )
  
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
    
    scale_x_continuous(breaks = seq(2016, 2022.5, by = 0.5),
                       label = c("S1 2016", "S2 2016",
                       "S1 2017", "S2 2017",
                       "S1 2018", "S2 2018",
                       "S1 2019", "S2 2019",
                       "S1 2020", "S2 2020",
                       "S1 2021", "S2 2021",
                       "S1 2022", "S2 2022"),
                       limits = c(2016, 2023)) +
    scale_y_continuous(limits = c(min, max)) +
    set_theme( 
      axis_line_x = element_line(),
      axis_line_y = element_line()
    ) +
    geom_hline(yintercept = 0) +
    geom_vline(xintercept = 2019.75, size = 1, color = "red", alpha = 1, linetype = "dotted") +
    xlab("") +
    ylab("") +
    ggtitle(
      title
    ) +
    labs(caption = "The fixed effects included are monthly, product, sector and buyer.") +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
  
  return(plot)
  
}

model_ols <- function(data, dep_var, filename, title) {
  
  clfe <- list(feols(as.formula(paste0(dep_var, "~ Treated | DT_TENDER_MONTH + ID_ITEM_UNSPSC")),
                     data = data, vcov = "HC1"),
               feols(as.formula(paste0(dep_var, "~ Treated | DT_TENDER_MONTH + ID_ITEM_UNSPSC + ID_RUT_BUYER")),
                     data = data, vcov = "HC1"))
  
  rows <- tribble(~term,          ~OLS,  ~OLS,
                  'Month Fixed Effects', 'Yes',   'Yes',
                  'Item Fixed Effects', 'Yes', 'Yes',
                  'Buyer Fixed Effects', 'No', 'Yes')
  attr(rows, 'position') <- c(4, 5, 6)
  f <- function(x) formatC(x, digits = 3, big.mark = ",", format = "f")
    modelsummary(clfe, 
             stars = c('*' = .1, '**' = .05, '***' = .01), 
             vcov = "HC1",
             coef_rename = c("Treatment"),
             title = title,
             gof_map = c("nobs", "r.squared"),
             add_rows = rows, fmt = f, output = "gt") %>% 
      gt::gtsave(filename = file.path(dropbox_dir, paste0("Outputs/", filename, ".html")), inline_css = FALSE)
  
}

# Task 1

data_covid <- data_offer_sub %>% 
  filter(DT_TENDER_YEAR > 2014) %>% 
  mutate(treat = COVID_LABEL == 1) %>% 
  mutate(ID_ITEM_UNSPSC = substr(ID_ITEM_UNSPSC, 0, 4))

n_bidders_y_covid <- data_covid[DT_TENDER_YEAR > 0, 
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
                                    by = list(DT_TENDER_MONTH, DT_S, ID_ITEM, ID_ITEM_UNSPSC, treat, ID_RUT_BUYER)]

n_bidders_y_covid <- n_bidders_y_covid %>% mutate(only_one_bidder = if_else(n_bidders == 1, 1, 0)) %>% mutate(Treated = treat == TRUE & DT_S %in% seq(8, 14))

data_medic <- data_offer_sub %>% 
  filter(DT_TENDER_YEAR > 2014) %>% 
  mutate(treat = CAT_MEDICAL == 1) %>% 
  mutate(ID_ITEM_UNSPSC = substr(ID_ITEM_UNSPSC, 0, 4))

n_bidders_y_medicine <- data_medic[DT_TENDER_YEAR > 0, 
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
                          by = list(DT_TENDER_MONTH, DT_S, ID_ITEM, ID_ITEM_UNSPSC, treat, ID_RUT_BUYER)]

n_bidders_y_medicine <- n_bidders_y_medicine %>% mutate(only_one_bidder = if_else(n_bidders == 1, 1, 0)) %>% mutate(Treated = treat == TRUE & DT_S %in% seq(8, 14))

for (dep_var in c(
  "only_one_bidder",
  "n_bidders",
  "sme_bidders",              
  "sme_winners",             
  "same_municipality_bidder", 
  "same_municipality_winner", 
  "DD_DECISION",              
  "DD_SUBMISSION",            
  "DD_TOT_PROCESS",           
  "DD_AWARD_CONTRACT"        
)) {
  
  for (type in c("covid", "medic")) {
    
    if (type == "covid") {
      
      data = n_bidders_y_covid
      
    } else {
      
      data = n_bidders_y_medicine
      
    }
    
    title = case_when(
        dep_var == "only_one_bidder" ~ "Share of only one bidder",
        dep_var == "n_bidders"   ~ "Number of bidders",
        dep_var == "sme_winners" ~ "Share of SMEs winning",             
        dep_var == "same_municipality_bidder" ~ "Share of firms bidding from the same municipality", 
        dep_var == "same_region_bidder" ~ "Share of firms bidding from the same region",       
        dep_var == "same_municipality_winner" ~ "Share of firms winning from the same municipality", 
        dep_var == "same_region_winner" ~ "Share of firms winning from the same region",       
        dep_var == "DD_DECISION" ~ "Average number of days between end of bidding and awarding",              
        dep_var == "DD_SUBMISSION" ~ "Average number of days between start and end of bidding",            
        dep_var == "DD_TOT_PROCESS" ~ "Average number of days between start of bidding and awarding contract",           
        dep_var == "DD_AWARD_CONTRACT" ~ "Average number of days between declaring winner and awarding contract"
    )
    
    type_title <- ifelse(type == "covid", " (Covid products)", " (Medical products)")
    
    title = paste0(title, type_title)
    
    clfe <- feols(
      data = n_bidders_y_covid,
      as.formula(paste0(dep_var, " ~ i(DT_S, treat, ref = 1)| DT_TENDER_MONTH + DT_S")), vcov = "HC1")
    plot <- plot_bar_errors(clfe, title)
    ggsave(
      filename = file.path(dropbox_dir, paste0("Outputs/", dep_var, "_treat_", type, ".png")),
      plot = plot                                                ,
      width    = 11                                            ,
      height   = 6.5                                            ,
      dpi      = 250                                              ,
      units    = "in"                                             ,
      device   = 'png'
    )
    model_ols(data = data, 
              dep_var = dep_var,
              title = title, 
              filename = paste0(dep_var, "_treat_", type))
    
  }
  
}

# Time to last bid (months)
last_bid_covid <- data_covid %>% 
  
  distinct(ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_S * 6 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) %>% mutate(Treated = treat == TRUE & DT_S %in% seq(8, 14))

# Time to last bid (months)
last_bid_med <- data_covid %>% 
  
  distinct(ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_S * 6 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) %>% mutate(Treated = treat == TRUE & DT_S %in% seq(8, 14))

for (months in c(6, 12, 24)) {
  
  for (type in c("covid", "medic")) {
    
    if (type == "covid") {
      
      data = last_bid_covid
      
    } else {
      
      data = last_bid_med
      
    }
    
    dep_var = paste0("new_bidder_", months)
    
    type_title <- ifelse(type == "covid", " (Covid products)", " (Medical products)")
    
    title = paste0("Share of firms bidding for the first time within the last ", months, " months", type_title)
    
    clfe <- feols(
      data = data,
      as.formula(paste0(dep_var, " ~ i(DT_S, treat, ref = 1)| DT_TENDER_MONTH + ID_ITEM_UNSPSC + DT_S")), vcov = "HC1")
    plot <- plot_bar_errors(clfe, title)
    ggsave(
      filename = file.path(dropbox_dir, paste0("Outputs/","first_bid_", months, "_treat_", type, ".png")),
      plot = plot                                                ,
      width    = 11                                            ,
      height   = 6.5                                            ,
      dpi      = 250                                              ,
      units    = "in"                                             ,
      device   = 'png'
    )
    model_ols(data = data, 
              dep_var = dep_var,
              title = title, 
              filename = paste0("first_bid_", months, "_treat_", type))
    
  }
  
}

# Time to last bid (months)
last_win_covid <- data_covid %>% 
  
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_S * 6 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>%  
  mutate(
    LAST_WIN_MONTHS = ifelse(is.na(LAST_WIN_MONTHS), 999999, LAST_WIN_MONTHS), 
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) %>% mutate(Treated = treat == TRUE & DT_S %in% seq(8, 14))

# Time to last bid (months)
last_win_med <- data_medic %>% 
  
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_S * 6 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  mutate(
    LAST_WIN_MONTHS = ifelse(is.na(LAST_WIN_MONTHS), 999999, LAST_WIN_MONTHS), 
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) %>% mutate(Treated = treat == TRUE & DT_S %in% seq(8, 14))

for (months in c(6, 12, 24)) {
  
  for (type in c("covid", "medic")) {
    
    if (type == "covid") {
      
      data = last_win_covid
      
    } else {
      
      data = last_win_med
      
    }
    
    dep_var = paste0("new_winner_", months)
    
    type_title <- ifelse(type == "covid", " (Covid products)", " (Medical products)")
    
    title = paste0("Share of firms winning for the first time within the last ", months, " months", type_title)
    
    clfe <- feols(
      data = data,
      as.formula(paste0(dep_var, " ~ i(DT_S, treat, ref = 1)| DT_TENDER_MONTH + ID_ITEM_UNSPSC + DT_S")), vcov = "HC1")
    plot <- plot_bar_errors(clfe, title)
    ggsave(
      filename = file.path(dropbox_dir, paste0("Outputs/","first_win_", months, "_treat_", type, ".png")),
      plot = plot                                                ,
      width    = 11                                            ,
      height   = 6.5                                            ,
      dpi      = 250                                              ,
      units    = "in"                                             ,
      device   = 'png'
    )
    model_ols(data = data, 
              dep_var = dep_var,
              title = title, 
              filename = paste0("first_win_", months, "_treat_", type))
    
  }
  
}

# Time to last bid (months)
last_win_covid <- data_covid %>% 
  
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_S * 6 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM, ID_RUT_BUYER
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  mutate(
    LAST_WIN_MONTHS = ifelse(is.na(LAST_WIN_MONTHS), 999999, LAST_WIN_MONTHS), 
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) %>% mutate(Treated = treat == TRUE & DT_S %in% seq(8, 14))

# Time to last bid (months)
last_win_med <- data_medic %>% 
  
  filter(CAT_OFFER_SELECT == 1) %>% 
  distinct(ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_S * 6 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM, ID_RUT_BUYER
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_WIN_MONTHS = MONTHS - before_date) %>% 
  mutate(
    LAST_WIN_MONTHS = ifelse(is.na(LAST_WIN_MONTHS), 999999, LAST_WIN_MONTHS), 
    new_winner_6  = ifelse(LAST_WIN_MONTHS >= 6, 1, 0),
    new_winner_12 = ifelse(LAST_WIN_MONTHS >= 12, 1, 0),
    new_winner_24 = ifelse(LAST_WIN_MONTHS >= 24, 1, 0)
  ) %>% mutate(Treated = treat == TRUE & DT_S %in% seq(8, 14))
# Time to last bid (months)
last_bid_covid <- data_covid %>% 
  
  distinct(ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_S * 6 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) %>% mutate(Treated = treat == TRUE & DT_S %in% seq(8, 14))

# Time to last bid (months)
last_bid_med <- data_covid %>% 
  
  distinct(ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  mutate(
    MONTHS = DT_S * 6 + DT_TENDER_MONTH
  ) %>% 
  distinct(MONTHS, ID_RUT_FIRM, ID_RUT_BUYER, ID_ITEM, ID_ITEM_UNSPSC, DT_OFFER_SEND, DT_S, DT_TENDER_MONTH, treat) %>% 
  arrange(
    MONTHS, ID_RUT_FIRM
  ) %>% 
  na.omit() %>% 
  group_by(ID_RUT_FIRM, ID_RUT_BUYER) %>% 
  mutate(before_date = lag(MONTHS, order_by = MONTHS)) %>%  
  mutate(LAST_BID_MONTHS = MONTHS - before_date) %>% 
  mutate(
    LAST_BID_MONTHS = ifelse(is.na(LAST_BID_MONTHS), 999999, LAST_BID_MONTHS), 
    new_bidder_6  = ifelse(LAST_BID_MONTHS >= 6, 1, 0),
    new_bidder_12 = ifelse(LAST_BID_MONTHS >= 12, 1, 0),
    new_bidder_24 = ifelse(LAST_BID_MONTHS >= 24, 1, 0)
  ) %>% mutate(Treated = treat == TRUE & DT_S %in% seq(8, 14))

for (months in c(6, 12, 24)) {
  
  for (type in c("covid", "medic")) {
    
    if (type == "covid") {
      
      data = last_win_covid
      
    } else {
      
      data = last_win_med
      
    }
    
    dep_var = paste0("new_winner_", months)
    
    type_title <- ifelse(type == "covid", " (Covid products)", " (Medical products)")
    
    title = paste0("Share of firms winning for the first time within the last ", months, " months", type_title)
    
    clfe <- feols(
      data = data,
      as.formula(paste0(dep_var, " ~ i(DT_S, treat, ref = 1)| DT_TENDER_MONTH + ID_ITEM_UNSPSC + DT_S")), vcov = "HC1")
    plot <- plot_bar_errors(clfe, title)
    ggsave(
      filename = file.path(dropbox_dir, paste0("Outputs/","first_establishment_win_", months, "_treat_", type, ".png")),
      plot = plot                                                ,
      width    = 11                                            ,
      height   = 6.5                                            ,
      dpi      = 250                                              ,
      units    = "in"                                             ,
      device   = 'png'
    )
    model_ols(data = data, 
              dep_var = dep_var,
              title = title, 
              filename = paste0("first_establishment_win_", months, "_treat_", type))
    
  }
  
}

for (months in c(6, 12, 24)) {
  
  for (type in c("covid", "medic")) {
    
    if (type == "covid") {
      
      data = last_bid_covid
      
    } else {
      
      data = last_bid_med
      
    }
    
    dep_var = paste0("new_bidder_", months)
    
    type_title <- ifelse(type == "covid", " (Covid products)", " (Medical products)")
    
    title = paste0("Share of firms bidding for the first time within the last ", months, " months", type_title)
    
    clfe <- feols(
      data = data,
      as.formula(paste0(dep_var, " ~ i(DT_S, treat, ref = 1)| DT_TENDER_MONTH + ID_ITEM_UNSPSC + DT_S")), vcov = "HC1")
    plot <- plot_bar_errors(clfe, title)
    ggsave(
      filename = file.path(dropbox_dir, paste0("Outputs/","first_establishment_bid_", months, "_treat_", type, ".png")),
      plot = plot                                                ,
      width    = 11                                            ,
      height   = 6.5                                            ,
      dpi      = 250                                              ,
      units    = "in"                                             ,
      device   = 'png'
    )
    model_ols(data = data, 
              dep_var = dep_var,
              title = title, 
              filename = paste0("first_establishment_bid_", months, "_treat_", type))
    
  }
  
  
}

data_pos_raw <- data_pos_raw %>% mutate(MED_DUMMY = ifelse(substr(ID_ITEM_UNSPSC, 1, 2) == 42, 1, 0)) %>% mutate(CAT_DIRECT = ifelse(CAT_DIRECT == "No", 0, 1))
data_po_collapse <- data_pos_raw[DT_YEAR > 2015 & !is.na(MED_DUMMY), 
                                 list(
                                   CAT_DIRECT     = mean(CAT_DIRECT, na.rm = TRUE)
                                 ), 
                                 by = list(DT_MONTH, DT_S, ID_PURCHASE_ORDER, ID_ITEM_UNSPSC, MED_DUMMY, ID_RUT_ISSUER)]

data_po_collapse <- data_po_collapse %>% filter(CAT_DIRECT == 0 | CAT_DIRECT == 1)%>% mutate(Treated = MED_DUMMY == 1 & DT_S %in% seq(1, 7))

clfe <- feols(
  data = data_po_collapse,
  CAT_DIRECT ~ i(DT_S, MED_DUMMY, ref = 1) | DT_MONTH + ID_ITEM_UNSPSC+ DT_S, vcov = "HC1")
  
plot <- plot_bar_errors(clfe, "Share of direct contracts (Medical Products)")
ggsave(
  filename = file.path(dropbox_dir, "Outputs/direct_treat_medic.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 6.5                                            ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)
model_ols(data = data_po_collapse %>% rename(DT_TENDER_MONTH = DT_MONTH, ID_RUT_BUYER = ID_RUT_ISSUER), 
          dep_var = "CAT_DIRECT",
          title = "Share of direct purchases (Medical products)", 
          filename = paste0("direct_treat_medic"))

data_po_collapse <- data_pos_raw[DT_YEAR > 2015 & !is.na(COVID_LABEL), 
                                 list(
                                   CAT_DIRECT     = mean(CAT_DIRECT, na.rm = TRUE)
                                 ), 
                                 by = list(DT_MONTH, DT_S, ID_PURCHASE_ORDER, ID_ITEM_UNSPSC, COVID_LABEL, ID_RUT_ISSUER)]

data_po_collapse <- data_po_collapse %>% filter(CAT_DIRECT == 0 | CAT_DIRECT == 1) %>% mutate(Treated = COVID_LABEL == 1 & DT_S %in% seq(1, 7))

clfe <- feols(
  data = data_po_collapse,
  CAT_DIRECT ~ i(DT_S, COVID_LABEL, ref = 1) | DT_MONTH + ID_ITEM_UNSPSC+ DT_S, vcov = "HC1")

plot <- plot_bar_errors(clfe, "Share of direct contracts (Covid Products)")
ggsave(
  filename = file.path(dropbox_dir, "Outputs/direct_treat_covid.png"),
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 6.5                                            ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)
model_ols(data = data_po_collapse %>% rename(DT_TENDER_MONTH = DT_MONTH, ID_RUT_BUYER = ID_RUT_ISSUER), 
          dep_var = "CAT_DIRECT",
          title = "Share of direct purchases (Covid products)", 
          filename = paste0("direct_treat_covid"))
