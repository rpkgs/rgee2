#' @title rgee `imgcol` tools collection
#' @name ee_tools
NULL

check_imgcol <- function(x) {
  if ("ee.image.Image" %in% class(x)) x <- ee$ImageCollection(x)
  x
}

#' @rdname ee_tools
#' @export
ee_getInfo <- function(x) {
  x$getInfo()
}

#' @rdname ee_tools
#' @export
ee_num2str <- function(x) {
  x$format("%d")
}

#' @rdname ee_tools
#' @export
getInfo <- ee_getInfo

#' @rdname ee_tools
#' @export
getInfo2 <- . %>%
  ee_getInfo() %>%
  str()

#' @rdname ee_tools
#' @export
ee_aggregate_array <- function(col, prop = "system:time_start") {
  col %<>% check_imgcol()
  props <- col$aggregate_array(prop) %>%
    ee$List$getInfo()
  props
}

#' @rdname ee_tools
#' @export
ee_systemIndex <- function(col) {
  ee_aggregate_array(col, "system:index")
}


#' @export
ee_imageClip <- function(x, mask = NULL) {
  if (!is.null(mask)) x <- ee$Image$clip(x, mask)
  x
}

#' @rdname ee_tools
#' @export
ee_first <- function(col) {
  col$first()
}

#' @rdname ee_tools
#' @export
ee_last <- function(col) {
  n <- col$size()
  l <- col$toList(n)
  l <- l$slice(n$subtract(1), n)
  ee$Image(l$get(0))
}

#' @rdname ee_tools
#' @export
ee_bandNames <- function(x) {
  x %<>% check_imgcol()
  x$first()$bandNames()$getInfo()
}

#' @rdname ee_tools
#' @export
ee_propertyNames <- function(col) {
  col %<>% check_imgcol()
  col$first()$propertyNames() %>% ee_getInfo()
}

#' @rdname ee_tools
#' @export
ee_properties <- function(col, verbose = TRUE) {
  col %<>% check_imgcol()
  ans <- col$first()$getInfo()$properties
  if (verbose) {
    cat(str(ans))
    invisible()
  } else {
    ans
  }
}

#' @rdname ee_tools
#' @export
ee_filterDate <- function(col, date_start, date_end = NULL) {
  do.call(col$filterDate, list(date_start, date_end))
}

#' @rdname ee_tools
#' @export
ee_filterBounds <- function(col, geom) {
  col$filterBounds(geom)
}

#' @rdname ee_tools
#' @export
image_size <- function(x) {
  info <- magick::image_info(x)
  info[1, c("height", "width")]
}
