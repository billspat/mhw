-- Marine Heatwave Analysis
-- Lala Kounta, Phoebe Zarnetske, Pat Bills, MSU
-- build mhw database from CSV files
-- assumes the following CSV files mentioned here are present as exported from matlab
-- data files 

create table ensembles (model char, ensemble char);
insert into ensembles values 
    ('ARISE-1.0', '001'),
    ('ARISE-1.0', '002'),
    ('ARISE-1.0', '003'),
    ('ARISE-1.0', '004'),
    ('ARISE-1.0', '005'),
    ('ARISE-1.0', '006'),
    ('ARISE-1.0', '007'),
    ('ARISE-1.0', '008'),
    ('ARISE-1.0', '009'),
    ('ARISE-1.0', '010');

create table mhw_metrics as 
    SELECT *, '001' AS ensemble FROM 'ARISE-1.0/MHW_metrics_Model_001.mat.mhw.csv'
    UNION
    SELECT *, '002' AS ensemble FROM 'ARISE-1.0/MHW_metrics_Model_002.mat.mhw.csv'
    UNION
    SELECT *, '003' AS ensemble FROM 'ARISE-1.0/MHW_metrics_Model_003.mat.mhw.csv'
    UNION
    SELECT *, '004' AS ensemble FROM 'ARISE-1.0/MHW_metrics_Model_004.mat.mhw.csv'
    UNION
    SELECT *, '005' AS ensemble FROM 'ARISE-1.0/MHW_metrics_Model_005.mat.mhw.csv'
    UNION
    SELECT *, '006' AS ensemble FROM 'ARISE-1.0/MHW_metrics_Model_006.mat.mhw.csv'
    UNION
    SELECT *, '007' AS ensemble FROM 'ARISE-1.0/MHW_metrics_Model_007.mat.mhw.csv'
    UNION
    SELECT *, '008' AS ensemble FROM 'ARISE-1.0/MHW_metrics_Model_008.mat.mhw.csv'
    UNION
    SELECT *, '009' AS ensemble FROM 'ARISE-1.0/MHW_metrics_Model_009.mat.mhw.csv'
    UNION
    SELECT *, '010' AS ensemble FROM 'ARISE-1.0/MHW_metrics_Model_010.mat.mhw.csv';

alter table mhw_metrics add column mhw_onset_date DATE;
alter table mhw_metrics add column mhw_end_date DATE;

update mhw_metrics set mhw_onset_date = cast(strptime(cast(mhw_onset as varchar), '%Y%m%d') as date) , 
                      mhw_end_date = cast(strptime(cast(mhw_end as varchar), '%Y%m%d') as date);

-- CREATE TABLE mhw_metrics(mhw_onset BIGINT, mhw_end BIGINT, mhw_dur BIGINT, int_max DOUBLE, int_mean DOUBLE, int_var DOUBLE, int_cum DOUBLE, xloc BIGINT, yloc BIGINT, ensemble VARCHAR, mhw_onset_date DATE, mhw_end_date DATE);

-- get lat and lon from matlab index file export.  Used to replace xloc with lon and yloc with lat
-- note the lat_ssp.csv is exported with "writematrix" which does not have a header row since writetable can't work with doubles

create table lat_index as select column0 as lat, row_number() OVER () as yloc from 'lat_ssp.csv';
create table lon_index as select column0 as lon, row_number() OVER () as xloc from 'lon_ssp.csv';

alter table mhw_metrics add column lat DOUBLE;
alter table mhw_metrics add column lon DOUBLE;

update mhw_metrics set lat = lat_index.lat from lat_index where mhw_metrics.yloc = lat_index.yloc ;
update mhw_metrics set lon = lon_index.lon from lon_index where mhw_metrics.xloc = lon_index.xloc ;


create index mhw_onset_date_idx on mhw_metrics (mhw_onset_date);
create index mhw_end_date_idx on mhw_metrics (mhw_end_date);

create index lat_lon_idx on mhw_metrics (lat, lon);

create table years (year integer);

create table decades (decade CHAR, decade_start DATE, decade_end DATE);
insert into  decades values 
    ('2040', DATE '2040-01-01', DATE '2049-12-31'),
    ('2050', DATE '2050-01-01', DATE '2059-12-31'), 
    ('2060', '2060-01-01', DATE '2069-12-31');


-- create table mclim as select * from 'mclim.csv'
