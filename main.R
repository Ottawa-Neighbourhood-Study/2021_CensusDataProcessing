# SOCIO-ECONOMIC INDICATORS FOR THE OTTAWA NEIGHBOURHOOD STUDY
#
# R script to create socio-economic status (SES) indices using census data and
# user-defined index definitions for the Ottawa Neighbourhood Study (ONS).
#
# HOW TO USE THIS SCRIPT
# 
# The only function you need to run is calculate_ses_indices(). It takes two
# optional inputs which tell it where two important input files are:
#   raw_data_filename tells it where to find the census data. By default it points
#                     to a file from StatsCan in the data folder. 
#   num_den_filename  tells it where the find the file that defines the indices,
#                     by giving their numerators and denominators. This file must
#                     be in .csv format with three columns: 
#                     * `SES Index` giving a human-readable name; 
#                     * `Numerator` giving either a number corresponding to the 
#                                   ID value of the numerator, OR a series of
#                                   numbers with `+` or `-` between them showing
#                                   which columns should be added or subtracted;
#                     * `Denominator` giving a numer corresponding to the ID value
#                                     of the denominator, OR any non-number (the
#                                     word `ONE` is recommended) if the denominator
#                                     should be the number 1.
#                     The default for `num_den_filename` points to the file 
#                     `SES indexes.csv` in the data folder.
#
# All the details are in the file `functions.R` in the r folder.
#
# Outputs are saved in the `outputs` folder in files stamped with today's date.

# load the functions
source("r/functions.R")

# calculate indices, save them to file in the "outputs" folder, and return results
results <- calculate_ses_indices()
