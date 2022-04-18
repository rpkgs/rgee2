library(rgee)
library(rfluxnet)
library(sf)
library(sf2)

ee_Initialize(drive = TRUE)

sp <- st_flux212[, .(site, lon, lat)] %>% df2sp() %>% st_as_sf()

imgcol = ee$ImageCollection$Dataset$MODIS_006_MOD15A2H
proj = ee_get_proj(imgcol)
scale = proj$scale # scale should lte prj.scale
# scale = 463.3127
sp2 = st_point_buffer(sp, scale = scale, half_win = 1) # -half_win: half_win
sp_5 = st_point_buffer(sp, scale = scale, half_win = 2)

# save(df, file = "data-raw/phenofit_NorthChinaPlain_test-(2015-2021)_3by3.rda")
## ALL the scale is 500m
## 1. vegetation index
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

ee_extract2( ee$ImageCollection$Dataset$MODIS_006_MOD09GA,
            sp2, via = "drive", lazy = TRUE, scale = scale,
            prefix = "st212_SR_MOD09GA_2000-2020_")
ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MCD12Q1,
            sp2, via = "drive", lazy = TRUE,
            prefix = "st212_2000-2020_")

ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MCD43A3$select('Albedo_WSA_shortwave'),
            sp2, via = "drive", lazy = TRUE,
            prefix = "st212_2000-2020_")

ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MCD12Q1,
            sp_5, via = "drive", lazy = TRUE,
            prefix = "st212_win5_2000-2020_")

## ET and GPP
ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MOD16A2,
            sp2, via = "drive", lazy = TRUE,
            prefix = "st212_ET-mod_2000-2020_")
ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MOD17A2H,
            sp2, via = "drive", lazy = TRUE,
            prefix = "st212_GPP-mod_2000-2020_")

## 1km scale dataset
# Emissivity
scale_1km = ee_get_proj(ee$ImageCollection$Dataset$MODIS_006_MOD11A2)$scale
sp2_1km = st_point_buffer(sp, scale = scale_1km, half_win = 1)
ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MOD11A2,
            sp2_1km, via = "drive", lazy = TRUE,
            prefix = "st212_Tland_2000-2020_")

drive_csv_clean(file, sp2_1km)
drive_csv_clean(file, sp2)


files <- dir("data-raw/st212/raw", full.names = TRUE)
overwrite = FALSE
for (infile in files) {
    print(infile)
    drive_csv_clean(infile, sp2)
}

file = "C:/Users/kongdd/Google 云端硬盘/rgee_backup/st212_2000-2020_ith06_MODIS_006_MOD15A2H.csv"
file = "C:/Users/kongdd/Google 云端硬盘/rgee_backup/st212_2000-2020_MODIS_006_MCD12Q1.csv"
