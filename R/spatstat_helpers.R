#' Analyze the spatial pattern of trees on an FIA plot
#'
#' Functions that facilitate point pattern analysis of FIA tree data using the
#' \pkg{spatstat} library.
#'
#' @name spatstat_helpers
#' @details
#' `create_fia_owin()` returns an object of class `"owin"` from the
#' \pkg{spatstat} library. This object represents the generic 2-D observation
#' window for the nationally standard FIA plot design which is a four-point
#' cluster of subplots. Used when creating a \pkg{spatstat} point pattern object
#' for an FIA tree list.
#'
#' `create_fia_ppp()` returns an object of class `"ppp"` representing the point
#' pattern of an FIA tree list in the 2-D plane. A point pattern object defines
#' the dataset for using a stem-mapped FIA plot with functions of the
#' \pkg{spatstat} library.
#'
#' The standard set of columns for tree list data in \pkg{FIAstemmap} is given
#' below, along with the status of each column as required or optional for
#' `create_fia_ppp()`:
#' * `PLT_CN`: optional, `create_fia_ppp()` assumes input is for one plot
#' * `SUBP`: required subplot number
#' * `TREE`: required tree number within a subplot
#' * `AZIMUTH`: required horizontal angle from subplot center
#' * `DIST`: required distance from subplot center
#' * `STATUSCD`: required tree status code (1 = live, 2 = dead)
#' * `SPCD`: optional FIA species code
#' * `SPGRPCD`: optional FIA species group code
#' * `DIA`: optional tree diameter
#' * `HT`: optional tree height
#' * `ACTUALHT`: optional tree actual height (accounts for broken top)
#' * `CCLCD`: optional crown class code
#' * `TPA_UNADJ`: optional tree expansion factor (per acre)
#' * `CRWIDTH`: optional crown width (may be computed with **TODO**)
#'
#' @param linear_unit An optional character string specifying the linear
#' distance unit. Defaults to the native FIA unit of `"ft"`, but may be set to
#' `"m"` instead (or `"meter"` / `"metre"`).
#' @param macroplot An optional logical value. The default is `FALSE`, which
#' defines the FIA plot footprint in terms of the standard four-subplot
#' configuration with subplot radius of 24 ft (7.3152 m). By default,
#' "macroplot trees" having `DIST` outside the subplot boundary are not
#' included. This argument may be set to `TRUE` in which case the observation
#' window will be defined using the FIA optional "macroplot" configuration
#' instead (58.9 ft or 18.227 m radius, used only in certain areas of the
#' Pacific Northwest FIA region).
#' @param npoly Integer value giving the number of edges to use for polygon
#' approximation. Defaults to `360`.
#' @param tree_list A data frame containing a set of tree records for one FIA
#' plot (see Details).
#' @param live_trees A logical value, `TRUE` to include live trees only (the
#' default, i.e., `STATUSCD == 1`).
#' @param min_dia A numeric value specifying the minimum diameter threshold
#' for included trees. The default is `5.0`. Trees less than 5-in. diameter but
#' greater than or equal to 1.0-in. diameter, denoted as "saplings", are only
#' recorded in FIA microplots so cannot be stem-mapped across the full 4-subplot
#' footprint.
#' @param window An optional object of class `"owin"` defining the observation
#' window of an FIA plot in the 2-D plane. Defaults to
#' `create_fia_owin(linear_unit, macroplot)`.
#' @param mark_cols An optional character vector of column names in `tree_list`
#' to designate as \pkg{spatstat} `marks` which carry additional information for
#' each data point in a point pattern object.
#' @param mark_as_factor An optional subset of `mark_cols` to be treated as
#' `factor` marks. If not already `factor`, these will be coerced as such upon
#' input. `factor` marks are those that take only a finite number of possible
#' values (e.g. colors or types).
#'
#' @examples
#' # observation window for the standard FIA plot design
#' w <- create_fia_owin()
#' summary(w)
#'
#' # or using metric units
#' w <- create_fia_owin("m")
#' summary(w)
#'
#' plot(w, main = "FIA standard four-subplot design")
#'
#' # point pattern object for the plantation example data
#' X <- create_fia_ppp(plantation)
#' summary(X)
#'
#' plot(X, pch = 16, main = "Loblolly pine plantation")
#'
#' # plot trees as trees :)
#' X <- create_fia_ppp(plantation, mark_cols = "SPCD")
#' plot(X, main = "Loblolly pine plantation",
#'      shape = "arrows", direction = 90, size = 12, cols = "darkgreen",
#'      background = "gray90", legend = FALSE)
#'
#' # Ripley's K-function
#' K <- spatstat.explore::Kest(X, rmax = 12)
#' plot(K, main = "Ripley's K-function for the plantation trees")
#' @export
create_fia_owin <- function(linear_unit = "ft", macroplot = FALSE,
                            npoly = 360) {

    if (is.null(linear_unit))
        linear_unit <- "ft"
    else if (!(is.character(linear_unit) && length(linear_unit) == 1))
        stop("'linear_unit' must be a single character string", call. = FALSE)
    else
        linear_unit <- tolower(linear_unit)

    if (!(linear_unit %in% c("ft", "foot", "m", "meter", "metre")))
        stop("'linear_unit' is invalid", call. = FALSE)

    if (is.null(macroplot))
        macroplot <- FALSE
    else if (!(is.logical(macroplot) && length(macroplot) == 1))
        stop("'macroplot' must be a single logical value", call. = FALSE)

    if (is.null(npoly))
        npoly <- 720L
    else if (!(is.numeric(npoly) && length(npoly) == 1))
        stop("'npoly' must be a single integer value", call. = FALSE)

    # avoid points falling outside a subplot boundary due to rounding error by
    # adding 0.001 here
    subp_radius <- 24.001
    if (macroplot)
        subp_radius <- 59.801

    unit_conv <- 1  # FIA native unit ft
    unit_names <- c("foot", "feet")
    if (linear_unit %in% c("m", "meter", "metre")) {
        unit_conv <- 0.3048  # ft to m
        unit_names <- c("meter", "meters")
        subp_radius <- subp_radius * unit_conv
    }

    s1 <- spatstat.geom::disc(subp_radius, c(0, 0), npoly = npoly)
    s2 <- spatstat.geom::disc(subp_radius,
                              c(0, 120 * unit_conv),
                              npoly = npoly)
    s3 <- spatstat.geom::disc(subp_radius,
                              c(103.92 * unit_conv, -60 * unit_conv),
                              npoly = npoly)
    s4 <- spatstat.geom::disc(subp_radius,
                              c(-103.92 * unit_conv, -60 * unit_conv),
                              npoly = npoly)

    w <- spatstat.geom::union.owin(s1, s2, s3, s4)
    spatstat.geom::unitname(w) <- unit_names

    return(w)
}

