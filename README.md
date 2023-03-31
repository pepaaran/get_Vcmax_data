# Get Vcmax25 data to run P-model

This repository contains the code used to retrieve the Vcmax25 data used for validation of the P-model as implemented in [`rsofun`](https://github.com/geco-bern/rsofun). Furthermore, it creates the respective forcing data to run the P-model, either from the WorldClim dataset (resulting dataset is incomplete to run the P-model) or from WATCH-WFDEI + others (see [this vignette](https://github.com/pepaaran/ingestr/blob/master/vignettes/get_drivers_coordinates.Rmd) for details). The final products are two `rsofun` nested dataframes, the drivers and validation Vcmax25 data.

The following code creates the objects `p_model_drivers_vcmax25` and
`p_model_validation_vcmax25` from the raw data:

```{r}
# Load libraries
library(dplyr); library(tidyr);
library(tibble); library(raster);
if(!require(devtools)){install.packages("devtools")}
devtools::install_github("pepaaran/ingestr")
library(ingestr)

# Load functions
source("R/read_vcmax25.R")
source("R/create_siteinfo.R")
source("R/aggregate_growingseasonmean.R")
source("R/format_forcing.R")
source("R/format_validation.R")
source("R/get_vcmax_data_rsofun.R")

# Get Vcmax25 data + average year forcing
get_vcmax_data_rsofun(
  source = "watch-wfdei"
) # Use default data archive file paths

# The outputs are saved in the `data` directory

# Incomplete: Get Vcmax25 data + WorldClim drivers into rsofun format
# using the data archive structure on the GECO workstations
get_vcmax_data_rsofun(
  source = "worldclim",
  file_vcmax = "data-raw/GlobResp database_Atkin et al 2015_New Phytologist.csv",
  path_worldclim = "/data/archive/worldclim_fick_2017/data"
)
```

The WorldClim data can be obtained from https://worldclim.org/data/worldclim21.html
and the [GlobResp](https://nph.onlinelibrary.wiley.com/doi/full/10.1111/nph.13364)
leaf traits data from [Atkin et al. 2015](https://nph.onlinelibrary.wiley.com/doi/10.1111/nph.13253)
via the [TRY database](https://www.try-db.org/de/Datasets.php). Other data sources are described
in [the GECO data archive repository](https://github.com/geco-bern/data_management).

The [ingestr](https://github.com/geco-bern/ingestr) package is used extract 
forcing data for the leaf trait sites and the data aggregation follows
the instructions in the [Run the P-model for point simulations](https://geco-bern.github.io/ingestr/articles/run_pmodel_points.html)
vignette. The data formatting functions are
inspired by the [FluxDataKit](https://github.com/geco-bern/FluxDataKit) package.
[This vignette](https://github.com/pepaaran/ingestr/blob/master/vignettes/get_drivers_coordinates.Rmd)
goes through the workflow implemented in the functions used above, step by step.

## Structure

The structure of the repository is as follows:

### The R folder

The `R` folder contains all R functions used to read, aggregate and format data.
The function `get_vcmax_data_rsofun()` is a wrapper of all other functions and
can be used to run the entire workflow, from the raw data path to the final
objects `p_model_drivers_vcmax25` and `p_model_validation_vcmax25`.

### The data-raw folder

The `data-raw` folder may be used to store the data files downloaded from the web.
In the GECO lab, the WorldClim data are available in our data archive (documented
[here](https://github.com/geco-bern/data_management). The data from Atkin et al. 2015
are stored in `data-raw` but not pushed to this repository (this folder is in the
`.gitignore`).

### The data folder

The `data` folder contains the output from the data processing. The objects
`p_model_drivers_vcmax25` and `p_model_validation_vcmax25` are stored here. 
Optionally, the intermediate objects created while ingesting the data are saved 
into `intermediate_data.RData` and can be used for analysis.

### The renv folder

This folder contains the files used by `renv` to manage the R packages used in
this repository. The `renv.lock` file contains information of the packages
currently used in the project and their version.

### The analysis folder

It contains R markdown files that explore the Vcmax25 data from GlobResp.
