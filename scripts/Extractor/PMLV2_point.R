library(rgee)
library(rfluxnet)
library(sf)
library(sf2)

ee_Initialize(drive = TRUE)

df = read_xlsx2list("C:/Users/kongdd/Desktop/chinamete_soiltype.xlsx")[[1]] %>% data.table()
sp <- df[, .(site, lon, lat)] %>% df2sp() %>% st_as_sf()

imgcol = ee$ImageCollection("CAS/IGSNRR/PML/V2")
# imgcol = ee$ImageCollection$Dataset$MODIS_006_MOD15A2H
proj = ee_get_proj(imgcol)
scale = proj$scale # scale should lte prj.scale
# scale = 463.3127
# sp2 = st_point_buffer(sp, scale = scale, half_win = 1)

# save(df, file = "data-raw/phenofit_NorthChinaPlain_test-(2015-2021)_3by3.rda")
## ALL the scale is 500m
## 1. vegetation index
ee_extract2(imgcol,
            sp, via = "drive", lazy = TRUE,
            prefix = "chinamete_2474_2002-2017_")

ee_extract2(ee$ImageCollection("projects/pml_evapotranspiration/PML/OUTPUT/PML_V2_8day_v017"),
            sp, via = "drive", lazy = TRUE,
            prefix = "ChinaMete_2474_2000-2020_")
