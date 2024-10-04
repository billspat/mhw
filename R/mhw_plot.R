# mhw_plot.R 
# plotting functions for maps of heatwave metrics
# includes numeric functions for handling the very large outliers produced by these models


#' find value for percentile cut-off
#' 
#' given a range of values, find the max value just before a percentile, say 1% , 
#' used to divide a range into two bins or set an upper limit.  If a whole number is sent, 
#' the percentiles are sequenced by 1% (0, 1..98, 98, 100) Ff a non-whole number is sent
#' like 2.25% or 0.25% then the percentiles are divided into finer resolution (e.g per 0.25%)
#' 
#' @param x values to find the cut-off in, numeric vector
#' @param cut_percent numeric  top percent to cut e.g. 1 to cut top 1% See description should be 0<x<100 and can be decimal
#' @returns numeric value in x that is the max befoe the percentile indicated by cut_percent
#' @export 
percentile_cutoff_value<- function(x, cut_percent = 1){
  
  if( mod(cut_percent, 1) != 0){
    divisor = mod(cut_percent, 1)/100.0
  } else {
    divisor = 0.01
  }
  
  percentiles <- quantile(x, seq(from = 0, to = 1, by = divisor), na.rm = TRUE)
  
  # names are characters like '99%', create such a name to find the value we want
  cut_name = paste0(as.character(100-cut_percent), "%")
  # send a warning is something is off and this percent is not in our percentiles
  if(!cut_name %in% names(percentiles)) {
    warning(paste("using", cut_percent, "cut off percent not valid single percent name, returning entire scale"))
  } 
  
  cut_max_value = percentiles[cut_name]
  
  return(cut_max_value)
}



#' plot terra rasters, but manage outliers
#' 
#' given a list of terra rasters to plot, use heat gradient to display values, 
#' but cut off the top X percent and replace those values with the top color (red in this case)
#' in order to handle extreme outliers.  Currently this does _not_ print the max range (outliers) in the legend
#' @param raster_list terra spat raster list (or stack?)
#' @param title character title of the plot, default is empty title
#' @param cut_percent numeric percentile cut-off, see percentile_cutoff_value function for descriptoin, but 1 
#' will cut top 1 percent, 0.25 will cut to 0.25% off and display as top color (e.g. red)
#' @param threshold_value numeric optional numeric cut off the range display.  if this is sent, then cut_percent is ignored 
#' @returns ggplot object, one map for each item in raster_list with single legend 
#' @export
plot_rasters_squish_outliers <- function(raster_list, title = "",  cut_percent = 0, threshold_value = NA){
  # where to cut off the values so that 
  if( is.na(threshold_value)){
    # if cut percent is 0, will not cut of the range
    cut_value <- percentile_cutoff_value(values(raster_list), cut_percent = cut_percent)  
    if( cut_percent > 0) {
      subtitle = paste("by lat/lon point, compressing top ", cut_percent, " percentile outliers") 
    } else {
      subtitle = ""
    }
  } else {
    # TODO check that threshold_value is in range? 
    cut_value <- threshold_value
    subtitle = paste("compressed all values above ", threshold_value) 
  }
  
  
  g<-ggplot2::ggplot() +
    tidyterra::geom_spatraster(data = raster_list, inherit.aes = TRUE) +
    ggplot2::labs(
      fill = = "MHW Duration, d",
      title = title,
      subtitle = subtitle
    ) +
    ggplot2::facet_wrap(~lyr,ncol= 1) + 
    tidyterra::scale_fill_whitebox_c(
      palette = 'bl_yl_rd', 
      limits = c(min(values(raster_list)),cut_value), 
      oob = scales::squish) + 
    ggplot2::theme_void()
  
  return(g)
}

#' plot of world rasters by layer, no outlier management
#' 
#' use plot_rasters_squish_outliers instead to plot mhw rasters
#' @export 
plot_decade_rasters <- function(mhwdb_conn, mhw_table){
  if (! check_mhw_connection(mhwdb_conn)) { 
    warning("db connection invalid")
  }
  
  duration_rasters <- durations_by_decade_raster(mhwdb_conn, mhw_table)
  
  ggplot2::ggplot() +
    tidyterra::geom_spatraster(data = duration_rasters) +
    ggplot2::labs(
      fill = "MHW Duration, d",
      title = "Mean MHW Duration (days) by Decade of Onset",
      subtitle = "by lat/lon point") +
    ggplot2::facet_wrap(~lyr,ncol= 1) +
    tidyterra::scale_fill_whitebox_c(
      palette = "muted",
      na.value = "white"
    )
}