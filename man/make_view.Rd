% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mhw_db.R
\name{make_view}
\alias{make_view}
\title{given a sql statement create a view in db}
\usage{
make_view(conn, sql, viewname)
}
\description{
Views are stored sql but act as tables in database.  These are useful when 
creating SQL queries that are based on other sql as inputs
this function is short but helps to remember the syntax
}
