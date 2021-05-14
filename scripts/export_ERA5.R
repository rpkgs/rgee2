# source("scripts/main_pkgs.R")
library(rgee)
ee_Initialize(drive = T)

{
    imgcol = ee$ImageCollection("ECMWF/ERA5_LAND/MONTHLY")$
        select(c("evaporation_from_vegetation_transpiration"))$
        map(add_TimeProp)

    img = imgcol$first()
    # img_jrc <- ee$Image("JRC/GSW1_2/GlobalSurfaceWater")
    # img_urban <- ee$Image("Tsinghua/FROM-GLC/GAIA/v10")

    proj <- ee_get_proj(img)
    options <- listk(
        # range = c(113, 29, 116, 32),
        # cellsize = 1/120,
        # scale = 100,
        crsTransform = proj$transform,
        verbose = TRUE,
        folder = "rgee"
    )
    # export_Img(img_jrc$select("change_abs"), "wuhan_water_jrc_1984-2019-change_abs", options)
    export_Img(img, "ERA5_01", options)
    # export_Img(img_jrc$select('change_abs'), "jrc_010deg", listk(range, cellsize = 1/10, folder = "rgee"))
    ee_monitoring()
}

imgcol_year = ee_aggregate(imgcol, "year", "sum")
imgcol_year = imgcol_year$filterDate('1980-01-01', '2020-12-31');

library(lubridate)
props = make_date(1982:2020, 1, 1) %>% format()
system.time({
    export_ImgCol(imgcol_year, "ERA5land_Ec_", options, props)
})


Map$addLayer(imgcol_year$first())
x = ee$ImageCollection$fromImages(c(img, img))
x %>% getInfo() %>% str()
