#' @export
as_date_img <- function(x, prop = "system:time_start") {
    ee$Date(x$get(prop))$format("YYYY-MM-dd")
}

fmt = "YYYY-MM-dd HH"
#' @export
as_date_millis <- function(x) { # HH:mm:ss
    ee$Date(x)$format(fmt)
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
    x$aggregate_array(prop)$map(ee_utils_pyfunc(as_date_millis)) %>% getInfo() %>% 
        gsub(" ", "T", .)
}

#' @rdname ee_systemtime
#' @export
ee_timeStart <- function(x) ee_systemtime(x, "system:time_start")

#' @rdname ee_systemtime
#' @export
ee_timeEnd <- function(x) ee_systemtime(x, "system:time_end")

#' @export
get_date_dn <- function(date_begin = "2000-02-26", date_end = "2020-12-31", dn = 16){
    years = seq(year(date_begin), year(date_end))
    dates = lapply(years, function(year){
        doy = seq(1, 365, dn)
        as.Date(sprintf("%d-%03d", year, doy), "%Y-%j")
    }) %>% do.call(c, .)
    dates[dates >= date_begin & dates <= date_end]
}
