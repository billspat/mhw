#' main decades to use for analysis
#' @export
decades <- c('2040', '2050','2060')


#' create table of start/end dates for year gaps
#' @export
create_partion_table<-function(partition_size_years=3, start_year = 2040, end_year = 2069) {
  start_years<- seq(from = start_year, to = end_year, by = partition_size_years)
  start_dates<- as.Date(paste0(start_years, "-01-01"))
  end_dates <- as.Date(paste0( ( start_years + partition_size_years - 1), "-12-31"))
  partition.df = data.frame("partition" =  start_years, "start_date" = start_dates, "end_date" = end_dates)
  return(partition.df)
}


partition_events<- function(con, mhw_table='mwh_metrics', partition_size_years=3, start_year = 2040, end_year = 2069){
  partition_table <- create_partion_table(partition_size_years=3, start_year = 2040, end_year = 2069)
  dplyr::copy_to(con, partition_table , overwrite = TRUE)  
  
  event_table <- dbplyr::tbl(con, table_name)
  event_table %>% mutate()
  
  
  
}
