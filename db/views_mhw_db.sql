


DROP VIEW IF EXISTS avg_duration_by_decade_arise10;
CREATE VIEW avg_duration_by_decade_arise10 AS
SELECT 
    lat, 
    lon, 
    decade,
    avg(mhw_dur) 
FROM 
    arise10_metrics, decades 
WHERE 
    mhw_onset_date >= decades.decade_start and mhw_onset_date <= decades.decade_end
GROUP BY
   lat, lon, decade
;

DROP VIEW IF EXISTS avg_duration_by_decade_truncated_arise10;
CREATE VIEW avg_duration_by_decade_truncated_arise10 AS
SELECT 
    lat, 
    lon, 
    decade,
    avg(
        IF(arise10_metrics.mhw_end_date < decades.decade_end, 
           arise10_metrics.mhw_end_date -arise10_metrics.mhw_onset_date, 
           decades.decade_end - arise10_metrics.mhw_onset_date
        )
    ) 
FROM 
    arise10_metrics, decades 
WHERE 
    mhw_onset_date >= decades.decade_start and mhw_onset_date <= decades.decade_end
GROUP BY
   lat, lon, decade
;