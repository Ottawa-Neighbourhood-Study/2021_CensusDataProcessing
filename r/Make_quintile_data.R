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

#create clean data file (insert source file for each here below)
raw_youth <- read_csv("outputs/pq outputs/processed/clean_pq_tgp_age_15to24-2023-09-08.csv")
colnames(raw_youth) <- raw_youth[1,]
colnames(raw_youth)[1] <- "ONS_Name"
colnames(raw_youth)[2] <- "ONS_ID"
raw_youth <- raw_youth[-c(1,2,3),]

filter(raw_youth, grep())

?grep
