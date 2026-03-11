#' Display modeled tree crowns projected vertically on subplot boundaries
#'
#' `plot_crowns()` draws vertically projected tree crowns as discs overlaid on
#' subplot or microplot boundaries. The full four-subplot cluster, or
#' individual subplots, can be displayed with trees `>= 5.0` in. (`12.7` cm)
#' diameter. Individual microplots can also be displayed with saplings (i.e.,
#' trees `< 5` in. diameter).
#'
#' @param tree_list A data frame with tree records for one FIA plot.  Must have
#' columns `SUBP` (FIA subplot number), `STATUSCD` (FIA integer tree status,
#' `1` = live), `DIA` (tree diameter), `HT` (tree height), `ACTUALHT` (tree
#' actual height, `ACTUALHT < HT` indicating a broken top), `DIST` (stem
#' distance from subplot/microplot center), `AZIMUTH` (horizontal angle from
#' subplot/microplot center to the stem location, in range `0:359`), and
#' `CRWIDTH` (tree crown width).
#' @param subplot Optional integer subplot number in the range `1:4` indicating
#' a specific subplot for display. May be `NULL` or `NA` to display the whole
#' four-point cluster plot.
#' @param microplot A logical value, `TRUE` to display the modeled crowns of
#' saplings overlaid of the microplot boundary of `subplot = n`. The default is
#' `FALSE`. Ignored if `subplot` is not specified.
#' @param linear_unit An optional character string specifying the linear
#' distance unit. Defaults to the native FIA unit of `"ft"`, but may be set to
#' `"m"` instead (or `"meter"` / `"metre"`), in which case subplot boundaries
#' will be display in meters, tree heights and crown widths are assumed to be
#' given in meters, and tree diameters are assumed to be given in centimeters.
#' **TODO: not currently implemented**
#' @param main Character string giving the main plot title (on top).
#' @param crown_col The color of tree crowns.
#' @param stem_col The color of tree stems when plotting an individual subplot
#' or microplot.
#' @param subp_border_lwd The line width of subplot boundaries, a _positive_
#' number, defaulting to `3`.
#' @return
#' The input, invisibly.
#'
#' @examples
#' trees <- within(plantation, CRWIDTH <- predict_crwidth(plantation))
#'
#' plot_crowns(trees, main = "plantation plot")
#'
#' plot_crowns(trees, subplot = 4, main = "plantation subplot 4")
#'
#' plot_crowns(trees, subplot = 4, microplot = TRUE,
#'             main = "plantation microplot 4")
#' @export
plot_crowns <- function(tree_list, subplot = NULL, microplot = FALSE,
                        linear_unit = "ft", main = "", crown_col = "#328e13",
                        stem_col = "#b85e00", subp_border_lwd = 3){

    if (missing(tree_list) || is.null(tree_list))
        stop("'tree_list' is required", call. = FALSE)

    if (!is.data.frame(tree_list))
        stop("'tree_list' must be a data frame", call. = FALSE)

    required_cols <- c("SUBP", "STATUSCD", "DIA", "HT", "ACTUALHT", "AZIMUTH",
                       "DIST", "CRWIDTH")

    if (!all(required_cols %in% colnames(tree_list)))
        stop("'tree_list' is missing required columns", call. = FALSE)

    if (!all(unique(tree_list$SUBP) %in% c(1, 2, 3, 4)))
        stop("'tree_list$SUBP' contains invalid subplot numbers", call. = FALSE)

    if (any(tree_list$AZIMUTH < 0) || any(tree_list$AZIMUTH > 360))
        stop("'tree_list$AZIMUTH' contains values out of range", call. = FALSE)

    if (is.null(linear_unit))
        linear_unit <- "ft"
    else if (!(is.character(linear_unit) && length(linear_unit) == 1))
        stop("'linear_unit' must be a single character string", call. = FALSE)
    else
        linear_unit <- tolower(linear_unit)

    if (!(linear_unit %in% c("ft", "foot", "m", "meter", "metre")))
        stop("'linear_unit' is invalid", call. = FALSE)

    if (is.null(subplot) || is.na(subplot))
        subplot <- FALSE

    if (subplot) {
        if (!is.numeric(subplot) && subplot %in% 1:4)
            stop("'subplot' must be a numeric value in the range 1:4",
                 call. = FALSE)
    }

    if (is.null(microplot) || is.na(microplot))
        microplot <- FALSE

    if (!(is.logical(microplot) && length(microplot) == 1))
        stop("'microplot' must be a single logical value", call. = FALSE)

    if (subplot && microplot) {
        trees_in <- tree_list[tree_list$STATUSCD == 1 &
                              tree_list$SUBP == subplot &
                              tree_list$DIA < 5, ]
    } else if (subplot && !microplot) {
        trees_in <- tree_list[tree_list$STATUSCD == 1 &
                              tree_list$SUBP == subplot &
                              tree_list$DIA >= 5, ]
    } else {
        trees_in <- tree_list[tree_list$STATUSCD == 1 & tree_list$DIA >= 5, ]
    }

    trees_in$height <- pmin(trees_in$HT, trees_in$ACTUALHT, na.rm = TRUE)
    trees_in$dia_ft <- 0.0833333 * trees_in$DIA
    trees_in <- trees_in[order(trees_in$height), ]

    if (subplot) {
        pts <- vector(mode = "list", length = 2)
        names(pts) <- c("x", "y")
        pts$x <- trees_in$DIST * sin(trees_in$AZIMUTH * (pi / 180))
        pts$y <- trees_in$DIST * cos(trees_in$AZIMUTH * (pi / 180))
    } else {
        pts <- .get_tree_list_xy(trees_in)
    }

    crowns <- lapply(seq_len(nrow(trees_in)), \(i) {
        gdalraster::g_create("POINT", c(pts$x[i], pts$y[i])) |>
            gdalraster::g_buffer(trees_in$CRWIDTH[i] / 2)})

    if (subplot) {
        if (microplot) {
            fia_poly <- gdalraster::g_buffer("POINT (0 0)", 6.8)
        } else {
            fia_poly <- gdalraster::g_buffer("POINT (0 0)", 24)
        }
        stems <- lapply(seq_len(nrow(trees_in)), \(i) {
            gdalraster::g_create("POINT", c(pts$x[i], pts$y[i])) |>
                gdalraster::g_buffer(trees_in$dia_ft[i] / 2)})
    } else {
        fia_poly <- .get_fia_plot_geom(linear_unit = linear_unit)
    }

    rct <- as.list(gdalraster::g_build_collection(c(crowns, list(fia_poly))) |>
                   gdalraster::g_envelope())
    names(rct) <- c("xmin", "xmax", "ymin", "ymax")

    xlab <- sprintf("x (%s)", linear_unit)
    ylab <- sprintf("y (%s)", linear_unit)
    gdalraster::plot_geom(fia_poly, xlab, ylab, main, border = "gray62",
                          lwd = subp_border_lwd, bbox = rct)

    for (i in seq_len(nrow(trees_in))) {
        gdalraster::plot_geom(crowns[[i]], col = crown_col, border = NA,
                              add = TRUE)
        if (subplot) {
            gdalraster::plot_geom(stems[[i]], col = stem_col, border = NA,
                                  add = TRUE)
        }
    }

    border_col <- grDevices::adjustcolor("gray62", alpha.f = 0.2)
    gdalraster::plot_geom(fia_poly, border = border_col, lwd = subp_border_lwd,
                          add = TRUE)

    invisible(tree_list)
}
