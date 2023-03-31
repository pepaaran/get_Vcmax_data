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
