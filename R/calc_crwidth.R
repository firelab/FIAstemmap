#' Predict individual tree crown width using species-specific equations
#'
#' `calc_crwidth()` predicts tree crown width using species-specific
#' regression equations from the literature.
#'
#' @details
#' Crown width is predicted from tree diameter using coefficients provided in
#' the lookup table [cw_coef] (see `?cw_coef`) The method also incorporates
#' adjustment factors used to derive crown width estimates for FIA "saplings",
#' i.e., trees less than 5.0 in. (12.7 cm) diameter but greater than or equal
#' to 1.0 in. (2.54 cm) diameter. Details are described in the documentation
#' for the lookup table [cw_sapling_adj].
#'
#' Large diameter trees in the temperate rain forests of the Pacific Northwest
#' region can far exceed the range of diameters in the broadly applicable
#' datasets that have been used to develop crown width prediction equations
#' (Bechtold 2003, 2004). To avoid extrapolation beyond the range of the model
#' fitting data in those cases, `calc_crwidth()` makes use of the "old growth"
#' equation presented by Gill et al. (2000) to estimate crown width for nine
#' tree species when their diameter is greater than 50 in. (127 cm).
#'
#' @param tree_list A data frame containing tree records. Must have columns
#' `SPCD` (FIA integer species code), `STATUSCD` (FIA integer tree status code,
#' 1 = live) and `DIA` (FIA tree diameter in inches).
#' @param digits Optional integer indicating the number of digits to keep in the
#' return values (defaults to `1`).
#' @return
#' A numeric vector of length `nrow(tree_list)` with predicted crown width in
#' feet for live trees. `NA` is returned for trees with `STATUSCD != 1`.
#'
#' @references
#' Bechtold, W.A. 2003. Crown-diameter prediction models for 87 species of
#' stand-grown trees in the eastern United States. _Southern Journal of Applied
#' Forestry_, 27(4): 269-278.
#'
#' Bechtold, W.A. 2004. Largest-crown-width prediction models for 53 species in
#' the western United States. _Western Journal of Applied Forestry_, 19(4):
#' 245-251.
#'
#' Gill, S.J., G.S. Biging, E.C. Murphy. 2000. Modeling conifer tree crown
#' radius and estimating canopy cover. _Forest Ecology and Management_, 126(3):
#' 405-416.
#'
#' @seealso
#' [cw_coef], [cw_sapling_adj]
#'
#' @examples
#' calc_crwidth(plantation)
#' @export
calc_crwidth <- function(tree_list, digits = 1) {
    if (missing(tree_list) || is.null(tree_list))
        stop("'tree_list' is required", call. = FALSE)

    if (!is.data.frame(tree_list))
        stop("'tree_list' must be a data frame", call. = FALSE)

    required_cols <- c("SPCD", "STATUSCD", "DIA")
    if (!all(required_cols %in% colnames(tree_list)))
        stop("'tree_list' is missing required columns", call. = FALSE)

    if (!is.numeric(tree_list$SPCD))
        stop("'tree_list$SPCD' must be numeric or integer", call. = FALSE)
    if (any(is.na(tree_list$SPCD)))
        stop("'tree_list$SPCD' cannot have missing values", call. = FALSE)

    if (!is.numeric(tree_list$STATUSCD))
        stop("'tree_list$STATUSCD' must be numeric or integer", call. = FALSE)
    if (any(is.na(tree_list$STATUSCD)))
        stop("'tree_list$STATUSCD' cannot have missing values", call. = FALSE)

    if (!is.numeric(tree_list$DIA))
        stop("'tree_list$DIA' must be numeric", call. = FALSE)
    if (any(is.na(tree_list$DIA)))
        stop("'tree_list$DIA' cannot have missing values", call. = FALSE)

    if (is.null(digits))
        digits <- 1

    cw <- rep_len(NA_real_, nrow(tree_list))

    # define a default equation to use in case a species-specific one is missing
    # SPCD == 807, blue oak
    b_default <- cw_coef[cw_coef$SPCD == 807, c("b0", "b1", "b2")]

    # special case for large trees of certain species in the PNW region:
    # use the "old growth" equation from Gill et al. (2000)
    old_growth_trees <- tree_list$DIA > 50 & tree_list$STATUSCD == 1 &
        tree_list$SPCD %in% c(11, 98, 108, 119, 122, 202, 242, 263, 264)

    cw[old_growth_trees] <- 16.449 + 0.4067 * tree_list$DIA[old_growth_trees]

    # apply species-specific equations
    # NB: crwidth of trees with DIA < 5 in. (i.e. "saplings") is predicted for
    # DIA = 5 and then sapling crwidth adjustment factors are applied afterward
    for (spcd in unique(tree_list$SPCD)) {
        b <- cw_coef[cw_coef$SPCD == spcd, c("b0", "b1", "b2")]
        if (nrow(b) == 0)
            b <- b_default

        this_subset <-
            tree_list$SPCD == spcd & tree_list$STATUSCD == 1 & is.na(cw)

        cw[this_subset] <-
            b$b0 + b$b1 * pmax(5, tree_list$DIA[this_subset]) +
            b$b2 * pmax(5, tree_list$DIA[this_subset])^2
    }

    # apply sapling crown width adjustment factors
    saplings <- tree_list$DIA < 5 & tree_list$STATUSCD == 1
    sapling_spp <- unique(tree_list$SPCD[saplings])
    # species-specific adjustment factors if any (based on Bragg 2001)
    spcd_adj <- intersect(sapling_spp, cw_sapling_adj$SPCD)
    for (spcd in spcd_adj) {
        rowid <- which(cw_sapling_adj$SPCD == spcd)
        # adjustment factors at 1, 2, 3, 4, 5 inches DIA:
        adj_factors <- c(as.numeric(cw_sapling_adj[rowid, 2:5]), 1)
        this_subset <- saplings & tree_list$SPCD == spcd
        # interpolated adjustment factors for the actual sapling diameters:
        n <- trunc(tree_list$DIA[this_subset])
        cw_adj <- (tree_list$DIA[this_subset] - n) *
                  (adj_factors[n + 1] - adj_factors[n]) + adj_factors[n]
        cw[this_subset] <- cw[this_subset] * cw_adj
    }
    # otherwise use avarage adjustment factors based on Bragg (2001) data
    # average adjustment factors at 1, 2, 3, 4, 5 inches DIA:
    adj_factors <- c(0.509, 0.644, 0.767, 0.885, 1.0)
    this_subset <- saplings & !(tree_list$SPCD %in% cw_sapling_adj$SPCD)
    # interpolated adjustment factors for the actual sapling diameters:
    n <- trunc(tree_list$DIA[this_subset])
    cw_adj <- (tree_list$DIA[this_subset] - n) *
              (adj_factors[n + 1] - adj_factors[n]) + adj_factors[n]
    cw[this_subset] <- cw[this_subset] * cw_adj

    round(cw, digits = digits)
}
