library(tidyr)
library(janitor)
library(dplyr)
library(readr)
library(usethis)
library(stringr)
# #load readr
# # read_csv for tibble
# 
#PART 1- run the script to calculate get the results:
calculate_ses_indices()

#PART 2- clean the results file and isolate Ottawa neighbourhoods
# load data
dirty_data<- read_csv("outputs/ses_indices-2023-09-04.csv")
# remove non-ONS hoods
dirty2<-dirty_data[grep("ons2022", dirty_data$name),]

# remove census jargon
dirty2$name <- gsub("\\_00000.*", "", dirty2$name)
dirty2$name <- gsub("ons2022_\\.*", "", dirty2$name)
dirty2$name <- gsub("\\_999.*", "", dirty2$name)
dirty2$name <- gsub("\\_0999.*", "", dirty2$name)
dirty2$name <- gsub("\\_000.*", "", dirty2$name)
dirty2$name <- gsub("\\_00919.*", "", dirty2$name)
dirty2$name <- gsub("\\_03030.*", "", dirty2$name)

# create ONS_ID
n_last<- 4
dirty3<-dirty2 %>%
  mutate(
    ONS_ID = as.numeric(substr(dirty2$name, nchar(dirty2$name) - n_last + 1, nchar(dirty2$name))))

#filter Ottawa hoods based on ONS_ID and drop NA cases
clean<- dirty3[dirty3$ONS_ID < 3400,] %>%
  na.omit(clean)


#write CSV
filename2 <- paste0("outputs/clean_ses_rawdata-", Sys.Date(),".csv")
readr::write_csv(clean, filename2)
message("Results saved to ", filename2)


calculate_ses_indices <- function(raw_data_filename = "data/PQ data/RAW_Census_Profile_2021_Gen3 - Copy.csv", num_den_filename = "data/PQ data/pq_data_dictionary_census_profile.csv"){
  nameoffile <- "pq_general_census_profile"
  # Importing the raw 2021 census data
  message("Loading census data: ", raw_data_filename)  
  raw_data_long <- readr::read_csv(raw_data_filename, col_types = readr::cols())
  
  # Importing the CSV file with SES index, numerator and denominator
  message("Loading SES index numerator/denominator data: ", num_den_filename)
  num_den <- readr::read_csv(num_den_filename, col_types = readr::cols())
  
  
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
  
  message("Processing input data...")
  data_pivoted <- raw_data_long |>
    janitor::clean_names() |>
    dplyr::select(-age_33p) |>
    tidyr::pivot_longer(cols = -"data_id") |> 
    tidyr::pivot_wider(names_from = data_id, values_from = value) |>
    dplyr::mutate(dplyr::across(-"name", as.numeric)) |> 
    suppressWarnings()
  
  
  # set up a tibble that will contain our results. one row per region
  results <- dplyr::select(data_pivoted, name)
  
  message("Calculating SES indices:")
  # loop through all ses indices in the dictionary
  for (i in 1:nrow(num_den)) {
    
    # extract the metadata for the index we are computing right now
    variables <- num_den[i,]
    variables_name <- variables$`variables`
    
    # get the column names/indices.
    # we keep the raw denominator index for comparison later to see is it a true
    # index, or if are we just using the number 1 as our denominator
    
    numerator_index <- variables$Numerator
    num_index <- paste0("ID", numerator_index)
    
    # check to see if the numerator contains non-numeric values, meaning it is
    # a "compound numerator" made up of other 
    if (suppressWarnings(is.na(as.numeric(numerator_index)))) {
      data_pivoted <- create_synthetic_numerator(data_pivoted = data_pivoted, numerator_index = numerator_index, num_index = num_index)
    }
    
    
    
    den_index_raw <- variables$Denominator
    den_index <- paste0("ID", den_index_raw)
    
    # print an update to the console
    message( "    ", i, ": ", variables_name)
    
    # calculate the index and put it in a tibble called result
    
    # if the denominator index is a number, we use it as expected
    if (!suppressWarnings(is.na(as.numeric(den_index_raw, warn = FALSE)))){
      
      ## this bit of code uses metaprogramming in R -- if you want to use a variable
      ## to select a column it takes some magic. That's what the {{ embraced }}
      ## variable does, the := operator, and the !!rlang::sym() call.
      ## you can read all about it here! https://adv-r.hadley.nz/metaprogramming.html
      result <- data_pivoted |>
        dplyr::transmute(name,  {{variables_name}} := !!rlang::sym(num_index) / !!rlang::sym(den_index)) |>
        janitor::clean_names()
      
    } else {
      # otherwise, if the denominator index is NOT a number, the denominator should just be 1
      
      result <- data_pivoted |>
        dplyr::transmute(name,  {{variables_name}} := !!rlang::sym(num_index) ) |>
        janitor::clean_names()
    }
    
    # add our result (this new index) to our results (table with all indices)
    results <- dplyr::left_join(results, result, by = "name")
  }
  
  
  
  
  ## results can now be written to file
  
  
  filename <- paste0("outputs/",nameoffile,Sys.Date(),".csv")
  readr::write_csv(results, filename)
  message("Results saved to ", filename)
  
  return(results)
}





create_synthetic_numerator <- function( data_pivoted, numerator_index,  num_index) {
  
  indices <- stringr::str_split(numerator_index, "\\D") |> 
    unlist() |>
    (function(x) {paste0("ID", x)})()
  
  operators <- stringr::str_split(numerator_index, "\\d+") |> 
    unlist() |>
    grep(pattern = ".+", value = TRUE)
  
  # this is similar to a functional reduce, but we're using a for loop to
  # keep things a bit conceptually simpler
  # set up our initial left-hand side
  lhs <- data_pivoted[,indices[[1]], drop=TRUE]
  
  for (temp_index in 2:length(indices)) {
    rhs <- data_pivoted[,indices[[temp_index]], drop=TRUE]
    
    operator_name <- operators[[temp_index-1]]
    
    operator <- NA
    if (operator_name == "+") operator <- `+`
    if (operator_name == "-") operator <- `-`
    if (suppressWarnings(is.na(operator))) stop ("Unknown operator: ", operator_name)
    
    lhs <- operator(lhs, rhs)
    
  } # end for temp_index in 2:length(indices) 
  
  data_pivoted[, num_index]  <- lhs
  
  return(data_pivoted)
  
}
