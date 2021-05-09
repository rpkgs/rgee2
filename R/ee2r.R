#' @import stringr
#' @export
ee2r <- function(x = NULL) {
    if (is.null(x)) {
          x <- readLines("clipboard", warn = FALSE)
      }
    ans <- str_replace_all(
        x,
        c(
            "\\[" = "c(",
            "]|\\};" = ")",
            ":" = " =",
            "= \\{" = "= list(",
            "var " = "",
            "\\." = "$",
            "===" = "==",
            "\\!==" = "!=",
            "//" = "#"
        )
    )
    ans %<>% str_replace_all(
        c(
            "(function) (.*)(?=\\()" = "\\2 <- \\1",
            "return (.*);" = "return(\\1)"
        )
    )
    writeLines(ans, "clipboard")
    ans
}
