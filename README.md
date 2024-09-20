### mhwci: Marine Heat Wave for Climate Intervention

*R package for database and analysis 'Marine Heat Waves during Climate Change & Climate Intervention' (in prep)*

Authors:

-   Lala Kounta
-   Pat Bills
-   Phoebe Zarnetske

## Overview

Continuation of Dr. Lala Kounta's project <https://github.com/srm-ecology/MHW_climateintervention>

Uses the EDI data frame work (more to come)

## Requirements/Install

For most code to work, there must be a database created from Matlab work from L0 level files. Build instructions are forthcoming, but see files in `matlab` and `db` folder

The database is in [duckdb](https://duckdb.org) format, an open source, in-process columnar database for analytics. The climate data prepared will create a database with tables with over 20M rows.

By default, the code looks for this database the file `db/mhwmetrics.duckdb` but the path to the database you would like can be sent to function `mhw_connect(path/to/database.duckdb)` or set in the environment as `$MHWDBFILE`

This uses the 'terra' package for geospatial operations. However this require the gdal library to be installed and available on your system. See <https://github.com/rspatial/terra> for instructions on installing terra and gdal on your system (especially for MacOS using homebrew). Note that most HPC systems have gdal installed and can be loaded the "module system" (eg. lmod) and must be loaded first.

### Usage on MSU HPC

When running on your own computer, you install the software you need.  The MSU HPC uses the ['module system'](https://docs.icer.msu.edu/Intro_to_modules/) to select software already installed.  This application requires the following modules to be loaded: 

R/4.3.2-gfbf-2023a: specific to MSU, this R module also loads many packages

`module load UDUNITS, GEOS, PROJ, GDAL`

Note these are all uppercase and there are versions compatible with R installed. 

To avoid having to load these everytime, you can create a file `.Rprofile` with the following in it: 

```R
if(Sys.getenv('HPCC_CLUSTER_FLAVOR')!='') {
  # load required MSU HPC Modules for spatial work
  source(file.path(Sys.getenv("LMOD_PKG"), "init/R"))
  module("load", "UDUNITS")
  module("load", "GEOS")
  module("load", "PROJ")
  module("load", "GDAL")
}
```
  
This will only run if you are running on the MSU HPC and load the modules needed when R starts up. 

IF you are also using the [`renv`](https://rstudio.github.io/renv/articles/renv.html) system to create an R Environment to manage packages for this project then you may already have a file `.Rprofile` and if you add modules they must come before the renve activate commands.   Most projects do not put the .Rprofile file into git but this one does to share the module load commands. 


## Basic Usage

