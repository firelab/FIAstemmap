#' Load tree data from a file or database connection
#'
#' `load_tree_data()` fetches tree records from a data source, most commonly
#' a comma-separated values (CSV) file, a SQLite database file (.db, .sqlite,
#' .gpkg), or a PostgreSQL database connection. Other data sources are also
#' possible. File-based sources can be read from compressed archives without
#' prior extraction (e.g., .zip), and network-hosted files can be read directly
#' without prior download (see Details).
#'
#' @details
#' A data source is typically specified as one of the following:
#'
#' CSV file\cr
#' Path to a text file with `".csv"` extension. For files structured as CSV,
#' but not ending with the `".csv"` extension, a `"CSV:"` prefix can be added
#' before the filename to force loading as CSV format.
#'
#' SQLite database\cr
#' Path to a SQLite file. File extensions are typically `".db"` or `".sqlite"`.
#' GeoPackage SQLite files with `".gpkg"` extension are also supported.
#'
#' PostgreSQL database\cr
#' A connection string in one of the following formats:
#' ```
#' src <- "PG:dbname=databasename"
#'
#' src <- "PG:dbname='db' host='addr' port='5432' user='x' password='y'"
#'
#' src <- "PG:service=servicename"
#'
#' src <- "postgresql://[usr[:pwd]@][netloc][:port][/db][?param1=val1&...]"
#' ```
#'
#' GDAL Virtual File Systems are also supported. This allows, for example,
#' reading from compressed archives such as `".zip"` without prior extraction.
#' The syntax in that case uses the `"/vsizip/"` prefix:
#' ```
#' # relative path to the .zip:
#' src <- "/vsizip/MT_CSV.zip/MT_TREE.csv"
#'
#' # absolute path to the .zip:
#' src <- "/vsizip//home/ctoney/data/MT_CSV.zip/MT_TREE.csv"
#'
#' # on Windows:
#' src <- "/vsizip/c:/users/ctoney/MT_CSV.zip/MT_TREE.csv"
#' ```
#'
#' Network-hosted files can also be read without prior download using the
#' `"vsicurl"` prefix:
#' ```
#' src <- "/vsicurl/https://apps.fs.usda.gov/fia/datamart/CSV/MT_TREE.csv"
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
#' sources containing multiple tables, as opposed to a single-table source such
#' as a CSV file.
#' @param columns Optional character vector specifying a subset of column names
#' in the source table to include in the result set.
#' @param sql Optional character string containing a SQL SELECT statement to
#' execute on `src` (instead of selecting all records potentially from a subset
#' of columns, i.e., mutually exclusive with `table` and/or `columns`).
#' @return
#' A data frame containing the tree records fetched from `src`.
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
#' @export
load_tree_data <- function(src, table = NULL, columns = DEFAULT_TREE_COLUMNS,
                           sql = NULL) {

    if (missing(src) || is.null(src))
        stop("'src' is required")

    if (!(is.character(src) && length(src) == 1))
        stop("'src' must be a single character string")

    if (!gdalraster::ogr_ds_exists(src)) {
        cli::cli_alert_danger("connection to {.path {src}} failed")
        stop("could not connect to 'src'", call. = FALSE)
    }

    if (!is.null(table) && !is.null(sql))
        stop("'table' and 'sql' are mutually exclusive", call. = FALSE)

    if (!is.null(table) && !(is.character(table) && length(table == 1)))
        stop("'table' must be a single character string")

    if (!is.null(columns) && !is.character(columns))
        stop("'columns' must be a character vector")

    if (!is.null(sql) && !(is.character(sql) && length(sql == 1)))
        stop("'sql' must be a single character string")

    if (is.null(sql) && !is.null(columns)) {
        if (any(c("DIST", "AZIMUTH") %in% columns)) {
            tbl <- ""
            if (!is.null(table))
                tbl <- table

            if (gdalraster::ogr_field_index(src, tbl, "DIST") < 0 ||
                gdalraster::ogr_field_index(src, tbl, "AZIMUTH") < 0) {

                cli::cli_alert_warning(c(
                    "The data source does not have ",
                    "{.field DIST} and/or {.field AZIMUTH}"))

                columns <- columns[!columns %in% c("DIST", "AZIMUTH")]
                if (length(columns) == 0)
                    columns = ""
            }
        }
    }

    ds <- NULL
    if (is.null(table) && is.null(sql)) {
        ds <- try(methods::new(gdalraster::GDALVector, src), silent = TRUE)
    } else if (!is.null(table)) {
        ds <- try(methods::new(gdalraster::GDALVector, src, table),
                  silent = TRUE)
    } else if (!is.null(sql)) {
        ds <- try(methods::new(gdalraster::GDALVector, src, sql), silent = TRUE)
    }

    if (!methods::is(ds, "Rcpp_GDALVector")) {
        cli::cli_alert_danger("failed to access tree data in {.path {src}}")
        if (!is.null(sql))
            stop("execute SQL failed on 'src'", call. = FALSE)
        else
            stop("table access failed on 'src'", call. = FALSE)
    } else {
        on.exit(ds$close(), add = TRUE)
    }

    if (!is.null(columns) && columns[1] != "")
        ds$setSelectedFields(columns)

    cli::cli_progress_step("Fetching tree data...")
    d <- ds$fetch(-1)
    cli::cli_progress_done()

    if (nrow(d) == 0)
        cli::cli_alert_danger("No tree records were returned")
    else
        cli::cli_alert_info("{.val {nrow(d)}} tree records returned")

    return(d)
}
