# Predict individual tree crown width using species-specific equations

`calc_crwidth()` predicts tree crown width using species-specific
regression equations from the literature.

## Usage

``` r
calc_crwidth(tree_list, digits = 1)
```

## Arguments

- tree_list:

  A data frame containing tree records. Must have columns `SPCD` (FIA
  integer species code), `STATUSCD` (FIA integer tree status code, 1 =
  live) and `DIA` (FIA tree diameter in inches).

- digits:

  Optional integer indicating the number of digits to keep in the return
  values (defaults to `1`).

## Value

A numeric vector of length `nrow(tree_list)` with predicted crown width
in feet for live trees. `NA` is returned for trees with `STATUSCD != 1`.

## Details

Crown width is predicted from tree diameter using coefficients provided
in the lookup table
[cw_coef](https://firelab.github.io/FIAstemmap/reference/cw_coef.md)
(see
[`?cw_coef`](https://firelab.github.io/FIAstemmap/reference/cw_coef.md))
The method also incorporates adjustment factors used to derive crown
width estimates for FIA "saplings", i.e., trees less than 5.0 in. (12.7
cm) diameter but greater than or equal to 1.0 in. (2.54 cm) diameter.
Details are described in the documentation for the lookup table
[cw_sapling_adj](https://firelab.github.io/FIAstemmap/reference/cw_sapling_adj.md).

Large diameter trees in the temperate rain forests of the Pacific
Northwest region can far exceed the range of diameters in the broadly
applicable datasets that have been used to develop crown width
prediction equations (Bechtold 2003, 2004). To avoid extrapolation
beyond the range of the model fitting data in those cases,
`calc_crwidth()` makes use of the "old growth" equation presented by
Gill et al. (2000) to estimate crown width for nine tree species when
their diameter is greater than 50 in. (127 cm).

## References

Bechtold, W.A. 2003. Crown-diameter prediction models for 87 species of
stand-grown trees in the eastern United States. *Southern Journal of
Applied Forestry*, 27(4): 269-278.

Bechtold, W.A. 2004. Largest-crown-width prediction models for 53
species in the western United States. *Western Journal of Applied
Forestry*, 19(4): 245-251.

Gill, S.J., G.S. Biging, E.C. Murphy. 2000. Modeling conifer tree crown
radius and estimating canopy cover. *Forest Ecology and Management*,
126(3): 405-416.

## See also

[cw_coef](https://firelab.github.io/FIAstemmap/reference/cw_coef.md),
[cw_sapling_adj](https://firelab.github.io/FIAstemmap/reference/cw_sapling_adj.md)

## Examples

``` r
calc_crwidth(plantation)
#>  [1] 11.9 13.0 10.8 15.8 13.7 10.8 10.2  9.7 15.3 13.9 12.2 11.9 13.0  9.7 14.2
#> [16] 14.7 12.2 10.8 12.5 13.0 10.7 15.1  9.9 12.8 11.9 13.0 10.3 13.9 11.7 14.6
#> [31] 11.0 13.9 11.8 12.4 12.1 14.4 10.8  9.9 14.3 11.8 11.1 14.3 13.7 11.3 13.7
#> [46] 15.5 10.7 11.5 10.2 14.6 14.6 13.9 11.3 13.0 11.4 10.3 14.3 11.0 14.0 13.3
#> [61] 12.9 13.5 11.9 11.5 10.0 12.9  7.8 13.9 11.1 10.8 12.6 14.7 12.9 11.7 12.5
#> [76]  9.7 14.6 11.3 10.6 11.0 11.9 14.2 11.4 12.2 12.6 10.6 13.0 12.9 11.5  9.5
#> [91]  8.6
```
