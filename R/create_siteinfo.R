# Create siteinfo data.frame

# This functions creates the siteinfo data.frame used to collect
# P-model drivers for a set of sites with Vcmax data

create_siteinfo <- function(df){
  # Remove duplicates of site data
  df |>
    dplyr::group_by(site) |>
    dplyr::summarise(lon = unique(lon),
                     lat = unique(lat),
                     elv = unique(elv)) |>
    dplyr::rename(sitename = site)
}
