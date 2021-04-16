## global parameters
cellsize <- 1/4
nlat     <- 180/cellsize; nlong <- 360/cellsize
prj   <- CRS('+init=epsg:4326')
range <- c(-60, 90, -180, 180)
grid  <- get_grid(range, cellsize)

## 
files <- dir("V:/JRC/30m/", "*.tif", full.names = T)
r <- readGDAL(files[1]) #16G array, type = "uint8"
# 