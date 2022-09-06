
#' ee_aggregate
#' 
#' @export 
ee_aggregate <- function(col, prop, reducerList = "mean", bandList = 0) {
  bands = bandList[1]
  reducer = reducerList[1]
  # props <- ee_aggregate_array(imgcol, prop) #%>% unique()
  probs = ee$Dictionary(col$aggregate_histogram(prop))$keys(); # list obj
  
  col_new <- probs$map(ee_utils_pyfunc(function(key) {
    
    .col = col$filterMetadata(prop, "equals", key)$sort("system:time_start")
    first = .col$first()

    r = .col$select(bands)$reduce(reducer)
    ee_copyProperties(r, first)
    # aggregate_process(col, prop, key, reducerList, bandList)
  }))
  ee$ImageCollection$fromImages(col_new)
}


#' @rdname ee_aggregate
#' @export
ee_aggregate_list <- function(col, prop, reducerList = "mean", bandList = 0) {
  bands = bandList[1]
  reducer = reducerList[1]
  bandNames = col$first()$select(bands)$bandNames()
  # probs <- ee_aggregate_array(imgcol, prop) # %>% unique()
  # grps <- unique(probs)
  grps = ee$Dictionary(col$aggregate_histogram(prop))$keys() %>% getInfo() %>% 
    set_names(., .)
  
  lst = foreach(key = grps, i = icount()) %do% {
    .col = col$filterMetadata(prop, "equals", key)$sort("system:time_start")
    first = .col$first()
    
    r = .col$select(bands)$reduce(reducer)
    ee_copyProperties(r, first)$rename(bandNames)
  }
  lst
  # ee$ImageCollection$fromImages(lst)
}

aggregate_process <- function(imgcol, prop, prop_val, reducerList, bandList) {
  nreducer <- length(reducerList)
  imgcol <- imgcol$filterMetadata(prop, "equals", prop_val)$sort("system:time_start")

  first <- imgcol$first()
  ans <- ee$Image()
  # if (!delta) ans = last$subtract(first);
  for (i in 1:nreducer) {
    bands <- bandList[i]
    reducer <- reducerList[i]
    img_new <- imgcol$select(bands)$reduce(reducer)
    ans <- ans$addBands(img_new)
  }
  ee_copyProperties(ans, first)
}

ee_copyProperties <- function(img, target) {
  # copyProperties(target, c("system:time_start", "system:time_end"))$
  ee$Image(
    img$copyProperties(target, target$propertyNames())
  )
}
