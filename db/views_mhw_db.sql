


DROP VIEW IF EXISTS avg_duration_by_decade;
CREATE VIEW avg_duration_by_decade AS
SELECT 
    lat, 
    lon, 
    decade,
    avg(mhw_dur) 
FROM 
    mhw_metrics, decades 
WHERE 
    mhw_onset_date >= decades.decade_start and mhw_onset_date <= decades.decade_end
GROUP BY
   lat, lon, decade
;

DROP VIEW IF EXISTS avg_duration_by_decade_truncated;
CREATE VIEW avg_duration_by_decade_truncated AS
SELECT 
    lat, 
    lon, 
    decade,
    avg(
        IF(mhw_metrics.mhw_end_date < decades.decade_end, 
           mhw_metrics.mhw_end_date - mhw_metrics.mhw_onset_date, 
           decades.decade_end - mhw_metrics.mhw_onset_date
        )
    ) 
FROM 
    mhw_metrics, decades 
WHERE 
    mhw_onset_date >= decades.decade_start and mhw_onset_date <= decades.decade_end
GROUP BY
   lat, lon, decade
;