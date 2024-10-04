# mhw_db.R
# database functions/utilities used for Marine HeatWave project 
# MHW project, collaborators Dr. Lala Kounta, Dr. Phoebe Zarnetske, Pat Bills
#version 1 Pat Bills July 2024

require(duckdb)
require(dbplyr)


#' path to database
#' 
#' path to the database that will be used for defaults, loaded from environment
#' create a file `.Renviron` in main directory to use that, or in your own R project
#' @export
get_dbfile <- function() {
  dbfile <- Sys.getenv('MHWDBFILE')
  if(!file.exists(dbfile)){
    warning("could not automatically set the default 'dbfile' variable to a file that exists, please set it manually")
    rm(dbfile)
  } else {
    warning(paste("default dbfile set to ", dbfile))
  }
  return(dbfile)
}

#' get connection to mhw database
#' 
#' get connection, but also ensure it has at least one of the required tables
#' 
#' @param duckdbfilepath posix path to .duckdb file
#' @param required_table_name name of table that must be in db to check for
#' @returns duckdb DBI database connection object for use in DBI::dbGetQuery, etc or NA if not found
#' @export
mhw_connect <- function(duckdbfilepath, required_table_name = "ensembles" ){
  stopifnot( file.exists(duckdbfilepath))
  conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdbfilepath)
  tblList <- duckdb::dbListTables(conn)
  if (required_table_name %in% tblList) {
    return(conn)
  } else {
    warning("database does not have required table in it")
    return(NA)
  }
}

#' check if connection works
#' 
#' test db connection by attempting to run SQL that should work, specific to this project
#' @export
check_mhw_connection<- function(conn, known_table_name = 'ensembles'){
  if(typeof(conn)!= "S4") return(FALSE)
  
  n <- 10
  sql <- paste("select * from ", known_table_name, " limit ", n)
  res <- DBI::dbGetQuery(conn, sql)
  return(nrow(res) == n)
}

#' get dbplyr table connection
#' 
#' @param conn  database connection 
#' @param table_name character name of table
#' @returns dplyr table connection for use in dplyr syntax or a 
#' @export 
mhw_table<- function(conn, table_name){
  tblList <- duckdb::dbListTables(conn)
  if (table_name %in% tblList) {
    return(dplyr::tbl(conn, table_name))
  } else {
    warning(paste("database does not have table", table_name))
    return(NA)
  }
  
}

#' get a few first rows of database table
#' 
#' useful for testing/exploration without creating large memory objects
#' 
#' @param conn database connection
#' @param tablename a table that exists in the database
#' @param n number of rows to return, default 10
#' 
#' @returns dataframe as result of query, or a promise of one for some db
#' @export 
table_head<- function(conn, tablename, n = 10){
  sql = paste0("select * from ", tablename, " limit ", n)
  res <- DBI::dbGetQuery(conn, sql)
  return(res)

}

#' get first few rows from a sql statement
#' 
#' useful for testing/exploration without creating large member objects
sql_head<- function(conn, sql, n = 10){
  sql <- paste0(sql, " limit ", n)
  res <- DBI::dbGetQuery(conn, sql)
  return(res)
  
}

#' given a sql statement create a view in db
#' 
#' Views are stored sql but act as tables in database.  These are useful when 
#' creating SQL queries that are based on other sql as inputs
#' this function is short but helps to remember the syntax 
make_view<- function(conn, sql, viewname){
  view_sql = paste0("CREATE VIEW ", viewname, " AS ", sql)
  res = DBI::dbExecute(conn, view_sql)
  return(res)
}
