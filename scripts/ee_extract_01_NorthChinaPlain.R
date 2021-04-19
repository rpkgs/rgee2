library(rgee)
library(sf)
library(sf2)

devtools::load_all()
ee_Initialize(drive = TRUE)

## 1. read tested points
sp <- read_sf("/mnt/n/Research/GEE_repos/gee_whittaker/data-raw/st_test-NorthChina&GuangDong.shp")
sp %<>% mutate(ID = 1:nrow(.)) %>% select(ID, IGBPcode)

## 2. clip EVI data by `rgee`
bands = c('EVI', 'DayOfYear', 'SummaryQA')
imgcol <- ee$ImageCollection('MODIS/006/MOD13A2')$
    select(bands)$
    filterDate('2015-01-01', '2021-12-31')
proj = ee_get_proj(imgcol)
scale = proj$scale # scale should lte prj.scale
sp2 = st_point_buffer(sp, scale = scale)

{
    df = ee_extract2(imgcol$limit(1e3), sp2, scale = scale, via = "drive") %>% data.table()
    save(df, file = "data-raw/phenofit_NorthChinaPlain_test-(2015-2021)_3by3.rda")
}

{
    grps = 1:9
    res = lapply(grps, function(grp){
        sp = subset(sp2, group == grp)
        system.time({
            df_tmp = ee_extract2(imgcol$limit(1e3), sp2, scale = scale) %>% data.table()
        }) %>% print()
        outfile = glue("northchina_{grp}.csv")
        fwrite(df_tmp, outfile)
        df_tmp
    })
    # save(df, file = "phenofit_NorthChinaPlain_test-(2015-2021).rda")
}

# load("data-raw/R_challenges/df_tmp.rda")
