library(rgee)
ee_Initialize(email = "cuijian426@gmail.com", drive = TRUE)
devtools::load_all()

varnames = c(
    'evaporation_from_bare_soil',
    'evaporation_from_open_water_surfaces_excluding_oceans',
    'evaporation_from_the_top_of_canopy',
    'evaporation_from_vegetation_transpiration',
    'potential_evaporation',
    'snow_evaporation',
    'runoff',
    'sub_surface_runoff',
    'surface_runoff',
    'total_evaporation'
)
varnames_hour = paste0(varnames, "_hourly")
varnames_all = c(varnames, varnames_hour) %>% sort()

imgcol_avg_hourly = ee$ImageCollection("ECMWF/ERA5_LAND/MONTHLY_BY_HOUR")$
    filterDate("2021-01-01", "2021-02-28")$
    select(varnames_all)

imgcol_raw = ee$ImageCollection("ECMWF/ERA5_LAND/HOURLY")$
    select(varnames_all)$
    filterDate('2021-01-01', '2021-02-28')
# limit(10)

temp = ee$ImageCollection("ECMWF/ERA5_LAND/HOURLY")$
    select(varnames_all)
temp = imgcol_raw$filter(ee$filter$Filter$calendarRange(1, 1, "month"))

date_begin = imgcol_raw %>% ee_systemtime()
date_end = imgcol_raw %>% ee_systemtime("system:time_end")

data.table(date_begin = temp %>% ee_systemtime(),
           date_end = temp %>% ee_systemtime("system:time_end"))

sp <- ee$Geometry$Point(c(115.2405811929134, 33.30350075205527)) # %>% ee_print()
vals = ee_extract2(imgcol_raw,
            sp, via = "drive", lazy = TRUE,
            scale = 10*1e3,
            prefix = "ERA5_test")

vals_avgH = ee_extract2(imgcol_avg_hourly,
                   sp, via = "getInfo", lazy = FALSE,
                   scale = 10*1e3,
                   prefix = "ERA5_test")
# vals = ee_extract(imgcol, sp, )
# 计算
df = d_ERA5L_hour %>% mutate(
    hour = str_extract(date, "(?<=T)\\d{2}"),
    date = as_date(substr(date, 1, 10))) %>%
    reorder_name(c("date", "hour")) %>%
    .[date < "2021-02-01"]

d = df %>% select(ends_with("_hourly"))
varnames = colnames(d)
cbind(df[, 1:2], d)[, lapply(.SD, sum), .(hour), .SDcols = varnames]




