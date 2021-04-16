library(rgee)

ee_Initialize(drive = TRUE)

sp = ee$Geometry$Point(c(115.2405811929134,33.30350075205527)) #%>% ee_print()
imgcol_mod = ee$ImageCollection$Dataset$MODIS_006_MOD13A2$
    filterDate("2014-01-01", "2021-12-31")$
    # select("EVI")$
    map(function(img){
        img$divide(1e4)
    })

{
    imgcol_ls8 = ee$ImageCollection$Dataset$LANDSAT_LC8_L1T_8DAY_EVI
    imgcol_ls8 = imgcol$
        # filterDate("2014-01-01", "2021-12-31")$
        select("EVI")
    imgcol_ls8$size()$getInfo()
    }

d1 = ee_extract(imgcol_mod, sp)
d2 = ee_extract(imgcol_ls8, sp, scale = 30) %>% ee_extract_clean()

ee_extract_clean(d1)
# d2
img = imgcol_ls8$mean()
{
    vis = list(min = 0, max = 0.7, palette = palette_VI)
    ## use rgee clip point data
    Map$centerObject(sp, 14)
    m1 = Map$addLayer(img, vis, "EVI") +
        Map$addLayer(sp)

    m2 = Map$addLayer(imgcol_mod$first(), vis, "EVI") +
        Map$addLayer(sp)

    m1 | m2
}
