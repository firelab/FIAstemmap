#' Compute fractional tree canopy cover of a subplot/microplot by crown overlay
#'
#' `calc_crown_overlay()` computes the proportion of a circular polygon covered
#' by a given set of tree crowns modeled as discs and having spatially explicit
#' stem locations. The sampled area is generally an FIA subplot with radius 24
#' ft (7.315 m) for trees with diameter \verb{>= 5 in.} (12.7 cm), or an FIA
#' microplot with radius 6.8 ft (2.073 m) for trees \verb{>= 1 in.} (2.54 cm)
#' but \verb{< 5 in.} (12.7 cm) diameter (denoted as "saplings"). Stem locations
#' are specified as distance and azimuth from subplot/microplot center.
#'
#' @param tree_list A data frame containing tree records for a
#' subplot/microplot. Must have columns `DIST` (stem distance from
#' subplot/microplot center in the same units as `sample_radius`), `AZIMUTH`
#' (horizontal angle from subplot/microplot center to the stem location, in the
#' range `0:359`) and `CRWIDTH` (tree crown width in the same units as
#' `sample_radius` and `DIST`).
#' @param sample_radius A numeric value giving the radius of the circular
#' subplot/microplot.
#' @param digits Optional integer indicating the number of digits to keep in the
#' return value (defaults to `1`, will be passed to `round()`).
#' @return
#' Estimated tree canopy cover as percent of the area specified by
#' `sample_radius` that is covered by a vertical projection of circular
#' crowns.
#'
#' @note
#' This function does not perform any filtering based on `SUBP` (subplot),
#' `STATUSCD`(live vs dead trees) or`DIA` (mature trees vs saplings). The input
#' tree list is assumed to be filtered to the specific set of live trees for
#' one subplot or microplot with the given `sample_radius`.
#'
#' @seealso
#' [calc_tcc_metrics()]
#'
#' @examples
#' # subplot 1 of the `plantation` plot
#' trees <- within(plantation, CRWIDTH <- calc_crwidth(plantation))
#' trees[trees$SUBP == 1 & trees$DIA >= 5, ] |>
#'   calc_crown_overlay(sample_radius = 24)
#'
#' plot_crowns(trees, subplot = 1, main = "plantation subplot 1")
#' @export
calc_crown_overlay <- function(tree_list, sample_radius, digits = 1) {
    if (missing(tree_list) || is.null(tree_list)) {
        stop(cli::format_error(c(
            "{.arg tree_list} is required",
        "x" = "A required argument is missing or NULL")))
    }

    if (!is.data.frame(tree_list)) {
        stop(cli::format_error(c(
            "{.arg tree_list} must be a {.cls data.frame}",
        "x" = "Invalid input type: {.cls {class(tree_list)}}")))
    }

    if (any(is.na(tree_list$AZIMUTH))) {
        stop(cli::format_error(c(
            "{.fld tree_list$AZIMUTH} has missing values",
        "x" = "{.fld tree_list$AZIMUTH} cannot contain {.val {NA}} values")))
    }

    if (any(tree_list$AZIMUTH < 0) || any(tree_list$AZIMUTH > 360)) {
        stop(cli::format_error(c(
            "{.fld tree_list$AZIMUTH} contains out-of-range values",
        "x" = "azimuth values must be in the range 0:360")))
    }

    if (missing(sample_radius) || is.null(sample_radius)) {
        stop(cli::format_error(c(
            "{.arg sample_radius} is required",
        "x" = "A required argument is missing or NULL")))
    }

    if (!(is.numeric(sample_radius) && length(sample_radius) == 1)) {
        stop(cli::format_error(c(
            "{.arg sample_radius} must be a single {.cls numeric} value",
        "x" = "Invalid input: length-{length(sample_radius)} {.cls {class(sample_radius)}}")))
    }

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
