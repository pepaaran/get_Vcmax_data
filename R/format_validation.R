# Format validation Vcmax25 data

# This functions turns the tabular data from Atkin et al. 2015
# into P-model validation data. A single Vcmax25 value per site is obtained
# by taking the average over all species in that site. Uncertainties are
# computed as the standard deviation of Vcmax25 among species and if there is
# only one species, the average sd over all other sites is used.

format_validation <- function(df_vcmax){
  # Reduce to one value per site
  val_vcmax <- df_vcmax |>
    dplyr::group_by(sitename) |>
    dplyr::summarise(vcmax25 = mean(Vcmax25),
                     vcmax25_unc = sd(Vcmax25))

  # Fill uncertainty for single-species sites
  mean_uncertainty <- mean(val_vcmax$vcmax25_unc, na.rm = TRUE)

  val_vcmax |>
    tidyr::replace_na(
      replace = list(vcmax25_unc = mean_uncertainty)
    ) |>

  # Return nested object
    dplyr::group_by(sitename) |>
    tidyr::nest()
}
