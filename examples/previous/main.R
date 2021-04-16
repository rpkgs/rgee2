library(jsonlite)
library(tidyverse)
library(data.table)
library(magrittr)
library(Ipaper)


js <- read_json("data/gs_manifest.json")


id = "kongdd"


files <- dir("X:/phenology/EVI2/", "*.tif")

bandNames <- str_extract(files, "(?<=\\d{4}.).*") %>% unique %>% gsub(".tif", "", .)
prefix <- "gs://Buckets/gee_upload/EVI2/VIPPHEN_EVI2.A"

dir.create("data/meta/")
for (i in 1:34){
    runningId(i)
    year <- 1980 + i
    id <- sprintf("projects/pml_evapotranspiration/phenology/VIPPHEN_EVI2_v004/EVI_%04d", year)
    tileSets <- paste0(prefix, year, ".",bandNames, ".tif") %>% map(~list(source = list(primaryPath = .x)))
    manifest <- list(id = id, tileSets = tileSets, bands = as.list(bandNames), pyramidingPolicy = "MEAN")
    rootdir <- getwd()
    
    outfile <- sprintf("%s/data/meta/manifest_%s.json", rootdir, basename(id))
    write_json(manifest, outfile)
}
i <- 1
# list(id = id, tilesets = c(list(source = list(file1 = ))))