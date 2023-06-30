library(tidyr)
library(janitor)
library(dplyr)
library(readr)
library(usethis)
#load readr
# read_csv for tibble


# Importing the raw 2021 census data
raw_data_long <- read_csv("data/RAW_Census_Profile_2021_Gen3 - Copy.csv")

# Importing the CSV file with SES index, numerator and denominator
num_den <- read_csv("data/SES indexes.csv")

# Convert the raw census data from long to wide
# We do this in a few steps.
# FIRST we use janitor::clean_names() to make nicer names with no spaces in them
# then we remove the column `age_33p` because entries in it are not unique. 
#    If we need human-readable data labels we can add them later!
# then we pivot to a very long tibble with one column for region name, one for
#    data index ("ID1", "ID134", etc.), and one for the data value
# then we pivot wide again, this time with one column per data ID and one column per region
# then we make every column EXCEPT name numeric. dplyr::across() lets you apply
#    functions across columns without having to type them all out

raw_data_pivoted <- raw_data_long |>
  janitor::clean_names() |>
  dplyr::select(-age_33p) |>
  tidyr::pivot_longer(cols = -"data_id") |> 
  tidyr::pivot_wider(names_from = data_id, values_from = value) |>
  dplyr::mutate(dplyr::across(-"name", as.numeric))


# set up a tibble that will contain our results. one row per region
results <- dplyr::select(raw_data_pivoted, name)

# loop through all ses indices in the dictionary
for (i in 1:nrow(num_den)) {
  
  # extract the metadata for the index we are computing right now
  ses_index <- num_den[i,]
  ses_index_name <- ses_index$`SES Index`
  
  # get the column names/indices.
  # we keep the raw denominator index for comparison later to see is it a true
  # index, or if are we just using the number 1 as our denominator
  num_index <- paste0("ID", ses_index$Numerator)
  den_index_raw <- ses_index$Denominator
  den_index <- paste0("ID", den_index_raw)
  
  # print an update to the console
  message(i, ": ", ses_index_name)
  
  # calculate the index and put it in a tibble called result
  
  # if the denominator index is a number, we use it as expected
  if (!suppressWarnings(is.na(as.numeric(den_index_raw, warn = FALSE)))){
    
    ## this bit of code uses metaprogramming in R -- if you want to use a variable
    ## to select a column it takes some magic. That's what the {{ embraced }}
    ## variable does, the := operator, and the !!rlang::sym() call.
    ## you can read all about it here! https://adv-r.hadley.nz/metaprogramming.html
    result <- raw_data_pivoted |>
      dplyr::transmute(name,  {{ses_index_name}} := !!rlang::sym(num_index) / !!rlang::sym(den_index)) |>
      janitor::clean_names()
    
  } else {
    # otherwise, if the denominator index is NOT a number, the denominator should just be 1
    
    result <- raw_data_pivoted |>
      dplyr::transmute(name,  {{ses_index_name}} := !!rlang::sym(num_index) ) |>
      janitor::clean_names()
  }
  
  # add our result (this new index) to our results (table with all indices)
  results <- dplyr::left_join(results, result, by = "name")
}


results

## results can now be written to file

readr::write_csv(results, paste0("outputs/ses_indices-", Sys.Date(),".csv"))

# raw_data_wide = as.data.frame(t(raw_data_long)) |> dplyr::as_tibble()

# #Adding column names and removing text rows
# df = raw_data_wide %>%
#   slice(-2)
# 
# colnames(df) = df[1, ]
# 
# df = df %>%
#   slice(-1)
# 
# typeof(df$ID1)
# 
# df[df == "x"] <- NA
# 
# #Converting column types to numeric
# df_2 <- df %>% mutate_at(1:2601, as.numeric)
# #Mutate
# df_3 = df_2 %>%
#   mutate("ONE" = 1)
# df_3$ONE
# 
# which(colnames(df_3) == "ONE")
# num_den["Denominator"][num_den["Denominator"] == 1] <- 2602
# 
# #testing the equation outside for loop, where i is set to 1
# num<- as.numeric(num_den[1,"Numerator"])
# denom<- as.numeric(num_den[1,"Denominator"])
# typeof(num)
# typeof(denom)
# 
# test4<- df_3 %>%
#   mutate (var = df_3[,num] / df_3[,denom])
# test4$var #and it works!
# 
# #now let's try it in a loop where i is in 1:14
# testloop = df_3 #creating a copy of df_3
# for (i in 1:13)
# {num<- as.numeric(num_den[i,"Numerator"])
# denom<- as.numeric(num_den[i,"Denominator"])
# testloop<- testloop%>%
#   mutate (var = testloop[,num] / testloop[,denom])}
# 
# print(testloop$ID1)
# 
# test5$i = as.data.frame(as.list.data.frame(testloop[,num])/as.list.data.frame(testloop[,denom]))}
# test5$i
# 
# #Testing to see that I can easily pull the numerator & denom col index from the num_dem file
# testloop = df_3
# 
# for (i in 1:14)
# {num<- num_den[i,"Numerator"]
# denom<- num_den[i,"Denominator"]
# testloop<- testloop %>%
#   mutate(var =testloop[,num]/testloop[,denom])}
# typeof(testloop$i)
