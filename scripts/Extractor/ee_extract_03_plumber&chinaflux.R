library(rgee)
library(rfluxnet)
library(sf)
library(glue)

ee_Initialize(drive = TRUE)

prefix = "plumber&chinaflux"

outdir = "H:/global_WB/benchmark/FluxNet_CLEX_PLUMBER2/fluxnet.plumber2/data-raw"
outfile = glue("{outdir}/plumber&chinaflux_metadata_7years_final_st75.shp")
sp <- read_sf(outfile)

imgcol = ee$ImageCollection$Dataset$MODIS_006_MCD12Q1
proj = ee_get_proj(imgcol)
# scale = 463.3127
scale_5h = proj$scale # scale should lte prj.scale
sp2 = st_point_buffer(sp, scale = scale_5h, half_win = 10)
## 1km scale
scale_1k = ee_get_proj(ee$ImageCollection$Dataset$MODIS_006_MOD11A2)$scale
sp2_1km = st_point_buffer(sp, scale = scale_1k, half_win = 1)

# save(df, file = "data-raw/phenofit_NorthChinaPlain_test-(2015-2021)_3by3.rda")
## ALL the scale is 500m
## 1. vegetation index
ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MCD12Q1,
            sp2, via = "drive", lazy = TRUE,
            prefix = "plumber_chinaflux_st75_2000-2020_")

file = "C:/Users/kongdd/Google 云端硬盘/rgee_backup/st212_2000-2020_MODIS_006_MCD12Q1.csv"
drive_csv_clean(file, sp2)

## 1km scale dataset
# drive_csv_clean(file, sp2_1km)

# files <- dir("data-raw/st212/raw", full.names = TRUE)
# overwrite = FALSE
# for (infile in files) {
#     print(infile)
#     drive_csv_clean(infile, sp2)
# }
# file = "C:/Users/kongdd/Google 云端硬盘/rgee_backup/st212_2000-2020_ith06_MODIS_006_MOD15A2H.csv"
# file = "C:/Users/kongdd/Google 云端硬盘/rgee_backup/st212_2000-2020_MODIS_006_MCD12Q1.csv"
