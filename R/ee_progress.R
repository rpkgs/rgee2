#' @export
get_date_dn <- function(date_begin = "2000-02-26", date_end = "2022-12-31", dn = 16) {
    years <- seq(year(date_begin), year(date_end))
    dates <- lapply(years, function(year) {
        doy <- seq(1, 365, dn)
        as.Date(sprintf("%d-%03d", year, doy), "%Y-%j")
    }) %>% do.call(c, .)
    dates[dates >= date_begin & dates <= date_end]
}

get_date_MODIS = get_date_dn

get_finished <- function(imgcol, date_begin = "1981-01-01", date_end = "2020-12-31") {
    imgcol = imgcol$filterDate(date_begin, date_end)
    dates = ee_systemtime(imgcol) %>% substr(1, 10)
    dates_all = seq(as.Date(date_begin), as.Date(date_end), by = "month") %>% as.character()
    # dates_all = get_date_dn(date_begin = "2000-01-01", dn = 8) %>% as.character()
    dates_miss = setdiff(dates_all, dates) #%>% year() %>% table()
    
    d_miss = data.table(date = dates) %>% mutate(year = year(date))
    info  = d_miss[, .N, .(year)]
    fprintf("%s: %d/%d finished!\n", 
        Sys.time() %>% as.character(),
        sum(info$N), length(dates_all))
    listk(d_miss, info)
}

get_missInfo <- function(imgcol, date_begin = "1981-01-01", date_end = "2020-12-31", by = "month") {
    imgcol = imgcol$filterDate(date_begin, date_end)
    dates = ee_systemtime(imgcol) %>% substr(1, 10)
    
    # dates_all = seq(as.Date(date_begin), as.Date(date_end), by = "month") %>% as.character()
    dates_all = get_date_dn(date_begin, date_end, dn = 8) %>% as.character()
    dates_miss = setdiff(dates_all, dates) #%>% year() %>% table()
    
    d_miss = data.table(date = dates_miss) %>% dplyr::mutate(year = year(date))
    info  = d_miss[, .N, .(year)]
    fprintf("%s: %d/%d missing!\n", 
        Sys.time() %>% as.character(),
        sum(info$N), length(dates_all))
    listk(d_miss, info)
}
