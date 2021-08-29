library(rgee)
ee_Initialize()

imgcol = ee$ImageCollection("users/kongdd/PML/PML_V2_yearly_v017")

imgcol_lc_raw = ee$ImageCollection("MODIS/006/MCD12Q1")$select(0)
imgcol_lc_processed = ee$ImageCollection("projects/pml_evapotranspiration/landcover_impact/MCD12Q1_06")

filter_urban <- function(imgcol, IGBP_code = 13) {
    expr = glue::glue("b() == {IGBP_code}")
    # print(expr)
    imgcol$map(function(img) {
        mask = img$expression(expr)
        img$updateMask(mask)
    })
}

library(plyr)
res = llply(1:17, function(IGBP_code) {
    imgcol = filter_urban(imgcol_lc_raw, IGBP_code)
    ee_stat(imgcol, year = 2018, scale = 5000)
}, .progress = "text")


# img = imgcol$first()
# Map$addLayer(img$updateMask(mask))
l_processed = plyr::llply(2015:2019, ee_stat,
    imgcol = imgcol_lc_processed %>% filter_urban, scale = 5000, .progress = "text") %>%
    do.call(rbind, .)
l_raw = plyr::llply(2015:2019, ee_stat,
    imgcol = imgcol_lc_raw %>% filter_urban, scale = 5000, .progress = "text")

map_dbl(lst, "LC_Type1_sum")/100
map_dbl(lst2, "LC_Type1_sum")/100

InitCluster(4)
lst = llply(2001:2020, , .progress = 'text')
# year  = 2001


x = brick("C:/Users/kongdd/Desktop/ERA5L_LandSurface_2011.tif")*-1000
write_fig({
    plot(x)
}, "ERA5L_yearly.pdf", 10, 6)

write_fig({
    plot(x[[5]])
}, "ERA5L_yearly_pot.pdf", 10, 6)



