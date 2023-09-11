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

poptype= "Youth_15-24"
#working pop type
filetouse<- "outputs/pq outputs/processed/clean_pq_tgp_age_15to24-2023-09-08.csv"
#create clean data file (insert source file for each here above)
raw_file <- read_csv(filetouse)
colnames(raw_file) <- raw_file[1,]
colnames(raw_file)[1] <- "ONS_Name"
colnames(raw_file)[2] <- "ONS_ID"
raw_file <- raw_file[-c(1,2,3),]


#cleaning the file
clean_file<- as.data.frame(raw_file[,-1] %>%
  t())

clean_file<-clean_file %>%
  mutate(
    VAR_ID = rownames(clean_file)
  ) %>% relocate("VAR_ID",.before = V1)
clean_file[1,1]="VAR_ID"
colnames(clean_file) <- clean_file[1,]
clean_file<- clean_file[-1,]
clean_file<-subset(clean_file, select =-65)

clean_file<-as.tibble(clean_file)
colnames(clean_file)

#subsetting dictionary to include only %
Percentages1<- filter(dictionary_indiv, grepl("Percentage",dictionary_indiv$type,))
Percentages2<- filter(dictionary_indiv, grepl("Median",dictionary_indiv$type,))
Percentages3<- filter(dictionary_indiv, grepl("Average",dictionary_indiv$type,))
compare_dictionary<- as.tibble(rbind(Percentages1,Percentages2,Percentages3))

comparable_data<- left_join(
  as.tibble(compare_dictionary),
  as.tibble(clean_file),
  by="VAR_ID"
)

comparable_data2 <- as.data.frame(t(comparable_data))
colnames(comparable_data2)<- comparable_data2[1,]
comparable_data2 <- comparable_data2[-c(1,2,3,4),]
compare3 <-comparable_data2

#convert to numeric
for (i in 1:40) {
  compare3[,i] <- as.numeric(compare3[,i])
  print(typeof(compare3[,1]))
}
ranked<-compare3

#rank
for (i in 1:40) {
  ranked[,i] <- rank(ranked[,i],ties.method="average")
  print(ranked[,i])
}

#quintiles
for (i in 1:40) {
  ranked[,i] <- if(ranked[,i],ties.method="average")
  print(ranked[,i])
}
?if
write_csv(compare3,"outputs/pq outputs/processed/forQs_youth.csv")
write_csv(ranked,"outputs/pq outputs/processed/ranked_youth.csv")
