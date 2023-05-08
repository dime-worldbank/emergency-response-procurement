# ---------------------------------------------------------------------------- #
#                                                                              #
#               FY23 MDTF - Emergency Response Procurement - Honduras          #
#                                                                              # 
#                                  Regression                                  #
#                                                                              #
#        Author: Hao Lyu (RA - DIME3)            Last Update: 3/28 2023        #
#                                                                              #
# ---------------------------------------------------------------------------- #


# Save datasets on 04 Output.Rmd 


# LOAD DATA -------------------------------------------------------------------

tender  <- as.data.frame(fread(file.path(cleaned, "Number_of_tenders.csv")))

contract_value  <- as.data.frame(fread(file.path(cleaned, "Contracts_value.csv")))

method_share  <- as.data.frame(fread(file.path(cleaned, "Procurement_method.csv")))

firm_item  <- as.data.frame(fread(file.path(cleaned, "Firm_item.csv")))

firm_item_did  <- as.data.frame(fread(file.path(cleaned, "Firm_item_did.csv")))

market_concentration  <- as.data.frame(fread(file.path(cleaned, "Market_concentration.csv")))

tender_contract  <- as.data.frame(fread(file.path(cleaned, "Duration.csv")))

new_winner  <- as.data.frame(fread(file.path(cleaned, "New_winner.csv")))



# set theme -----------------------

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
  
)



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




# overall trend ------------------------------------------------------ 
# tender <- tender %>% 
#   filter(year > 2016) %>% 
#   mutate(treat = Group == "COVID")
# 
# n_bidders_y_covid <- tender[year > 0, 
#                             list(
#                               n_bidders                =    .N                                      ,
#                               sme_bidders              = mean(sme                     , na.rm = TRUE),
#                               sme_winners              = mean(sme_winner              , na.rm = TRUE),
#                               same_municipality_bidder = mean(same_municipality_bidder, na.rm = TRUE),
#                               same_region_bidder       = mean(same_region_bidder      , na.rm = TRUE),
#                               same_municipality_winner = mean(same_municipality_winner, na.rm = TRUE),
#                               same_region_winner       = mean(same_region_winner      , na.rm = TRUE),
#                               DD_DECISION              = mean(DD_DECISION             , na.rm = TRUE),
#                               DD_SUBMISSION            = mean(DD_SUBMISSION           , na.rm = TRUE),
#                               DD_TOT_PROCESS           = mean(DD_TOT_PROCESS          , na.rm = TRUE),
#                               DD_AWARD_CONTRACT        = mean(DD_AWARD_CONTRACT       , na.rm = TRUE)), 
#                             by = list(DT_TENDER_MONTH, DT_S, ID_ITEM, ID_ITEM_UNSPSC, treat, ID_RUT_BUYER)]
# 
# n_bidders_y_covid <- n_bidders_y_covid %>% mutate(only_one_bidder = if_else(n_bidders == 1, 1, 0))


# 1 Overall trend ----------------------------

# number of tender per month 
tender <- tender%>%
  filter(DT_TENDER_PUB >= as.Date("2016-01-01"))

tender$month <- as.numeric(strftime(tender$DT_TENDER_PUB, "%m"))

tender$year <- as.numeric(strftime(tender$DT_TENDER_PUB, "%Y"))

tender$year_month <- as.Date(paste0(tender$year, "-", tender$month, "-01"))

tender <- tender%>%
  
  mutate(semester = ifelse(month <= 6, "03", "09"))

tender$semester <- paste0(tender$year, "-", tender$semester, "-30")

tender <- as.data.table(tender)

n_tender <- tender[year >= 2016 & year <= 2022, 
                   n_tender :=  length(unique(ID)),
                   by = .(year_month, semester, Group)]


clfe <- feols(data = n_tender, n_tender ~ Group | year_month, cluster = ~semester)

etable(clfe)

# number of contract per month 
n_contract <- tender[year >= 2016 & year <= 2022, 
                     n_contract :=  length(unique(ID_CONTRACT)),
                     by = .(year_month, semester, Group)]


clfe <- feols(data = n_contract, n_contract ~ Group | year_month, cluster = ~semester)

etable(clfe)

# Average Contract Value per Month  
contract_value$year_month <- as.Date(paste0(contract_value$year, "-", contract_value$month, "-01"))

contract_value <- as.data.table(contract_value)

contract_value_avg <- contract_value[year >= 2016 & year <= 2022, 
                     contract_value_avg := mean(AMT_CONTRACT_VALUE_USD),
                     by = .(year_month, semester, Group)]

clfe <- feols(data = contract_value_avg, contract_value_avg ~ Group | year_month, cluster = ~semester)

etable(clfe)


## 2 Type of Procedure ----------------------------------------------

# Not sure what would be a better dependent variable for this 

# The code below do not work 
# the share of contract value purchased by open method in each group??
# method_share <- method_share[year >= 2016 & year <= 2022, 
#                                      method_share := sum(AMT_CONTRACT_VALUE_USD)/length(unique(ID_CONTRACT)),
#                                      by = .(year_month, semester, Group)]
# 
# clfe <- feols(data = contract_value_avg, contract_value_avg ~ Group | year_month, cluster = ~semester)
# 
# etable(clfe)


# 3 Competition ------------------------------------------------------

