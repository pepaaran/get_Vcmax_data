# Read Vcmax25 data

# This function reads the relevant Vcmax25 data from
# the Atkin et al. 2015 GlobResp dataset and returns
# a data.frame of Vcmax25 observations per site and species
# with the same units that the P-model uses

read_vcmax25 <- function(
    filename = "data-raw/GlobResp database_Atkin et al 2015_New Phytologist.csv"
    ){

  # Read csv
  df <- read.csv(filename)

  # Select relevant variables
  df <- df[, c("site", "lat", "lon", "z",
               "species", "Family", "Vcmax25")]

  # Remove NAs
  df <- df[!is.na(df$Vcmax25), ]

  # Change Vcmax units to mol C m^{-2} d^{-1}
  df$Vcmax25 <- df$Vcmax25*(10^6)

  # Rename variables
  colnames(df) <- c("sitename", "lat", "lon", "elv",
                    "species", "family", "Vcmax25")

  df
}
