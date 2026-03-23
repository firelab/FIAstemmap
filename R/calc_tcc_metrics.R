#' Predict plot-level canopy cover from individual tree measurements
#'
#' `calc_tcc_metrics()` computes predicted plot-level tree canopy cover (TCC)
#' from standard field inventory measurements. By default, the output includes
#' a full set of stand structure variables used to model the plot-level TCC
#' value (see Details).
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
#' a square root transformation of Ripley's edge-corrected K-function, Ripley
#' 1977, Stoyan and Penttinen 2000).
#'
#' Alternatively, TCC can be predicted using a simplified approach that does not
#' include exact stem placement within the plot boundary (`stem_map = FALSE`). A
#' random arrangement of stems is assumed in that case. This is the method used
#' to estimate tree canopy cover in the Forest Vegetation Simulator (Crookston
#' and Stage 1999).
#'
#' Both methods require estimates of individual tree crown widths, which are
#' computed with `calc_crwidth()` if not provided in the input tree list.
#'
#' The stem-map method also requires computation of several stand structure
#' metrics which are used in various components of the overall model used to
#' derive a plot-level TCC estimate. These additional variables include:
#'
#' * individual subplot and microplot crown overlays via `calc_crown_overlay()`
#' * a stand height metric (`meanTreeHtBAW`), and plot-level counts of mature
#' trees and saplings, via `calc_ht_metrics()`
#' * descriptive spatial statistics for the overstory tree point pattern via
#' `create_fia_ppp() |> spatstat.explore::Lest()`
#'
#' By default, `calc_tcc_metrics()` returns a named list containing the
#' plot-level modeled TCC value, along with those additional component
#' variables. Specific elements of the returned list include some or all of the
#' following, conditionally:
#'
#' * `$model_tcc`: plot-level predicted canopy cover of trees `>= 1` inch
#' (`2.54` cm)  diameter, derived by one of the two methods described above
#' depending on the value given for argument `stem_map = TRUE|FALSE`
#'
#' If the stem-map method is used, then TCC values derived by crown overlay
#' on the individual subplot and microplot boundaries are included, along with
#' means of the four subplot/microplot values:
#'
#' * `$subpN_crown_overlay`: estimated canopy cover of trees `>= 5-in.`
#' (12.7 cm) diameter in subplot `N` based on crown overlay (`N = 1:4`)
#' * `$subp_overlay_mean`: mean of the four subplot crown overlays
#' * `$micrN_crown_overlay`: estimated canopy cover of saplings in the microplot
#' of subplot `N` based on crown overlay (`N = 1:4`)
#' * `$micr_overlay_mean`: mean of the four microplot crown overlays
#'
#' A set of spatial point pattern statistics is also included when the stem-map
#' method is used. A square root transformation of Ripley's K function using
#' isotropic edge correction is computed with `spatstat.explore::Lest()` for
#' trees `>= 5-in.` (12.7 cm) diameter within the four-subplot observation
#' window. The mean of the following values is a predictor variable in a linear
#' regression model used to estimate the sapling contribution to total tree
#' canopy cover:
#'
#' * `$L_rft`: estimates of the L-function at `r` feet (`r` = `6`, `8`, `10`,
#' and `12`)
#'
#' If the argument `full_output = TRUE` (the default), then the output will
#' also include all of the the named elements from the output of
#' `calc_ht_metrics()`.
#'
#' @param tree_list A data frame with tree records for one FIA plot. In general,
#' the input data frame will have the columns specified in
#' [DEFAULT_TREE_COLUMNS] (see `?DEFAULT_TREE_COLUMNS`). Potentially, only a
#' subset of those columns will be needed depending on values given for the
#' arguments `stem_map` and `full_output` described below. If the input data
#' frame has a column named `"CRWIDTH"` it will be used for tree crown width
#' values, otherwise, crown widths will be calculated with a call to
#' `calc_crwidth()`.
#' @param stem_map A logical value indicating whether to map individual tree
#' stems explicitly, using coordinates specified in terms of distance and
#' azimuth from subplot/microplot centers. The default is `TRUE`, in which case
#' the input `tree_list` must contain columns `"DIST"` and `"AZIMUTH"`. This
#' argument may be set to `FALSE` if individual tree locations are not
#' available, in which case TCC will be predicted assuming a random arrangement
#' of tree locations (see Details).
#' @param full_output A logical value indicating whether to include the full set
#' of components used to derive the plot-level prediction. By default, the
#' output list includes subplot-level TCC estimates, live tree and sapling
#' counts, stand height metrics, and point pattern statistics, depending on the
#' value given for `stem_map` (see Details).
#' @param digits Optional integer indicating the number of digits to keep in the
#' return values (defaults to `1`). May be passed to `calc_crwidth()` and
#' `calc_ht_metrics()`.
#' @return
#' If `full_output = TRUE`, a named list with element `model_tcc` containing
#' the plot-level predicted tree canopy cover as percent (`0:100`), and
#' additional named elements containing stand structure metrics as described in
#' Details. If `full_output = FALSE`, a single numeric value of plot-level
#' predicted TCC is returned instead.
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
#' Stoyan, D., and Penttinen, A. (2000). Recent applications of point process
#' methods in forestry statistics. _Statistical Science_, 15(1), 61–78.
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
#' @examples
#' # using the spatially explicit "stem-map model" by default
#' calc_tcc_metrics(plantation)
#'
#' # return only the predicted TCC value (`$model_tcc`)
#' calc_tcc_metrics(plantation, full_output = FALSE)
#'
#' # using the "FVS method" which assumes random tree locations
#' calc_tcc_metrics(plantation, stem_map = FALSE, full_output = FALSE)
#' @export
calc_tcc_metrics <- function(tree_list, stem_map = TRUE, full_output = TRUE,
                             digits = 1) {

    if (!(is.logical(stem_map) && length(stem_map) == 1))
        stop("'stem_map' must be a single logical value", call. = FALSE)

    if (!(is.logical(full_output) && length(full_output) == 1))
        stop("'full_output' must be a single logical value", call. = FALSE)

    L_mean <- NA_real_
    if (stem_map) {
        # validate the input tree list for stem-mapping and get an estimate
        # of the L-function (square root transform of Ripley's K)
        # r = 0:12 feet
        L <- create_fia_ppp(tree_list) |>
            spatstat.explore::Lest(r = 0:12, correction = "isotropic")

        # mean of L at r = 6, 8, 10, 12 ft (Ripley's isotropic edge corrected)
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
        # implement the stem-map canopy cover model (Toney et al. 2009)

        # subplot and microplot crown overlays
        subp_overlay <- rep(NA_real_, 4)
        micr_overlay <- rep(NA_real_, 4)
        for (i in 1:4) {
            # trees in the subplot
            tree_subp <- tree_list[tree_list$SUBP == i &
                                   tree_list$STATUSCD == 1 &
                                   tree_list$DIA >= 5, ]

            if (nrow(tree_subp) == 0) {
                subp_overlay[i] <- 0
            } else {
                subp_overlay[i] <- calc_crown_overlay(tree_subp, 24)
            }

            # saplings in the microplot
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
                # apply an adjustment to the plot-level canopy cover derived
                # from crown overlay to account for the sapling contribution

                # linear regression model based on RMRS FIA line-intercept
                # field measurements for all single-condition DESIGNCD 1 plots
                # through 2005 that had subp_overlay_tcc >= 10 (FORTYPCDs 925
                # and 926 omitted)
                # coefficients given in Table 2, Toney et al. (2009)
                sapling_component <-
                    -8.036 +
                    0.211 * micr_overlay_tcc +
                    0.552 * ht_metrics$numSaplings +
                    -0.131 * ht_metrics$numTrees +
                    4.367 * log(ht_metrics$meanTreeHtBAW) +
                    0.222 * L_mean

                # constrain sapling adjustment >= 0
                sapling_component <- max(c(sapling_component, 0))

                model_tcc <-
                    min(c(subp_overlay_tcc + sapling_component, 100)) |>
                        round(digits = digits)
            }
        }

    } else {
        # FVS method for percent tree canopy cover (Crookston and Stage 1999)
        # *** assumes random tree locations ***

        if (!("TPA_UNADJ" %in% colnames(tree_list))) {
            stop("'TPA_UNADJ' is a required column in 'tree_list'",
                 call. = FALSE)
        }

        # "uncorrected" total tree canopy cover without accounting for overlap
        # may be > 100
        # Crookston and Stage (1999) Eq. 1
        tot_crown_area_per_acre <-
            sum(tree_list$TPA_UNADJ[tree_list$STATUSCD == 1] * pi *
                (tree_list$CRWIDTH[tree_list$STATUSCD == 1] / 2)^2)

        uncorrected_tcc <- 100 * tot_crown_area_per_acre / 43560

        # "corrected" TCC accounting for overlap
        # Crookston and Stage (1999) Eq. 2
        model_tcc <- round(100 * (1 - exp(-0.01 * uncorrected_tcc)), digits)
    }

    if (full_output) {
        if (stem_map) {
            return(c(
                model_tcc = model_tcc,
                subp1_crown_overlay = subp_overlay[1],
                subp2_crown_overlay = subp_overlay[2],
                subp3_crown_overlay = subp_overlay[3],
                subp4_crown_overlay = subp_overlay[4],
                subp_overlay_mean = subp_overlay_tcc,
                micr1_crown_overlay = micr_overlay[1],
                micr2_crown_overlay = micr_overlay[2],
                micr3_crown_overlay = micr_overlay[3],
                micr4_crown_overlay = micr_overlay[4],
                micr_overlay_mean = micr_overlay_tcc,
                L_6ft = L$iso[7],
                L_8ft = L$iso[9],
                L_10ft = L$iso[11],
                L_12ft = L$iso[13],
                ht_metrics))
        } else {
            return(c(
                model_tcc = model_tcc,
                ht_metrics))
        }
    } else {
        return(model_tcc)
    }
}
