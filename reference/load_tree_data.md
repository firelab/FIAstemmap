# Load tree data from a file or database connection

`load_tree_data()` fetches tree records from a data source, most
commonly a comma-separated values (CSV) file, a SQLite database file
(.db, .sqlite, .gpkg), or a PostgreSQL database connection. Other data
sources are also possible. File-based sources can be read from
compressed archives without prior extraction (e.g., .zip), and
network-hosted files can be read directly without prior download (see
Details).

## Usage

``` r
load_tree_data(src, table = NULL, columns = DEFAULT_TREE_COLUMNS, sql = NULL)
```

## Arguments

- src:

  A character string specifying the data source as a file name or
  database connection string (see Details).

- table:

  Optional character string giving the name of a table in `src` from
  which tree records will be fetched. Generally needed with database
  sources containing multiple tables, as opposed to a single-table
  source such as a CSV file.

- columns:

  Optional character vector specifying a subset of column names in the
  source table to include in the result set.

- sql:

  Optional character string containing a SQL SELECT statement to execute
  on `src` (instead of selecting all records potentially from a subset
  of columns, i.e., mutually exclusive with `table` and/or `columns`).

## Value

A data frame containing the tree records fetched from `src`.

## Details

A data source is typically specified as one of the following:

CSV file  
Path to a text file with `".csv"` extension. For files structured as
CSV, but not ending with the `".csv"` extension, a `"CSV:"` prefix can
be added before the filename to force loading as CSV format.

SQLite database  
Path to a SQLite file. File extensions are typically `".db"` or
`".sqlite"`. GeoPackage SQLite files with `".gpkg"` extension are also
supported.

PostgreSQL database  
A connection string in one of the following formats:

    src <- "PG:dbname=databasename"

    src <- "PG:dbname='db' host='addr' port='5432' user='x' password='y'"

    src <- "PG:service=servicename"

    src <- "postgresql://[usr[:pwd]@][netloc][:port][/db][?param1=val1&...]"

GDAL Virtual File Systems are also supported. This allows, for example,
reading from compressed archives such as `".zip"` without prior
extraction. The syntax in that case uses the `"/vsizip/"` prefix:

    # relative path to the .zip:
    src <- "/vsizip/MT_CSV.zip/MT_TREE.csv"

    # absolute path to the .zip:
    src <- "/vsizip//home/ctoney/data/MT_CSV.zip/MT_TREE.csv"

    # on Windows:
    src <- "/vsizip/c:/users/ctoney/MT_CSV.zip/MT_TREE.csv"

Network-hosted files can also be read without prior download using the
`"/vsicurl/"` prefix:

    src <- "/vsicurl/https://apps.fs.usda.gov/fia/datamart/CSV/MT_TREE.csv"

For more details, including supported VSI prefixes for cloud storage
services and other virtual file systems, see
<https://gdal.org/en/stable/user/virtual_file_systems.html>.

## Note

`src` can be any GDAL supported dataset. A full list of formats
supported by the current GDAL installation can be obtained with:

    fmt <- gdalraster::gdal_formats()
    fmt$long_name[fmt$vector]

For more details: <https://gdal.org/en/stable/drivers/vector/index.html>

## Examples

``` r
# Lolo NF, single-condition forest plots, INVYR 2022, from public FIADB
f <- system.file("extdata/mt_lnf_2022_1cond_tree.csv", package="FIAstemmap")
tree <- load_tree_data(f)
#> ! The data source does not have DIST and/or AZIMUTH
#> ℹ Fetching tree data...
#> ✔ Fetching tree data... [16ms]
#> 
#> ℹ 910 tree records returned

head(tree)
#> OGR feature set (attribute table)
#>   PLT_CN          SUBP TREE STATUSCD SPCD  DIA HT ACTUALHT CCLCD TPA_UNADJ
#> 1 670951075126144 1    1    2        108.0                                
#> 2 670951075126144 1    2    1        108.0 1.0 9  9        3     74.965282
#> 3 670951075126144 2    1    2        108.0                                
#> 4 670951075126144 2    2    2        108.0                                
#> 5 670951075126144 2    3    2        108.0                                
#> 6 670951075126144 2    4    2        108.0                                
```
