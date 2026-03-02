#' Compute fractional tree canopy cover of a subplot/microplot by crown overlay
#'
#' @param sample_radius A numeric value giving the radius of the
#' subplot/microplot.
#' @param tree_list A data frame containing tree records for the
#' subplot/microplot. Must have columns `DIST` (stem distance from subplot
#' center in same units as `sample_radius`), `AZIMUTH` (horizontal angle from
#' subplot/microplot center to the stem location, in the range `0:359`) and
#' `CRWIDTH` (tree crown width in the same units as `sample_radius` and `DIST`).
#' @param digits Optional integer number of digits to keep in the result
#' (defaults to `1`, will be passed to `round()`).
#' @return
#' An numeric value for tree canopy cover as percent of the subplot/microplot
#' covered by a vertical projection of circular crowns.
#'
#' @examples
#' crown_overlay_pct(24, plantation[plantation$SUBP == 1 &
#'                                  plantation$DIA >= 5, ])
#' @export
crown_overlay_pct <- function(sample_radius, tree_list, digits = 1) {
    if (missing(sample_radius) || is.null(sample_radius))
        stop("'sample_radius' is required", call. = FALSE)

    if (!(is.numeric(sample_radius) && length(sample_radius) == 1))
        stop("'sample_radius' must be a single numeric value", call. = FALSE)

    if (missing(tree_list) || is.null(tree_list))
        stop("'tree_list' is required", call. = FALSE)

    if (!is.data.frame(tree_list))
        stop("'tree_list' must be a data frame", call. = FALSE)

    if (any(tree_list$AZIMUTH < 0) || any(tree_list$AZIMUTH > 360))
        stop("'tree_list$AZIMUTH' contains values out of range", call. = FALSE)

    if (is.null(digits))
        digits <- 1

    x <- tree_list$DIST * sin(tree_list$AZIMUTH * (pi / 180))
    y <- tree_list$DIST * cos(tree_list$AZIMUTH * (pi / 180))

    crowns <- lapply(seq_len(nrow(tree_list)), \(i) {
        gdalraster::g_create("POINT", c(x[i], y[i])) |>
          gdalraster::g_buffer(tree_list$CRWIDTH[i] / 2)
    })

    crowns_poly <- gdalraster::g_build_collection(crowns) |>
      gdalraster::g_unary_union()

    plot_poly <- gdalraster::g_buffer("POINT (0 0)", sample_radius, 90L)

    tcc <- gdalraster::g_intersection(plot_poly, crowns_poly) |>
      gdalraster::g_area() / gdalraster::g_area(plot_poly) * 100
    
    round(tcc, digits)
}
