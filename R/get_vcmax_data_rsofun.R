# From raw data to P-model input and validation data - OLD VERSION

# This function reads the raw Vcmax25 and climate data from
# the given (full) paths, collects the relevant information and creates
# p_model_drivers and p_model_validation objects used to
# run and calibrate the P-model with `rsofun`. The resulting objects
# are saved in the `data` folder.

get_vcmax_data_rsofun <- function(
    file_vcmax,
    path_worldclim,
    save_intermediate_data = FALSE){

  # Get Vcmax25 data
  data_vcmax <- read_vcmax25(
    filename = file_vcmax
  )

  # Create site information data.frame
  siteinfo <- create_siteinfo(data_vcmax)

  # Get WorldClim data using ingestr
  df_wc <- ingestr::ingest(
    siteinfo,
    source    = "worldclim",
    settings = list(varnam = c("tmin", "tmax", "vapr", "srad", "prec", "tavg")),
    dir       = path_worldclim
  )

  # Aggregate climatic variables over growing season into a single
  # yearly value, and format as p_model_drivers
  forcing <- aggregate_growingseasonmean(
    df_wc = df_wc,
    df_sites = siteinfo
  )

  # Format drivers
  p_model_drivers_vcmax25 <- format_forcing(forcing, siteinfo)

  # Format validation
  p_model_validation_vcmax25 <- format_validation(data_vcmax)

  # Save intermediate objects
  if(save_intermediate_data) save(data_vcmax, siteinfo, df_wc, forcing,
                                  file = "data/intermediate_data.RData")

  # Save p_model_drivers and p_model_validation objects
  save(p_model_drivers_vcmax25, file = "data/p_model_drivers_vcmax25.rda")
  save(p_model_validation_vcmax25, file = "data/p_model_validation_vcmax25.rda")
}
