# Here is a script that you can copy/paste into the console.  

# his assumes you have set the variable MHWDBFILE either in the `.Renviron` file or in the environment/shell before starting R/Rstudio.    
# MHWDBFILE must be the full path to the database file.  You can set this manually in your scripts is prefered
# in the console run dev_tools::load_all() to get your latest edits

# read from the environment
db_file <- get_dbfile()
# OR set manually
# db_file = "/full/path/to/mhwci.b"

# Optional check that the `db_file` is a file that can be found from your script. 
# this halts the program if the dbfile can't be found
stopifnot(file.exists(db_file))

# Get connected
conn<- mhw_connect(db_file)
# optionally just showing that we have an actual connect
print(duckdb::dbListTables(conn))


# Each scenario has it's own table of marine heat wave metrics, so let's set that table name here
mhw_table_name <-"ssp245_metrics"


# You can run SQL command to get data using the duckdb database engine, which is very fast.  

# This SQL averages duration for the specific table 
# this is a function that creates a string of SQL with the table we want to use
sql<- avg_duration_by_decade_sql(mhw_table_name)
print(sql)


# Here is how you run a query using the `dbGetQuery` command.  
duration_by_loc<- DBI::dbGetQuery(conn, sql)
# that didn't take long
print('data sample')
head(duration_by_loc)


# this does all the stuff above encapsulated into a function: 
duration_rasters <- durations_by_decade_raster(conn, mhw_table_name)


# create a map of these rasters that manages the outliers
cut_percent = 0.5
duration_title <- paste("Mean MHW Duration (days) by Decade of Onset, ", mhw_table_name)
plot_rasters_squish_outliers(raster_list = duration_rasters, title = duration_title, cut_percent = 0.5 )
