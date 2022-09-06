
#' @title ee_date
#' @name ee_date
NULL

#' @rdname ee_date
#' @export
as_date_img <- function(x, prop = "system:time_start") {
  ee$Date(x$get(prop))$format("YYYY-MM-dd")
}

fmt <- "YYYY-MM-dd HH"
#' @rdname ee_date
#' @export
as_date_millis <- function(x) { # HH:mm:ss
  ee$Date(x)$format(fmt)
  # ee$Date(x)$format("YYYY-MM-dd")
}

#' @rdname ee_date
#' @export
str_date <- function(date) {
 ee$Date(date)$format(fmt) %>%
   getInfo() %>%
   gsub(" ", "T", .)
}

#' ee_systemtime
#'
#' Get imgcol or img "system:time_start" or "system:time_end"
#'
#' @param prop "system:time_start" or "system:time_end"
#' @rdname ee_date
#' @export 
ee_systemtime <- function(x, prop = "system:time_start") {
  class <- class(x)
  if ("ee.image.Image" %in% class) x <- ee$ImageCollection(x)
  x$aggregate_array(prop)$map(ee_utils_pyfunc(as_date_millis)) %>%
    getInfo() %>%
    gsub(" ", "T", .)
}

#' @return 
#' - `ee_yday`: ee.Number
#' @rdname ee_date
#' @export 
ee_yday <- function(x, ...) {
  date_begin <- ee$Date(x)
  year <- date_begin$get("year")
  doy <- date_begin$difference(ee$Date$fromYMD(year, 1, 1), "day")$add(1)
  doy
}

#' @rdname ee_date
#' @export
ee_timestart <- function(x) ee_systemtime(x, "system:time_start")

#' @rdname ee_date
#' @export
ee_timeend <- function(x) ee_systemtime(x, "system:time_end")

# #' @rdname ee_tools
# #' @export
# get_time <- function(img) {
#   ee$Date(img$get("system:time_start"))$format("yyyy-MM-dd")
# }


add_TimeProp <- function(img, pheno = FALSE) {
  date <- ee$Date(img$get("system:time_start"))
  month <- date$get("month")
  year <- date$get("year")
  ingrow <- ee$Algorithms$If(month$gte(4)$And(month$lte(10)), "true", "false")

  spring_begin <- ifelse(pheno, 4, 3)
  autumn_end <- ifelse(pheno, 10, 11)
  # /** 4-10 as growing season if pheno = TRUE */
  season <- ""
  season <- ee$Algorithms$If(month$lte(spring_begin - 1), ee_num2str(year$subtract(1))$cat("_winter"), season)
  season <- ee$Algorithms$If(month$gte(spring_begin)$And(month$lte(5)), ee_num2str(year)$cat("_spring"), season)
  season <- ee$Algorithms$If(month$gte(6)$And(month$lte(8)), ee_num2str(year)$cat("_summer"), season)
  season <- ee$Algorithms$If(month$gte(9)$And(month$lte(autumn_end)), ee_num2str(year)$cat("_autumn"), season)
  season <- ee$Algorithms$If(month$gte(autumn_end + 1), ee_num2str(year)$cat("_winter"), season)
	
  img$
    set("season", season)$
    set("ingrow", ingrow)$
    set("year-ingrow", year$format()$cat("-")$cat(ingrow))$
    set("year", year$format())$
    set("month", month$format("%02d"))$
    set("yearmonth", date$format("YYYY-MM")) # seasons$get(month$subtract(1))
}
