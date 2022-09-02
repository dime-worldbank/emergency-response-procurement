# ---------------------------------------------------------------------------- #
#
#                            Global Health Data 

#                                  Graphs 

#       Author: Hao Lyu                           Update: 09/01/2022
#
# ---------------------------------------------------------------------------- #


# ================================= Content ================================== #
# 
#
#        1)  draw graphs :plot the time trends of number of deaths and number 
#                         of cases at weekly level
#        2)  Honduras, Brazil, Romania, Chile
#
#                                                                                 
# ---------------------------------------------------------------------------- #


# Import Data  -----------------------------------------------------------------

  covid <- fread(paste0(raw, "owid-covid-data.csv"), stringsAsFactors = FALSE)
  

# Clean Data 
  # the dataset is harmonized 
  
  
# Calculate Week sum 
  
    # generate a year_week variable 
    
    covid <- as.data.frame(covid)
    
    covid <- covid %>%
      mutate(date = as.Date(date, format = "%Y-%m-%d")) %>%
      mutate(yearweek = as.integer(strftime(date, format = "%Y%V")))%>%
      mutate(yearweek2 = ifelse(test = day(date) < 7 & as.integer(substr(yearweek, 5, 6)) > 51,
                                yes =  yearweek - 100,
                                no = yearweek))%>%
      select(-yearweek)%>%
      rename(yearweek = yearweek2)
  
    
     # calculate weekly sum of number of death, number of cases
     
     covid$location <- as.character(covid$location)
   
     death_week <- covid%>%
       group_by(location, yearweek)%>%
       summarise(death_week = sum(new_deaths))%>%
       ungroup()
    
     cases_week <- covid%>%
       group_by(location, yearweek)%>%
       summarise(cases_week = sum(new_cases))%>%
       ungroup()
     

# Plot for the number of death 
     
     death_week$location <- as.factor(death_week$location)
     
     death_week_brazil <- filter(death_week, location == "Brazil")
     
     brazil_death <- 
       ggplot(death_week_brazil, aes(x = yearweek, y = death_week))+
       geom_line(size = 1)+
       labs(x = "Week", y = "Number of New Death")+
       theme_classic()
     
     death_week_honduras <- filter(death_week, location == "Honduras")
     
     honduras_death <- 
       ggplot(death_week_honduras, aes(x = yearweek, y = death_week))+
       geom_line(size = 1)+
       labs(x = "Week", y = "Number of New Death")+
       theme_classic()
     
     death_week_chile <- filter(death_week, location == "Chile")
     
     chile_death <- 
       ggplot(death_week_chile, aes(x = yearweek, y = death_week))+
       geom_line(size = 1)+
       labs(x = "Week", y = "Number of New Death")+
       theme_classic()
     
     death_week_romania <- filter(death_week, location == "Romania")
     
     romania_death <- 
       ggplot(death_week_romania, aes(x = yearweek, y = death_week))+
       geom_line(size = 1)+
       labs(x = "Week", y = "Number of New Death")+
       theme_classic()

     tiff(filename = paste(output, 'Death_per_Week.png'), units="in", width=12, height=10, res=300)
     
     ggarrange(brazil_death, romania_death, chile_death, honduras_death, 
               labels = c("Brazil","Romania","Chile", "Honduras"),
               font.label = list(size = 11, face = "plain", color ="black"),
               ncol = 2, nrow = 2,
               hjust = -0.5,
               vjust = 0.8,
               common.legend = TRUE)
     
     dev.off()
     
    

# Plot the number of cases    

     cases_week$location <- as.factor(cases_week$location)
    
     cases_week_brazil <- filter(cases_week, location == "Brazil")
     
     brazil_cases <- 
       ggplot(cases_week_brazil, aes(x = yearweek, y = cases_week))+
       geom_line(size = 1)+
       labs(x = "Week", y = "Number of New Cases")+
       theme_classic()
     
     cases_week_romania <- filter(cases_week, location == "Romania")
     
     romania_cases <- 
       ggplot(cases_week_romania, aes(x = yearweek, y = cases_week))+
       geom_line(size = 1)+
       labs(x = "Week", y = "Number of New Cases")+
       theme_classic()
     
     cases_week_chile <- filter(cases_week, location == "Chile")
     
     chile_cases <- 
       ggplot(cases_week_chile, aes(x = yearweek, y = cases_week))+
       geom_line(size = 1)+
       labs(x = "Week", y = "Number of New Cases")+
       theme_classic()
     
     cases_week_honduras <- filter(cases_week, location == "Honduras")
     
     honduras_cases <- 
       ggplot(cases_week_honduras, aes(x = yearweek, y = cases_week))+
       geom_line(size = 1)+
       labs(x = "Week", y = "Number of New Cases")+
       theme_classic()
     
     tiff(filename = paste(output, 'New_Cases_per_Week.png'), units="in", width=12, height=10, res=300)
     
     ggarrange(brazil_cases, romania_cases, chile_cases, honduras_cases, 
               labels = c("Brazil","Romania","Chile", "Honduras"),
               font.label = list(size = 11, face = "plain", color ="black"),
               ncol = 2, nrow = 2,
               hjust = -0.5,
               vjust = 0.8,
               common.legend = TRUE)
     
     dev.off()
     
     
     
     
     
     
     
     
     
     
     
     
     


  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

