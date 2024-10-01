-- create tables for SSP-245 decade-limited metrics
-- requires build_mhw_db.sql scripts to run first


create table ssp245_decade_metrics as
SELECT *, '001' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2015-2024_Model_001.mat.mhw.csv
 union
SELECT *, '002' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2015-2024_Model_002.mat.mhw.csv
 union
SELECT *, '003' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2015-2024_Model_003.mat.mhw.csv
 union
SELECT *, '004' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2015-2024_Model_004.mat.mhw.csv
 union
SELECT *, '005' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2015-2024_Model_005.mat.mhw.csv
 union
SELECT *, '006' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2015-2024_Model_006.mat.mhw.csv
 union
SELECT *, '007' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2015-2024_Model_007.mat.mhw.csv
 union
SELECT *, '008' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2015-2024_Model_008.mat.mhw.csv
 union
SELECT *, '009' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2015-2024_Model_009.mat.mhw.csv
 union
SELECT *, '010' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2015-2024_Model_010.mat.mhw.csv
 union
SELECT *, '001' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2025-2034_Model_001.mat.mhw.csv
 union
SELECT *, '002' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2025-2034_Model_002.mat.mhw.csv
 union
SELECT *, '003' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2025-2034_Model_003.mat.mhw.csv
 union
SELECT *, '004' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2025-2034_Model_004.mat.mhw.csv
 union
SELECT *, '005' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2025-2034_Model_005.mat.mhw.csv
 union
SELECT *, '006' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2025-2034_Model_006.mat.mhw.csv
 union
SELECT *, '007' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2025-2034_Model_007.mat.mhw.csv
 union
SELECT *, '008' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2025-2034_Model_008.mat.mhw.csv
 union
SELECT *, '009' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2025-2034_Model_009.mat.mhw.csv
 union
SELECT *, '010' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2025-2034_Model_010.mat.mhw.csv
 union
SELECT *, '001' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2040-2049_Model_001.mat.mhw.csv
 union
SELECT *, '002' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2040-2049_Model_002.mat.mhw.csv
 union
SELECT *, '003' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2040-2049_Model_003.mat.mhw.csv
 union
SELECT *, '004' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2040-2049_Model_004.mat.mhw.csv
 union
SELECT *, '005' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2040-2049_Model_005.mat.mhw.csv
 union
SELECT *, '006' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2040-2049_Model_006.mat.mhw.csv
 union
SELECT *, '007' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2040-2049_Model_007.mat.mhw.csv
 union
SELECT *, '008' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2040-2049_Model_008.mat.mhw.csv
 union
SELECT *, '009' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2040-2049_Model_009.mat.mhw.csv
 union
SELECT *, '010' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2040-2049_Model_010.mat.mhw.csv
 union
SELECT *, '001' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2050-2059_Model_001.mat.mhw.csv
 union
SELECT *, '002' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2050-2059_Model_002.mat.mhw.csv
 union
SELECT *, '003' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2050-2059_Model_003.mat.mhw.csv
 union
SELECT *, '004' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2050-2059_Model_004.mat.mhw.csv
 union
SELECT *, '005' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2050-2059_Model_005.mat.mhw.csv
 union
SELECT *, '006' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2050-2059_Model_006.mat.mhw.csv
 union
SELECT *, '007' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2050-2059_Model_007.mat.mhw.csv
 union
SELECT *, '008' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2050-2059_Model_008.mat.mhw.csv
 union
SELECT *, '009' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2050-2059_Model_009.mat.mhw.csv
 union
SELECT *, '010' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2050-2059_Model_010.mat.mhw.csv
 union
SELECT *, '001' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2060-2069_Model_001.mat.mhw.csv
 union
SELECT *, '002' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2060-2069_Model_002.mat.mhw.csv
 union
SELECT *, '003' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2060-2069_Model_003.mat.mhw.csv
 union
SELECT *, '004' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2060-2069_Model_004.mat.mhw.csv
 union
SELECT *, '005' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2060-2069_Model_005.mat.mhw.csv
 union
SELECT *, '006' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2060-2069_Model_006.mat.mhw.csv
 union
SELECT *, '007' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2060-2069_Model_007.mat.mhw.csv
 union
SELECT *, '008' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2060-2069_Model_008.mat.mhw.csv
 union
SELECT *, '009' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2060-2069_Model_009.mat.mhw.csv
 union
SELECT *, '010' AS ensemble, 'SSP-245' AS scenario FROM 'SSP-245/2015-2069/'MHW_metrics_2060-2069_Model_010.mat.mhw.csv;

alter table  ssp245_decade_metricsadd column mhw_onset_date DATE;
alter table  ssp245_decade_metricsadd column mhw_end_date DATE;

update  ssp245_decade_metricsset mhw_onset_date = cast(strptime(cast(mhw_onset as varchar), '%Y%m%d') as date) , 
                      mhw_end_date = cast(strptime(cast(mhw_end as varchar), '%Y%m%d') as date);


alter table  ssp245_decade_metricsadd column lat DOUBLE;
alter table  ssp245_decade_metricsadd column lon DOUBLE;

update  ssp245_decade_metricsset lat = lat_index.lat from lat_index where  arise10_decade_metrics.yloc = lat_index.yloc ;
update  ssp245_decade_metricsset lon = lon_index.lon from lon_index where  arise10_decade_metrics.xloc = lon_index.xloc ;

create index arise15_onset_date_idx on  ssp245_decade_metrics(mhw_onset_date);
create index arise15_end_date_idx on  ssp245_decade_metrics(mhw_end_date);

create index arise15_lat_lon_idx on  ssp245_decade_metrics(lat, lon);