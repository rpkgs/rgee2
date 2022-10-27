# library(rgee)
library(rgee2)
library(rcolors)

ee_init()

## global variables ------------------------------------------------------------
system.time({
  bands <- c("NDVI", "EVI", "DayOfYear", "SummaryQA")
  col <- ee$ImageCollection("MODIS/006/MOD13A1")$
    select(bands)$
    filterDate("2000-01-01", "2022-12-31")

  col = col_add_dn_date(col, include.year = FALSE, chunksize = 16)
  # ee_aggregate_array(col, "di")
  col_clim = col$filterDate("2000-01-01", "2021-12-31")
  col_2022 = col$filterDate("2022-01-01", "2022-12-31")

  # 根据doy进行aggregate，计算气候态均值
  system.time(lst_mean <- ee_aggregate_list(col_clim, "di", "mean"))
  system.time(lst_sd <- ee_aggregate_list(col_clim, "di", "stdDev"))
  # lst_mean[[1]]
  # lst_sd[[1]]
})
# names(lst_clim)
# system.time(print(lst_clim))

# system.time( ee_systemtime(img_clim) )

# col_2022$first()
img_latest = ee_last(col)
di = img_latest$get("di") %>% getInfo()
mean <- lst_mean[[di]]
sd <- lst_sd[[di]]
# img_diff <- img_latest$select(0)$subtract(mean)#$divide(sd)
img_diff_norm <- img_latest$select(0)$subtract(mean)$divide(sd)

## check about image qc
{
  color <- rcolors$MPL_RdYlGn
  delta = 1
  vis_vi <- list(
    bands = c("NDVI"), palette = color,
    min = -delta, max = delta
  )
  Map$addLayer(img_diff_norm, vis_vi, "NDVI anomaly normalize") +
    Map$addLegend(vis_vi)
}

{
  color <- rcolors$MPL_RdYlGn
  vis_vi <- list(
    bands = c("NDVI_mean"), palette = color,
    min = 1000, max = 7000
  )
  Map$addLayer(img_clim$first(), vis_vi, "NDVI")+
    Map$addLegend(vis_vi)
}

# TODO:
# - 添加省界

# proj <- ee_get_proj(imgcol)
# scale <- proj$scale # scale should lte prj.scale
# sp2 <- st_point_buffer(sp, scale = scale)
