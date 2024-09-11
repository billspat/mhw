% load and save climatology files used for thresholding
% note that these matrices are the same in all the files above, 

load('ARISE-1.0/MHW_metrics_Model_001.mat')
writematrix(m90, 'm90.csv')
writematrix(mclim, 'mclim.csv')
writematrix(mhw_ts, 'mclim.csv')