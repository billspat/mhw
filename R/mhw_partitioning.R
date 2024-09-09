#' main decades to use for analysis
#' @export
decades <- c('2040', '2050','2060')


#' create table of start/end dates for year gaps
#' 
#' @param partition_size_years integer width of partitions in whole years, not more than 10 usually
#' @param start_year integer year to start partitioning (low end of range), default 2040
#' @param end_year integer year to end portioning
#' @returns vector of integers, division of the range of inter 
#' @export
create_partion_table<-function(partition_size_years=3, start_year = 2040, end_year = 2069) {
  start_years<- seq(from = start_year, to = end_year, by = partition_size_years)
  start_dates<- as.Date(paste0(start_years, "-01-01"))
  end_dates <- as.Date(paste0( ( start_years + partition_size_years - 1), "-12-31"))
  partition.df = data.frame("partition" =  start_years, "start_date" = start_dates, "end_date" = end_dates)
  return(partition.df)
}

#' create tabl assigning partition to each event
#' @param conn dbi database connection, see mhw_connect()
#' @param mhw_table name of main metrics table to use
#' @param partition_size_years width of partions in years
#' @param start_year year to start partitions default 2040
#' @param end_year year to end partitions  default 2069
#' @param use_end_date bolean deafult TRUE
#' @returns data frame with partition value assigned to each event 
#' @export
partition_mhw_events<- function(conn, mhw_table='mhw_metrics', partition_size_years=3, start_year = 2040, end_year = 2069, use_end_date = TRUE){
  
  partitions <- create_partion_table(partition_size_years=3, start_year = 2040, end_year = 2069)
  dplyr::copy_to(conn, partitions , overwrite = TRUE)  
  
  event_table <- dplyr::tbl(conn, mhw_table)
  partition_table <- dplyr::tbl(conn, "partitions")
  
  
  if(use_end_date){
    where_clause <- "WHERE ((mhw_end_date >= partitions.start_date) AND (mhw_end_date < partitions.end_date))"
  } 
  else {
    where_clause <- "WHERE ((mhw_onset_date >= partitions.start_date) AND (mhw_onset_date < partitions.end_date))"
  }
  
  sql_template <- "SELECT lat, lon, partitions.partition as partition, mhw_dur 
    FROM {mhw_table}, partitions, 
    {where_clause}"       
  
  sql <- (stringr::str_glue(sql_template))
  
  partition_events.df <- dbGetQuery(conn=conn, sql)
  dbExecute(conn, "drop table partitions")
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
#'
#' @examples
windowing_overlap <- function(vec, seg.length, overlap=0) {
  starts = seq(1, length(vec), by=seg.length-overlap)
  ends   = starts + seg.length - 1
  ends[ends > length(vec)] = length(vec)
  
  return(lapply(1:length(starts), function(i) vec[starts[i]:ends[i]]))
}


# duration_by_partition <- function(conn, mhw_table='mhw_metrics', partition_size_years=3, start_year = 2040, end_year = 2069, use_end_date = TRUE){
#   
# }

