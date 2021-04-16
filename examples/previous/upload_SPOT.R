library(magrittr)
library(tidyverse)
library(purrr)
library(data.table)
library(lubridate)

indirs <- c("E:/output/", 
           "Z:/SPOT_NDVI/", 
           "V:/SPOT2/")

# indir <- "E:/output/"
# indir <- "Z:/SPOT_NDVI/"

files <- llply(indirs, dir, "*.ZIP", full.names = T) %>% unlist()

dirs = map(files, ~unzip(.x, list = T)[[1]]) %>% map_chr(~.x[1])

x <- data.frame(zip = files, dir = dirs)
s <- fread("imgcol_ids.txt", header = F)$V1

fwrite(x , "spot_dirs.txt")
# # dirs = unzip(files, list = T)
# file.show(outfile)

x$date <- str_extract(x$dir, "(?<=.)\\d{8,}") %>% ymd

x <- x[order(x$date), ]
x$diff <- c(0, diff(x$date))

I_del <- match(s, format(x$date)) %>% na.omit()
I_del <- match(gsub("-", "", imgcol), x$dir %>% str_extract("\\d{8}")) %>% 
    na.omit()
x_left <- x[-I_del, ]

library(plyr)
stats <- llply(as.character(x_left$zip), function(file){
    if (file.exists(file)){
        newfile <- paste0("V://SPOT/", basename(file))
        file <- paste0("V://SPOT2/", basename(file))
        file.rename(file, newfile)
    }
}, .progress = "text")

imgcol = fread("imgcol_ids.txt", header = F)$V1
openxlsx::write.xlsx(x, "spot.xlsx")
