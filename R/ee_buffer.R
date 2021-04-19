#' ee_point_buffer
#'
#' @param st data.table with the columns at least of `site`, `lon`, and `lat`.
#' @param scale in the unit of `m`
#' @param half_win half window of the buffer (in grids). window size equals to
#' `2*halfwin + 1`.
#'
#' @examples
#' \dontrun{
#' st = st_212[, .(site, lon, lat, IGBP)]
#' st_point_buffer_3by3(st, 500)
#' }
#' @import sf2
#' @export
st_point_buffer <- function(sp, scale = 500, half_win = 1){
    st = as.data.table(sp)
    cellsize = scale/500 * 1/240

    win = half_win*2 + 1
    lon      = c(-half_win, 0, -half_win) %>% rep(win) %>% multiply_by(cellsize)
    lat      = c(-half_win, 0, -half_win) %>% rep(each = win) %>% multiply_by(cellsize)
    adj_mat  = cbind(lon, lat)

    grps = 1:nrow(adj_mat) %>% set_names(., .)
    df = lapply(grps, function(i) {
        d = st
        delta_x = adj_mat[i, 1]
        delta_y = adj_mat[i, 2]
        d$lon %<>% add(delta_x)
        d$lat %<>% add(delta_y)
        d
    }) %>% melt_list("group")

    df %>% df2sp() %>%
        st_as_sf()
}

#' colors to hex
#' 
#' @param cname color names
#' @examples
#' col2hex("grey60")
#' @export
col2hex <- function (cname) {
    colMat <- col2rgb(cname)/255
    rgb(red = colMat[1, ], green = colMat[2, ], blue = colMat[3,])
}
