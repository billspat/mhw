source("renv/activate.R")
if(Sys.getenv('HPCC_CLUSTER_FLAVOR')!='') {
  # load required MSU HPC Modules for spatial work
  source(file.path(Sys.getenv("LMOD_PKG"), "init/R"))
  module("load", "GEOS")
  module("load", "PROJ")
  module("load", "GDAL")
}
