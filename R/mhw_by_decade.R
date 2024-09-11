require(terra)
require(ggplot2)
require(tidyterra)
require(stringr)
require(magrittr)
require(duckdb)
## SQL 

decades <- c('2040', '2050','2060')


#' sql for parititioning wave durations by decade 
#' 
#' collect all durations (not summarized) by decade, useful for histograms. Decade start/end dates come
#' from a table 'decades' that must exist in the database
#' @param mhw_table character name of scenario table to use
#' @param use_end_date boolean TRUE: use waves ending in the decade; FALSE: use waves starting in the deacde
#' @returns character sql code to run
#' @export
duration_by_decade_sql <- function(mhw_table, use_end_date = FALSE) {
  
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

#' sql to summary scenario table
#' 
#' sql code to calc avg duration grouped by decade. Decade start/end dates come
#' from a table 'decades' that must exist in the database
#' 
#' @param mhw_table character name of scenario table to use
#' @param use_end_date boolean TRUE: use waves ending in the decade; FALSE: use waves starting in the deacde
#' @returns character sql code to run
#' @export
avg_duration_by_decade_sql <- function(mhw_table, use_end_date = FALSE) {
  
  if(use_end_date){
    sql_template <- "SELECT lat, lon, decade, avg(mhw_dur) as avg_dur 
      FROM {mhw_table} , decades 
      WHERE ((decades.decade_start <= mhw_end_date ) AND (mhw_end_date <= decades.decade_end)) 
      GROUP BY lat, lon, decade"
    
  } else {
    sql_template <- "SELECT lat, lon, decade, avg(mhw_dur) as avg_dur 
      FROM {mhw_table}, decades 
    WHERE ((mhw_onset_date >= decades.decade_start) AND (mhw_onset_date <= decades.decade_end)) 
    GROUP BY lat, lon, decade"
  }
  
  sql <- glue::glue(sql_template)
  return(sql)
}

avg_duration_by_decade_truncated <- function(mhw_table) {
  warning("function not implemented yet")
  return(NA)
}

#' rasters of global heatwave duration per decade
#' 
#' a raster with layers by decade 
#' @param mhwdb_conn database connection
#' @param mhw_table character string name of the table to query, required (e.g. arise10_metrics)
#' @returns terra raster stack of layers for each decade
#' @export
durations_by_decade_raster <- function(mhwdb_conn, mhw_table, decades = c('2040', '2050','2060')){

  duration_by_loc<- DBI::dbGetQuery(conn=mhwdb_conn, avg_duration_by_decade_sql(mhw_table))
  filterfn <- function(decade_str)  { 
    return ( filter(duration_by_loc, decade == decade_str) %>% select(lon, lat, avg_dur) %>% terra::rast(type="xyz", crs='EPSG:4326'))
   }

  # apply function to get a list 
  d_list <- sapply(decades, filterfn)
  # stack the rasters into layers
  return(rast(d_list))
}


#' calc mean duration by decade
#' 
#' @param mhwdb_conn database connection to a mhw database
#' @param mhw_table character name of the table of ensembles to query
#' @returns list of dataframes, one dataframe per decade, each data frame see avg_duration_by_decade_sql for
#' @export 
duration_by_decades <- function(mhwdb_conn,mhw_table){
  duration_by_loc<- DBI::dbGetQuery(conn=mhwdb_conn, avg_duration_by_decade_sql(mhw_table))
  filterfn <- function(decade_str)  { 
    return (data.frame(filter(duration_by_loc, decade == decade_str) %>% select(lon, lat, mhw_dur) ))
  }
  d_list <- lapply(decades, filterfn)

  return(d_list)
}


#' @export 
duration_by_decade_histogram<-function(mhwdb_conn, mhw_table = "mhw_metrics", log_scale = FALSE){
    
  # get rows of data for all decades in single table
  duration_by_loc<- DBI::dbGetQuery(conn=mhwdb_conn, duration_by_decade_sql(mhw_table))

  # create list object, one item per decade
  filterfn <- function(decade_str)  { 
      return (data.frame(dplyr::filter(duration_by_loc, decade == decade_str) %>% dplyr::select(lon, lat, mhw_dur) ))
    }
  
  d_list <- lapply(decades, filterfn)
    
  d<- lapply(d_list, function(x) {dplyr::select(x, mhw_dur)})
  d<- dplyr::bind_rows(d, .id = "id")
  g = ggplot2::ggplot(d, ggplot2::aes(mhw_dur)) + ggplot2::geom_histogram(bins=100)+ ggplot2::facet_wrap(~id)
  if(log_scale) g = g + ggplot2::scale_x_log10() + ggplot2::scale_y_log10() 
  g
}

