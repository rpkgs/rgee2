# library(rgee)
# ee_Initialize(drive = TRUE)
library(raster)
library(rgdal)
library(sf2)
library("rnaturalearth")
library("rnaturalearthdata")
library(gganimate)
# library()

files <- dir("/mnt/c/Users/kongdd/Google\ 云端硬盘/rgee", "ERA5_.*.tif", full.names = TRUE)

InitCluster(10, kill = FALSE)
# resampled into 0.5deg
lst <- plyr::llply(files, function(file) {
    r  = brick(file)
    r5 = aggregate(r, fact = 10)
    s  = as_SpatialGridDataFrame(r)

    df <- s %>% {cbind(.@data, coordinates(.))} %>%
        set_colnames(c("u", "v", "lon", "lat")) %>%
        data.table()
    df[, wind := sqrt(u^2 + v^2)]
    df
}, .parallel = TRUE)

df = set_names(lst, 1:12) %>% melt_list("month")
df$month %<>% as.integer()
df[, season := season(month)]

d = df[, map(.SD, mean, na.rm = TRUE), .(season, lon, lat), .SDcols = c("u", "v", "wind")]

library(purrr)
# r = brick(files[1])
world <- ne_countries(scale = "medium",
                      # country = "China",
                      returnclass = "sf")

d$season %<>%  factor(c("Spring", "Summer", "Autumn", "Winter"),
                     c("春", "夏", "秋", "冬") %>% label_tag())

save(d, file = "d.rda")
load("d.rda")
{
    # r = readGDAL(files[1])
    library(metR)
    library(ggplot2)
    library(gganimate)
    library(rcolors)
    brks = c(0, 1, 2, 3, 4, 5, 8, 10)
    nbrks = length(brks)
    cols  = get_color("amwg256", nbrks)

    range = c(108, 116,29, 34)
    scale = 1#/4
    p <- ggplot(d, aes(lon, lat)) +
        # geom_contour(aes(z = wind)) +
        geom_arrow(aes(dx = u, dy = v
                       # color = cut(wind, brks)
                       ),
                   size = 0.2,
                   skip = 2,
                   arrow = arrow(length = unit(0.2, "npc"))) +
        scale_mag("Wind (m/s)", max_size = 1, max = 2) +
        guides(color = FALSE) +
        # geom_segment(aes(x = lon, xend = lon + u*scale,
        #                  y = lat, yend = lat + v*scale,
        #                  color = cut(wind, brks)),
        #              size = 0.5,
        #              arrow = arrow(length = unit(0.1, "cm"))) +
        # geom_sf(data = world, aes(x = NULL, y = NULL),
        #         fill = "transparent",
        #         size = 0.5,
        #         color = "grey60") +
        geom_sf(data = shp, aes(x = NULL, y = NULL),
                fill = "transparent", size = 0.5, color = "grey60") +
        geom_sf(data = shp_wuhan, aes(x = NULL, y = NULL),
                fill = "transparent", size = 0.7, color = "red") +
        coord_sf(xlim = range[1:2], ylim = range[3:4]) +
        scale_x_continuous(breaks = seq(109, 115, 2)) +
        scale_y_continuous(breaks = seq(29, 34, 2)) +
        theme_grey(base_size = 14) +
        theme(
            legend.position = "bottom",
            legend.margin = margin(-10),
            # legend.position = c(0.02, 0.98),
            # legend.justification = c(0, 1),
            # legend.position = c(0.98, 0.01),
            # legend.justification = c(1, 0),
            legend.text = element_text(size = 14)) +
        facet_wrap(~season, labeller = "label_parsed") +
        labs(x = NULL, y = NULL) # , title = "Month of : {frame_time}

    write_fig(tag_facet(p,
                        label = "season",
                        # label.padding = unit(0.25, "lines"),
                        label.r = unit(0, "lines"),
                        label.size = NA,
                        family = "rTimes",
                        hjust = -0.2, vjust = 1.2,
                        size = 6,
                        # update_theme = TRUE,
                        parse = TRUE),
                        # x = Inf, y = 20, size = 6,
                        # vjust = 0, hjust = 1.1),
              "a.pdf", 11, 6.5, show = FALSE)
}

Ipaper::set_font()
shp = read_sf(path.mnt("d:/Documents/R/poly_湖北省市界.shp"))
shp_wuhan = read_sf(path.mnt("d:/Documents/R/poly_武汉市界.shp"))

# geom_streamline(aes(dx = u, dy = v))
# p
# p2 = p + transition_time(month) +
#     ease_aes("linear")
# job::job(result = {
#     library(gganimate)
# g = animate(p2, fps = 10)
# anim_save("china_wind.gif", )
# }, packages = "gganimate")
