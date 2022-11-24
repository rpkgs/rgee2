#! /usr/bin/Rscript --no-init-file
suppressMessages({
    library(rgee)
    library(magrittr)
    library(dplyr)
    library(Ipaper)
    ee_Initialize(drive = FALSE)
})
devtools::load_all("/mnt/i/Research/rpkgs/rgee2")
# library(rfluxnet)
# library(sf)
imgcol = ee$ImageCollection("projects/pml_evapotranspiration/PML/OUTPUT/PML_V2_8day_v017")
imgcol = ee$ImageCollection("projects/pml_evapotranspiration/PML_INPUTS/GLDAS_V21_8day_V2")
imgcol <- ee$ImageCollection("projects/gee-hydro/INPUT/EAR5L_8day")
imgcol <- ee$ImageCollection("projects/gee-hydro/INPUT/EAR5L_8day_extra")
imgcol <- ee$ImageCollection("projects/gee-hydro/INPUT/GLDASv21_8day")

# imgcol <- ee$ImageCollection("projects/gee-hydro/INPUT/EAR5L_mon")
# imgcol <- ee$ImageCollection("projects/gee-hydro/INPUT/CFSV2_8day")
    # filterDate("2000-01-01", "2019-12-31")

i = 0
while (1) {
    tryCatch({
        # info = get_finished(imgcol, date_end = "2020-12-31")$info
        info = get_missInfo(imgcol, date_begin = "2000-01-01")
        # print(info)
        if (mod(i, 10) == 0) print(info)
    }, error = function(e) {
        message(sprintf('%s', e$message))
    })
    i <- i + 1
    Sys.sleep(30*4)
}
# get_missInfo(imgcol)
