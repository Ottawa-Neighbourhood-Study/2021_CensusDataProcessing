library(tibble)
library(readr)
library(tidyr)
library(tidyverse)
library(dplyr)

#create dictionary for quintile-able data only
quintile_dictionary<- as.tibble(read_csv("data/PQ data/Dictionaries/v2_PQ_non-census_dictionary-2023-09-27.csv"))


#data
filetouse<- "data/PQ data/WIDE_data/v2_pq_data_non_census_wide_no_metadata.csv"
#create clean data file (insert source file for each here above)
raw_file <- read_csv(filetouse)


#Move ONS id to front
#raw_file<-raw_file%>%
#  relocate("ONS_ID",.before = name)

colnames(raw_file)[1] <- "ONS_ID"
#colnames(raw_file)[2] <- "ONS_Name"


clean_file<- raw_file[-1,] #remove first row of ONS ID

#pull out that dictionary
quintile_dictionary <- quintile_dictionary %>%
  relocate("data_ID",.before = "Var_Name_clean")
  
ncol(quintile_dictionary)
nrow(quintile_dictionary)

#filter dictionary by quintilable

quintile_dictionary2 <- filter(quintile_dictionary, Quintilable == "yes")

clean_file2<- as.data.frame(raw_file %>%
                             t())

clean_file3 <- clean_file2 |>
    mutate(data_ID=rownames(clean_file2)) |>
     relocate("data_ID",.before = "V1")
clean_file3[1,1] = "data_ID"
colnames(clean_file3) = clean_file3[1,]

## Join here
comparable_data<- left_join(
  as.tibble(quintile_dictionary2),
  as.tibble(clean_file3),
  by="data_ID"
)

# comparable_data<- clean_file    ---a little different for the non-census data here
comparable_data2 <- as.data.frame(t(comparable_data))
colnames(comparable_data2)<- comparable_data2[1,]


compare3 <-comparable_data2[-c(1:7),]

compare3_backup<-compare3
#convert to numeric
ncol(compare3)
nrow(compare3)
for (i in 1:(ncol(compare3))) {
  compare3[,i] <- as.numeric(compare3[,i])
  print(typeof(compare3[,1]))
}


## a little different here too for non-census: ranked=compare3[-c(1,2),] (removing Ottawa from quintile analysis)
ranked=compare3

#rank
ncol(ranked)
nrow(ranked)
for (i in 1:(ncol(ranked))) {
  ranked[,i] <- rank(ranked[,i],ties.method="average",na.last="keep")
  print(ranked[,i])
}

print(ranked[,2])

#check last column of data
ncol(ranked)
colnames(ranked[ncol(ranked)])
print(ranked[,(ncol(ranked))])


ncol(ranked)
#quintiles

ranked_backup=ranked

x <- ncol(ranked)
for (i in 1:x) {
  ranked[,i] <- ifelse(ranked[,i]<22.5,"Q1",
                       ifelse(ranked[,i]<43.5,"Q2",
                              ifelse(ranked[,i]<64.5,"Q3",
                                     ifelse(ranked[,i]<85.5,"Q4",
                                            ifelse(ranked[,i]>85.49,"Q5","MISTAKE!")))))
  print(ranked[,i])
}

#count how many Q1s, Q2, Q3, etc. for each column. Look up how to do


#transpose - not sure if this part below belongs or not (resolving conflicts)
#quintiles<- as.data.frame(t(ranked))
#quintiles<-quintiles %>%
#  mutate(VAR_ID= rownames(quintiles)) %>% 
#  relocate("VAR_ID",.before = "3002")
#
#compare3 <- as.data.frame(compare3) %>%
#  t()

quintiles<-ranked %>%
  mutate(ONS_ID= rownames(ranked)) %>% 
  relocate("ONS_ID",.before = "food_convenience_num_per_1000_res_plus_buffer")

#colnames(compare3)

#write CSV
file_name <- paste0("outputs/pq outputs/processed/quintiles/FINAL_Quintiles_non_census-", Sys.Date(),".csv")
readr::write_csv(quintiles, file_name)
message("Results saved to ", file_name)


