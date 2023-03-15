# Aggregate WorldClim data by growing season mean

# This auxiliary function takes the growing season mean of variables
# tgrowth, vpd and ppfd for a single data.frame

get_growingseasonmean <- function(df){
  df |>
    filter(tgrowth > 0) |>
    ungroup() |>
    summarise(across(c(tgrowth, vpd, ppfd), mean))
}


# This function

