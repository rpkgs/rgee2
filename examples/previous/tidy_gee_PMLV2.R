library(terra)
library(rgee2)
library(lubridate)
library(matrixStats)
ee_Initialize()

get_date <- function(f_bandname) {
    fread(f_bandname)$bandname %>%
        gsub("\\[|\\]", "", .) %>% strsplit(", ") %>% .[[1]] %>%
        substr(1, 10) %>%
        gsub("_", "-", .) %>%
        as.POSIXct("UTC")
}

## 01. LAI
r = rast("C:/Users/hydro/Downloads/Compressed/LAI_v014_2003_2017.tif")
dates = get_date("C:/Users/hydro/Downloads/Compressed/LAI_v014_2003_2017_names.csv")
time(r) = dates %>% as.POSIXct("UTC")
writeCDF(r, "LAI_v014_200207_201712.nc", "LAI", "Leaf area index", overwrite = TRUE)



## 02. ET
dates = ee$ImageCollection("CAS/IGSNRR/PML/V2") %>% ee_systemtime() #%>%
r = rast("C:/Users/hydro/Downloads/Compressed/PMLV2_ET3_v014_200207_201712.tif")
dim = dim(r)[2:1]
time(r) = dates %>% as.POSIXct("UTC")

fout = "PMLV2_ET3_v014_200207_201712.nc"
writeCDF(r, fout, overwrite = TRUE, unit = "mm/d")

## 绘图展示数据
r = rast(fout)
arr = rast_array(r) %>% array_3dTo2d()

info = data.table(date = dates) %>%
    mutate(doy = yday(dates),
           dn = floor((doy - 1)/8) + 1)
t_delta = diff(c(seq(1, 366, 8), 365)) %>% as.matrix()

## 多年平均
arr_mean = apply_row(arr, info$doy)
x = colMeans2(arr_mean)
plot(x)

ET_avg = arr_mean %*% t_delta
ans = array_2dTo3d(ET_avg, dim = dim)

r2 = make_rast(range = c(110, 123, 31, 43), cellsize = 0.25, vals= ans %>% flipud())
plot(r2)
# arr_mean = apply_row(arr, info$doy) %>% t() %>% multiply_by(t_delta)
rowSums2()
# x = matrixStats::weightedMean(arr_mean, t_delta)


poly = vect("D:/Documents/ArcGIS/china/bou2_4p_ChinaProvince.shp")
{
    mask(r, r >= 0.4, maskvalues = FALSE) %>% plot()
    plot(poly, add = TRUE)
}
