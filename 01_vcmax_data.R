# This script reads and cleans Vcmax25 data from Atkin et al

# Load functions
source("R/read_vcmax25.R")
source("R/create_siteinfo.R")

# Load libraries
library(dplyr)
library(tidyr)

# Get Vcmax25 data
validation_vcmax <- read_vcmax25(
  filename = "data-raw/GlobResp database_Atkin et al 2015_New Phytologist.csv"
)

# Create site information data.frame
siteinfo <- create_siteinfo(validation_vcmax)
