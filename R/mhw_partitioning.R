#' main decades to use for analysis
#' @export
decades <- c('2040', '2050','2060')


#' create table of start/end dates for year gaps
#' 
#' @param partition_size_years integer width of partitions in whole years, not more than 10 usually
#' @param start_year integer year to start partitioning (low end of range), default 2040
#' @param end_year integer year to end portioning
#' @returns data frame of with years, start_date, end_date
#' @export
create_partion_df<-function(partition_size_years=3, start_year = 2040, end_year = 2069) {
  start_years<- seq(from = start_year, to = end_year, by = partition_size_years)
  start_dates<- as.Date(paste0(start_years, "-01-01"))
  end_dates <- as.Date(paste0( ( start_years + partition_size_years - 1), "-12-31"))
  partition.df = data.frame("partition_start" =  start_years, "start_date" = start_dates, "end_date" = end_dates)
  
  return(partition.df)
}

#' create temporary partitions table 
#' 
#' create a temporary table in the database of partitions named 'partitions', used 
#' to create joins on metrics tables in-database rather than in
#' R space using dplyr for speed and so can use SQL
#' this function has the destructive side effect of overwriting existing partitions 
#' table.  
#' this will disappear when the connection is disconnected or garbage collected
#' 
#' @param conn dbi database connection, see mhw_connect()
#' @param partition_size_years integer width of partitions in whole years, not more than 10 usually
#' @param start_year integer year to start partitioning (low end of range), default 2040
#' @param end_year integer year to end portioning
#' @returns data frame copy of the table as created of with years, start_date, end_date
#' @export
create_partion_table<- function(conn, partition_size_years=3, start_year = 2040, end_year = 2069){
  
  table_name = 'partitions'
  
  partitions.df <- create_partion_df(partition_size_years=3, start_year = 2040, end_year = 2069)
  warning(paste("table '", table_name, "'is being replaced with new data with ", nrow(partitions.df), "rows"))
  
  sql <- paste("CREATE OR REPLACE TEMP TABLE ", table_name, " (partition_start INTEGER, start_date DATE, end_date DATE);")
  DBI::dbExecute(conn, sql)
  
  dplyr::copy_to(conn, partitions.df, overwrite = TRUE) 
  return(mhw_table(conn, table_name))
  
}

#' assign partition to each event
#' 
#' assign a partition_start (a year) to every event in the mhw metrics table 
#' that is sent based on either start or end date of the mhw, the new column is called
#' partition_start
#' 
#' @param conn dbi database connection, see mhw_connect()
#' @param mhw_table_name name of main metrics table to use
#' @param partition_size_years width of partions in years
#' @param start_year year to start partitions default 2040
#' @param end_year year to end partitions  default 2069
#' @param use_end_date bolean deafult TRUE
#' @returns dbplyr 'table', data frame with partition value assigned to each event in column partition_start 
#' @export
partition_mhw_events<- function(conn, mhw_table_name, partition_size_years=3, start_year = 2040, end_year = 2069, use_end_date = TRUE){
  
  partitions<- create_partion_table(conn, partition_size_years=3, start_year = 2040, end_year = 2069)
  if(use_end_date){
    where_clause <- "WHERE ((mhw_end_date >= partitions.start_date) AND (mhw_end_date < partitions.end_date))"
  } 
  else {
    where_clause <- "WHERE ((mhw_onset_date >= partitions.start_date) AND (mhw_onset_date < partitions.end_date))"
  }
  
  sql_template <- "SELECT partitions.partition_start as partition_start, {mhw_table_name}.* 
    FROM {mhw_table_name}, partitions, 
    {where_clause}"       
  
  sql <- (stringr::str_glue(sql_template))
  
  partition_events.df <- dbGetQuery(conn=conn, sql)

  return(partition_events.df)
  
}



#' create overlapping subsets of a sequence/vector
#' 
#' draft/experimental function for creating moving windows of vectors of years
#'
#' @param vec 
#' @param seg.length 
#' @param overlap 
#'
#' @returns list of subsets
#' @export
windowing_overlap <- function(vec, seg.length, overlap=0) {
  starts = seq(1, length(vec), by=seg.length-overlap)
  ends   = starts + seg.length - 1
  ends[ends > length(vec)] = length(vec)
  
  return(lapply(1:length(starts), function(i) vec[starts[i]:ends[i]]))
}


# duration_by_partition <- function(conn, mhw_table='mhw_metrics', partition_size_years=3, start_year = 2040, end_year = 2069, use_end_date = TRUE){
#   
# }

