% mhw_coordinates_export.m 
% MATLAB code to open outputs from MHW matlab processes and save as CSV for database import and use by R
% August 2024
% Pat Bills, based on work from Dr. Lala Kounta

% load and save coordinate index tables as text files for import into other systems
load('coordonnates_SSP.mat')
writematrix(lon_SSP, 'lon_SSP.txt')
writematrix(lat_SSP, 'lat_SSP.txt')
writematrix(wA, 'wA.txt')


