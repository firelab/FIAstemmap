# Compute fractional tree canopy cover of a subplot/microplot by crown overlay

`calc_crown_overlay()` computes the proportion of a circular polygon
covered by a given set of tree crowns modeled as discs and having
spatially explicit stem locations. The sampled area is generally an FIA
subplot with radius 24 ft (7.315 m) for trees with diameter `>= 5 in.`
(12.7 cm), or an FIA microplot with radius 6.8 ft (2.073 m) for trees
`>= 1 in.` (2.54 cm) but `< 5 in.` (12.7 cm) diameter (denoted as
"saplings"). Stem locations are specified as distance and azimuth from
subplot/microplot center.

## Usage

``` r
calc_crown_overlay(tree_list, sample_radius, digits = 1)
```

## Arguments

- tree_list:

  A data frame containing tree records for a subplot/microplot. Must
  have columns `DIST` (stem distance from subplot/microplot center in
  the same units as `sample_radius`), `AZIMUTH` (horizontal angle from
  subplot/microplot center to the stem location, in the range `0:359`)
  and `CRWIDTH` (tree crown width in the same units as `sample_radius`
  and `DIST`).

- sample_radius:

  A numeric value giving the radius of the circular subplot/microplot.

- digits:

  Optional integer indicating the number of digits to keep in the return
  value (defaults to `1`, will be passed to
  [`round()`](https://rdrr.io/r/base/Round.html)).

## Value

Estimated tree canopy cover as percent of the area specified by
`sample_radius` that is covered by a vertical projection of circular
crowns.

## Note

This function does not perform any filtering based on `SUBP` (subplot),
`STATUSCD`(live vs dead trees) or`DIA` (mature trees vs saplings). The
input tree list is assumed to be filtered to the specific set of live
trees for one subplot or microplot with the given `sample_radius`.

## See also

[`calc_tcc_metrics()`](https://firelab.github.io/FIAstemmap/reference/calc_tcc_metrics.md)

## Examples

``` r
# subplot 1 of the `plantation` plot
trees <- within(plantation, CRWIDTH <- calc_crwidth(plantation))
trees[trees$SUBP == 1 & trees$DIA >= 5, ] |>
  calc_crown_overlay(sample_radius = 24)
#> [1] 86.8

plot_crowns(trees, subplot = 1, main = "plantation subplot 1")
```
