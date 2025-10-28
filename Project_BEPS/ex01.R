library(rgee)
ee_Initialize()

ee_proj <- function(img) {
  proj <- ee$Image$projection(img)$getInfo()
  proj$transform <- unlist(proj$transform)
  return(proj)
}

ee_scale <- function(img) {
  proj <- ee_proj(img)
  proj$transform[1] * 120 * 1000 # 1/120 degree = 1km
}

df2sf <- function(d, coords = c("lon", "lat"), crs = 4326, ...) {
  sf::st_as_sf(d, coords = coords, crs = crs, ...)
}

st <- data.table::fread("./Project_BEPS/st_flux341.csv")
sp <- df2sf(st[, .(site, lon, lat)])

img = ee$Image("OpenLandMap/SOL/SOL_CLAY-WFRACTION_USDA-3A1A1A_M/v02")
col <- ee$ImageCollection(img)

ee_scale(img)
r <- ee_extract(col, sp, via = "getInfo", lazy = FALSE, scale = 500)
r <- ee_extract(col, sp, via = "getInfo", lazy = FALSE, scale = 500)

images <- list(
  CI = "users/kongdd/BEPS/CI_240X_1Y_V1",
  soil_type = "OpenLandMap/SOL/SOL_TEXTURE-CLASS_USDA-TT_M/v02",
  soil_water = "OpenLandMap/SOL/SOL_WATERCONTENT-33KPA_USDA-4B1C_M/v01",
  soil_buld = "OpenLandMap/SOL/SOL_BULKDENS-FINEEARTH_USDA-4A1H_M/v02",
  soil_pH = "OpenLandMap/SOL/SOL_PH-H2O_USDA-4C1A2A_M/v02",
  soil_clay = "OpenLandMap/SOL/SOL_CLAY-WFRACTION_USDA-3A1A1A_M/v02",
  soil_sand = "OpenLandMap/SOL/SOL_SAND-WFRACTION_USDA-3A1A1A_M/v02"
)
