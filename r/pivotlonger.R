library(tibble)
library(readr)
library(tidyr)
library(tidyverse)
library(dplyr)

genpop_raw<- read_csv("outputs/pq outputs/processed/quintiles/modified/Quintiles_genpop.csv")
seniors_raw<- read_csv("outputs/pq outputs/processed/quintiles/modified/Quintiles_seniors.csv")
youth_raw<- read_csv("outputs/pq outputs/processed/quintiles/modified/Quintiles_youth.csv")
newcomers_raw<-read_csv("outputs/pq outputs/processed/quintiles/modified/Quintiles_Newcomers20162021.csv")
racialized_raw<-read_csv("outputs/pq outputs/processed/quintiles/modified/Quintiles_Racialized.csv")
noncensus<-read_csv("data/PQ data/pq_data_non_census_wide.csv")

#long
long_gen<-pivot_longer(genpop_raw,2:ncol(genpop_raw))
long_seniors<-pivot_longer(seniors_raw,2:ncol(seniors_raw))
long_youth<-pivot_longer(youth_raw,2:ncol(youth_raw))
long_newcomers<-pivot_longer(newcomers_raw,2:ncol(newcomers_raw))
long_racial<-pivot_longer(racialized_raw,2:ncol(racialized_raw))
long_noncensus<-pivot_longer(noncensus,2:ncol(noncensus))

#rounding values to two decimals
long_noncensus$value <-round(long_noncensus$value,2)

#writeing long file
write_csv(long_gen,"outputs/pq outputs/processed/quintiles/modified/long_Quintiles_genpop.csv")
write_csv(long_seniors,"outputs/pq outputs/processed/quintiles/modified/long_Quintiles_seniors.csv")
write_csv(long_youth,"outputs/pq outputs/processed/quintiles/modified/long_Quintiles_youth.csv")
write_csv(long_newcomers,"outputs/pq outputs/processed/quintiles/modified/long_Quintiles_Newcomers20162021.csv")
write_csv(long_racial,"outputs/pq outputs/processed/quintiles/modified/long_Quintiles_Racialized.csv")

write_csv(long_noncensus,"outputs/pq outputs/processed/long_NONcensus2023-09-12.csv")



stats_gen<- read_csv("outputs/pq outputs/processed/quintiles/forQs_genpop.csv")
test<- stats_gen %>%
  select(ncol(stats_gen),1:(ncol(stats_gen)-1))
write_csv(test,file="outputs/pq outputs/stats_genpop.csv")
stats_gen

long_gen2<-pivot_longer(test,2:ncol(test))
write_csv(long_gen2,file="outputs/pq outputs/long_stats_genpop.csv")
