library(rgee)
library(sf)
library(sf2)
library(magrittr)
library(Ipaper)

devtools::load_all()
# ee_Initialize(user = "cuijian426", drive = TRUE)
ee_Initialize(drive = TRUE)

## 1. read tested points
sp <- read_sf("G:/Researches/gee_Whittaker_V2/data/shp/NorthChina_2GS_testPoints_sp200.shp")
sp %<>% dplyr::mutate(ID = 1:nrow(.)) %>% dplyr::select(ID)

## 2. clip EVI data by `rgee`
bands = c("NDVI", 'EVI', 'DayOfYear', 'SummaryQA')
imgcol <- ee$ImageCollection('MODIS/006/MOD13A1')$
    select(bands)$
    filterDate('2000-01-01', '2020-12-31')
proj = ee_get_proj(imgcol)
scale = proj$scale # scale should lte prj.scale
sp2 = st_point_buffer(sp, scale = scale)

prefix = "NorthChina_st200_2000-2020_"




## 1. Vegetation Index
ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MOD15A2H$
                select(c("Lai_500m", "FparLai_QC", "FparExtra_QC")),
            sp2, via = "drive", lazy = TRUE, prefix = prefix)
ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MCD15A3H$
                select(c("Lai", "FparLai_QC", "FparExtra_QC")),
            sp2, via = "drive", lazy = TRUE, prefix = prefix)

ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MOD13A1$
                select(c("NDVI", 'EVI', 'DayOfYear', 'SummaryQA')),
            sp2, via = "drive", lazy = TRUE, prefix = prefix)

## 2. ET products, 500m
# - MODIS ET
ee_extract2(ee$ImageCollection$Dataset$MODIS_006_MOD16A2$select(0:3),
            sp2, via = "drive", lazy = TRUE, prefix = prefix)

# - PMLV2 ET, v014
ee_extract2(ee$ImageCollection("CAS/IGSNRR/PML/V2")$select(0:4),
            sp2, via = "drive", lazy = TRUE, prefix = prefix)

# - PMLV2 ET, v017
col = ee$ImageCollection("projects/pml_evapotranspiration/PML/OUTPUT/PML_V2_8day_v017")$select(0:4)
col2 = ee$ImageCollection(col$toList(9999))
# col = col$map(function(img) {
#     ee$Image(img)$unmask(-99)
# })
ee_extract2(col2,
            sp2, via = "drive", lazy = TRUE, scale = scale,
            outfile = "NorthChina_st200_2000-2020_CAS_IGSNRR_PML_V2_v017.csv",
            prefix = prefix)

## 3. Reanalysis data
# 1. GLDAS Evap_tavg, kg/m^2/s, Evapotranspiration
ee_extract2(ee$ImageCollection("NASA/GLDAS/V021/NOAH/G025/T3H")$select("Evap_tavg"),
            sp, via = "drive", lazy = TRUE, prefix = prefix) #

#2. ERA5L
bands = "ET"
years = rev(2000:2007)
temp = foreach(year = years, i = icount()) %do% {
    runningId(i)
    # year = 2010
    # month = 1
    filter <- ee$filter$Filter$calendarRange(year, year, "year")
    col <- ee$ImageCollection("ECMWF/ERA5_LAND/HOURLY")$
        filter(ee$filter$Filter$calendarRange(year, year, "year"))$
        # filter(ee$filter$Filter$calendarRange(month, month, "month"))$
        map(tidy_ERA5)$
        select(bands)
    dates_daily = seq(make_date(year), make_date(year, 12, 31), by = "day") %>% format()
    # dates = ee_timestart(col)
    # dates_daily = substr(dates, 1, 10) %>% unique()

    res <- map(dates_daily, ~ aggregate_ERA5_daily(.x, col, bands))
    res <- ee$ImageCollection(res)
    tmp <- ee_extract2(res,
                       sp,
                       via = "drive", lazy = TRUE, scale = 10e3, # 10km
                       # sp, via = "getInfo", lazy = FALSE, scale = 10e3,#10km
                       outfile = glue("ET_NorthChina_ERA5L_{year}.csv")
    )
}


## tidy
files = dir("G:/Researches/gee_Whittaker_V2/data/ET_products/ERA5L", "*.csv", full.names = TRUE)
files = dir("G:/Researches/gee_Whittaker_V2/data/ET_products", "*.csv", full.names = TRUE)
# lst = map(files, fread)

for (infile in files) {
    print(infile)
    drive_csv_clean(infile, sp2, overwrite = TRUE)
}

