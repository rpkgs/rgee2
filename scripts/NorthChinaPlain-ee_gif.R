library(magick)
library(rgee)
library(sf)
# ee_Initialize()
imgcol = ee$ImageCollection$Dataset$MODIS_006_MOD13A2
dates = imgcol %>% ee_timestart() %>% getInfo()

poly <- read_sf("/mnt/o/ChinaBasins/dem_raw/NorthChina/bou2_NorthChina_4p.shp")[1:6, ]
mask <- sf_as_ee(poly)
# region <- mask$geometry()$bounds()

# img = imgcol$first()
# load_all("/mnt/n/Research/r_pkgs/rgee")
vis <- list( min = 0.0, max = 8000.0, bands = "EVI", palette = palette_VI)

# dates = ee_systemIndex(imgcol)
# dates %<>% gsub("_", "-", .)
gif = ee_gif(imgcol$limit(80), vis, mask = mask)
system.time({
  size = image_size(gif)
  loc_date = sprintf("+%d+%d", floor(size$width * 0.6), floor(size$height * 0.9))
  gif %>%
    # ee_utils_gif_annotate(
    #   text = "EVI: MODIS/006/MOD13A2",
    #   size = 20, color = "white", location = "+10+10"
    # ) %>%
    ee_utils_gif_annotate(
      text = dates[1:80],
      size = 30, location = loc_date, # "+20+350",
      color = "white", font = "arial", boxcolor = "#000000"
    ) -> animation_wtxt
  # animation_wtxt
  ee_utils_gif_save(animation_wtxt, path = "raster_as_ee2.gif")
}
