#' Calculate canopy base height metrics from FIA tree data
#'
#' `calc_cbh_metrics()` computes canopy base height metrics for FIA tree data
#' based on measurements of uncompacted live crown ratio (`UNCRCD`) of
#' individual trees `>= 5.0` in. (`12.7` cm) diameter. Canopy base height
#' represents the lowest height at which canopy fuel, aggregated across multiple
#' tree crowns, can propagate fire vertically (see, e.g., Mast et al. 2026).
#' This function derives individual tree crown base heights from actual tree
#' height and the uncompacted crown ratio, and computes the mean, median,
#' \eqn{20^{th}}{20th} percentile and minimum.
#'
#' @param tree_table A data frame with tree records for one or more FIA plots.
#' Must have columns `ACTUALHT` (tree actual height) and `UNCRCD` (uncompacted
#' live crown ratio as percentage).
#' @param plot_id_col Optional column name in `tree_table` of a plot unique
#' identifier. If `NULL` and no column named `PLT_CN` or `plt_cn` exists,
#' the input data are assumed to be a single tree list. If `PLT_CN` or `plt_cn`
#' exists, it will be used as the plot ID column.
#' @param digits Optional integer indicating the number of digits to keep in the
#' return values (defaults to `1`).
#' @return
#' Canopy base height metrics aggregated from individual tree crown base
#' heights: `"cbh_mean"`, `"cbh_median"`, `"cbh_pct20"` and `"cbh_min"`. If the
#' input contains tree data for a single plot without a plot ID column, a named
#' list is returned, otherwise a data frame.
#'
#' @references
#' Mast, C.N., L. Vallet, M.D. Hurteau, H. Zald, G.M. Jones, G.A. Woolsey,
#' W. Tinkham, C.M. Hoffman, E.J. Francis. 2026. Methods and implications of
#' canopy base height characterization for modeling crown fire potential.
#' _Fire Ecology_ 22(117). \doi{10.1186/s42408-026-00567-4}.
#'
#' @seealso
#' [calc_ht_metrics()], [calc_tcc_metrics()]
#'
#' @examples
#' system.file("extdata/dfir_plot.csv", package="FIAstemmap") |>
#'   load_tree_data(columns = NULL) |>
#'   calc_cbh_metrics()
#' @export
calc_cbh_metrics <- function(tree_table, plot_id_col = NULL, digits = 1) {
    if (missing(tree_table) || is.null(tree_table)) {
        stop(cli::format_error(c(
            "{.arg tree_table} is required",
            "x" = "A required argument is missing or NULL")))
    }

    if (!is.data.frame(tree_table)) {
        stop(cli::format_error(c(
            "{.arg tree_table} must be a {.cls data.frame}",
            "x" = "Invalid input type: {.cls {class(tree_table)}}")))
    }

    has_plot_id_col <- FALSE
    if (!is.null(plot_id_col)) {
        if (!(is.character(plot_id_col) && length(plot_id_col) == 1)) {
            stop(cli::format_error(c(
                "{.arg plot_id_col} must be a {.cls character} string",
                "x" = "{.arg plot_id_col} not a length-1 {.cls character} vector")))
        }
        has_plot_id_col <- TRUE
    }

    if (!has_plot_id_col) {
        if ("PLT_CN" %in% colnames(tree_table)) {
            plot_id_col <- "PLT_CN"
            has_plot_id_col <- TRUE
        } else if ("plt_cn" %in% colnames(tree_table)) {
            plot_id_col <- "plt_cn"
            has_plot_id_col <- TRUE
        }
    }

    required_cols <- c("ACTUALHT", "UNCRCD", plot_id_col)
    if (!all(required_cols %in% colnames(tree_table))) {
        stop(cli::format_error(c(
            "{.arg tree_table} is missing one or more required columns",
            "x" = "Missing column(s): {.fld {setdiff(required_cols, colnames(tree_table))}}")))
    }

    if (is.null(digits))
        digits <- 1

    plot_ids <- 1L
    if (has_plot_id_col) {
        plot_ids <- unique(tree_table[plot_id_col])
    }
    num_plots <- length(plot_ids)

    cbh <- tree_table$ACTUALHT - (tree_table$UNCRCD / 100 * tree_table$ACTUALHT)

    cbh_mean <- rep(NA_real_, num_plots)
    cbh_median <- rep(NA_real_, num_plots)
    cbh_pct20 <- rep(NA_real_, num_plots)
    cbh_min <- rep(NA_real_, num_plots)
    cbh_var_names <- c("cbh_mean", "cbh_median", "cbh_pct20", "cbh_min")

    for (i in seq_along(plot_ids)) {
        if (has_plot_id_col)
            this_cbh <- cbh[tree_table[, plot_id_col] == plot_ids[i]]
        else
            this_cbh <- cbh

        cbh_mean[i] <- mean(this_cbh, na.rm = TRUE) |>
            round(digits)
        cbh_median[i] <- stats::median(this_cbh, na.rm = TRUE) |>
            round(digits)
        cbh_pct20[i] <- stats::quantile(this_cbh, probs = 0.2, na.rm = TRUE) |>
            round(digits)
        cbh_min[i] <- min(this_cbh, na.rm = TRUE) |>
            round(digits)
    }

    if (has_plot_id_col) {
        out <- data.frame(plot_ids, cbh_mean, cbh_median, cbh_pct20, cbh_min)
        colnames(out) <- c(plot_id_col, cbh_var_names)
    } else {
        out <- list(cbh_mean, cbh_median, cbh_pct20, cbh_min)
        names(out) <- cbh_var_names
    }

    return(out)
}
