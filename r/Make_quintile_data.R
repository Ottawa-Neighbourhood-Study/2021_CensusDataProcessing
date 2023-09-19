library(tibble)
library(readr)
library(tidyr)
library(tidyverse)
library(dplyr)

#create dictionary using any of the data files
dictionary_indiv<- as.tibble(read_csv("outputs/pq outputs/processed/clean_pq_tgp_age_15to24-2023-09-08.csv")[c(1,2,3),] %>%
  t()) %>%
  mutate(
    description =as.tibble(colnames(read_csv("outputs/pq outputs/processed/clean_pq_tgp_age_15to24-2023-09-08.csv")))
  )
colnames(dictionary_indiv) <- c("VAR_ID","type","category", "description")
dictionary_indiv<- dictionary_indiv[-c(1,2,nrow(dictionary_indiv)),]

poptype= "Racialized"
#working pop type
filetouse<- "data/PQ data/ForQs_pq_data_non_census_wide.csv"
#create clean data file (insert source file for each here above)
raw_file <- read_csv(filetouse)

#colnames(raw_file) <- raw_file[1,]
#colnames(raw_file)[1] <- "ONS_Name"
#colnames(raw_file)[2] <- "ONS_ID"
#raw_file <- raw_file[-c(1,2,3),]
raw_file <- raw_file[-1,]

#cleaning the file
clean_file<- as.data.frame(raw_file %>%
  t())

clean_file<-clean_file %>%
  mutate(
    VAR_ID = rownames(clean_file)
  ) %>% relocate("VAR_ID",.before = V1)
clean_file[1,1]="VAR_ID"
colnames(clean_file) <- clean_file[1,]
clean_file<- clean_file[-1,] #remove first row of ONS ID
colnames(clean_file)

clean_file[,65]
clean_file<-subset(clean_file, select =-65)
colnames(clean_file)
clean_file<-as.tibble(clean_file)
colnames(clean_file)

#subsetting dictionary to include only %
#Percentages1<- filter(dictionary_indiv, grepl("Percentage",dictionary_indiv$type,))
#Percentages2<- filter(dictionary_indiv, grepl("Median",dictionary_indiv$type,))
#Percentages3<- filter(dictionary_indiv, grepl("Average",dictionary_indiv$type,))
#compare_dictionary<- as.tibble(rbind(Percentages1,Percentages2,Percentages3))

#comparable_data<- left_join(
#  as.tibble(compare_dictionary),
#  as.tibble(clean_file),
#  by="VAR_ID"
#)

comparable_data<- as.tibble(clean_file)

# comparable_data<- clean_file    ---a little different for the non-census data here

comparable_data2 <- as.data.frame(t(comparable_data))
colnames(comparable_data2)<- comparable_data2[1,]
#comparable_data2 <- comparable_data2[-c(1,2,3,4),]
comparable_data2 <- comparable_data2[-1,]
compare3 <-comparable_data2

compare3_backup<-compare3
#convert to numeric
ncol(compare3)
for (i in 1:23) {
  compare3[,i] <- as.numeric(compare3[,i])
  print(typeof(compare3[,1]))
}

#checking on data- insert variable name here as a test. check for NAs
test=as.tibble(compare3$percent_attached)
print(as.list(test))

#remove non populated hoods
ranked=compare3[-c(1,6,19,30,42,51,57,83),]


## a little different here too for non-census: ranked=compare3[-c(1,2),] (removing Ottawa from quintile analysis)

backup_orig = ranked
ncol(ranked)
#rank
for (i in 1:23) {
  ranked[,i] <- rank(ranked[,i],ties.method="average",na.last="keep")
  print(ranked[,i])
}

print(ranked[,2])

ncol(ranked)
#quintiles
ranked_backup=ranked

for (i in 1:23) {
  ranked[,i] <- ifelse(ranked[,i]<22.5,"Q1",
                       ifelse(ranked[,i]<43.5,"Q2",
                              ifelse(ranked[,i]<64.5,"Q3",
                                     ifelse(ranked[,i]<85.5,"Q4",
                                            ifelse(ranked[,i]>85.49,"Q5","MISTAKE!")))))
  print(ranked[,i])
}


quintiles<- as.data.frame(t(ranked))
quintiles<-quintiles %>%
  mutate(VAR_ID= rownames(quintiles)
         ) %>% relocate("VAR_ID",.before = "3002")
compare3 <- as.data.frame(compare3) %>%
  t()

compare3<- as.data.frame(compare3) %>%
  mutate(VAR_ID= rownames(compare3)
  )

colnames(compare3)

write_csv(compare3,"outputs/pq outputs/processed/quintiles/forQs_Racialized.csv")
write_csv(quintiles,"outputs/pq outputs/processed/quintiles/Quintiles_NON_census.csv")

