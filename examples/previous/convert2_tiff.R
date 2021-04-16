library(purrr)
library(lubridate)
library(stringr)
library(plyr)
library(Ipaper)
library(rgdal)
library(ncdf4)
library(data.table)
library(parallel)

if (.Platform$OS.type == "unix"){
    dir_climate <- "/OSM/CBR/CoRE/working/timeseries/Climate/"
    dir_flush   <- "/flush1/kon055/"
    
} else{
    dir_climate <- "//clw-03-cdc.it.csiro.au/OSM_CBR_CoRE_working/timeseries/Climate/"
    dir_flush   <- "//braggflush1/flush1/kon055/"
}

prefix <- 'princeton_'
indir  <- paste0(dir_climate, "Princeton")
outdir <- paste0(dir_flush, "Princeton_tiff")

if (!dir.exists(outdir)) dir.create(outdir)

files     <- dir(indir, "*.nc$", full.names = T)
bandNames <- str_extract(files, "\\w{1,}(?=_d)") %>% unique 

## global parameters
cellsize <- 1/4
nlat     <- 180/cellsize; nlong <- 360/cellsize
prj   <- CRS('+init=epsg:4326')
range <- c(-60, 90, -180, 180)
grid  <- get_grid(range, cellsize)

ilat <- seq(range[1] + cellsize/2, range[2], cellsize)
ilon <- seq(range[3] + cellsize/2, range[4], cellsize)

nc2tiff <- function(year){
    ## yearly parameters
    files = map_chr(bandNames, ~sprintf('%s/%s_daily_%04d-%04d.nc', indir, .x, year, year))
    print(files)
    # files %<>% set_names(varnames)
    # year  <- as.numeric(str_extract(files[1], "\\d{4}"))
    ydays <- ifelse(leap_year(year), 366, 365)
    
    # 1. open fids
    fids   <- llply(files, nc_open)
    print(files)
    
    # dims <- fids[[1]]$dim
    # lon  <- dims$lon$vals
    # lat  <- dims$lat$vals
    
    varsize <- fids[[1]]$var[[1]]$varsize[1:2] # c(long, lat) or c(lat, long)
    count   <- c(varsize, 1) # change to count=(nx,ny,nz,...,1) to read 1 tstep
    
    subfun <- function(i){
        date    <- as.Date(sprintf("%04d-%03d", year, i), "%Y-%j")
        outfile <- sprintf('%s/%s%s.tif', outdir, prefix, format(date))
        if (file.exists(outfile)) return()
        
        fprintf('[%03d] %s ...\n', i, outfile)
        
        lst <- list()
        nvar <- length(files)
        # A <- array(NA, dim = c(varsize, nvar))
        A <- array(NA, dim = c(1440, 600, nvar))
        for (j in seq_along(fids)){
            runningId(j)
            # ncvar_get( fids[[j]], bandNames[j], start=c(1, 1, i), count=count)
            # temp <- ncvar_get( fids[[j]], bandNames[j], start=c(1, 1, i), count=count)
            # temp <- temp[c(721:1440, 1:720), 600:1] # just for princeton
            A[,,j] <- ncvar_get( fids[[j]], bandNames[j], start=c(1, 1, i), count=c(1440, 600, 1))
        }
        temp = A[c(721:1440, 1:720), 600:1, ] #%>% aperm(c(2, 1, 3))#c(601:720, 1:600)
        # aperm(A, c(2, 1, 3)) %>%
        d = array(temp, dim = c(prod(dim(temp)[1:2]), nvar)) %>% as.data.table()
        grid@data <- d
        # Cairo::CairoPNG("test.png", 1000, 600)
        # spplot(grid)
        # dev.off()
        writeGDAL(grid, outfile, mvFlag = -999, type = "Float32", 
                  options = c("COMPRESS=LZW"))
    }
    # temp <- mclapply(1:ydays, subfun, mc.cores = 16)
    for (i in 1:ydays){
        subfun(i)
    }
    # 4. Finally close fids
    l_ply(fids, nc_close)
}

# nc2tiff(1994)
# par_sbatch(1980:2016, nc2tiff, nodes = 4, cpus_per_node = 10)

# geeadd delete users/kongdd/gleam
# geeadd upload --source E:/gleam --dest users/kongdd/gleam -u kongdd.sysu@gmail.com -m gleam_meta.csv --bands E,Eb,Ei,Ep,Es,Et,Ew,S,SMroot,SMsurf
# geeadd upload --source F:/SPOT_unload/data --dest projects/pml_evapotranspiration/SPOT/SPOT_NDVIs10_raw -u kongdd@live.cn -m F:/SPOT_unload/spot_meta.csv #--bands E,Eb,Ei,Ep,Es,Et,Ew,S,SMroot,SMsur