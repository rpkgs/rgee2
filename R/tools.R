check_imgcol <- function(x) {
    if ("ee.image.Image" %in% class(x)) x = ee$ImageCollection(x)
    x
}

#' @export
get_time <- function(img) {
  ee$Date(img$get('system:time_start'))$format('yyyy-MM-dd')
}

#' @export
ee_getInfo <- function(x) {
    x$getInfo()
}

ee_num2str <- function(x) {
    x$format("%d")
}

#' @export
getInfo = ee_getInfo

#' @export
getInfo2 = . %>% ee_getInfo() %>% str()

#' @export
ee_aggregate_array <- function(col, prop = "system:time_start") {
  col %<>% check_imgcol()
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

ee_first <- function(col) {
    col$first()
}

ee_last <- function(col) {
    n = col$size()
    list = col$toList(n)
    list$slice(n$substract(1), n)
    col$first()
}

#' @export
ee_bandNames <- function(x) {
    x %<>% check_imgcol()
    x$first()$bandNames()$getInfo()
}

#' @export
ee_propertyNames <- function(col) {
    col %<>% check_imgcol()
    col$first()$propertyNames() %>% ee_getInfo()
}

#' @export
ee_properties <- function(col, verbose = TRUE) {
    col %<>% check_imgcol()
    ans = col$first()$getInfo()$properties
    if (verbose) {
        cat(str(ans))
        invisible()
    } else ans
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

#' @import crayon
#' @export
print.ee.image.Image <- function(x, ...) {
    # ok(bold("ee$Image:"))
    bands = x$bandNames()$getInfo()
    bands_str = paste(bands, collapse = ', ')
    fun = . %>% { bold(green(underline(.))) }

    fprintf("%s: \n%s\n", fun("bandNames"), (bands_str))
    fprintf("%s: \n", fun("Properties"))
    ee_properties(x, verbose = TRUE)
}

#' @export
print.ee.imagecollection.ImageCollection <- function(x, ...) {
    n = x$size()$getInfo()
    fun = . %>% { bold(green(underline(.))) }
    fprintf("%s, n = %02d\n", fun("[ee.ImageCollection]"), n)

    img = x$first()
    print.ee.image.Image(img)
}
