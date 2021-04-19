#' @export
get_time <- function(img) {
  ee$Date(img$get('system:time_start'))$format('yyyy-MM-dd')
}

#' @export
ee_getInfo <- function(x) {
    x$getInfo()
}

#' @export
getInfo = ee_getInfo


#' @export
ee_aggregate_array <- function(col, prop = "system:time_start") {
  props = col$aggregate_array(prop) %>% 
    ee$List$getInfo()
  props
}

#' @export
ee_systemIndex <- function(col) {
    ee_aggregate_array(col, "system:index")
}

#' @export
ee_imageClip <- function(x, mask = NULL) {
    if (!is.null(mask)) x = ee$Image$clip(x, mask)
    x
}

#' @export
ee_bandNames <- function(col) {
    col$first()$bandNames()$getInfo()
}

#' @export
ee_propertyNames <- function(col) {
    col$first()$propertyNames() %>% ee_getInfo()
}

#' @export
ee_filterDate <- function(col, date_start, date_end = NULL) {
    do.call(col$filterDate, list(date_start, date_end))
}

#' @export
ee_filterBounds <- function(col, geom) {
    col$filterBounds(geom)
}

#' @export
image_size <- function(x) {
    info <- magick::image_info(x)
    info[1, c("height", "width")]
}
