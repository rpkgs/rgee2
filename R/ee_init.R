#' ee_init
#' 
#' @param drive ignored
#' @param ... others to [rgee::ee_Initialize()]
#' 
#' @examples 
#' \dontrun{
#' # ee_Initialize(user = "cuijian426", drive = TRUE)
#' ee_init()
#' }
#' @seealso [rgee::ee_Initialize()]
#' @export 
ee_Init <- function(drive=FALSE, ...) {
  tryCatch({
    ee$Image(1)
    invisible()
  }, error = function(e) {
    # rgee::ee_Initialize(drive=drive, ...)
    ee$Initialize(...)
    # message(sprintf('%s', e$message))
  })
}

ci_auth <- function() {
  ci_auth <- system.file("python/ci_auth.py", package = "rgee2")
  reticulate::source_python(ci_auth)
  auto_Initialize()
}

#' @export
ee_init = ee_Init
