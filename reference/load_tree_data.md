# Load tree data from a file or database connection

`load_tree_data()` fetches tree records from a data source, typically a
comma-separated values (CSV) file, a SQLite database file (.db, .sqlite,
.gpkg), or a PostgreSQL database connection. Other data sources are also
possible. File-based sources can be read from compressed archives
without prior extraction if desired (e.g., .zip), and network-hosted
files can be read directly without prior download (see Details).

## Usage

``` r
load_tree_data(
  src,
  table = NULL,
  columns = DEFAULT_TREE_COLUMNS,
  sql = NULL,
  quoted_cols_as_char = TRUE
)
```

## Arguments

- src:

  A character string specifying the data source as a file name or
  database connection string (see Details).

- table:

  Optional character string giving the name of a table in `src` from
  which tree records will be fetched. Generally needed with database
  sources containing multiple tables (as opposed to a single-table
  source such as a CSV file).

- columns:

  Optional character vector specifying a subset of column names in the
  source table to include in the result set. Defaults to
  [DEFAULT_TREE_COLUMNS](https://firelab.github.io/FIAstemmap/reference/DEFAULT_TREE_COLUMNS.md).
  Can also be set to `NULL` or empty string (`""`) to read all columns
  in the source table.

- sql:

  Optional character string containing a SQL SELECT statement to execute
  on `src` (instead of selecting all records, potentially from a subset
  of columns, i.e., mutually exclusive with `table` and/or `columns`).

- quoted_cols_as_char:

  A logical value indicating whether to auto-detect columns that contain
  quoted values as `"character"` type, `TRUE` by default. Only used when
  `src` is a CSV file.

## Value

A data frame containing tree records fetched from `src`.

## Details

A data source is most commonly specified as one of the following:

CSV file  
Path to a text file with `".csv"` extension. For files structured as
CSV, but not ending with the `".csv"` extension, a `"CSV:"` prefix can
be added before the filename to force loading as CSV format.

SQLite database  
Path to a SQLite file. The file extension is generally either `".db"` or
`".sqlite"`, but GeoPackage files with the `".gpkg"` extension are also
supported.

PostgreSQL database  
A connection string in one of the following formats:

    "PG:dbname=databasename"

    "PG:dbname='db' host='addr' port='5432' user='x' password='y'"

    "PG:service=servicename"

    "postgresql://[user[:pwd]@][netloc][:port][/dbname][?param1=val1&...]"

GDAL Virtual File Systems are also supported. This allows, for example,
reading from compressed archives such as `".zip"` without prior
extraction. The syntax in that case uses the `"/vsizip/"` prefix:

    # relative path to the .zip:
    f <- "/vsizip/MT_CSV.zip/MT_TREE.csv"

    # absolute path to the .zip:
    f <- "/vsizip//home/ctoney/data/MT_CSV.zip/MT_TREE.csv"

    # on Windows:
    f <- "/vsizip/c:/users/ctoney/MT_CSV.zip/MT_TREE.csv"

Network-hosted files can also be read without prior download using the
`"/vsicurl/"` prefix:

    f <- "/vsicurl/https://apps.fs.usda.gov/fia/datamart/CSV/MT_TREE.csv"

For more details, including supported VSI prefixes for cloud storage
services and other virtual file systems, see
<https://gdal.org/en/stable/user/virtual_file_systems.html>.

## Note

`src` can be any GDAL supported dataset. A full list of formats
supported by the current GDAL installation can be obtained with:

    fmt <- gdalraster::gdal_formats()
    fmt$long_name[fmt$vector]

For more details: <https://gdal.org/en/stable/drivers/vector/index.html>

`load_tree_data()` from a PostgreSQL database requires GDAL built with
support for the PostgreSQL client library (can be checked with
`gdalraster::gdal_formats("postgresql")`).

Column names are case-sensitive in FIAstemmap functions, and are assumed
to follow the FIADB upper case naming convention.

If column `PLT_CN` is present, it will be read or coerced if necessary
to R `"character"` type consistent with its data type in FIADB (i.e., a
string but all digits).

## See also

[DEFAULT_TREE_COLUMNS](https://firelab.github.io/FIAstemmap/reference/DEFAULT_TREE_COLUMNS.md),[`process_tree_data()`](https://firelab.github.io/FIAstemmap/reference/process_tree_data.md)

## Examples

``` r
# Lolo NF, single-condition forest plots, INVYR 2022, from public FIADB
f <- system.file("extdata/mt_lnf_2022_1cond_tree.csv", package="FIAstemmap")
tree <- load_tree_data(f)
#> ! The data source does not have DIST and/or AZIMUTH.
#> ℹ Fetching tree data
#> ✔ Fetching tree data [11ms]
#> 
#> ℹ 910 tree records returned.

head(tree)
#>            PLT_CN SUBP TREE STATUSCD SPCD DIA HT ACTUALHT CCLCD TPA_UNADJ
#> 1 670951075126144    1    1        2  108  NA NA       NA    NA        NA
#> 2 670951075126144    1    2        1  108   1  9        9     3  74.96528
#> 3 670951075126144    2    1        2  108  NA NA       NA    NA        NA
#> 4 670951075126144    2    2        2  108  NA NA       NA    NA        NA
#> 5 670951075126144    2    3        2  108  NA NA       NA    NA        NA
#> 6 670951075126144    2    4        2  108  NA NA       NA    NA        NA
```