#' @name spatstat_helpers
#' @export
create_fia_ppp <- function(tree_list, live_trees = TRUE, min_dia = 5,
                           linear_unit = "ft", macroplot = FALSE, window = NULL,
                           mark_cols = NULL, mark_as_factor = NULL) {

    if (missing(tree_list) || is.null(tree_list))
        stop("'tree_list' is required", call. = FALSE)

    if (!is.data.frame(tree_list))
        stop("'tree_list' must be a data frame", call. = FALSE)

    required_cols <- c("SUBP", "TREE", "AZIMUTH", "DIST", "STATUSCD")
    if (!all(required_cols %in% colnames(tree_list)))
        stop("'tree_list' is missing required columns", call. = FALSE)

    if (!all(unique(tree_list$SUBP) %in% c(1, 2, 3, 4)))
        stop("'tree_list$SUBP' contains invalid subplot numbers", call. = FALSE)

    if (any(tree_list$AZIMUTH < 0) || any(tree_list$AZIMUTH > 360))
        stop("'tree_list$AZIMUTH' contains values out of range", call. = FALSE)

    if (is.null(live_trees))
        live_trees <- TRUE
    else if (!(is.logical(live_trees) && length(live_trees) == 1))
        stop("'live_trees' must be a single logical value", call. = FALSE)

    if (is.null(min_dia))
        min_dia <- 5
    else if (!(is.numeric(min_dia) && length(min_dia) == 1))
        stop("'min_dia' must be a single numeric value", call. = FALSE)

    if (is.null(linear_unit))
        linear_unit <- "ft"
    else if (!(is.character(linear_unit) && length(linear_unit) == 1))
        stop("'linear_unit' must be a single character string", call. = FALSE)
    else
        linear_unit <- tolower(linear_unit)

    if (!(linear_unit %in% c("ft", "foot", "m", "meter", "metre")))
        stop("'linear_unit' is invalid", call. = FALSE)

    if (is.null(macroplot))
        macroplot <- FALSE
    else if (!(is.logical(macroplot) && length(macroplot) == 1))
        stop("'macroplot' must be a single logical value", call. = FALSE)

    if (is.null(window))
        window <- create_fia_owin(linear_unit, macroplot)
    else if (!methods::is(window, "owin"))
        stop("'window' must be an object of class `owin`", call. = FALSE)

    if (!is.null(mark_cols) && !is.character(mark_cols))
        stop("'mark_cols' must be a character vector", call. = FALSE)
    else if (!all(mark_cols %in% colnames(tree_list)))
        stop("'tree_list' is missing one or more columns in 'mark_cols",
             call. = FALSE)

    if (!is.null(mark_as_factor) && !is.character(mark_as_factor))
        stop("'mark_as_factor' must be a character vector", call. = FALSE)
    else if (!all(mark_as_factor %in% mark_cols))
        stop("'mark_cols' is missing one or more columns in 'mark_as_factor",
             call. = FALSE)

    tree_list_in <- tree_list
    if (live_trees) {
        tree_list_in <- tree_list[tree_list$STATUSCD == 1 &
                                  tree_list$DIA >= min_dia, ]
    } else {
        tree_list_in <- tree_list[tree_list$DIA >= min_dia, ]
    }

    xy <- .get_tree_list_xy(tree_list_in)

    marks <- NULL
    if (!is.null(mark_cols))
        marks <- tree_list_in[, mark_cols]

    if (!is.null(mark_as_factor)) {
        if (is.vector(marks)) {
            if (!is.factor(marks))
                marks <- as.factor(marks)
        } else {
            for (col in mark_as_factor) {
                if (!is.factor(marks[, col]))
                    marks[, col] <- as.factor(marks[, col])
            }
        }
    }

    spatstat.geom::ppp(xy$x, xy$y, window = window, marks = marks)
}
