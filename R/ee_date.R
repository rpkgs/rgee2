#' @export
as_date_img <- function(x, prop = "system:time_start") {
      ee$Date(x$get(prop))$format("YYYY-MM-dd")
  }
#' @export
as_date_millis <- function(x) {
    ee$Date(x)$format("YYYY-MM-dd HH:mm:ss")
    # ee$Date(x)$format("YYYY-MM-dd")
}

#' ee_systemtime
#' 
#' Get imgcol or img "system:time_start" or "system:time_end"
#' 
#' @param prop "system:time_start" or "system:time_end"
#' @export 
ee_systemtime <- function(x, prop = 'system:time_start') {
    class <- class(x)
    if ("ee.image.Image" %in% class) x = ee$ImageCollection(x)
    x$aggregate_array(prop)$map(ee_utils_pyfunc(as_date_millis)) %>% getInfo()
}

#' @rdname ee_systemtime
#' @export 
ee_timeStart <- function(x) ee_systemtime(x, "system:time_start")    

#' @rdname ee_systemtime
#' @export
ee_timesEnd <- function(x) ee_systemtime(x, "system:time_end")    
