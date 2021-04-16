#' ee_extract_clean
#' 
#' @author Song HeYang, Kong Dongdong
#' @importFrom tidyr pivot_longer pivot_wider
#' @export 
ee_extract_clean <- function(x) {
    pivot_longer(x,
             names_to = c("date", "band"),
             names_transform = list(date = lubridate::as_date),
             names_pattern = "X(.*\\d{2})_(.*)",
             cols = starts_with('X')) %>%
    pivot_wider(names_from = "band")
}

#' ee_extract2
#' 
#' @import rgee
#' @inheritParams rgee::ee_extract
#' @export
ee_extract2 <- function(x, y, fun = ee$Reducer$mean(), scale = NULL, ...) {
    if (is.null(scale)) scale = ee_get_proj(x)$scale
    ee_extract(x, y, fun, scale, ...) %>% ee_extract_clean()
}
