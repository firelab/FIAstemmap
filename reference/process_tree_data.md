# Generate plot-level stand structure metrics for a tree dataset

`process_tree_data()` takes a table of tree records for a set of forest
inventory plots as input, and generates selected plot-level stand
structure metrics.

## Usage

``` r
process_tree_data(tree_table, stem_map = TRUE, full_output = TRUE, digits = 1)
```

## Arguments

- tree_table:

  A data frame containing tree records for a set of forest inventory
  plots. Must have column `PLT_CN` containing the plot unique identifier
  for each tree. Other required columns are those of
  [`calc_crwidth()`](https://firelab.github.io/FIAstemmap/reference/calc_crwidth.md)
  (if column `CRWIDTH` is not included),
  [`calc_ht_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_ht_metrics.md)
  and
  [`calc_tcc_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_tcc_metrics.md),
  depending on values given for `stem_map` and `full_output`.

- stem_map:

  A logical value indicating whether to map individual tree stems
  explicitly, using coordinates specified in terms of distance and
  azimuth from subplot/microplot centers. The default is `TRUE`, in
  which case the input `tree_table` must contain columns `"DIST"` and
  `"AZIMUTH"`. This argument may be set to `FALSE` if individual tree
  locations are not available, in which case TCC will be predicted
  assuming a random arrangement of tree locations (see Details for
  [`calc_tcc_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_tcc_metrics.md)).

- full_output:

  A logical value indicating whether to include the full set of
  components used to derive the plot-level TCC prediction. By default,
  the output data includes subplot-level TCC estimates, live tree and
  sapling counts, stand height metrics, and point pattern statistics,
  depending on the value given for `stem_map` (see Details for
  [`calc_tcc_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_tcc_metrics.md)).

- digits:

  Optional integer indicating the number of digits to keep in the return
  values (defaults to `1`). May be passed to
  [`calc_crwidth()`](https://firelab.github.io/FIAstemmap/reference/calc_crwidth.md)
  and
  [`calc_ht_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_ht_metrics.md).

## Value

A data frame with one row for each unique `PLT_CN` in the input
`tree_table`, and additional columns containing the output of
[`calc_tcc_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_tcc_metrics.md)
conditional on the values given for `stem_map` and `full_output`.

## See also

[`calc_ht_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_ht_metrics.md),
[`calc_tcc_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_tcc_metrics.md),
[`load_tree_data()`](https://firelab.github.io/FIAstemmap/reference/load_tree_data.md)

## Examples

``` r
# Lolo NF, single-condition forest plots, INVYR 2022, from public FIADB
f <- system.file("extdata/mt_lnf_2022_1cond_tree.csv", package="FIAstemmap")
tree_table <- load_tree_data(f)
#> ! The data source does not have DIST and/or AZIMUTH
#> ℹ Fetching tree data...
#> ✔ Fetching tree data... [10ms]
#> 
#> ℹ 910 tree records returned

process_tree_data(tree_table, stem_map = FALSE, full_output = TRUE)
#> Error: 'PLT_CN' must be character, numeric, integer or integer64
```
