library(plyr)
library(ncdf4)
library(purrr)
library(abind)
library(rgdal)

read_nc <- function(file) {
    fid = nc_open(file)
    on.exit(nc_close(fid))
    x = ncvar_get(fid, raw_datavals = TRUE)
    dim <- dim(x)
    ndim = length(dim)
    array(x, dim = c(prod(dim[1:(ndim-1)]), dim[ndim]))
}

# library(stars)
# nc2tiff <- function(files, outfile, info){
#     x = read_stars(files, proxy = TRUE)
#     x = (x - info$addOffset)/info$scaleFact
#  s   write_stars(x, outfile, options = "COMPRESS=lzw", type = "Int16") # JPEG, 
# }

indir = "N:/DATA/3h metrology data/Data_forcing_01dy_010deg/nc"
indir = "N:/DATA/3h metrology data/daily_temp/"
l_files <- dir(indir, "*.nc", full.names = TRUE) %>% 
    { split(., substr(basename(.), 1, 4)) }
fids = map(l_files, ~nc_open(.x[1]))
df_info = map(fids, ~.x$var[[1]][c("addOffset", "scaleFact")] %>% data.frame) %>% do.call(rbind, .)

fid <- nc_open(l_files[[1]][1])
lats <- fid$dim$lat$vals
lons <- fid$dim$lon$vals
grid <- get_grid.lonlat(lons, lats)

# ------------------------------------------------------------------------------
years = 1979:2018
for (i in seq_along(l_files)) {
    runningId(i)
    files = l_files[[i]]
    outfile = sprintf("ITPCAS-CMFD_V0106-%s (1979-2018).tif", names(l_files)[i])
    if (!file.exists(outfile)) {
        # info = infos[i, ]
        lst <- llply(files, read_nc, .progress = "text")
        mat <- abind(lst, along = 2)
        grid@data <- data.frame(mat)
        
        writeGDAL(grid, outfile,
            options = "COMPRESS=LZW",
            mvFlag = -32767, type = "Int16")
    }
}

# for (j in 1:8) {
#     runningId(j)
#     ind = seq((j-1) * 5 + 1, j*5)
#     outfile = sprintf("ITPCAS-CMFD_V0106-%s_%d-%d-010deg.tif", names(l_files[i]), years[ind[1]], years[ind[length(ind)]])
#     nc2tiff(files[ind], outfile, info)
# }
# vals <- x[,,] %>% set_dim(c(700*400, dim(x) %>% last()))
# vals[vals == -32767] = NA_integer_
# grid@data <- data.frame(vals)
# writeGDAL(grid, "a_lzw.tif", 
#           options="COMPRESS=LZW", 
#           mvFlag = -32767,
#           type = "Int16")
