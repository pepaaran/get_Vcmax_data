# This script runs the full workflow to extract Vcmax25 site information and
# the corresponding drivers to run the P-model, from WorldClim data.
# Based on the GECO data archive structure

# Load functions
source("R/aggregate_growingseasonmean.R")

# Load libraries
if(!require(devtools)){install.packages("devtools")}
devtools::install_github("geco-bern/ingestr")
library(ingestr)

library(dplyr)
library(tidyr)

# Get WorldClim data using ingestr
df_wc <- ingest(
  siteinfo,
  source    = "worldclim",
  settings = list(varnam = c("tmin", "tmax", "vapr", "srad")),
  dir       = "/data/archive/worldclim_fick_2017/data"  # workstation
)

# Aggregate climatic variables over growing season into a single
# yearly value, and format as p_model_drivers
forcing <- aggregate_growingseasonmean(
  df_wc = df_wc,
  df_sites = siteinfo
)
