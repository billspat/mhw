
# Here is a script that you can copy/paste into the console.
# this assumes you have set the variable MHWDBFILE either in the `.Renviron` file or in the environment/shell before starting R/Rstudio.
# MHWDBFILE must be the full path to the database file.  You can set this manually in your scripts is prefered
# in the console run dev_tools::load_all() to get your latest edits

#' plot a series of MHW tables as maps and histograms
#' 
#' @param mhw_tables vector of character names of tables to plot
#' @param conn database connection to use with mhw functions
#' @param threshold numeric common value to use to constrain scale of all plots, see plot_rasters_squish_outliers, default 365/2
#' @param pdf_file_name optional character if set, will be used as a path to a pdf file
#' @returns plots or path to plots
#' @examples
#' \dontrun{
#' db_file = get_dbfile()
#' db <- mhw_connect(db_file)
#' mhw_tables <- c('arise10_decade_metrics','arise15_decade_metrics','ssp245_decade_metrics' )
#' generate_duration_plots(mhw_tables, conn= db, threshold = 150, pdf_file_name = 'duration_plots.pdf')
#' }

#' @export
generate_duration_plots<- function(mhw_tables, conn, threshold = 365/2, pdf_file_name = NULL) {

  if(! is.null(pdf_file_name)) {
    pdf(pdf_file_name)
  }
  
  for(mhw_table_name in mhw_tables){
      raster_list <- durations_by_decade_raster(conn, mhw_table_name)
      duration_title <- paste("Mean MHW Duration (days) by Decade of Onset, ", mhw_table_name)
      print(plot_rasters_squish_outliers(raster_list = raster_list, title = duration_title, threshold = threshold ))
      
      # plot histograms here
  }
  
  dev.off()
}

