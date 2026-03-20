#' Predict plot-level canopy cover from individual tree measurements
#'
#' `calc_tcc_metrics()` computes plot-level predicted tree canopy cover (TCC)
#' from tree list data. By default, a full set of stand structure metrics used
#' to derive the plot-level TCC prediction are included in the output (see
#' Details).
#'
#' @details
#' This function provides two methods for predicting plot-level TCC.
#'
#' The default "stem-map" method requires individual tree coordinates to be
#' given in the input as distance and azimuth from subplot centers for trees
#' with diameter \verb{>= 5 in.} (12.7 cm), and from microplot centers for
#' "saplings" having diameter \verb{>= 1 in.} (2.54 cm) but \verb{< 5 in.}
#' (12.7 cm). This method involves mapping trees spatially within the plot
#' boundary to account for crown overlap explicitly, along with empirical
#' modeling of the understory sapling contribution to total canopy cover
#' (Toney et al. 2009). The empirical model for the sapling component also uses
#' the spatial point pattern of overstory trees as a predictor variable (using
#' a square root transformation of Ripley's edge-corrected K function, Ripley
#' 1977, Stoyan and Penttinen 2000).
#'
#' Alternatively, plot-level TCC can be predicted using a simplified approach
#' that does not include exact stem placement (`stem_map = FALSE`). A random
#' arrangement of stems is assumed in that case. This is the method used to
#' estimate tree canopy cover in the Forest Vegetation Simulator (Crookston and
#' Stage 1999).
#'
#' Both methods require estimates of individual tree crown width, which are
#' computed with `calc_crwidth()` if not provided in the input tree list.
#'
#' The stem-map method also requires computation of several stand structure
#' metrics, as components of the overall model used to derive a plot-level TCC
#' estimate. These additional variables include:
#'
#' * individual subplot and microplot crown overlays via `calc_crown_overlay()`
#' * a stand height metric (`meanTreeHtBAW`) via `calc_ht_metrics()`
#' * plot-level counts of mature trees and saplings
#' * descriptive spatial statistics for the overstory tree point pattern via
#' `create_fia_ppp() |> spatstat.explore::Lest()`
#'
#'
#'
#' @param tree_list A data frame with tree records for one FIA plot. In general,
#' the input data frame will have the columns specified in
#' [DEFAULT_TREE_COLUMNS] (see `?DEFAULT_TREE_COLUMNS`). Potentially, only a
#' subset of those columns will be needed depending on values given for the
#' arguments `stem_map` and `full_output` described below. If the input data
#' frame has a column named `"CRWIDTH"` it will be used for tree crown width
#' values, otherwise, crown widths will be calculated with a call to
#' `calc_crwidth()`.
#' @param stem_map A logical value indicating whether to map individual trees
#' explicitly using coordinates specified in terms of distance and azimuth from
#' subplot/microplot centers. The default is `TRUE`, in which case the input
#' `tree_list` must contain columns `"DIST"` and `"AZIMUTH"`. This argument may
#' be set to `FALSE` if individual tree locations are not available, in which
#' case TCC will be predicted assuming a random arrangement of the stems (see
#' Details).
#' @param full_output A logical value indicating whether to include the full set
#' of components used to derive the plot-level prediction. By default, the
#' output list includes subplot-level TCC estimates, live tree and sapling
#' counts, stand height metrics, and point pattern statistics, depending on the
#' value given for `stem_map` (see Details).
#' @param digits Optional integer indicating the number of digits to keep in the
#' return values (defaults to `1`). May be passed to `calc_crwidth()` and
#' `calc_ht_metrics()`.
#' @return
#' If `full_output = TRUE`, a named list with the element `model_tcc` containing
#' plot-level predicted tree canopy cover percent (`0:100`), and additional
#' named elements containing stand structure metrics as described in Details.
#' If `full_output = FALSE`, a single numeric value of plot-level predicted TCC
#' is returned instead.
#'
#' @references
#' Crookston, N.L. and A.R. Stage. (1999). Percent canopy cover and stand
#' structure statistics from the Forest Vegetation Simulator. Gen. Tech. Rep.
#' RMRS-GTR-24. Ogden, UT: U. S. Department of Agriculture, Forest Service,
#' Rocky Mountain Research Station. 11 p.
#' \url{https://research.fs.usda.gov/treesearch/6261}.
#'
#' Ripley, B.D. (1977). Modelling spatial patterns. _Journal of the Royal
#' Statistical Society: Series B (Methodological)_, 39(2): 172–192.
#' \url{https://doi.org/10.1111/j.2517-6161.1977.tb01615.x}.
#'
#' Stoyan, D., and Penttinen, A. (2000). Recent Applications of Point Process
#' Methods in Forestry Statistics. _Statistical Science_, 15(1), 61–78.
#' \url{http://www.jstor.org/stable/2676677}.
#'
#' Toney, C., J.D. Shaw and M.D. Nelson. 2009. A stem-map model for predicting
#' tree canopy cover of Forest Inventory and Analysis (FIA) plots. In:
#' McWilliams, Will; Moisen, Gretchen; Czaplewski, Ray, comps. _Forest Inventory
#' and Analysis (FIA) Symposium 2008_; October 21-23, 2008; Park City, UT. Proc.
#' RMRS-P-56CD. Fort Collins, CO: U.S. Department of Agriculture, Forest
#' Service, Rocky Mountain Research Station. 19 p.
#' \url{https://research.fs.usda.gov/treesearch/33381}.
#'
#' @seealso
#' [calc_crwidth()], [calc_crown_overlay()], [calc_ht_metrics()],
#' [create_fia_ppp()]
#'
calc_tcc_metrics <- function(tree_list, stem_map = TRUE, full_output = TRUE,
                             digits = 1) {

    if (!(is.logical(stem_map) && length(stem_map) == 1))
        stop("'stem_map' must be a single logical value", call. = FALSE)

    if (!(is.logical(full_output) && length(full_output) == 1))
        stop("'full_output' must be a single logical value", call. = FALSE)

    X <- NULL  # spatstat point pattern object
    L_mean <- NA_real_  # predictor variable based on Ripley's K
    if (stem_map) {
        # validate the input tree list for stem-mapping and get X
        X <- create_fia_ppp(tree_list)

        # get estimate of the L-function (square root transform of Ripley's K)
        # r = 0:12 feet
        L <- spatstat.explore::Lest(X, r = 0:12)
        # mean of L at r = 6, 8, 10, 12 ft (Ripley's isotropic edge correction)
        L_mean <- mean(L$iso[c(7, 9, 11, 13)])
    }

    ht_metrics <- NULL
    if (stem_map || full_output) {
        # validate the input tree list for stand height calc and get metrics
        ht_metrics <- calc_ht_metrics(tree_list)
    }

    if (!("CRWIDTH" %in% colnames(tree_list)))
        tree_list$CRWIDTH <- calc_crwidth(tree_list)

    model_tcc <- NA_real_
    if (stem_map) {
        # implement the stem-map canopy cover model from Toney et al. (2009)
        # subplot and microplot crown overlays
        subp_overlay <- rep(NA_real_, 4)
        micr_overlay <- rep(NA_real_, 4)
        for (i in 1:4) {
            # subplot trees
            tree_subp <- tree_list[tree_list$SUBP == i &
                                   tree_list$STATUSCD == 1 &
                                   tree_list$DIA >= 5, ]

            if (nrow(tree_subp) == 0) {
                subp_overlay[i] <- 0
            } else {
                subp_overlay[i] <- calc_crown_overlay(tree_subp, 24)
            }

            # microplot saplings
            sap_micr <- tree_list[tree_list$SUBP == i &
                                  tree_list$STATUSCD == 1 &
                                  tree_list$DIA < 5, ]

            if (nrow(sap_micr) == 0) {
                micr_overlay[i] <- 0
            } else {
                micr_overlay[i] <- calc_crown_overlay(sap_micr, 6.8)
            }
        }

        subp_overlay_tcc <- NA_real_
        micr_overlay_tcc <- NA_real_
        if (all(subp_overlay == 0) && all(micr_overlay == 0)) {
            subp_overlay_tcc <- 0
            micr_overlay_tcc <- 0
            model_tcc <- 0
        } else {
            subp_overlay_tcc <- mean(subp_overlay)
            micr_overlay_tcc <- mean(micr_overlay)

            if (subp_overlay_tcc < 10) {
                # plot has low cover of trees > 5.0-in. DIA: combine tree and
                # sapling cover estimated by crown overlay on the subplots and
                # microplots, respectively
                model_tcc <- subp_overlay_tcc + micr_overlay_tcc
            }
            else {
                # apply an adjustment to plot-level canopy cover based on crown
                # overlay to account for the sapling contribution

                # estimated by linear regression using RMRS FIA line-intercept
                # data for all single-condition DESGNCD == 1 plots through 2005
                # with subp_overlay_tcc >= 10 (FORTYPCDs 925 and 926 omitted)
                sapling_component <-
                    -8.036 +
                    0.211 * micr_overlay_tcc +
                    0.552 * ht_metrics$numSaplings +
                    4.367 * log(ht_metrics$meanTreeHtBAW) +
                    -0.131 * ht_metrics$numTrees +
                    0.222 * L_mean

                # do not allow negative sapling adjustment
                sapling_component <- max(c(sapling_component, 0))

                model_tcc <-
                    min(c(subp_overlay_tcc + sapling_component, 100)) |>
                        round(digits = digits)
            }
        }

    } else {
        # "FVS method" for percent canopy cover, assuming random tree locations
        if (!("TPA_UNADJ" %in% colnames(tree_list))) {
            stop("'TPA_UNADJ' is a required column in 'tree_list'",
                 call. = FALSE)
        }

        # total "uncorrected" plot canopy cover without accounting for overlap
        # Crookston and Stage (1999) Eq. 1
        tot_crown_area_per_acre <-
            sum(tree_list$TPA_UNADJ[tree_list$STATUSCD == 1] * pi *
                (tree_list$CRWIDTH[tree_list$STATUSCD == 1] / 2)^2)

        C_uncorrected <- 100 * tot_crown_area_per_acre / 43560

        # corrected plot canopy cover accounting for overlap
        # Crookston and Stage (1999) Eq. 2
        model_tcc <- round(100 * (1 - exp(-0.01 * C_uncorrected)), digits)
    }

    return(model_tcc)
}
