# Compute fractional tree canopy cover of a subplot/microplot by crown overlay

Compute fractional tree canopy cover of a subplot/microplot by crown
overlay

## Usage

``` r
crown_overlay_pct(sample_radius, tree_list, digits = 1)
```

## Arguments

- sample_radius:

  A numeric value giving the radius of the subplot/microplot.

- tree_list:

  A data frame containing tree records for the subplot/microplot. Must
  have columns `DIST` (stem distance from subplot center in same units
  as `sample_radius`), `AZIMUTH` (horizontal angle from
  subplot/microplot center to the stem location, in the range `0:359`)
  and `CRWIDTH` (tree crown width in the same units as `sample_radius`
  and `DIST`).

- digits:

  Optional integer number of digits to keep in the result (defaults to
  `1`, will be passed to
  [`round()`](https://rdrr.io/r/base/Round.html)).

## Value

An numeric value for tree canopy cover as percent of the
subplot/microplot covered by a vertical projection of circular crowns.

## Examples

``` r
crown_overlay_pct(24, plantation[plantation$SUBP == 1 &
                                 plantation$DIA >= 5, ])
#> Error: 'g_build_collection' is not an exported object from 'namespace:gdalraster'
```
