library(rgee)
ee_Initialize(drive = TRUE)

dataset = ee$ImageCollection$Dataset
# guess imgcol date range
imgcol = dataset$ECMWF_ERA5_LAND_MONTHLY
imgcol_byHour =dataset$ECMWF_ERA5_LAND_MONTHLY_BY_HOUR

dates  = imgcol %>% ee_systemtime()
{
    dates2 = imgcol_byHour %>% ee_systemtime()
    dates2[1:10]
}

mapedit::editMap()

sp = ee$Geometry$Point(c(115.2405811929134,33.30350075205527))
res = ee_extract(imgcol, sp)
