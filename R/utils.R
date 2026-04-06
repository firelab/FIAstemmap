#' Get stem xy coordinates for an FIA tree list
#'
#' `.get_tree_list_xy()` returns a named list with two elements each containing
#' a numeric vector of the x and y coordinates for trees within the FIA
#' 4-subplot configuration. The origin is the center of the center subplot.
#'
#' @param tree_list A data frame containing the standard tree list columns for
#' a plot. This input generally has been pre-filtered, e.g., to live trees with
#' `DIA >= 5.0`.
#' @param linear_unit An optional character string specifying the linear
#' distance unit. Defaults to the native FIA unit of `"ft"`, but may be set to
#' `"m"` instead (or `"meter"` / `"metre"`). Specifies units of the input
#' `tree_list$DIST`.
#' @return
#' A named list with elements `x` and `y` containing numeric vectors of stem
#' coordinates.
#' @noRd
#' @export
.get_tree_list_xy <- function(tree_list, linear_unit = "ft") {
    unit_conv <- 1  # FIA native unit ft
    if (linear_unit %in% c("m", "meter", "metre")) {
        unit_conv <- 0.3048  # ft to m
    }

    x <- rep(NA_real_, nrow(tree_list))
    y <- rep(NA_real_, nrow(tree_list))

    # subplot 1 "plot center" is 0, 0 (center of the center subplot)
    dist <- tree_list$DIST[tree_list$SUBP == 1]
    azimuth <- tree_list$AZIMUTH[tree_list$SUBP == 1]
    x[tree_list$SUBP == 1] <- dist * sin(azimuth * (pi / 180))
    y[tree_list$SUBP == 1] <- dist * cos(azimuth * (pi / 180))

    # subplot 2 - offsets from plot center
    xoff2 <- 0.0
    yoff2 <- 120.0 * unit_conv
    dist <- tree_list$DIST[tree_list$SUBP == 2]
    azimuth <- tree_list$AZIMUTH[tree_list$SUBP == 2]
    x[tree_list$SUBP == 2] <- dist * sin(azimuth * (pi / 180)) + xoff2
    y[tree_list$SUBP == 2] <- dist * cos(azimuth * (pi / 180)) + yoff2

    # subplot 3 - offsets from plot center
    xoff3 <- 103.92 * unit_conv
    yoff3 <- -60.0 * unit_conv
    dist <- tree_list$DIST[tree_list$SUBP == 3]
    azimuth <- tree_list$AZIMUTH[tree_list$SUBP == 3]
    x[tree_list$SUBP == 3] <- dist * sin(azimuth * (pi / 180)) + xoff3
    y[tree_list$SUBP == 3] <- dist * cos(azimuth * (pi / 180)) + yoff3

    # subplot 4 - offsets from plot center
    xoff4 <- -103.92 * unit_conv
    yoff4 <- -60.0 * unit_conv
    dist <- tree_list$DIST[tree_list$SUBP == 4]
    azimuth <- tree_list$AZIMUTH[tree_list$SUBP == 4]
    x[tree_list$SUBP == 4] <- dist * sin(azimuth * (pi / 180)) + xoff4
    y[tree_list$SUBP == 4] <- dist * cos(azimuth * (pi / 180)) + yoff4

    list(x = x, y = y)
}

#' Get a WKB or WKT geometry for an FIA plot
#'
#' `.get_fia_plot_geom()` returns a MultiPolygon geometry for the FIA 4-point
#' cluster design.
#'
#' @param center_x Numeric x coordinate of plot center (center of the center
#' subplot).
#' @param center_y Numeric y coordinate of plot center (center of the center
#' subplot).
#' @param macroplot A logical value, `TRUE` to use the FIA optional "macroplot"
#' dimension. Default is `FALSE`.
#' @param linear_unit An optional character string specifying the linear
#' distance unit. Defaults to the native FIA unit of `"ft"`, but may be set to
#' `"m"` instead (or `"meter"` / `"metre"`).
#' @param quad_segs Integer number of segments used to define a 90 degree curve
#' (quadrant of a circle). Passed to `gdalraster::g_buffer()`. Defaults to `30`.
#' @param as_wkb A logical value, `TRUE` to return the geometry as a `"raw"`
#' vector of WKB (the default). Can be set to `FALSE` to return a `"character"`
#' string of WKT instead.
#' @return
#' A MultiPolygon geometry as a raw vector of WKB by default, or as a character
#' string of WKT if `as_wkb = FALSE`.
#' @noRd
#' @export
.get_fia_plot_geom <- function(center_x = 0, center_y = 0, macroplot = FALSE,
                               linear_unit = "ft", quad_segs = 30L,
                               as_wkb = TRUE) {

    subp_radius <- 24
    if (macroplot)
        subp_radius <- 59.8

    unit_conv <- 1  # FIA native unit ft
    if (linear_unit %in% c("m", "meter", "metre")) {
        unit_conv <- 0.3048  # ft to m
        subp_radius <- subp_radius * unit_conv
    }

    sub_geoms <- vector(mode = "list", length = 4)

    sub_geoms[[1]] <- gdalraster::g_create("POINT", c(center_x, center_y)) |>
        gdalraster::g_buffer(subp_radius, quad_segs = quad_segs)

    s2_y <- center_y + (120 * unit_conv)
    sub_geoms[[2]] <- gdalraster::g_create("POINT", c(center_x, s2_y)) |>
        gdalraster::g_buffer(subp_radius, quad_segs = quad_segs)

    s3_x <- center_x + (103.92 * unit_conv)
    s3_y <- center_y + (-60 * unit_conv)
    sub_geoms[[3]] <- gdalraster::g_create("POINT", c(s3_x, s3_y)) |>
        gdalraster::g_buffer(subp_radius, quad_segs = quad_segs)

    s4_x <- center_x + (-103.92 * unit_conv)
    s4_y <- s3_y
    sub_geoms[[4]] <- gdalraster::g_create("POINT", c(s4_x, s4_y)) |>
        gdalraster::g_buffer(subp_radius, quad_segs = quad_segs)

    gdalraster::g_build_collection(sub_geoms, "MULTIPOLYGON", as_wkb)
}
