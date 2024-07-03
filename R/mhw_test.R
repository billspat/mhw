#'test reading MWH output files: mhw_test.R

#' Marine Heat Wave Project
#' test/exploration reading Dr. Kounta's Matlab output and plotting

library(R.matlab)



mhw_matlab2df <- function(mhwFilePath, mhwStatName = "MHW.max.C"){

   mhwStatsMatlab <- readMat(mhwFilePath)
   s <- mhwStatsMatlab[[mhwStatName]]

   
   rownames(s) <- mhwStatsMatlab$lon
   colnames(s) <- mhwStatsMatlab$lat
   # latLon.df <- data.frame(col = rep(colnames(s), each = nrow(s)), 
   #            row = rep(rownames(s), ncol(s)), 
   #            value = as.vector(s))
   
   latLon.df <- data.frame(lat = rep(colnames(s), each = nrow(s)), 
                           lon = rep(rownames(s), ncol(s)), 
                           x = as.vector(s))
   
   names(latLon.df)<- c("lat", "lon", mhwStatName)
   
   return(latLon.df)
   
}

globeMHWStat<- function(mhwFilePath){
  latlon.df <- mhw_matlab2df(m)
  
}


quicktest <-function( L1 = '/mnt/research/ibeem/climate_mhw/L1/',
                      test_folder = 'ARISE-10/2040-2069/max_metrics', 
                      test_file = 'Model_005_MHW_MAX_int_Year_cat_SSP245.mat', 
                      mhwStatName = "MHW.max.C") {
  
  mhwFilePath <- file.path(L1, test_folder, test_file) 
  global.df <- mhw_matlab2df(mhwFilePath, mhwStatName)
  return(global.df)
  
}