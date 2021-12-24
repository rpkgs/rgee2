add_TimeProp <- function(img, pheno = FALSE) {
    date   = ee$Date(img$get('system:time_start'));
    month  = date$get('month');
    year   = date$get('year');
    ingrow = ee$Algorithms$If(month$gte(4)$And(month$lte(10)), "true", "false");

    spring_begin = ifelse(pheno, 4, 3)
    autumn_end   = ifelse(pheno, 10, 11)
    # /** 4-10 as growing season if pheno = TRUE */
    season = ""
    season = ee$Algorithms$If(month$lte(spring_begin-1), ee_num2str(year$subtract(1))$cat("_winter"), season)
    season = ee$Algorithms$If(month$gte(spring_begin)$And(month$lte(5)), ee_num2str(year)$cat("_spring"), season);
    season = ee$Algorithms$If(month$gte(6)$And(month$lte(8)), ee_num2str(year)$cat("_summer"), season);
    season = ee$Algorithms$If(month$gte(9)$And(month$lte(autumn_end)), ee_num2str(year)$cat("_autumn"), season);
    season = ee$Algorithms$If(month$gte(autumn_end+1), ee_num2str(year)$cat("_winter"), season);

    img$
        set('season', season)$
        set('ingrow', ingrow)$
        set('year-ingrow', year$format()$cat('-')$cat(ingrow))$
        set('year', year$format())$
        set('month', month$format("%02d"))$
        set('yearmonth', date$format('YYYY-MM')); #seasons$get(month$subtract(1))
}

ee_aggregate <- function(imgcol, prop, reducerList = "mean", bandList = 0) {
    props = ee_aggregate_array(imgcol, prop) %>% unique()
    imgcol_new = map(props, ~ aggregate_process2(imgcol, prop, .x, reducerList, bandList))
    ee$ImageCollection$fromImages(imgcol_new)
}

aggregate_process <- function(imgcol, bandList, reducerList){
    first = ee$Image(imgcol$first());
    # nreducer = reducerList$length;
    # print(bandList, reducerList, nreducer);
    n = length(reducerList)
    ans = NULL;
    for (i in 1:n) {
        bands = bandList[i];
        reducer = reducerList[i];
        img_new = imgcol$select(bands)$reduce(reducer);
        if (i == 1) {
            ans = img_new
        } else {
            ans = ans$addBands(img_new);
        }
    }
    ans
    # return(ee$Image(pkg_agg$copyProperties(ee$Image(ans), first)))
}

# aggregate_process <- function(imgcol, prop, prop_val, reducerList, bandList) {
#     nreducer = length(reducerList)
#     imgcol = imgcol$filterMetadata(prop, "equals", prop_val)$sort("system:time_start")

#     first = imgcol$first();
#     # last  = pkg_trend$imgcol_last(imgcol);
#     ans = ee$Image();
#     # if (!delta) {
#     for (i in 1:nreducer) {
#         bands = bandList[i];
#         reducer = reducerList[i];
#         img_new = imgcol$select(bands)$reduce(reducer);
#         ans = ans$addBands(img_new);
#     }
#     # } else {
#     #     ans = last$subtract(first);
#     # }
#     ee_copyProperties(ans, first)
#     # ans$copyProperties(first, first$propertyNames())
# }

aggregate_process2 <- function(imgcol, prop, prop_val, reducerList, bandList) {
    nreducer = length(reducerList)
    imgcol = imgcol$filterMetadata(prop, "equals", prop_val)$sort("system:time_start")

    first = imgcol$first();
    # last  = pkg_trend$imgcol_last(imgcol);
    ans = ee$Image();
    # if (!delta) {
    # for (i in 1:nreducer) {
        bands = bandList[i];
        reducer = reducerList[i];
        img_new = imgcol$select(bands)$reduce(reducer);
        ans = ans$addBands(img_new);
    # }
    # } else {
    #     ans = last$subtract(first);
    # }
    ee_copyProperties(ans, first)
    # ans$copyProperties(first, first$propertyNames())
}

ee_copyProperties <- function(img, target) {
    img$copyProperties(target, c("system:time_start", "system:time_end"))$
        copyProperties(target, target$propertyNames())
}
