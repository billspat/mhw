# source('R/mhw_db.R') # use devtools::load_all() instead
# require(terra)
# require(ggplot2)
# require(tidyterra)

mhw_window_duration <- function(mhwdb_conn, window_size_years=2, truncate=TRUE, start_year = 2040, end_year = 2069){

  
  start_years = seq(from = start_year, 
              to = end_year,
              by = window_size_years)
  
  end_years =  seq(from = (start_year+window_size_years-1), 
                   to = end_year,
                   by = window_size_years)
  
  partition_dates<- data.frame(partition = as.character(start_years), onset = paste0(start_years, "-01-01"), end = paste0(end_years, '-12-31') )
  
  create_table_sql = "create table partitions (partition varhcar, onset DATE, end DATE)"
  
  
    sql <- "SELECT lat, lon, decade, avg(mhw_dur) as avg_dur FROM mhw_metrics , decades 
  WHERE ((mhw_onset_date >= decades.decade_start) AND (mhw_onset_date <= decades.decade_end)) 
  GROUP BY lat, lon, decade"
  
  
}