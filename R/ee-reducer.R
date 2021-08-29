combineReducers <- function(reducers) {
    combine <- function(reducer, prev) reducer$combine(prev, NULL, TRUE)
    reduce(reducers, combine)
}

range <- c(-180, -60, 180, 90)
geom_global <- ee$Geometry$Rectangle(range, "EPSG:4326", FALSE) # c(xmin, ymin, xmax, ymax)

ee_stat <- function(imgcol, year = NULL, scale = 5000) {
    reducer = c(ee$Reducer$mean(), ee$Reducer$count(), ee$Reducer$sum()) %>% combineReducers()

    if (!is.null(year)) {
        filter = ee$filter$Filter$calendarRange(year, year, "year")
        img = imgcol$filter(filter)$first()
    } else {
        img = imgcol
    }
    img_area <- ee$Image$pixelArea()$divide(1e6)
    img$reduceRegion(
        reducer = reducer, geometry = geom_global, scale = scale,
        maxPixels = 1e13, tileScale = 16
    ) %>% getInfo() %>% as.data.table() %>% cbind(year = year, .)
}
