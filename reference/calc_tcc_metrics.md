# Predict plot-level canopy cover from individual tree measurements

`calc_tcc_metrics()` computes plot-level predicted tree canopy cover
(TCC) from tree list data. By default, a full set of stand structure
metrics used to derive the plot-level TCC prediction are included in the
output (see Details).

## Usage

``` r
calc_tcc_metrics(tree_list, stem_map = TRUE, full_output = TRUE, digits = 1)
```

## Arguments

- tree_list:

  A data frame with tree records for one FIA plot. In general, the input
  data frame will have the columns specified in
  [DEFAULT_TREE_COLUMNS](https://ctoney.github.io/FIAstemmap/reference/DEFAULT_TREE_COLUMNS.md)
  (see
  [`?DEFAULT_TREE_COLUMNS`](https://ctoney.github.io/FIAstemmap/reference/DEFAULT_TREE_COLUMNS.md)).
  Potentially, only a subset of those columns will be needed depending
  on values given for the arguments `stem_map` and `full_output`
  described below. If the input data frame has a column named
  `"CRWIDTH"` it will be used for tree crown width values, otherwise,
  crown widths will be calculated with a call to
  [`calc_crwidth()`](https://ctoney.github.io/FIAstemmap/reference/calc_crwidth.md).

- stem_map:

  A logical value indicating whether to map individual trees explicitly
  using coordinates specified in terms of distance and azimuth from
  subplot/microplot centers. The default is `TRUE`, in which case the
  input `tree_list` must contain columns `"DIST"` and `"AZIMUTH"`. This
  argument may be set to `FALSE` if individual tree locations are not
  available, in which case TCC will be predicted assuming a random
  arrangement of the stems (see Details).

- full_output:

  A logical value indicating whether to include the full set of
  components used to derive the plot-level prediction. By default, the
  output list includes subplot-level TCC estimates, live tree and
  sapling counts, stand height metrics, and point pattern statistics,
  depending on the value given for `stem_map` (see Details).

- digits:

  Optional integer indicating the number of digits to keep in the return
  values (defaults to `1`). May be passed to
  [`calc_crwidth()`](https://ctoney.github.io/FIAstemmap/reference/calc_crwidth.md)
  and
  [`calc_ht_metrics()`](https://ctoney.github.io/FIAstemmap/reference/calc_ht_metrics.md).

## Value

If `full_output = TRUE`, a named list with the element `model_tcc`
containing plot-level predicted tree canopy cover percent (`0:100`), and
additional named elements containing stand structure metrics as
described in Details. If `full_output = FALSE`, a single numeric value
of plot-level predicted TCC is returned instead.

## Details

This function provides two methods for predicting plot-level TCC.

The default "stem-map" method requires individual tree coordinates to be
given in the input as distance and azimuth from subplot centers for
trees with diameter `>= 5 in.` (12.7 cm), and from microplot centers for
"saplings" having diameter `>= 1 in.` (2.54 cm) but `< 5 in.` (12.7 cm).
This method involves mapping trees spatially within the plot boundary to
account for crown overlap explicitly, along with empirical modeling of
the understory sapling contribution to total canopy cover (Toney et al.
2009). The empirical model for the sapling component also uses the
spatial point pattern of overstory trees as a predictor variable (using
a square root transformation of Ripley's edge-corrected K function,
Ripley 1977, Stoyan and Penttinen 2000).

Alternatively, plot-level TCC can be predicted using a simplified
approach that does not include exact stem placement
(`stem_map = FALSE`). A random arrangement of stems is assumed in that
case. This is the method used to estimate tree canopy cover in the
Forest Vegetation Simulator (Crookston and Stage 1999).

Both methods require estimates of individual tree crown width, which are
computed with
[`calc_crwidth()`](https://ctoney.github.io/FIAstemmap/reference/calc_crwidth.md)
if not provided in the input tree list.

The stem-map method also requires computation of several stand structure
metrics, as components of the overall model used to derive a plot-level
TCC estimate. These additional variables include:

- individual subplot and microplot crown overlays via
  [`calc_crown_overlay()`](https://ctoney.github.io/FIAstemmap/reference/calc_crown_overlay.md)

- a stand height metric (`meanTreeHtBAW`) and plot-level counts of
  mature trees and saplings via
  [`calc_ht_metrics()`](https://ctoney.github.io/FIAstemmap/reference/calc_ht_metrics.md)

- descriptive spatial statistics for the overstory tree point pattern
  via `create_fia_ppp() |> spatstat.explore::Lest()`

## References

Crookston, N.L. and A.R. Stage. (1999). Percent canopy cover and stand
structure statistics from the Forest Vegetation Simulator. Gen. Tech.
Rep. RMRS-GTR-24. Ogden, UT: U. S. Department of Agriculture, Forest
Service, Rocky Mountain Research Station. 11 p.
<https://research.fs.usda.gov/treesearch/6261>.

Ripley, B.D. (1977). Modelling spatial patterns. *Journal of the Royal
Statistical Society: Series B (Methodological)*, 39(2): 172–192.
<https://doi.org/10.1111/j.2517-6161.1977.tb01615.x>.

Stoyan, D., and Penttinen, A. (2000). Recent applications of point
process methods in forestry statistics. *Statistical Science*, 15(1),
61–78. <http://www.jstor.org/stable/2676677>.

Toney, C., J.D. Shaw and M.D. Nelson. 2009. A stem-map model for
predicting tree canopy cover of Forest Inventory and Analysis (FIA)
plots. In: McWilliams, Will; Moisen, Gretchen; Czaplewski, Ray, comps.
*Forest Inventory and Analysis (FIA) Symposium 2008*; October 21-23,
2008; Park City, UT. Proc. RMRS-P-56CD. Fort Collins, CO: U.S.
Department of Agriculture, Forest Service, Rocky Mountain Research
Station. 19 p. <https://research.fs.usda.gov/treesearch/33381>.

## See also

[`calc_crwidth()`](https://ctoney.github.io/FIAstemmap/reference/calc_crwidth.md),
[`calc_crown_overlay()`](https://ctoney.github.io/FIAstemmap/reference/calc_crown_overlay.md),
[`calc_ht_metrics()`](https://ctoney.github.io/FIAstemmap/reference/calc_ht_metrics.md),
[`create_fia_ppp()`](https://ctoney.github.io/FIAstemmap/reference/spatstat_helpers.md)

## Examples

``` r
calc_tcc_metrics(plantation)
#> Error in calc_tcc_metrics(plantation): could not find function "calc_tcc_metrics"
```
