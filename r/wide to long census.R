library(tidyr)
library(janitor)
library(dplyr)
library(readr)
library(usethis)
wide = read_csv("outputs/pq outputs/CLEAN_2021_census_extract-2023-09-14.csv")

#bring ONS ID to front and remove hood names
wide2<-wide %>%
  relocate("ONS_ID",.before = name)
wide2<- wide2[,-2]


long = pivot_longer(wide2, 2:(ncol(wide2)))
colnames(wide2)

long2 <-long %>%
  mutate(
    value_round= round(long$value, digits = 4)
  )

filename <- paste0("outputs/pq outputs/processed/Final_Census_long_PQ", Sys.Date(),".csv")
readr::write_csv(long2, filename)
message("Results saved to ", filename)

write.csv(long, file="outputs/pq outputs/processed/pq_final_census_var_long.csv")