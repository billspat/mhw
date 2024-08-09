% mhw_export_text.m
% MATLAB code to open outputs from MHW matlab processes and save as CSV for database import and use by R
%
% Pat Bills, based on work from Dr. Lala Kounta
cd /mnt/research/plz-lab/DATA/ClimateData/MHW_metrics/
% load and save coordinate index tables as text fils
load('coordonnates_SSP.mat')
writematrix(lon_SSP, 'lon_SSP.txt')
writematrix(lat_SSP, 'lat_SSP.txt')
writematrix(wA, 'wA.txt')

% load all detection data files and save the time intervals "MHW" objects in them
% note these files are Matlab 2016 and later version (HDF5) and can't be 
% opened easily in R 

dirfiles = dir('**/*.mat');
for idx = 1:numel(dirfiles)
  dirfile = dirfiles(idx)
  f = strcat(dirfile.folder, dirfile.name)
  load(f,'MHW');
  mhwfile = strcat(f, '.mhw.csv'); 
  disp(mhwfile)
  writetable(MHW, mhwfile);
end

% load and save climatology files used for thresholding
% note that these matrices are the same in all the files above, 

load('ARISE-1.0/MHW_metrics_Model_001.mat')
writematrix(m90, 'm90.csv')
writematrix(mclim, 'mclim.csv')
writematrix(mhw_ts, 'mclim.csv')



