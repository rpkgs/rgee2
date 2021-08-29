library(rgee)
ee_Initialize(drive = TRUE)
devtools::load_all()
# library(rfluxnet)
# library(sf)
# library(sf2)
imgcol = ee$ImageCollection("projects/pml_evapotranspiration/PML/OUTPUT/PML_V2_8day_v017")
imgcol = ee$ImageCollection("projects/pml_evapotranspiration/PML_INPUTS/GLDAS_V21_8day_V2")


get_missInfo <- function(imgcol) {
    dates = ee_systemtime(imgcol)
    dates_all = get_date_MODIS(dn = 8) %>% as.character()
    dates_miss = setdiff(dates_all, dates) #%>% year() %>% table()
    d_miss = data.table(date = dates_miss) %>% mutate(year = year(date))
    info  = d_miss[, .N, .(year)]
    listk(d_miss, info)
    info
}

get_missInfo(imgcol)
