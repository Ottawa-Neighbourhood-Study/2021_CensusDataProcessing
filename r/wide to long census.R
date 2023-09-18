library(tidyr)
library(janitor)
library(dplyr)
library(readr)
library(usethis)

wide = read_csv("outputs/pq outputs/processed/quintiles/FINAL_Quintiles_CensusProfile.csv", col_names= FALSE)

wide2 = as_tibble(t(wide))
wide2[1,1]="ONS_ID"

#bring ONS ID to front and remove hood names
wide3 <- as_tibble(t(wide2))

colnames(wide3)<- wide3[1,]
wide3 <- wide3[-1,]



long = pivot_longer(wide3, 2:(ncol(wide3)))
colnames(wide3)

long2 <-long %>%
  mutate(
    value_round= round(long$value, digits = 4)
  )

filename <- paste0("outputs/pq outputs/processed/Final_Census_long_PQ", Sys.Date(),".csv")
readr::write_csv(long2, filename)
message("Results saved to ", filename)

write.csv(long, file="outputs/pq outputs/processed/quintiles/FINAL_LONG_QUINTILES_CENSUS.csv")
