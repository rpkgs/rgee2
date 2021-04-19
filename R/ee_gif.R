#' ee_gif
#'
#' @param mask  (Feature|Geometry|Object) The Geometry or Feature to clip to.
#' @param region (optional) ee$Geometry$Polygon, GeoJSON or c(E,S,W,N). Geospatial region
#' of the result. By default, the whole image.
#'
#' @param dimensions A number or pair of numbers in format c(WIDTH,HEIGHT).
#' Max dimensions of the thumbnail to render, in pixels. If only one number is passed,
#' it is used as the maximum, and the other dimension is computed by proportional scaling.
#' @param crs A CRS string specifying the projection of the output.
#' "EPSG:4326" and "EPSG:3857" (Web Mercator projection) are the most frequent used.
#' @param crs_transform The affine transform to use for the output pixel grid.
#' @param scale A scale to determine the output pixel grid; ignored if both crs
#' and crs_transform are specified.
#' @param format String. The output format (only 'gif' is currently supported).
#' @param framesPerSecond String. Animation speed.
ee_gif <- function(imgcol, vis = NULL, mask = NULL, reigon = NULL, dimensions = 600,
    crs = "EPSG:3857", framesPerSecond = 2)
{
    bands <- ee_bandNames(imgcol)
    imgcol_vis <- imgcol$map(function(img) {
        ans = img
        if (!is.null(vis)) ans = do.call(img$visualize, vis)
        ans %<>% ee_imageClip(mask)
        ans
    })

    if (is.null(region)) region = mask$geometry()$bounds()

    gifParams <- listk(region, dimensions, crs, framesPerSecond)
    animation <- .ee_utils_gif_creator(imgcol_vis, gifParams)
    animation
}

.ee_utils_gif_creator <- function (ic, parameters, outfile = "tmp.gif", quiet = FALSE, ...) {
    rgee:::ee_check_packages("ee_utils_gif_creator", "magick")
    if (!quiet) {
        message("1. Creating gif ... please wait ....")
    }
    animation_url <- ee$ImageCollection$getVideoThumbURL(ic, parameters)
    # temp_gif <- tempfile()
    if (!quiet) {
        message("1. Downloading GIF from: ", animation_url)
    }
    download.file(url = animation_url, destfile = outfile, quiet = quiet, mode = "wb", ...)
    magick::image_read(path = outfile)
}
