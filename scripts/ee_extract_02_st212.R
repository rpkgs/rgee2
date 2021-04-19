library(rgee)
library(rfluxnet)
ee_Initialize(drive = TRUE)

sp <- st_flux212[, .(site, lon, lat)] %>% df2sp() %>% st_as_sf()

imgcol = ee$ImageCollection$Dataset$MODIS_006_MOD15A2H
proj = ee_get_proj(imgcol)
scale = proj$scale # scale should lte prj.scale
# scale = 463.3127
sp2 = st_point_buffer(sp, scale = scale)

# save(df, file = "data-raw/phenofit_NorthChinaPlain_test-(2015-2021)_3by3.rda")
ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MOD15A2H,
            sp2, via = "drive", lazy = TRUE,
            prefix = "st212_2000-2020_")
ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MCD15A3H,
            sp2, via = "drive", lazy = TRUE,
            prefix = "st212_2000-2020_")
ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MOD13A1,
            sp2, via = "drive", lazy = TRUE,
            prefix = "st212_2000-2020_")
ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MOD13A2,
            sp2, via = "drive", lazy = TRUE,
            prefix = "st212_2000-2020_")
