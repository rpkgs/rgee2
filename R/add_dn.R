# ee_utils_pyfunc
col_add_dn_date <- function(col, include.year = TRUE, chunksize = 8) {
  fun <- . %>% add_dn_date(., NULL, include.year, chunksize)
  col$map(ee_utils_pyfunc(fun))
}

#' add_dn_date
#' @export 
#' @rdname add_dn_date
add_dn_date <- function(img, date_begin=NULL, include.year=TRUE, chunksize=8) {
  if (is.null(date_begin)) date_begin = ee$Date(img$get("system:time_start"))
  
  year = date_begin$get("year")
  yearstr = year$format("%d")

  .di = cal_di(date_begin, chunksize)
  dndate = dndate_start(year, .di, chunksize)$format("yyyy-MM-dd")

  di = .di$format("%02d")
  di = ee$String(ee$Algorithms$If(include.year, yearstr$cat("-")$cat(di), di))
  
  ee$Image(img)$
    set('system:time_start', date_begin$millis())$
    set('date', date_begin$format('yyyy-MM-dd'))$
    # set("dndate", dndate)$
    set('year', yearstr)$
    set('month', date_begin$format('MM'))$
    set('yearmonth', date_begin$format('YYYY-MM'))$
    set('di', di)
}

#' @rdname add_dn_date
#' @export
cal_di <- function(date_begin, chunksize = 8) {
  date_begin = ee$Date(date_begin)
  month = date_begin$get("month")
  year = date_begin$get("year")
  yearstr = year$format("%d")

  doy = ee_yday(date_begin)
  di = doy$subtract(1)$divide(chunksize)$floor()$add(1)$
    int()
  di
}

#' @examples 
#' \dontrun{
#' dndate_start(2020, 46) %>% cal_di(include.year = FALSE)
#' }
#' @rdname add_dn_date
#' @export 
dndate_start <- function(year, di, chunksize = 8) {
  doy <- ee$Number(di)$subtract(1)$multiply(chunksize)$add(1)
  datestr <- ee$Number(year)$format("%d")$cat(doy$format("%03d"))
  ee$Date$parse("YYYYDDD", datestr)
}


#' @export
get_date_dn <- function(date_begin = "2000-02-26", date_end = "2020-12-31", dn = 16) {
  years <- seq(year(date_begin), year(date_end))
  dates <- lapply(years, function(year) {
    doy <- seq(1, 365, dn)
    as.Date(sprintf("%d-%03d", year, doy), "%Y-%j")
  }) %>% do.call(c, .)
  dates[dates >= date_begin & dates <= date_end]
}
