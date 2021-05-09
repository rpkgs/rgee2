listk <- function(...) {
    cols <- as.list(substitute(list(...)))[-1]
    vars <- names(cols)
    Id_noname <- if (is.null(vars)) {
          seq_along(cols)
      } else {
        which(vars == "")
    }
    if (length(Id_noname) > 0) {
          vars[Id_noname] <- sapply(cols[Id_noname], deparse)
      }
    x <- setNames(list(...), vars)
    return(x)
}

#' colors to hex
#'
#' @param cname color names
#' @examples
#' col2hex("grey60")
#' @export
col2hex <- function(cname) {
    colMat <- col2rgb(cname) / 255
    rgb(red = colMat[1, ], green = colMat[2, ], blue = colMat[3, ])
}

season <- function(month) {
    ans <- rep("Winter", length(month))
    ans[month %in% 3:5] <- "Spring"
    ans[month %in% 6:8] <- "Summer"
    ans[month %in% 9:11] <- "Autumn"
    ans
}

tag_facet <- function(p, open = "(", close = ")", tag_pool = letters, x = -Inf,
                      y = Inf, hjust = -0.5, vjust = 1.5, fontface = 2, family = "rTimes",
                      label = "label",
                      ...) {
    gb <- ggplot_build(p)
    lay <- gb$layout$layout
    # browser()
    tags <- cbind(lay, label = paste0(open, tag_pool[lay$PANEL], close), x = x, y = y)

    p + geom_label(
        data = tags, aes_string(x = "x", y = "y", label = label),
        ..., hjust = hjust, vjust = vjust, fontface = fontface,
        family = family, inherit.aes = FALSE
    ) + theme(
        strip.text = element_blank(),
        strip.background = element_blank()
    )
}

modifyList <- function (x, val, keep.null = FALSE)
{
    # stopifnot(is.list(x), is.list(val))
    xnames <- names(x)
    vnames <- names(val)
    vnames <- vnames[nzchar(vnames)]
    if (keep.null) {
        for (v in vnames) {
            x[v] <- if (v %in% xnames && is.list(x[[v]]) && is.list(val[[v]]))
                list(modifyList(x[[v]], val[[v]], keep.null = keep.null))
            else val[v]
        }
    }
    else {
        for (v in vnames) {
            x[[v]] <- if (v %in% xnames && is.list(x[[v]]) &&
                is.list(val[[v]]))
                modifyList(x[[v]], val[[v]], keep.null = keep.null)
            else val[[v]]
        }
    }
    x
}
