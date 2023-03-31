# Helper functions to get data from WATCH-WFDEI + CRU + others
# based on ingestr

# Function to extract Water Holding Capacity
extract_whc <- function(file, siteinfo){

  siteinfo <- siteinfo[, c("lon", "lat")] |>
    unique()                                   # Remove repeated coordinates

  rasta <- raster::brick(file)

  raster::extract(
    rasta,                                            # raster object
    sp::SpatialPoints(siteinfo[, c("lon", "lat")]),   # points
    sp = TRUE                                         # add raster values to siteinfo
  ) |>
    tibble::as_tibble() |>
    dplyr::rename(whc = layer)
}

# Define function to aggregate forcing over day of year
aggregate_forcing_doy <- function(forcing){
  forcing |>
    dplyr::group_by(doy) |>
    summarise(date = first(date),                # 2001 as symbolic date
              temp = mean(temp, na.rm = TRUE),
              rain = mean(rain, na.rm = TRUE),
              vpd = mean(vpd, na.rm = TRUE),
              ppfd = mean(ppfd, na.rm = TRUE),
              snow = mean(snow, na.rm = TRUE),
              co2 = mean(co2, na.rm = TRUE),
              fapar = mean(fapar, na.rm = TRUE),
              patm = mean(patm, na.rm = TRUE),
              tmin = mean(tmin, na.rm = TRUE),
              tmax = mean(tmax, na.rm = TRUE),
              ccov = mean(ccov, na.rm = TRUE)
    ) |>                               # already ungrouped
    dplyr::slice(1:365)                          # ignore leap years
}
