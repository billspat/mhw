# mhw_matlab.R
# Marine Heat Wave Project
# This is not used, but was an early experiment reading Dr. Kounta's Matlab output and plotting

library(R.matlab)
library(sf)
library(ggplot2)

# CONSTANTS
mhw_matlab2sf <- function(mhwFilePath, mhwStatName = "MHW.max.C"){

    # read matlab
   mhwStatsMatlab <- readMat(mhwFilePath)
   # select the column of stats requested
   s <- mhwStatsMatlab[[mhwStatName]]

   # to make it easy to create lat/lon columns use row/column names
   rownames(s) <- mhwStatsMatlab$lon
   colnames(s) <- mhwStatsMatlab$lat

   # convert matrix to long form
   latlon.df <- data.frame(lat = as.double(rep(colnames(s), each = nrow(s))), 
                           lon = as.double(rep(rownames(s), ncol(s))), 
                           x = as.vector(s))
   
   # assign col names inlcuding name of stat
   names(latlon.df)<- c("lat", "lon", mhwStatName)
   print(paste(nrow(latlon.df), "points"))
   # convert to geospatial object
   latlon.sf <- st_as_sf(latlon.df, coords = c('lon', 'lat'), crs=4326)
   
   return(latlon.sf)
   
}



quicktest <-function( L1 = '/mnt/research/ibeem/climate_mhw/L1/',
                      test_folder = 'ARISE-10/2040-2069/max_metrics', 
                      test_file = 'Model_005_MHW_MAX_int_Year_cat_SSP245.mat', 
                      mhwStatName = "MHW.max.C") {
  
  
  mhwFilePath <- file.path(L1, test_folder, test_file) 
  mhw.sf <- mhw_matlab2sf(mhwFilePath, mhwStatName)
  return(mhw.sf)
  
}


test_import_metrics <- function() {
  metrics_folder = '/mnt/research/plz-lab/DATA/ClimateData/MHW_metrics/'
  TESTFILE <-  file.path(metrics_folder,  'ARISE-1.0', 'MHW_metrics_Model_004.mat')
  
}

