# Calculate stand height metrics from tree list data

`calc_ht_metrics()` computes several stand height metrics for a given
tree list.

## Usage

``` r
calc_ht_metrics(tree_list, digits = 1)
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

## Value

A named list of computed height metrics for the input tree list, as
described in Details.

## Details

Stand height metrics are based on live trees (`STATUSCD == 1`), and are
are assigned `0` by definition if no live trees are present. Height
metrics are returned in a named list with the following elements:

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
#> [1] 51
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
```
