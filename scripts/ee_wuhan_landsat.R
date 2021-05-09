library(rgee)
ee_Initialize(drive = TRUE)

poly_wuhan = ee$FeatureCollection("users/kongdd/poly_Hubei_Wuhan")

LC08col = ee$ImageCollection("LANDSAT/LC08/C01/T1_SR");
LE07col = ee$ImageCollection("LANDSAT/LE07/C01/T1_SR");
LT05col = ee$ImageCollection("LANDSAT/LT05/C01/T1_SR");
LT04col = ee$ImageCollection("LANDSAT/LT04/C01/T1_SR");

roi = poly_wuhan;
startDate = '1984-01-01';
endDate = '2020-12-31';
apply_fmask = TRUE;

# Filter collections and prepare them for merging$
LC08coly = colFilter(LC08col, roi, startDate, endDate)$map(prepOli);
LE07coly = colFilter(LE07col, roi, startDate, endDate)$map(prepEtm);
LT05coly = colFilter(LT05col, roi, startDate, endDate)$map(prepEtm);
LT04coly = colFilter(LT04col, roi, startDate, endDate)$map(prepEtm);

# Merge the collections$
col = LC08coly$merge(LE07coly)$merge(LT05coly)$merge(LT04coly);
print(col$size(), col$limit(3), col$aggregate_array('system:index'));

lst = listk(l8 = LC08coly, l7 = LE07coly, l5 = LT05coly, l4 = LT04coly)

library(purrr)
dates = map(lst, ~ee_systemtime(.x) %>% getInfo())
info = map(dates, ~data.table(date = .)) %>% melt_list("source")
info2 = info[, .N, .(source, year(date))][order(source, year)]
info_nums = info2[, .(N= sum(N)), .(year)][order(year)]

year_begin = info2$year %>% first()
year_end   = info2$year %>% last()
years_miss <- setdiff(year_begin:year_end, info2$year)


year = 1986; img1 = col$filter(ee$filter$Filter$calendarRange(year, year, "year"))$mosaic()
year = 2020; img2 = col$filter(ee$filter$Filter$calendarRange(year, year, "year"))$mosaic()

# img = imgcol$mosaic()
vis = list('min' = 0, 'max' = 4000, 'gamma' = c(1, 1, 1), 'bands' = c('NIR', 'Red', 'Green'))
Map$centerObject(poly_wuhan, 10)
# Map$addLayer(poly_wuhan, {}, "wuhan") +
Map$addLayer(img1, vis, "1986") |
    Map$addLayer(img2, vis, "2020")

gif = ee_gif(col, )
