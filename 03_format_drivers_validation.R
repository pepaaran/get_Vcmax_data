# This script takes the Vcmax25 and forcing data and creates p_model_drivers
# and p_model_validation objects to run the rsofun calibration

# Load functions
source("R/format_forcing.R")
source("R/format_validation.R")

# Format drivers
p_model_drivers_vcmax25 <- format_forcing(forcing, siteinfo)

# Format validation
p_model_validation_vcmax25 <- format_validation(data_vcmax)
