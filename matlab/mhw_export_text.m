% mhw_export_text.m
% MATLAB code to open outputs from MHW matlab processes and save as CSV
% for import into other systems
% Pat Bills, based on work from Dr. Lala Kounta
% requires modern version of Matlab, tested on with 2023b
% assumes certain file name structure, only works with files with '.mat' extension
% v1 initial version July 2024
% v2 focus on single folder of metrics only Sept 2024


% load all detection data files and save the time intervals "MHW" objects in them
% note these files are Matlab 2016 and later version (HDF5) and can't be 
% opened easily in R 

% make sure to run this is a directory where matlab files are, not the parent folder. 
% e.g. cd <datadir>
dirfiles = dir('*.mat');
% adjust this for computer you are using 
cores = 10
pool = parpool(cores)
parfor idx = 1:numel(dirfiles)
  dirfile = dirfiles(idx)
  f = strcat(dirfile.name)
  mhwdata = load(f,'MHW');
  mhwfile = strcat(f, '.mhw.csv'); 
  disp(mhwfile)
  writetable(mhwdata.MHW, mhwfile);
end

delete(pool)




