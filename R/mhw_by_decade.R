source('R/mhw_db.R')
require(terra)
library(ggplot2)
library(tidyterra)
## SQL 

decades <- c('2040', '2050','2060')

avg_duration_by_decade <- function() {
  sql <- "SELECT lat, lon, decade, avg(mhw_dur) as avg_dur 
  FROM mhw_metrics , decades 
  WHERE ((mhw_onset_date >= decades.decade_start) AND (mhw_onset_date <= decades.decade_end)) 
  GROUP BY lat, lon, decade"
  
  return(sql)
}

avg_duration_by_decade_end <- function() {
  sql <- "SELECT lat, lon, decade, avg(mhw_dur) as avg_dur FROM mhw_metrics , decades 
  WHERE ((decades.decade_start <= mhw_end_date ) AND (mhw_end_date <= decades.decade_end)) 
  GROUP BY lat, lon, decade"
  return(sql)
}

avg_duration_by_decade_exclusive <- function() {
  sql <- "SELECT lat, lon, decade, avg(mhw_dur) as avg_dur FROM mhw_metrics , decades 
  WHERE ((mhw_start_date >= decades.decade_start) AND (mhw_end_date <= decades.decade_end)) 
  GROUP BY lat, lon, decade"
  return(sql)
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
    return (data.frame(filter(duration_by_loc, decade == decade_str) %>% select(lon, lat, avg_dur) ))
  }
  d_list <- lapply(decades, filterfn)

  return(d_list)
}


### visualizations

  duration_histogram<-function(mhwdb_conn, log_scale = FALSE){
  d<- duration_by_decades(mhwdb_conn)
  d<- lapply(d, function(x) {dplyr::select(x, avg_dur)})
  d<- dplyr::bind_rows(d, .id = "id")
  g = ggplot(d, aes(avg_dur)) + geom_histogram(bins=100)+ facet_wrap(~id)
  if(log_scale) g = g + scale_x_log10() 
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