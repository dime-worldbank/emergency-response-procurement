
require(data.table)
require(tidyverse)
library("factoextra")

setwd("C:/Users/leand/Dropbox/3-Profissional/07-World BANK/04-procurement/06-Covid_Brazil/1_data")

#Load iris dataset
data_test<-fread("covid_test.csv") %>%
      select( log_covid_value,log_covid_purchase) %>%
    filter(!is.na(log_covid_purchase),!is.na(log_covid_value))

data_test<-rbind(data_test,
                 tibble(log_covid_value =0,log_covid_purchase=0))

glimpse(data_test)

aux_scale     <- scale(data_test)
kmeansClusters<- kmeans(aux_scale, 5, nstart = 25)

x11()
#Visualisation of resuls using fviz_cluster from factoextra
fviz_cluster(kmeansClusters,data_test, stand = FALSE, geom = "point")


data_out <- mutate(data_test, cluster= kmeansClusters$cluster) %>%
    arrange(cluster,log_covid_purchase) %>%
    filter(log_covid_value !=0)

limits <- data_out %>%
    group_by(cluster) %>%
    summarize(min_purchases = min(log_covid_purchase), 
              min_value = min(log_covid_value)) %>%
    mutate(N_limits    = exp(min_purchases),
           value_limit = exp(min_value),
           ) %>%
  arrange(min_purchases)

limits[,c(4,5)]

count(data_out,cluster)


