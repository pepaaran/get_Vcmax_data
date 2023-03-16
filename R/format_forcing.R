# Expand yearly forcing into rsofun format

# This function is based on FluxDataKit::fdk_format_drivers()
# The default input values correspond to the p_model_drivers example dataset
format_forcing <- function(
    forcing_wc,
    site_info,
    params_siml = list(
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
      lgr4               = FALSE
    ),
    df_soiltexture = bind_rows(
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
    ),
    verbose = TRUE){
  browser()
  # Expand forcing to 365 days and get into nested format
  drivers <- forcing_wc |>
    dplyr::mutate(lon = NULL, lat = NULL, elv = NULL) |>
    dplyr::slice(rep(1:n(), each = 365)) |>
    dplyr::group_by(sitename) |>
    tidyr:: nest() |>
    dplyr::rename(forcing = data)

  # Join with params_siml
  drivers$params_siml <-  list(as_tibble(params_siml))

  # Join with site_info
  drivers <- drivers |>
    dplyr::left_join(
      site_info |>
        dplyr::group_by(sitename) |>
        tidyr::nest() |>
        dplyr::rename(site_info = data),
      by = 'sitename'
    )

  # Join with params_soil
  drivers$params_soil <- list(df_soiltexture)

  # Return output (P-model drivers)
  drivers
}
