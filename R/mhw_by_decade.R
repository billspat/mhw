# source('R/mhw_db.R')  # use devtools::load_all() instead 
require(terra)
require(ggplot2)
require(tidyterra)
require(stringr)
require(magrittr)
## SQL 

decades <- c('2040', '2050','2060')


duration_by_decade_sql <- function(mhw_table='mwh_metrics', use_end_date = FALSE) {
  
  if(use_end_date){
    where_clause <- "WHERE ((mhw_end_date >= decades.decade_start) AND (mhw_end_date < decades.decade_end))"
  } 
  else {
    where_clause <- "WHERE ((mhw_onset_date >= decades.decade_start) AND (mhw_onset_date < decades.decade_end))"
  }
  
  sql <- "SELECT lat, lon, decade, mhw_dur 
    FROM {mhw_table}, decades 
    {where_clause}"
    
  # GROUP BY lat, lon, decade"  
  return(stringr::str_glue(sql))
  
}

avg_duration_by_decade_sql <- function(mhw_table='mwh_metrics', use_end_date = FALSE) {
  
  if(use_end_date){
    sql <- "SELECT lat, lon, decade, avg(mhw_dur) as avg_dur FROM mhw_metrics , decades 
  WHERE ((decades.decade_start <= mhw_end_date ) AND (mhw_end_date <= decades.decade_end)) 
  GROUP BY lat, lon, decade"
    
  } else {
    sql <- "SELECT lat, lon, decade, avg(mhw_dur) as avg_dur 
  FROM mhw_metrics , decades 
  WHERE ((mhw_onset_date >= decades.decade_start) AND (mhw_onset_date <= decades.decade_end)) 
  GROUP BY lat, lon, decade"
  }
  
  return(sql)
}

avg_duration_by_decade_sql <- function(mhw_table='mwh_metrics') {
  sql <- "SELECT lat, lon, decade, avg(mhw_dur) as avg_dur FROM mhw_metrics , decades 
  WHERE ((decades.decade_start <= mhw_end_date ) AND (mhw_end_date <= decades.decade_end)) 
  GROUP BY lat, lon, decade"
  return(sql)
}

avg_duration_by_decade_truncated <- function(mhw_table='mwh_metrics') {
  warning("function not implemented yet")
  return(NA)
}

#' rasters of global heatwave duration per decade
#' 
#' a raster with layers by decade 
durations_by_decade_raster <- function(mhwdb_conn){

  duration_by_loc<- dbGetQuery(conn=mhwdb_conn, avg_duration_by_decade())
  filterfn <- function(decade_str)  { 
    return ( filter(duration_by_loc, decade == decade_str) %>% select(lon, lat, avg_dur) %>% terra::rast(type="xyz", crs='EPSG:4326'))
   }

  # apply function to get a list 
  d_list <- sapply(decades, filterfn)
  # stack the rasters into layers
  return(rast(d_list))
}


duration_by_decades <- function(mhwdb_conn){
  duration_by_loc<- dbGetQuery(conn=mhwdb_conn, avg_duration_by_decade())
  filterfn <- function(decade_str)  { 
    return (data.frame(filter(duration_by_loc, decade == decade_str) %>% select(lon, lat, mhw_dur) ))
  }
  d_list <- lapply(decades, filterfn)

  return(d_list)
}



duration_by_decade_histogram<-function(mhwdb_conn, mhw_table = "mhw_metrics", log_scale = FALSE){
    
  # get rows of data for all decades in single table
  duration_by_loc<- dbGetQuery(conn=mhwdb_conn, duration_by_decade_sql(mhw_table))

  # create list object, one item per decade
  filterfn <- function(decade_str)  { 
      return (data.frame(filter(duration_by_loc, decade == decade_str) %>% select(lon, lat, mhw_dur) ))
    }
  
  d_list <- lapply(decades, filterfn)
    
  d<- lapply(d_list, function(x) {dplyr::select(x, mhw_dur)})
  d<- dplyr::bind_rows(d, .id = "id")
  g = ggplot(d, aes(mhw_dur)) + geom_histogram(bins=100)+ facet_wrap(~id)
  if(log_scale) g = g + scale_x_log10() + scale_y_log10() 
  g
}


plot_decade_rasters <- function(mhwdb_conn){
  if (! check_mhw_connection(mhwdb_conn)) { 
    warning("db connection invalid")
  }
  
  duration_rasters <- durations_by_decade_raster(mhwdb_conn)
  
  ggplot() +
    geom_spatraster(data = duration_rasters) +
    labs(
      fill = "MHW Duration, d",
      title = "Mean MHW Duration (days) by Decade of Onset",
      subtitle = "by lat/lon point") +
    facet_wrap(~lyr,ncol= 1) +
    scale_fill_whitebox_c(
      palette = "muted",
      na.value = "white"
    )
}