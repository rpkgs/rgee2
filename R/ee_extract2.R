#' ee_extract_clean
#' 
#' @author Song HeYang, Kong Dongdong
#' @importFrom tidyr pivot_longer pivot_wider
#' @export 
ee_extract_clean <- function(x) {
    if (is.character(x)) x = fread(x)
    pivot_longer(x,
             names_to = c("date", "band"),
            #  names_transform = list(date = lubridate::as_date),
            #  names_transform = list(date = function(x) as.Date(paste0(x, "01"), format = "%Y%m%d")),
             names_pattern = "(\\d{4}.*\\d{2})_(.*)",
            #  names_pattern = "(\\d{4}.*\\d{2})_(.*)",
             cols = matches("\\d{4}")) %>%
    pivot_wider(names_from = "band") %>% data.table()
}

#' ee_extract2
#' 
#' @import rgee
#' @inheritParams rgee::ee_extract
#' @export
ee_extract2 <- function(imgcol, y, fun = ee$Reducer$mean(), scale = NULL, 
    prefix = "", lazy = FALSE, ...) 
{
    id = imgcol$limit(1)$get("system:id") %>% getInfo() %>% gsub("/", "_", .)
    outfile = paste0(prefix, id, ".csv")
    if (is.null(scale)) scale = ee_get_proj(imgcol)$scale

    df = .ee_extract(imgcol, y, fun, scale, dsn = outfile, lazy = lazy, ...) 
    if (!lazy && !is.null(outfile)) {
        ee_extract_clean(df) %>% fwrite(outfile)
        return(df)
    } else invisible()
}

#' @import data.table
#' @export
drive_csv_clean <- function(infile, sp2, outfile = NULL, overwrite = FALSE) {
    if (is.null(outfile))
        outfile = paste0(dirname(dirname(infile)), "/", basename(infile))
    if (file.exists(outfile) && !overwrite) return()

    table_sf = fread(infile)
    table_sf[, `:=`(`system:index` = NULL, ee_ID = NULL, .geo = NULL)]

    df = sp2 %>% sf::st_drop_geometry() %>% cbind(table_sf) %>% ee_extract_clean()
    fwrite(df, outfile)
}
