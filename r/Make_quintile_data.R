library(tibble)
library(readr)
library(tidyr)
library(tidyverse)
library(dplyr)

dictionary_indiv<- read_csv("outputs/pq outputs/processed/clean_pq_tgp_age_15to24-2023-09-08.csv")[c(1,2,3),]

testdf <- dictionary_indiv %>%
  pivot_longer()

raw_youth <- read_csv("outputs/pq outputs/processed/clean_pq_tgp_age_15to24-2023-09-08.csv")
colnames(raw_youth) <- raw_youth[1,]
colnames(raw_youth)[1] <- "ONS_Name"
colnames(raw_youth)[2] <- "ONS_ID"
dictionary <- raw_youth[c(1,2,3),]

raw_youth <- raw_youth[-c(1,2,3)]
