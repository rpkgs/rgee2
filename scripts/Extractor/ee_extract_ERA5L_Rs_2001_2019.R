library(rgee)
library(sf)
library(sf2)
library(dplyr)
library(Ipaper)
library(missInfo)
devtools::load_all()

ee_Initialize()

# ee_Authenticate()
# ee_Initialize(user = 'xieyuxuan', drive = TRUE)

## 1. read tested points
sp = st_met2481[, .(site, lon, lat)] %>% df2sp() %>% st_as_sf()
# sp <- read_sf('E:/rPML/data-raw/data_xieyx/st_met2481/st_met2481.shp') %>%
#     dplyr::select(site)
# sp %<>% mutate(ID = 1:nrow(.)) %>% select(ID, IGBPcode)

## 2. clip ERA5L data by `rgee`
# bands = c('T', "Tdew", 'Pa', 'Rn', 'ET', 'U2')
bands = c('Rs')

# years = rev(2001:2019)
years = rev(2020:2021)
temp = foreach(year = years, i = icount()) %do% {
    runningId(i)
    # year = 2010
    # month = 1
    # filter <- ee$filter$Filter$calendarRange(year, year, "year")
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
                       outfile = glue("st2481_ERA5L_Rs_{year}.csv")
    )
}
