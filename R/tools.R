# img = col$first()
get_time <- function(img) {
  ee$Date(img$get('system:time_start'))$format('yyyy-MM-dd')
}

ee_getInfo <- function(x) {
    x$getInfo()
}
getInfo = ee_getInfo

ee_aggregate_array <- function(col, prop = "system:time_start") {
  props = col$aggregate_array(prop) %>% 
    ee$List$getInfo()
  props
}

ee_systemIndex <- function(col) {
    ee_aggregate_array(col, "system:index")
}

ee_imageClip <- function(x, mask = NULL) {
    if (!is.null(mask)) x = ee$Image$clip(x, mask)
    x
}

ee_bandNames <- function(col) {
    col$first()$bandNames()$getInfo()
}

ee_propertyNames <- function(col) {
    col$first()$propertyNames() %>% ee_getInfo()
}

ee_filterDate <- function(col, date_start, date_end = NULL) {
    do.call(col$filterDate, list(date_start, date_end))
}

ee_filterBounds <- function(col, geom) {
    col$filterBounds(geom)
}

image_size <- function(x) {
    info <- image_info(x)
    info[1, c("height", "width")]
    # list(height = info$height[1], width = info$width[1])
}
