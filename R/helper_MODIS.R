#' @importFrom lubridate make_date
#' @export 
get_date_MODIS <- function(date_begin = make_date(2000, 02, 18),
                           date_end = make_date(2020, 12, 31), dn = 8) {
  year_begin <- year(date_begin)
  year_end <- year(date_end)

  years <- year_begin:year_end
  doys <- seq(1, 366, dn)

  nyear <- length(years)
  ndoy <- length(doys)

  years <- rep(years, each = ndoy)
  doys <- rep(doys, nyear)
  str <- sprintf("%d%03d", years, doys)
  dates <- as.Date(str, "%Y%j")
  dates[dates >= date_begin & dates <= date_end]
}
