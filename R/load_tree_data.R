#' Load tree data from a file or database connection
#'
#' `load_tree_data()` fetches tree records from a data source, typically a
#' comma-separated values (CSV) file, a SQLite database file (.db, .sqlite,
#' .gpkg), or a PostgreSQL database connection. Other data sources are also
#' possible. File-based sources can be read from compressed archives without
#' prior extraction if desired (e.g., .zip), and network-hosted files can be
#' read directly without prior download (see Details).
#'
#' @details
#' A data source is most commonly specified as one of the following:
#'
#' CSV file\cr
#' Path to a text file with `".csv"` extension. For files structured as CSV,
#' but not ending with the `".csv"` extension, a `"CSV:"` prefix can be added
#' before the filename to force loading as CSV format.
#'
#' SQLite database\cr
#' Path to a SQLite file. The file extension is generally either `".db"` or
#' `".sqlite"`, but GeoPackage files with the `".gpkg"` extension are also
#' supported.
#'
#' PostgreSQL database\cr
#' A connection string in one of the following formats:
#' ```
#' "PG:dbname=databasename"
#'
#' "PG:dbname='db' host='addr' port='5432' user='x' password='y'"
#'
#' "PG:service=servicename"
#'
#' "postgresql://[user[:pwd]@][netloc][:port][/dbname][?param1=val1&...]"
#' ```
#'
#' GDAL Virtual File Systems are also supported. This allows, for example,
#' reading from compressed archives such as `".zip"` without prior extraction.
#' The syntax in that case uses the `"/vsizip/"` prefix:
#' ```
#' # relative path to the .zip:
#' f <- "/vsizip/MT_CSV.zip/MT_TREE.csv"
#'
#' # absolute path to the .zip:
#' f <- "/vsizip//home/ctoney/data/MT_CSV.zip/MT_TREE.csv"
#'
#' # on Windows:
#' f <- "/vsizip/c:/users/ctoney/MT_CSV.zip/MT_TREE.csv"
#' ```
#'
#' Network-hosted files can also be read without prior download using the
#' `"/vsicurl/"` prefix:
#' ```
#' f <- "/vsicurl/https://apps.fs.usda.gov/fia/datamart/CSV/MT_TREE.csv"
#' ```
#'
#' For more details, including supported VSI prefixes for cloud storage services
#' and other virtual file systems, see
#' \url{https://gdal.org/en/stable/user/virtual_file_systems.html}.
#'
#' @param src A character string specifying the data source as a file name or
#' database connection string (see Details).
#' @param table Optional character string giving the name of a table in `src`
#' from which tree records will be fetched. Generally needed with database
#' sources containing multiple tables (as opposed to a single-table source such
#' as a CSV file).
#' @param columns Optional character vector specifying a subset of column names
#' in the source table to include in the result set. Defaults to
#' [DEFAULT_TREE_COLUMNS]. Can also be set to `NULL` or empty string (`""`) to
#' read all columns in the source table.
#' @param sql Optional character string containing a SQL SELECT statement to
#' execute on `src` (instead of selecting all records, potentially from a subset
#' of columns, i.e., mutually exclusive with `table` and/or `columns`).
#' @param quoted_cols_as_char A logical value indicating whether to auto-detect
#' columns that contain quoted values as `"character"` type, `TRUE` by default.
#' Only used when `src` is a CSV file.
#' @return
#' A data frame containing tree records fetched from `src`.
#'
#' @note
#' `src` can be any GDAL supported dataset. A full list of formats supported by
#' the current GDAL installation can be obtained with:
#' ```
#' fmt <- gdalraster::gdal_formats()
#' fmt$long_name[fmt$vector]
#' ```
#'
#' For more details: \url{https://gdal.org/en/stable/drivers/vector/index.html}
#'
#' `load_tree_data()` from a PostgreSQL database requires GDAL built with
#' support for the PostgreSQL client library (can be checked with
#' `gdalraster::gdal_formats("postgresql")`).
#'
#' Column names are case-sensitive in \pkg{FIAstemmap} functions, and are
#' assumed to follow the FIADB upper case naming convention.
#'
#' If column `PLT_CN` is present, it will be read or coerced if necessary to R
#' `"character"` type consistent with its data type in FIADB (i.e., a string
#' but all digits).
#'
#' @seealso
#' [DEFAULT_TREE_COLUMNS],[process_tree_data()]
#'
#' @examples
#' # Lolo NF, single-condition forest plots, INVYR 2022, from public FIADB
#' f <- system.file("extdata/mt_lnf_2022_1cond_tree.csv", package="FIAstemmap")
#' tree <- load_tree_data(f)
#'
#' head(tree)
#' @export
load_tree_data <- function(src, table = NULL, columns = DEFAULT_TREE_COLUMNS,
                           sql = NULL, quoted_cols_as_char = TRUE) {

    if (missing(src) || is.null(src))
        stop("'src' is required")

    if (!(is.character(src) && length(src) == 1))
        stop("'src' must be a single character string")

    if (!gdalraster::ogr_ds_exists(src)) {
        cli::cli_alert_danger("connection to {.path {src}} failed")
        stop("could not connect to 'src'", call. = FALSE)
    }

    src_fmt <- gdalraster::ogr_ds_format(src)
    if (is.null(src_fmt)) {
        cli::cli_alert_danger("unsupported format: {.path {src}}")
        stop("'src' is not recognized as a supported format", call. = FALSE)
    }

    if (!is.null(table) && !is.null(sql))
        stop("'table' and 'sql' are mutually exclusive", call. = FALSE)

    if (!is.null(table) && !(is.character(table) && length(table == 1)))
        stop("'table' must be a single character string")

    if (!is.null(columns) && !is.character(columns))
        stop("'columns' must be a character vector")

    if (!is.null(sql) && !(is.character(sql) && length(sql == 1)))
        stop("'sql' must be a single character string")

    if (missing(quoted_cols_as_char) || is.null(quoted_cols_as_char)) {
        quoted_cols_as_char <- TRUE
    } else if (!(is.logical(quoted_cols_as_char) ||
                 length(quoted_cols_as_char) != 1)) {
        stop("'quoted_cols_as_char' must be a single logical value",
             call. = FALSE)
    }

    if (is.null(sql) && !is.null(columns)) {
        if (any(c("DIST", "AZIMUTH") %in% columns)) {
            tbl_tmp <- ""
            if (!is.null(table))
                tbl_tmp <- table

            if (gdalraster::ogr_field_index(src, tbl_tmp, "DIST") < 0 ||
                gdalraster::ogr_field_index(src, tbl_tmp, "AZIMUTH") < 0) {

                cli::cli_alert_warning(
                    c("the data source does not have ",
                      "{.field DIST} and/or {.field AZIMUTH}"))

                columns <- columns[!columns %in% c("DIST", "AZIMUTH")]
                if (length(columns) == 0)
                    columns = ""
            }
        }
    }

    ds <- NULL
    open_options <- character(0)

    if (src_fmt == "CSV") {
        # auto-detect column data types
        open_options <- c(open_options, "AUTODETECT_TYPE=YES")
        if (quoted_cols_as_char) {
            open_options <- c(open_options, "QUOTED_FIELDS_AS_STRING=YES")
        }

        # force PLT_CN as string data type by schema override (GDAL >= 3.11)
        # avoids copy, versus changing it later in the data frame
        tbl_tmp <- table
        if (is.null(tbl_tmp) || tbl_tmp == "") {
            tbl_tmp <- gdalraster:::.cpl_get_basename(src)
        }

        if (gdalraster::ogr_field_index(src, tbl_tmp, "PLT_CN") >= 0 &&
            gdalraster::gdal_version_num() >=
                gdalraster::gdal_compute_version(3, 11, 0)) {

            schema <- 'OGR_SCHEMA={"layers": [{"name": "%s", "fields":[{
                                   "name": "PLT_CN", "type": "String" }]}]}'

            override_schema <- sprintf(schema, tbl_tmp)
            open_options <- c(open_options, override_schema)
        }
    }

    gdalraster::push_error_handler("quiet")
    if (is.null(table) && is.null(sql)) {
        ds <- try(methods::new(gdalraster::GDALVector, src, "", TRUE,
                               open_options),
                  silent = TRUE)
    } else if (!is.null(table)) {
        ds <- try(methods::new(gdalraster::GDALVector, src, table, TRUE,
                               open_options),
                  silent = TRUE)
    } else if (!is.null(sql)) {
        ds <- try(methods::new(gdalraster::GDALVector, src, sql, TRUE,
                               open_options),
                  silent = TRUE)
    }
    gdalraster::pop_error_handler()

    if (!methods::is(ds, "Rcpp_GDALVector")) {
        cli::cli_alert_danger("Failed to access tree data in {.path {src}}")
        if (!is.null(sql))
            stop("execute SQL failed on 'src'", call. = FALSE)
        else
            stop("table access failed on 'src'", call. = FALSE)
    } else {
        on.exit(ds$close(), add = TRUE)
    }

    if (is.null(sql) && !is.null(columns) && columns[1] != "")
        ds$setSelectedFields(columns)

    cli::cli_progress_step("Fetching tree data...")
    d <- ds$fetch(-1)
    cli::cli_progress_done()

    # make it a regular data frame without gdalraster attributes
    try(d$FID <- NULL, silent = TRUE)
    class(d) <- "data.frame"
    attr(d, "gis") <- NULL

    if ("PLT_CN" %in% colnames(d) && !is.character(d$PLT_CN))
        d$PLT_CN <- as.character(d$PLT_CN)

    if (nrow(d) == 0)
        cli::cli_alert_danger("No tree records were returned.")
    else
        cli::cli_alert_info("{.val {nrow(d)}} tree records returned.")

    return(d)
}
