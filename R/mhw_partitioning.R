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
create_partition_df<-function(partition_size_years=3, start_year = 2040, end_year = 2069) {
  start_years<- seq(from = start_year, to = end_year, by = partition_size_years)
  start_dates<- as.Date(paste0(start_years, "-01-01"))
  end_dates <- as.Date(paste0( ( start_years + partition_size_years - 1), "-12-31"))
  partition.df = data.frame("partition_start" =  start_years, "partition_start_date" = start_dates, "partition_end_date" = end_dates)
  
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
#' @returns data frame copy of the table as created of with partition_name, partition_start_date, partition_end_date
#' @export
create_partition_table<- function(conn, partition_size_years=3, start_year = 2040, end_year = 2069){
  
  table_name = 'partitions'
  
  partitions.df <- create_partition_df(partition_size_years, start_year, end_year)
  # warning(paste("table '", table_name, "'is being replaced with new data with ", nrow(partitions.df), "rows"))
  
  # sql <- paste("CREATE OR REPLACE TABLE ", table_name, " (partition_start INTEGER, partition_start_date DATE, partition_end_date DATE);")
  #DBI::dbExecute(conn, sql)
  duckdb::dbWriteTable(conn, name = table_name, value = partitions.df, overwrite=TRUE)
  # dplyr::copy_to(conn, partitions.df, overwrite = TRUE) 
  
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
  
  partition_table_name = 'partitions'
  
  partitions<- create_partition_table(conn, partition_size_years=3, start_year = 2040, end_year = 2069)
  if(use_end_date){
    where_clause <- "WHERE ((mhw_end_date >= partition_start_date) AND (mhw_end_date < partition_end_date))"
  } 
  else {
    where_clause <- "WHERE ((mhw_onset_date >= partition_start_date) AND (mhw_onset_date < partition_end_date))"
  }
  
  sql_template <- "SELECT partition_start, {mhw_table_name}.* 
    FROM {mhw_table_name}, {partition_table_name}, 
    {where_clause}"       
  
  sql <- (stringr::str_glue(sql_template))
  
  partition_events.df <- dbGetQuery(conn=conn, sql)

  return(partition_events.df)
  
}


#' sql for partitioning
#' 
#' @param mhw_table_name name of main metrics table to use
#' @param partition_size_years width of partions in years
#' @param start_year year to start partitions default 2040
#' @param end_year year to end partitions  default 2069
#' @returns character sql to create new table of truncated mwh by partition
#' @export
partition_mhw_events_truncated_sql<- function(mhw_table_name, partition_size_years=3, start_year = 2040, end_year = 2069){
  
  partition_table_name = "partitions"
  partition_duration_column_name = "partition_dur"
  
  # reusable sections of sql 
  select_clause <- paste0("SELECT ", partition_table_name, ".*, ", mhw_table_name,".*, ")
  from_clause <- paste0(" FROM ", mhw_table_name, ", ", partition_table_name, " ")
  
  # sql for all of mhw included in partition
  sql_whole_mhw <- paste(select_clause,
   "'whole' as mhw_portion, 
   mhw_onset_date as mhw_portion_start,
   mhw_end_date as mhw_portion_end,
   (mhw_end_date - mhw_onset_date) as ", partition_duration_column_name,
   from_clause,
   " WHERE ((mhw_onset_date >= partition_start_date) AND (mhw_end_date <= partition_end_date))"
   )
  
  # sql to collect waves that start before partition but ends inside partition
  sql_end_portion <- paste(select_clause, 
  "'end' as mhw_portion, 
  partition_start_date as mhw_portion_start,
  mhw_end_date as mhw_portion_end,
  (mhw_end_date - partition_start_date) as ", partition_duration_column_name,
  from_clause, 
  " WHERE ((mhw_onset_date < partition_start_date) AND (mhw_end_date >= partition_start_date) AND (mhw_end_date <= partition_end_date))"
  )
  
  # sql to collect waves that start inside partition but ends after
  sql_start_portion <- paste(select_clause, 
  "'start' as mhw_portion, 
    mhw_onset_date as mhw_portion_start, partition_end_date as mhw_portion_end, (mhw_onset_date - partition_end_date) as ", partition_duration_column_name, 
  from_clause, 
  " WHERE ( (mhw_onset_date >= partition_start_date) AND (mhw_onset_date <= partition_end_date) AND (mhw_end_date > partition_end_date))"
  )
  
  sql <- paste( sql_whole_mhw, " union ", sql_end_portion, " union ",sql_start_portion )

  # remove the line breaks
  return(gsub("[\n\r]", "", sql))
}
  
#' mhw_partitioning.R
#' this is a work in progress (WIP) and not complete


#' table of truncated mhw metrics by partitions
#' 
#' given set of partitions with dates, create table by matching waves to partions and truncated them 
#' 
#' @param conn dbi database connection, see mhw_connect()
#' @param mhw_table_name name of main metrics table to use
#' @param partition_size_years width of partions in years
#' @param start_year year to start partitions default 2040
#' @param end_year year to end partitions  default 2069
#' @returns dplyr table with fields from mhw table, partition table (partition_name, partition_start_date, partition_end_date ), 
#'          mhw_portion = which part of wave, mhw_portion_start =  start date of truncated mhw, 
#'          mhw_portion_end = end date of truncate wave, partition_dur = duration in days of truncated wave
#' @export
partition_mhw_events_truncated<- function(conn, mhw_table_name, partition_size_years=3, start_year = 2040, end_year = 2069){
  
  # partition_table_name = "partitions"
  # partition_duration_column_name = "partition_dur"
  
  # generate sql string to run 
  sql<- partition_mhw_events_truncated_sql(mhw_table_name, partition_size_years, start_year, end_year)
  
  # create temp partitions table
  create_partition_table(conn, partition_size_years, start_year, end_year)
  truncated_mhw.df <- DBI::dbGetQuery(conn=conn, sql)
  
  return(truncated_mhw.df)
  
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

