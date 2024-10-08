-- build_historical.db
-- add table of historical data from matlab CSV exports

create table historical as
select *, '001' as ensemble, 'historical' as scenario from 'MHW_metrics_1980-1989_Model_001.mat.mhw.csv'
union
select *, '002' as ensemble, 'historical' as scenario from 'MHW_metrics_1980-1989_Model_002.mat.mhw.csv'
union
select *, '003' as ensemble, 'historical' as scenario from 'MHW_metrics_1980-1989_Model_003.mat.mhw.csv';

alter table historical add column lat DOUBLE;
alter table historical add column lon DOUBLE;

update historical set lat = lat_index.lat from lat_index where historical.yloc = lat_index.yloc ;
update historical set lon = lon_index.lon from lon_index where historical.xloc = lon_index.xloc ;
