#' Compute plot-level stand height metrics
#'
#' `compute_ht_metrics()` computes several stand height metrics for a given FIA
#' plot, i.e., across the full four-subplot cluster (see Details).
#'
#' @details
#' The following plot-level height metrics are returned in a named list with
#' elements:
#' * `meanTreeHt`: mean height of trees `>= 5.0` in. (`12.7` cm) diameter
#' * `meanTreeHtBAW`: basal-area weighted mean height of trees `>= 5.0` in.
#'   (`12.7` cm) diameter
#' * `meanTreeHtDom`: mean height of canopy dominant/codominant trees
#'   `>= 5.0` in. (`12.7` cm) diameter
#' * `meanTreeHtDomBAW`: basal-area weighted mean height of canopy
#'   dominant/codominant trees `>= 5.0` in. (`12.7` cm) diameter
#' * `maxTreeHt`: height of the tallest tree `>= 5.0` in. (`12.7` cm) diameter
#' * `predomTreeHt`: predominant tree height, as the mean height of the tallest
#'   trees `>= 5.0` in. (`12.7` cm) diameter comprising `16` trees per acre
#'   (`39.5` trees per hectare)
#' * `meanSapHt`: mean height of saplings (trees `>= 1.0` in. diameter but
#'   `< 5.0` in. diameter, i.e., `>= 2.54` cm but `< 12.7` cm)
#' * `maxSapHt`: height of the tallest sapling
#'
#' For the purpose of height calculations, canopy dominant/codominant include
#' "open grown" trees, i.e., include trees with FIA crown class codes (`CCLCD`)
#' of `1` (open grown), `2` (dominant) and `3` (codominant), but exclude trees
#' with `CCLCD` of `4` (intermediate) and `5` (overtopped).
#'
#' @param tree_list A data frame with tree records for one FIA plot.  Must have
#' columns `DIA` (tree diameter), `HT` (tree height), `ACTUALHT` (tree actual
#' height, `ACTUALHT < HT` indicating a broken top), `CCLCD1` (FIA crown class
#' code), `TPA_UNADJ` (trees per acre).
#' @return
#' A named list of height metrics computed for the input tree list, as described
#' in Details.
#'
compute_ht_metrics <- function(tree_list) {

    if (missing(tree_list) || is.null(tree_list))
        stop("'tree_list' is required", call. = FALSE)

    if (!is.data.frame(tree_list))
        stop("'tree_list' must be a data frame", call. = FALSE)

    required_cols <- c("DIA", "HT", "ACTUALHT", "CCLCD", "TPA_UNADJ")

    if (!all(required_cols %in% colnames(tree_list)))
        stop("'tree_list' is missing required columns", call. = FALSE)

    # separate "trees" vs "saplings" here
    if ("STATUSCD" %in% colnames(tree_list)) {
        trees_in <- tree_list[tree_list$STATUSCD == 1 & tree_list$DIA >= 5, ]
        saplings_in <- tree_list[tree_list$STATUSCD == 1 & tree_list$DIA < 5, ]
    } else {
        trees_in <- tree_list[tree_list$DIA >= 5, ]
        saplings_in <- tree_list[tree_list$DIA < 5, ]
    }

    tree_ht <- pmin(trees_in$HT, trees_in$ACTUALHT, na.rm = TRUE)
    if (any(is.na(tree_ht)))
        warning("one or more tree heights are missing", call. = FALSE)

    sapling_ht <- pmin(saplings_in$HT, saplings_in$ACTUALHT, na.rm = TRUE)
    if (any(is.na(sapling_ht)))
        warning("one or more sapling heights are missing", call. = FALSE)

    ht_metrics <- vector(mode = "list", length = 8)
    names(ht_metrics) <- c("meanTreeHt", "meanTreeHtBAW", "meanTreeHtDom",
                           "meanTreeHtDomBAW", "maxTreeHt", "predomTreeHt",
                           "meanSapHt", "maxSapHt")

    basal_area <- pi * (trees_in$DIA / 2)^2

    ht_metrics$meanTreeHt <- mean(tree_ht, na.rm = TRUE)
    ht_metrics$meanTreeHtBAW <- stats::weighted.mean(tree_ht, basal_area,
                                                     na.rm = TRUE)

    tree_ht_doms <- tree_ht[trees_in$CCLCD %in% c(1, 2, 3)]
    ht_metrics$meanTreeHtDom <- mean(tree_ht_doms, na.rm = TRUE)

    basal_area_doms <- basal_area[trees_in$CCLCD %in% c(1, 2, 3)]
    ht_metrics$meanTreeHtDomBAW <-
        stats::weighted.mean(tree_ht_doms, basal_area_doms, na.rm = TRUE)

    ht_metrics$maxTreeHt <- max(tree_ht, na.rm = TRUE)

    tree_ht_tpa <- data.frame(tree_ht, trees_in$TPA_UNADJ, check.names = FALSE)
    tree_ht_tpa <- tree_ht_tpa[order(tree_ht, decreasing = TRUE), ]
    tpa <- 0
    sum_ht <- 0
    n <- 0
    for (i in seq_len(nrow(tree_ht_tpa))) {
        sum_ht <- sum_ht + tree_ht_tpa[i, 1]
        tpa <- tpa + tree_ht_tpa[i, 2]
        n <- n + 1
        if (tpa > 16)
            break
    }






    return(ht_metrics)
}
