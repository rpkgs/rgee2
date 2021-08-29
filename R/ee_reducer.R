combineReducers <- function(reducers) {
    combine <- function(reducer, prev) reducer$combine(prev, NULL, TRUE)
    reduce(reducers, combine)
}

#' @export 
ee_rect <- function(range = c(-180, -60, 180, 90)) {
    if (is.null(range)) range = c(-180, -60, 180, 90)
    ee$Geometry$Rectangle(range, "EPSG:4326", FALSE) # c(xmin, ymin, xmax, ymax)
}

#' @export 
ee_stat <- function(imgcol, year = NULL, scale = 5000, range = NULL) {
    reducer = c(ee$Reducer$mean(), ee$Reducer$count(), ee$Reducer$sum()) %>% combineReducers()

    if (!is.null(year)) {
        filter = ee$filter$Filter$calendarRange(year, year, "year")
        img = imgcol$filter(filter)$first()
    } else {
        img = imgcol
    }
    img_area <- ee$Image$pixelArea()$divide(1e6)
    img$reduceRegion(
        reducer = reducer, geometry = ee_rect(range), scale = scale,
        maxPixels = 1e13, tileScale = 16
    ) %>% getInfo() %>% as.data.table() %>% cbind(year = year, .)
}
