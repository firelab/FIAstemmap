# Calculate canopy base height metrics from FIA tree data

`calc_cbh_metrics()` computes canopy base height metrics for FIA tree
data based on measurements of uncompacted live crown ratio (`UNCRCD`) of
individual trees `>= 5.0` in. (`12.7` cm) diameter. Canopy base height
represents the lowest height at which canopy fuel, aggregated across
multiple tree crowns, can propagate fire vertically (see, e.g., Mast et
al. 2026). This function derives individual tree crown base heights from
actual tree height and the uncompacted crown ratio, and computes the
mean, median, \\20^{th}\\ percentile and minimum.

## Usage

``` r
calc_cbh_metrics(tree_table, plot_id_col = NULL, digits = 1)
```

## Arguments

- tree_table:

  A data frame with tree records for one or more FIA plots. Must have
  columns `ACTUALHT` (tree actual height) and `UNCRCD` (uncompacted live
  crown ratio as percentage).

- plot_id_col:

  Optional column name in `tree_table` of a plot unique identifier. If
  `NULL` and no column named `PLT_CN` or `plt_cn` exists, the input data
  are assumed to be a single tree list. If `PLT_CN` or `plt_cn` exists,
  it will be used as the plot ID column.

- digits:

  Optional integer indicating the number of digits to keep in the return
  values (defaults to `1`).

## Value

Canopy base height metrics aggregated from individual tree crown base
heights: `"cbh_mean"`, `"cbh_median"`, `"cbh_pct20"` and `"cbh_min"`. If
the input contains tree data for a single plot without a plot ID column,
a named list is returned, otherwise a data frame.

## References

Mast, C.N., L. Vallet, M.D. Hurteau, H. Zald, G.M. Jones, G.A. Woolsey,
W. Tinkham, C.M. Hoffman, E.J. Francis. 2026. Methods and implications
of canopy base height characterization for modeling crown fire
potential. *Fire Ecology* 22(117).
[doi:10.1186/s42408-026-00567-4](https://doi.org/10.1186/s42408-026-00567-4)
.

## See also

[`calc_ht_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_ht_metrics.md),
[`calc_tcc_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_tcc_metrics.md)

## Examples

``` r
system.file("extdata/dfir_plot.csv", package="FIAstemmap") |>
  load_tree_data(columns = NULL) |>
  calc_cbh_metrics()
#> ℹ Fetching tree data
#> ✔ Fetching tree data [9ms]
#> 
#> ℹ 32 tree records returned.
#>            PLT_CN cbh_mean cbh_median cbh_pct20 cbh_min
#> 1 670950967126144     29.1       29.4         9     0.9
```
