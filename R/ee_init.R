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

#' @export
ee_init = ee_Init
