print_title <- function(x) bold(green(underline(x)))

print_time <- function(col) {
  time <- ee_systemtime(col)
  head <- head(time) %>% paste(collapse = ",")
  tail <- tail(time) %>% paste(collapse = ",")
  sprintf("%s, ..., %s", head, tail)
}

#' @import crayon
#' @export
print.ee.image.Image <- function(x, ...) {
  # ok(bold("ee$Image:"))
  bands <- x$bandNames()$getInfo()
  bands_str <- paste(bands, collapse = ", ")
  
  fprintf("%s: \n%s\n", print_title("bandNames"), (bands_str))
  fprintf("%s: \n", print_title("Properties"))
  ee_properties(x, verbose = TRUE)
}

#' @export
print.ee.imagecollection.ImageCollection <- function(x, ...) {
  n <- x$size()$getInfo()
  fprintf("%s: n = %02d\n", print_title("[ee.ImageCollection]"), n)
  fprintf("%s: %s\n", print_title("time"), print_time(x))

  img <- x$first()
  print.ee.image.Image(img)
}

#' @export
print.ee.ee_date.Date <- function(x, ...) {
  fprintf(
    "%s: %s\n", print_title("[ee.Date]"),
    str_date(x)
  )
}

#' @export
print.ee.ee_number.Number <- function(x, ...) {
  fprintf(
    "%s: %s\n", print_title("[ee.Number]"),
    getInfo(x)
  )
}

#' @export
print.ee.ee_string.String <- function(x, ...) {
  fprintf(
    "%s: '%s'\n", print_title("[ee.String]"),
    getInfo(x)
  )
}

#' @export
print.ee.ee_list.List <- function(x, ...) {
  fprintf(
    "%s: [%s]\n", print_title("[ee.List]"),
    getInfo(x) %>% paste(collapse = ", ")
  )
}
