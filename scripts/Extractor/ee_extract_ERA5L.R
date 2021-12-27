library(rgee)
library(sf)
library(sf2)
library(dplyr)

devtools::load_all()
# ee_Initialize(user = "kongdd.sysu", drive = TRUE)
ee_Initialize(user = "cuijian426", drive = TRUE)
# ee_Initialize(user = "kjding93", drive = TRUE)
# ee_Initialize(drive = TRUE)

## 1. read tested points
sp <- read_sf(path.mnt("C:/Users/kongdd/Desktop/学生研究/谢宇轩研究-planB/st_met2481.shp")) %>%
    dplyr::select(site)
# sp %<>% mutate(ID = 1:nrow(.)) %>% select(ID, IGBPcode)

## 2. clip ERA5L data by `rgee`
bands = c('T', "Tdew", 'Pa', 'Rn', 'ET', 'U2')

years = rev(2000:2020)
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
        outfile = glue("PET_forcings_{year}.csv")
    )
}

files <- dir("H:/global_WB/ChinaPET/ERA5L_raw", full.names = TRUE)
overwrite = FALSE
for (infile in files) {
    print(infile)
    drive_csv_clean(infile, sp)
}

files <- dir("H:/global_WB/ChinaPET", "*.csv", full.names = TRUE)

# res = ee$List(dates_daily)$map(ee_utils_pyfunc(function(date_begin){
#     ans = aggregate_ERA5_daily(date_begin, col, bands)
#     ans
# }))
