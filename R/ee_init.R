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
ee_auth_ci <- function(token = NULL) {
  ci_auth <- system.file("python/ci_auth.py", package = "rgee2")
  reticulate::source_python(ci_auth)

  if (is.null(token)) {
    token = os.getenv("EARTHENGINE_TOKEN")
  }
  auto_Initialize(token)
  print("ee_auth_ci: Authentication successful!")
}

#' @export
use_backend <- function() {
  reticulate::py_require("earthengine-api")
}

#' @export
ee_init = ee_Init
