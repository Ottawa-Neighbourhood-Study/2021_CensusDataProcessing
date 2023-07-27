# DPLYR FUNCTIONS YOU MUST KNOW!!
# select
# mutate
# rename
# tibble
# (transmute)

add_six <- function(x){
  
  result <- x + 6
  return (result)
  
}


new_var_df <- raw_data_pivoted |>
  dplyr::transmute(name,
                   new_var = ID16 / ID17)

new_var_df |>
  dplyr::mutate(newer_var = get_value(new_var)) |>
  dplyr::rename(final_result = newer_var)

