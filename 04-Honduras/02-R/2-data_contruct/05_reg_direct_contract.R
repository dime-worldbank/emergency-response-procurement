# ---------------------------------------------------------------------------- #
#                                                                              #
#               FY23 MDTF - Emergency Response Procurement - Honduras          #
#                                                                              # 
#                                  Regression                                  #
#                                                                              #
#        Author: Hao Lyu (RA - DIME3)            Last Update: 3/28 2023 
#                Maria Arnal                     Last Update: 7/5 2023 
#                Ruggero Diodino
#                                                                              #
# ---------------------------------------------------------------------------- #



# 0: Setting R ----------------------------------------------------------------

{
  { # 0.1: Prepare the workspace 
    
    # Clean the workspace
    #rm(list=ls()) 
    
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
        "kableExtra", 
        "data.table"
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



# Setting working directories

if (Sys.info()["user"] == "wb554125") {
  
  scriptFolder <- file.path("C:/Users/wb554125/GitHub/emergency-response-procurement/04-Honduras")
  
  projectFolder <- file.path("C:/Users/wb554125/WBG/DIME3 Files - FY23 MDTF project/Covid_datawork/03-Honduras/Data")
  
}


{
  
  scripts          <- file.path(scriptFolder,  "02-R/2-data_contruct"                             ) # folder for the scripts
  raw_oncae        <- file.path(projectFolder, "1_Raw/Data_ONCAE/DCC/Final"                       ) # folder for raw data from the standard portal 
  raw_data         <- file.path(projectFolder, "1_Raw"                                            ) # folder for all raw datasets
  raw_oncae_interm <- file.path(projectFolder, "1_Raw/Data_ONCAE/DCC/Intermediate/1 - Panel data" )
  intermediate     <- file.path(projectFolder, "2_Intermediate"                                   ) # all datasets used for variable constructions 
  cleaned          <- file.path(projectFolder, "3_Cleaned"                                        ) # cleaned datasets 
  output           <- file.path(projectFolder, "4_Output"                                         )
  
  
  
  ##________________________________CODE_______________________________________________________
  
  #function_code <- file.path(scriptFolder, "02-R/2-data_contruct/Functions")  
  function_code <- file.path("C:/Users/wb554125/GitHub/emergency-response-procurement/05-Chile/02-R/Scripts/Functions")
}


# Load the functions needed
invisible(sapply(list.files(function_code, full.names=TRUE), source, .GlobalEnv))



##___________________________________FUNCTIONS_______________________________________________

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
    labs(caption = "The fixed effects included are monthly and buyer.") +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
  
  return(plot)
  
}


model_ols <- function(data, dep_var, filename, title) {
  
  clfe <- list(feols(as.formula(paste0(dep_var, "~ Treated | DT_M")), 
                     data = data, vcov = "HC1"),
               feols(as.formula(paste0(dep_var, "~ Treated | DT_M + ID_BUYER")), 
                     data = data, vcov = "HC1"))
  
  rows <- tribble(~term,          ~OLS,  ~OLS,
                  'Month Fixed Effects', 'Yes', 'Yes',
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
    gt::gtsave(filename = file.path(projectFolder, paste0("4_Output/", filename, ".html")), inline_css = FALSE)
  
}



###Load the data

method_share  <- as.data.frame(fread(file.path(cleaned, "Procurement_method.csv")))

###Prepare the data for regression 

method_share$year_month <- as.Date(paste0(method_share$year, "-",
                                  method_share$month, "-01"))

method_share <- method_share %>%
  filter(year >= 2016)



method_share <- method_share %>%
  mutate(open = case_when(method == "open" ~ 1,
                          method == "close" ~ 0))


method_share_re <- as.data.table(method_share)

method_share <- method_share %>%
  group_by(year_month, semester, Group) %>%
  mutate(share_open = sum(open)/length(ID_CONTRACT))



#Generate the dummy for the treatment
method_share <- method_share %>%
  mutate(COVID_LABEL = case_when(Group == "Open - COVID" ~ 1,
                                 Group == "Open - Non-COVID" ~ 0))


#Create the quarters for each year
method_share <- 
  method_share%>%
  mutate(
    DT_Y = year(year_month),
    DT_M = month) %>%
  mutate(
    DT_S = if_else(DT_M <= 6,1,2) +
      if_else(DT_Y == 2016,0,
              if_else(DT_Y == 2017,2,
                      if_else(DT_Y == 2018,4,
                              if_else(DT_Y == 2019,6,
                                      if_else(DT_Y == 2020,8,
                                              if_else(DT_Y == 2021,10,
                                                      if_else(DT_Y == 2022,12,12))))))))



data_covid <- method_share %>% 
  filter(year > 2014)%>%
  mutate(treat = COVID_LABEL  == 1) 



method_share_di <- data_covid[year > 0,
                                    list(
                                    n_c                     = .N                              ,
                                    sh_open                 = mean(share_open                 , na.rm = TRUE)),
                                    by = list(DT_M, DT_S, ID_BUYER, treat)] %>%
                                    mutate(Treated = treat == TRUE & DT_S %in% seq(8, 14))



for(dep_var in c( 
  "sh_open"
  
)){
  
  
  
  title = case_when(
    dep_var == "sh_open" ~ "Share of open tenders "
    
  )
  
  title = paste0(title, " (Covid products)")
  
  
  clfe <- feols(
    data = method_share_di,  
    as.formula(paste0(dep_var, " ~ i(DT_S, treat, ref = 1) | DT_S + DT_M")), vcov = "HC1") 
  
  
  
  plot <- plot_bar_errors(clfe, title)  
  ggsave(
    filename = file.path(projectFolder, paste0("4_Output/", dep_var, "_treat_", ".png")),
    plot = plot                                                ,
    width    = 11                                            ,
    height   = 6.5                                            ,
    dpi      = 250                                              ,
    units    = "in"                                             ,
    device   = 'png'
  )
  
  model_ols(data = method_share_di, 
            dep_var = dep_var,
            title = title, 
            filename = paste0(dep_var, "_treat_"))
  
}


write_xlsx(method_share_re_sh_covid, "C:/Users/wb554125/OneDrive - WBG/Desktop/covid/method_share_re_sh_covid.xlsx", col_names = TRUE) 
