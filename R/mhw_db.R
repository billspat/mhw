#' mhw_db.R
#' database functions/utilities used for Marine HeatWave project 
#' 
#' MHW project, collaborators Dr. Lala Kounta, Dr. Phoebe Zarnetske, Pat Bills
#' 
#' version 1 Pat Bills July 2024
library(duckdb)
library(duckplyr)


#' path to database
#' 
#' path to the database that will be used for defaults, loaded from environment
#' create a file `.Renviron` in main directory to use that, or in your own R project
dbfile <- Sys.getenv('MHWDBFILE', unset='data/mhwmetrics.duckdb')


#' get connection to mhw database
#' 
#' get connection, but also ensure it has at least one of the required tables
#' 
#' @param duckdbfilepath
#' 
#' @returns duckdb DBI database connection object for use in dbGetQuery, etc or NA if not found
mhw_connect <- function(duckdbfilepath = dbfile, required_table_name = "mhw_metrics" ){
  stopifnot( file.exists(duckdbfilepath))
  con <- dbConnect(duckdb(), dbdir = duckdbfilepath)
  tblList <- dbListTables(con)
  if (required_table_name %in% tblList) {
    return(con)
  } else {
    warning("database does not have required table in it")
    return(NA)
  }
}

#' check if connection works
#' 
#' test db connection by attempting to run SQL that should work, specific to this project
check_mhw_connection<- function(con){
  if(typeof(con)!= "S4") return(FALSE)
  
  n <- 10
  sql <- paste0("select * from mhw_metrics limit ", n)
  res <- dbGetQuery(con, sql)
  return(nrow(res) == n)
}

#' get a few first rows of database table
#' 
#' useful for testing/exploration without creating large memory objects
#' 
#' @param con database connection
#' @param tablename a table that exists in the database
#' @param n number of rows to return, default 10
#' 
#' @returns dataframe as result of query, or a promise of one for some db
table_head<- function(con, tablename, n = 10){
  sql = paste0("select * from ", tablename, " limit ", n)
  res <- dbGetQuery(con, sql)
  return(res)

}

#' get first few rows from a sql statement
#' 
#' useful for testing/exploration without creating large member objects
sql_head<- function(con, sql, n = 10){
  sql <- paste0(sql, " limit ", n)
  res <- dbGetQuery(con, sql)
  return(res)
  
}

#' given a sql statement create a view in db
#' 
#' Views are stored sql but act as tables in database.  These are useful when 
#' creating SQL queries that are based on other sql as inputs
#' this function is short but helps to remember the syntax 
make_view<- function(con, sql, viewname){
  view_sql = paste0("CREATE VIEW ", viewname, " AS ", sql)
  res = dbExecute(con, view_sql)
  return(res)
}
