# This script creates the p_model_drivers_vcmax25
# object for the rsofun package.
# The original data files were previously downloaded
# and stored in the folders specified in this script.

# Load libraries
library(dplyr)
library(tidyr)
library(tibble)
library(ingestr)
library(raster)
library(ggplot2)

if(!require(devtools)){install.packages(devtools)}
devtools::install_github("pepaaran/ingestr")
library(ingestr)

# Load functions
source("R/read_vcmax25.R")
source("R/create_siteinfo.R")

#---- Get siteinfo ----

# Get Vcmax25 data
data_vcmax <- read_vcmax25(
  filename = file_vcmax
)

# Create site information data.frame
siteinfo <- create_siteinfo(data_vcmax)

#---- Complete siteinfo with water holding capacity ----

# Define function to extract whc
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

# Get WHC data
path_whc <- "/data/archive/whc_stocker_2021/data"

df_whc <- extract_whc(file = paste0(path_whc, "/cwdx80.nc"),
                      siteinfo = siteinfo)

# Merge whc with site information
siteinfo <- dplyr::left_join(
  siteinfo,
  df_whc,
  by = c("lon", "lat")
)

# Fill gaps by median value (here there are no NAs)
siteinfo$whc[is.na(siteinfo$whc)] <- median(siteinfo$whc,
                                            na.rm = TRUE)

#---- Get forcing from data archive ----

# Get WATCH data
path_watch <- "/data/archive/wfdei_weedon_2014/data"
path_worldclim <- "/data/archive/worldclim_fick_2017/data" # for debiasing

df_watch <- ingestr::ingest(
  siteinfo = siteinfo,
  source = "watch_wfdei",
  getvars = c("temp", "prec", "ppfd", "vpd", "patm"),
  dir = path_watch,
  settings = list(
    correct_bias = "worldclim",    # 0.5 deg
    dir_bias = path_worldclim
  )
) |>
  suppressWarnings() |> suppressMessages()
# Variables tmin and tmax missing but not currently in use

# Memory intensive, purge memory
gc()

# Get CRU data
path_cru <- "/data/archive/cru_NA_2021/data/"

df_cru <- ingestr::ingest(
  siteinfo = siteinfo,
  source = "cru",
  getvars = c("ccov"),
  dir = path_cru,
  settings = list(
    correct_bias = NULL       # 0.5 deg resolution
  )
)

#---- Download CO2 data ----

df_co2 <- read.csv(
  url("https://gml.noaa.gov/webdata/ccgg/trends/co2/co2_annmean_mlo.csv"),
  skip = 59) |>
  dplyr::select(year, mean) |>
  dplyr::rename(co2 = mean)

#---- Merge meteorological forcing ----

# Merge WATCH and CRU data
df_meteo <- df_watch |>
  tidyr::unnest(data) |>
  left_join(
    df_cru |>
      tidyr::unnest(data),
    by = c("sitename", "date")
  ) |>
  dplyr::ungroup() |>                         # keep unnested
  dplyr::mutate(tmin = temp,                  # placeholders for variables tmin and tmax
                tmax = temp) |>               # (not used in P-model runs)
  dplyr::mutate(doy = lubridate::yday(date))  # add day of year

# Merge CO2 with meteo drivers
df_meteo <- df_meteo |>
  dplyr::mutate(year = lubridate::year(date)) |>
  dplyr::left_join(df_co2, by = "year")            # keep unnested

# Add fapar column with value 1
df_meteo <- df_meteo |>
  dplyr::mutate(fapar = 1)

# Nest forcing
df_meteo <- df_meteo |>
  dplyr::group_by(sitename) |>
  tidyr::nest() |>
  dplyr::rename(forcing = data) |>
  dplyr::ungroup()

#---- Aggregate forcing across years ----

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

# Compute aggregated drivers
df_meteo <- df_meteo |>
  dplyr::mutate(forcing =
                  lapply(df_meteo$forcing, aggregate_forcing_doy))

#---- Format nested data

# Define default model parameters, soil data, etc
params_siml <- list(
  spinup             = TRUE,  # to bring soil moisture to steady state
  spinupyears        = 10,    # 10 is enough for soil moisture.
  recycle            = 1,     # number of years recycled during spinup
  soilmstress        = FALSE, # soil moisture stress function is included
  tempstress         = FALSE, # temperature stress function is included
  calc_aet_fapar_vpd = FALSE, # set to FALSE - should be dropped again
  in_ppfd            = TRUE,  # if available from forcing files, set to TRUE
  in_netrad          = FALSE, # if available from forcing files, set to TRUE
  outdt              = 1,
  ltre               = FALSE,
  ltne               = FALSE,
  ltrd               = FALSE,
  ltnd               = FALSE,
  lgr3               = TRUE,
  lgn3               = FALSE,
  lgr4               = FALSE,
  firstyeartrend     = 2001,  # first year of running the model
  nyeartrend         = 15     # number of years running the model
)

df_soiltexture <- bind_rows(
  top    = tibble(
    layer = "top",
    fsand = 0.4,
    fclay = 0.3,
    forg = 0.1,
    fgravel = 0.1),
  bottom = tibble(
    layer = "bottom",
    fsand = 0.4,
    fclay = 0.3,
    forg = 0.1,
    fgravel = 0.1)
)

# Nest site information
df_siteinfo <- siteinfo |>
  dplyr::group_by(sitename) |>
  tidyr::nest() |>
  dplyr::rename(site_info = data) |>
  dplyr::ungroup()

# Finally put it all into drivers object
p_model_drivers_vcmax25 <- df_meteo |>
  dplyr::left_join(df_siteinfo,
                   by = "sitename")

p_model_drivers_vcmax25$params_siml <- list(dplyr::as_tibble(params_siml))
p_model_drivers_vcmax25$params_soil <- list(df_soiltexture)

#---- Save p_model_drivers_vcmax25 ----

save(p_model_drivers_vcmax25, file = "data/p_model_drivers_vcmax25.rda")
