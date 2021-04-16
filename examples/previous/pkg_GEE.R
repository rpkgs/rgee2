convert_nc2tiff <- function(year, outdir = "E:/gleam", prefix = 'gleam_'){
    ## global parameters
    cellsize <- 1/4
    nlat     <- 180/cellsize; nlong <- 360/cellsize

    ## yearly parameters
    files    <- dir(indir, "*.nc$", full.names = T)
    varnames <- str_extract(files, "\\w{1,}(?=_d)")
    files %<>% set_names(varnames)

    year  <- as.numeric(str_extract(files[1], "\\d{4}"))
    ydays <- ifelse(leap_year(year), 366, 365)

    # 1. open fids
    fids   <- llply(files, nc_open)
    for (i in 1:ydays){
        date    <- as.Date(sprintf("%04d-%03d", year, i), "%Y-%j")
        outfile <- sprintf('%s/%s%s.tif', outdir, prefix, format(date))
        fprintf('[%03d] %s ...\n', i, outfile)
        
        start        <- c(1, 1, i)         # change to start=(1,1,1,...,i) to read timestep i
        count        <- c(nlat, nlong, 1) # change to count=(nx,ny,nz,...,1) to read 1 tstep

        lst <- list()
        nvar <- length(files)
        A <- array(NA, dim = c(nlat, nlong, nvar))
        for (j in seq_along(fids)){
            runningId(j)
            A[,,j] <- ncvar_get( fids[[j]], varnames[j], start=start, count=count)
        }

        A = aperm(A, c(2, 1, 3)) %>% array(dim = c(nlat*nlong, nvar))
        grid@data <- data.table(A)
        writeGDAL(grid, outfile, mvFlag = -999, type = "Float32", 
                  options = c("COMPRESS=LZW"))
    }
    # 4. Finally close fids
    l_ply(fids, nc_close)
}

millis <- function(date){
    if (is.character(date)) date <- ymd(date)
    difftime(date, ymd("1970-01-01"), units = "secs") %>% 
        as.integer() %>% paste0("000")
}

#' @param  type one of c("y", "m", "d)
write_meta <- function(indir, type = "y", pattern, outfile = 'meta.csv', dest = "asset_id", exec = FALSE){
    files   <- dir(indir, "*.tif")
    id      <- basename(files) %>% gsub(".tif", "", .)
    
    if (missing(pattern)){
        pattern <- switch (type,
            y = "\\d{4}",
            m = "\\d{5,6}",
            d = "\\d{4}-\\d{1,2}-\\d{1,2}"
        )
    }
    datestr <- switch (type, 
           y = str_extract(files, pattern) %>% paste0("0101"), 
           m = str_extract(files, pattern) %>% paste0("01"), 
           d = str_extract(files, pattern))
    dates   <- ymd(datestr)
    mill    <- millis(dates)
    
    meta <- data.table(id = id, `system:time_start` = mill)
    outfile <- paste0(dirname(indir), "/", outfile)
    fwrite(meta, outfile)    
    
    cmd <- sprintf("geeadd upload --source %s --dest %s -u kongdd@live.cn -m %s", indir, dest, outfile)
    if (exec){
        cat(cmd, "\n")
        shell(cmd)
    }
    writeLines(cmd, "clipboard")
}

dest  <- "projects/pml_evapotranspiration/PML_INPUTS/WATCH_raw"
indir <- "X:/WATCH/GeotiffAnnual/" 

# geeadd upload --source F:/SPOT_unload/data --dest projects/pml_evapotranspiration/SPOT/SPOT_NDVIs10_raw  -m F:/SPOT_unload/spot_meta.csv #--bands E,Eb,Ei,Ep,Es,Et,Ew,S,SMroot,SMsurf
write_meta(indir, type = "y", dest = dest)
