library(tibble)
library(readr)
library(tidyr)
library(tidyverse)
library(dplyr)

#create dictionary for quintile-able data only
quintile_dictionary<- as.tibble(read_csv("data/PQ data/subset_quintile_PQ_dictionary_censusprofile.csv"))


#data
filetouse<- "outputs/pq outputs/CLEAN_2021_census_extract-2023-09-14.csv"
#create clean data file (insert source file for each here above)
raw_file <- read_csv(filetouse)

#Move ONS id to front
raw_file<-raw_file%>%
  relocate("ONS_ID",.before = name)

colnames(raw_file)[1] <- "ONS_ID"
colnames(raw_file)[2] <- "ONS_Name"

#cleaning the file
clean_file<- as.data.frame(raw_file %>%
  t())

### THIS NEXT PART YOU CAN PROBABLY OMIT####

clean_file<-clean_file %>%
  mutate(
    VAR_ID = rownames(clean_file)
  ) %>% relocate("VAR_ID",.before = V1)

clean_file[1,1]="VAR_ID"
colnames(clean_file) <- clean_file[1,]
clean_file<- clean_file[-1,]
colnames(clean_file)

clean_file<-as.tibble(clean_file)
colnames(clean_file)
clean_file<-clean_file[-1,]



####IGNORE THIS PART IF YOU ALREADY SUBSET YOUR DICTIONARY######
#subsetting dictionary to include only %
Percentages1<- filter(dictionary_indiv, grepl("Percentage",dictionary_indiv$type,))
Percentages2<- filter(dictionary_indiv, grepl("Median",dictionary_indiv$type,))
Percentages3<- filter(dictionary_indiv, grepl("Average",dictionary_indiv$type,))
quintile_dictionary<- as.tibble(rbind(Percentages1,Percentages2,Percentages3))

#pull out that dictionary
quintile_dictionary<- as.tibble(quintile_dictionary)
colnames(quintile_dictionary)[1] <- "VAR_ID"

  
ncol(quintile_dictionary)
nrow(quintile_dictionary)

## Join here
comparable_data<- left_join(
  as.tibble(quintile_dictionary),
  as.tibble(clean_file),
  by="VAR_ID"
)

# comparable_data<- clean_file    ---a little different for the non-census data here
comparable_data2 <- as.data.frame(t(comparable_data))
colnames(comparable_data2)<- comparable_data2[1,]
comparable_data2 <- comparable_data2[-1,]
compare3 <-comparable_data2[-c(1,2,3,4,5,6,7,8,9),]

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

#check last column of data
ncol(ranked)
colnames(ranked[ncol(ranked)])
print(ranked[,(ncol(ranked))])


#quintiles
x <- ncol(ranked)
for (i in 1:x) {
  ranked[,i] <- ifelse(ranked[,i]<22.5,"Q1",
                       ifelse(ranked[,i]<43.5,"Q2",
                              ifelse(ranked[,i]<64.5,"Q3",
                                     ifelse(ranked[,i]<85.5,"Q4",
                                            ifelse(ranked[,i]>85.49,"Q5","MISTAKE!")))))
  print(ranked[,i])
}

#transpose
quintiles<- as.data.frame(t(ranked))
quintiles<-quintiles %>%
  mutate(VAR_ID= rownames(quintiles)
         )
quintiles<-quintiles%>% 
  relocate("VAR_ID",.before = "3002")


write_csv(quintiles,"outputs/pq outputs/processed/quintiles/FINAL_Quintiles_CensusProfile.csv")