# FE: the average unique UNSPSC code firms have supplied within 6 months 
firm_item <- firm_item%>%
  filter(year >= 2016 & 
           year <= 2022)%>%
  dplyr::rename(Group = covid_firm)

firm_item$Group <- replace(firm_item$Group, firm_item$Group == 0|is.na(firm_item$Group), "Non-COVID")

firm_item$Group <- replace(firm_item$Group, firm_item$Group == 1, "COVID")

firm_item$semester <- as.Date(firm_item$semester)

# calculation 
firm_item <- as.data.table(firm_item)

firm_item_avg <- firm_item[year >= 2016 & year <= 2022, 
                           num_unspsc := length(unique(ID_ITEM_UNSPSC)),
                           by = .(ID_PARTY, semester, Group)]

firm_item_avg <- firm_item_avg[,
                               num_unspsc_avg := mean(num_unspsc),
                               by = .(semester, Group)]

clfe <- feols(data = firm_item_avg, num_unspsc_avg ~ Group | year_month, cluster = ~semester)

etable(clfe)


# DiD 
firm_item_did <- as.data.table(firm_item_did)

# average number of new product sold since 2020 by semester
firm_item_avg_new <- firm_item_did[year >= 2016 & year <= 2022, 
                                   sum_new := sum(unspsc_new, na.rm = TRUE),
                                   by = .(ID_PARTY, semester, Group)]

firm_item_avg_new <- firm_item_avg_new[,
                                       avg_new := mean(sum_new, na.rm = TRUE),
                                       by = .(semester, Group)]

clfe <- feols(data = firm_item_avg_new, avg_new ~ Group | year_month, cluster = ~semester)

etable(clfe)

# average number of new COVID product 
firm_item_avg_new_COVID <- firm_item_did[year >= 2016 & year <= 2022, 
                                         new_COVID := unspsc_new * covid_item]

firm_item_avg_new_COVID <- firm_item_avg_new_COVID[,
                                                   sum_new := sum(new_COVID, na.rm = TRUE),
                                                   by = .(ID_PARTY, semester, Group)]

firm_item_avg_new_COVID <- firm_item_avg_new_COVID[,
                                                   avg_new := mean(sum_new, na.rm = TRUE),
                                                   by = .(semester, Group)]

clfe <- feols(data = firm_item_avg_new_COVID, avg_new ~ Group | year_month, cluster = ~semester)

etable(clfe)


# average number of new non-COVID product 
firm_item_avg_new_non_COVID <- firm_item_did%>%
  filter(year >= 2020 & year <= 2022)%>%
  mutate(new_non_COVID = ifelse(unspsc_new == 1 & covid_item == 0, 1, 0))

firm_item_avg_new_non_COVID <- as.data.table(firm_item_avg_new_non_COVID)

firm_item_avg_new_non_COVID <- firm_item_avg_new_non_COVID[,
                                                       sum_new := sum(new_non_COVID, na.rm = TRUE),
                                                       by = .(ID_PARTY, semester, Group)]

firm_item_avg_new_non_COVID <- firm_item_avg_new_non_COVID[,
                                                           avg_new := mean(sum_new, na.rm = TRUE),
                                                           by = .(semester, Group)]

clfe <- feols(data = firm_item_avg_new_non_COVID, avg_new ~ Group | year_month, cluster = ~semester)

etable(clfe)



# 4 market concentration ----------------------------------------------
# the market share of the top 3 suppliers in each sector per semester
clfe <- feols(data = market_concentration, top3_share ~ Group | semester)

etable(clfe)


# 5 duration -----------------------------------------------

tender_contract <- as.data.table(tender_contract)

# submission time 
submission <- tender_contract[year >= 2016 & year <= 2022, 
                     submission :=  mean(submission_time),
                     by = .(year_month, semester, Group)]


clfe <- feols(data = submission, submission ~ Group | year_month, cluster = ~semester)

etable(clfe)


# processing time 
processing <- tender_contract[year >= 2016 & year <= 2022, 
                              processing :=  mean(processing_time),
                              by = .(year_month, semester, Group)]


clfe <- feols(data = processing, processing ~ Group | year_month, cluster = ~semester)

etable(clfe)



# decision time 
decision <- tender_contract[year >= 2016 & year <= 2022, 
                              decision :=  mean(decision_time),
                              by = .(year_month, semester, Group)]


clfe <- feols(data = decision, decision ~ Group | year_month, cluster = ~semester)

etable(clfe)


# 6 new winners 
new_winner_month_group <- new_winner%>%
  dplyr::rename(Group = covid_firm)%>%
  filter(year >= 2016 &
           year <= 2022)%>%
  filter(!is.na(Group))

new_winner_month_group$Group <- replace(new_winner_month_group$Group, new_winner_month_group$Group == 0, "Non-COVID")

new_winner_month_group$Group <- replace(new_winner_month_group$Group, new_winner_month_group$Group == 1, "COVID")

new_winner_month_group$year_month <- as.Date(paste0(new_winner_month_group$year, "-",
                                                    new_winner_month_group$month, "-01"))

new_winner <- as.data.table(new_winner_month_group)

new_winner <- new_winner[year >= 2016 & year <= 2022, 
                                     share_new_winner := sum(new_winner)/length(unique(ID_CONTRACT)),
                            by = .(year_month, semester, Group)]


clfe <- feols(data = new_winner, share_new_winner ~ Group | year_month, cluster = ~semester)

etable(clfe)





