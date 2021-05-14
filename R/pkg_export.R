.option_img <- list2env(
    list(
        range = c(-180, -60, 180, 90), cellsize = NULL,
        folder = "",
        proj = NULL,
        scale = NULL,
        crs = "EPSG:4326",
        crsTransform = NULL,
        dimensions = NULL,
        verbose = FALSE,
        filterProp = "system:time_start",
        type = "drive"
    )
)

#' export_Img
#'
#' # Some options to clip regional data
#' * 1. crs + region + crsTransform    | √
#' * 2. crs + region + dimensions      | √ (resample)
#' * 3. crs + region + scale           | √
export_Img <- function(img, task, options) {
    options %<>% modifyList(.option_img, .)
    description = task

    range    = options$range
    cellsize = options$cellsize
    proj     = options$proj
    region   = ee$Geometry$Rectangle(options$range, "EPSG:4326", FALSE)

    # crsTransform <- dimensions <- NULL
    if (!is.null(cellsize)) {
        nrow <- round(diff(range[c(1, 3)]) / cellsize)
        ncol <- round(diff(range[c(2, 4)]) / cellsize)
        options$dimensions = paste0(nrow, "x", ncol)
    } else if (is.null(options$scale)) {
        if (is.null(proj)) proj = ee_get_proj(img)
        options$crs = proj$crs
        options$crsTransform = proj$transform
    }

    params = listk(image = img, region, description,
        timePrefix = FALSE, maxPixels  = 1e13) %>%
        c(mget(c("folder", "crs", "crsTransform", "dimensions", "scale"), options))
    # browser()
    if (options$verbose) str(params) %>% rm_empty() %>% print()
    do.call(ee_image_to_drive, params)$start()
}

export_ImgCol <- function(imgcol, prefix, options, props = NULL) {
    filterProp = if (is.null(options$filterProp)) "system:time_start" else options$filterProp
    if (is.null(props)) {
        if (filterProp == "system:time_start") {
            props <- ee_systemtime(imgcol, filterProp)
        } else {
            props <- ee_aggregate_array(imgcol, filterProp)
        }
    }

    for (i in seq_along(props)) {
        prop = props[i]
        task = paste0(prefix, prop)

        if (filterProp == "system:time_start") {
            img = imgcol$filterDate(prop)$first()
        } else {
            img = imgcol$filterMetadata(filterProp, "equals", prop)$first()
        }
        # browser()
        export_Img(img, task, options)
    }
}

#' @export
map_col <- function(col, fun, ...) {
    ids <- col %>% ee_systemIndex()
    plyr::llply(ids, function(id) {
        x <- col$filter(ee$filter$Filter$eq("system:index", id))$first()
        fun(x, ...)
    }, .progress = "text")
}
