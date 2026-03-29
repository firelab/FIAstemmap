#' Calculate stand height metrics from tree list data
#'
#' `calc_ht_metrics()` computes several stand height metrics for a given tree
#' list.
#'
#' @details
#' Stand height metrics are based on live trees (`STATUSCD == 1`), and are
#' are assigned `0` by definition if no live trees are present. Height metrics
#' are returned in a named list with the following elements:
#' * `$numTrees`: number of live trees `>= 5.0` in. (`12.7` cm) diameter
#' * `$meanTreeHt`: mean height of trees `>= 5.0` in. (`12.7` cm) diameter
#' * `$meanTreeHtBAW`: basal-area weighted mean height of trees `>= 5.0` in.
#'   (`12.7` cm) diameter
#' * `$meanTreeHtDom`: mean height of canopy dominant/co-dominant trees
#'   `>= 5.0` in. (`12.7` cm) diameter
#' * `$meanTreeHtDomBAW`: basal-area weighted mean height of canopy
#'   dominant/co-dominant trees `>= 5.0` in. (`12.7` cm) diameter
#' * `$maxTreeHt`: height of the tallest tree `>= 5.0` in. (`12.7` cm) diameter
#' * `$predomTreeHt`: predominant tree height, as the mean height of the tallest
#'   trees `>= 5.0` in. (`12.7` cm) diameter comprising up to `16` trees per
#'   acre (`39.5` trees per hectare)
#' * `$numSaplings`: number of live saplings (trees `>= 1.0` in. but `< 5.0` in.
#'   diameter, i.e., `>= 2.54` cm but `< 12.7` cm)
#' * `$meanSapHt`: mean height of saplings
#' * `$maxSapHt`: height of the tallest sapling
#'
#' For the purpose of height calculations, metrics based on
#' "canopy dominant/co-dominant" include open grown trees, i.e., include trees
#' with FIA crown class codes `CCLCD` of `1` (open grown), `2` (dominant) or `3`
#' (co-dominant), but exclude trees with `CCLCD` of `4` (intermediate) or `5`
#' (over-topped).
#'
#' @param tree_list A data frame with tree records for one FIA plot.  Must have
#' columns `DIA` (tree diameter), `HT` (tree height), `ACTUALHT` (tree actual
#' height, `ACTUALHT < HT` indicating a broken top), `CCLCD` (FIA crown class
#' code), `TPA_UNADJ` (trees per acre).
#' @param digits Optional integer indicating the number of digits to keep in the
#' return values (defaults to `1`).
#' @return
#' A named list of computed height metrics for the input tree list, as described
#' in Details.
#'
#' @examples
#' calc_ht_metrics(plantation)
#' @export
calc_ht_metrics <- function(tree_list, digits = 1) {

    # TODO: support input in SI units

    if (missing(tree_list) || is.null(tree_list))
        stop("'tree_list' is required", call. = FALSE)

    if (!is.data.frame(tree_list))
        stop("'tree_list' must be a data frame", call. = FALSE)

    required_cols <- c("DIA", "HT", "ACTUALHT", "CCLCD", "TPA_UNADJ")

    if (!all(required_cols %in% colnames(tree_list)))
        stop("'tree_list' is missing required columns", call. = FALSE)

    if (is.null(digits))
        digits <- 1

    # separate "trees" vs "saplings" here
    if ("STATUSCD" %in% colnames(tree_list)) {
        trees_in <- tree_list[tree_list$STATUSCD == 1 & tree_list$DIA >= 5, ]
        saplings_in <- tree_list[tree_list$STATUSCD == 1 & tree_list$DIA < 5, ]
    } else {
        trees_in <- tree_list[tree_list$DIA >= 5, ]
        saplings_in <- tree_list[tree_list$DIA < 5, ]
    }

    tree_ht <- pmin(trees_in$HT, trees_in$ACTUALHT, na.rm = TRUE)
    if (any(is.na(tree_ht))) {
        warning("one or more tree heights are missing, NAs returned",
                call. = FALSE)
    }

    sapling_ht <- pmin(saplings_in$HT, saplings_in$ACTUALHT, na.rm = TRUE)
    if (any(is.na(sapling_ht))) {
        warning("one or more sapling heights are missing, NAs returned",
                call. = FALSE)
    }

    ht_metrics <- vector(mode = "list", length = 10)
    ht_metrics[seq_along(ht_metrics)] <- 0  # by definition

    names(ht_metrics) <- c("numTrees", "meanTreeHt", "meanTreeHtBAW",
                           "meanTreeHtDom", "meanTreeHtDomBAW", "maxTreeHt",
                           "predomTreeHt", "numSaplings", "meanSapHt",
                           "maxSapHt")

    ht_metrics$numTrees <- nrow(trees_in)
    if (nrow(trees_in) > 0) {
        ht_metrics$meanTreeHt <-
            round(mean(tree_ht), digits)

        basal_area <- pi * (trees_in$DIA / 2)^2

        ht_metrics$meanTreeHtBAW <-
            round(stats::weighted.mean(tree_ht, basal_area), digits)

        tree_ht_doms <- tree_ht[trees_in$CCLCD %in% c(1, 2, 3)]
        basal_area_doms <- basal_area[trees_in$CCLCD %in% c(1, 2, 3)]

        ht_metrics$meanTreeHtDom <-
            round(mean(tree_ht_doms), digits)

        ht_metrics$meanTreeHtDomBAW <-
            round(stats::weighted.mean(tree_ht_doms, basal_area_doms),
                  digits = digits)

        ht_metrics$maxTreeHt <- max(tree_ht)

        if (any(is.na(tree_ht)) || any(is.na(trees_in$TPA_UNADJ))) {
            ht_metrics$predomTreeHt <- NA_real_
        } else {
            tree_ht_tpa <-
                data.frame(tree_ht, trees_in$TPA_UNADJ, check.names = FALSE)

            tree_ht_tpa <- tree_ht_tpa[order(tree_ht, decreasing = TRUE), ]
            tpa <- sum_ht <- n <- 0
            for (i in seq_len(nrow(tree_ht_tpa))) {
                sum_ht <- sum_ht + tree_ht_tpa[i, 1]
                tpa <- tpa + tree_ht_tpa[i, 2]
                n <- n + 1
                if (tpa > 16)
                    break
            }
            ht_metrics$predomTreeHt <- round(sum_ht / n, digits)
        }
    }

    ht_metrics$numSaplings <- nrow(saplings_in)
    if (nrow(saplings_in) > 0) {
        ht_metrics$meanSapHt <-
            round(mean(sapling_ht), digits)

        ht_metrics$maxSapHt <- max(sapling_ht)
    }

    return(ht_metrics)
}
