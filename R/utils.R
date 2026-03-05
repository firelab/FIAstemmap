# .rda datasets in data/ that are used internally but also intended to be
# available to users
utils::globalVariables(c("cw_coef", "cw_sapling_adj"), package = "FIAstemmap")

#' Get stem xy coordinates for a tree list
#'
#' `.get_tree_list_xy()` returns a named list with two elemnts each containing
#' a numeric vector of the x and y coordinates for trees within the FIA
#' 4-subplot configuration.
#'
#' @param tree_list A data frame containing the standard tree list columns for
#' a plot. This input generally has been pre-filtered, e.g., to live trees with
#' `DIA >= 5.0`.
#' @return
#' A named list with elements `x` and `y` containing numeric vectors of stem
#' coordinates.
#' @noRd
#' @export
.get_tree_list_xy <- function(tree_list) {
    x <- rep(NA_real_, nrow(tree_list))
    y <- rep(NA_real_, nrow(tree_list))

    # subplot 1 "plot center" is 0, 0 (center of the center subplot)
    dist <- tree_list$DIST[tree_list$SUBP == 1]
    azimuth <- tree_list$AZIMUTH[tree_list$SUBP == 1]
    x[tree_list$SUBP == 1] <- dist * sin(azimuth * (pi / 180))
    y[tree_list$SUBP == 1] <- dist * cos(azimuth * (pi / 180))

    # subplot 2 - offsets from plot center
    xoff2 <- 0.0
    yoff2 <- 120.0
    dist <- tree_list$DIST[tree_list$SUBP == 2]
    azimuth <- tree_list$AZIMUTH[tree_list$SUBP == 2]
    x[tree_list$SUBP == 2] <- dist * sin(azimuth * (pi / 180)) + xoff2
    y[tree_list$SUBP == 2] <- dist * cos(azimuth * (pi / 180)) + yoff2

    # subplot 3 - offsets from plot center
    xoff3 <- 103.92
    yoff3 <- -60.0
    dist <- tree_list$DIST[tree_list$SUBP == 3]
    azimuth <- tree_list$AZIMUTH[tree_list$SUBP == 3]
    x[tree_list$SUBP == 3] <- dist * sin(azimuth * (pi / 180)) + xoff3
    y[tree_list$SUBP == 3] <- dist * cos(azimuth * (pi / 180)) + yoff3

    # subplot 4 - offsets from plot center
    xoff4 <- -103.92
    yoff4 <- -60.0
    dist <- tree_list$DIST[tree_list$SUBP == 4]
    azimuth <- tree_list$AZIMUTH[tree_list$SUBP == 4]
    x[tree_list$SUBP == 4] <- dist * sin(azimuth * (pi / 180)) + xoff4
    y[tree_list$SUBP == 4] <- dist * cos(azimuth * (pi / 180)) + yoff4

    list(x = x, y = y)
}
