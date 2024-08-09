# mhw_matlab_detection.R

# abandonded code
# these functions were to be able to open Matab files > 2016 version files
# created by the MHW detection process Lala Kounta. 
# it's more efficient to read and export from Matlab which includes the column headings
# see matlab/mhw_export_text.m 

# library(hdf5r)
# source('mhw_matlab.R')
# 
# open_mhw_detection<-function(mhw_file=TESTFILE){
#   # print info
#   h5f = H5File$new(mhw_file, mode='r')
#   d<- h5f$open("MHW")
#   mhw<- h5f$read(d)
#   return(mhw)
#   
# }
