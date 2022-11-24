#' ee_init
#' 
#' @inheritParams rgee::ee_Initialize
#' @param ... others to [rgee::ee_Initialize()]
#' 
#' @examples 
#' \dontrun{
#' # ee_Initialize(user = "cuijian426", drive = TRUE)
#' ee_init()
#' }
#' @seealso [rgee::ee_Initialize()]
#' @export 
ee_init <- function(drive=FALSE, ...) {
  tryCatch({
    ee$Image(1)
    invisible()
  }, error = function(e) {
    rgee::ee_Initialize(drive=drive, ...)
    # message(sprintf('%s', e$message))
  })
}
