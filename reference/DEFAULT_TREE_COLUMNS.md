# Names of the FIADB TREE columns used by default in FIAstemmap

`DEFAULT_TREE_COLUMNS` is a character vector of column names in the
FIADB TREE table that are used to compute various tree- and plot-level
derived variables in FIAstemmap. Note that certain outputs can be
generated without this full set of TREE attributes, but these are the
ones generally needed for all functionality in the package.

## Usage

``` r
DEFAULT_TREE_COLUMNS
```

## Source

<https://research.fs.usda.gov/products/dataandtools/fia-datamart>

## Value

A character vector of 12 strings containing the names of columns in the
FIADB TREE table used by default in FIAstemmap.

## Examples

``` r
DEFAULT_TREE_COLUMNS
#>  [1] "PLT_CN"    "SUBP"      "TREE"      "AZIMUTH"   "DIST"      "STATUSCD" 
#>  [7] "SPCD"      "DIA"       "HT"        "ACTUALHT"  "CCLCD"     "TPA_UNADJ"
```
