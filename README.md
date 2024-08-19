## this was abandoned due to issues installing the 'terra' package and most work has continued in the folder `../mhw` 

**mhwci: Marine Heat Wave for Climate Intervention**

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

## Basic Usage

