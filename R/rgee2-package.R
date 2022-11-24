#' @importFrom magrittr %<>% %>% set_names add
#' @importFrom grDevices col2rgb rgb
#' @importFrom stats setNames
#' @importFrom utils download.file str
#' @keywords internal
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL

.onLoad <- function(libname, pkgname) {
  if (getRversion() >= "2.15.1") {
    utils::globalVariables(
      c(
        ".", ".SD", ".N", "..vars"
      )
    )
  }
}
