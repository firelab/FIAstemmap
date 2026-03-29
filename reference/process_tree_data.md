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
#> ! the data source does not have DIST and/or AZIMUTH
#> ℹ Fetching tree data...
#> ✔ Fetching tree data... [10ms]
#> 
#> ℹ 910 tree records returned.

process_tree_data(tree_table, stem_map = FALSE, full_output = TRUE)
#> ℹ The input table contains tree data for 22 plots.
#> ℹ Done.
#>             PLT_CN model_tcc numTrees meanTreeHt meanTreeHtBAW meanTreeHtDom
#> 1  670951075126144       1.2        0        0.0           0.0           0.0
#> 2  670950940126144      38.4       24       61.4          66.4          64.5
#> 3  670950992126144       3.4        1       43.0          43.0          43.0
#> 4  670950609126144      17.2        4      102.2         102.6         102.2
#> 5  670950600126144      34.9       16       62.1          79.0          69.9
#> 6  670951118126144      20.6        9       24.6          28.0          30.0
#> 7  670950964126144      37.9       16       58.8          67.1          64.1
#> 8  670951031126144      51.2       29       70.2          72.8          72.4
#> 9  670950608126144      70.8       32       73.7          94.8          86.6
#> 10 670950599126144      66.4       44       61.8          66.4          64.1
#> 11 670950967126144      57.4       23       86.0         100.7          96.1
#> 12 670950732126144      34.4       12       64.3          91.8          72.6
#> 13 670950725126144      66.5       69       66.3          87.0          73.9
#> 14 670950598126144      55.8       20       65.7          89.6          83.9
#> 15 670950965126144      81.3       74       53.1          55.1          54.5
#> 16 670951032126144      32.5        5       15.0          14.2          15.0
#> 17 670951034126144      16.4        7       40.7          45.0          40.7
#> 18 670950625126144      44.5       23       42.0          61.9          42.9
#> 19 670951029126144      55.1       33       64.7          68.5          64.7
#> 20 670951035126144      97.6       54       44.9          50.6          45.7
#> 21 670951089126144      21.1        7       79.9          83.0          79.9
#> 22 670951152126144       5.3        3       21.3          21.7          21.3
#>    meanTreeHtDomBAW maxTreeHt predomTreeHt numSaplings meanSapHt maxSapHt
#> 1               0.0         0          0.0           1       9.0        9
#> 2              67.9        85         81.7           1      16.0       16
#> 3              43.0        43         43.0           0       0.0        0
#> 4             102.6       114        106.3           0       0.0        0
#> 5              83.4       104         99.3           0       0.0        0
#> 6              34.8        47         39.7           0       0.0        0
#> 7              69.0        80         78.0           0       0.0        0
#> 8              73.6        85         83.0           0       0.0        0
#> 9              98.3       120        112.7          19      15.8       38
#> 10             67.2        84         81.7           1      14.0       14
#> 11            103.7       123        117.0           2      13.0       16
#> 12             94.2       109         93.7           0       0.0        0
#> 13             89.6       118        116.3           2      12.5       16
#> 14             97.3       128        112.0           5      11.4       18
#> 15             56.1        72         67.0           3      40.3       45
#> 16             14.2        22         18.3          15      12.3       20
#> 17             45.0        53         48.3           0       0.0        0
#> 18             63.0       104         70.0           2      20.5       25
#> 19             68.5        87         83.3           3      19.0       22
#> 20             51.2        74         66.0          27      23.5       39
#> 21             83.0        92         85.3           0       0.0        0
#> 22             21.7        24         21.3           1      14.0       14
```
