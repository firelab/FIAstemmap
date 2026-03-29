#' Generate plot-level stand structure metrics for a tree dataset
#'
#' `process_tree_data()` takes a table of tree records for a set of forest
#' inventory plots as input, and generates selected plot-level stand structure
#' metrics.
#'
#' @param tree_table A data frame containing tree records for a set of forest
#' inventory plots. Must have column `PLT_CN` containing the plot unique
#' identifier for each tree. Other required columns are those of
#' `calc_crwidth()` (if column `CRWIDTH` is not included), `calc_ht_metrics()`
#' and `calc_tcc_metrics()`, depending on values given for `stem_map` and
#' `full_output`.
#' @param stem_map A logical value indicating whether to map individual tree
#' stems explicitly, using coordinates specified in terms of distance and
#' azimuth from subplot/microplot centers. The default is `TRUE`, in which case
#' the input `tree_table` must contain columns `"DIST"` and `"AZIMUTH"`. This
#' argument may be set to `FALSE` if individual tree locations are not
#' available, in which case TCC will be predicted assuming a random arrangement
#' of tree locations (see Details for [calc_tcc_metrics()]).
#' @param full_output A logical value indicating whether to include the full set
#' of components used to derive the plot-level TCC prediction. By default, the
#' output data includes subplot-level TCC estimates, live tree and sapling
#' counts, stand height metrics, and point pattern statistics, depending on the
#' value given for `stem_map` (see Details for [calc_tcc_metrics()]).
#' @param digits Optional integer indicating the number of digits to keep in the
#' return values (defaults to `1`). May be passed to `calc_crwidth()` and
#' `calc_ht_metrics()`.
#' @return
#' A data frame with one row for each unique `PLT_CN` in the input `tree_table`,
#' and additional columns containing the output of `calc_tcc_metrics()`
#' conditional on the values given for `stem_map` and `full_output`.
#'
#' @seealso
#' [calc_ht_metrics()], [calc_tcc_metrics()], [load_tree_data()]
#'
#' @examples
#' # Lolo NF, single-condition forest plots, INVYR 2022, from public FIADB
#' f <- system.file("extdata/mt_lnf_2022_1cond_tree.csv", package="FIAstemmap")
#' tree_table <- load_tree_data(f)
#'
#' process_tree_data(tree_table, stem_map = FALSE, full_output = TRUE)
#' @export
process_tree_data <- function(tree_table, stem_map = TRUE, full_output = TRUE,
                              digits = 1) {

    if (missing(tree_table) || is.null(tree_table))
        stop("'tree_table' is required", call. = FALSE)

    if (!is.data.frame(tree_table))
        stop("'tree_table' must be a data frame", call. = FALSE)

    if (!("PLT_CN" %in% colnames(tree_table))) {
        stop("'tree_table' must have column 'PLT_CN' with unique plot IDs",
             call. = FALSE)
    }

    if (!(is.logical(stem_map) && length(stem_map) == 1))
        stop("'stem_map' must be a single logical value", call. = FALSE)

    if (!(is.logical(full_output) && length(full_output) == 1))
        stop("'full_output' must be a single logical value", call. = FALSE)

    if (is.null(digits))
        digits <- 1

    plot_id_dt <- storage.mode(tree_table$PLT_CN)
    if (!(plot_id_dt %in% c("character", "numeric", "integer", "integer64"))) {
        stop("'PLT_CN' must be character, numeric, integer or integer64",
             call. = FALSE)
    }
    plot_ids <- unique(tree_table$PLT_CN)
    num_plots <- length(plot_ids)

    # avoid creating a new owin on every call, pass through to create_fia_ppp()
    w <- create_fia_owin()

    # get the output for one plot, this validates input columns and defines
    # the output data structure
    tree_list <- tree_table[tree_table$PLT_CN == plot_ids[1], ]
    x <- calc_tcc_metrics(tree_list, stem_map, full_output, digits, window = w)

    out <- vector("list", 1 + length(x))
    names(out) <- c("PLT_CN", names(x))

    if (plot_id_dt == "character")
        out$PLT_CN <- character(num_plots)
    else if (plot_id_dt == "numeric")
        out$PLT_CN <- rep(NA_real_, num_plots)
    else if (plot_id_dt == "integer")
        out$PLT_CN <- rep(NA_integer_, num_plots)
    else if (plot_id_dt == "integer64")
        out$PLT_CN <- rep(bit64::NA_integer64_, num_plots)

    for (j in 2:length(out)) {
        if (storage.mode(x[[j - 1]]) == "integer")
            out[[j]] <- rep(NA_integer_, num_plots)
        else
            out[[j]] <- rep(NA_real_, num_plots)
    }

    cli::cli_progress_bar("Processing tree data", total = num_plots)
    for (i in seq_along(plot_ids)) {
        tree_list <- tree_table[tree_table$PLT_CN == plot_ids[i], ]
        x <- calc_tcc_metrics(tree_list, stem_map, full_output, digits,
                              window = w)
        out$PLT_CN[i] <- plot_ids[i]
        for (j in 2:length(out)) {
            out[[j]][i] <- x[[j - 1]]
        }
        cli::cli_progress_update()
    }
    cli::cli_progress_done()

    as.data.frame(out)
}
