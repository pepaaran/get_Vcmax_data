# Aggregate WorldClim data by growing season mean

# This auxiliary function takes the growing season mean of variables
# tgrowth, vpd and ppfd for a single data.frame

get_growingseasonmean <- function(df){
  df |>
    filter(tgrowth > 0) |>
    ungroup() |>
    summarise(across(c(tgrowth, vpd, ppfd), mean))
}


# This function takes the site information data.frame and the
# WorldClim nested data.frame and merges them, changes the
# variable units, computes PPFD and VPD, aggregates WorldClim
# variables over the growing season (base on tmin and tmax)
# and sets generic values for co2 and fAPAR. It returns a nested
# data.frame in the rsofun input format.

aggregate_growingseasonmean <- function(df_wc, df_sites){
  kfFEC <- 2.04

  df_wc |>

    unnest(data) |>

    ## add latitude
    left_join(df_sites, by = "sitename") |>

    ## vapour pressure kPa -> Pa
    mutate(vapr = vapr * 1e3) |>

    ## PPFD from solar radiation: kJ m-2 day-1 -> mol m−2 s−1 PAR
    mutate(ppfd = 1e3 * srad * kfFEC * 1.0e-6 / (60 * 60 * 24)) |>

    ## calculate VPD (Pa) based on tmin and tmax
    rowwise() |>
    mutate(vpd = calc_vpd(eact = vapr, tmin = tmin, tmax = tmax)) |>

    ## calculate growth temperature (average daytime temperature)
    mutate(doy = lubridate::yday(lubridate::ymd("2001-01-15") + months(month - 1))) |>
    mutate(tgrowth = ingestr::calc_tgrowth(tmin, tmax, lat, doy)) |>

    ## average over growing season (where Tgrowth > 0 deg C)
    group_by(sitename) |>
    nest() |>
    mutate(data_growingseason = purrr::map(data, ~get_growingseasonmean(.))) |>
    unnest(data_growingseason) |>
    select(-data) |>

    ## since we don't know the year of measurement (often), we assume a "generic" concentration (ppm)
    mutate(co2 = 380) |>

    ## we're interested not in ecosystem fluxes, but in leaf-level quantities
    ## therefore, apply a "dummy" fAPAR = 1
    mutate(fapar = 1.0) |>

    ## add elevation (elv)
    left_join(df_sites, by = "sitename")
}

