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
    sql_template <- "SELECT lat, lon, decades.decade, avg(mhw_dur) as avg_dur 
      FROM {mhw_table} , decades 
      WHERE ((decades.decade_start <= mhw_end_date ) AND (mhw_end_date <= decades.decade_end)) 
      GROUP BY lat, lon, decades.decade"
    
  } else {
    sql_template <- "SELECT lat, lon, decades.decade, avg(mhw_dur) as avg_dur 
      FROM {mhw_table}, decades 
    WHERE ((mhw_onset_date >= decades.decade_start) AND (mhw_onset_date <= decades.decade_end)) 
    GROUP BY lat, lon, decades.decade"
  }
  
  sql <- glue::glue(sql_template)
  return(sql)
}

#' create SQL tocalculate average duration of marine heatwaves by point in space, grouped by decade
#' 
#' craft the sql code to calculate averge MHW duration, using the data tables with models truncated by decade
#' this will run on any table but you should restrict to those tables needed for analysis.   Tables are required
#' to have column lat, lon, mhw_onset (integer formatted dates like 20411231), mhw_dur
#' this function does not check that the table has those columns, it only generates a string of SQL
#' 
#' @param mhw_table character name of the table to analyze
#' @param start_year integer year to start, inclusive (dates will include this start year)
#' @param end_year integer year to end, inclusive (dates will include up to 12/31 of the end year)
#' @returns character SQL code to run on the MHW database
#' @export
avg_duration_by_decade_truncated_sql <- function(mhw_table, start_year=2040, end_year=2069) {
  sql_template <- "SELECT lat, lon, (mhw_onset- mod(mhw_onset,100000))/10000 as decade,avg(mhw_dur) as avg_dur
  FROM {mhw_table} WHERE mhw_onset/10000 >= {start_year} and mhw_onset/10000 <= {end_year}+1
  GROUP BY lat, lon, decade ORDER by decade, lat, lon"
  sql <- glue::glue(sql_template)
  return(sql)
}

#' rasters of global heatwave duration per decade
#' 
#' a raster with layers by decade 
#' @param mhwdb_conn database connection
#' @param mhw_table character string name of the table to query, required (e.g. arise10_metrics)
#' @param crs character coordinate reference system, EPSG:4087, alternatives are EPSG:4326. 
#' @returns terra raster stack of layers for each decade
#' @export
durations_by_decade_raster <- function(mhwdb_conn, mhw_table, decades = c('2040', '2050','2060'), crs='EPSG:4087'){

  # sql = avg_duration_by_decade_sql(mhw_table)
  sql = avg_duration_by_decade_truncated_sql(mhw_table)
  # calculate the average duration by coordinate (see sql function above for specifics)
  duration_by_loc<- DBI::dbGetQuery(conn=mhwdb_conn, sql)
  
  filterfn <- function(decade_str)  { 
    return ( filter(duration_by_loc, decade == decade_str) %>% select(lon, lat, avg_dur) %>% terra::rast(type="xyz", crs=crs))
   }

  # apply function to get a list 
  d_list <- sapply(decades, filterfn)
  # stack the rasters into layers, climate data is 0 to 360, use rotate to make -180 to 180
  raster_list <-terra::rast(d_list)
  rotated_raster_list <- terra::rotate(raster_list)
  return(rotated_raster_list)
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

