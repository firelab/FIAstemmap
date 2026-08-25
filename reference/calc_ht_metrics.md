# Calculate stand height metrics from tree list data

These functions compute several stand height metrics from tree list
data.

## Usage

``` r
calc_ht_metrics(tree_list, digits = 1)

calc_landfire_stand_ht(
  subp_overlay_mean,
  micr_overlay_mean,
  numTrees,
  meanTreeHtDomBAW,
  meanTreeHtBAW,
  meanSapHt
)
```

## Arguments

- tree_list:

  A data frame with tree records for one FIA plot. Must have columns
  `DIA` (tree diameter), `HT` (tree height), `ACTUALHT` (tree actual
  height, `ACTUALHT < HT` indicating a broken top), `CCLCD` (FIA crown
  class code), `TPA_UNADJ` (trees per acre).

- digits:

  Optional integer indicating the number of digits to keep in the return
  values (defaults to `1`).

- subp_overlay_mean:

  A numeric vector, value(s) of `subp_overlay_mean` from the output of
  [`calc_tcc_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_tcc_metrics.md).

- micr_overlay_mean:

  A numeric vector, value(s) of `micr_overlay_mean` from the output of
  [`calc_tcc_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_tcc_metrics.md).

- numTrees:

  A numeric vector, value(s) of `numTrees` from the output of
  `calc_ht_metrics()`.

- meanTreeHtDomBAW:

  A numeric vector, value(s) of `meanTreeHtDomBAW` from the output of
  `calc_ht_metrics()`.

- meanTreeHtBAW:

  A numeric vector, value(s) of `meanTreeHtBAW` from the output of
  `calc_ht_metrics()`.

- meanSapHt:

  A numeric vector, value(s) of `meanTreeHmeanSapHttBAW` from the output
  of `calc_ht_metrics()`.

## Details

`calc_ht_metrics()` computes several stand height metrics for a given
tree list. The return value is a named list as described below.

`calc_landfire_stand_ht()` computes LANDFIRE stand height. This metric
is computed separately since it depends on canopy cover estimates for
the sapling and overstory layers derived by overlaying modeled crowns.
The input data are given as vectors of values for one or more plots (all
input vectors must have the same length). The return value is a numeric
vector of stand heights, with length equal to the number of elements in
each of the input vectors.

Stand height metrics are based on live trees (`STATUSCD == 1`), and are
are assigned `0` by definition if no live trees are present.
`calc_ht_metrics()`returns a named list with the following elements:

- `$numTrees`: number of live trees `>= 5.0` in. (`12.7` cm) diameter

- `$meanTreeHt`: mean height of trees `>= 5.0` in. (`12.7` cm) diameter

- `$meanTreeHtBAW`: basal-area weighted mean height of trees `>= 5.0`
  in. (`12.7` cm) diameter

- `$meanTreeHtDom`: mean height of canopy dominant/co-dominant trees
  `>= 5.0` in. (`12.7` cm) diameter

- `$meanTreeHtDomBAW`: basal-area weighted mean height of canopy
  dominant/co-dominant trees `>= 5.0` in. (`12.7` cm) diameter

- `$maxTreeHt`: height of the tallest tree `>= 5.0` in. (`12.7` cm)
  diameter

- `$predomTreeHt`: predominant tree height, as the mean height of the
  tallest trees `>= 5.0` in. (`12.7` cm) diameter comprising up to `16`
  trees per acre (`39.5` trees per hectare)

- `$numSaplings`: number of live saplings (trees `>= 1.0` in. but
  `< 5.0` in. diameter, i.e., `>= 2.54` cm but `< 12.7` cm)

- `$meanSapHt`: mean height of saplings

- `$maxSapHt`: height of the tallest sapling

For the purpose of height calculations, metrics based on "canopy
dominant/co-dominant" include open grown trees, i.e., include trees with
FIA crown class codes `CCLCD` of `1` (open grown), `2` (dominant) or `3`
(co-dominant), but exclude trees with `CCLCD` of `4` (intermediate) or
`5` (over-topped).

LANDFIRE stand height is a metric computed for FIA plots used as
reference data supporting development of the Existing Vegetation Height
(EVH) raster product (<https://www.landfire.gov/vegetation/evh>). It is
generally the basal-area weighted mean height of canopy
dominant/co-dominant trees (i.e., `meanTreeHtDomBAW`). However, this
metric attempts to identify plots that may be best characterized as
sapling stage, in which case stand height is the mean height of saplings
(`meanSapHt`). Sapling-stage plots are defined using arbitrary
thresholds of canopy cover, estimated separately for the sapling layer
based on microplot data, and the overstory tree layer based on subplot
measurements. See
[`calc_tcc_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_tcc_metrics.md)
for variable definitions. A plot is considered sapling stage if
`subp_overlay_mean <= 10` and
`micr_overlay_mean >= 3 * subp_overlay_mean`.

## Examples

``` r
calc_ht_metrics(plantation)
#> $numTrees
#> [1] 89
#> 
#> $meanTreeHt
#> [1] 44.8
#> 
#> $meanTreeHtBAW
#> [1] 45.3
#> 
#> $meanTreeHtDom
#> [1] 44.8
#> 
#> $meanTreeHtDomBAW
#> [1] 45.3
#> 
#> $maxTreeHt
#> [1] 51
#> 
#> $predomTreeHt
#> [1] 50.7
#> 
#> $numSaplings
#> [1] 2
#> 
#> $meanSapHt
#> [1] 34.5
#> 
#> $maxSapHt
#> [1] 43
#> 

calc_landfire_stand_ht(86, 11, 89, 45, 45, 34)
#> [1] 45
```
