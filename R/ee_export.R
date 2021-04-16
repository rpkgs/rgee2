#' Get projection of ee.Image or ee.ImageCollection
#' 
#' @param imgcol ee.Image or ee.ImageCollection
#' 
#' @note After `map` operation, scale and transform information will disappear.
#' @return
#' - proj
#' - scale
#' - crs
#' - transform
#' @export 
ee_get_proj <- function(imgcol) {
    imgcol = ee$ImageCollection(imgcol)
    proj <- imgcol$first()$select(0)$projection()
    proj_val <- getInfo(proj)

    transform <- proj_val$transform %>% unlist()
    listk(proj, scale = transform[1], crs = proj_val$crs, transform)
}

#' @import rgee
ee_imgcol <- function(x) ee$ImageCollection(x)
