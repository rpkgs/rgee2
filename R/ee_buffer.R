#' ee_point_buffer
#'
#' @param st data.table with the columns at least of `site`, `lon`, and `lat`.
#' @param scale in the unit of `m`
#' @param half_win half window of the buffer (in grids). window size equals to
#' `2*halfwin + 1`.
#'
#' @examples
#' \dontrun{
#' st <- st_212[, .(site, lon, lat, IGBP)]
#' st_point_buffer_3by3(st, 500)
#' }
#' @export
st_point_buffer <- function(st, scale = 500, half_win = 1) {
  # st <- as.data.table(sp)
  cellsize <- scale / 500 * 1 / 240
  
  win <- half_win * 2 + 1
  lon <- seq(-half_win:half_win) * cellsize
  lat <- seq(-half_win:half_win) * cellsize
  adj_mat <- expand.grid(lon = lon, lat = lat)

  grps <- 1:nrow(adj_mat) %>% set_names(., .)
  df <- lapply(grps, function(i) {
    d <- st
    delta_x <- adj_mat[i, 1] # lon
    delta_y <- adj_mat[i, 2]
    d$lon %<>% add(delta_x)
    d$lat %<>% add(delta_y)
    d
  }) %>% Ipaper::melt_list("group")

  df %>% df2sf()
}

#' df2sf
#' @example R/examples/ex-df2sf.R
#' @keywords internal
#' @export 
df2sf <- function(d, coords = c("lon", "lat"), crs = 4326) {
  sf::st_as_sf(d, coords = coords, crs = crs)
}
